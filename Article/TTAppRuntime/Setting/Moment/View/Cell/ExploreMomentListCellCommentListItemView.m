//
//  ExploreMomentListCellCommentListItemView.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-16.
//
//

#import "ExploreMomentListCellCommentListItemView.h"
#import "SSAttributeLabel.h"
#import "ArticleMomentListCellCommentItem.h"
#import "ArticleMomentListCellCommentItemManager.h"
#import "ArticleMomentCommentModel.h"
#import "SSUserModel.h"
#import "ArticleMomentHelper.h"
#import "SSAttributeLabel.h"
#import "NewsUserSettingManager.h"
#import "ExploreMomentListCellDiggUsersItemView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "UIImage+TTThemeExtension.h"
#import "TTTabBarProvider.h"

#define kViewNoDiggUsersTopPadding 8

#define kViewBottomPadding 10
#define kShowMoreLabelTopPadding 5
#define kCommentItemPadding 10
//#define kShowCommentMaxNumber 15

#define kCommentLabelLeftPadding (9 + kMomentCellItemViewLeftPadding)
#define kCommentLabelRightPadding (9 + kMomentCellItemViewRightPadding)

#define kWriteCommentButtonWidth 94
#define kWriteCommentButtonHeight 30
#define kWriteCommentButtonTopPadding 4
#define kWriteCommentButtonTopPaddingWithoutShowMoreButton 10

@interface ExploreMomentListCellCommentListItemView()<ArticleMomentListCellCommentItemDelegate, SSAttributeLabelModelDelegate>

@property(nonatomic, strong)NSMutableArray * commentItems;
//@property(nonatomic, strong)SSAttributeLabel * showMoreLabel;
@property(nonatomic, strong)UIButton * showMoreButton;
@property(nonatomic, copy)NSString * showMoreStr;
@property(nonatomic, strong)UIButton * writeCommentButton;
@property(nonatomic, strong)UIView * bgView;

@end

@implementation ExploreMomentListCellCommentListItemView

- (void)dealloc
{
    [_writeCommentButton removeObserver:self forKeyPath:@"highlighted"];
    [self recycleItems];
}

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.bgView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_bgView];
        
        self.commentItems = [NSMutableArray arrayWithCapacity:10];
                
        self.showMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _showMoreButton.backgroundColor = [UIColor clearColor];
        _showMoreButton.hidden = YES;
        _showMoreButton.titleLabel.font = [UIFont systemFontOfSize:[NewsUserSettingManager settedMomentDiggCommentFontSize]];
        [_showMoreButton addTarget:self action:@selector(ShowMoreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_showMoreButton];
        
        self.writeCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _writeCommentButton.size = CGSizeMake(kWriteCommentButtonWidth, kWriteCommentButtonHeight);
        _writeCommentButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _writeCommentButton.layer.cornerRadius = 15.f;
        [_writeCommentButton setTitle:@" 写评论" forState:UIControlStateNormal];
        [_writeCommentButton setTitle:@" 写评论" forState:UIControlStateHighlighted];
        _writeCommentButton.titleLabel.font = [UIFont systemFontOfSize:[NewsUserSettingManager settedMomentDiggCommentFontSize]];
        _writeCommentButton.backgroundColor = [UIColor clearColor];
        [_writeCommentButton addTarget:self action:@selector(writeCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_writeCommentButton];
        
        [_writeCommentButton addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshForMomentModel:self.momentModel];
}

- (void)themeChanged:(NSNotification *)notification
{
    [_showMoreButton setTitleColor:[UIColor tt_themedColorForKey:kColorText5] forState:UIControlStateNormal];
    [_showMoreButton setTitleColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"95a3be" nightColorName:@"4d5866"]] forState:UIControlStateHighlighted];
    
    [_writeCommentButton setImage:[UIImage themedImageNamed:@"writeicon_review_dynamic.png"] forState:UIControlStateNormal];
    [_writeCommentButton setImage:[UIImage themedImageNamed:@"writeicon_review_dynamic.png"] forState:UIControlStateHighlighted];
    [_writeCommentButton setTitleColor:[UIColor tt_themedColorForKey:kColorText5] forState:UIControlStateNormal];
    [_writeCommentButton setTitleColor:[UIColor tt_themedColorForKey:kColorText5Highlighted] forState:UIControlStateHighlighted];
    _writeCommentButton.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground1].CGColor;

    _bgView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
}


// Expand the click scope

- (void)expandShowMoreButton
{
    CGPoint center = _showMoreButton.center;
    CGSize size = _showMoreButton.bounds.size;
    
    CGFloat newHeight = size.height + 5.f;
    CGFloat newWidth = size.width + 5.f;
    _showMoreButton.size = CGSizeMake(newWidth, newHeight);
    _showMoreButton.center = center;
}

