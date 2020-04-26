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
#import "HMDTTMonitor.h"
#import "TTInstallIDManager.h"
#import "FHOldSuggestionItemCell.h"
#import "FHSuggestionEmptyCell.h"

@interface FHChildSuggestionListViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)   FHChildSuggestionListViewModel      *viewModel;

@property (nonatomic, assign)   FHEnterSuggestionType       fromSource;

@property (nonatomic, weak)     id<FHHouseSuggestionDelegate>    suggestDelegate;
@property (nonatomic, weak)     UIViewController   *backListVC; // 需要返回到的页面

@property (nonatomic, strong)   NSMutableDictionary       *homePageRollDic;// 传入搜索列表的轮播词-只用于搜索框展示和搜索用
@property (nonatomic, assign)   BOOL       canSearchWithRollData; // 如果为YES，支持placeholder搜索
@property (nonatomic, assign)   BOOL       hasDismissedVC;

@property (nonatomic, assign)   BOOL isShowHistory;
@property (nonatomic, copy)     NSString *textFieldText;

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
        // 4.1、guess_you_want_words 猜你想搜前3个词，外部轮播传入
        id tempArray = paramObj.allParams[@"guess_you_want_words"];
        if (tempArray && [tempArray isKindOfClass:[NSArray class]]) {
            self.viewModel.guessYouWantWords = [[NSMutableArray alloc] initWithArray:tempArray];
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
    self.canSearchWithRollData = NO;
    self.hasDismissedVC = NO;
    [self setupUI];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)setFatherVC:(FHSuggestionListViewController *)fatherVC
{
    _fatherVC = fatherVC;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    if (isCanTrack && self.fatherVC.naviBar.searchInput.text.length == 0) {
        [self.viewModel reloadHistoryTableView];
    }
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
    if (self.canSearchWithRollData) {
        self.canSearchWithRollData = NO;
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
    }
    if (isCanTrack) {
        _textFieldText = text;
    }
}

// 输入框执行搜索
- (void)doTextFieldShouldReturn:(NSString *)text {
    NSString *userInputText = text;
    
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
        if (self.tracerDict.count > 0) {
            infos = @{
                      @"houseSearch":houseSearchParams,
                      @"tracer": self.tracerDict
                      };
        }
        [self jumpToCategoryListVCByUrl:openUrl queryText:placeHolderStr placeholder:placeHolderStr infoDict:infos];
    } else {
        self.tracerDict[@"category_name"] = [self.viewModel categoryNameByHouseType];
        NSDictionary *infos = @{@"houseSearch":houseSearchParams,
                               @"tracer": self.tracerDict
                               };
        [self jumpToCategoryListVCByUrl:openUrl queryText:placeHolderStr placeholder:placeHolderStr infoDict:infos];
    }
}

- (void)jumpToCategoryListVCByUrl:(NSString *)jumpUrl queryText:(NSString *)queryText placeholder:(NSString *)placeholder infoDict:(NSDictionary *)infos {
    NSString *openUrl = jumpUrl;
    if (openUrl.length <= 0) {
        openUrl = [NSString stringWithFormat:@"fschema://house_list?house_type=%ld&full_text=%@&placeholder=%@",self.houseType,queryText,placeholder];
    }
    if (self.suggestDelegate != NULL && ![openUrl containsString:@"webview"]) {
        // 1、suggestDelegate说明需要回传sug数据
        // 2、如果是从租房大类页和二手房大类页向下个页面跳转，则需要移除搜索列表相关的页面
        // 3、如果是从列表页和找房Tab列表页进入搜索，则还需pop到对应的列表页
        NSMutableDictionary *tempInfos = [NSMutableDictionary dictionaryWithDictionary:infos];
        if (self.backListVC == nil && (self.fromSource == FHEnterSuggestionTypeOldMain || self.fromSource == FHEnterSuggestionTypeRenting)) {
            // 需要移除搜索列表相关页面
            tempInfos[@"fh_needRemoveLastVC_key"] = @(YES);
            tempInfos[@"fh_needRemoveedVCNamesString_key"] = @[@"FHSuggestionListViewController",@"FHSugSubscribeListViewController"];
        }
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:tempInfos];
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
        if (self.fromSource == FHEnterSuggestionTypeHome || self.fromSource == FHEnterSuggestionTypeFindTab || self.fromSource == FHEnterSuggestionTypeDefault || self.fromSource == FHEnterSuggestionTypeOldMain) {
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
            [paramsExtra setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
            [[HMDTTMonitor defaultManager] hmdTrackService:@"guess_you_want_error" status:1 extra:paramsExtra];
        }else
        {
            [[HMDTTMonitor defaultManager] hmdTrackService:@"guess_you_want_error" status:0 extra:nil];
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
         [self requestSuggestion:text];
        _suggestTableView.hidden = !hasText;
        _historyTableView.hidden = hasText;
    }
    // 历史记录 + 猜你想搜
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
        [[ToastManager manager] showToast:@"网络异常"];
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

// 搜索订阅
- (void)requestSugSubscribe {
    NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    if (cityId) {
        [self.viewModel requestSugSubscribe:cityId houseType:self.houseType];
    }
}

// sug建议
- (void)requestSuggestion:(NSString *)text {
    NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    if (cityId) {
        [self.viewModel requestSuggestion:cityId houseType:self.houseType query:text];
    }
}

#pragma mark - dealloc

- (void)dealloc
{
    
}

@end

