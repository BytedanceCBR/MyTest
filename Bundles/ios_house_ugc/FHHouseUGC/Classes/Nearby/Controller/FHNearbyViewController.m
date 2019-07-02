//
//  FHNearbyViewController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHNearbyViewController.h"
#import "UIColor+Theme.h"
#import "FHLocManager.h"
#import "TTThemedAlertController.h"
#import "TTUIResponderHelper.h"
#import "TTReachability.h"
#import "FHUserTracker.h"

@interface FHNearbyViewController ()

@property(nonatomic, strong) CLLocation *currentLocaton;
@property(nonatomic, assign) NSTimeInterval lastRequestTime;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;

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
    
    [self addEnterCategoryLog];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear {
    [self loadFeedListView];
    [self.feedVC viewWillAppear];
    
    if ([[NSDate date]timeIntervalSince1970] - _enterTabTimestamp > 24*60*60) {
        //超过一天
        _enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
    }
}

- (void)viewWillDisappear {
    [self addStayCategoryLog];
}

- (void)initView {
    if(!self.feedVC){
        self.view.backgroundColor = [UIColor whiteColor];
    
        self.feedVC =[[FHCommunityFeedListController alloc] init];
        _feedVC.listType = FHCommunityFeedListTypeNearby;
        _feedVC.currentLocaton = self.currentLocaton;
        _feedVC.view.frame = self.view.bounds;
        _feedVC.tracerDict = [self.tracerDict mutableCopy];
        [self addChildViewController:_feedVC];
        [self.view addSubview:_feedVC.view];
        [self.feedVC viewWillAppear];
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
    [self trackLocationAuthShow];
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"你还没有开启定位服务哦" message:@"请在手机设置中开启定位服务，获取更多周边小区趣事" preferredType:TTThemedAlertControllerTypeAlert];
    [alertVC addActionWithGrayTitle:@"我知道了" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        [wself trackLocationAuthClick:YES];
        [wself initView];
    }];
    
    [alertVC addActionWithTitle:@"开启定位" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        [wself trackLocationAuthClick:NO];
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

#pragma mark - 埋点

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName];
    TRACK_EVENT(@"enter_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

- (void)addStayCategoryLog {
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTabTimestamp;
    if (duration <= 0 || duration >= 24*60*60) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName];
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:(duration * 1000)];
    TRACK_EVENT(@"stay_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

- (NSString *)categoryName {
    return @"nearby_list";
}

- (void)trackLocationAuthShow {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName];
    TRACK_EVENT(@"ugc_location_authpopoup_show", tracerDict);
}

- (void)trackLocationAuthClick:(BOOL)isCancel {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName];
    if(isCancel){
        tracerDict[@"click_type"] = @"confirm";
    }else{
        tracerDict[@"click_type"] = @"open_location";
    }
    TRACK_EVENT(@"ugc_location_authpopoup_click", tracerDict);
}

@end
