//
//  FHMessageSegmentedViewController.m
//  Pods
//
//  Created by bytedance on 2020/7/30.
//

#import "FHMessageSegmentedViewController.h"
#import "FHMessageViewController.h"
#import "TTDeviceHelper.h"
#import "IMManager.h"
#import "FHMessageViewModel.h"
#import "FHMessageNotificationTipsManager.h"
#import <FHMessageNotificationManager.h>
#import "UIViewController+Track.h"
#import <TTReachability/TTReachability.h>
#import "FHNoNetHeaderView.h"
#import <FHCHousePush/FHPushMessageTipView.h>
#import <FHCHousePush/FHPushAuthorizeManager.h>
#import <FHCHousePush/FHPushAuthorizeHelper.h>
#import <FHCHousePush/FHPushMessageTipView.h>
#import "FHBubbleTipManager.h"
#import <FHPopupViewCenter/FHPopupViewManager.h>
#import "TTAccountManager.h"
#import "UIViewController+NavigationBarStyle.h"
#import "FHCommonDefines.h"
#import "TTTabBarManager.h"
#import "TTTabBarItem.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "FHEnvContext.h"
#import "FHMessageManager.h"

@interface FHMessageBadgetNumberMonitorHelper : NSObject
@property (nonatomic, assign, readonly) NSInteger sysUnreadNumber;
@property (nonatomic, assign, readonly) NSInteger chatMsgUnreadNumber;
+ (instancetype)shared;
- (void)updateSystemUnreadNumber:(NSInteger)systemNumber chatUnreadNumber:(NSInteger)chatNumber;
@end
@interface FHMessageBadgetNumberMonitorHelper()
@property (nonatomic, assign) NSInteger sysUnreadNumber;
@property (nonatomic, assign) NSInteger chatMsgUnreadNumber;
@end
static FHMessageBadgetNumberMonitorHelper *_shared = nil;
@implementation FHMessageBadgetNumberMonitorHelper
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!_shared) {
            _shared = [[FHMessageBadgetNumberMonitorHelper alloc] init];
        }
    });
    return _shared;
}
- (void)updateSystemUnreadNumber:(NSInteger)systemNumber chatUnreadNumber:(NSInteger)chatNumber {
    self.sysUnreadNumber = systemNumber;
    self.chatMsgUnreadNumber = chatNumber;
}
@end

typedef NS_ENUM(NSInteger, FHSegmentedControllerAnimatedTransitionDirection) {
    FHSegmentedControllerAnimatedTransitionDirectionUnknown,
    FHSegmentedControllerAnimatedTransitionDirectionFromLeftToRight,
    FHSegmentedControllerAnimatedTransitionDirectionFromRightToLeft
};

@interface FHSegmentedControllerAnimatedTransitionContext : NSObject <UIViewControllerContextTransitioning>

@property (nonatomic, copy) void (^completionHandler)(BOOL completed);

@property (nonatomic, copy) void (^interactiveTransitionCompletionHandler)(void);
@property (nonatomic, copy) void (^interactiveTransitionCancellationHandler)(void);

@property (nonatomic, getter=isAnimated) BOOL animated;
@property (nonatomic, getter=isInteractive) BOOL interactive;

@property (nonatomic,weak) UIView *containerView;
@property (nonatomic,copy) NSDictionary *viewControllers;

@property (nonatomic) CGRect initalFrameOfFromView;
@property (nonatomic) CGRect initalFrameOfToView;

@property (nonatomic) CGRect finialFrameOfFromView;
@property (nonatomic) CGRect finialFrameOfToView;

@property (nonatomic) FHSegmentedControllerAnimatedTransitionDirection direction;

@property (nonatomic, getter = isCancelled) BOOL cancelled;
@end

@implementation FHSegmentedControllerAnimatedTransitionContext

- (UIModalPresentationStyle)presentationStyle {
    return UIModalPresentationCustom;
}

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController direction:(FHSegmentedControllerAnimatedTransitionDirection)direction {
    
    if ((self = [super init])) {
        self.containerView = fromViewController.view.superview;
        self.viewControllers = @{
                                 UITransitionContextFromViewControllerKey:fromViewController,
                                 UITransitionContextToViewControllerKey:toViewController,
                                 };
        
        self.direction = direction;
        [self updateFramesWithInteractiveTransitionPercentComplete:0];
    }
    
    return self;
}

