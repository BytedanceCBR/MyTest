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

@interface FHMyJoinViewController ()

@property(nonatomic, strong) FHMyJoinViewModel *viewModel;
@property(nonatomic, assign) FHUGCMyJoinType type;
@property(nonatomic, strong) UIView *currentView;
@property(nonatomic, strong) FHUGCMyInterestedController *interestedVC;
@property(nonatomic, assign) BOOL showFeed;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;

@end

@implementation FHMyJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadVC];
}

- (void)loadVC {
    self.showFeed = [FHUGCConfig sharedInstance].followList.count > 0;
    if(self.showFeed){
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
}

- (void)viewWillDisappear {
    if(self.showFeed){
        [self addStayCategoryLog];
    }else{
        [self.interestedVC viewWillDisappear];
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
    vc.tableHeaderView = self.neighbourhoodView;
    vc.tracerDict = [self.tracerDict mutableCopy];
    
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    _currentView = vc.view;
    _feedListVC = vc;
    
    _type = FHUGCMyJoinTypeFeed;
    
    [self addEnterCategoryLog];
}

- (void)initMyInterestListVC {
    if(self.type == FHUGCMyJoinTypeEmpty){
        return;
    }
    
    _feedListVC = nil;
    
    if(_currentView){
        [_currentView removeFromSuperview];
        _currentView = nil;
    }
    
    FHUGCMyInterestedController *vc =[[FHUGCMyInterestedController alloc] init];
    vc.type = FHUGCMyInterestedTypeEmpty;
    
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

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName];
    tracerDict[@"show_type"] = @"feed_full";
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
    tracerDict[@"show_type"] = @"feed_full";
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:(duration * 1000)];
    TRACK_EVENT(@"stay_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

- (NSString *)categoryName {
    return @"my_join_list";
}

@end
