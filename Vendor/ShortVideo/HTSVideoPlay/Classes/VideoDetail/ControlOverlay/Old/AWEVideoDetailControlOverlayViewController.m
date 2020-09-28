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
#import "UIImageView+WebCache.h"
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
#import <lottie-ios/Lottie/Lottie.h>
#import "UIView+CustomTimingFunction.h"
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
#import "TTNavigationController.h"
#import "TSVDetailRouteHelper.h"
#import "NSDictionary+TTAdditions.h"
#import <TTBaseLib/TTBaseMacro.h>
#import "TSVAvatarImageView.h"
#import "HTSVideoSwitch.h"
#import "TTUGCPostCenterProtocol.h"
#import "TSVShortVideoPostTaskProtocol.h"
#import "TSVRecommendCardViewController.h"
#import "TSVRecommendCardModel.h"
#import "TSVRecommendCardViewModel.h"
#import "FHCommonApi.h"
#import "UIColor+Theme.h"
#import "UIImage+FIconFont.h"
#import <FHHouseBase/FHRealtorAvatarView.h>
#import "NSString+BTDAdditions.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHShortVideoTracerUtil.h"
#import "TTAccountManager.h"

static const CGFloat kCheckChallengeButtonWidth = 72;
static const CGFloat kCheckChallengeButtonHeight = 28;
static const CGFloat kCheckChallengeButtonLeftPadding = 28;

@import AssetsLibrary;

@interface AWEVideoDetailControlOverlayViewController ()<TTUGCAttributedLabelDelegate>

// Top controls
@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) CAGradientLayer *topBarGradientLayer;
@property (nonatomic, strong) FHRealtorAvatarView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *sourceImage;
//@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIView *userInfoContainerView;
@property (nonatomic, strong) UIView *layoutContainerView;

@property (nonatomic, strong) UIView *rightInfoView;

// Buttom controls
@property (nonatomic, strong) TTUGCAttributedLabel *titleLabel;
@property (nonatomic, strong) AWEDetailLogoViewController *logoViewController;
@property (nonatomic, strong) TSVIconLabelButton *commentButton;
@property (nonatomic, strong) TSVIconLabelButton *likeButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) CAGradientLayer *bottomGradientLayer;
//@property (nonatomic, strong) AWEAwemeMusicInfoView *musicInfoView;

@property (nonatomic, strong) TSVRecommendCardViewController *recViewController;
@property (nonatomic, strong) UIButton *recArrowButton;

@property (nonatomic, strong) NSLock *diggLock;     // Seems overkill to me, a boolean will do the trick
@property (nonatomic, assign) BOOL challengeTagHasShowed;

@property (nonatomic, strong) UIView *operationView;
@property (nonatomic, strong) UIButton *inputButton;

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

    @weakify(self);

    [RACObserve(self, model.user.relation.isFollowing) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        BOOL isFollowing = [x boolValue];
        if (!isFollowing && !self.recArrowButton.hidden) {
            [self dismissRecommendCardView];
            [self dismissRecommendArrow];
        }
    }];
    
    RAC(self, commentButton.labelString) = [RACObserve(self, model.commentCount) map:^id(NSNumber *commentCount) {
        return [TTBusinessManager formatCommentCount:[commentCount longLongValue]];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:@"SKStoreProductViewDidDisappearKey" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStateChange:) name:@"kFHUGCDiggStateChangeNotification" object:nil];
//    [RACObserve(self, viewModel.likeCountString) subscribeNext:^(id  _Nullable x) {
//        [self updateDiggState];
//    }];
    
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

- (void)sendShareTrakingWithActivityName:(NSString *)activityName
{
    NSString *type = [AWEVideoShareModel labelForContentItemType:activityName];
    NSAssert(type, @"Type should not be empty");
    [AWEVideoDetailTracker trackEvent:@"rt_share_to_platform"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{
                                        @"share_platform": type ?: @"",
                                        @"position": @"detail",
                                        @"event_type": @"house_app2c_v2"
                                        }];

}