- (void)updateFramesWithInteractiveTransitionPercentComplete:(double)percentComplete {
    CGFloat travelDistance = 0;
    switch (self.direction) {
        case FHSegmentedControllerAnimatedTransitionDirectionFromLeftToRight:
            travelDistance = self.containerView.bounds.size.width;
            break;
        case FHSegmentedControllerAnimatedTransitionDirectionFromRightToLeft:
            travelDistance = -self.containerView.bounds.size.width;
            break;
        default:
            break;
    }
    
    CGRect initalFrameOfFromView = self.containerView.bounds;
    CGRect initalFrameOfToView = CGRectOffset(self.containerView.bounds, -travelDistance, 0);
    CGRect finalFrameOfFromView = CGRectOffset(self.containerView.bounds, travelDistance, 0);
    CGRect finalFrameOfToView = initalFrameOfFromView;
    
    self.initalFrameOfFromView = CGRectOffset(initalFrameOfFromView, travelDistance * percentComplete, 0);
    self.initalFrameOfToView = CGRectOffset(initalFrameOfToView, travelDistance * percentComplete, 0);
    self.finialFrameOfFromView = finalFrameOfFromView;
    self.finialFrameOfToView = finalFrameOfToView;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.initalFrameOfFromView;
    } else {
        return self.initalFrameOfToView;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.finialFrameOfFromView;
    } else {
        return self.finialFrameOfToView;
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.viewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionHandler) {
        self.completionHandler(didComplete);
    }
}

- (BOOL)transitionWasCancelled {
    return self.isCancelled;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [self updateFramesWithInteractiveTransitionPercentComplete:percentComplete];
}

- (void)finishInteractiveTransition {
    if (self.interactiveTransitionCompletionHandler) {
        self.interactiveTransitionCompletionHandler();
    }
}

- (void)cancelInteractiveTransition {
    self.cancelled = YES;
    [self updateInteractiveTransition:0];
    if (self.interactiveTransitionCancellationHandler) {
        self.interactiveTransitionCancellationHandler();
    }
}

@end

@interface FHSegmentedControllerAnimatedTransition :  NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation FHSegmentedControllerAnimatedTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    CGRect initalFrameOfToView = [transitionContext initialFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    CGRect finalFrameOfToView = [transitionContext finalFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    CGFloat movingDistance = ABS(CGRectGetMinX(initalFrameOfToView) - CGRectGetMinX(finalFrameOfToView));
    return 0.3 * (movingDistance/CGRectGetWidth([UIScreen mainScreen].bounds));
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (!transitionContext.animated) {
        fromViewController.view.frame = [transitionContext finalFrameForViewController:fromViewController];
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }
    else if ([transitionContext transitionWasCancelled]) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromViewController.view.frame = [transitionContext initialFrameForViewController:fromViewController];
            toViewController.view.frame = [transitionContext initialFrameForViewController:toViewController];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        toViewController.view.frame = [transitionContext initialFrameForViewController:toViewController];
        fromViewController.view.frame = [transitionContext initialFrameForViewController:fromViewController];

        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromViewController.view.frame = [transitionContext finalFrameForViewController:fromViewController];
            toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

@end


@interface FHSegmentedControllerInteractiveTransition : NSObject <UIViewControllerInteractiveTransitioning>

@property (nonatomic,strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic) CGFloat percentComplete;

@end

@implementation FHSegmentedControllerInteractiveTransition

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    self.percentComplete = percentComplete;
    
    [self.transitionContext updateInteractiveTransition:percentComplete];
    UIViewController* fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    fromViewController.view.frame = [self.transitionContext initialFrameForViewController:fromViewController];
    toViewController.view.frame = [self.transitionContext initialFrameForViewController:toViewController];
}

- (void)cancelInteractiveTransition {
    [self.transitionContext cancelInteractiveTransition];
}

- (void)finishInteractiveTransition {
    [self.transitionContext finishInteractiveTransition];
}

@end

@interface FHMessageSegmentedViewController ()<UIGestureRecognizerDelegate,FHMessageSegmentedViewControllerDelegate, IMChatStateObserver, AccountStatusListener>

@property (nonatomic,strong,readwrite) HMSegmentedControl *segmentedControl;
@property (nonatomic,readwrite,weak) UIViewController *activeViewController;
@property (nonatomic,weak) UIView *contentView;

@property (nonatomic,weak) UIPanGestureRecognizer *interactivePanGestureRecognizer;
@property (nonatomic) CGPoint interactivePanInitialPoint;
@property (nonatomic) FHSegmentedControllerAnimatedTransitionDirection interactivePanDirection;
@property (nonatomic,strong) FHSegmentedControllerAnimatedTransitionContext *interactiveTransitionContext;
@property (nonatomic,strong) FHSegmentedControllerInteractiveTransition *interactiveTransitionAnimator;
@property (nonatomic, strong) NSString *enterType;
@property (nonatomic, strong) FHNoNetHeaderView *notNetHeader;
@property (nonatomic, assign) CGFloat notNetHeaderHeight;
@property (nonatomic, strong) FHPushMessageTipView *pushTipView;
@property (nonatomic, assign) CGFloat pushTipViewHeight;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, assign) BOOL loginStateChange;
@property (nonatomic, strong) RACSubject *conversationUpdateSubject;

@end

@implementation FHMessageSegmentedViewController

