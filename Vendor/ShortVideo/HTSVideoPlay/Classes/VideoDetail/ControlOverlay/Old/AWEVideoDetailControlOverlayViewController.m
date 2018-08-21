//
//  AWEVideoDetailBottomControlOverlayViewController.m
//  Pods
//
//  Created by Zuyang Kou on 20/06/2017.
//
//

#import "AWEVideoDetailControlOverlayViewController.h"
#import "TSVIconLabelButton.h"
#import "SSThemed.h"
#import "AWEAwemeMusicInfoView.h"
#import "TSVShortVideoOriginalData.h"
#import "AWEVideoConstants.h"
#import "AWEVideoPlayTrackerBridge.h"
#import <Masonry/Masonry.h>
#import "HTSVideoPlayColor.h"
#import "AWEVideoDetailManager.h"
#import "AWEVideoOverlayView.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import "HTSDeviceManager.h"
#import "HTSVideoPlayToast.h"
#import "AWEVideoPlayAccountBridge.h"
#import "AWEVideoPlayShareBridge.h"
#import "BTDResponder.h"
#import "MBProgressHUD.h"
//#import "AFURLSessionManager.h"
#import "TTBusinessManager+StringUtils.h"
#import "AWEDetailLogoViewController.h"
#import "AWEVideoDetailTracker.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTFollowThemeButton.h"
#import "TTDeviceHelper.h"
#import "AWEVideoPlayTransitionBridge.h"
#import <UIImageView+WebCache.h>
#import "TTSettingsManager.h"
#import "AWEVideoUserInfoManager.h"
#import "AWEUserModel.h"
#import "TSVVideoDetailPromptManager.h"
#import "TTShareManager.h"
#import "AWEVideoShareModel.h"
#import "TTServiceCenter.h"
#import "TTAdManagerProtocol.h"
#import "TSVVideoDetailControlOverlayUITypeConfig.h"
#import "UIViewAdditions.h"
#import <TTThemed/UIColor+TTThemeExtension.h>
#import "TTModuleBridge.h"
#import <Lottie/Lottie.h>
#import <UIView+CustomTimingFunction.h>
#import "TSVWriteCommentButton.h"
#import "UIView+Yoga.h"
#import "SSMotionRender.h"
#import "UIButton+TTAdditions.h"
#import "TSVTagInfoView.h"
#import "AWEVideoDetailScrollConfig.h"
#import "TSVSlideUpPromptViewController.h"
#import "TTRichSpanText.h"
#import "TTUGCAttributedLabel.h"
#import "TTRichSpanText+Link.h"
#import "TTRichSpanText+Emoji.h"
#import "TTUGCEmojiParser.h"
#import <TTRoute/TTRoute.h>
#import "TSVDebugInfoView.h"
#import "TSVVideoDetailShareHelper.h"
#import "TSVVideoShareManager.h"
#import <TTRoute/TTRoute.h>
#import "TSVTitleLabelConfigurator.h"
#import "TSVDebugInfoConfig.h"
#import <TTNavigationController.h>
#import "TSVDetailRouteHelper.h"
#import <NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTBaseMacro.h>
#import "TSVAvatarImageView.h"
#import "HTSVideoSwitch.h"
#import "TTUGCPostCenterProtocol.h"
#import "TSVShortVideoPostTaskProtocol.h"
#import "TSVRecommendCardViewController.h"
#import "TSVRecommendCardModel.h"
#import "TSVRecommendCardViewModel.h"

static const CGFloat kCheckChallengeButtonWidth = 72;
static const CGFloat kCheckChallengeButtonHeight = 28;
static const CGFloat kCheckChallengeButtonLeftPadding = 28;

@import AssetsLibrary;

@interface AWEVideoDetailControlOverlayViewController ()<TTUGCAttributedLabelDelegate>

// Top controls
@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) CAGradientLayer *topBarGradientLayer;
@property (nonatomic, strong) TSVAvatarImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) TTFollowThemeButton *followButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *userInfoContainerView;
@property (nonatomic, strong) UIView *layoutContainerView;

// Buttom controls
@property (nonatomic, strong) TTUGCAttributedLabel *titleLabel;
@property (nonatomic, strong) AWEDetailLogoViewController *logoViewController;
@property (nonatomic, strong) UIView *operationView;
@property (nonatomic, strong) UIButton *inputButton;
@property (nonatomic, strong) TSVIconLabelButton *commentButton;
@property (nonatomic, strong) TSVIconLabelButton *likeButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) CAGradientLayer *bottomGradientLayer;
@property (nonatomic, strong) AWEAwemeMusicInfoView *musicInfoView;
@property (nonatomic, strong) UIButton *wechatShareButton;
@property (nonatomic, strong) UIButton *wechatMomentsShareButton;

@property (nonatomic, strong) TSVRecommendCardViewController *recViewController;
@property (nonatomic, strong) UIButton *recArrowButton;

@property (nonatomic, strong) NSLock *diggLock;     // Seems overkill to me, a boolean will do the trick

@property (nonatomic, strong) UIView *tagContainerView;
@property (nonatomic, strong) UIView *horizontalTopTagsContainerView;/*第一行*/
@property (nonatomic, strong) UIView *horizontalBottomTagsContainerView;/*第二行*/
@property (nonatomic, strong) TSVTagInfoView *tagInfoView;
@property (nonatomic, strong) TSVTagInfoView *interactTag;
@property (nonatomic, strong) TSVTagInfoView *activityTag;
@property (nonatomic, strong) TSVTagInfoView *challengeTag;/*挑战标签*/
@property (nonatomic, strong) UIButton *checkChallengeButton;/*查看挑战*/

@property (nonatomic, strong) TSVDebugInfoView *debugInfoView;
@property (nonatomic, assign) BOOL challengeTagHasShowed;

