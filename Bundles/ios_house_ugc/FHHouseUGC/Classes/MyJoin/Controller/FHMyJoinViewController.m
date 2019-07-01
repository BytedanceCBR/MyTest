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
#import "UIViewController+Track.h"
#import "FHUserTracker.h"

@interface FHMyJoinViewController ()

@property(nonatomic, strong) FHMyJoinViewModel *viewModel;
@property(nonatomic, assign) FHUGCMyJoinType type;
@property(nonatomic, strong) UIView *currentView;

@end

@implementation FHMyJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addEnterCategoryLog];
    [self loadVC];
}

- (void)loadVC {
    BOOL hasSocialGroups = [FHUGCConfig sharedInstance].followList.count > 0;
    if(hasSocialGroups){
        [self initFeedListVC];
        [self.feedListVC viewWillAppear];
        [self loadData];
    }else{
        [self initMyInterestListVC];
    }
}

- (void)viewWillAppear {
    [self loadVC];
}

- (void)viewWillDisappear {
    [self addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//
//    BOOL hasSocialGroups = [FHUGCConfig sharedInstance].followList.count > 0;
//
//    if(hasSocialGroups){
//        [self initFeedListVC];
//        [self.feedListVC viewWillAppear];
//        [self loadData];
//    }else{
//        [self initMyInterestListVC];
//    }
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//
//    [self addStayCategoryLog:self.ttTrackStayTime];
//    [self tt_resetStayTime];
//}

- (void)initFeedListVC {
    if(self.type == FHUGCMyJoinTypeFeed){
        //考虑是否需要刷新数据
        return;
    }
    
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
    TRACK_EVENT(@"enter_category", tracerDict);
}

- (void)addStayCategoryLog:(NSTimeInterval)stayTime {
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName];
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_category", tracerDict);
}

- (NSString *)categoryName {
    return @"my_join_list";
}

@end