- (RACSubject *)conversationUpdateSubject {
    if(!_conversationUpdateSubject) {
        _conversationUpdateSubject = [RACSubject subject];
    }
    return _conversationUpdateSubject;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    for (UIViewController *viewController in _viewControllers) {
        if (viewController.parentViewController == self) {
            [viewController willMoveToParentViewController:nil];
            if (viewController.isViewLoaded) [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
    }
    _viewControllers = viewControllers.copy;
    self.activeViewController = nil;
    if (self.isViewLoaded) {
        [self configureSegmentedControlUsingViewControllers:viewControllers];
    }
}

- (void)setActiveViewController:(UIViewController *)activeViewController {
    _activeViewController = activeViewController;
    [self addEnterCategoryLogWithType:_enterType];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)configureSegmentedControlUsingViewControllers:(NSArray *)viewControllers {
//    NSMutableArray *arrayM = [[NSMutableArray alloc] init];
//    for (UIViewController *viewController in viewControllers.objectEnumerator.allObjects) {
//        [arrayM addObject:viewController.title];
//    }
//    self.segmentedControl.sectionTitles = arrayM;
    [self.segmentedControl sizeToFit];
    if (self.segmentedControl.sectionTitles.count) {
        NSArray<IMConversation *> *allConversations = [[IMManager shareInstance].chatService allConversations];
        if ([allConversations count] > 0) {
            self.segmentedControl.selectedSegmentIndex = 1;
        } else {
            self.segmentedControl.selectedSegmentIndex = 0;
        }
    }
    [self segmentedControlValueChangedWithAnimate:NO];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
//    self.topView = [[UIView alloc] init];
//    self.topView.backgroundColor = [UIColor themeGray8];
//    [self.view addSubview:_topView];
//    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
//    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20) + 54;
//    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.mas_equalTo(0);
//        make.height.mas_equalTo(naviHeight);
//    }];
    
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"通知", @"微聊"]];
    NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
                                          NSForegroundColorAttributeName: [UIColor themeGray1]};
    segmentedControl.titleTextAttributes = titleTextAttributes;
    NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontSemibold:18],
                                                  NSForegroundColorAttributeName: [UIColor themeGray1]};
    segmentedControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
        segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(5, 0, 5, 0);
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.selectionIndicatorWidth = 20.0f;
    segmentedControl.selectionIndicatorHeight = 4.0f;
    segmentedControl.selectionIndicatorCornerRadius = 2.0f;
    segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 0, -3, 0);
    segmentedControl.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
    [segmentedControl setBackgroundColor:[UIColor clearColor]];
    segmentedControl.isMessageTab = YES;
    WeakSelf;
    segmentedControl.indexChangeBlock = ^(NSInteger index) {
        StrongSelf;
        self.enterType = @"click";
        [self segmentedControlValueChangedWithAnimate:YES];
    };
    //self.navigationItem.titleView = segmentedControl;
    //[self.customNavBarView addSubview:segmentedControl];
    self.segmentedControl = segmentedControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.ttDisableDragBack = YES;
    _isLogin = [TTAccountManager isLogin];
    _loginStateChange = YES;
    self.enterType = @"dafault";
    self.ttTrackStayEnable = YES;
    _dataList = [[NSMutableArray alloc] init];
    _combiner = [[FHConversationDataCombiner alloc] init];
    [[IMManager shareInstance] addChatStateObverver:self];
    self.delegate = self;
    UIPanGestureRecognizer *interactivePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    interactivePanGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:interactivePanGestureRecognizer];
    self.interactivePanGestureRecognizer = interactivePanGestureRecognizer;
    
    [self setupDefaultNavBar:NO];
    self.customNavBarView.bgView.backgroundColor = [UIColor themeGray7];
    self.customNavBarView.leftBtn.hidden = [self leftActionHidden];
    self.customNavBarView.seperatorLine.hidden = YES;
    [self.customNavBarView addSubview:_segmentedControl];
    NSInteger count = _segmentedControl.sectionTitles.count;
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.customNavBarView);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(-6);
        make.width.mas_equalTo(80 * count);
    }];

    __weak typeof(self) weakSelf = self;
    FHMessageViewController *imViewController = [[FHMessageViewController alloc] init];
    imViewController.fatherVC = self;
    [imViewController setUpdateRedPoint:^(NSInteger chatNumber, BOOL hasRedPoint, NSInteger systemMessageNumber) {
        [weakSelf updateRedPointWithChat:chatNumber andHasChatRedPoint:hasRedPoint andSystemMessage:systemMessageNumber];
    }];
    imViewController.isSegmentedChildViewController = YES;
    imViewController.dataType = FHMessageRequestDataTypeIM;

    FHMessageViewController *systemViewController = [[FHMessageViewController alloc] init];
    systemViewController.fatherVC = self;
    [systemViewController setUpdateRedPoint:^(NSInteger chatNumber, BOOL hasRedPoint, NSInteger systemMessageNumber) {
        [weakSelf updateRedPointWithChat:chatNumber andHasChatRedPoint:hasRedPoint andSystemMessage:systemMessageNumber];
    }];
    systemViewController.isSegmentedChildViewController = YES;
    systemViewController.dataType = FHMessageRequestDataTypeSystem;
    
    self.viewControllers = @[systemViewController, imViewController];
    //self.segmentedControl.hidden = YES;
    