@end

@implementation AWEVideoDetailControlOverlayViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.diggLock = [[NSLock alloc] init];
    }

    return self;
}

- (void)loadView
{
    self.view = [[AWEVideoOverlayView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    RAC(self, model) = RACObserve(self, viewModel.model);
    RAC(self, commonTrackingParameter) = RACObserve(self, viewModel.commonTrackingParameter);

    [self setupTopBarViews];
    [self setupBottomBarViews];

    [self setupTagViews];

    @weakify(self);
    if ([[TSVDebugInfoConfig config] debugInfoEnabled]) {
        self.debugInfoView = [[TSVDebugInfoView alloc] init];
        [self.view addSubview:self.debugInfoView];
    }

    [RACObserve(self, model.author.isFollowing) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        BOOL isFollowing = [x boolValue];
        self.followButton.followed = isFollowing;
        if (!isFollowing && !self.recArrowButton.hidden) {
            [self dismissRecommendCardView];
            [self dismissRecommendArrow];
        }
    }];
    
    RAC(self, commentButton.labelString) = [RACObserve(self, model.commentCount) map:^id(NSNumber *commentCount) {
        return [TTBusinessManager formatCommentCount:[commentCount longLongValue]];
    }];
    [[[[RACObserve(self, model.checkChallenge.allowCheck)
        distinctUntilChanged]
       takeUntil:self.rac_willDeallocSignal]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSNumber *allowCheck) {
         @strongify(self);
         if (self.checkChallengeButton.hidden == [allowCheck boolValue]) {
             self.checkChallengeButton.hidden = ![allowCheck boolValue];
             [self refreshTitleLabel];
             [self.view setNeedsUpdateConstraints];
         }
     }];
    
    [[[[RACObserve(self, model.challengeInfo.allowChallenge)
         distinctUntilChanged]
       takeUntil:self.rac_willDeallocSignal]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSNumber *allowChallenge) {
         @strongify(self);
         if (self.challengeTag.hidden == [allowChallenge boolValue]) {
             if ([allowChallenge boolValue] && !self.challengeTagHasShowed) {
                 //恢复展示时报
                 self.challengeTagHasShowed = YES;
                 [AWEVideoDetailTracker trackEvent:@"shortvideo_pk_show"
                                             model:self.model
                                   commonParameter:self.commonTrackingParameter
                                    extraParameter:nil];
             }
             self.challengeTag.hidden = ![allowChallenge boolValue];
             [self.view setNeedsLayout];
         }
     }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:@"SKStoreProductViewDidDisappearKey" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    void (^sendShareButtonApperanceTracking)(NSString *activityName) = ^(NSString *activityName) {
        @strongify(self);
        [AWEVideoDetailTracker trackEvent:@"share_to_platform_out"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:@{
                                            @"position": @"detail_bottom_bar_out",
                                            @"share_platform": [AWEVideoShareModel labelForContentItemType:activityName] ?: @"",
                                            }];
    };

    [[RACObserve(self, viewModel.showShareIconOnBottomBar)
      distinctUntilChanged]
     subscribeNext:^(id x) {
         @strongify(self);
         BOOL showShareIconOnBottomBar = [x boolValue];

         if (showShareIconOnBottomBar && !self.viewModel.showOnlyOneShareIconOnBottomBar) {
             [UIView animateWithDuration:0.15
                    customTimingFunction:CustomTimingFunctionLinear
                               animation:^{
                                   self.shareButton.alpha = 0;
                               }];

             sendShareButtonApperanceTracking(TTActivityContentItemTypeWechat);
             sendShareButtonApperanceTracking(TTActivityContentItemTypeWechatTimeLine);
             [self.operationView addSubview:self.wechatMomentsShareButton];
             [self.operationView addSubview:self.wechatShareButton];
             self.wechatMomentsShareButton.alpha = self.wechatShareButton.alpha = 0;
             self.wechatMomentsShareButton.center = self.wechatShareButton.center = self.shareButton.center;
             [UIView animateWithDuration:0.45
                    customTimingFunction:CustomTimingFunctionQuintOut
                               animation:^{
                                   self.wechatMomentsShareButton.alpha = self.wechatShareButton.alpha = 1;
                                   self.shareButton.yoga.isIncludedInLayout = NO;
                                   [self.view setNeedsLayout];
                                   [self.view layoutIfNeeded];
                               }];
         } else if (showShareIconOnBottomBar && self.viewModel.showOnlyOneShareIconOnBottomBar) {
             sendShareButtonApperanceTracking(self.viewModel.lastUsedShareActivityName);
             UIButton *iconButton = [self singleShareButton];
             [self.operationView addSubview:iconButton];
             self.shareButton.yoga.isIncludedInLayout = NO;
             [self.view setNeedsLayout];
             [self.view layoutIfNeeded];
             iconButton.alpha = 0;
             [UIView animateWithDuration:0.15
                    customTimingFunction:CustomTimingFunctionLinear
                               animation:^{
                                   iconButton.alpha = 1;
                                   self.shareButton.alpha = 0;
                               }];
         } else {
             self.shareButton.alpha = 1;
             self.shareButton.yoga.isIncludedInLayout = YES;
             [self.wechatMomentsShareButton removeFromSuperview];
             [self.wechatShareButton removeFromSuperview];
             [self.view setNeedsLayout];
         }
     }];

    [[[RACObserve(self, viewModel.isStartFollowLoading)
       deliverOnMainThread]
      distinctUntilChanged]
     subscribeNext:^(id x) {
         @strongify(self);
         BOOL isStartFollowLoading = [x boolValue];
         if (isStartFollowLoading) {
             [self.followButton startLoading];
         } else {
             [self.followButton stopLoading:nil];
         }
     }];

    [RACObserve(self, viewModel.likeCountString) subscribeNext:^(id  _Nullable x) {
        [self updateDiggState];
    }];
    
    // 解决较低版本的 iOS 中布局可能会产生问题，例如隐式动画、布局错位等问题，猜测可能是 UICollectionView 的问题
    void (^fuckLayout)() = ^{
        [UIView performWithoutAnimation:^{
            [self.view updateConstraintsIfNeeded];
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
    };
    fuckLayout();
    dispatch_async(dispatch_get_main_queue(), ^{
        fuckLayout();
    });
}

- (UIButton *)singleShareButton
{
    NSString *lastUsedActivity = self.viewModel.lastUsedShareActivityName;
    UIButton *iconView;
    if ([lastUsedActivity isEqualToString:TTActivityContentItemTypeWechat]) {
        iconView = self.wechatShareButton;
    } else if ([lastUsedActivity isEqualToString:TTActivityContentItemTypeWechatTimeLine]) {
        iconView = self.wechatMomentsShareButton;
    }

    return iconView;
}

- (UIButton *)wechatShareButton
{
    if (!_wechatShareButton) {
        _wechatShareButton = [[UIButton alloc] init];
        _wechatShareButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -10, -20, -10);
        [_wechatShareButton setImage:[UIImage imageNamed:@"tsv_share_icon_wechat"] forState:UIControlStateNormal];
        @weakify(self);
        [[[_wechatShareButton rac_signalForControlEvents:UIControlEventTouchUpInside]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             [self sendShareTrakingWithActivityName:TTActivityContentItemTypeWechat];
             [self.viewModel shareToActivityNamed:TTActivityContentItemTypeWechat];
         }];
    }

    return _wechatShareButton;
}

- (UIButton *)wechatMomentsShareButton
{
    if (!_wechatMomentsShareButton) {
        _wechatMomentsShareButton = [[UIButton alloc] init];
        _wechatMomentsShareButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -10, -20, -10);
        [_wechatMomentsShareButton setImage:[UIImage imageNamed:@"tsv_share_icon_wechat_moments"] forState:UIControlStateNormal];
        @weakify(self);
        [[[_wechatMomentsShareButton rac_signalForControlEvents:UIControlEventTouchUpInside]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             [self sendShareTrakingWithActivityName:TTActivityContentItemTypeWechatTimeLine];
             [self.viewModel shareToActivityNamed:TTActivityContentItemTypeWechatTimeLine];
         }];
    }

    return _wechatMomentsShareButton;
}

- (void)sendShareTrakingWithActivityName:(NSString *)activityName
{
    NSString *type = [AWEVideoShareModel labelForContentItemType:activityName];
    NSAssert(type, @"Type should not be empty");
    [AWEVideoDetailTracker trackEvent:@"rt_share_to_platform"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{
                                        @"share_platform": type ?: @"",
                                        @"position": @"detail_bottom_bar_out",
                                        }];

}

- (UIView *)userInfoContainerView
{
    if (!_userInfoContainerView) {
        _userInfoContainerView = [[UIView alloc] init];
        _userInfoContainerView.backgroundColor = [UIColor clearColor];

        _avatarImageView = [[TSVAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40) model:self.model.author disableNightMode:YES];
        [_userInfoContainerView addSubview:_avatarImageView];
        [_avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarClick:)]];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.layer.shadowOffset = CGSizeZero;
        _nameLabel.font = [UIFont boldSystemFontOfSize:17];
        _nameLabel.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor;
        _nameLabel.layer.shadowRadius = 1.0;
        _nameLabel.layer.shadowOpacity = 1.0;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.userInteractionEnabled = YES;
        [_userInfoContainerView addSubview:_nameLabel];
        [_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserNameClick:)]];
        
        _userInfoContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return _userInfoContainerView;
}

