//
//  FHChildSuggestionListViewController.m
//  FHHouseList
//
//  Created by xubinbin on 2020/4/16.
//

#import "FHChildSuggestionListViewController.h"
#import "TTDeviceHelper.h"
#import "FHHouseType.h"
#import "FHHouseTypeManager.h"
#import "FHPopupMenuView.h"
#import "FHChildSuggestionListViewModel.h"
#import "FHEnvContext.h"
#import "ToastManager.h"
#import "TTNavigationController.h"
#import "FHSugSubscribeListViewController.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import "FHOldSuggestionItemCell.h"
#import "FHSuggestionEmptyCell.h"
#import "FHFindHouseHelperCell.h"
#import "FHHouseListRecommendTipCell.h"
#import "UIDevice+BTDAdditions.h"
#import "TTSettingsManager.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHMonitor.h"

@interface FHChildSuggestionListViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)   FHChildSuggestionListViewModel      *viewModel;

@property (nonatomic, assign)   FHEnterSuggestionType       fromSource;

@property (nonatomic, weak)     id<FHHouseSuggestionDelegate>    suggestDelegate;
@property (nonatomic, weak)     UIViewController   *backListVC; // 需要返回到的页面

@property (nonatomic, strong)   NSMutableDictionary       *homePageRollDic;// 传入搜索列表的轮播词-只用于搜索框展示和搜索用
@property (nonatomic, assign)   BOOL       hasDismissedVC;

@property (nonatomic, assign)   BOOL isShowHistory;
@property (nonatomic, copy)     NSString *textFieldText;

@property (nonatomic, copy)     NSString *lastSearchWord;

@property (nonatomic, assign)   NSInteger defaultHouseType;

@end

@implementation FHChildSuggestionListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _isCanTrack = NO;
        _isShowHistory = NO;
        _textFieldText = @"";
        // 1、from_home(native参数)
        if (paramObj.allParams[@"from_home"]) {
            self.fromSource = [paramObj.allParams[@"from_home"] integerValue];
        } else {
            self.fromSource = FHEnterSuggestionTypeDefault; // h5 不需要此参数，但是需要其他一些参数：origin_from enter_from element_from house_type page_type
        }
        // 2、house_type
        _houseType = 0; // 特殊值，为了第一次setHouseType的时候执行相关功能
        _viewModel = [[FHChildSuggestionListViewModel alloc] initWithController:self];
        NSInteger hp = [paramObj.allParams[@"house_type"] integerValue];
        if (hp >= 1 && hp <= 4) {
            _viewModel.houseType = hp;
        } else {
            _viewModel.houseType = 2;// 默认二手房
        }
        _viewModel.fromPageType = self.fromSource;
        
        _defaultHouseType = _viewModel.houseType;
        
        // 3、sug_delegate 代理
        /*
         NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
         [sugDelegateTable addObject:self];
         @"sug_delegate":sugDelegateTable
         */
        NSHashTable<FHHouseSuggestionDelegate> *sug_delegate = paramObj.allParams[@"sug_delegate"];
        self.suggestDelegate = sug_delegate.anyObject;
        NSHashTable *back_vc = paramObj.allParams[@"need_back_vc"]; // pop方式返回某个页面
        self.backListVC = back_vc.anyObject;  // 需要返回到的某个列表页面
        // 4、homepage_roll_data 首页轮播词
        /*homepage_roll_data:{
         "text":"",
         "guess_search_id":"",
         "house_type":2,
         "open_url":""
         }
         */
        id dic = paramObj.allParams[@"homepage_roll_data"];
        if (dic) {
            self.homePageRollDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            self.viewModel.homePageRollDic = self.homePageRollDic;
        }
        // 5、tracer（TRACER_KEY）: self.tracerDict 字典
        // 6、H5页面传入的其他字段 3.18号上 H5放到report_params
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithDictionary:paramObj.allParams];
        NSString *report_params = paramObj.allParams[@"report_params"];
        if ([report_params isKindOfClass:[NSString class]]) {
            NSDictionary *report_params_dic = [self getDictionaryFromJSONString:report_params];
            if (report_params_dic) {
                [paramDic addEntriesFromDictionary:report_params_dic];
            }
        }
        if (paramDic[@"page_type"]) {
            self.viewModel.pageTypeStr = paramDic[@"page_type"];
        }
        //
        if (paramDic[@"origin_from"]) {
            NSString *origin_from = paramDic[@"origin_from"];
            self.tracerDict[@"origin_from"] = origin_from;
        }
        if (paramDic[@"enter_from"]) {
            NSString *enter_from = paramDic[@"enter_from"];
            self.tracerDict[@"enter_from"] = enter_from;
        }
        if (paramDic[@"element_from"]) {
            NSString *element_from = paramDic[@"element_from"];
            self.tracerDict[@"element_from"] = element_from;
        }
        if (paramDic[@"origin_search_id"]) {
            NSString *origin_search_id = paramDic[@"origin_search_id"];
            self.tracerDict[@"origin_search_id"] = origin_search_id;
        }
        // 7、hint_text：text guess_search_id house_type
        NSString *hint_text = paramDic[@"hint_text"];
        NSString *guess_search_id = paramDic[@"guess_search_id"];
        if (!self.homePageRollDic) {
            self.homePageRollDic = [NSMutableDictionary new];
        }
        if (hint_text.length > 0) {
            self.homePageRollDic[@"text"] = hint_text;
        }
        if (guess_search_id.length > 0) {
            self.homePageRollDic[@"guess_search_id"] = guess_search_id;
        }
        if (self.homePageRollDic.count > 0) {
            self.homePageRollDic[@"house_type"] = @(self.viewModel.houseType);
            self.viewModel.homePageRollDic = self.homePageRollDic;
        }
        //自动填充，并初始请求
    }
    return self;
}

