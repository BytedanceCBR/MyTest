//
//  FHPriceValuationResultViewModel.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import "FHPriceValuationResultViewModel.h"
#import "TTRoute.h"
#import "FHHouseType.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHPriceValuationAPI.h"
#import "ToastManager.h"
#import "FHDetailNoticeAlertView.h"
#import <FHHouseBase/FHEnvContext.h>
#import "TTReachability.h"
#import "FHUserTracker.h"

extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHToastCountKey;
extern NSString *const kFHPLoginhoneNumberCacheKey;

@interface FHPriceValuationResultViewModel()<FHPriceValuationResultViewDelegate,FHHouseBaseDataProtocel>

@property(nonatomic , weak) FHPriceValuationResultController *viewController;
@property(nonatomic , strong) FHPriceValuationResultView *view;
@property (nonatomic, weak) FHDetailNoticeAlertView *alertView;
@property (nonatomic, strong) FHDetailNeighborhoodModel *neighborhoodDetailModel;

@end

@implementation FHPriceValuationResultViewModel

- (instancetype)initWithView:(FHPriceValuationResultView *)view controller:(FHPriceValuationResultController *)viewController {
    self = [super init];
    if (self) {
        _view = view;
        _view.delegate = self;
        _viewController = viewController;
    }
    return self;
}

- (void)requestData {
    if(self.viewController.model){
        [self addGoDetailTracer];
        [self requestChartData];
    }else{
        [self requestEvaluateResultData];
    }
}

- (void)requestEvaluateData {
    __weak typeof(self) wself = self;
    NSDictionary *params = [self getEvaluateParams];

    [self.viewController startLoading];
    [FHPriceValuationAPI requestEvaluateWithParams:params completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.viewController endLoading];
            FHPriceValuationEvaluateModel *eModel = (FHPriceValuationEvaluateModel *)model;
            
            if (!wself) {
                return;
            }
            
            if (error) {
                //TODO: show handle error
                [wself.viewController setNavBar:YES];
                wself.viewController.model = nil;
                [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
                [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
                return;
            }
            
            [wself.viewController refreshContentOffset:self.view.scrollView.contentOffset];
            [wself.viewController.emptyView hideEmptyView];
            wself.view.hidden = NO;
            
            if(model){
                wself.viewController.model = eModel;
                //仅仅为了同步一下回传的参数数据
                FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *infoModel = eModel.data.houseInfoDict;
                infoModel.neighborhoodName = wself.viewController.infoModel.neighborhoodName;
                wself.viewController.infoModel = infoModel;
                
                [wself.view updateView:eModel infoModel:wself.viewController.infoModel];
                [wself addGoDetailTracer];
            }
        });
    }];
}

- (void)requestEvaluateResultData {
    __weak typeof(self) wself = self;
    NSDictionary *params = [self getEvaluateParams];
    
    [self.viewController startLoading];
    [FHPriceValuationAPI requestEvaluateResultWithParams:params neighborhoodId:self.viewController.infoModel.neighborhoodId completion:^(NSDictionary * _Nonnull response, NSError * _Nonnull error) {
        [wself.viewController endLoading];
        
        FHPriceValuationEvaluateModel *eModel = (FHPriceValuationEvaluateModel *)response[@"evaluateData"];
        FHDetailNeighborhoodModel *cModel = (FHPriceValuationEvaluateModel *)response[@"chartData"];
        
        if (!wself) {
            return;
        }
        
        if (error) {
            //TODO: show handle error
            [wself.viewController setNavBar:YES];
            wself.viewController.model = nil;
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            return;
        }
        
        [wself.viewController refreshContentOffset:wself.view.scrollView.contentOffset];
        [wself.viewController.emptyView hideEmptyView];
        self.view.hidden = NO;
        
        if(eModel){
            wself.viewController.model = eModel;
            //仅仅为了同步一下回传的参数数据
            FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *infoModel = eModel.data.houseInfoDict;
            infoModel.neighborhoodName = wself.viewController.infoModel.neighborhoodName;
            wself.viewController.infoModel = infoModel;
            
            [wself.view updateView:eModel infoModel:wself.viewController.infoModel];
            [wself addGoDetailTracer];
        }
        
        if(cModel){
            wself.neighborhoodDetailModel = cModel;
            [wself.view updateChart:cModel];
        }
    }];
}