//        [weakSelf setActiveViewController:weakSelf.viewControllers.lastObject];
//        [wself refreshDataWithType:tag];
 //   };
//    [self.customNavBarView addSubview:self.topView];
//    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.customNavBarView);
//        make.width.mas_equalTo(180);
//        make.height.mas_equalTo(30);
//        make.bottom.mas_equalTo(0);
//    }];
    [self check];
    _notNetHeader = [[FHNoNetHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
    [self.view addSubview:_notNetHeader];
    if ([TTReachability isNetworkConnected]) {
        [_notNetHeader setHidden:YES];
    } else {
        [_notNetHeader setHidden:NO];
    }
    [self.notNetHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        if ([TTReachability isNetworkConnected]) {
            make.height.mas_equalTo(0);
            _notNetHeaderHeight = 0;
        }else {
            make.height.mas_equalTo(36);
            _notNetHeaderHeight = 36;
        }
    }];
    __weak typeof(self)wself = self;
    _pushTipView = [[FHPushMessageTipView alloc] initAuthorizeTipWithCompleted:^(FHPushMessageTipCompleteType type) {
        [wself addTipClickLog:type];
        if (type == FHPushMessageTipCompleteTypeDone) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        } else if (type == FHPushMessageTipCompleteTypeCancel) {
            [wself hidePushTip];
        }
    }];
    [self.view addSubview:_pushTipView];
    BOOL isEnabled = [FHPushAuthorizeManager isMessageTipEnabled];
    isEnabled = YES;
    CGFloat pushTipHeight = isEnabled ? 36 : 0;
    self.pushTipView.hidden = pushTipHeight > 0 ? NO : YES;
    _pushTipViewHeight = pushTipHeight;
    [self.pushTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.notNetHeader.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(pushTipHeight);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange:) name:TTReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(periodicalFetchUnreadMessage:) name:kPeriodicalFetchUnreadMessage object:nil];
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KUSER_UPDATE_NOTIFICATION object:nil] throttle:2] subscribeNext:^(NSNotification *_Nullable x) {
        @strongify(self)
        [self refreshConversationList];
        //[self check];
    }];
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kTTMessageNotificationTipsChangeNotification object:nil] throttle:2] subscribeNext:^(NSNotification *_Nullable x) {
        @strongify(self)
        if([FHMessageNotificationTipsManager sharedManager].tipsModel){
            [self.combiner resetSystemChannels:self.dataList ugcUnreadMsg:[FHMessageNotificationTipsManager sharedManager].tipsModel];
            [self reloadData];
            return;
        }
    }];
    [[IMManager shareInstance].accountCenter registerAccountStatusListener:self];
    [self updateContentView];
    
    
    [[[self.conversationUpdateSubject throttle:0.5] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self refreshConversationListDisplayEmptyMaskViewIfNeed];
    }];
}

- (void)didLogin {
    if (!_isLogin) {
        _loginStateChange = YES;
    }
    _isLogin = YES;
    [self refreshUnreadNumberManually];
}

- (void)didLogout {
    if (_isLogin) {
        _loginStateChange = YES;
    }
    _isLogin = NO;
    [self refreshUnreadNumberManually];
}

