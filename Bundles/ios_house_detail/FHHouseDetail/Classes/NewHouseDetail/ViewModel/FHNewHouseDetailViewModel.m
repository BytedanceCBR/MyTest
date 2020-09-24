//
//  FHNewHouseDetailViewModel.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailViewModel.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTAccountLogin/TTAccountLoginManager.h>
#import <FHHouseBase/FHEnvContext.h>
#import "FHHouseDetailAPI.h"
#import "TTUIResponderHelper.h"
#import "FHDetailPictureViewController.h"
#import "FHDetailNoticeAlertView.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHNewHouseDetailSectionController.h"
#import "FHNewHouseDetailHeaderMediaSM.h"
#import "FHNewHouseDetailHeaderMediaSC.h"
#import "FHNewHouseDetailCoreInfoSM.h"
#import "FHNewHouseDetailCoreInfoSC.h"
#import "FHNewHouseDetailFloorpanSM.h"
#import "FHNewHouseDetailFloorpanSC.h"
#import "FHNewHouseDetailSalesSM.h"
#import "FHNewHouseDetailSalesSC.h"
#import "FHNewHouseDetailAgentSM.h"
#import "FHNewHouseDetailAgentSC.h"
#import "FHNewHouseDetailAssessSM.h"
#import "FHNewHouseDetailAssessSC.h"
#import "FHNewHouseDetailBuildingsSM.h"
#import "FHNewHouseDetailBuildingsSC.h"
#import "FHNewHouseDetailRecommendSM.h"
#import "FHNewHouseDetailRecommendSC.h"
#import "FHNewHouseDetailRGCListSM.h"
#import "FHNewHouseDetailRGCListSC.h"
#import "FHNewHouseDetailSurroundingSM.h"
#import "FHNewHouseDetailSurroundingSC.h"
#import "FHNewHouseDetailTimelineSM.h"
#import "FHNewHouseDetailTimelineSC.h"
#import "FHNewHouseDetailDisclaimerSC.h"
#import "FHNewHouseDetailDisclaimerSM.h"
#import "FHNewHouseDetailViewController.h"

@interface FHNewHouseDetailViewModel ()

@property (nonatomic, strong , nullable) FHListResultHouseModel *relatedHouseData;

@property (nonatomic, weak)     FHHouseNewsSocialModel       *weakSocialInfo;

@end

@implementation FHNewHouseDetailViewModel

// 网络数据请求
- (void)startLoadData {
    // sub implements.........
    // Donothing
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestNewDetail:self.houseId logPB:self.listLogPB ridcode:self.ridcode realtorId:self.realtorId extraInfo:self.extraInfo completion:^(FHDetailNewModel * _Nullable model, NSError * _Nullable error) {
        if ([model isKindOfClass:[FHDetailNewModel class]] && !error) {
            if (model.data) {
                wSelf.detailController.hasValidateData = YES;
                [wSelf.detailController.emptyView hideEmptyView];
                wSelf.bottomBar.hidden = NO;
                [wSelf processDetailData:model];
                [wSelf.navBar showMessageNumber];
            }else {
                wSelf.detailController.isLoadingData = NO;
                wSelf.detailController.hasValidateData = NO;
                wSelf.bottomBar.hidden = YES;
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                [wSelf addDetailRequestFailedLog:model.status.integerValue message:@"empty"];
            }
        }else {
            wSelf.detailController.isLoadingData = NO;
            //            if (wSelf.detailController.instantData) {
            //                SHOW_TOAST(@"请求失败");
            //            }else{
            wSelf.detailController.hasValidateData = NO;
            wSelf.bottomBar.hidden = YES;
            [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            [wSelf addDetailRequestFailedLog:model.status.integerValue message:error.domain];
            //            }
        }
    }];
}