- (TTFollowThemeButton *)followButton
{
    if (!_followButton) {
        _followButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101
                                                               followedType:TTFollowedType103
                                                         followedMutualType:TTFollowedMutualType103];
        [_followButton addTarget:self action:@selector(handleFollowClick:) forControlEvents:UIControlEventTouchUpInside];
        _followButton.hidden = YES;
        _followButton.forbidNightMode = YES;
    }

    return _followButton;
}

- (UIButton *)checkChallengeButton
{
    if (!_checkChallengeButton) {
        _checkChallengeButton = [[UIButton alloc] init];
        _checkChallengeButton.layer.cornerRadius = 4;
        _checkChallengeButton.layer.borderWidth = 1;
        _checkChallengeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _checkChallengeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_checkChallengeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_checkChallengeButton setTitle:@"查看挑战" forState:UIControlStateNormal];
        [_checkChallengeButton addTarget:self action:@selector(_onCheckChallengeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkChallengeButton;
}

- (AWEDetailLogoViewController *)logoViewController
{
    if (!_logoViewController) {
        _logoViewController = [[AWEDetailLogoViewController alloc] init];
        RAC(_logoViewController, model) = RACObserve(self, model);
        RAC(_logoViewController, commonTrackingParameter) = RACObserve(self, commonTrackingParameter);
        RAC(_logoViewController, detailPromptManager) = RACObserve(self, detailPromptManager);
    }

    return _logoViewController;
}

- (TSVRecommendCardViewController *)recViewController
{
    if (!_recViewController) {
        _recViewController = [[TSVRecommendCardViewController alloc] init];
        RAC(_recViewController, viewModel) = RACObserve(self, viewModel.recViewModel);
    }
    return _recViewController;
}

- (UIButton *)recArrowButton
{
    if (!_recArrowButton) {
        _recArrowButton = [[UIButton alloc] init];
        _recArrowButton.layer.cornerRadius = 4;
        _recArrowButton.layer.borderWidth = 1;
        _recArrowButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [_recArrowButton setImage:[UIImage imageNamed:@"tsv_detail_rec_arrow"] forState:UIControlStateNormal];
        [_recArrowButton addTarget:self action:@selector(onRecArrowButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recArrowButton;
}

- (void)setupTopBarViews
{
    self.topBarView = [[UIView alloc] init];
    self.topBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64.0);
    self.topBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.topBarView];

    self.topBarGradientLayer = [CAGradientLayer layer];
    self.topBarGradientLayer.locations = @[@0, @.046875, @.109375, @.296875, @.484375, @.671875, @1];
    self.topBarGradientLayer.colors = @[(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.38].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.34].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.24].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.14].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.06].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor];
    [self.view.layer addSublayer:self.topBarGradientLayer];

    _layoutContainerView = [[UIView alloc] init];
    _layoutContainerView.backgroundColor = [UIColor clearColor];
    [self.topBarView addSubview:_layoutContainerView];

    _moreButton = [[UIButton alloc] init];
    [_moreButton setImage:[UIImage imageNamed:@"hts_vp_white_more_titlebar"] forState:UIControlStateNormal];
    [_moreButton setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 0)];
    [_moreButton addTarget:self action:@selector(handleReportClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:_moreButton];

    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"hts_vp_close"] forState:UIControlStateNormal];
    [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 0)];
    [_closeButton addTarget:self action:@selector(handleCloseClick:) forControlEvents:UIControlEventTouchUpInside];
    [_layoutContainerView addSubview:_closeButton];
    
    [_layoutContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBarView);
        make.left.equalTo(self.topBarView).offset(12.0);
        make.height.equalTo(@48.0);
        make.right.equalTo(_moreButton.mas_left).offset(-8.0);
    }];

    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_layoutContainerView);
        make.height.equalTo(@48.0);
        make.width.equalTo(@30.0);
    }];

    [self addChildViewController:self.logoViewController];
    [self.topBarView addSubview:self.logoViewController.view];
    [self.logoViewController didMoveToParentViewController:self];
    self.logoViewController.view.hidden = YES;

    [self.logoViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@100);
        make.height.equalTo(@28);
        make.centerY.equalTo(self.closeButton.mas_centerY);
    }];

    [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_closeButton);
        make.right.equalTo(self.view).offset(-12.0);
        make.height.equalTo(@50.0);
        make.width.equalTo(@30.0);
    }];
}