- (UIView *)userInfoContainerView
{
    if (!_userInfoContainerView) {
        _userInfoContainerView = [[UIView alloc] init];
        _userInfoContainerView.backgroundColor = [UIColor clearColor];

        _avatarView = [[FHRealtorAvatarView alloc] init];
        _avatarView.userInteractionEnabled = YES;
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.layer.shadowOffset = CGSizeZero;
        _nameLabel.font = [UIFont themeFontMedium:14];
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
        CGFloat topInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
    self.topBarView.frame = CGRectMake(0, topInset, CGRectGetWidth(self.view.bounds), 64.0);
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

//    _moreButton = [[UIButton alloc] init];
//    [_moreButton setImage:[UIImage imageNamed:@"hts_vp_white_more_titlebar"] forState:UIControlStateNormal];
//    [_moreButton setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 0)];
//    [_moreButton addTarget:self action:@selector(handleReportClick:) forControlEvents:UIControlEventTouchUpInside];
//    _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-12, -12, -12, -12);
//
//    [self.topBarView addSubview:_moreButton];

    
//    [_layoutContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.topBarView);
//        make.left.equalTo(self.topBarView).offset(12.0);
//        make.height.equalTo(@48.0);
//        make.right.equalTo(_moreButton.mas_left).offset(-8.0);
//    }];


    [self addChildViewController:self.logoViewController];
    [self.topBarView addSubview:self.logoViewController.view];
    [self.logoViewController didMoveToParentViewController:self];
    self.logoViewController.view.hidden = YES;

    [self.logoViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@100);
        make.height.equalTo(@28);
        make.centerY.equalTo(self.topBarView.mas_centerY);
    }];

//    [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.topBarView);
//        make.right.equalTo(self.view).offset(-12.0);
//        make.height.equalTo(@50.0);
//        make.width.equalTo(@30.0);
//    }];
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
        label.numberOfLines = 0;
        label.delegate = self;
        label.extendsLinkTouchArea = NO;
        label.longPressGestureRecognizer.enabled = NO;
        label;
    });
    [self.view addSubview:self.titleLabel];

//    _musicInfoView = [AWEAwemeMusicInfoView new];
//    _musicInfoView.userInteractionEnabled = NO;
//    [self.view addSubview:_musicInfoView];

    
    _rightInfoView = [[UIView alloc]init];
     [self.view addSubview:_rightInfoView];

    _operationView = [[UIView alloc] init];
    [self.view addSubview:_operationView];

    _inputButton = [[TSVWriteCommentButton alloc] init];
    [_inputButton addTarget:self action:@selector(_onInputButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_operationView addSubview:_inputButton];


    _commentButton = [[TSVIconLabelButton alloc] initWithImage:@"shortvideo_comment" label:nil];
    _commentButton.label.textColor = [UIColor tt_defaultColorForKey:kColorText7];
    [_commentButton addTarget:self action:@selector(_onCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightInfoView addSubview:_commentButton];

    _likeButton = [[TSVIconLabelButton alloc] initWithImage:@"shortvideo_dig_normal" label:nil];
    _likeButton.iconImageView.image = ICON_FONT_IMG(24, @"\U0000e69c", [UIColor themeWhite]);
    _likeButton.label.textColor = [UIColor themeWhite];
    [_likeButton addTarget:self action:@selector(_onLikeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightInfoView addSubview:_likeButton];
    
    self.shareButton = [[UIButton alloc] init];
    self.shareButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    
    [self.shareButton setImage:[UIImage imageNamed:@"shortvideo_share"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(handleReportClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightInfoView addSubview:self.shareButton];

    [self.view addSubview:self.userInfoContainerView];
    
    self.sourceImage = [[UIImageView alloc]init];
    self.sourceImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview: self.sourceImage];

    [self addChildViewController:self.recViewController];
    [self.view addSubview:self.recViewController.view];
    [self.recViewController didMoveToParentViewController:self];
    self.recViewController.view.hidden = YES;
    
    [self.view addSubview:self.recArrowButton];
//    self.recArrowButton.hidden = YES;
    
    [self.rightInfoView addSubview:_avatarView];
    // add by zjing 去掉小视频关注
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAvatarClick:)]];

}