- (void)processDetailData:(FHDetailNewModel *)model{
    self.detailData = model;
    [self addDetailCoreInfoExcetionLog];
    
    // 清空数据源
    NSMutableArray *sectionModels = [NSMutableArray array];
    FHDetailContactModel *contactPhone = nil;
    
    if (model.data.highlightedRealtor) {
        contactPhone = model.data.highlightedRealtor;
    }else {
        contactPhone = model.data.contact;
    }
    contactPhone.isFormReport = !contactPhone.enablePhone;
    self.contactViewModel.contactPhone = contactPhone;
    self.contactViewModel.shareInfo = model.data.shareInfo;
    self.contactViewModel.followStatus = model.data.userStatus.courtSubStatus;
    self.contactViewModel.chooseAgencyList = model.data.chooseAgencyList;
    self.contactViewModel.socialInfo = model.data.socialInfo;
    self.contactViewModel.highlightedRealtorAssociateInfo = model.data.highlightedRealtorAssociateInfo;
    self.weakSocialInfo = model.data.socialInfo;
    
    BOOL showTitleMapBtn = NO;
    if (model.data.coreInfo.gaodeLat.length>0 && model.data.coreInfo.gaodeLng.length>0) {
        showTitleMapBtn = YES;
    }else {
        showTitleMapBtn = NO;
    }
    //头图
    FHNewHouseDetailHeaderMediaSM *headerMediaSM = [[FHNewHouseDetailHeaderMediaSM alloc] initWithDetailModel:self.detailData];
    [headerMediaSM updatewithContactViewModel:self.contactViewModel];
    headerMediaSM.sectionType = FHNewHouseDetailSectionTypeHeader;
    [sectionModels addObject:headerMediaSM];
    
    //基础信息
    FHNewHouseDetailCoreInfoSM *coreInfoSM = [[FHNewHouseDetailCoreInfoSM alloc] initWithDetailModel:self.detailData];
    coreInfoSM.sectionType = FHNewHouseDetailSectionTypeBaseInfo;
    [sectionModels addObject:coreInfoSM];
        
    //户型
    if ([model.data.floorpanList.list isKindOfClass:[NSArray class]] && model.data.floorpanList.list.count > 0) {
        FHNewHouseDetailFloorpanSM *floorpanSM = [[FHNewHouseDetailFloorpanSM alloc] initWithDetailModel:self.detailData];
        floorpanSM.sectionType = FHNewHouseDetailSectionTypeFloorpan;
        [sectionModels addObject:floorpanSM];
    }
    
    // 优惠信息
    if (model.data.discountInfo) {
        FHNewHouseDetailSalesSM *salesSM = [[FHNewHouseDetailSalesSM alloc] initWithDetailModel:self.detailData];
        salesSM.sectionType = FHNewHouseDetailSectionTypeSales;
        [salesSM updateDetailModel:self.detailData contactViewModel:self.contactViewModel];
        [sectionModels addObject:salesSM];
    }
    
//     推荐经纪人
    if (model.data.recommendedRealtors.count > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHNewHouseDetailAgentSM *agentSM = [[FHNewHouseDetailAgentSM alloc] initWithDetailModel:self.detailData];
        agentSM.sectionType = FHNewHouseDetailSectionTypeAgent;
        [sectionModels addObject:agentSM];
    }

    //楼盘动态
    if (model.data.timeline.list.count > 0) {
        FHNewHouseDetailTimelineSM *timeLineSM = [[FHNewHouseDetailTimelineSM alloc] initWithDetailModel:self.detailData];
        timeLineSM.sectionType = FHNewHouseDetailSectionTypeTimeline;
        [sectionModels addObject:timeLineSM];
    }
    
    // 小区评测
    if (model.data.strategy && model.data.strategy.articleList.count > 0) {
        FHNewHouseDetailAssessSM *assessSM = [[FHNewHouseDetailAssessSM alloc] initWithDetailModel:self.detailData];
        assessSM.sectionType = FHNewHouseDetailSectionTypeAssess;
        [sectionModels addObject:assessSM];
    }
    
//    用户房源评价
    if (model.data.realtorContent.content.data.count > 0) {
        FHNewHouseDetailRGCListSM *RGCListModel = [[FHNewHouseDetailRGCListSM alloc] initWithDetailModel:self.detailData];
        RGCListModel.sectionType = FHNewHouseDetailSectionTypeRGC;
        RGCListModel.detailTracerDic = self.detailTracerDic;
        NSString *searchId = self.listLogPB[@"search_id"];
        NSString *imprId = self.listLogPB[@"impr_id"];
        NSDictionary *extraDic = @{
            @"searchId":searchId?:@"be_null",
            @"imprId":imprId?:@"be_null",
            @"houseId":self.houseId,
            @"houseType":@(FHHouseTypeNewHouse),
            @"channelId":@"f_hosue_wtt"
        };
        RGCListModel.extraDic = extraDic;
        [sectionModels addObject:RGCListModel];
    }
    
    if (model.data.surroundingInfo || (model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng)) {
        FHNewHouseDetailSurroundingSM *surroundingSM = [[FHNewHouseDetailSurroundingSM alloc] initWithDetailModel:self.detailData];
        surroundingSM.sectionType = FHNewHouseDetailSectionTypeSurrounding;
        [sectionModels addObject:surroundingSM];

    }
    //地图
//    if(model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng){
//        FHDetailStaticMapCellModel *staticMapModel = [[FHDetailStaticMapCellModel alloc] init];
//        staticMapModel.baiduPanoramaUrl = model.data.coreInfo.baiduPanoramaUrl;
//        staticMapModel.mapCentertitle = model.data.coreInfo.name;
//        staticMapModel.gaodeLat = model.data.coreInfo.gaodeLat;
//        staticMapModel.gaodeLng = model.data.coreInfo.gaodeLng;
//        staticMapModel.houseId = model.data.coreInfo.id;
//        staticMapModel.houseType = [NSString stringWithFormat:@"%ld",(long)FHHouseTypeNewHouse];
//        //        staticMapModel.title = model.data.coreInfo.name;
//        staticMapModel.tableView = self.tableView;
//        staticMapModel.staticImage = model.data.coreInfo.gaodeImage;
//        staticMapModel.houseModelType = FHHouseModelTypeNewLocation;
//        [self.items addObject:staticMapModel];
//
//    } else{
//        NSString *eventName = @"detail_map_location_failed";
//        NSDictionary *cat = @{@"status": @(1)};
//
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
//        [params setValue:@"经纬度缺失" forKey:@"reason"];
//        [params setValue:model.data.coreInfo.id forKey:@"house_id"];
//        [params setValue:@(FHHouseTypeNewHouse) forKey:@"house_type"];
//        [params setValue:model.data.coreInfo.name forKey:@"name"];
//
//        [[HMDTTMonitor defaultManager] hmdTrackService:eventName metric:nil category:cat extra:params];
//    }
    
    //楼栋信息
    if (model.data.buildingInfo && model.data.buildingInfo.list.count) {
        FHNewHouseDetailBuildingsSM *BuildingSM = [[FHNewHouseDetailBuildingsSM alloc] initWithDetailModel:self.detailData];
        BuildingSM.sectionType = FHNewHouseDetailSectionTypeBuildings;
        [sectionModels addObject:BuildingSM];
    }
    
    self.sectionModels = sectionModels.copy;
    [self.detailController updateLayout:model.isInstantData];
    
    __weak typeof(self) weakSelf = self;
    if (!model.isInstantData && model.data) {
        [FHHouseDetailAPI requestRelatedFloorSearch:self.houseId offset:@"0" query:nil count:0 completion:^(FHListResultHouseModel * _Nullable model, NSError * _Nullable error) {
            weakSelf.relatedHouseData = model;
            [weakSelf processDetailRelatedData];
        }];
    }
}