- (void)setupBottomBarViews
{
    //height 140
    _bottomGradientLayer = [CAGradientLayer layer];
    _bottomGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor];
    [self.view.layer addSublayer:_bottomGradientLayer];

    // UI交互View
    self.titleLabel = ({
        TTUGCAttributedLabel *label = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
        label.numberOfLines = 2;
        label.delegate = self;
        label.extendsLinkTouchArea = NO;
        label.longPressGestureRecognizer.enabled = NO;
        label;
    });
    [self.view addSubview:self.titleLabel];

    _musicInfoView = [AWEAwemeMusicInfoView new];
    _musicInfoView.userInteractionEnabled = NO;
    [self.view addSubview:_musicInfoView];


    _operationView = [[UIView alloc] init];
    [self.view addSubview:_operationView];

    _inputButton = [[TSVWriteCommentButton alloc] init];
    [_inputButton addTarget:self action:@selector(_onInputButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_operationView addSubview:_inputButton];

    _commentButton = [[TSVIconLabelButton alloc] initWithImage:@"hts_vp_comments" label:nil];
    _commentButton.label.textAlignment = NSTextAlignmentLeft;
    _commentButton.label.textColor = [UIColor tt_defaultColorForKey:kColorText7];
    [_commentButton addTarget:self action:@selector(_onCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.operationView addSubview:_commentButton];

    _likeButton = [[TSVIconLabelButton alloc] initWithImage:@"hts_vp_like" label:nil];
    _likeButton.label.textAlignment = NSTextAlignmentLeft;
    _likeButton.label.textColor = [UIColor tt_defaultColorForKey:kColorText7];
    [_likeButton addTarget:self action:@selector(_onLikeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.operationView addSubview:_likeButton];
    
    self.shareButton = [[UIButton alloc] init];
    self.shareButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    [self.shareButton setImage:[UIImage imageNamed:@"hts_vp_more"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(_onShareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    NSNumber *shareEnable = [[TTSettingsManager sharedManager] settingForKey:@"tt_lite_huoshan_share_enable" defaultValue:@NO freeze:NO];
    if (shareEnable.boolValue){
        [self.operationView addSubview:self.shareButton];
    }

    [self.view addSubview:self.userInfoContainerView];
    [self.view addSubview:self.followButton];
    self.followButton.hidden = YES;
    
    [self.view addSubview:self.checkChallengeButton];
    self.checkChallengeButton.hidden = YES;

    [self addChildViewController:self.recViewController];
    [self.view addSubview:self.recViewController.view];
    [self.recViewController didMoveToParentViewController:self];
    self.recViewController.view.hidden = YES;
    
    [self.view addSubview:self.recArrowButton];
    self.recArrowButton.hidden = YES;
}

- (void)setupTagViews
{
    self.tagContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tagContainerView];
    
    self.horizontalTopTagsContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tagContainerView addSubview:self.horizontalTopTagsContainerView];
    
    self.activityTag = [[TSVTagInfoView alloc] initWithNightThemeEnabled:NO];
    self.activityTag.style = TSVTagInfoViewStyleActivity;
    [self.activityTag addTarget:self action:@selector(activityTagTap:)];
    [self.horizontalTopTagsContainerView addSubview:self.activityTag];
    
    self.challengeTag = [[TSVTagInfoView alloc] initWithNightThemeEnabled:NO];
    self.challengeTag.style = TSVTagInfoViewStyleChallenge;
    [self.challengeTag addTarget:self action:@selector(challengeTagTap:)];
    [self.horizontalTopTagsContainerView addSubview:self.challengeTag];
    
    self.horizontalBottomTagsContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tagContainerView addSubview:self.horizontalBottomTagsContainerView];
    
    self.tagInfoView = [[TSVTagInfoView alloc] initWithNightThemeEnabled:NO];
    [self.horizontalBottomTagsContainerView addSubview:self.tagInfoView];
    
    self.interactTag = [[TSVTagInfoView alloc] initWithNightThemeEnabled:NO];
    [self.horizontalBottomTagsContainerView addSubview:self.interactTag];
}

- (void)activityTagTap:(id)sender
{
    [self.viewModel clickActivityTag];
}

- (void)challengeTagTap:(id)sender
{
    [self.viewModel clickChallengeTag];
}

- (void)updateViewConstraints
{
    [self.checkChallengeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-15);
        make.bottom.equalTo(self.operationView.mas_top).offset(-14);
        make.width.equalTo(@(kCheckChallengeButtonWidth));
        make.height.equalTo(@(kCheckChallengeButtonHeight));
    }];
    
    CGFloat avatarSize = 40;

    [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.userInfoContainerView);
        make.left.equalTo(_userInfoContainerView);
        make.width.height.equalTo(@(avatarSize));
    }];

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.userInfoContainerView);
        make.left.equalTo(_avatarImageView.mas_right).offset(8.0);
        make.right.equalTo(_userInfoContainerView);
        make.height.equalTo(@24.0);
    }];

    UIView *topmostView;
    if ([self.titleLabel.attributedText length]) {
        topmostView = self.titleLabel;
    } else if (self.musicInfoView.hidden == NO) {
        topmostView = self.musicInfoView;
    } else {
        topmostView = self.operationView;
    }
    
    if (self.recViewController.view.hidden) {
        [self.userInfoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.height.equalTo(@24);
            make.bottom.equalTo(topmostView.mas_top).offset(-16);
        }];
    } else {
        [self.userInfoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.height.equalTo(@24);
            make.bottom.equalTo(self.operationView.mas_top).offset(-171);
        }];
    }


    CGFloat followButtonMinRightMargin;
    CGFloat musicLeftAndRightMargin;
    CGFloat titleLeftAndRightMargin;
    if (!self.checkChallengeButton.hidden) {
        followButtonMinRightMargin = kCheckChallengeButtonLeftPadding + kCheckChallengeButtonWidth + 15;
        musicLeftAndRightMargin = kCheckChallengeButtonLeftPadding + kCheckChallengeButtonWidth + 30;
        titleLeftAndRightMargin = kCheckChallengeButtonLeftPadding + kCheckChallengeButtonWidth + 30;
    } else {
        followButtonMinRightMargin = 58;
        musicLeftAndRightMargin = 30;
        titleLeftAndRightMargin = 30;
    }
    [self.followButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userInfoContainerView.mas_right).offset(8);
        make.centerY.equalTo(self.userInfoContainerView);
        make.width.equalTo(@58.0);
        make.height.equalTo(@28.0);
        make.right.lessThanOrEqualTo(self.view.mas_right).offset(-followButtonMinRightMargin);
    }];
    
    if (self.musicInfoView.hidden == NO) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.width.equalTo(self.view.mas_width).offset(-titleLeftAndRightMargin);
            make.bottom.equalTo(self.musicInfoView.mas_top).offset(-10);
        }];
    } else {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.width.equalTo(self.view.mas_width).offset(-titleLeftAndRightMargin);
            make.bottom.equalTo(self.operationView.mas_top);
        }];
    }
    
    [self.musicInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16.0);
        make.bottom.equalTo(self.operationView.mas_top);
        make.width.equalTo(self.view.mas_width).offset(-musicLeftAndRightMargin);
        make.height.equalTo(@16);
    }];
    
    [self.logoViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@100);
    }];
    
    [self.recViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(@156);
        make.top.equalTo(self.userInfoContainerView.mas_bottom).offset(15);
    }];
    
    [self.recArrowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.followButton.mas_right).offset(5);
        make.centerY.equalTo(self.followButton.mas_centerY);
        make.height.equalTo(@28);
        make.width.equalTo(@28);
    }];

    CGFloat tagContainerViewHeight;
    if ( !(self.tagInfoView.hidden && self.interactTag.hidden) && !(self.activityTag.hidden && self.challengeTag.hidden)) {
        tagContainerViewHeight = 20 + 6 + 20;
    } else if (!(self.tagInfoView.hidden && self.interactTag.hidden) || !(self.activityTag.hidden && self.challengeTag.hidden)) {
        tagContainerViewHeight = 20;
    } else {
        tagContainerViewHeight = 0;
    }
    
    [self.tagContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.bottom.equalTo(self.userInfoContainerView.mas_top).offset(-16);
        make.height.equalTo([NSNumber numberWithFloat:tagContainerViewHeight]);
    }];
    
    [super updateViewConstraints];
}