- (void)likeStateChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if(userInfo){
        NSInteger user_digg = [userInfo[@"action"] integerValue];
        NSInteger diggCount = [self.model.diggCount integerValue];
        NSInteger groupType = [userInfo[@"group_type"] integerValue];
        NSString *groupId = userInfo[@"group_id"];
        
        if(groupType == FHDetailDiggTypeSMALLVIDEO && [groupId isEqualToString:self.model.groupId]){
            if(user_digg == 0) {
                self.model.diggCount = [NSString stringWithFormat:@"%ld",diggCount - 1];
                self.model.userDigg = @"0";
            }else {
                self.model.diggCount = [NSString stringWithFormat:@"%ld",diggCount + 1];
                self.model.userDigg = @"1";
            }
            [self updateDiggState];
        }
    }
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
    
    CGFloat avatarSize = 40;
    
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
         bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    
    [_operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.mas_offset(50+bottomInset);
    }];
    [_inputButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.operationView);
    }];
    
    [_rightInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.operationView.mas_top).offset(-10);
        make.width.mas_offset(40);
    }];
    
    [_shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.rightInfoView);
        make.centerX.equalTo(self.rightInfoView);
        make.size.mas_equalTo(CGSizeMake(40, 50));
    }];
    
    [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.shareButton.mas_top).offset(-7);
        make.centerX.equalTo(self.rightInfoView);
        make.size.mas_equalTo(CGSizeMake(40, 50));
    }];
    
    [_likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.commentButton.mas_top).offset(-15);
        make.centerX.equalTo(self.rightInfoView);
        make.size.mas_equalTo(CGSizeMake(40, 50));
    }];
    
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.likeButton.mas_top).offset(-20);
        make.width.height.equalTo(@(avatarSize));
        make.centerX.equalTo(self.rightInfoView);
        make.top.equalTo(self.rightInfoView);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.userInfoContainerView);
        make.left.equalTo(self.userInfoContainerView);
        make.right.equalTo(self.userInfoContainerView);
        make.height.equalTo(@24.0);
    }];
    [_sourceImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.bottom.equalTo(self.userInfoContainerView.mas_top).offset(-2);
        make.height.mas_offset(16);
    }];

    UIView *topmostView;
    if ([self.titleLabel.attributedText length]) {
        topmostView = self.titleLabel;
//    } else if (self.musicInfoView.hidden == NO) {
//        topmostView = self.musicInfoView;
    } else {
//        topmostView = self.operationView;
    }
    
//    if (self.recViewController.view.hidden) {
//        [self.userInfoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.view).offset(15);
//            make.height.equalTo(@24);
//            make.bottom.equalTo(topmostView.mas_top).offset(-16);
//        }];
//    } else {
        [self.userInfoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.height.equalTo(@24);
            make.bottom.equalTo(self.titleLabel.mas_top).offset(-2);
        }];
//    }


    CGFloat followButtonMinRightMargin;
    CGFloat musicLeftAndRightMargin;
    CGFloat titleLeftAndRightMargin;
    
//    if (self.musicInfoView.hidden == NO) {
//        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.view).offset(15);
//            make.right.equalTo(self.rightInfoView.mas_left).offset(-30);
//            make.bottom.equalTo(self.musicInfoView.mas_top).offset(-10);
//        }];
//    } else {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.rightInfoView.mas_left).offset(-15);
            make.bottom.equalTo(self.operationView.mas_top).offset(-20);
        }];
//    }
    
//    [self.musicInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(@16.0);
//        make.right.equalTo(self.rightInfoView).offset(-15);
//        make.bottom.equalTo(self.operationView.mas_top).offset(-5);
//        make.height.equalTo(@16);
//    }];
    
    [self.logoViewController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@100);
    }];
    
    [self.recViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(@156);
        make.top.equalTo(self.userInfoContainerView.mas_bottom).offset(15);
    }];
    
    [super updateViewConstraints];
}