- (NSDictionary *)getDictionaryFromJSONString:(NSString *)jsonString {
    NSMutableDictionary *retDic = nil;
    if (jsonString.length > 0) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        retDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if ([retDic isKindOfClass:[NSDictionary class]] && error == nil) {
            return retDic;
        } else {
            return nil;
        }
    }
    return retDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hasDismissedVC = NO;
    [self setupUI];
    [self addDefaultEmptyViewFullScreen];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shrinkKeyboard:)];
    [self.emptyView addGestureRecognizer:tap];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)shrinkKeyboard:(UITapGestureRecognizer *)tap {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)retryLoadData
{
    if (!self.isLoadingData) {
        [self requestData];
    }
}

- (void)setFatherVC:(FHSuggestionListViewController *)fatherVC
{
    _fatherVC = fatherVC;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.viewModel viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupUI {
    [self setupTableView];
}

- (void)setupTableView {
    self.historyTableView  = [self createTableView];
    self.historyTableView.tag = 1;
    self.historyTableView.hidden = NO;
    
    self.suggestTableView  = [self createTableView];
    self.suggestTableView.tag = 2;
    self.suggestTableView.hidden = YES;
}

- (void)setIsCanTrack:(BOOL)isCanTrack
{
    if (!_isShowHistory) {
        return;
    }
    _isCanTrack = isCanTrack;
    if (!self.historyIsSuccess) {
        [self requestData];
    }
//    if (isCanTrack && self.fatherVC.naviBar.searchInput.text.length == 0) {
//        [self.viewModel reloadHistoryTableView];
//    }
}

- (FHSuggectionTableView *)createTableView {
    BOOL isIphoneX = [UIDevice btd_isIPhoneXSeries];
    FHSuggectionTableView *tableView = [[FHSuggectionTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    __weak typeof(self) weakSelf = self;
    tableView.handleTouch = ^{
        [weakSelf.fatherVC.view endEditing:YES];
    };
    tableView.backgroundColor = UIColor.whiteColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (isIphoneX) {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view);
    }];
    tableView.delegate  = self.viewModel;
    tableView.dataSource = self.viewModel;
    [tableView registerClass:[FHSuggestionItemCell class] forCellReuseIdentifier:@"suggestItemCell"];
    [tableView registerClass:[FHSuggestionNewHouseItemCell class] forCellReuseIdentifier:@"suggestNewItemCell"];
    [tableView registerClass:[FHOldSuggestionItemCell class] forCellReuseIdentifier:@"FHOldSuggestionItemCell"];
    [tableView registerClass:[FHSuggestHeaderViewCell class] forCellReuseIdentifier:@"suggestHeaderCell"];
    [tableView registerClass:[FHGuessYouWantCell class] forCellReuseIdentifier:@"guessYouWantCell"];
    [tableView registerClass:[FHSuggestionEmptyCell class] forCellReuseIdentifier:@"suggetEmptyCell"];
    [tableView registerClass:[FHFindHouseHelperCell class] forCellReuseIdentifier:@"helperCell"];
    [tableView registerClass:[FHHouseListRecommendTipCell class] forCellReuseIdentifier:@"tipcell"];
    [tableView registerClass:[FHRecommendtHeaderViewCell class] forCellReuseIdentifier:@"RecommendtHeaderCell"];

    if (@available(iOS 11.0 , *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    return tableView;
}

- (void)setHouseType:(FHHouseType)houseType {
    if (_houseType == houseType) {
        return;
    }
    
    _houseType = houseType;
    self.viewModel.houseType = self.houseType;
    // 清空埋点key
    [self.viewModel.guessYouWantShowTracerDic removeAllObjects];
    // 网络请求
    [self requestData];
}

- (NSArray *)houseTypeSectionByConfig:(FHConfigDataModel *)config {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (config.searchTabFilter.count > 0) {
        [items addObject:@(FHHouseTypeSecondHandHouse)];
    }
    if (config.searchTabRentFilter.count > 0) {
        [items addObject:@(FHHouseTypeRentHouse)];
    }
    if (config.searchTabCourtFilter.count > 0) {
        [items addObject:@(FHHouseTypeNewHouse)];
    }
    if (config.searchTabNeighborhoodFilter.count > 0) {
        [items addObject:@(FHHouseTypeNeighborhood)];
    }
    return items;
}


- (void)textFiledTextChange:(NSString *)text andIsCanTrack:(BOOL)isCanTrack
{
    BOOL hasText = text.length > 0;
    _suggestTableView.hidden = !hasText;
    _historyTableView.hidden = hasText;
    if (hasText) {
        self.viewModel.isAssociatedCanTrack = NO;
        if (![text isEqualToString:_textFieldText] && isCanTrack) {
            self.viewModel.isAssociatedCanTrack = YES;
        }
        [self requestSuggestion:text];
    } else {
        // 清空sug列表数据
        _isShowHistory = YES;
        if (isCanTrack) {
            self.isCanTrack = isCanTrack;
        }
        [self.viewModel clearSugTableView];
        self.lastSearchWord = nil;
    }
    if (isCanTrack) {
        _textFieldText = text;
    }
}

- (void)textFieldWillClear {
    ///点击textField清空按钮时清空上次的sug词
    self.lastSearchWord = nil;
}

// 输入框执行搜索
- (void)doTextFieldShouldReturn:(NSString *)text {
    
    
    NSString *userInputText = text;
    
    // 如果外部传入搜索文本homePageRollData并且当前tab是默认tab，直接当搜索内容进行搜索
    if (userInputText.length == 0 && self.viewModel.houseType == self.defaultHouseType) {
        userInputText = [self.homePageRollDic btd_stringValueForKey:@"text"];
    }
    
    if (userInputText == nil) {
        userInputText = @"";
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
    __block NSInteger jumpHouseTpye = -1;
    WeakSelf;
    [self.fatherVC.houseTypeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongSelf;
        if(self.viewModel.jumpHouseType == [obj intValue]){
            jumpHouseTpye = self.viewModel.jumpHouseType ;
        }
    }];
    jumpHouseTpye = jumpHouseTpye != -1 ? jumpHouseTpye : self.houseType;
    NSString *openUrl = [NSString stringWithFormat:@"fschema://house_list?house_type=%zi&full_text=%@&placeholder=%@",jumpHouseTpye,placeHolderStr,placeHolderStr];
    if(jumpHouseTpye != self.houseType){
        self.tracerDict[@"element_from"] = [self.viewModel relatedRecommendelEmentFromNameByHouseType:self.houseType];
    }
    self.tracerDict[@"enter_type"] = @"enter";
    self.tracerDict[@"enter_from"] = @"search_detail";
    NSDictionary *infos = @{
        @"houseSearch":houseSearchParams,
        @"tracer": self.tracerDict,
        @"pre_house_type":@(self.houseType),
        @"jump_house_type":@(self.viewModel.jumpHouseType),
    };
    [self jumpToCategoryListVCByUrl:openUrl queryText:placeHolderStr placeholder:placeHolderStr infoDict:infos isGoDetail:NO];
}

- (void)jumpToCategoryListVCByUrl:(NSString *)jumpUrl queryText:(NSString * _Nullable)queryText placeholder:(NSString * _Nullable)placeholder infoDict:(NSDictionary *)infos isGoDetail:(BOOL)isGoDetail{
    NSString *openUrl = jumpUrl;
    if (openUrl.length <= 0) {
        openUrl = [NSString stringWithFormat:@"fschema://house_list?house_type=%zi&full_text=%@&placeholder=%@",self.houseType,queryText,placeholder];
    }
    if (self.suggestDelegate != NULL && ![openUrl containsString:@"webview"] && !isGoDetail) {
        // 1、suggestDelegate说明需要回传sug数据
        // 2、如果是从列表页和找房Tab列表页进入搜索，则还需pop到对应的列表页
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
        // 回传数据，外部pop 页面
        TTRouteObject *obj = [[TTRoute sharedRoute] routeObjWithOpenURL:[NSURL URLWithString:openUrl] userInfo:userInfo];
        if ([self.suggestDelegate respondsToSelector:@selector(suggestionSelected:)]) {
            [self.suggestDelegate suggestionSelected:obj];// 部分-内部有页面跳转逻辑
        }
        if (self.backListVC) {
            // FHEnterSuggestionTypeFindTab =   2,// 找房Tab列表页和  FHEnterSuggestionTypeList =   3, // 列表页
            [self.navigationController popToViewController:self.backListVC animated:YES];
        }
    } else {
        // 不需要回传sug数据，以及自己控制页面跳转和移除逻辑
        NSMutableDictionary *tempInfos = [NSMutableDictionary dictionaryWithDictionary:infos];
        // 跳转页面之后需要移除当前页面，如果从home和找房tab叫起，则当用户跳转到列表页，则后台关闭此页面
        if (self.fromSource == FHEnterSuggestionTypeFindTab || self.fromSource == FHEnterSuggestionTypeDefault || self.fromSource == FHEnterSuggestionTypeMapSearch) {
            UIViewController *topVC = self.navigationController.viewControllers.lastObject;
            if (![topVC isKindOfClass:[FHSugSubscribeListViewController class]]) {
                tempInfos[@"fh_needRemoveLastVC_key"] = @(YES);
                tempInfos[@"fh_needRemoveedVCNamesString_key"] = @[@"FHSuggestionListViewController",@"FHSugSubscribeListViewController"];
            }
        }
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:tempInfos];
        
        NSURL *url = [NSURL URLWithString:openUrl];
        
        if (!url) {
            NSMutableDictionary *paramsExtra = [NSMutableDictionary new];
            [paramsExtra setValue:@"跳转错误" forKey:@"desc"];
            [paramsExtra setValue:[BDTrackerProtocol deviceID] forKey:@"device_id"];
            [FHMonitor hmdTrackService:@"guess_you_want_error" status:1 extra:paramsExtra];
        }else
        {
            [FHMonitor hmdTrackService:@"guess_you_want_error" status:0 extra:nil];
        }
        
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

#pragma mark - Request

// 执行网络请求
- (void)requestData {
    NSString *text = @"";
    if (self.fatherVC) {
        text = self.fatherVC.naviBar.searchInput.text;
    }
    BOOL hasText = text.length > 0;
    
    if (hasText) {
        _suggestTableView.hidden = !hasText;
        _historyTableView.hidden = hasText;
         [self requestSuggestion:text];
    }
    // 历史记录 + 猜你想搜
    self.historyIsSuccess = YES;
    [self.viewModel clearHistoryTableView];
    self.viewModel.loadRequestTimes = 0;
    [self requestHistoryFromRemote];
    [self requestSugSubscribe];
    [self requestGuessYouWantData];
}

// 猜你想搜
- (void)requestGuessYouWantData {
    NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    if (cityId) {
        [self.viewModel requestGuessYouWant:cityId houseType:self.houseType];
    }
}

// 历史记录
- (void)requestHistoryFromRemote {
    if (![FHEnvContext isNetworkConnected]) {
        self.isLoadingData = NO;
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    } else {
        [self startLoading];
        self.isLoadingData = YES;
        [self.viewModel requestSearchHistoryByHouseType:[NSString stringWithFormat:@"%zi",_houseType]];
    }
}

// 删除历史记录
- (void)requestDeleteHistory {
    if (![FHEnvContext isNetworkConnected]) {
        self.isLoadingData = NO;
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    } else {
        self.isLoadingData = YES;
        [self.viewModel requestDeleteHistoryByHouseType:[NSString stringWithFormat:@"%zi",_houseType]];
    }
}

// 搜索订阅
- (void)requestSugSubscribe {
    NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    if (cityId) {
        [self.viewModel requestSugSubscribe:cityId houseType:self.houseType];
    }
}

// sug建议
- (void)requestSuggestion:(NSString *)text {
    if (![FHEnvContext isNetworkConnected]) {
        self.isLoadingData = NO;
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    } else {
        if (![self shouldReloadSuggestionWord:text]) {
            return;
        }
        NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
        if (cityId) {
            self.suggestTableView.hidden = YES;
            self.emptyView.hidden = YES;
            [self startLoading];
            self.isLoadingData = YES;
            [self.viewModel requestSuggestion:cityId houseType:self.houseType query:text];
        }
    }
}

/**
 Sug词有变化时发起请求，否则不发请求，用于避免
 搜索中间页顶部tab切换时发起重复sug词的请求
 */
- (BOOL)shouldReloadSuggestionWord:(NSString *)word {
    ///加个开关，万一有问题直接关了这个优化
    BOOL disableSugOptimization = NO;
    NSDictionary *settings = [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    if (settings && [settings isKindOfClass:[NSDictionary class]]) {
        disableSugOptimization = [settings btd_boolValueForKey:@"f_disable_sug_word_show_optimization"];
        if (disableSugOptimization) {
            return YES;
        }
    }
    
    if (![self.lastSearchWord isEqualToString:word]) {
        self.lastSearchWord = word;
        return YES;
    }
    
    return NO;
}

#pragma mark - dealloc

- (void)dealloc
{
    
}

@end

