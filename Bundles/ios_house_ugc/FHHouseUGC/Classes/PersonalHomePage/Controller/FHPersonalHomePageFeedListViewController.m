//
//  FHPersonalHomePageFeedListViewController.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import "FHPersonalHomePageFeedListViewController.h"
#import "FHPersonalHomePageManager.h"
#import "FHPersonalHomePageFeedListViewModel.h"
#import "UIDevice+BTDAdditions.h"
#import "TTReachability.h"

@interface FHPersonalHomePageFeedListViewController ()
@property(nonatomic,strong) FHPersonalHomePageFeedListViewModel *viewModel;
@property(nonatomic,assign) BOOL isFirstLoad;
@end

@implementation FHPersonalHomePageFeedListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    [self initViewModel];
    self.isFirstLoad = YES;
}

- (void)initView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.backgroundColor = [UIColor themeGray7];
    self.tableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    
    if ([UIDevice btd_isIPhoneXSeries]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    [self.view addSubview:self.tableView];
}

- (void)initViewModel {
    self.viewModel = [[FHPersonalHomePageFeedListViewModel alloc] initWithController:self tableView:self.tableView];
    self.viewModel.homePageManager = self.homePageManager;
}

- (void)setHomePageManager:(FHPersonalHomePageManager *)homePageManager {
    _homePageManager = homePageManager;
    _viewModel.homePageManager = homePageManager;
}


-(void)firstLoadData {
    if(self.isFirstLoad) {
        self.isFirstLoad = NO;
        [self startLoadData];
    }
}

- (void)startLoadData {
    [self.viewModel requestData:YES first:YES];
}

-(void)retryLoadData {
    [self.viewModel.emptyView hideEmptyView];
    [self startLoadData];
}

- (NSString *)categoryName {
    return @"f_user_profile";
}

@end
