//
//  FHCitySearchViewController.m
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import "FHCitySearchViewController.h"
#import "TTDeviceHelper.h"
#import "FHHouseType.h"
#import "FHHouseTypeManager.h"
#import "FHPopupMenuView.h"
#import "FHEnvContext.h"
#import "ToastManager.h"
#import "FHCitySearchNavBarView.h"
#import "TTNavigationController.h"
#import "FHCitySearchViewModel.h"
#import "FHCitySearchItemCell.h"

@interface FHCitySearchViewController ()

@property (nonatomic, strong)   FHCitySearchViewModel      *viewModel;

@end

@implementation FHCitySearchViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _viewModel = [[FHCitySearchViewModel alloc] initWithController:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    __weak typeof(self) weakSelf = self;
    self.panBeginAction = ^{
        [weakSelf.naviBar.searchInput resignFirstResponder];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.naviBar resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.naviBar.searchInput resignFirstResponder];
}

- (void)setupUI {
    [self setupNaviBar];
    self.tableView = [self createTableView];
}

- (void)setupNaviBar {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    _naviBar = [[FHCitySearchNavBarView alloc] init];
    [self.view addSubview:_naviBar];
    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20);
    [_naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(naviHeight);
    }];
    [_naviBar.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    _naviBar.searchInput.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledTextChangeNoti:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (FHCitySearchTableView *)createTableView {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    FHCitySearchTableView *tableView = [[FHCitySearchTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    __weak typeof(self) weakSelf = self;
    tableView.handleTouch = ^{
        [weakSelf.view endEditing:YES];
    };
    tableView.backgroundColor = UIColor.whiteColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (isIphoneX) {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.naviBar.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    tableView.delegate  = self.viewModel;
    tableView.dataSource = self.viewModel;
    [tableView registerClass:[FHCitySearchItemCell class] forCellReuseIdentifier:@"fh_city_search_cell"];
    if (@available(iOS 11.0 , *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    
    return tableView;
}

// 文本框文字变化，进行sug请求
- (void)textFiledTextChangeNoti:(NSNotification *)noti {
    NSInteger maxCount = 80;
    NSString *text = self.naviBar.searchInput.text;
    if (text.length > maxCount) {
        text = [text substringToIndex:maxCount];
        self.naviBar.searchInput.text = text;
    }
    BOOL hasText = text.length > 0;
    if (hasText) {
        [self.viewModel requestSearchCityByQuery:text];
    } else {
        [self.viewModel clearTableView];
    }
}

@end
