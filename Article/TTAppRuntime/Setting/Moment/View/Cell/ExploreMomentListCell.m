//
//  ExploreMomentListCell.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-14.
//
//

#import "ExploreMomentListCell.h"
#import "ExploreMomentListCellDiggUsersItemView.h"
#import "ExploreMomentListCellCommentListItemView.h"
#import "ArticleDetailHeader.h"
#import "ExploreMomentDefine.h"
#import "SSUserModel.h"
#import "TTIndicatorView.h"
#import "ArticleMomentCommentModel.h"
#import <TTAccountBusiness.h>
#import "ExploreDeleteManager.h"
#import "NetworkUtilities.h"
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "ArticleMomentGroupModel.h"
#import "TTTabBarProvider.h"

#define kNoDiggUsersAndCommentItemBottomPadding 10
#define KHasCommentItemBottomPadding 10
#define KBottomCommentsHasMoreBottomPadding 10
#define kBottomIsDiggUsersItemBottomPadding 10

#define kDeleteCommentActionSheetTag 1

@interface ExploreMomentListCell()<UIActionSheetDelegate, ExploreMomentListCellCommentListItemViewDelegate>

@property(nonatomic, strong)ExploreMomentListCellDiggUsersItemView * diggUsersItemView;
@property(nonatomic, strong)ExploreMomentListCellCommentListItemView * commentListItemView;
@property(nonatomic, strong)UIView * lineView;
//@property(nonatomic, strong)UIView * diggCommentItemSeparatorLine;

@property(nonatomic, strong)ArticleMomentCommentModel * needDeleteCommentModel;

@end

@implementation ExploreMomentListCell

- (void)dealloc
{
    [self.momentModel removeObserver:self forKeyPath:@"commentsCount"];
    [self.momentModel removeObserver:self forKeyPath:@"diggUsers"];
    [self.momentModel removeObserver:self forKeyPath:@"comments"];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.lineView = [[UIView alloc] initWithFrame:[self _lineViewFrame]];
        [self addSubview:_lineView];
        
        [self themeChanged:nil];
    }
    return self;
}

- (CGRect)_lineViewFrame
{
    return CGRectMake(0, 0, CGRectGetWidth(self.frame), [TTDeviceHelper ssOnePixel]);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.lineView.frame = [self _lineViewFrame];
    [self _layoutViews];
    [self bringSubviewToFront:self.lineView];
}