- (CGFloat)titleLabelWidth
{
        return self.view.bounds.size.width - 90;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    if (!isEmptyString(self.viewModel.musicLabelString)) {
//        [self.musicInfoView startAnimation];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//
//    if (!isEmptyString(self.viewModel.musicLabelString)) {
//        [self.musicInfoView stopAnimation];
//    }
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

    [self updateViewFrameForSafeAreaIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
//    if ([self.model.groupSource isEqualToString:AwemeGroupSource]){
//        [self.musicInfoView stopAnimation];
//    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setModel:(FHFeedUGCCellModel *)model
{
    _model = model;
    
    self.likeButton.labelString = [TTBusinessManager formatCommentCount:[self.model.diggCount intValue]];
    self.likeButton.imageString =  [self.model.userDigg boolValue]? @"shortvideo_dig_select" : @"shortvideo_dig_normal";
//    self.likeButton.iconImageView.image = self.model.userDigg ? ICON_FONT_IMG(24, @"\U0000e6b1", [UIColor themeOrange4]) : ICON_FONT_IMG(24, @"\U0000e69c", [UIColor themeWhite]);
    self.likeButton.selected = [self.model.userDigg boolValue];
//    self.likeButton.label.textColor = [self.model.userDigg boolValue] ? [UIColor themeOrange4] : [UIColor themeWhite];

//    NSString *musicLabelString = self.viewModel.musicLabelString;
//    if (!isEmptyString(musicLabelString)) {
//        [self.musicInfoView configRollingAnimationWithLabelString:musicLabelString];
//        [self.musicInfoView startAnimation];
//        self.musicInfoView.hidden = NO;
//    } else {
//        self.musicInfoView.hidden = YES;
//    }
    
//    self.musicInfoView.alpha = 1;
    self.titleLabel.alpha = 1;
    self.recViewController.view.hidden = YES;
    self.recArrowButton.hidden = YES;

    [self refreshTitleLabel];

    [self.view setNeedsUpdateConstraints];
    [self.avatarView updateAvatarWithTSVUserModel:model];
    [self.sourceImage bd_setImageWithURL:[NSURL URLWithString:model.videoSourceIcon]];
    if (self.model.videoSourceIcon.length > 0) {
        self.avatarView.hidden = YES;
    }else {
        self.avatarView.hidden = NO;
    }
    self.nameLabel.text = [NSString stringWithFormat:@"@%@",self.model.user.name];

    self.logoViewController.view.hidden = ![self shouldShowLogoViewController];

}

- (void)refreshTitleLabel
{
    @weakify(self);
    [TSVTitleLabelConfigurator updateAttributeTitleForLabel:self.titleLabel
                                               trimHashTags:NO
                                                       text:self.model.content
                                        richTextStyleConfig:@""
                                                allBoldFont:NO
                                                   fontSize:14
                                               activityName:@""
                                            prependUserName:NO
                                                   userName:self.model.user.name
                                               linkTapBlock:[self.viewModel titleLinkClickBlock]
                                           userNameTapBlock:^{
                                               @strongify(self);
                                               [self.viewModel clickUserNameButton];
                                           }];
    [self.titleLabel sizeThatFits:CGSizeMake([self titleLabelWidth], CGFLOAT_MAX)];
}

- (void)updateDiggState
{
    BOOL userDigg = [self.model.userDigg boolValue];
    self.likeButton.labelString = [TTBusinessManager formatCommentCount:[self.model.diggCount intValue]];
    self.likeButton.imageString = userDigg ? @"shortvideo_dig_select" : @"shortvideo_dig_normal";
//    self.likeButton.iconImageView.image = self.model.userDigg ? ICON_FONT_IMG(24, @"\U0000e6b1", [UIColor themeOrange4]) : ICON_FONT_IMG(24, @"\U0000e69c", [UIColor themeWhite]);
    self.likeButton.selected = userDigg;
//    self.likeButton.label.textColor = userDigg ? [UIColor themeOrange4] : [UIColor themeWhite];
    [self.view setNeedsLayout];
}

#pragma mark - Action

- (BOOL)alertIfNotValid
{
//    if (self.model.isDelete) {
//        [HTSVideoPlayToast show:@"视频已被删除"];
//        return YES;
//    }
    return !self.model;
}

- (void)digg
{
    
    
    [self _showPlusOneDiggAnimation];

    CGFloat viewWidth = 100;
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

    if (![self.model.userDigg boolValue]) {
        [self.viewModel doubleTapView];
        //point:视频点赞
    }
}

- (void)cancelDigg
{
    if ([self alertIfNotValid]) {
        return;
    }

    if ([self.model.userDigg boolValue]) {
        [self doSafeCancelDigg];
    }
}


- (void)_onLikeButtonClicked:(UIControl * )sender
{
    if (!self.model) {
        return;
    }
    
    if (![TTAccountManager isLogin]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *page_type = [FHShortVideoTracerUtil pageType];
        [params setObject:page_type forKey:@"enter_from"];
        [params setObject:@"click_publisher" forKey:@"enter_type"];
        // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
        [params setObject:@(YES) forKey:@"need_pop_vc"];
        [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
               if (type == TTAccountAlertCompletionEventTypeDone) {
                   //登录成功 走发送逻辑
                   if ([TTAccountManager isLogin]) {
                       [self diggAction];
                   }
               }
           }];
    }else {
        [self diggAction];
    }
}

- (void)diggAction {
        BOOL userDigg = [self.model.userDigg boolValue];
        NSString *eventName;
        if (!userDigg) {
            eventName = @"click_like";
        } else {
            eventName = @"click_dislike";
        }
    //    [AWEVideoDetailTracker trackEvent:eventName
    //                                model:self.model
    //                      commonParameter:self.commonTrackingParameter
    //                       extraParameter:@{
    //                                        @"user_id": self.model.user.userId ?: @"",
    //                                        @"position": @"feed_detail",
    //                                        }];
            [FHShortVideoTracerUtil clickLikeOrdisLikeWithWithName:eventName eventPosition:@"video" eventModel:self.model eventIndex:self.selfIndex commentId:nil];
        if (!userDigg) {
                [self digg];
                //point:视频点赞
        } else {
            [self cancelDigg];
        }
}

- (void)_onInputButtonClicked:(UIButton *)sender
{
    if (!self.model) {
        return;
    }
    
    [self.viewModel clickWriteCommentButton];
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
//    self.model.diggCount = [NSString stringWithFormat:@"%ld",[self.model.diggCount intValue] - 1];
//    self.model.userDigg = @"0";
//    [self postDiggCountSyncNotification];
//
    [FHCommonApi requestCommonDigg:[NSString stringWithFormat:@"%@", self.model.groupId] groupType:FHDetailDiggTypeSMALLVIDEO action:0 completion:nil];
}

//- (void)postDiggCountSyncNotification
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSVShortVideoDiggCountSyncNotification"
//                                                        object:nil
//                                                      userInfo:@{@"group_id" : self.model.groupId ?:@"",
//                                                                 @"user_digg" : @([self.model.userDigg intValue]),}];
//}


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
//    [self.viewModel clickUserNameButton];
}

- (void)handleFollowClick:(id)sender
{
    [self.viewModel clickFollowButton];
}

- (void)handleReportClick:(id)sender
{
    [self.viewModel clickMoreButton];
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
        CGFloat safeAreaTop = 0;
        if (@available(iOS 11.0, *)) {
            safeAreaTop = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        }
        self.topBarView.top = safeAreaTop - 17;
        self.topBarGradientLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 120);
        self.bottomGradientLayer.frame = CGRectMake(0, self.view.bounds.size.height - 220, CGRectGetWidth(self.view.bounds), 220);
    }
}


