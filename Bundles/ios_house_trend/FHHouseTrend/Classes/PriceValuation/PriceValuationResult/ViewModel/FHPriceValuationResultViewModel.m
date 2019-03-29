//
//  FHPriceValuationResultViewModel.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import "FHPriceValuationResultViewModel.h"
#import <TTRoute.h>
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
        self.view.hidden = NO;
        [self.view updateView:self.viewController.model infoModel:self.viewController.infoModel];
    }else{
        [self requestEvaluateData];
    }
    [self requestChartData];
}

- (void)requestEvaluateData {
    __weak typeof(self) wself = self;
    NSDictionary *params = [self getEvaluateParams];
    
    [self.viewController startLoading];
    [FHPriceValuationAPI requestEvaluateWithParams:params completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        [self.viewController endLoading];
        FHPriceValuationEvaluateModel *eModel = (FHPriceValuationEvaluateModel *)model;

        if (!wself) {
            return;
        }

        if (error) {
            //TODO: show handle error
            [wself.viewController setNavBar:YES];
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            return;
        }

        [wself.viewController setNavBar:NO];
        [wself.viewController.emptyView hideEmptyView];
        self.view.hidden = NO;

        if(model){
            wself.viewController.model = eModel;
            //仅仅为了同步一下回传的参数数据
            FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *infoModel = eModel.data.houseInfoDict;
            infoModel.neighborhoodName = self.viewController.infoModel.neighborhoodName;
            self.viewController.infoModel = infoModel;

            [wself.view updateView:eModel infoModel:wself.viewController.infoModel];
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
    [FHHouseDetailAPI requestNeighborhoodDetail:self.viewController.infoModel.neighborhoodId logPB:nil query:nil completion:^(FHDetailNeighborhoodModel * _Nullable model, NSError * _Nullable error) {
        if (model && !error) {
            _neighborhoodDetailModel = model;
            [wself.view updateChart:model];
        }
    }];
}

- (void)setDefaultBuildYear {
    NSString *buildYear = self.viewController.infoModel.builtYear;
    if((!buildYear || [buildYear isEqualToString:@""]) && _neighborhoodDetailModel){
        NSArray *baseInfos = _neighborhoodDetailModel.data.baseInfo;
        for (FHDetailNeighborhoodDataBaseInfoModel *model in baseInfos) {
            if([model.attr isEqualToString:@"建造年代"]){
                buildYear = [model.value substringToIndex:model.value.length - 1];
                self.viewController.infoModel.builtYear = buildYear;
                return;
            }
        }
    }
}

- (void)addGoDetailTracer {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"page_type"] = [self pageType];
    tracerDict[@"group_id"] = self.viewController.model.data.estimateId;
    TRACK_EVENT(@"go_detail", tracerDict);
}

- (void)addInfomationTracer:(NSString *)key {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"page_type"] = [self pageType];
    tracerDict[@"click_position"] = @"sale";
    tracerDict[@"group_id"] = self.viewController.model.data.estimateId;
    TRACK_EVENT(key, tracerDict);
}

- (void)addClickExpectedTracer:(NSString *)result {
    NSMutableDictionary *tracerDict = [self.viewController.tracerModel logDict];
    tracerDict[@"page_type"] = [self pageType];
    tracerDict[@"click_type"] = result;
    tracerDict[@"group_id"] = self.viewController.model.data.estimateId;
    TRACK_EVENT(@"click_expected", tracerDict);
}

- (NSString *)pageType {
    return @"value_result";
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
    NSMutableDictionary *traceParam = [self.viewController.tracerModel logDict];
    traceParam[@"page_type"] = @"neighborhood_detail";
    traceParam[@"card_type"] = @"no_pic";
    traceParam[@"enter_from"] = [self pageType];
    traceParam[@"element_from"] = @"be_null";
    traceParam[@"rank"] = @"be_null";
    NSDictionary *dict = @{
                           @"house_type":@(FHHouseTypeNeighborhood),
                           @"tracer": traceParam
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
        }
    }];
}

//进入城市行情页
- (void)goToCityMarket {
    
}

- (void)houseSale {
    
    //埋点
    [self addInfomationTracer:@"information_show"];
    
    __weak typeof(self)wself = self;
    FHDetailNoticeAlertView *alertView = [[FHDetailNoticeAlertView alloc] initWithTitle:@"我要卖房" subtitle:@"专业房地产经纪人为您服务" btnTitle:@"提交"];
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    alertView.phoneNum = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    alertView.confirmClickBlock = ^(NSString *phoneNum){
        [wself addInfomationTracer:@"click_confirmation"];
        [wself fillFormRequest:phoneNum];
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

- (void)fillFormRequest:(NSString *)phoneNum {
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"estimate_id"] = self.viewController.model.data.estimateId;
    params[@"house_type"] = @(2);
    params[@"phone"] = phoneNum;
    
    [FHPriceValuationAPI requestSubmitPhoneWithParams:params completion:^(BOOL success, NSError * _Nonnull error) {
       if(success && !error){
            [wself.alertView dismiss];
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache setObject:phoneNum forKey:kFHPhoneNumberCacheKey];
            NSInteger toastCount = [[NSUserDefaults standardUserDefaults]integerForKey:kFHToastCountKey];
            if (toastCount >= 3) {
                [[ToastManager manager] showToast:@"提交成功，经纪人将尽快与您联系"];
            }
        }else {
            [[ToastManager manager] showToast:@"提交失败"];
        }
    }];
}

@end
