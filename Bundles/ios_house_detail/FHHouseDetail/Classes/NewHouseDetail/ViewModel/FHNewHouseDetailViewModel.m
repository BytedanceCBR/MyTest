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
#import <FHHouseBase/NSObject+FHOptimize.h>

@interface FHNewHouseDetailViewModel ()

@property (nonatomic, strong , nullable) FHListResultHouseModel *relatedHouseData;

@property (nonatomic, weak)     FHHouseNewsSocialModel       *weakSocialInfo;

@end

@implementation FHNewHouseDetailViewModel

// 网络数据请求
- (void)startLoadData {
    // sub implements.........
    // Donothing
    __weak typeof(self) weakSelf = self;
    [FHHouseDetailAPI requestNewDetail:self.houseId logPB:self.listLogPB ridcode:self.ridcode realtorId:self.realtorId extraInfo:self.extraInfo completion:^(FHDetailNewModel * _Nullable model, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([model isKindOfClass:[FHDetailNewModel class]] && !error) {
            if (model.data) {
                strongSelf.isShowEmpty = NO;
                [strongSelf processDetailData:model];
            }else {
                strongSelf.isShowEmpty = YES;
                [strongSelf addDetailRequestFailedLog:model.status.integerValue message:@"empty"];
            }
        }else {
            strongSelf.isShowEmpty = YES;
            [strongSelf addDetailRequestFailedLog:model.status.integerValue message:error.domain];
        }
    }];
}

- (void)processDetailData:(FHDetailNewModel *)model{
    self.detailData = model;
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self addDetailCoreInfoExcetionLog];
        // 清空数据源
        NSMutableArray *sectionModels = [NSMutableArray array];

        //头图
        FHNewHouseDetailHeaderMediaSM *headerMediaSM = [[FHNewHouseDetailHeaderMediaSM alloc] initWithDetailModel:self.detailData];
        [headerMediaSM updateWithContactViewModel:self.contactViewModel];
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
            NSMutableDictionary *paramsDict = @{}.mutableCopy;
            if (self.detailTracerDic) {
                [paramsDict addEntriesFromDictionary:self.detailTracerDic];
            }
            paramsDict[@"page_type"] = [self pageTypeString];
            paramsDict[@"from_gid"] = self.houseId;
            paramsDict[@"element_type"] = @"guide";
            NSString *searchId = self.listLogPB[@"search_id"];
            NSString *imprId = self.listLogPB[@"impr_id"];
            paramsDict[@"search_id"] = searchId.length > 0 ? searchId : @"be_null";
            paramsDict[@"impr_id"] = imprId.length > 0 ? imprId : @"be_null";
            [assessSM updateDetailTracer:paramsDict.copy];
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
            [RGCListModel updateModel:self.detailData];
            [sectionModels addObject:RGCListModel];
        }
    
        if (model.data.surroundingInfo || (model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng)) {
            FHNewHouseDetailSurroundingSM *surroundingSM = [[FHNewHouseDetailSurroundingSM alloc] initWithDetailModel:self.detailData];
            surroundingSM.sectionType = FHNewHouseDetailSectionTypeSurrounding;
            [sectionModels addObject:surroundingSM];
        }
        
        //楼栋信息
        if (model.data.buildingInfo && model.data.buildingInfo.list.count) {
            FHNewHouseDetailBuildingsSM *BuildingSM = [[FHNewHouseDetailBuildingsSM alloc] initWithDetailModel:self.detailData];
            BuildingSM.sectionType = FHNewHouseDetailSectionTypeBuildings;
            [sectionModels addObject:BuildingSM];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sectionModels = [sectionModels btd_filter:^BOOL(id  _Nonnull obj) {
                if (obj && [obj isKindOfClass:[FHNewHouseDetailSectionModel class]]) {
                    return YES;
                }
                return NO;
            }];
            self.firstReloadInterval = CFAbsoluteTimeGetCurrent();
            if (self.updateLayout) {
                self.updateLayout();
            }
        });
        
        __weak typeof(self) weakSelf = self;
        [self executeOnce:^{
            [weakSelf addPageLoadLog];
        } token:FHExecuteOnceUniqueTokenForCurrentContext];
        
        if (!model.isInstantData && model.data) {
            [FHHouseDetailAPI requestRelatedFloorSearch:self.houseId offset:@"0" query:nil count:0 completion:^(FHListResultHouseModel * _Nullable model, NSError * _Nullable error) {
                weakSelf.relatedHouseData = model;
                [weakSelf processDetailRelatedData];
            }];
        }

    });
    
}

// 处理详情页周边新盘请求数据
- (void)processDetailRelatedData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *sectionModels = self.sectionModels.mutableCopy;
        if(self.relatedHouseData.data && self.relatedHouseData.data.items.count > 0)
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
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sectionModels = sectionModels.copy;
        });
    });
}

- (NSString *)pageTypeString {
    return @"new_detail";
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
    params[@"growth_deepevent"] = @(1);
    params[kFHClueExtraInfo] = self.extraInfo;
    if (self.houseId.length) {
        params[@"group_id"] = self.houseId;
    }
    params[@"growth_deepevent"] = @(1);
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
            NSMutableDictionary *metricDict = [NSMutableDictionary dictionary];
            //单位 秒 -> 毫秒
            metricDict[@"total_duration"] = @(duration * 1000);
            [[HMDTTMonitor defaultManager] hmdTrackService:@"pss_new_house_detail" metric:metricDict.copy category:@{@"status":@(0)} extra:nil];
        }
    });
}

@end