- (void)refreshUnreadNumberManually {
    [self.viewControllers enumerateObjectsUsingBlock:^(FHMessageViewController   * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
            [vc startLoadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FHBubbleTipManager shareInstance].canShowTip = NO;
    [self applicationDidBecomeActive];
    [self refreshConversationList];
    [self check];
    [self startLoadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[FHPopupViewManager shared] triggerPopupView];
    [[FHPopupViewManager shared] triggerPendant];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
    [FHBubbleTipManager shareInstance].canShowTip = YES;
}

- (void)check {
    if (self.loginStateChange) {
        self.loginStateChange = NO;
        NSArray<IMConversation *> *allConversations = [[IMManager shareInstance].chatService allConversations];
        if (!_isLogin || [allConversations count] == 0) {
            [self selectViewControllerAtIndex:0];
        } else {
            [self selectViewControllerAtIndex:1];
        }
    }
}

- (void)updateRedPointWithChat:(NSInteger)chatNumber andHasChatRedPoint:(BOOL)hasRedPoint andSystemMessage:(NSInteger)systemMessageNumber {
    NSInteger boolNumber = hasRedPoint ? 1 : 0;
    self.segmentedControl.sectionMessageTips = @[@(systemMessageNumber), @(chatNumber)];
    self.segmentedControl.sectionRedPoints = @[@0, @(boolNumber)];
    
    // 先添加监控息tab的未读数更新逻辑
    [self monitorBadgetNumberAndReport:systemMessageNumber chatNumber:chatNumber];
    // 用单例记录一下系统消息未读数和微聊消息未读数，用于之后比较消息tab未读数
    [[FHMessageBadgetNumberMonitorHelper shared] updateSystemUnreadNumber:systemMessageNumber chatUnreadNumber:chatNumber];
    // 刷新消息tab未读数
    [[FHEnvContext sharedInstance].messageManager refreshBadgeNumber];
}

- (void)monitorBadgetNumberAndReport:(NSInteger)systemMessageNumber chatNumber:(NSInteger)chatNumber {
    // 监听消息tab的未读数变化事件，每次变化比较和当前系统通知未读数与微聊未读数的和是否相等，不相等就上报
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TTTabBarItem *tabBarItem = [[TTTabBarManager sharedTTTabBarManager] tabItemWithIdentifier:kFHouseMessageTabKey];
        [[[[RACObserve(tabBarItem.ttBadgeView, badgeNumber) distinctUntilChanged] throttle:1] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
            NSInteger messageTabBadgeNumber = [x integerValue];
            NSInteger sysUnreadNumber = [FHMessageBadgetNumberMonitorHelper shared].sysUnreadNumber;
            NSInteger chatUnreadNumber = [FHMessageBadgetNumberMonitorHelper shared].chatMsgUnreadNumber;
            if(sysUnreadNumber + chatUnreadNumber != messageTabBadgeNumber) {
                NSLog(@"test badget number: %@ + %@ = %@", @(sysUnreadNumber), @(chatUnreadNumber), @(messageTabBadgeNumber));
                NSMutableDictionary *categoryDict = [NSMutableDictionary dictionary];
                categoryDict[@"error"] = @"1";
                categoryDict[@"reason"] = @"消息tab未读数与分段页面未读数之和不相等";
                NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
                extraDict[@"top:notify_tab_unread"] = @(sysUnreadNumber).stringValue;
                extraDict[@"top:chat_tab_unread"] = @(chatUnreadNumber).stringValue;
                extraDict[@"bottom:message_tab_unread"] = @(messageTabBadgeNumber).stringValue;
                extraDict[@"manager:total_unread"] = @([[FHEnvContext sharedInstance].messageManager getTotalUnreadMessageCount]).stringValue;
                extraDict[@"manager:sysMsg_unread"] = @([[FHEnvContext sharedInstance].messageManager systemMsgUnreadNumber]).stringValue;
                extraDict[@"manager:ugcMsg_unread"] = @([[FHEnvContext sharedInstance].messageManager ugcMsgUnreadNumber]).stringValue;
                extraDict[@"manager:im_chat_unread"] = @([[FHEnvContext sharedInstance].messageManager chatMsgUnreadNumber]).stringValue;
                extraDict[@"im_sdk:unmute_conv_unread"] = @([[IMManager shareInstance] chatUnmuteUnreadTotalNumber]);
                extraDict[@"im_sdk:mute_conv_unread"]  = @([[IMManager shareInstance] chatMutedUnreadTotalNumber]);
                extraDict[@"im_sdk:unmute_conv_info"] = [[IMManager shareInstance].chatService allConversationsInfoDict];
                extraDict[@"im_sdk:unmute_timo_conv_info"] = [[IMManager shareInstance].chatService allTIMOConversationsInfoDict];
                [[HMDTTMonitor defaultManager] hmdTrackService:@"f_message_tab_badget_number_display_error"
                                                        metric:nil
                                                      category:categoryDict.copy
                                                         extra:extraDict.copy];
            }
        }];
    });
}

- (void)applicationDidBecomeActive
{
    BOOL isEnabled = [FHPushAuthorizeManager isMessageTipEnabled];
    CGFloat pushTipHeight = isEnabled ? 36 : 0;
    if (pushTipHeight > 0) {
        [self addTipShowLog];
    }
    self.pushTipView.hidden = pushTipHeight > 0 ? NO : YES;
    _pushTipViewHeight = pushTipHeight;
    [self.pushTipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(pushTipHeight);
    }];
    [self updateContentView];
}

