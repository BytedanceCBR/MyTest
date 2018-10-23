//
//  TSVVideoOverlayViewModel.h
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 10/12/2017.
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class TTShortVideoModel, TSVVideoDetailPromptManager, TTRichSpanText, TTUGCAttributedLabelLink,TSVRecommendCardViewModel;

extern NSString * _Nonnull const TSVLastShareActivityName;

typedef NS_ENUM(NSInteger, TSVGroupSource) {
    TSVGroupSourceAd        = 3, // 3
    TSVGroupSourceHuoshan   = 16,
    TSVGroupSourceDouyin    = 19,
    TSVGroupSourceToutiao   = 21,
    TSVGroupSourceUnknown
};

@interface TSVControlOverlayViewModel : NSObject

// Configuration
@property (nonatomic, copy, nullable) NSDictionary *commonTrackingParameter;
@property (nonatomic, strong, nullable) TTShortVideoModel *model;
@property (nonatomic, copy, nullable) void (^closeButtonDidClick)();
@property (nonatomic, copy, nullable) void (^moreButtonDidClick)();
@property (nonatomic, copy, nullable) void (^writeCommentButtonDidClick)();
@property (nonatomic, copy, nullable) void (^showProfilePopupBlock)();
@property (nonatomic, copy, nullable) void (^showCommentPopupBlock)();
@property (nonatomic, strong) TSVVideoDetailPromptManager *detailPromptManager;
@property (nonatomic, assign) TSVShortVideoListEntrance listEntrance;
@property (nonatomic, readonly) TSVRecommendCardViewModel *recViewModel;

// State
@property (nonatomic, readonly) BOOL showShareIconOnBottomBar;
@property (nonatomic, readonly) BOOL showOnlyOneShareIconOnBottomBar;
@property (nonatomic, readonly, nullable) NSString *lastUsedShareActivityName;
@property (nonatomic, readonly) TSVGroupSource groupSource;
@property (nonatomic, readonly) NSString *musicLabelString;
@property (nonatomic, readonly) NSString *titleString;
@property (nonatomic, readonly) NSString *titleRichTextStyleConfig;
@property (nonatomic, readonly) NSURL *avatarImageURL;
@property (nonatomic, readonly) BOOL followButtonHidden;
@property (nonatomic, readonly) NSString *authorUserName;
@property (nonatomic, readonly) NSArray<NSString *> *normalTagArray;
@property (nonatomic, readonly) NSString *activityTagString;
@property (nonatomic, readonly) NSString *likeCountString;
@property (nonatomic, readonly) NSString *commentCountString;
@property (nonatomic, readonly) BOOL isFollowing;
@property (nonatomic, readonly) BOOL isLiked;
@property (nonatomic, readonly) BOOL isStartFollowLoading;
@property (nonatomic, readonly) BOOL showRecommendCard;
@property (nonatomic, readonly) BOOL isArrowRotationBackground;

@property (nonatomic, readonly) NSString *debugInfo;

// Action
- (void)videoDidPlayOneLoop;
- (void)clickCloseButton;
- (void)clickLogoButton;
- (void)clickMoreButton;
- (void)clickWriteCommentButton;
- (void)clickActivityTag;
- (void)clickChallengeTag;
- (void)clickFollowButton;
- (void)clickUserNameButton;
- (void)clickAvatarButton;
- (void)clickLikeButton;
- (void)clickCommentButton;
- (void)clickShareButton;
- (void)clickCheckChallengeButton;
- (void)showShareButtonIfNeeded;
- (void)shareToActivityNamed:(NSString *_Nonnull)activityName;
- (void)didShareToActivityNamed:(NSString *_Nonnull)activityName;
- (void)cellWillDisplay;
- (void)doubleTapView;
- (void)singleTapView;
- (void)clickRecommendArrow;

- (void)trackFollowCardEvent;

- (void (^)(TTRichSpanText *richSpanText, TTUGCAttributedLabelLink *curLink))titleLinkClickBlock;

- (void)markLikeDirectly;

@end

NS_ASSUME_NONNULL_END
