//
//  FHPersonalHomePageFeedListViewController.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import "FHPersonalHomePageFeedListViewController.h"
#import "FHPersonalHomePageFeedListViewModel.h"

@interface FHPersonalHomePageFeedListViewController ()
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) FHPersonalHomePageFeedListViewModel *viewModel;
@end

@implementation FHPersonalHomePageFeedListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initViewModel];
}

- (void)initView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.bounces = YES;
    [self.view addSubview:self.tableView];
}

- (void)initViewModel {
    self.viewModel = [[FHPersonalHomePageFeedListViewModel alloc] initWithController:self tableView:self.tableView];
}

@end