- (void)hidePushTip {
    NSInteger lastTimeShowMessageTip = (NSInteger)[[NSDate date] timeIntervalSince1970];
    [FHPushAuthorizeHelper setLastTimeShowMessageTip:lastTimeShowMessageTip];
    self.pushTipView.hidden = YES;
    [self.pushTipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    _pushTipViewHeight = 0;
    [self updateContentView];
}

- (NSString *)getPageType {
    return @"message_list";
}

- (BOOL)leftActionHidden {
    return YES;
}

- (CGFloat)getBottomMargin {
    return 49;
}

- (BOOL) isAlignToSafeBottom {
    return YES;
}

- (void)startLoadData {
    FHMessageViewController *vc = self.activeViewController;
    if (vc) {
        [vc startLoadData];
    }
}

- (void)periodicalFetchUnreadMessage:(NSNotification *)notification {
    [self startLoadData];
}

- (void)networkStateChange:(NSNotification *)notification {
    _notNetHeaderHeight = 0.f;
    if ([TTReachability isNetworkConnected]) {
        [_notNetHeader setHidden:YES];
        [_notNetHeader mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
    } else {
        _notNetHeaderHeight = 36.f;
        [_notNetHeader setHidden:NO];
        [_notNetHeader mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(36);
        }];
    }
    [_notNetHeader layoutIfNeeded];
    [self updateContentView];
}

- (void)updateContentView {
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, _notNetHeaderHeight + _pushTipViewHeight, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

- (void)reloadData {
    FHMessageViewController *vc = self.activeViewController;
    if (vc && vc.viewModel) {
        [vc.viewModel reloadData];
    }
}

- (void)refreshConversationList {
    NSArray<IMConversation *> *allConversations = [[IMManager shareInstance].chatService allConversations];
    [_combiner resetConversations:allConversations];
    FHMessageViewController *vc = self.activeViewController;
    if (vc && vc.viewModel) {
        [vc.viewModel reloadData];
    }
}

- (void)refreshConversationListDisplayEmptyMaskViewIfNeed {
    NSArray<IMConversation *> *allConversations = [[IMManager shareInstance].chatService allConversations];
    [_combiner resetConversations:allConversations];
    FHMessageViewController *vc = self.activeViewController;
    if (vc && vc.viewModel) {
        [vc.viewModel checkShouldShowEmptyMaskView];
    }
}

// 更新单个会话的内容
- (void)conversationUpdated:(NSString *)conversationIdentifier {
    if(conversationIdentifier.length > 0) {
        [self.conversationUpdateSubject sendNext:conversationIdentifier];
    }
}

// 更新多个会话的个数和顺序
- (void)conversationsUpdated:(NSArray<NSString *> *)conversationIdentifiers {
    [self refreshConversationList];
}

- (void)setInteractivePanDirection:(FHSegmentedControllerAnimatedTransitionDirection)interactivePanDirection {
    if (_interactivePanDirection == interactivePanDirection) return;
    
    _interactivePanDirection = interactivePanDirection;
    
    [self.interactiveTransitionAnimator cancelInteractiveTransition];
    self.interactiveTransitionAnimator = nil;
    self.interactiveTransitionContext = nil;
    
    
    UIViewController *toViewController = nil;
    UIViewController *fromViewController = self.activeViewController;

    switch (interactivePanDirection) {
        case FHSegmentedControllerAnimatedTransitionDirectionFromLeftToRight:{
            if (self.segmentedControl.selectedSegmentIndex - 1 >= 0) {
                toViewController = self.viewControllers[self.segmentedControl.selectedSegmentIndex - 1];
            }
        } break;
        case FHSegmentedControllerAnimatedTransitionDirectionFromRightToLeft:{
            if (self.segmentedControl.selectedSegmentIndex + 1 < (NSInteger)self.segmentedControl.sectionTitles.count) {
                toViewController = self.viewControllers[self.segmentedControl.selectedSegmentIndex + 1];
            }
        } break;
        default:
            break;
    }
    
    if (toViewController) {
        void (^viewControllerTransitionPrepare)(void) = ^{
            if ([self.delegate respondsToSelector:@selector(segmentedViewController:willChangeContentViewControllerFromViewController:toViewController:)]) {
                [self.delegate segmentedViewController:self willChangeContentViewControllerFromViewController:fromViewController toViewController:toViewController];
            }
            
            [fromViewController willMoveToParentViewController:nil];
            [self addChildViewController:toViewController];
            toViewController.view.frame = self.contentView.bounds;
            toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.contentView addSubview:toViewController.view];
            [self makeNavigationControllerComputeAndApplyScrollContentInsetDeltaForViewController:toViewController];
            
            self.segmentedControl.userInteractionEnabled = NO;
        };
        
        void(^viewControllerTransitionComplete)(void) = ^ {
            [fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
            [toViewController didMoveToParentViewController:self];
            self.activeViewController = toViewController;
            
            if ([self.delegate respondsToSelector:@selector(segmentedViewController:didChangeContentViewControllerFromViewController:toViewController:)]) {
                [self.delegate segmentedViewController:self didChangeContentViewControllerFromViewController:fromViewController toViewController:toViewController];
            }
            
            self.segmentedControl.userInteractionEnabled = YES;
            
            self.segmentedControl.selectedSegmentIndex = [self.viewControllers indexOfObject:self.activeViewController];
        };
        
        void(^viewControllerTransitionRollback)(void) = ^{
            [toViewController willMoveToParentViewController:nil];
            [self addChildViewController:fromViewController];
            fromViewController.view.frame = self.contentView.bounds;
            fromViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.contentView addSubview:fromViewController.view];
            [self makeNavigationControllerComputeAndApplyScrollContentInsetDeltaForViewController:fromViewController];
            
            [toViewController.view removeFromSuperview];
            [toViewController removeFromParentViewController];
            [fromViewController didMoveToParentViewController:self];
            self.activeViewController = fromViewController;
            
            if ([self.delegate respondsToSelector:@selector(segmentedViewController:didChangeContentViewControllerFromViewController:toViewController:)]) {
                [self.delegate segmentedViewController:self didChangeContentViewControllerFromViewController:toViewController toViewController:fromViewController];
            }
            
            self.segmentedControl.selectedSegmentIndex = [self.viewControllers indexOfObject:self.activeViewController];
        };
        
        
        viewControllerTransitionPrepare();
        
        id<UIViewControllerAnimatedTransitioning>animator = [[FHSegmentedControllerAnimatedTransition alloc] init];
        id<UIViewControllerInteractiveTransitioning>interactiveAnimator = [[FHSegmentedControllerInteractiveTransition alloc] init];
        FHSegmentedControllerAnimatedTransitionContext *transitionContext = [[FHSegmentedControllerAnimatedTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController direction:interactivePanDirection];
        
        transitionContext.animated = YES;
        transitionContext.interactive = YES;
        
        transitionContext.completionHandler = ^(BOOL didComplete) {
            viewControllerTransitionComplete();
            if ([animator respondsToSelector:@selector(animationEnded:)]) {
                [animator animationEnded:didComplete];
            }
            if (!didComplete) {
                viewControllerTransitionRollback();
            }
        };

        typeof(transitionContext) __weak weakTransitionContext = transitionContext;
        [transitionContext setInteractiveTransitionCompletionHandler:^{
            [animator animateTransition:weakTransitionContext];
        }];
        [transitionContext setInteractiveTransitionCancellationHandler:^{
            [animator animateTransition:weakTransitionContext];
        }];
        self.interactiveTransitionContext = transitionContext;
        self.interactiveTransitionAnimator = interactiveAnimator;
        [interactiveAnimator startInteractiveTransition:transitionContext];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    self.enterType = @"flip";
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            //Begin
            self.interactivePanDirection = FHSegmentedControllerAnimatedTransitionDirectionUnknown;
            self.interactivePanInitialPoint = [sender locationInView:self.view];
        }break;
        case UIGestureRecognizerStateChanged:{
            //Change
            CGPoint currentPoint = [sender locationInView:self.view];
            [UIView performWithoutAnimation:^{
                if (currentPoint.x > self.interactivePanInitialPoint.x) {
                    self.interactivePanDirection = FHSegmentedControllerAnimatedTransitionDirectionFromLeftToRight;
                } else {
                    self.interactivePanDirection = FHSegmentedControllerAnimatedTransitionDirectionFromRightToLeft;
                }
            }];
            double progress = ABS(currentPoint.x - self.interactivePanInitialPoint.x)/CGRectGetWidth(self.contentView.bounds);
            [self.interactiveTransitionAnimator updateInteractiveTransition:progress];
        }break;
        default:{
            //End
            CGPoint velocity = [sender velocityInView:self.view];
            if (velocity.x < -20) {
                if (self.interactivePanDirection == FHSegmentedControllerAnimatedTransitionDirectionFromRightToLeft) {
                    [self.interactiveTransitionAnimator finishInteractiveTransition];
                } else {
                    [self.interactiveTransitionAnimator cancelInteractiveTransition];
                }
            } else if (velocity.x > 20) {
                if (self.interactivePanDirection == FHSegmentedControllerAnimatedTransitionDirectionFromLeftToRight) {
                    [self.interactiveTransitionAnimator finishInteractiveTransition];
                } else {
                    [self.interactiveTransitionAnimator cancelInteractiveTransition];
                }
            } else {
                CGPoint currentPoint = [sender locationInView:self.view];
                double progress = ABS(currentPoint.x - self.interactivePanInitialPoint.x)/CGRectGetWidth(self.contentView.bounds);
                if (progress > 0.4) {
                    [self.interactiveTransitionAnimator finishInteractiveTransition];
                } else {
                    [self.interactiveTransitionAnimator cancelInteractiveTransition];
                }
            }
            self.interactiveTransitionContext = nil;
            self.interactiveTransitionAnimator = nil;
        }break;
    }
}

- (void)addEnterCategoryLogWithType:(NSString *)enterType {
    if (!self.activeViewController) {
        return;
    }
    FHMessageViewController *vc = self.activeViewController;
    [vc addEnterCategoryLogWithType: enterType];
}

#pragma mark - GestureDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (void)segmentedControlValueChangedWithAnimate:(BOOL)animated {
    if (self.viewControllers.count && self.segmentedControl.selectedSegmentIndex >= 0 && self.segmentedControl.selectedSegmentIndex < (NSInteger)self.viewControllers.count) {
        UIViewController *toViewController = self.viewControllers[self.segmentedControl.selectedSegmentIndex];
        UIViewController *fromViewController = self.activeViewController;
        
        if ((fromViewController != toViewController && fromViewController.parentViewController == self) || !fromViewController) {
            
            if ([self.delegate respondsToSelector:@selector(segmentedViewController:willChangeContentViewControllerFromViewController:toViewController:)]) {
                [self.delegate segmentedViewController:self willChangeContentViewControllerFromViewController:fromViewController toViewController:toViewController];
            }
            
            [fromViewController willMoveToParentViewController:nil];
            [self addChildViewController:toViewController];
            toViewController.view.frame = self.contentView.bounds;
            toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.contentView addSubview:toViewController.view];
            [self makeNavigationControllerComputeAndApplyScrollContentInsetDeltaForViewController:toViewController];
            
            self.segmentedControl.userInteractionEnabled = NO;

            void(^viewControllerTransitionCompletedHandler)(void) = ^(void) {
                [fromViewController.view removeFromSuperview];
                [fromViewController removeFromParentViewController];
                [toViewController didMoveToParentViewController:self];
                self.activeViewController = toViewController;
                
                if ([self.delegate respondsToSelector:@selector(segmentedViewController:didChangeContentViewControllerFromViewController:toViewController:)]) {
                    [self.delegate segmentedViewController:self didChangeContentViewControllerFromViewController:fromViewController toViewController:toViewController];
                }
                
                self.segmentedControl.userInteractionEnabled = YES;
            };
            

            if (fromViewController) {
                id<UIViewControllerAnimatedTransitioning>animator = [[FHSegmentedControllerAnimatedTransition alloc] init];
                
                NSUInteger fromIndex = [self.viewControllers indexOfObject:fromViewController];
                NSUInteger toIndex = [self.viewControllers indexOfObject:toViewController];
                FHSegmentedControllerAnimatedTransitionContext *transitionContext = [[FHSegmentedControllerAnimatedTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController direction:(toIndex > fromIndex)?FHSegmentedControllerAnimatedTransitionDirectionFromRightToLeft:FHSegmentedControllerAnimatedTransitionDirectionFromLeftToRight];
                
                transitionContext.animated = animated;
                transitionContext.interactive = NO;
                transitionContext.completionHandler = ^(BOOL didComplete) {
                    viewControllerTransitionCompletedHandler();
                    if ([animator respondsToSelector:@selector(animationEnded:)]) {
                        [animator animationEnded:didComplete];
                    }
                };
                [animator animateTransition:transitionContext];
            } else {
                viewControllerTransitionCompletedHandler();
            }
        }
    }
}

