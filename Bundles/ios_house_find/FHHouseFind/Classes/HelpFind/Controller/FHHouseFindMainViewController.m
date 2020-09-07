//
//  FHHouseFindMainViewController.m
//  FHHouseFind
//
//  Created by 张静 on 2019/4/1.
//

#import "FHHouseFindMainViewController.h"
#import "FHHouseFindHelpMainViewModel.h"
#import "FHHouseFindHelpBaseViewController.h"
#import "FHHouseFindResultViewController.h"
#import <TTReachability/TTReachability.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "FHHouseFindHelpViewController.h"
#import "FHHouseType.h"
#import "FHEnvContext.h"
#import "NSURL+BTDAdditions.h"

extern NSString *const kFHFindHouseTypeNumberCacheKey;

@interface FHHouseFindMainViewController ()

@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) FHHouseFindHelpMainViewModel *viewModel;
@property (nonatomic , strong) TTRouteParamObj *paramObj;
@property (nonatomic , strong) FHHouseFindHelpBaseViewController *childVC;
@property (nonatomic , assign) FHHouseType houseType;

@end

@implementation FHHouseFindMainViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        //init coordinate viewmodel according to viewmodel
        self.paramObj = paramObj;
        self.hidesBottomBarWhenPushed = YES;
        _viewModel = [[FHHouseFindHelpMainViewModel alloc]initWithViewController:self paramObj:paramObj];
        NSDictionary *recommendDict = [paramObj.allParams tt_dictionaryValueForKey:@"recommend_house"];
        if (recommendDict.count > 0) {
            _viewModel.recommendModel = [[FHHouseFindRecommendDataModel alloc]initWithDictionary:recommendDict error:nil];
        }
        
        _houseType = paramObj.allParams[@"house_type"] ? [paramObj.allParams[@"house_type"] integerValue] : FHHouseTypeSecondHandHouse;

        NSHashTable<FHHouseSuggestionDelegate> *help_delegate = paramObj.allParams[@"help_delegate"];
        self.helpDelegate = help_delegate.anyObject;
        NSHashTable *back_vc = paramObj.allParams[@"need_back_vc"]; // pop方式返回某个页面
        self.backListVC = back_vc.anyObject;  // 需要返回到的某个列表页面
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //解决跳到结果页后在ios9下面顶部出现白条的问题
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    [self setupUI];
    if (_viewModel.recommendModel != nil) {
        
        if (_viewModel.recommendModel.used) {
            [self addHouseFindResultVC];
        }else {
            [self addHouseFindHelpVC];
        }
        return;
    }
    [self startLoadData];
}

- (void)setupUI
{
    [self addDefaultEmptyViewFullScreen];
}

- (void)addHouseFindHelpVC
{
    NSDictionary *recommendDict = [_viewModel.recommendModel toDictionary];
    TTRouteParamObj *paramObj = self.paramObj;
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    if (paramObj.userInfo.allInfo) {
        [infoDict addEntriesFromDictionary:paramObj.userInfo.allInfo];
    }
    infoDict[@"recommend_house"] = recommendDict;
    infoDict[@"house_type"] = @(_houseType);
    paramObj.userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
    _childVC = [[FHHouseFindHelpViewController alloc]initWithRouteParamObj:paramObj];
    [self addChildViewController:_childVC];
    [self.view addSubview:_childVC.view];
    [self.view bringSubviewToFront:self.emptyView];
}