- (CGFloat)titleLabelWidth
{
    if (self.checkChallengeButton.hidden) {
        return self.view.bounds.size.width - 30;
    } else {
        return self.view.bounds.size.width - 30 - (kCheckChallengeButtonLeftPadding + kCheckChallengeButtonWidth);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!isEmptyString(self.viewModel.musicLabelString)) {
        [self.musicInfoView startAnimation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (!isEmptyString(self.viewModel.musicLabelString)) {
        [self.musicInfoView stopAnimation];
    }
}

- (UIEdgeInsets)viewSafeAreaInsets
{
    //FIXME: 这个 view 的 safeAreaInsets 经常不对，会是0，所以取了 superview 的。推测可能跟这个 view 有对应的 VC 有关
    return self.view.superview.tt_safeAreaInsets;
}

- (void)viewDidLayoutSubviews
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    [super viewDidLayoutSubviews];

    self.topBarGradientLayer.frame = self.topBarView.frame;
   
    self.bottomGradientLayer.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 140, CGRectGetWidth(self.view.bounds), 140);

    self.operationView.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame) - 50 - self.viewSafeAreaInsets.bottom,
                                          CGRectGetWidth(self.view.frame), 50);

    [self.operationView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPercentValue(100);
        layout.height = YGPointValue(50);
        layout.paddingLeft = YGPointValue(15);
        layout.paddingRight = YGPointValue(15);
        layout.flexDirection = YGFlexDirectionRow;
        layout.justifyContent = YGJustifySpaceBetween;
        layout.alignItems = YGAlignCenter;
    }];
    [self.inputButton configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(32);
        if (![TTDeviceHelper isScreenWidthLarge320]) {
            layout.width = YGPointValue(106);
        } else if (self.viewModel.showShareIconOnBottomBar) {
            if ([TTDeviceHelper is736Screen]) {
                layout.width = YGPointValue(120);
            } else {
                layout.width = YGPointValue(106);
            }
        } else {
            if ([TTDeviceHelper is736Screen]) {
                layout.width = YGPointValue(176);
            } else {
                layout.width = YGPointValue(160);
            }
        } 
    }];
    [self.likeButton configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginRight = YGPointValue(5);
    }];
    [self.shareButton configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPointValue(24);
        layout.height = YGPointValue(24);
    }];
    if ([[TSVDebugInfoConfig config] debugInfoEnabled]) {
        self.debugInfoView.frame = CGRectMake(0, 100, 100, 200);
    }
    [self.operationView.yoga applyLayoutPreservingOrigin:YES];

    [self updateViewFrameForSafeAreaIfNeeded];
    
    [self.tagContainerView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.paddingHorizontal = YGPointValue(15);
        layout.flexDirection = YGFlexDirectionColumn;
        layout.alignItems = YGAlignFlexStart;
    }];
    
    [self.horizontalTopTagsContainerView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(20);
        layout.width = YGPercentValue(100);
        layout.marginBottom = YGPointValue(6);
        layout.flexDirection = YGFlexDirectionRow;
        layout.alignItems = YGAlignCenter;
    }];
    
    [self.activityTag configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(20);
        layout.width = YGPointValue([self.activityTag originalContainerWidth]);
        layout.maxWidth = YGPercentValue(100);
        layout.marginRight = YGPointValue(6);
        layout.flexShrink = 1;
    }];
    
    [self.challengeTag configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(20);
        layout.width = YGPointValue([self.challengeTag originalContainerWidth]);
        layout.maxWidth = YGPercentValue(100);
    }];
    
    [self.horizontalBottomTagsContainerView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPercentValue(100);
        layout.height = YGPointValue(20);
        layout.flexDirection = YGFlexDirectionRow;
        layout.alignItems = YGAlignCenter;
    }];

    [self.tagInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(20);
        layout.maxWidth = YGPointValue([[TSVTagInfoView class] maxContainerWidth]);
        layout.width = YGPointValue([self.tagInfoView originalContainerWidth]);
        layout.marginRight = YGPointValue(6);
    }];
    
    [self.interactTag configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(20);
        layout.width = YGPointValue([self.interactTag originalContainerWidth]);
        layout.flexShrink = 1;
    }];
    
    self.tagInfoView.yoga.isIncludedInLayout = !self.tagInfoView.hidden;
    self.interactTag.yoga.isIncludedInLayout = !self.interactTag.hidden;
    self.horizontalBottomTagsContainerView.yoga.isIncludedInLayout = !(self.tagInfoView.hidden && self.interactTag.hidden);
    self.activityTag.yoga.isIncludedInLayout = !self.activityTag.hidden;
    self.challengeTag.yoga.isIncludedInLayout = !self.challengeTag.hidden;
    self.horizontalTopTagsContainerView.yoga.isIncludedInLayout = !(self.activityTag.hidden && self.challengeTag.hidden);
    
    [self.tagContainerView.yoga applyLayoutPreservingOrigin:YES];
    
    [CATransaction commit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if ([self.model.groupSource isEqualToString:AwemeGroupSource]){
        [self.musicInfoView stopAnimation];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setModel:(TTShortVideoModel *)model
{
    _model = model;
    
    self.likeButton.labelString = [TTBusinessManager formatCommentCount:self.model.diggCount];
    self.likeButton.imageString = self.model.userDigg ? @"hts_vp_like_press" : @"hts_vp_like";
    self.likeButton.selected = self.model.userDigg;
    self.likeButton.label.textColor = [UIColor tt_defaultColorForKey:self.model.userDigg ? kColorText4 : kColorText7];

    NSString *musicLabelString = self.viewModel.musicLabelString;
    if (!isEmptyString(musicLabelString)) {
        [self.musicInfoView configRollingAnimationWithLabelString:musicLabelString];
        [self.musicInfoView startAnimation];
        self.musicInfoView.hidden = NO;
    } else {
        self.musicInfoView.hidden = YES;
    }
    
    self.musicInfoView.alpha = 1;
    self.titleLabel.alpha = 1;
    self.recViewController.view.hidden = YES;
    self.recArrowButton.hidden = YES;
    
    [self.activityTag refreshTagWithText:model.activity.name];
    [self.challengeTag refreshTagWithText:model.challengeInfo.challengeAward];
    [self.tagInfoView refreshTagWithText:model.labelForDetail];
    [self.interactTag refreshTagWithText:model.labelForInteract];
    
    [self refreshTagHiddenStatusWithModel:model];

    [self refreshTitleLabel];

    [self.view setNeedsUpdateConstraints];

    [self.avatarImageView refreshWithModel:model.author];

    self.nameLabel.text = self.model.author.name;

    self.logoViewController.view.hidden = ![self shouldShowLogoViewController];
    self.followButton.hidden = self.viewModel.followButtonHidden;;

    if ([[TSVDebugInfoConfig config] debugInfoEnabled]) {
        self.debugInfoView.debugInfo = model.debugInfo;
    }

}

- (void)refreshTitleLabel
{
    @weakify(self);
    [TSVTitleLabelConfigurator updateAttributeTitleForLabel:self.titleLabel
                                               trimHashTags:!self.activityTag.hidden
                                                       text:self.model.title
                                        richTextStyleConfig:self.model.titleRichSpanJSONString
                                                allBoldFont:NO
                                                   fontSize:14
                                               activityName:self.model.activity.name
                                            prependUserName:NO
                                                   userName:self.model.author.name
                                               linkTapBlock:[self.viewModel titleLinkClickBlock]
                                           userNameTapBlock:^{
                                               @strongify(self);
                                               [self.viewModel clickUserNameButton];
                                           }];
    [self.titleLabel sizeThatFits:CGSizeMake([self titleLabelWidth], CGFLOAT_MAX)];
}

- (void)updateDiggState
{
    self.likeButton.labelString = [TTBusinessManager formatCommentCount:self.model.diggCount];
    self.likeButton.imageString = self.model.userDigg ? @"hts_vp_like_press" : @"hts_vp_like";
    self.likeButton.selected = self.model.userDigg;
    self.likeButton.label.textColor = [UIColor tt_defaultColorForKey:self.model.userDigg ? kColorText4 : kColorText7];
    [self.view setNeedsLayout];
}

#pragma mark - Action

- (BOOL)alertIfNotValid
{
    if (self.model.isDelete) {
        [HTSVideoPlayToast show:@"视频已被删除"];
        return YES;
    }
    return !self.model;
}

- (void)digg
{
    [self _showPlusOneDiggAnimation];

    CGFloat viewWidth = 300;
    NSString *animationPath = [[NSBundle mainBundle] pathForResource:@"like" ofType:@"json" inDirectory:@"HTSVideoPlay.bundle"];
    LOTAnimationView *animationView = [LOTAnimationView animationWithFilePath:animationPath];
    animationView.contentMode = UIViewContentModeScaleAspectFit;
    animationView.bounds = CGRectMake(0, 0, viewWidth, CGRectGetHeight(self.view.frame));
    animationView.center = self.view.center;
    [self.view addSubview:animationView];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [animationView playWithCompletion:^(BOOL animationFinished) {
        [animationView removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];

    if ([self alertIfNotValid]) {
        return;
    }

    if (!self.model.userDigg) {
        [self.viewModel doubleTapView];
        [self updateDiggState];
        //point:视频点赞
    }
}

- (void)cancelDigg
{
    if ([self alertIfNotValid]) {
        return;
    }

    if (self.model.userDigg) {
        [self doSafeCancelDigg];
    }
}


- (void)_onLikeButtonClicked:(UIControl * )sender
{
    if (!self.model) {
        return;
    }
    
    NSString *eventName;
    if (!self.model.userDigg) {
        eventName = @"rt_like";
    } else {
        eventName = @"rt_unlike";
    }
    [AWEVideoDetailTracker trackEvent:eventName
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{
                                        @"user_id": self.model.author.userID ?: @"",
                                        @"position": @"detail_bottom_bar",
                                        }];

    if (!self.model.userDigg) {
            [self digg];
            //point:视频点赞
    } else {
        [self cancelDigg];
    }
}

- (void)_showPlusOneDiggAnimation
{
    [SSMotionRender motionInView:self.likeButton.iconImageView
                          byType:SSMotionTypeZoomInAndDisappear
                           image:[UIImage imageNamed:@"hts_add_all_dynamic"]
                     offsetPoint:CGPointMake(0, -9.0)];

    self.likeButton.iconImageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    self.likeButton.iconImageView.contentMode = UIViewContentModeCenter;    // 这行代码很神奇，没有的话动画的效果就不对
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.likeButton.iconImageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        self.likeButton.alpha = 0;
    } completion:^(BOOL finished) {
        self.likeButton.alpha = 0;
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.likeButton.iconImageView.transform = CGAffineTransformMakeScale(1.f,1.f);
            self.likeButton.alpha = 1;
        } completion:nil];
    }];
}
- (void)doSafeCancelDigg
{

    self.model.diggCount -= 1;
    self.model.userDigg = NO;
    [self postDiggCountSyncNotification];
    [self.model save];
    [self updateDiggState];

    [AWEVideoDetailManager cancelDiggVideoItemWithID:self.model.groupID completion:nil];
}