// 处理详情页周边新盘请求数据
- (void)processDetailRelatedData {
    self.detailController.isLoadingData = NO;
    NSMutableArray *sectionModels = self.sectionModels.mutableCopy;
    if(_relatedHouseData.data && self.relatedHouseData.data.items.count > 0)
    {
        
        FHNewHouseDetailRecommendSM *recommendSM = [[FHNewHouseDetailRecommendSM alloc] initWithDetailModel:self.detailData];
        recommendSM.sectionType = FHNewHouseDetailSectionTypeRecommend;
        [recommendSM updateRelatedModel:self.relatedHouseData];
        [sectionModels addObject:recommendSM];
    }
    // 免责声明
    FHDetailNewModel * model = (FHDetailNewModel *)self.detailData;
    if (model.data.contact || model.data.disclaimer) {
        FHNewHouseDetailDisclaimerSM *disclaimerSM = [[FHNewHouseDetailDisclaimerSM alloc] initWithDetailModel:self.detailData];
        disclaimerSM.sectionType = FHNewHouseDetailSectionTypeDisclaimer;
        [sectionModels addObject:disclaimerSM];
    }
    self.sectionModels = sectionModels.copy;
}

- (NSString *)pageTypeString {
    return @"new_detail";
}

- (void)enableController:(BOOL)enabled
{
    TTNavigationController *nav = (TTNavigationController *)self.detailController.navigationController;
    nav.panRecognizer.enabled = enabled;
}