- (void)recycleItems
{
    for (ArticleMomentListCellCommentItem * item in _commentItems) {
        [[ArticleMomentListCellCommentItemManager shareManager] queueReusableCommentItem:item];
        [item removeFromSuperview];
        item.delegate = nil;
    }
    [_commentItems removeAllObjects];
}

- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    [super refreshForMomentModel:model];
    [self recycleItems];
    
    if ([self.momentModel.comments count] == 0) {
        CGRect frame = self.frame;
        frame.size.height = 0;
        self.frame = frame;
        return;
    }
    
    BOOL hasDiggUsers = [ExploreMomentListCellDiggUsersItemView needShowForModel:model userInfo:nil];
    
    CGFloat originY = hasDiggUsers ? 0 : kViewNoDiggUsersTopPadding;
    
    BOOL showAllComments = ([model.comments count] <= model.visibleCommentsCount);
    NSUInteger needShowCommentsCount = showAllComments ? [model.comments count] : model.visibleCommentsCount;
    for (NSUInteger i = 0; i < needShowCommentsCount; i ++) {
        ArticleMomentListCellCommentItem * item = [[ArticleMomentListCellCommentItemManager shareManager] dequeueReusableCommentItem];
        if (!item) {
            item = [[ArticleMomentListCellCommentItem alloc] initWithFrame:CGRectZero];
        }
        item.delegate = self;
        item.orderIndex = i;
        item.sourceType = self.sourceType;
        
        ArticleMomentCommentModel * model = [self.momentModel.comments objectAtIndex:i];
        [item refreshWithCommentModel:model cellWidth:self.width];
        
        item.origin = CGPointMake(0, originY);
        originY = CGRectGetMaxY(item.frame) + kCommentItemPadding;
        [self addSubview:item];
        [_commentItems addObject:item];
    }
    
    if ([_commentItems count] > 0) {
        originY -= kCommentItemPadding;
    }
    
    if ([ExploreMomentListCellCommentListItemView needShowHasMoreView:model]) {
        if (showAllComments) {
            self.showMoreStr = @"全部评论";
        }
        else {
            self.showMoreStr = @"更多评论";
        }
        _showMoreButton.hidden = NO;
        [_showMoreButton setTitle:_showMoreStr forState:UIControlStateNormal];
        [_showMoreButton setTitle:_showMoreStr forState:UIControlStateHighlighted];
        [_showMoreButton sizeToFit];
        CGRect frame = _showMoreButton.frame;
        frame.origin.x = kCommentLabelLeftPadding;
        frame.origin.y = originY + ([_commentItems count] > 0 ? kShowMoreLabelTopPadding : 0);
        _showMoreButton.frame = frame;
        originY = (_showMoreButton.bottom);
    } else {
        _showMoreButton.hidden = YES;
    }
    
    //originY += (originY == 0 ? 0 : kWriteCommentButtonTopPadding);
    originY += [ExploreMomentListCellCommentListItemView needShowHasMoreView:model] ? kWriteCommentButtonTopPadding : kWriteCommentButtonTopPaddingWithoutShowMoreButton;
    _writeCommentButton.origin = CGPointMake(kCommentLabelLeftPadding, originY);
    
    _bgView.frame = CGRectMake(kMomentCellItemViewLeftPadding, 0, self.width - kMomentCellItemViewLeftPadding - kMomentCellItemViewRightPadding, self.height);
    
    if (!_showMoreButton.hidden) {
        [self expandShowMoreButton];
    }
    
}

