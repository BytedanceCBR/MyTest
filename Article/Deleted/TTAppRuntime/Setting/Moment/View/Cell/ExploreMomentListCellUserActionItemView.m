//
//  ExploreMomentListCellUserActionItemView.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-16.
//
//

#import "ExploreMomentListCellUserActionItemView.h"
#import "ArticleForwardViewController.h"
#import "TTIndicatorView.h"
#import "NetworkUtilities.h"
#import <TTAccountBusiness.h>
#import "ArticleMomentDiggManager.h"
#import "SSMotionRender.h"
#import "ArticleMomentDiggManager.h"
#import "SSMyUserModel.h"
#import "ArticleMomentDetailView.h"
#import "ArticleMomentListViewBase.h"

#import "TTNavigationController.h"
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"
#import "TTBusinessManager+StringUtils.h"
#import "ArticleMomentGroupModel.h"
#import "TTTabBarProvider.h"

#define kViewHeight (7 + 14 + 16)

#undef kButtonWidth
#define kButtonWidth 60

#undef kButtonHeight
#define kButtonHeight 30


@interface ExploreMomentListCellUserActionItemView()

@property(nonatomic, retain)UIButton * diggButton;

@end

@implementation ExploreMomentListCellUserActionItemView

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _forwardButton.frame = CGRectMake(0, 0, kButtonWidth, kButtonHeight);
        _forwardButton.titleLabel.font = [UIFont systemFontOfSize:12];
        //        [_forwardButton addTarget:self action:@selector(forwardButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_forwardButton];
        _forwardButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _forwardButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        
        self.diggButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _diggButton.frame = CGRectMake(0, 0, kButtonWidth, kButtonHeight);
        _diggButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_diggButton addTarget:self action:@selector(diggButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_diggButton];
        _diggButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _diggButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        
        self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentButton.frame = CGRectMake(0, 0, kButtonWidth, kButtonHeight);
        _commentButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _commentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _commentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        
        [self addSubview:_commentButton];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [_forwardButton setImage:[UIImage themedImageNamed:@"repost_video.png"] forState:UIControlStateNormal];
    [_forwardButton setImage:[UIImage themedImageNamed:@"repost_video_press.png"] forState:UIControlStateHighlighted];
    [_forwardButton setTitleColor:SSGetThemedColorWithKey(kColorText3) forState:UIControlStateNormal];
    [_forwardButton setTitleColor:SSGetThemedColorWithKey(kColorText4) forState:UIControlStateHighlighted];
    
    [_commentButton setImage:[UIImage themedImageNamed:@"comment_video.png"] forState:UIControlStateNormal];
    [_commentButton setImage:[UIImage themedImageNamed:@"comment_video_press.png"] forState:UIControlStateHighlighted];
    [_commentButton setTitleColor:SSGetThemedColorWithKey(kColorText3) forState:UIControlStateNormal];
    [_commentButton setTitleColor:SSGetThemedColorWithKey(kColorText4) forState:UIControlStateHighlighted];
    
    [self refreshDigViewUI];
    
}


- (void)diggButtonClicked
{
    if (self.isInMomentListView) {
        if ([TTTabBarProvider isFollowTabOnTabBar]) {
            wrapperTrackEvent(self.listUmengEventName, @"digg");
        }
    } else {
        wrapperTrackEvent(self.detailUmengEventName, @"digg");
    }
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    if (self.momentModel.digged) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经赞过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    if (self.isInMomentListView) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"digg" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
    }
    
    self.momentModel.digged = YES;
    if (self.momentModel.diggLimit <= 0) {
        self.momentModel.diggLimit = 1;
    }
    else {
        self.momentModel.diggLimit += 1;
    }
    self.momentModel.diggsCount += 1;
    [self.momentModel insertDiggUser:[[TTAccountManager sharedManager] myUser]];
    
    [ArticleMomentDiggManager startDiggMoment:self.momentModel.ID finishBlock:^(int newCount, NSError *error) {
    }];
    [SSMotionRender motionInView:_diggButton byType:SSMotionTypeZoomInAndDisappear image:[UIImage themedImageNamed:@"add_all_dynamic.png"] offsetPoint:CGPointMake(-16.f, -3.f)];
    _diggButton.imageView.contentMode = UIViewContentModeCenter;
    _diggButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    _diggButton.imageView.alpha = 1.f;
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        _diggButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        _diggButton.imageView.alpha = 0.f;
    } completion:^(BOOL finished){
        [self refreshDigViewUI];
        _diggButton.imageView.alpha = 0.f;
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            _diggButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            _diggButton.imageView.alpha = 1.f;
        } completion:^(BOOL finished){
            
        }];
    }];
    
    if (![TTAccountManager isLogin]) {
        //        [self momentTrack:@"logoff_digg"];
    } else {
        // 顶用户的收藏应发送dig_favorite，不发digg
        if (self.momentModel.type == 2) {
            //            [self momentTrack:@"dig_favorite"];
        } else {
            //            [self momentTrack:@"digg"];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didDigMoment:)]) {
        [self.delegate didDigMoment:self.momentModel];
    }
}

