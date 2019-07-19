//
// Created by zhulijun on 2019-07-17.
//

#import "FHUGCCommunityListViewController.h"
#import "FHCommunityList.h"
#import "UIViewController+Track.h"
#import "FHUGCCommunityListSearchBar.h"
#import "FHUGCCommunityDistrictTabView.h"
#import "FHUGCCommunityListViewModel.h"
#import "FHUGCScialGroupModel.h"

@interface FHUGCCommunityListViewController ()
@property(nonatomic, strong) UIView *loadingView;
@property(nonatomic, strong) FHUGCCommunityCategoryView *categoryView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UILabel *districtListTitleLabel;
@property(nonatomic, strong) FHUGCCommunityListSearchBar *searchBar;
@property(nonatomic, strong) FHUGCCommunityListViewModel *viewModel;

@property(nonatomic, assign) FHCommunityListType listType;
@property(nonatomic, weak) id <FHUGCCommunityChooseDelegate> chooseDelegate;
@end

@implementation FHUGCCommunityListViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.ttTrackStayEnable = YES;
        self.listType = FHCommunityListTypeFollow;
        if (paramObj.allParams[@"action_type"]) {
            self.listType = [paramObj.allParams[@"action_type"] integerValue];
        }
        self.defaultSelectDistrictTab = FHUGCCommunityDistrictTabIdRecommend;
        if (paramObj.allParams[@"select_district_tab"]) {
            self.defaultSelectDistrictTab = [paramObj.allParams[@"select_district_tab"] integerValue];
        }
        self.title = @"全部小区圈";
        if (paramObj.allParams[@"title"]) {
            self.title = paramObj.allParams[@"title"];
        }
        NSHashTable <FHUGCCommunityChooseDelegate> *choose_delegate = paramObj.allParams[@"choose_delegate"];
        self.chooseDelegate = choose_delegate.anyObject;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self initNavBar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)initNavBar {
    [self setupDefaultNavBar:NO];
    [self.customNavBarView cleanStyle:YES];
    self.customNavBarView.title.text = self.title;
}

- (void)initView {
    self.searchBar.backgroundColor = [UIColor themeWhite];
    self.searchBar.searchTint = @"搜索小区圈";
    WeakSelf;
    self.searchBar.searchClickBlk = ^() {
        NSString *routeUrl = @"sslocal://ugc_search_list";
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
        NSHashTable *chooseDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [chooseDelegateTable addObject:self.chooseDelegate];
        paramDic[@"choose_delegate"] = chooseDelegateTable;
        paramDic[@"action_type"] = @(self.listType);
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:paramDic];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    };

    self.categoryView.backgroundColor = [UIColor themeWhite];
    self.tableView.backgroundColor = [UIColor themeWhite];
}

- (void)initConstraints {
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(46);
    }];

    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchBar.mas_bottom);
        make.width.mas_equalTo(94);
    }];

    [self.districtListTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.categoryView.mas_right).offset(10);
        make.top.mas_equalTo(self.searchBar.mas_bottom);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self.view);
        make.left.mas_equalTo(self.categoryView.mas_right);
        make.top.mas_equalTo(self.districtListTitleLabel.mas_bottom);
    }];

    [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
    }];

    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHUGCCommunityListViewModel alloc]
            initWithTableView:self.tableView
                 categoryView:self.categoryView
           districtTitleLabel:self.districtListTitleLabel
                   controller:self
                     listType:self.listType];
}

- (void)retryLoadData {
    [self.viewModel retryLoadData];
}

- (void)onItemSelected:(FHUGCScialGroupDataModel *)item indexPath:(NSIndexPath *)indexPath {
    if (self.chooseDelegate) {
        [self.chooseDelegate selectedItem:item];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.viewModel viewDidAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.viewModel viewDidDisappear];
}

- (void)startLoading {
    self.loadingView.hidden = NO;
    [self.loadingView performSelector:@selector(startLoadingAnimation)];
}

- (void)endLoading {
    self.loadingView.hidden = YES;
    [self.loadingView performSelector:@selector(stopLoadingAnimation)];
}

#pragma getter

- (UILabel *)districtListTitleLabel {
    if (!_districtListTitleLabel) {
        _districtListTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _districtListTitleLabel.font = [UIFont themeFontRegular:14];
        _districtListTitleLabel.textColor = [UIColor themeGray3];
        _districtListTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_districtListTitleLabel];
    }
    return _districtListTitleLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionFooterHeight = 0;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (FHUGCCommunityCategoryView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[FHUGCCommunityCategoryView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_categoryView];
    }
    return _categoryView;
}

- (FHUGCCommunityListSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[FHUGCCommunityListSearchBar alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_searchBar];
    }
    return _searchBar;
}


- (FHErrorView *)errorView {
    if (!_errorView) {
        _errorView = [[FHErrorView alloc] init];
        _errorView.hidden = YES;
        [self.view addSubview:_errorView];
        __weak typeof(self) wself = self;
        _errorView.retryBlock = ^{
            [wself retryLoadData];
        };
    }
    return _errorView;
}

- (UIView *)loadingView {
    if (!_loadingView) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TTUIWidgetResources" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSArray *nibViews = [bundle loadNibNamed:@"TTFullScreenLoadingView" owner:nil options:nil];
        _loadingView = nibViews.firstObject;
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _loadingView.userInteractionEnabled = NO;
        _loadingView.hidden = YES;
        [self.view addSubview:_loadingView];
    }
    return _loadingView;
}

@end
