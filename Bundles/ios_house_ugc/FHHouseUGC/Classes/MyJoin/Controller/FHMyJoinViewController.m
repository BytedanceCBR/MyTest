//
//  FHMyJoinViewController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHMyJoinViewController.h"
#import "FHMyJoinViewModel.h"
#import "FHUGCMyInterestedController.h"
#import "FHHouseUGCHeader.h"
#import "FHUGCConfig.h"
#import "FHUserTracker.h"
#import "TTArticleTabBarController.h"
#import "TTTabBarManager.h"

@interface FHMyJoinViewController ()

@property(nonatomic, strong) FHMyJoinViewModel *viewModel;
@property(nonatomic, assign) FHUGCMyJoinType type;
@property(nonatomic, strong) UIView *currentView;
@property(nonatomic, strong) FHUGCMyInterestedController *interestedVC;
@property(nonatomic, assign) BOOL showFeed;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;
@property(nonatomic, assign) BOOL noNeedAddEnterCategorylog;
@property(nonatomic, assign) BOOL noNeedRefreshData;

@end

@implementation FHMyJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topVCChange:) name:@"kExploreTopVCChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadVC];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadVC {
    self.showFeed = [FHUGCConfig sharedInstance].followList.count > 0;
    if(self.showFeed){
        if(!self.noNeedAddEnterCategorylog){
            [self addEnterCategoryLog];
        }else{
            self.noNeedAddEnterCategorylog = NO;
        }
        [self initFeedListVC];
        [self.feedListVC viewWillAppear];
        [self loadData];
    }else{
        [self initMyInterestListVC];
    }
}

- (void)viewWillAppear {
    [self loadVC];
    
    if ([[NSDate date]timeIntervalSince1970] - _enterTabTimestamp > 24*60*60) {
        //超过一天
        _enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear {
    if(self.showFeed){
        [self.feedListVC viewWillDisappear];
        [self addStayCategoryLog];
    }else{
        [self.interestedVC viewWillDisappear];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)topVCChange:(NSNotification *)notification {
    TTArticleTabBarController *vc = (TTArticleTabBarController *)notification.object;
    if ([[vc currentTabIdentifier] isEqualToString:kFHouseFindTabKey]) {
        self.noNeedAddEnterCategorylog = YES;
        self.noNeedRefreshData = YES;
    }else{
        self.noNeedAddEnterCategorylog = NO;
        self.noNeedRefreshData = NO;
    }
}

- (void)refreshFeedListData:(BOOL)isHead {
    if(!self.noNeedRefreshData){
        if(isHead){
            [self.feedListVC scrollToTopAndRefreshAllData];
        }else{
            [self.feedListVC scrollToTopAndRefresh];
        }
    }else{
        self.noNeedRefreshData = NO;
    }
}

- (void)initFeedListVC {
    if(self.type == FHUGCMyJoinTypeFeed){
        //考虑是否需要刷新数据
        return;
    }
    
    _interestedVC = nil;
    
    if(_currentView){
        [_currentView removeFromSuperview];
        _currentView = nil;
    }
    
    FHCommunityFeedListController *vc =[[FHCommunityFeedListController alloc] init];
    vc.listType = FHCommunityFeedListTypeMyJoin;
    vc.showErrorView = NO;
//    vc.hidePublishBtn = YES;
    vc.tableHeaderView = self.neighbourhoodView;
    vc.tracerDict = [self.tracerDict mutableCopy];
    
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    _currentView = vc.view;
    _feedListVC = vc;
    
    _type = FHUGCMyJoinTypeFeed;
}

- (void)initMyInterestListVC {
    if(self.type == FHUGCMyJoinTypeEmpty){
        if(!self.noNeedAddEnterCategorylog){
            [self.interestedVC viewWillAppear];
        }else{
            self.noNeedAddEnterCategorylog = NO;
        }
        return;
    }
    
    _feedListVC = nil;
    
    if(_currentView){
        [_currentView removeFromSuperview];
        _currentView = nil;
    }
    
    FHUGCMyInterestedController *vc =[[FHUGCMyInterestedController alloc] init];
    vc.type = FHUGCMyInterestedTypeEmpty;
    vc.tracerDict = @{
                      @"enter_from":@"neighborhood_tab"
                      };
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    _currentView = vc.view;
    _interestedVC = vc;
    
    _type = FHUGCMyJoinTypeEmpty;
}

- (FHMyJoinNeighbourhoodView *)neighbourhoodView {
    if(!_neighbourhoodView){
        _neighbourhoodView = [[FHMyJoinNeighbourhoodView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 194)];
    }
    return _neighbourhoodView;
}

- (FHMyJoinViewModel *)viewModel {
    if(!_viewModel){
        _viewModel = [[FHMyJoinViewModel alloc] initWithCollectionView:self.neighbourhoodView.collectionView controller:self];
        self.neighbourhoodView.delegate = _viewModel;
    }
    return _viewModel;
}

- (void)loadData {
    [self.viewModel requestData];
}

- (void)applicationDidEnterBackground {
    if(self.type == FHUGCMyJoinTypeFeed){
        [self addStayCategoryLog];
    }
}

- (void)applicationDidBecomeActive {
    if(self.type == FHUGCMyJoinTypeFeed){
        self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
    }
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName];
    tracerDict[@"show_type"] = @"feed_full";
    [tracerDict setValue:(self.withTips ? @(1):@(0)) forKey:@"with_tips"];
    TRACK_EVENT(@"enter_category", tracerDict);
    
    self.withTips = NO;
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

- (void)addStayCategoryLog {
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTabTimestamp;
    if (duration <= 0 || duration >= 24*60*60) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName];
    tracerDict[@"show_type"] = @"feed_full";
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:(duration * 1000)];
    [tracerDict setValue:@(0) forKey:@"with_tips"];
    TRACK_EVENT(@"stay_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

- (NSString *)categoryName {
    return @"my_join_list";
}

@end
