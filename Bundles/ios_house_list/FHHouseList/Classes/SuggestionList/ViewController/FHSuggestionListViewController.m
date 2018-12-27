//
//  FHSuggestionListViewController.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewController.h"
#import "FHSuggestionListNavBar.h"
#import "TTDeviceHelper.h"
#import "FHHouseType.h"
#import "FHHouseTypeManager.h"
#import "FHPopupMenuView.h"
#import "FHSuggestionListViewModel.h"
#import "FHEnvContext.h"
#import "ToastManager.h"

@interface FHSuggestionListViewController ()<UITextFieldDelegate>

@property (nonatomic, assign)     FHHouseType       houseType;
@property (nonatomic, weak)     FHPopupMenuView       *popupMenuView;
@property (nonatomic, strong)   FHSuggestionListViewModel      *viewModel;

@property (nonatomic, assign)   FHEnterSuggestionType       fromSource;

@property (nonatomic, weak)     id<FHHouseSuggestionDelegate>    suggestDelegate;

@property (nonatomic, strong)   NSDictionary       *homePageRollDic;
@property (nonatomic, assign)   BOOL       canSearchWithRollData; // 如果为YES，支持placeholder搜索

@end

@implementation FHSuggestionListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 1、from_home
        self.fromSource = [paramObj.userInfo.allInfo[@"from_home"] integerValue];
        // 2、house_type
        _houseType = 0; // 特殊值，为了第一次setHouseType的时候执行相关功能
        _viewModel = [[FHSuggestionListViewModel alloc] initWithController:self];
        _viewModel.houseType = [paramObj.userInfo.allInfo[@"house_type"] integerValue];
        _viewModel.fromPageType = self.fromSource;
        // 3、sug_delegate 代理
        /*
         NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
         [sugDelegateTable addObject:self];
         @"sug_delegate":sugDelegateTable
         */
        NSHashTable<FHHouseSuggestionDelegate> *sug_delegate = paramObj.userInfo.allInfo[@"sug_delegate"];
        self.suggestDelegate = sug_delegate.anyObject;
        // 4、homepage_roll_data 首页轮播词
        /*homepage_roll_data:{
         "text":"",
         "guess_search_id":"",
         "house_type":2,
         "open_url":""
         }
         */
        id dic = paramObj.userInfo.allInfo[@"homepage_roll_data"];
        if (dic) {
            self.homePageRollDic = [NSDictionary dictionaryWithDictionary:dic];
            self.viewModel.homePageRollDic = self.homePageRollDic;
        }
        // 5、tracer（TRACER_KEY）: self.tracerDict 字典
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.canSearchWithRollData = NO;
    [self setupUI];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.houseType = self.viewModel.houseType;// 执行网络请求等逻辑
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.homePageRollDic) {
        NSString *text = self.homePageRollDic[@"text"];
        if (text.length > 0) {
            [self.naviBar setSearchPlaceHolderText:text];
            self.canSearchWithRollData = YES;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.naviBar resignFirstResponder];
}

- (void)setupUI {
    [self setupNaviBar];
    [self setupTableView];
}