- (void)postDiggCountSyncNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSVShortVideoDiggCountSyncNotification"
                                                        object:nil
                                                      userInfo:@{@"group_id" : self.model.groupID ?:@"",
                                                                 @"user_digg" : @(self.model.userDigg),}];
}

- (void)_onInputButtonClicked:(UIButton *)sender
{
    if (!self.model) {
        return;
    }
    
    [self.viewModel clickWriteCommentButton];
}

- (void)_onCommentButtonClicked:(UIButton *)sender
{
    [self.viewModel clickCommentButton];
}

- (void)_onShareButtonClicked:(UIButton *)sender
{
    [self.viewModel clickShareButton];
}

- (void)_onCheckChallengeButtonClicked:(UIButton *)sender
{
    [self.viewModel clickCheckChallengeButton];
}

#pragma mark - Actions

- (void)handleAvatarClick:(id)sender
{
    [self.viewModel clickAvatarButton];
}

- (void)handleUserNameClick:(id)sender
{
    [self.viewModel clickUserNameButton];
}

- (void)handleFollowClick:(id)sender
{
    [self.viewModel clickFollowButton];
}

- (void)handleReportClick:(id)sender
{
    [self.viewModel clickMoreButton];
}

- (void)handleCloseClick:(id)sender
{
    [self.viewModel clickCloseButton];
}

