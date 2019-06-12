//
//  FHMyJoinViewController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHMyJoinViewController.h"
#import "FHCommunityFeedListController.h"
#import "FHMyJoinViewModel.h"
#import "FHMyJoinNeighbourhoodView.h"

@interface FHMyJoinViewController ()

@property(nonatomic, strong) FHMyJoinNeighbourhoodView *neighbourhoodView;
@property(nonatomic, strong) FHMyJoinViewModel *viewModel;

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
    
    FHCommunityFeedListController *vc =[[FHCommunityFeedListController alloc] init];
    vc.listType = FHCommunityFeedListTypeMyJoin;
    
    self.neighbourhoodView = [[FHMyJoinNeighbourhoodView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    vc.tableHeaderView = self.neighbourhoodView;
    
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

- (void)initViewModel {
    FHMyJoinViewModel *viewModel = [[FHMyJoinViewModel alloc] initWithCollectionView:self.neighbourhoodView.collectionView controller:self];
    self.viewModel = viewModel;
    [self startLoadData];
}

- (void)startLoadData {
    [self.viewModel requestData];
}

@end