- (void)addGoDetailLog
{
    //    1. event_type ：house_app2c_v2
    //    2. page_type（详情页类型）：rent_detail（租房详情页），old_detail（二手房详情页）
    //    3. card_type（房源展现时的卡片样式）：left_pic（左图）
    //    4. enter_from（详情页入口）：search_related_list（搜索结果推荐）
    //    5. element_from ：search_related
    //    6. rank
    //    7. origin_from
    //    8. origin_search_id
    //    9.log_pb
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.detailTracerDic) {
        [params addEntriesFromDictionary:self.detailTracerDic];
    }
    params[kFHClueExtraInfo] = self.extraInfo;
    if (self.houseId.length) {
        params[@"group_id"] = self.houseId;
    }
    if (self.trackingId && self.trackingId.length) {
        params[@"event_tracking_id"] = self.trackingId;
    }
    [FHUserTracker writeEvent:@"go_detail" params:params];
}

-(void)addClickOptionLog:(NSString *)position
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    param[UT_PAGE_TYPE] = self.detailTracerDic[UT_PAGE_TYPE];
    param[UT_ENTER_FROM] = self.detailTracerDic[UT_ENTER_FROM];
    param[UT_ORIGIN_FROM] = self.detailTracerDic[UT_ORIGIN_FROM];
    param[UT_ORIGIN_SEARCH_ID] = self.detailTracerDic[UT_ORIGIN_SEARCH_ID];
    param[UT_LOG_PB] = self.detailTracerDic[UT_LOG_PB];
    
    param[UT_ELEMENT_FROM] = self.detailTracerDic[UT_ELEMENT_FROM]?:UT_BE_NULL;
    
    [param addEntriesFromDictionary:self.detailTracerDic];
    param[@"click_position"] = position;
    
    TRACK_EVENT(@"click_options", param);
}

- (NSDictionary *)subPageParams
{
    NSMutableDictionary *info = @{}.mutableCopy;
    if (self.contactViewModel) {
        info[@"follow_status"] = @(self.contactViewModel.followStatus);
    }
    if (self.contactViewModel.contactPhone) {
        info[@"contact_phone"] = self.contactViewModel.contactPhone;
    }
    if (self.contactViewModel.chooseAgencyList) {
        info[@"choose_agency_list"] = self.contactViewModel.chooseAgencyList;
    }
    info[@"house_type"] = @(FHHouseTypeNewHouse);
    info[@"court_id"] = self.houseId;

    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    [tracerDict addEntriesFromDictionary:self.detailTracerDic];
    info[@"tracer"] = tracerDict;
    return info;
}

- (void)addLeadShowLog:(FHDetailContactModel *)contactPhone
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"event_type"] = @"house_app2c_v2";
    params[@"element_type"] = @"trade_tips";
    params[@"page_type"] = self.detailTracerDic[@"page_type"];
    params[@"card_type"] = self.detailTracerDic[@"card_type"];
    params[@"element_from"] = self.detailTracerDic[@"element_from"];
    params[@"enter_from"] = self.detailTracerDic[@"enter_from"];
    params[@"origin_from"] = self.detailTracerDic[@"origin_from"];
    params[@"origin_search_id"] = self.detailTracerDic[@"origin_search_id"];
    params[@"rank"] = self.detailTracerDic[@"rank"];
    params[@"log_pb"] = self.detailTracerDic[@"log_pb"];
    params[@"click_position"] = @"house_ask_question";
    params[@"is_im"] = contactPhone.imOpenUrl.length ? @"1" : @"0";
    params[@"is_call"] =  @"0";
    params[@"biz_trace"] = contactPhone.bizTrace;
    params[@"is_report"] = @"0";
    params[@"is_online"] = contactPhone.unregistered?@"1":@"0";
    [FHUserTracker writeEvent:@"lead_show" params:params];
}

