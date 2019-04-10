//
//  FHPriceValuationNeiborhoodSearchController.m
//  FHHouseTrend
//
//  Created by 张元科 on 2019/3/26.
//

#import "FHPriceValuationNeiborhoodSearchController.h"
#import "FHSuggestionListNavBar.h"
#import "TTDeviceHelper.h"
#import "FHHouseType.h"
#import "FHHouseTypeManager.h"
#import "FHPopupMenuView.h"
#import "FHSuggestionListViewModel.h"
#import "FHEnvContext.h"
#import "ToastManager.h"
#import "TTNavigationController.h"
#import "FHPriceValuationNeiborhoodSearchViewModel.h"
#import "FHPriceValuationNSearchView.h"
#import "FHFakeInputNavbar.h"
#import "FHPriceValuationNSCell.h"
#import "TTReachability.h"

@interface FHPriceValuationNeiborhoodSearchController ()<UITextFieldDelegate>

@property (nonatomic, strong)   FHPriceValuationNSearchView       *searchView;
@property (nonatomic, strong)   FHPriceValuationNeiborhoodSearchViewModel      *viewModel;
@property (nonatomic, weak)     id<FHHouseBaseDataProtocel>    delegate;

@end

@implementation FHPriceValuationNeiborhoodSearchController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSHashTable<FHHouseSuggestionDelegate> *temp_delegate = paramObj.allParams[@"delegate"];
        self.delegate = temp_delegate.anyObject;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor themeGray7];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    __weak typeof(self) weakSelf = self;
    self.panBeginAction = ^{
        [weakSelf.searchView.searchInput resignFirstResponder];
    };
    // 初始化
    if (![TTReachability isNetworkConnected]) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
        self.suggestTableView.hidden = YES;
    } else {
        self.suggestTableView.hidden = YES;
        self.emptyView.hidden = YES;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.searchView.searchInput becomeFirstResponder];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchView.searchInput resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.searchView.searchInput resignFirstResponder];
}

- (void)setupUI {
    self.viewModel = [[FHPriceValuationNeiborhoodSearchViewModel alloc] initWithController:self];
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self setupNaviBar];
    [self setupTableView];
    self.emptyView.hidden = NO;
}

- (void)setupNaviBar {
    [self setupDefaultNavBar:YES];
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    
    self.searchView = [[FHPriceValuationNSearchView alloc] init];
    [self.view addSubview:self.searchView];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(height);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(64);
    }];
    
    self.searchView.searchInput.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledTextChangeNoti:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setupTableView {
    self.suggestTableView  = [self createTableView];
    self.suggestTableView.hidden = YES;
}

- (FHSuggectionTableView *)createTableView {
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    FHSuggectionTableView *tableView = [[FHSuggectionTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
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
        make.top.mas_equalTo(self.searchView.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    tableView.delegate  = self.viewModel;
    tableView.dataSource = self.viewModel;
    [tableView registerClass:[FHPriceValuationNSCell class] forCellReuseIdentifier:@"FHPriceValuationNSCell"];
    if (@available(iOS 11.0 , *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.estimatedRowHeight = 50;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    
    return tableView;
}

// 文本框文字变化，进行sug请求
- (void)textFiledTextChangeNoti:(NSNotification *)noti {
    NSInteger maxCount = 80;
    NSString *text = self.searchView.searchInput.text;
    if (text.length > maxCount) {
        text = [text substringToIndex:maxCount];
        self.searchView.searchInput.text = text;
    }
    BOOL hasText = text.length > 0;
    if (hasText) {
        [self requestSuggestion:text];
    } else {
        // 清空sug列表数据
        [self.viewModel clearSugTableView];
        self.emptyView.hidden = YES;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //
    return YES;
}

// 输入框执行搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *userInputText = self.searchView.searchInput.text;
    [textField resignFirstResponder];
    return YES;
}

// sug建议
- (void)requestSuggestion:(NSString *)text {
    NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    if (cityId) {
        // 小区搜索
        [self.viewModel requestSuggestion:cityId houseType:FHHouseTypeNeighborhood query:text];
    }
}

#pragma mark - dealloc

- (void)cellDidClick:(NSString *)text neigbordId:(NSString *)neigbordId {
    if (text.length > 0 && self.delegate && [self.delegate respondsToSelector:@selector(callBackDataInfo:)]) {
        NSDictionary *dicInfo = @{
                                  @"neighborhood_name":text,
                                  @"neighborhood_id":neigbordId,
                                  };
        [self.delegate callBackDataInfo:dicInfo];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