- (void)setupNaviBar {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    _naviBar = [[FHSuggestionListNavBar alloc] init];
    [self.view addSubview:_naviBar];
    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20);
    [_naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(naviHeight);
    }];
    [_naviBar.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_naviBar setSearchPlaceHolderText:[[FHHouseTypeManager sharedInstance] searchBarPlaceholderForType:self.houseType]];
    _naviBar.searchTypeLabel.text = [[FHHouseTypeManager sharedInstance] stringValueForType:self.houseType];
    CGSize size = [self.naviBar.searchTypeLabel sizeThatFits:CGSizeMake(100, 20)];
    [self.naviBar.searchTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
    [_naviBar.searchTypeBtn addTarget:self action:@selector(searchTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _naviBar.searchInput.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledTextChangeNoti:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setupTableView {
    self.historyTableView  = [self createTableView];
    self.historyTableView.tag = 1;
    self.historyTableView.hidden = NO;
    
    self.suggestTableView  = [self createTableView];
    self.suggestTableView.tag = 2;
    self.suggestTableView.hidden = YES;
}

- (FHSuggectionTableView *)createTableView {
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
        make.top.mas_equalTo(self.naviBar.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    tableView.delegate  = self.viewModel;
    tableView.dataSource = self.viewModel;
    [tableView registerClass:[FHSuggestionItemCell class] forCellReuseIdentifier:@"suggestItemCell"];
    [tableView registerClass:[FHSuggestionNewHouseItemCell class] forCellReuseIdentifier:@"suggestNewItemCell"];
    [tableView registerClass:[FHSuggestHeaderViewCell class] forCellReuseIdentifier:@"suggestHeaderCell"];
    if (@available(iOS 11.0 , *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    
    return tableView;
}

- (void)setHouseType:(FHHouseType)houseType {
    if (_houseType == houseType) {
        return;
    }
    if (self.canSearchWithRollData) {
        self.canSearchWithRollData = NO;
    }
    _houseType = houseType;
    [_naviBar setSearchPlaceHolderText:[[FHHouseTypeManager sharedInstance] searchBarPlaceholderForType:houseType]];
    _naviBar.searchTypeLabel.text = [[FHHouseTypeManager sharedInstance] stringValueForType:houseType];
    CGSize size = [self.naviBar.searchTypeLabel sizeThatFits:CGSizeMake(100, 21)];
    [self.naviBar.searchTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
    self.viewModel.houseType = self.houseType;
    // 清空埋点key
    [self.viewModel.historyShowTracerDic removeAllObjects];
    // 网络请求
    [self requestData];
}

- (void)searchTypeBtnClick:(UIButton *)btn {
    NSArray *items = @[@(FHHouseTypeSecondHandHouse),
                       @(FHHouseTypeRentHouse),
                       @(FHHouseTypeNewHouse),
                       @(FHHouseTypeNeighborhood),];
    FHConfigDataModel *model = [[FHEnvContext sharedInstance] getConfigFromCache];
    //TODO: add by zyk configCcache中数据获取
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    [items enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHHouseType houseType = [obj integerValue];
        FHPopupMenuItem *item = [self getPopupItemBy:houseType];
        [menuItems addObject:item];
    }];
    
    FHPopupMenuView *popup = [[FHPopupMenuView alloc] initWithTargetView:self.naviBar.searchTypeBtn menus:menuItems];
    [self.view addSubview:popup];
    self.popupMenuView = popup;
    [popup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.mas_equalTo(self.view);
    }];
    [self.popupMenuView showOnTargetView];
    
}
- (FHPopupMenuItem *)getPopupItemBy:(FHHouseType)ht {
    FHPopupMenuItem *item = [[FHPopupMenuItem alloc] initWithHouseType:ht isSelected:self.houseType == ht];
    __weak typeof(self) weakSelf = self;
    item.itemClickBlock = ^(FHHouseType houseType) {
        weakSelf.houseType = houseType;
        [weakSelf.popupMenuView removeFromSuperview];
    };
    return item;
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
    _suggestTableView.hidden = !hasText;
    _historyTableView.hidden = hasText;
    if (hasText) {
        [self requestSuggestion:text];
    } else {
        // 清空sug列表数据
        [self.viewModel clearSugTableView];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (self.popupMenuView) {
        [self.popupMenuView removeFromSuperview];
    }
    return YES;
}

// 输入框执行搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *userInputText = self.naviBar.searchInput.text;
    
    // 如果外部传入搜索文本homePageRollData，直接当搜索内容进行搜索
    NSString *rollText = self.homePageRollDic[@"text"];
    if (self.canSearchWithRollData) {
        if (userInputText.length <= 0 && rollText.length > 0) {
            userInputText = rollText;
        }
    }
    // 保存关键词搜索到历史记录
    /*
    NSString *tempStr = [userInputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (tempStr.length > 0) {
    }
     */
    
    NSString *pageType = [self.viewModel pageTypeString];
    NSDictionary *houseSearchParams = @{
                                        @"enter_query":userInputText,
                                        @"search_query":userInputText,
                                        @"page_type":pageType.length > 0 ? pageType : @"be_null",
                                        @"query_type":@"enter"
                                        };
    // 拼接URL
    NSString * fullText = [userInputText stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString * placeHolderStr = (fullText.length > 0 ? fullText : userInputText);
    
    NSString *openUrl = [NSString stringWithFormat:@"fschema://house_list?house_type=%ld&full_text=%@&placeholder=%@",self.houseType,placeHolderStr,placeHolderStr];
    if (self.suggestDelegate != NULL) {
        NSDictionary *infos = @{
                                @"houseSearch":houseSearchParams
                                };
        [self jumpToCategoryListVCByUrl:openUrl queryText:placeHolderStr placeholder:placeHolderStr infoDict:infos];
    } else {
        self.tracerDict[@"category_name"] = [self.viewModel categoryNameByHouseType];
        NSDictionary *infos = @{@"houseSearch":houseSearchParams,
                               @"tracer": self.tracerDict
                               };
        [self jumpToCategoryListVCByUrl:openUrl queryText:placeHolderStr placeholder:placeHolderStr infoDict:infos];
    }
    return YES;
}

- (void)jumpToCategoryListVCByUrl:(NSString *)jumpUrl queryText:(NSString *)queryText placeholder:(NSString *)placeholder infoDict:(NSDictionary *)infos {
    NSString *openUrl = jumpUrl;
    if (openUrl.length <= 0) {
        openUrl = [NSString stringWithFormat:@"fschema://house_list?house_type=%ld&full_text=%@&placeholder=%@",self.houseType,queryText,placeholder];
    }
    if (self.suggestDelegate != NULL) {
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
        // 回传数据，外部pop 页面
        TTRouteObject *obj = [[TTRoute sharedRoute] routeObjWithOpenURL:[NSURL URLWithString:openUrl] userInfo:userInfo];
        if ([self.suggestDelegate respondsToSelector:@selector(suggestionSelected:)]) {
            [self.suggestDelegate suggestionSelected:obj];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        // 拿到所需参数，跳转
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
        
        NSURL *url = [NSURL URLWithString:openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
    [self dismissSelfVCIfNeeded];
}

// 如果从home和找房tab叫起，则当用户跳转到列表页，则后台关闭此页面
- (void)dismissSelfVCIfNeeded {
    if (self.fromSource == FHEnterSuggestionTypeHome || self.fromSource == FHEnterSuggestionTypeFindTab) {
        [self removeFromParentViewController];
    }
}

#pragma mark - Request

// 执行网络请求
- (void)requestData {
    // Sug
    NSString *text = self.naviBar.searchInput.text;
    if (text.length > 0) {
         [self requestSuggestion:text];
    }
    // 历史记录 + 猜你想搜
    [self.viewModel clearHistoryTableView];
    self.viewModel.loadRequestTimes = 0;
    [self requestHistoryFromRemote];
    [self requestGuessYouWantData];
}

// 历史记录
- (void)requestHistoryFromRemote {
    if (![FHEnvContext isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        // TODO:add by zyk 有loadRequestTimes 自动加的逻辑需要处理吗？
    } else {
        [self.viewModel requestSearchHistoryByHouseType:[NSString stringWithFormat:@"%ld",_houseType]];
    }
}

// 删除历史记录
- (void)requestDeleteHistory {
    if (![FHEnvContext isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
    } else {
        [self.viewModel requestDeleteHistoryByHouseType:[NSString stringWithFormat:@"%ld",_houseType]];
    }
}

// 猜你想搜
- (void)requestGuessYouWantData {
    NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    [self.viewModel requestGuessYouWant:cityId houseType:self.houseType];
}

// sug建议
- (void)requestSuggestion:(NSString *)text {
    NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    [self.viewModel requestSuggestion:cityId houseType:self.houseType query:text];
}

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