- (void)addStayPageLog:(NSTimeInterval)stayTime
{
    //    1. event_type ：house_app2c_v2
    //    2. page_type（详情页类型）：rent_detail（租房详情页），old_detail（二手房详情页）
    //    3. card_type（房源展现时的卡片样式）：left_pic（左图）
    //    4. enter_from（详情页入口）：search_related_list（搜索结果推荐）
    //    5. element_from ：search_related
    //    6. rank
    //    7. origin_from
    //    8. origin_search_id
    //    9.log_pb
    //    10.stay_time
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:self.detailTracerDic];
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    params[kFHClueExtraInfo] = self.extraInfo;
    [FHUserTracker writeEvent:@"stay_page" params:params];
    
}

- (BOOL)isMissTitle
{
    FHDetailNewModel *model = (FHDetailNewModel *)self.detailData;
    return model.data.coreInfo.name.length < 1;
}

- (BOOL)isMissImage
{
    FHDetailNewModel *model = (FHDetailNewModel *)self.detailData;
    return model.data.imageGroup.count < 1;
}

- (BOOL)isMissCoreInfo
{
    FHDetailNewModel *model = (FHDetailNewModel *)self.detailData;
    return model.data.coreInfo == nil;
}

// excetionLog
- (void)addDetailCoreInfoExcetionLog
{
    //    detail_core_info_error
    NSMutableDictionary *attr = @{}.mutableCopy;
    NSInteger status = 0;
    if ([self isMissTitle]) {
        attr[@"title"] = @(1);
        attr[@"house_id"] = self.houseId;
        status |= FHDetailCoreInfoErrorTypeTitle;
    }
    if ([self isMissImage]) {
        attr[@"image"] = @(1);
        attr[@"house_id"] = self.houseId;
        status |= FHDetailCoreInfoErrorTypeImage;
    }
    if ([self isMissCoreInfo]) {
        attr[@"core_info"] = @(1);
        attr[@"house_id"] = self.houseId;
        status |= FHDetailCoreInfoErrorTypeCoreInfo;
    }
    attr[@"house_type"] = @(FHHouseTypeNewHouse);
    if (status != 0) {
        [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_core_info_error" status:status extra:attr];
    }
    
}

- (void)addDetailRequestFailedLog:(NSInteger)status message:(NSString *)message
{
    NSMutableDictionary *attr = @{}.mutableCopy;
    attr[@"message"] = message;
    attr[@"house_type"] = @(FHHouseTypeNewHouse);
    attr[@"house_id"] = self.houseId;
    [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_request_failed" status:status extra:attr];
}

- (void)addPageLoadLog {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.firstReloadInterval == 0) {
            self.firstReloadInterval = CFAbsoluteTimeGetCurrent();
        }
        if (self.initTimeInterval > 0 && self.firstReloadInterval > 0) {
            
            double duration = self.firstReloadInterval - self.initTimeInterval;
            //为了避免出现特别大的无效数据 App切换前后台的时候数据大的也不添加
            NSMutableDictionary *metricDict = [NSMutableDictionary dictionary];
            //单位 秒 -> 毫秒
            metricDict[@"total_duration"] = @(duration * 1000);
            
            [[HMDTTMonitor defaultManager] hmdTrackService:@"pss_house_detail_old" metric:metricDict.copy category:@{@"status":@(0)} extra:nil];

        }
        

    });
}

- (FHDetailHalfPopLayer *)popLayer
{
    FHDetailHalfPopLayer *poplayer = [[FHDetailHalfPopLayer alloc] initWithFrame:self.detailController.view.bounds];
    __weak typeof(self) wself = self;
    poplayer.reportBlock = ^(id  _Nonnull data) {
        [wself popLayerReport:data];
    };
    poplayer.feedBack = ^(NSInteger type, id  _Nonnull data, void (^ _Nonnull compltion)(BOOL)) {
        [wself poplayerFeedBack:data type:type completion:compltion];
    };
    poplayer.dismissBlock = ^{
        [wself enableController:YES];
        wself.tableView.scrollsToTop = YES;
    };
    
    [self.detailController.view addSubview:poplayer];
    return poplayer;
}