+ (BOOL)needShowHasMoreView:(ArticleMomentModel *)model
{
    return MIN(model.visibleCommentsCount, [model.comments count]) < model.commentsCount ? YES : NO;
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellCommentListItemView heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo];
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)momentModel cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    if (![self needShowForModel:momentModel userInfo:uInfo]) {
        return 0;
    }

    BOOL hasDiggUsers = [ExploreMomentListCellDiggUsersItemView needShowForModel:momentModel userInfo:nil];
    CGFloat height = hasDiggUsers ? 0 : kViewNoDiggUsersTopPadding;
    
    int needShowCommentsCount = momentModel.visibleCommentsCount < [momentModel.comments count] ? momentModel.visibleCommentsCount : (int)[momentModel.comments count];
    for (int i = 0; i < needShowCommentsCount; i ++) {
        ArticleMomentCommentModel * model = [momentModel.comments objectAtIndex:i];
        
        CGFloat h = [ArticleMomentListCellCommentItem heightForCommentModel:model cellWidth:cellWidth];
        height += h;
        height += kCommentItemPadding;
    }
    if (needShowCommentsCount > 0) {
        height -= kCommentItemPadding;
    }
    
    if ([ExploreMomentListCellCommentListItemView needShowHasMoreView:momentModel]) {
        height += (needShowCommentsCount > 0 ? kShowMoreLabelTopPadding : 0);
        //UIFont * font = [UIFont systemFontOfSize:[NewsUserSettingManager settedMomentDiggCommentFontSize]];
        //height += font.lineHeight;
        UIButton * tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tmpButton setTitle:@"全部评论" forState:UIControlStateNormal];
        [tmpButton sizeToFit];
        height += (tmpButton.height);
    }
    
    //height += (height == 0 ? 0 : kWriteCommentButtonTopPadding) + kWriteCommentButtonHeight;
    height += ([ExploreMomentListCellCommentListItemView needShowHasMoreView:momentModel] ? kWriteCommentButtonTopPadding : kWriteCommentButtonTopPaddingWithoutShowMoreButton) + kWriteCommentButtonHeight;
    
    height += kViewBottomPadding;
    
    return height;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    if ([model.comments count] == 0) {
        return NO;
    }
    return YES;
}

- (void)writeCommentButtonClicked:(id)sender
{
    
    if (self.sourceType == ArticleMomentSourceTypeMoment) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"add_comment" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
        else {
            wrapperTrackEvent(@"update_tab", @"add_comment");
        }
    } else if (self.sourceType == ArticleMomentSourceTypeForum) {
        wrapperTrackEvent(@"topic_tab", @"add_comment");
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(momentCellCommentViewWriteCommentButtonClicked:rectInKeyWindow:)]) {
        CGRect rect = [self convertRect:_writeCommentButton.frame toView:[[UIApplication sharedApplication] keyWindow]];
        [_delegate momentCellCommentViewWriteCommentButtonClicked:self rectInKeyWindow:rect];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"highlighted"] && object == _writeCommentButton) {
        if (_writeCommentButton.highlighted) {
            _writeCommentButton.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground1];
        } else {
            _writeCommentButton.backgroundColor = [UIColor clearColor];
        }
    }
}

#pragma mark -- ArticleMomentListCellCommentItemDelegate

- (void)commentItemDidSeletedCommentButton:(ArticleMomentListCellCommentItem *)item
{
    if (item.orderIndex < [_commentItems count]) {
        
        CGRect rect = [item.superview convertRect:item.frame toView:[[UIApplication sharedApplication] keyWindow]];
        
        ArticleMomentCommentModel * model = [self.momentModel.comments objectAtIndex:item.orderIndex];
        if (_delegate && [_delegate respondsToSelector:@selector(momentCellCommentView:commentButtonClicked:rectInKeyWindow:)]) {
            [_delegate momentCellCommentView:self commentButtonClicked:model rectInKeyWindow:rect];
        }
    }
}

- (void)commentItemDidSeletedReplyNameButton:(ArticleMomentListCellCommentItem *)item
{
    if (item.orderIndex < [_commentItems count]) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"replier_avatar" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
        ArticleMomentCommentModel * model = [self.momentModel.comments objectAtIndex:item.orderIndex];
        [ArticleMomentHelper openMomentProfileView:model.replyUser navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedCom];
    }
}

- (void)commentItemDidSeletedNameButton:(ArticleMomentListCellCommentItem *)item
{
    if (item.orderIndex < [_commentItems count]) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"replier_avatar" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
        ArticleMomentCommentModel * model = [self.momentModel.comments objectAtIndex:item.orderIndex];
        [ArticleMomentHelper openMomentProfileView:model.user navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedCom];
    }
}

- (void)ShowMoreButtonClicked:(id)sender
{
    if (self.sourceType == ArticleMomentSourceTypeMoment) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            if ([self.momentModel.comments count] <= self.momentModel.visibleCommentsCount) {
                [TTTrackerWrapper event:@"micronews_tab" label:@"all_comments" value:nil extValue:nil extValue2:nil dict:[extra copy]];
            }
            else {
                [TTTrackerWrapper event:@"micronews_tab" label:@"more_comments" value:nil extValue:nil extValue2:nil dict:[extra copy]];
            }
        }
        else {
            wrapperTrackEvent(@"update_tab", @"more_comment");
        }
    } else if (self.sourceType == ArticleMomentSourceTypeForum) {
        wrapperTrackEvent(@"topic_tab", @"more_comment");
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(momentCellCommentViewShowMoreLabelClicked:)]) {
        [_delegate momentCellCommentViewShowMoreLabelClicked:self];
    }
}

@end
