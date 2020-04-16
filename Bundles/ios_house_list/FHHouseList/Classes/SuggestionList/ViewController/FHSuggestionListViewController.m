//
//  FHSuggestionListViewController.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewController.h"
#import "TTDeviceHelper.h"
#import "FHHouseType.h"
#import "FHHouseTypeManager.h"
#import "FHPopupMenuView.h"
#import "FHSuggestionListViewModel.h"
#import "FHEnvContext.h"
#import "ToastManager.h"
#import "TTNavigationController.h"
#import "FHSugSubscribeListViewController.h"
#import "HMDTTMonitor.h"
#import "TTInstallIDManager.h"
#import "FHOldSuggestionItemCell.h"

@interface FHSuggestionListViewController ()<UITextFieldDelegate>

@property (nonatomic, assign)     FHHouseType       houseType;
@property (nonatomic, weak)     FHPopupMenuView       *popupMenuView;
@property (nonatomic, strong)   FHSuggestionListViewModel      *viewModel;

@property (nonatomic, assign)   FHEnterSuggestionType       fromSource;
@property (nonatomic, copy)   NSString*   autoFillInputText;

@property (nonatomic, weak)     id<FHHouseSuggestionDelegate>    suggestDelegate;
@property (nonatomic, weak)     UIViewController   *backListVC; // 需要返回到的页面

@property (nonatomic, strong)   NSMutableDictionary       *homePageRollDic;// 传入搜索列表的轮播词-只用于搜索框展示和搜索用
@property (nonatomic, assign)   BOOL       canSearchWithRollData; // 如果为YES，支持placeholder搜索
@property (nonatomic, assign)   BOOL       hasDismissedVC;

@end

@implementation FHSuggestionListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 1、from_home(native参数)
        if (paramObj.allParams[@"from_home"]) {
            self.fromSource = [paramObj.allParams[@"from_home"] integerValue];
        } else {
            self.fromSource = FHEnterSuggestionTypeDefault; // h5 不需要此参数，但是需要其他一些参数：origin_from enter_from element_from house_type page_type
        }
        // 2、house_type
        _houseType = 0; // 特殊值，为了第一次setHouseType的时候执行相关功能
        _viewModel = [[FHSuggestionListViewModel alloc] initWithController:self];
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
        if (paramObj.allParams[@"search_history_text"]) {
            self.autoFillInputText = paramObj.allParams[@"search_history_text"];
        }
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
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    if (self.autoFillInputText) {
        self.naviBar.searchInput.text = self.autoFillInputText;
    }
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.naviBar.searchInput resignFirstResponder];
}

- (void)setupUI {
    [self setupNaviBar];
}

- (void)setupNaviBar {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    _naviBar = [[FHSearchBar alloc] initWithType:FHSearchNavTypeSug];
    [_naviBar setSearchPlaceHolderText:@"二手房/租房/小区"];
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

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