-(void)popLayerReport:(id)model
{
    NSString *enterFrom = @"be_null";
    if ([model isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        enterFrom = @"official_inspection";
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
        enterFrom = @"happiness_eye";
        FHDetailDataBaseExtraDetectiveModel *detective = (FHDetailDataBaseExtraDetectiveModel *)model;
        if (detective.fromDetail) {
            enterFrom = @"happiness_eye_detail";
        }
    }
    
    NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
    tracerDic[@"enter_from"] = enterFrom;
    tracerDic[@"log_pb"] = self.listLogPB ?: @"be_null";
    [FHUserTracker writeEvent:@"click_feedback" params:tracerDic];
    
    if ([TTAccountManager isLogin]) {
        [self gotoReportVC:model];
    } else {
        [self gotoLogin:model enterFrom:enterFrom];
    }
}

- (void)gotoLogin:(id)model enterFrom:(NSString *)enterFrom
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:enterFrom forKey:@"enter_from"];
    [params setObject:@"feedback" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(NO) forKey:@"need_pop_vc"];
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                [wSelf gotoReportVC:model];
            }
            // 移除登录页面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wSelf delayRemoveLoginVC];
            });
        }
    }];
}

// 二手房-房源问题反馈
- (void)gotoReportVC:(id)model
{
    NSString *reportUrl = nil;
    if ([model isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        reportUrl = [(FHDetailDataBaseExtraOfficialModel *)model dialogs].reportUrl;
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
        reportUrl = [(FHDetailDataBaseExtraDetectiveModel *)model dialogs].reportUrl;
    }
    
    if(reportUrl.length == 0){
        return;
    }
    
    NSDictionary *jsonDic = [self.detailData toDictionary];
    if (jsonDic) {
        
        NSString *openUrl = @"sslocal://webview";
        NSDictionary *pageData = @{@"data":jsonDic};
        NSDictionary *commonParams = [[FHEnvContext sharedInstance] getRequestCommonParams];
        if (commonParams == nil) {
            commonParams = @{};
        }
        NSDictionary *commonParamsData = @{@"data":commonParams};
        NSDictionary *jsParams = @{@"requestPageData":pageData,
                                   @"getNetCommonParams":commonParamsData
                                   };
        NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",host,reportUrl];
        NSDictionary *info = @{@"url":urlStr,@"fhJSParams":jsParams,@"title":@"房源问题反馈"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:userInfo];
    }
}

- (void)delayRemoveLoginVC {
    UINavigationController *navVC = self.detailController.navigationController;
    NSInteger count = navVC.viewControllers.count;
    if (navVC && count >= 2) {
        NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:navVC.viewControllers];
        if (vcs.count == count) {
            [vcs removeObjectAtIndex:count - 2];
            [self.detailController.navigationController setViewControllers:vcs];
        }
    }
}

-(void)poplayerFeedBack:(id)model type:(NSInteger)type completion:(void (^)(BOOL success))completion
{
    if (![TTReachability isNetworkConnected]) {
        SHOW_TOAST(@"网络异常");
        completion(NO);
        return;
    }
    NSString *source = nil;
    NSString *agencyId = nil;
    if ([model isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        source = @"official";
        agencyId = [(FHDetailDataBaseExtraOfficialModel *)model agency].agencyId;
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
        source = @"detective";
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]]){
        source = @"skyeye_price_abnormal";
    }
    
    [FHHouseDetailAPI requstQualityFeedback:self.houseId houseType:FHHouseTypeNewHouse source:source feedBack:type agencyId:agencyId completion:^(bool succss, NSError * _Nonnull error) {
        if (succss) {
            completion(succss);
        }else{
            if (![TTReachability isNetworkConnected]) {
                SHOW_TOAST(@"网络异常");
            }else{
                SHOW_TOAST(error.domain);
            }
            completion(NO);
        }
    } ];
    
}

