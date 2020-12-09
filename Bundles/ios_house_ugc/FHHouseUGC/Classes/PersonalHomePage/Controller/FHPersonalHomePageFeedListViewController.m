//
//  FHPersonalHomePageFeedListViewController.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import "FHPersonalHomePageFeedListViewController.h"
#import "FHPersonalHomePageManager.h"
#import "FHPersonalHomePageFeedListViewModel.h"
#import "TTReachability.h"

@interface FHPersonalHomePageFeedListViewController ()
@property(nonatomic,strong) FHPersonalHomePageFeedListViewModel *viewModel;
@end

@implementation FHPersonalHomePageFeedListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initViewModel];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startLoadData];
}

- (void)initView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:self.tableView];
    
    [self addDefaultEmptyViewFullScreen];
}

- (void)initViewModel {
    self.viewModel = [[FHPersonalHomePageFeedListViewModel alloc] initWithController:self tableView:self.tableView];
}

- (void)startLoadData {
    [self.viewModel requestData:YES first:YES];
}

-(void)retryLoadData {
    [self.emptyView hideEmptyView];
    [self startLoadData];
}

- (NSString *)categoryName {
    return @"f_user_profile";
}

@end
