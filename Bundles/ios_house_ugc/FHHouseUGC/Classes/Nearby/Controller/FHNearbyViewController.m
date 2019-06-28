//
//  FHNearbyViewController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHNearbyViewController.h"
#import "FHHotTopicView.h"
#import "FHInterestCommunityView.h"
#import "UIColor+Theme.h"
#import "FHLocManager.h"
#import "TTThemedAlertController.h"
#import "TTUIResponderHelper.h"
#import "TTReachability.h"

@interface FHNearbyViewController ()

@property(nonatomic, strong) CLLocation *currentLocaton;
@property(nonatomic, assign) NSTimeInterval lastRequestTime;

@end

@implementation FHNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if([[FHLocManager sharedInstance] isHaveLocationAuthorization]){
        self.currentLocaton = [FHLocManager sharedInstance].currentLocaton;
        [self initView];
        self.lastRequestTime = [[NSDate date] timeIntervalSince1970];
    }else{
        [self showLocationGuideAlert];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadFeedListView];
    [self.feedVC viewWillAppear];
}

- (void)initView {
    if(!self.feedVC){
        self.view.backgroundColor = [UIColor whiteColor];
    
        self.feedVC =[[FHCommunityFeedListController alloc] init];
        _feedVC.listType = FHCommunityFeedListTypeNearby;
        _feedVC.currentLocaton = self.currentLocaton;
        _feedVC.view.frame = self.view.bounds;
        [self addChildViewController:_feedVC];
        [self.view addSubview:_feedVC.view];
    }else{
        _feedVC.currentLocaton = self.currentLocaton;
        [self.feedVC startLoadData];
    }
}

- (void)loadFeedListView {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970] - self.lastRequestTime;
    //间隔6小时再次进入页面会主动刷新
    if([[FHLocManager sharedInstance] isHaveLocationAuthorization] && currentTime > 21600 && [TTReachability isNetworkConnected]){
        self.currentLocaton = [FHLocManager sharedInstance].currentLocaton;
        [self initView];
        self.lastRequestTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)applicationDidBecomeActive {
    [self loadFeedListView];
}

- (void)showLocationGuideAlert {
    __weak typeof(self) wself = self;
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"你还没有开启定位服务哦" message:@"请在手机设置中开启定位服务，获取更多周边小区趣事" preferredType:TTThemedAlertControllerTypeAlert];
    [alertVC addActionWithGrayTitle:@"我知道了" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        [wself initView];
    }];
    
    [alertVC addActionWithTitle:@"开启定位" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        NSURL *jumpUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if ([[UIApplication sharedApplication] canOpenURL:jumpUrl]) {
            [[UIApplication sharedApplication] openURL:jumpUrl];
        }
    }];
    
    UIViewController *topVC = [TTUIResponderHelper topmostViewController];
    if (topVC) {
        [alertVC showFrom:topVC animated:YES];
    }
}


@end
