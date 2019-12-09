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
#import "TTArticleTabBarController.h"
#import "TTTabBarManager.h"

@interface FHNearbyViewController ()

@property(nonatomic, strong) CLLocation *currentLocaton;
@property(nonatomic, assign) NSTimeInterval lastRequestTime;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;
@property(nonatomic, assign) BOOL noNeedAddEnterCategorylog;
@property(nonatomic, assign) BOOL needRefresh;
@property(nonatomic, strong) TTThemedAlertController *alertVC;

@end

@implementation FHNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.needRefresh = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topVCChange:) name:@"kExploreTopVCChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if([[FHLocManager sharedInstance] isHaveLocationAuthorization]){
        self.currentLocaton = [FHLocManager sharedInstance].currentLocaton;
        [self initView];
        self.lastRequestTime = [[NSDate date] timeIntervalSince1970];
    }else{
        [self checkNeedShowLocationAlert];
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
    
    if(!self.noNeedAddEnterCategorylog){
        [self addEnterCategoryLog];
    }else{
        self.noNeedAddEnterCategorylog = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear {
    [self.feedVC viewWillDisappear];
    [self addStayCategoryLog];
    // add by zjing 不对外暴露了，先暂时这么搞
    if ([self.alertVC respondsToSelector:@selector(dismissSelfFromParentViewControllerDidCancel)]) {
        [self.alertVC performSelector:@selector(dismissSelfFromParentViewControllerDidCancel)];
    }
    self.needRefresh = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)topVCChange:(NSNotification *)notification {
    TTArticleTabBarController *vc = (TTArticleTabBarController *)notification.object;
    if ([[vc currentTabIdentifier] isEqualToString:kFHouseFindTabKey]) {
        self.noNeedAddEnterCategorylog = YES;
    }else{
        self.noNeedAddEnterCategorylog = NO;
    }
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
    //开启定位时候需要获取定位信息
    if([[FHLocManager sharedInstance] isHaveLocationAuthorization]){
        self.currentLocaton = [FHLocManager sharedInstance].currentLocaton;
    }
    //间隔6小时再次进入页面会主动刷新
    if(currentTime > 21600){
        [self initView];
        self.lastRequestTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)applicationDidEnterBackground {
    [self addStayCategoryLog];
}

- (void)applicationDidBecomeActive {
    if(self.needRefresh){
        [self loadFeedListView];
    }
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

// UGC定位弹窗 3天 弹一次
- (void)checkNeedShowLocationAlert {
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970];
    NSLog(@"-----:%lf",duration);
}

- (void)showLocationGuideAlert {
    __weak typeof(self) wself = self;
    self.needRefresh = NO;
    [self trackLocationAuthShow];
    self.alertVC = [[TTThemedAlertController alloc] initWithTitle:@"你还没有开启定位服务哦" message:@"请在手机设置中开启定位服务，获取更多周边小区趣事" preferredType:TTThemedAlertControllerTypeAlert];
    [_alertVC addActionWithGrayTitle:@"我知道了" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        [wself trackLocationAuthClick:YES];
        wself.needRefresh = YES;
        [wself initView];
        wself.lastRequestTime = [[NSDate date] timeIntervalSince1970];
    }];
    
    [_alertVC addActionWithTitle:@"开启定位" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        [wself trackLocationAuthClick:NO];
        wself.needRefresh = YES;
        NSURL *jumpUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if ([[UIApplication sharedApplication] canOpenURL:jumpUrl]) {
            [[UIApplication sharedApplication] openURL:jumpUrl];
        }
    }];
    
    UIViewController *topVC = [TTUIResponderHelper topmostViewController];
    if (topVC) {
        [_alertVC showFrom:topVC animated:YES];
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