// 是否弹出ugc表单
- (BOOL)needShowSocialInfoForm:(id)model {
    if (self.weakSocialInfo) {
        // 是否已关注
        BOOL hasFollow = [self.weakSocialInfo.socialGroupInfo.hasFollow boolValue];
        if (hasFollow) {
            return NO;
        }
        
        // 弹窗数据是否为空
        if (self.weakSocialInfo.associateActiveInfo.activeInfo.count <= 0) {
            return NO;
        }
        
        // 当前VC是否在顶部
        __block UIViewController * viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: self.detailController];
        if (viewController == self.detailController) {
            // 房源详情添加了子图片VC为子VC，导致需要特殊处理
            NSArray *tempSubVCs = [viewController childViewControllers];
            if (tempSubVCs.count > 0) {
                [tempSubVCs enumerateObjectsUsingBlock:^(UIViewController *  _Nonnull tempVC, NSUInteger idx, BOOL * _Nonnull stop) {
                    // 图片VC
                    if([tempVC isKindOfClass:[FHDetailPictureViewController class]]) {
                        viewController = tempVC;
                        *stop = YES;
                    }
                }];
            }
        }
        if (viewController != self.detailController) {
            return NO;
        }
        // 可以弹窗
        return YES;
    }
    return NO;
}

// 显示新房UGC填留资弹窗
- (void)showUgcSocialEntrance:(FHDetailNoticeAlertView *)alertView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showSocialEntranceViewWith:alertView];
    });
}