- (void)selectViewControllerAtIndex:(NSInteger)index {
    self.segmentedControl.selectedSegmentIndex = index;
    [self segmentedControlValueChangedWithAnimate:NO];
}

- (void)makeNavigationControllerComputeAndApplyScrollContentInsetDeltaForViewController:(UIViewController *)viewController {
        SEL computeAndApplyInsetSelector = NSSelectorFromString([@[ @"_computeAndApply", @"ScrollContentInsetDeltaForViewController:"] componentsJoinedByString:@""]);
        if ([self.navigationController respondsToSelector:computeAndApplyInsetSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.navigationController performSelector:computeAndApplyInsetSelector withObject:viewController];
#pragma clang diagnostic pop
        }
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return self.activeViewController.automaticallyAdjustsScrollViewInsets;
}

#pragma mark - FHMessageSegmentedViewControllerDelegate

- (void)segmentedViewController:(FHMessageSegmentedViewController *)segmentedViewController willChangeContentViewControllerFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
    
}

- (void)segmentedViewController:(FHMessageSegmentedViewController *)segmentedViewController didChangeContentViewControllerFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
    //self.topView.selectIndex = [self.viewControllers indexOfObject:toViewController];
}

- (void)addTipClickLog:(FHPushMessageTipCompleteType)type
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"page_type"] = @"messagetab";
    if (type == FHPushMessageTipCompleteTypeDone) {
        params[@"click_type"] = @"confirm";
    }else {
        params[@"click_type"] = @"cancel";
    }
    [FHUserTracker writeEvent:@"tip_click" params:params];
}

-(NSDictionary *)categoryLogDict {
    FHMessageViewController *vc = self.activeViewController;
    NSInteger badgeNumber = [[vc.viewModel messageBridgeInstance] getMessageTabBarBadgeNumber];
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"enter_type"] = @"click_tab";
    tracerDict[@"tab_name"] = @"message";
    tracerDict[@"with_tips"] = badgeNumber > 0 ? @"1" : @"0";
    
    return tracerDict;
}

-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
    
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_tab", tracerDict);
}

- (void)addTipShowLog
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"page_type"] = @"messagetab";
    [FHUserTracker writeEvent:@"tip_show" params:params];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)dealloc
{
    
}

@end
