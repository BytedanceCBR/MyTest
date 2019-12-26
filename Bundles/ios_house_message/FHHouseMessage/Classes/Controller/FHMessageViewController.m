//
//  FHMessageViewController.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import "FHMessageViewController.h"
#import "FHMessageViewModel.h"
#import <Masonry.h>
#import "UIViewController+NavbarItem.h"
#import "UIColor+Theme.h"
#import "TTReachability.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "UIViewController+Track.h"
#import "FHTracerModel.h"
#import "FHUserTracker.h"
#import "TTRoute.h"
#import "ChatMsg.h"
#import "IMManager.h"
#import <TTReachability/TTReachability.h>
#import "FHBubbleTipManager.h"
#import "ReactiveObjC.h"
#import "UIView+House.h"
#import <FHCHousePush/FHPushMessageTipView.h>
#import <FHCHousePush/FHPushAuthorizeManager.h>
#import <FHCHousePush/FHPushAuthorizeHelper.h>
#import <FHCHousePush/FHPushMessageTipView.h>
#import <FHHouseBase/FHBaseTableView.h>
#import <FHMessageNotificationManager.h>
#import "FHSpringHangView.h"
#import <FHEnvContext.h>

@interface FHMessageViewController ()

@property(nonatomic, strong) FHMessageViewModel *viewModel;
@property(nonatomic, strong) FHPushMessageTipView *pushTipView;
@property (nonatomic, copy)     NSString       *enter_from;// 外部传入
//春节活动运营位
@property (nonatomic, strong) FHSpringHangView *springView;

@end

@implementation FHMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showenRetryButton = YES;
    self.ttTrackStayEnable = YES;
    self.enter_from = self.tracerDict[UT_ENTER_FROM];
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoReload) name:KUSER_UPDATE_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(periodicalFetchUnreadMessage:) name:kPeriodicalFetchUnreadMessage object:nil];
    
    if([FHEnvContext isSpringHangOpen]){
        [self addSpringView];
    }
}

- (void)addSpringView {
    if(!_springView){
        self.springView = [[FHSpringHangView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        [self.view addSubview:_springView];
        _springView.hidden = YES;
        
        CGFloat bottom = 49;
        if (@available(iOS 11.0 , *)) {
            bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
        }
        
        [_springView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view).offset(-bottom - 85);
            make.width.height.mas_equalTo(80);
            make.right.mas_equalTo(self.view).offset(-2);
        }];
    }
}

- (void)applicationDidBecomeActive
{
    BOOL isEnabled = [FHPushAuthorizeManager isMessageTipEnabled];
    CGFloat pushTipHeight = isEnabled ? 36 : 0;
    if (pushTipHeight > 0) {
        [self addTipShowLog];
    }
    self.pushTipView.hidden = pushTipHeight > 0 ? NO : YES;
    [self.pushTipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(pushTipHeight);
    }];
    
    //春节活动运营位
    if([FHEnvContext isSpringHangOpen]){
        [self.springView show:@"message"];
    }
}


- (void)periodicalFetchUnreadMessage:(NSNotification *)notification {
    [self startLoadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //春节活动运营位
    if([FHEnvContext isSpringHangOpen]){
        [self.springView show:@"message"];
    }
    [FHBubbleTipManager shareInstance].canShowTip = NO;
    [self startLoadData];
    [self applicationDidBecomeActive];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
    [FHBubbleTipManager shareInstance].canShowTip = YES;
}

- (void)addTipShowLog
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"page_type"] = @"messagetab";
    [FHUserTracker writeEvent:@"tip_show" params:params];

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

- (void)userInfoReload {
    [_tableView reloadData];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.leftBtn.hidden = [self leftActionHidden];
    self.customNavBarView.title.text = @"消息";
}

- (BOOL)leftActionHidden {
    return YES;
}

- (void)initView {
    self.containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    
    _notNetHeader = [[FHNoNetHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    if ([TTReachability isNetworkConnected]) {
        [_notNetHeader setHidden:YES];
    } else {
        [_notNetHeader setHidden:NO];
    }
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

    _tableView = [[FHBaseTableView alloc] init];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01f)];
    _tableView.tableHeaderView = headerView;

    [self.containerView addSubview:_tableView];
    [self.containerView addSubview:_notNetHeader];
    [self.containerView addSubview:_pushTipView];

    [self addDefaultEmptyViewFullScreen];
}

- (void)hidePushTip
{
    NSInteger lastTimeShowMessageTip = (NSInteger)[[NSDate date] timeIntervalSince1970];
    [FHPushAuthorizeHelper setLastTimeShowMessageTip:lastTimeShowMessageTip];
    self.pushTipView.hidden = YES;
    [self.pushTipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
}

- (void)networkStateChange:(NSNotification *)notification {
    if ([TTReachability isNetworkConnected]) {
        [_notNetHeader setHidden:YES];
        [_notNetHeader mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    } else {
        [_notNetHeader setHidden:NO];
        [_notNetHeader mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
        }];
    }
//    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        if ([TTReachability isNetworkConnected]) {
//            make.top.left.right.bottom.mas_equalTo(self.contaicognerView);
//        } else {
//            make.top.mas_equalTo(self.containerView).offset(30);
//            make.left.right.bottom.mas_equalTo(self.containerView);
//        }
//    }];
}


- (void)initConstraints {
    CGFloat bottom = [self getBottomMargin];
    if (@available(iOS 11.0 , *)) {
        if([self isAlignToSafeBottom]){
            bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
        }
    }
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(44);
        if (@available(iOS 11.0, *)) {
              make.top.mas_equalTo(self.view).offset(44.f + self.view.tt_safeAreaInsets.top);
//            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
    [self.notNetHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        if ([TTReachability isNetworkConnected]) {
            make.height.mas_equalTo(0);
        }else {
            make.height.mas_equalTo(30);
        }
    }];
    BOOL isEnabled = [FHPushAuthorizeManager isMessageTipEnabled];
    CGFloat pushTipHeight = isEnabled ? 36 : 0;
    self.pushTipView.hidden = pushTipHeight > 0 ? NO : YES;
    [self.pushTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.notNetHeader.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(pushTipHeight);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pushTipView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.containerView);
    }];
}

- (CGFloat)getBottomMargin {
    return 49;
}

- (void)initViewModel {
    _viewModel = [[FHMessageViewModel alloc] initWithTableView:_tableView controller:self];
    [_viewModel setPageType:[self getPageType]];
    if (self.enter_from.length > 0) {
        [_viewModel setEnterFrom:self.enter_from];
    }
}

- (NSString *)getPageType {
    return @"message_list";
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

-(NSDictionary *)categoryLogDict {
    NSInteger badgeNumber = [[self.viewModel messageBridgeInstance] getMessageTabBarBadgeNumber];
    
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

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return _viewModel.dataList.count == 0 ? NO : YES; //默认会显示空
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

- (BOOL) isAlignToSafeBottom {
    return YES;
}
@end