- (void)addHouseFindResultVC
{
    NSDictionary *recommendDict = [_viewModel.recommendModel toDictionary];
    TTRouteParamObj *paramObj = self.paramObj;
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    if (paramObj.userInfo.allInfo) {
        [infoDict addEntriesFromDictionary:paramObj.userInfo.allInfo];
    }
    infoDict[@"recommend_house"] = recommendDict;
    
    //增加服务端逻辑控制,如果没下发用本地兜底
    if ([recommendDict[@"open_url"] isKindOfClass:[NSString class]]) {
        NSURL *openUrl = [NSURL URLWithString:recommendDict[@"open_url"]];
        NSDictionary *queryDict = [openUrl btd_queryItems];
        if (queryDict && queryDict[@"house_type"]) {
            infoDict[@"house_type"]  = @([queryDict[@"house_type"] integerValue]);
        }
    }else{
        if ([[self readHouseTypeNum] isKindOfClass:[NSString class]] && [[[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList containsObject:@([[self readHouseTypeNum] integerValue])]) {
            infoDict[@"house_type"] = @([[self readHouseTypeNum] integerValue]);
        }else{
            infoDict[@"house_type"] = @(_houseType);
        }
    }
    
    
    
    paramObj.userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
    _childVC = [[FHHouseFindResultViewController alloc]initWithRouteParamObj:paramObj];
    [self addChildViewController:_childVC];
    [self.view addSubview:_childVC.view];
    [self.view bringSubviewToFront:self.emptyView];
}


- (NSString *)readHouseTypeNum{
    YYCache *findHousePhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig findHousePhoneNumberCache];
    return (NSString *)[findHousePhoneNumberCache objectForKey:kFHFindHouseTypeNumberCacheKey];
}

- (void)jumpHouseFindHelpVC:(NSNumber *)houseTypeNum
{
    NSDictionary *recommendDict = nil;
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    FHHouseFindRecommendDataModel *recommendModel = [self.childVC getRecommendModel];
    if (recommendModel) {
        recommendModel.used = NO;
        recommendDict = [recommendModel toDictionary];
    }
    infoDict[@"recommend_house"] = recommendDict;
    infoDict[@"house_type"] = @([houseTypeNum integerValue]);
    _houseType = [houseTypeNum integerValue];
    [self jump2ChildVC:infoDict isHelp:NO];
}

- (void)jumpHouseFindResultVC:(NSNumber *)houseTypeNum
{
    NSString *openUrl = [NSString stringWithFormat:@"sslocal://house_find"];
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    NSDictionary *recommendDict = nil;
    FHHouseFindRecommendDataModel *recommendModel = [self.childVC getRecommendModel];
    if (recommendModel) {
        recommendModel.used = YES;
        recommendDict = [recommendModel toDictionary];
    }
    infoDict[@"house_type"] = @([houseTypeNum integerValue]);
    _houseType = [houseTypeNum integerValue];
    infoDict[@"recommend_house"] = recommendDict;
    [self jump2ChildVC:infoDict isHelp:YES];
}



- (void)jump2ChildVC:(NSDictionary *)dict isHelp:(BOOL)isHelp
{
    NSString *openUrl = [NSString stringWithFormat:@"sslocal://house_find"];
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    //帮我找房区分来源
    NSDictionary *tracerDict = self.tracerDict;
    if (!tracerDict || !tracerDict.count) {
        tracerDict = self.paramObj.userInfo.allInfo[@"tracer"];
    }
    infoDict[@"tracer"] = tracerDict ?: @{};
    if (dict.count > 0) {
        [infoDict addEntriesFromDictionary:dict];
    }
    if (isHelp) {
        
        infoDict[@"fh_needRemoveLastVC_key"] = @(YES);
        infoDict[@"fh_needRemoveedVCNamesString_key"] = @[@"FHHouseFindMainViewController"];
        
    }
    if (self.helpDelegate != nil) {
        
        _houseType = [dict[@"house_type"] integerValue];
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        // 回传数据，外部pop 页面
        
        if ([self.helpDelegate respondsToSelector:@selector(changeHouseType:)]) {
            [self.helpDelegate performSelector:@selector(changeHouseType:) withObject:@(_houseType)];
        }
        
        TTRouteObject *obj = [[TTRoute sharedRoute] routeObjWithOpenURL:[NSURL URLWithString:openUrl] userInfo:userInfo];
        if ([self.helpDelegate respondsToSelector:@selector(suggestionSelected:)]) {
            [self.helpDelegate suggestionSelected:obj];// 部分-内部有页面跳转逻辑
        }
                
        if (self.backListVC) {
            [self.navigationController popToViewController:self.backListVC animated:YES];
        }
    } else {
        
        NSHashTable *helpDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [helpDelegateTable addObject:self];
        infoDict[@"help_delegate"] = helpDelegateTable;
        NSHashTable *tempTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [tempTable addObject:self];
        infoDict[@"need_back_vc"] = tempTable;
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        NSURL *url = [NSURL URLWithString:openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)changeHouseType:(NSNumber *)houseNum
{
    _houseType = [houseNum integerValue];
}

#pragma mark - help delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject
{
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    NSDictionary *recommendDict = [routeObject.paramObj.allParams tt_dictionaryValueForKey:@"recommend_house"];
    if (recommendDict.count > 0) {
        _viewModel.recommendModel = [[FHHouseFindRecommendDataModel alloc]initWithDictionary:recommendDict error:nil];
    }
    [_childVC refreshRecommendModel:_viewModel.recommendModel andHouseType:_houseType];
}

- (void)startLoadData
{
    if ([TTReachability isNetworkConnected]) {
        [self startLoading];
        self.isLoadingData = YES;
        [self.viewModel startLoadData];

    } else {
        __weak typeof(self)wself = self;
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        if (!self.customNavBarView) {
            [self setupDefaultNavBar:NO];
        }
        [self.emptyView addSubview:self.customNavBarView];
    }
}

// 重新加载
- (void)retryLoadData
{
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        if([change[@"new"] boolValue]){
            [self.view endEditing:YES];
            [_childVC endEditing:NO];
        }else{
            [_childVC endEditing:YES];
        }
    }
}

- (void)dealloc
{
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
}

@end