- (void)_layoutViews
{
    NSDictionary * userInfo = @{kMomentListCellItemBaseUserInfoSourceTypeKey:@(self.sourceType)};
    
    ArticleMomentModel *model = self.momentModel;
    BOOL needShowHeaderItem = [ExploreMomentListCellHeaderItem needShowForModel:self.momentModel userInfo:userInfo];
    CGFloat width = CGRectGetWidth(self.frame);
    if (needShowHeaderItem) {
        if (!_headerItem) {
            self.headerItem = [[ExploreMomentListCellHeaderItem alloc] initWithWidth:width userInfo:userInfo];
            _headerItem.sourceType = self.sourceType;
            [self addSubview:_headerItem];
        }
        _headerItem.cellWidth = width;
    }
    
    BOOL needShowDiggUsersItemView = [ExploreMomentListCellDiggUsersItemView needShowForModel:model userInfo:userInfo];
    if (needShowDiggUsersItemView) {
        if (!_diggUsersItemView) {
            self.diggUsersItemView = [[ExploreMomentListCellDiggUsersItemView alloc] initWithWidth:width userInfo:userInfo];
            [self addSubview:_diggUsersItemView];
        }
        _diggUsersItemView.hidden = NO;
        _diggUsersItemView.cellWidth = width;
    }
    else {
        _diggUsersItemView.hidden = YES;
    }
    
    BOOL needShowCommentListItemView = [ExploreMomentListCellCommentListItemView needShowForModel:model userInfo:userInfo];
    if (needShowCommentListItemView) {
        if (!_commentListItemView) {
            self.commentListItemView = [[ExploreMomentListCellCommentListItemView alloc] initWithWidth:width userInfo:userInfo];
            _commentListItemView.delegate = self;
            [self addSubview:_commentListItemView];
        }
        _commentListItemView.hidden = NO;
        _commentListItemView.cellWidth = width;
    }
    else {
        _commentListItemView.hidden = YES;
    }
    //设置数据
    CGFloat originY = 0;
    
    if (needShowHeaderItem) {
        _headerItem.top = originY;
        [_headerItem refreshForMomentModel:model];
        [_headerItem.actionItemView.commentButton addTarget:self action:@selector(headerItemCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        originY = (_headerItem.bottom);
        
        if (needShowDiggUsersItemView || needShowCommentListItemView) {
            
            [self themeChanged:nil];
        }
    }
    CGFloat bottomPadding = kNoDiggUsersAndCommentItemBottomPadding;
    
    if (needShowDiggUsersItemView) {
        _diggUsersItemView.top = originY;
        [_diggUsersItemView refreshForMomentModel:model];
        originY = (_diggUsersItemView.bottom);
        bottomPadding = kBottomIsDiggUsersItemBottomPadding;
    }
    
    if (needShowCommentListItemView) {
        _commentListItemView.top = originY;
        [_commentListItemView refreshForMomentModel:model];
        originY = (_commentListItemView.bottom);
        if ([ExploreMomentListCellCommentListItemView needShowHasMoreView:model]) {
            bottomPadding = KBottomCommentsHasMoreBottomPadding;
        }
        else {
            bottomPadding = KHasCommentItemBottomPadding;
        }
    }
    
    originY += bottomPadding - [TTDeviceHelper ssOnePixel];
    _lineView.top = originY;
}

- (void)refreshWithModel:(ArticleMomentModel *)model indexPath:(NSIndexPath *)indexPath
{
    [self.momentModel removeObserver:self forKeyPath:@"commentsCount"];
    [self.momentModel removeObserver:self forKeyPath:@"diggUsers"];
    [self.momentModel removeObserver:self forKeyPath:@"comments"];
    [super refreshWithModel:model indexPath:indexPath];
    [self.momentModel addObserver:self forKeyPath:@"diggUsers" options:NSKeyValueObservingOptionNew context:nil];
    [self.momentModel addObserver:self forKeyPath:@"comments" options:NSKeyValueObservingOptionNew context:nil];
    [self.momentModel addObserver:self forKeyPath:@"commentsCount" options:NSKeyValueObservingOptionNew context:nil];
    //生成view
    [self _layoutViews];
}

- (void)themeChanged:(NSNotification *)notification
{
    _lineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
}

- (void)showMomentDetailView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(momentListCell:openCommentDetailForModel:)]) {
        [self.delegate momentListCell:self openCommentDetailForModel:self.momentModel];
    }
}

- (void)headerItemCommentButtonClicked:(id)sender
{
    if (self.sourceType == ArticleMomentSourceTypeMoment) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar] ) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"comment" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
    }
    
    if (self.momentModel.commentsCount > 0) {
        wrapperTrackEventWithCustomKeys(@"update_detail", @"enter", self.momentModel.ID, nil, @{@"ext_value": self.momentModel.itemType == MomentItemTypeForum? @"2": @"3",
                                                                                           @"source": @"6"});
        [self showMomentDetailView];
    } else {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(momentListCell:commentButtonClicked:rectInKeyWindow:)]) {
            UIButton * commentButton = (UIButton *)sender;
            CGRect rect = [commentButton.superview convertRect:commentButton.frame toView:nil];
            [self.delegate momentListCell:self commentButtonClicked:nil rectInKeyWindow:rect];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"diggUsers"] ||
        [keyPath isEqualToString:@"comments"] ||
        [keyPath isEqualToString:@"commentsCount"]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(momentListCell:needReloadForIndex:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate momentListCell:self needReloadForIndex:self.cellIndex.row];
            });
        }
        
    }
}