- (BOOL)shouldShowLogoViewController
{
//    if ([self.model isAuthorMyself]) {
        return NO;
//    }
//
//    NSDictionary *configDic = [AWEVideoPlayTransitionBridge getConfigDictWithGroupSource:self.model.groupSource];
//    if ([configDic[@"should_display"] integerValue] == 0) {
//        return NO;
//    }
//    return YES;
}

#pragma mark - Recommend Card
- (void)showRecommendCardView
{
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }

    CGFloat bottomInputFieldHeight = 50 + bottomInset;
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
            make.bottom.equalTo(self.view).offset(-171 - bottomInputFieldHeight);
        }];
        [self.userInfoContainerView updateConstraintsIfNeeded];
  
        [UIView animateWithDuration:0.22f customTimingFunction:CustomTimingFunctionSineOut animation:^{
            
            [self.view layoutIfNeeded];
            self.recViewController.view.alpha = 1;
            self.recArrowButton.alpha = 1;
            self.titleLabel.alpha = 0;
//            self.musicInfoView.alpha = 0;
            if (!self.viewModel.isArrowRotationBackground) {
                self.recArrowButton.imageView.transform = CGAffineTransformMakeRotation(0);
            }
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)dismissRecommendCardView
{
    CGFloat bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }

    CGFloat bottomInputFieldHeight = 50 + bottomInset;
//    UIView *topmostView;
//    if ([self.titleLabel.attributedText length]) {
//        topmostView = self.titleLabel;
//    } else if (self.musicInfoView.hidden == NO) {
//        topmostView = self.musicInfoView;
//    } else {
//        topmostView = self.operationView;
//    }
    [self.userInfoContainerView setNeedsUpdateConstraints];
    [self.userInfoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.height.equalTo(@24);
        make.bottom.equalTo(self.view).offset(-16-bottomInputFieldHeight);
    }];
    [self.userInfoContainerView updateConstraintsIfNeeded];

    [UIView animateWithDuration:0.22f customTimingFunction:CustomTimingFunctionSineOut animation:^{
        [self.view layoutIfNeeded];
        self.titleLabel.alpha = 1;
//        self.musicInfoView.alpha = 1;
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
