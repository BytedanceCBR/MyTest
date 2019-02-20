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

@interface FHMessageViewController ()<UIViewControllerErrorHandler>

@property(nonatomic, strong) FHMessageViewModel *viewModel;

@end

@implementation FHMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showenRetryButton = YES;
    self.ttTrackStayEnable = YES;
    
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSURL *url = [NSURL URLWithString:[@"sslocal://open_single_chat?target_user_id=50264240862&chat_title=谷春晖&house_cover=https://p3.pstatp.com/large/f100-image/R41qHUI3GYuu6B_1Xia0z1&house_type=1&house_title=4室2厅 刘湾小区刘湾小区…&house_des=70平/南北/高层/刘湾小区&house_price=170万&house_avg_price=5000/平&house_id=1231231&house_type=2" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        [[TTRoute sharedRoute] openURLByPushViewController:url];
//    });
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startLoadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];

}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.leftBtn.hidden = YES;
    self.customNavBarView.title.text = @"消息";
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
    
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    _tableView.tableHeaderView = headerView;
    
    [self.containerView addSubview:_tableView];
    [self.containerView addSubview:_notNetHeader];
    
    [self addDefaultEmptyViewFullScreen];
}

- (void)networkStateChange:(NSNotification *)notification {
    if ([TTReachability isNetworkConnected]) {
        [_notNetHeader setHidden:YES];
    } else {
        [_notNetHeader setHidden:NO];
    }
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ([TTReachability isNetworkConnected]) {
            make.top.left.right.bottom.mas_equalTo(self.containerView);
        } else {
            make.top.mas_equalTo(self.containerView).offset(30);
            make.left.right.bottom.mas_equalTo(self.containerView);
        }
    }];
}


- (void)initConstraints {
    CGFloat bottom = 49;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([TTReachability isNetworkConnected]) {
            make.top.left.right.bottom.mas_equalTo(self.containerView);
        } else {
            make.top.mas_equalTo(self.containerView).offset(30);
            make.left.right.bottom.mas_equalTo(self.containerView);
        }
    }];
}

- (void)initViewModel {
    _viewModel = [[FHMessageViewModel alloc] initWithTableView:_tableView controller:self];
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

@end