+ (CGFloat)heightForModel:(ArticleMomentModel *)model cellWidth:(CGFloat)width sourceType:(ArticleMomentSourceType)sourceType
{
    NSDictionary * userInfo = @{kMomentListCellItemBaseUserInfoSourceTypeKey:@(sourceType)};
    CGFloat headerHeight = [ExploreMomentListCellHeaderItem heightForMomentModel:model cellWidth:width userInfo:userInfo];
    CGFloat diggHeight = [ExploreMomentListCellDiggUsersItemView heightForMomentModel:model cellWidth:width userInfo:userInfo];
    CGFloat commentHeight = [ExploreMomentListCellCommentListItemView heightForMomentModel:model cellWidth:width userInfo:userInfo];

    CGFloat height = headerHeight + diggHeight + commentHeight;
    
    CGFloat bottomPadding = kNoDiggUsersAndCommentItemBottomPadding;
    if (diggHeight > 0) {
        bottomPadding = kBottomIsDiggUsersItemBottomPadding;
    }
    if (commentHeight > 0) {
        if ([ExploreMomentListCellCommentListItemView needShowHasMoreView:model]) {
            bottomPadding = KBottomCommentsHasMoreBottomPadding;
        }
        else {
            bottomPadding = KHasCommentItemBottomPadding;
        }
    }
    
    return height + bottomPadding;
}

#pragma mark - ExploreMomentListCellCommentListItemViewDelegate

- (void)momentCellCommentViewShowMoreLabelClicked:(ExploreMomentListCellCommentListItemView *)view
{
    //[self commentButtonClicked];
    if (self.momentModel.visibleCommentsCount < (int)[self.momentModel.comments count]) {
        self.momentModel.visibleCommentsCount = (int)[self.momentModel.comments count];
        if (self.delegate && [self.delegate respondsToSelector:@selector(momentListCell:needReloadForIndex:)]) {
            [self.delegate momentListCell:self needReloadForIndex:self.cellIndex.row];
        }
    } else {
        wrapperTrackEventWithCustomKeys(@"update_detail", @"enter", self.momentModel.ID, nil, @{@"ext_value": self.momentModel.itemType == MomentItemTypeForum? @"2": @"3",
                                                                                @"source": @"5"});
        [self showMomentDetailView];
    }
}

- (void)momentCellCommentView:(ExploreMomentListCellCommentListItemView *)view commentButtonClicked:(ArticleMomentCommentModel *)commentModel rectInKeyWindow:(CGRect)rect
{
    if ([commentModel.user.ID longLongValue] == [[TTAccountManager userID] longLongValue]) {
        // delete comment
        if (!isEmptyString(commentModel.ID)) {
            self.needDeleteCommentModel = commentModel;
            UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"确定删除此评论?", nil) delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles:nil, nil];
            sheet.tag = kDeleteCommentActionSheetTag;
            [sheet showInView:self];
        }
        else {
            self.needDeleteCommentModel = nil;
        }
        
        return;
    }
    
    if (self.sourceType == ArticleMomentSourceTypeMoment) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"reply" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(momentListCell:commentButtonClicked:rectInKeyWindow:)]) {
        [self.delegate momentListCell:self commentButtonClicked:commentModel rectInKeyWindow:rect];
    }
}

- (void)momentCellCommentViewWriteCommentButtonClicked:(ExploreMomentListCellCommentListItemView *)view rectInKeyWindow:(CGRect)rect
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(momentListCell:commentButtonClicked:rectInKeyWindow:)]) {
        [self.delegate momentListCell:self commentButtonClicked:nil rectInKeyWindow:rect];
    }
}

#pragma mark -- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kDeleteCommentActionSheetTag) {
        if ([_needDeleteCommentModel.ID longLongValue] != 0 &&
            buttonIndex != actionSheet.cancelButtonIndex) {
            if (!TTNetworkConnected()) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            }
            else {
                if (_needDeleteCommentModel) {
                    if (self.sourceType == ArticleMomentSourceTypeMoment) {
                        wrapperTrackEvent(@"delete", @"reply_update");
                    } else if (self.sourceType == ArticleMomentSourceTypeForum) {
                        wrapperTrackEvent(@"delete", @"reply_post");
                    } else if (self.sourceType == ArticleMomentSourceTypeProfile) {
                        wrapperTrackEvent(@"delete", @"reply_profile");
                    }
                    
                    [[ExploreDeleteManager shareManager] deleteMomentCommentForCommentID:[NSString stringWithFormat:@"%@", _needDeleteCommentModel.ID]];
                    [self.momentModel deleteComment:_needDeleteCommentModel];
                }
            }
        }
        self.needDeleteCommentModel = nil;
    }
}

@end