#pragma mark -
- (void)skStoreViewDidDisappear:(NSNotification *)notification
{
    [self refreshLogoImage];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self refreshLogoImage];
}

- (void)refreshLogoImage
{
    [self.logoViewController refreshLogoImage];
    [self.view setNeedsUpdateConstraints];
}

#pragma mark - iPhone X 适配

- (void)updateViewFrameForSafeAreaIfNeeded
{
    if ([TTDeviceHelper isIPhoneXDevice]) {
        CGFloat safeAreaTop = self.viewSafeAreaInsets.top;
        
        self.topBarView.top = safeAreaTop - 17;
        self.topBarGradientLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 120);
        self.bottomGradientLayer.frame = CGRectMake(0, self.view.bounds.size.height - 220, CGRectGetWidth(self.view.bounds), 220);
    }
}

#pragma mark -
- (void)refreshTagHiddenStatusWithModel:(TTShortVideoModel *)model
{
    if (!isEmptyString(model.labelForDetail)) {
        self.tagInfoView.hidden = NO;
    } else {
        self.tagInfoView.hidden = YES;
    }
    
    if (!isEmptyString(model.labelForInteract)) {
        self.interactTag.hidden = NO;
    } else {
        self.interactTag.hidden = YES;
    }
    
    if (!isEmptyString(model.activity.name) && ![HTSVideoSwitch shouldHideActivityTag]) {
        self.activityTag.hidden = NO;
    } else {
        self.activityTag.hidden = YES;
    }

    if (model.challengeInfo.allowChallenge) {
        [AWEVideoDetailTracker trackEvent:@"shortvideo_pk_show"
                                    model:self.model
                          commonParameter:self.commonTrackingParameter
                           extraParameter:nil];
        self.challengeTagHasShowed = YES;
        self.challengeTag.hidden = NO;
    } else {
        self.challengeTag.hidden = YES;
    }
}