- (void)showSocialEntranceViewWith:(FHDetailNoticeAlertView *)alertView {
    if (self.weakSocialInfo.associateActiveInfo.activeInfo.count <= 0) {
        if (alertView) {
            [alertView dismiss];
            [[ToastManager manager] showToast:@"提交成功，经纪人将尽快与您联系"];
        }
        return;
    }
    BOOL isfromForm = YES;
    if (alertView == nil) {
        isfromForm = NO;
        alertView = [[FHDetailNoticeAlertView alloc] initWithTitle:@"" subtitle:@"" btnTitle:@""];
        [alertView showFrom:self.detailController.view];
    }
    CGFloat width = 280.0;
    if ([UIDevice btd_deviceWidthType] == BTDDeviceWidthMode320) {
        width = 280.0 * [UIScreen mainScreen].bounds.size.width / 375.0f;
    }
    
    NSString *titleText = self.weakSocialInfo.associateActiveInfo.associateContentTitle;
    if (titleText.length <= 0) {
        // 添加默认文案
        NSString *type = self.weakSocialInfo.associateActiveInfo.associateLinkShowType;
        if ([type isEqualToString:@"0"]) {
            // 圈子
            titleText = [NSString stringWithFormat:@"%@人已加入看房圈",self.weakSocialInfo.socialGroupInfo.followerCount];
        } else if ([type isEqualToString:@"1"]) {
            // 群聊
            titleText = [NSString stringWithFormat:@"%ld人已加入看房群",self.weakSocialInfo.socialGroupInfo.chatStatus.currentConversationCount];
        }
    }
    if (isfromForm) {
        titleText = [NSString stringWithFormat:@"提交成功！%@",titleText];
    }
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width - 40, 300)];
    titleLabel.hidden = YES;
    titleLabel.font = [UIFont themeFontMedium:20];
    titleLabel.textColor = [UIColor themeGray1];
    titleLabel.numberOfLines = 0;
    titleLabel.text = titleText;
    CGSize size = [titleLabel sizeThatFits:CGSizeMake(width - 40, 300)];
    
    // 高度计算
    CGFloat height = 40 + size.height + 60;
    NSInteger count = 3;
    if (self.weakSocialInfo.associateActiveInfo.activeInfo.count >= 3) {
        count = 3;
    } else if (self.weakSocialInfo.associateActiveInfo.activeInfo.count > 0) {
        count = self.weakSocialInfo.associateActiveInfo.activeInfo.count;
    } else {
        count = 1;
    }
    CGFloat messageHeight = 20 * 2 + 28 * count + (count - 1) * 5;
    height += messageHeight;
    
    FHDetailSocialEntranceView *v = [[FHDetailSocialEntranceView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    v.backgroundColor = [UIColor themeWhite];
    v.parentView = alertView;
    v.messageHeight = messageHeight;
    v.topTitleHeight = 40 + size.height;
    v.socialInfo = self.weakSocialInfo;
    __weak typeof(self) weakSelf = self;
    v.submitBtnBlock = ^{
        [weakSelf socialEntranceButtonClick];
    };
    v.titleLabel.text = titleText;
    [alertView showAnotherView:v];
    [v startAnimate];
    
    // show 埋点
    NSMutableDictionary *params = @{}.mutableCopy;
    NSDictionary *log_pb = self.detailTracerDic[@"log_pb"];
    NSString *page_type = self.detailTracerDic[@"page_type"];
    if (log_pb) {
        params[@"log_pb"] = log_pb;
    }
    if (page_type) {
        params[@"page_type"] = page_type;
    }
    NSString *type = self.weakSocialInfo.associateActiveInfo.associateLinkShowType;
    if ([type isEqualToString:@"0"]) {
        // 圈子
        params[@"skip_page_type"] = @"community_group";
    } else if ([type isEqualToString:@"1"]) {
        // 群聊
        params[@"skip_page_type"] = @"community_member_talk";
    }
    params[@"tip_type"] = @"community_tip";
    [FHUserTracker writeEvent:@"tip_show" params:params];
}

- (void)socialEntranceButtonClick {
    // click 埋点
    NSMutableDictionary *params = @{}.mutableCopy;
    NSDictionary *log_pb = self.detailTracerDic[@"log_pb"];
    NSString *page_type = self.detailTracerDic[@"page_type"];
    if (log_pb) {
        params[@"log_pb"] = log_pb;
    }
    if (page_type) {
        params[@"page_type"] = page_type;
    }
    NSString *type = self.weakSocialInfo.associateActiveInfo.associateLinkShowType;
    if ([type isEqualToString:@"0"]) {
        // 圈子
        params[@"skip_page_type"] = @"community_group";
    } else if ([type isEqualToString:@"1"]) {
        // 群聊
        params[@"skip_page_type"] = @"community_member_talk";
    }
    params[@"tip_type"] = @"community_tip";
    params[@"click_type"] = @"confirm";
    [FHUserTracker writeEvent:@"tip_click" params:params];
    
    if (self.weakSocialInfo && self.weakSocialInfo.associateActiveInfo) {
        NSString *type = self.weakSocialInfo.associateActiveInfo.associateLinkShowType;
        if ([type isEqualToString:@"0"]) {
            // 圈子
            NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
            if (self.weakSocialInfo) {
                FHHouseNewsSocialModel *socialInfo = (FHHouseNewsSocialModel *)self.weakSocialInfo;
                if (socialInfo.socialGroupInfo && socialInfo.socialGroupInfo.socialGroupId.length > 0) {
                    self.contactViewModel.needRefetchSocialGroupData = YES;
                    NSMutableDictionary *dict = @{}.mutableCopy;
                    NSDictionary *log_pb = tracerDic[@"log_pb"];
                    NSString *group_id = nil;
                    if (log_pb && [log_pb isKindOfClass:[NSDictionary class]]) {
                        group_id = log_pb[@"group_id"];
                    }
                    tracerDic[@"log_pb"] = socialInfo.socialGroupInfo.logPb ? socialInfo.socialGroupInfo.logPb : @"be_null";
                    NSString *page_type = tracerDic[@"page_type"];
                    tracerDic[@"enter_from"] = page_type ?: @"be_null";
                    tracerDic[@"enter_type"] = @"click";
                    tracerDic[@"group_id"] = group_id ?: @"be_null";
                    tracerDic[@"element_from"] = @"community_tip";
                    dict[@"community_id"] = socialInfo.socialGroupInfo.socialGroupId;
                    dict[@"tracer"] = tracerDic;
                    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
                    // 跳转到圈子详情页
                    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
                    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
                }
            }
        } else if ([type isEqualToString:@"1"]) {
            // 群聊
            if (self.contactViewModel) {
                self.contactViewModel.ugcLoginType = FHUGCCommunityLoginTypeTip;
                [self.contactViewModel groupChatAction];
            }
        }
    }
}
@end
