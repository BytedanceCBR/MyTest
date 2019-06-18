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

@interface FHMyJoinViewController ()

@property(nonatomic, strong) FHMyJoinViewModel *viewModel;
@property(nonatomic, assign) FHUGCMyJoinType type;
@property(nonatomic, strong) UIView *currentView;
@property(nonatomic, assign) BOOL isEmpty;

@end

@implementation FHMyJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self initView];
//    [self initViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(!_isEmpty){
        [self initFeedListVC];
        [self.feedListVC viewWillAppear];
        [self startLoadData];
    }else{
        [self initMyInterestListVC];
    }
    
    
//    _isEmpty = !_isEmpty;
}

//- (void)initView {
//
//    //根据用户是否已加入小区显示不同的页面
//    if(1){
//        [self initFeedListVC];
//    }else{
//        [self initMyInterestListVC];
//    }
//
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
    vc.tableHeaderView = self.neighbourhoodView;
    
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
    _feedListVC = vc;
    
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

- (void)startLoadData {
    [self.viewModel requestData];
}

@end