- (void)refreshDigViewUI
{
    if (self.momentModel.digged) {
        [_diggButton setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateNormal];
        [_diggButton setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateHighlighted];
        [_diggButton setTitleColor:SSGetThemedColorWithKey(kColorText4) forState:UIControlStateNormal];
    }
    else {
        [_diggButton setImage:[UIImage themedImageNamed:@"digup_video.png"] forState:UIControlStateNormal];
        [_diggButton setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateHighlighted];
        [_diggButton setTitleColor:SSGetThemedColorWithKey(kColorText3) forState:UIControlStateNormal];
    }
    
    if (self.momentModel.diggsCount > 0) {
        [_diggButton setTitle:[NSString stringWithFormat:@"%@", [TTBusinessManager formatCommentCount:self.momentModel.diggsCount]] forState:UIControlStateNormal];
    }
    else {
        [_diggButton setTitle:NSLocalizedString(@"赞", nil) forState:UIControlStateNormal];
    }
}

- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    [super refreshForMomentModel:model];
    if ([model.forwardNum longLongValue] > 0) {
        [_forwardButton setTitle:[NSString stringWithFormat:@"%@", model.forwardNum] forState:UIControlStateNormal];
    }
    else {
        [_forwardButton setTitle:NSLocalizedString(@"分享", nil) forState:UIControlStateNormal];
    }
    
    [self refreshDigViewUI];
    
    NSString *commentCountPreviousTitle = _commentButton.titleLabel.text;
    NSString *commentCountTitle = [NSString stringWithFormat:@"%i", model.commentsCount];
    if (commentCountPreviousTitle && ![commentCountTitle isEqualToString:commentCountPreviousTitle]) {
        if ([self.delegate respondsToSelector:@selector(didSendCommentToMoment:)]) {
            [self.delegate didSendCommentToMoment:model];
        }
    }
    if (model.commentsCount > 0) {
        [_commentButton setTitle:commentCountTitle forState:UIControlStateNormal];
    }
    else {
        [_commentButton setTitle:NSLocalizedString(@"评论", nil) forState:UIControlStateNormal];
    }
    
    _forwardButton.origin = CGPointMake(kMomentCellItemViewLeftPadding, (kViewHeight - kButtonHeight) / 2);
    _commentButton.origin = CGPointMake(self.width - kMomentCellItemViewRightPadding - kButtonWidth, (_forwardButton.top));
    _diggButton.origin = CGPointMake(((_commentButton.left) - (_forwardButton.right) - (_diggButton.width)) / 2 + (_forwardButton.right), (_forwardButton.top));
    
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellUserActionItemView heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo];
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    if (![self needShowForModel:model userInfo:uInfo]) {
        return 0;
    }
    
    return kViewHeight;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    ArticleMomentSourceType sourceType = [[uInfo objectForKey:kMomentListCellItemBaseUserInfoSourceTypeKey] intValue];
    if (sourceType == ArticleMomentSourceTypeMoment ||
        sourceType == ArticleMomentSourceTypeProfile) {
        return YES;
    }
    return NO;
}

- (void)forwardButtonClicked
{
    if ([TTAccountManager isLogin]) {
        [self openForwardView];
    }
    else {
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"social_item_share" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                if ([TTAccountManager isLogin]) {
                    [self openForwardView];
                }
            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"social_item_share" completion:^(TTAccountLoginState state) {

                }];
            }
        }];
    }
}

- (void)openForwardView
{
    if (self.isInMomentListView) {
        wrapperTrackEvent(self.listUmengEventName, @"repost");
    } else {
        wrapperTrackEvent(self.detailUmengEventName, @"repost");
    }
    
    ArticleForwardSourceType sourceType = ArticleForwardSourceTypeOther;
    switch (self.sourceType) {
        case ArticleMomentSourceTypeMoment:
            sourceType = ArticleForwardSourceTypeMoment;
            break;
        case ArticleMomentSourceTypeProfile:
            sourceType = ArticleForwardSourceTypeProfile;
            break;
        case ArticleMomentSourceTypeForum:
            sourceType = ArticleForwardSourceTypeTopic;
            break;
        case ArticleMomentSourceTypeMessage:
            sourceType = ArticleForwardSourceTypeNotify;
            break;
        default:
            break;
    }
    ArticleForwardViewController * forwardController = [[ArticleForwardViewController alloc] initWithMomentModel:self.momentModel];
    forwardController.sourceType = sourceType;
    
    TTNavigationController * nav = [[TTNavigationController alloc] initWithRootViewController:forwardController];
    nav.ttDefaultNavBarStyle = @"White";
    
    [[TTUIResponderHelper topNavigationControllerFor: self] presentViewController:nav animated:YES completion:nil];
}

@end