- (BOOL)shouldShowLogoViewController
{
    if ([self.model isAuthorMyself]) {
        return NO;
    }
    
    NSDictionary *configDic = [AWEVideoPlayTransitionBridge getConfigDictWithGroupSource:self.model.groupSource];
    if ([configDic[@"should_display"] integerValue] == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - Recommend Card
- (void)showRecommendCardView
{
    if (self.recViewController.viewModel.userCards.count > 0) {
        
        [self.viewModel trackFollowCardEvent];
        self.recViewController.view.hidden = NO;
        self.recViewController.view.alpha = 0;
        
        self.recArrowButton.hidden = NO;
        if (self.viewModel.isArrowRotationBackground) {
            [UIView performWithoutAnimation:^{
                self.recArrowButton.imageView.transform = CGAffineTransformMakeRotation(0);
                self.recArrowButton.alpha = 0;
            }];
        }

        [self.userInfoContainerView setNeedsUpdateConstraints];
        [self.userInfoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.height.equalTo(@24);
            make.bottom.equalTo(self.operationView.mas_top).offset(-171);
        }];
        [self.userInfoContainerView updateConstraintsIfNeeded];
  
        [UIView animateWithDuration:0.22f customTimingFunction:CustomTimingFunctionSineOut animation:^{
            
            [self.view layoutIfNeeded];
            self.recViewController.view.alpha = 1;
            self.recArrowButton.alpha = 1;
            self.titleLabel.alpha = 0;
            self.musicInfoView.alpha = 0;
            if (!self.viewModel.isArrowRotationBackground) {
                self.recArrowButton.imageView.transform = CGAffineTransformMakeRotation(0);
            }
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)dismissRecommendCardView
{
    UIView *topmostView;
    if ([self.titleLabel.attributedText length]) {
        topmostView = self.titleLabel;
    } else if (self.musicInfoView.hidden == NO) {
        topmostView = self.musicInfoView;
    } else {
        topmostView = self.operationView;
    }
    [self.userInfoContainerView setNeedsUpdateConstraints];
    [self.userInfoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.height.equalTo(@24);
        make.bottom.equalTo(topmostView.mas_top).offset(-16);
    }];
    [self.userInfoContainerView updateConstraintsIfNeeded];

    [UIView animateWithDuration:0.22f customTimingFunction:CustomTimingFunctionSineOut animation:^{
        [self.view layoutIfNeeded];
        self.titleLabel.alpha = 1;
        self.musicInfoView.alpha = 1;
        if (!self.viewModel.isArrowRotationBackground) {
            self.recArrowButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.045f customTimingFunction:CustomTimingFunctionSineOut animation:^{
        self.recViewController.view.alpha = 0;
        if (self.viewModel.isArrowRotationBackground) {
            self.recArrowButton.alpha = 0;
        }
    } completion:^(BOOL finished) {
        self.recViewController.view.hidden = YES;
    }];
}

- (void)dismissRecommendArrow
{
    if (!self.recArrowButton.hidden) {
        [UIView animateWithDuration:0.045f customTimingFunction:CustomTimingFunctionSineOut animation:^{
            self.recArrowButton.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)tapToFoldRecCard
{
    [self.viewModel singleTapView];
}

- (void)onRecArrowButtonClicked:(id)sender
{
    [self.viewModel clickRecommendArrow];
}


@end
