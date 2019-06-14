//
//  FHMyJoinViewController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHMyJoinViewController.h"
#import "FHMyJoinViewModel.h"
#import "FHUGCMyInterestedController.h"

@interface FHMyJoinViewController ()

@property(nonatomic, strong) FHMyJoinViewModel *viewModel;
@property(nonatomic, strong) UIView *currentView;

@end

@implementation FHMyJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initViewModel];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];

    //根据用户是否已加入小区显示不同的页面
    if(1){
        [self initFeedListVC];
    }else{
        [self initMyInterestListVC];
    }
    
}

- (void)initFeedListVC {
    if(_currentView){
        [_currentView removeFromSuperview];
        _currentView = nil;
    }
    
    FHCommunityFeedListController *vc =[[FHCommunityFeedListController alloc] init];
    vc.listType = FHCommunityFeedListTypeMyJoin;
    self.neighbourhoodView = [[FHMyJoinNeighbourhoodView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    vc.tableHeaderView = self.neighbourhoodView;
    
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    _currentView = vc.view;
    _feedListVC = vc;
}

- (void)initMyInterestListVC {
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
}

- (void)initViewModel {
    FHMyJoinViewModel *viewModel = [[FHMyJoinViewModel alloc] initWithCollectionView:self.neighbourhoodView.collectionView controller:self];
    self.neighbourhoodView.delegate = viewModel;
    self.viewModel = viewModel;
    [self startLoadData];
}

- (void)startLoadData {
    [self.viewModel requestData];
}

@end