- (NSDictionary *)getEvaluateParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if(self.viewController.infoModel){
        params[@"neighborhood_id"] = self.viewController.infoModel.neighborhoodId;
        params[@"squaremeter"] = self.viewController.infoModel.squaremeter;
        params[@"floor_plan_room"] = self.viewController.infoModel.floorPlanRoom;
        params[@"floor_plan_hall"] = self.viewController.infoModel.floorPlanHall;
        params[@"floor_plan_bath"] = self.viewController.infoModel.floorPlanBath;
        params[@"total_floor"] = self.viewController.infoModel.totalFloor;
        params[@"floor"] = self.viewController.infoModel.floor;
        params[@"facing_type"] = self.viewController.infoModel.facingType;
        params[@"decoration_type"] = self.viewController.infoModel.decorationType;
        params[@"built_year"] = self.viewController.infoModel.builtYear;
        params[@"building_type"] = self.viewController.infoModel.buildingType;
    }
    
    return params;
}

- (void)requestChartData {
    __weak typeof(self) wself = self;
    //图表数据
    [self.viewController startLoading];
    [FHHouseDetailAPI requestNeighborhoodDetail:self.viewController.infoModel.neighborhoodId ridcode:nil realtorId:nil logPB:nil query:nil extraInfo:nil completion:^(FHDetailNeighborhoodModel * _Nullable model, NSError * _Nullable error) {
        [wself.viewController endLoading];
        if (model && !error) {
            wself.view.hidden = NO;
            [wself.view updateView:wself.viewController.model infoModel:wself.viewController.infoModel];
            [wself.viewController refreshContentOffset:wself.view.scrollView.contentOffset];
            [wself.viewController.emptyView hideEmptyView];
            _neighborhoodDetailModel = model;
            [wself.view updateChart:model];
        }else{
            [wself.viewController setNavBar:YES];
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }];
}

- (void)setDefaultBuildYear {
    //兼容android的逻辑
    if([self.viewController.infoModel.builtYear isEqualToString:@"0"]){
        self.viewController.infoModel.builtYear = @"";
    }
    
    NSString *buildYear = self.viewController.infoModel.builtYear;
    
    if((!buildYear || [buildYear isEqualToString:@""]) && _neighborhoodDetailModel){
        NSArray *baseInfos = _neighborhoodDetailModel.data.baseInfo;
        for (FHHouseBaseInfoModel *model in baseInfos) {
            if([model.attr isEqualToString:@"建造年代"]){
                if(model.value.length >= 4){
                    buildYear = [model.value substringToIndex:4];
                    if([self isPureInt:buildYear]){
                        self.viewController.infoModel.builtYear = buildYear;
                    }
                }
                return;
            }
        }
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (void)addGoDetailTracer {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    tracer[@"enter_from"] = tracerDict[@"enter_from"] ? tracerDict[@"enter_from"] : @"be_null";
    tracer[@"page_type"] = [self pageType];
    tracer[@"group_id"] = self.viewController.model.data.estimateId;
    tracer[@"origin_from"] = tracerDict[@"origin_from"] ? tracerDict[@"origin_from"] : @"be_null";
    tracer[@"origin_search_id"] = tracerDict[@"origin_search_id"] ? tracerDict[@"origin_search_id"] : @"be_null";
    TRACK_EVENT(@"go_detail", tracer);
}

- (void)addInfomationTracer:(NSString *)key {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    tracer[@"enter_from"] = tracerDict[@"enter_from"] ? tracerDict[@"enter_from"] : @"be_null";
    tracer[@"page_type"] = [self pageType];
    tracer[@"click_position"] = @"sale";
    tracer[@"group_id"] = self.viewController.model.data.estimateId;
    tracer[@"origin_from"] = tracerDict[@"origin_from"] ? tracerDict[@"origin_from"] : @"be_null";
    tracer[@"origin_search_id"] = tracerDict[@"origin_search_id"] ? tracerDict[@"origin_search_id"] : @"be_null";

    TRACK_EVENT(key, tracer);
}

- (void)addClickConfirmationLogWithAlertView:(FHDetailNoticeAlertView *)alertView
{
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    tracer[@"enter_from"] = tracerDict[@"enter_from"] ? tracerDict[@"enter_from"] : @"be_null";
    tracer[@"page_type"] = [self pageType];
    tracer[@"click_position"] = @"sale";
    tracer[@"group_id"] = self.viewController.model.data.estimateId;
    tracer[@"origin_from"] = tracerDict[@"origin_from"] ? tracerDict[@"origin_from"] : @"be_null";
    tracer[@"origin_search_id"] = tracerDict[@"origin_search_id"] ? tracerDict[@"origin_search_id"] : @"be_null";
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSArray *selectAgencyList = [alertView selectAgencyList] ? : self.neighborhoodDetailModel.data.chooseAgencyList;
    for (FHFillFormAgencyListItemModel *item in selectAgencyList) {
        if (item.agencyId.length > 0) {
            [dict setValue:[NSNumber numberWithInt:item.checked] forKey:item.agencyId];
        }
    }
    tracer[@"agency_list"] = dict.count > 0 ? dict : @"be_null";
    TRACK_EVENT(@"click_confirmation", tracer);
}

- (void)addClickExpectedTracer:(NSString *)result {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    tracer[@"enter_from"] = tracerDict[@"enter_from"] ? tracerDict[@"enter_from"] : @"be_null";
    tracer[@"page_type"] = [self pageType];
    tracer[@"click_type"] = result;
    tracer[@"group_id"] = self.viewController.model.data.estimateId;
    tracer[@"origin_from"] = tracerDict[@"origin_from"] ? tracerDict[@"origin_from"] : @"be_null";
    tracer[@"origin_search_id"] = tracerDict[@"origin_search_id"] ? tracerDict[@"origin_search_id"] : @"be_null";
    TRACK_EVENT(@"click_expected", tracer);
}

- (NSString *)pageType {
    return @"value_result";
}

- (BOOL)popToViewController:(NSString *)aVCName animated:(BOOL)animated {
    __block UIViewController *viewController = nil;
    [self.viewController.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(aVCName)]) {
            viewController = obj;
        }
    }];
    if (viewController) {
        [self.viewController.navigationController popToViewController:viewController animated:animated];
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - FHHouseBaseDataProtocel

- (void)callBackDataInfo:(NSDictionary *)info {
    [self requestEvaluateData];
}

#pragma mark - FHPriceValuationResultViewDelegate

- (void)moreInfo {
    NSHashTable *delegate = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [delegate addObject:self];
    
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"enter_from"] = [self pageType];
    
    //默认带入小区的建造年代
    [self setDefaultBuildYear];

    NSDictionary *dict = @{
                           @"infoModel" : self.viewController.infoModel,
                           @"delegate" : delegate,
                           @"tracer" : tracerDict,
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://price_valuation_more_info"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)goToNeiborhoodDetail {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionary];
    tracer[@"page_type"] = @"neighborhood_detail";
    tracer[@"card_type"] = @"no_pic";
    tracer[@"enter_from"] = [self pageType];
    tracer[@"element_from"] = @"be_null";
    tracer[@"rank"] = @"be_null";
    tracer[@"origin_from"] = tracerDict[@"origin_from"] ? tracerDict[@"origin_from"] : @"be_null";
    tracer[@"origin_search_id"] = tracerDict[@"origin_search_id"] ? tracerDict[@"origin_search_id"] : @"be_null";
    tracer[@"log_pb"] = tracerDict[@"log_pb"] ? tracerDict[@"log_pb"] : @"be_null";
    NSDictionary *dict = @{
                           @"house_type":@(FHHouseTypeNeighborhood),
                           @"tracer": tracer
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",self.viewController.infoModel.neighborhoodId];

    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)evaluate:(NSInteger)type desc:(nonnull NSString *)desc {
    __weak typeof(self) wself = self;
    
    //埋点
    [self addClickExpectedTracer:desc];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"estimate_id"] = self.viewController.model.data.estimateId;
    params[@"evaluate_score"] = @(type);
    params[@"evaluate_desc"] = desc;
    
    [FHPriceValuationAPI requestEvaluateEstimateWithParams:params completion:^(BOOL success, NSError * _Nonnull error) {
        if(success && !error){
            [wself.view hideEvaluateView];
            [[ToastManager manager] showToast:@"感谢您的反馈"];
        }else{
            [[ToastManager manager] showToast:@"网络异常"];
        }
    }];
}

//进入城市行情页
- (void)goToCityMarket {
    BOOL isPop = [self popToViewController:@"FHCityMarketDetailViewController" animated:YES];
    if(!isPop){
        //push
        NSURL* url = [NSURL URLWithString:@"sslocal://city_market_trend"];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
    }
}

- (void)houseSale {
    //埋点
    [self addInfomationTracer:@"information_show"];
    
    __weak typeof(self)wself = self;
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    id phoneCache = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    id loginPhoneCache = [sendPhoneNumberCache objectForKey:kFHPLoginhoneNumberCacheKey];
    
    NSString *phoneNum = nil;
    if ([phoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)phoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }else if ([loginPhoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)loginPhoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }
    NSString *subtitle = @"专业房地产经纪人为您服务";
    if (phoneNum.length > 0) {
        subtitle = [NSString stringWithFormat:@"%@\n已为您填写上次提交时使用的手机号",subtitle];
    }
    FHDetailNoticeAlertView *alertView = [[FHDetailNoticeAlertView alloc] initWithTitle:@"我要卖房" subtitle:subtitle btnTitle:@"提交"];
    if (_neighborhoodDetailModel.data.chooseAgencyList.count > 0) {
        NSInteger selectCount = 0;
        for (FHFillFormAgencyListItemModel *item in _neighborhoodDetailModel.data.chooseAgencyList) {
            if (![item isKindOfClass:[FHFillFormAgencyListItemModel class]]) {
                continue;
            }
            if (item.checked) {
                selectCount += 1;
            }
        }
        [alertView updateAgencyTitle:[NSString stringWithFormat:@"%ld",selectCount]];
        alertView.agencyClickBlock = ^(FHDetailNoticeAlertView *alert){
            
            [alert endEditing:YES];
            NSMutableDictionary *info = @{}.mutableCopy;
            info[@"choose_agency_list"] = [alert selectAgencyList] ? : _neighborhoodDetailModel.data.chooseAgencyList;
            NSHashTable *delegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
            [delegateTable addObject:alert];
            info[@"delegate"] = delegateTable;
            TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
            NSURL *url = [NSURL URLWithString:@"fschema://house_agency_list"];
            [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
        };
    }
    alertView.phoneNum = phoneNum;
    alertView.confirmClickBlock = ^(NSString *phoneNum,FHDetailNoticeAlertView *alert){
        [wself addClickConfirmationLogWithAlertView:alert];
        [wself fillFormRequest:phoneNum alertView:alert];
    };
    alertView.tipClickBlock = ^{
        NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
        NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
        [[TTRoute sharedRoute]openURLByPushViewController:url];
    };
    [alertView showFrom:self.view];
    self.alertView = alertView;
}

- (void)fillFormRequest:(NSString *)phoneNum alertView:(FHDetailNoticeAlertView *)alertView {
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSArray *selectAgencyList = [alertView selectAgencyList] ? : self.neighborhoodDetailModel.data.chooseAgencyList;
    if (selectAgencyList.count > 0) {
        NSMutableArray *array = @[].mutableCopy;
        for (FHFillFormAgencyListItemModel *item in selectAgencyList) {
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"agency_id"] = item.agencyId;
            dict[@"checked"] = [NSNumber numberWithInt:item.checked];
            if (dict.count > 0) {
                [array addObject:dict];
            }
        }
        params[@"choose_agency_list"] = array;
    }
    [FHPriceValuationAPI requestSubmitPhoneWithEstimateId:self.viewController.model.data.estimateId houseType:2 phone:phoneNum params:params completion:^(BOOL success, NSError * _Nonnull error) {
        if(success && !error){
            [wself.alertView dismiss];
            [[ToastManager manager] showToast:@"提交成功，经纪人将尽快与您联系"];
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache setObject:phoneNum forKey:kFHPhoneNumberCacheKey];
        }else {
            [[ToastManager manager] showToast:@"提交失败"];
        }
    }];
}

@end
