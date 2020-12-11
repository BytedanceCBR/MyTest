//
//  FHNeighborhoodDetailViewModel.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/9.
//

#import "FHNeighborhoodDetailViewModel.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTAccountLogin/TTAccountLoginManager.h>
#import <FHHouseBase/FHEnvContext.h>
#import "FHHouseDetailAPI.h"
#import "TTUIResponderHelper.h"
#import "FHDetailPictureViewController.h"
#import "FHDetailNoticeAlertView.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHNewHouseDetailSectionController.h"
#import "FHNeighborhoodDetailViewController.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"
#import "FHRentSameNeighborhoodResponse.h"
#import "FHNeighborhoodDetailHeaderMediaSC.h"
#import "FHNeighborhoodDetailHeaderMediaSM.h"
#import "FHNeighborhoodDetailCoreInfoSC.h"
#import "FHNeighborhoodDetailCoreInfoSM.h"
#import "FHNeighborhoodDetailFloorpanSC.h"
#import "FHNeighborhoodDetailFloorpanSM.h"
#import "FHNeighborhoodDetailHouseSaleSC.h"
#import "FHNeighborhoodDetailHouseSaleSM.h"
#import "FHNeighborhoodDetailCommentAndQuestionSC.h"
#import "FHNeighborhoodDetailCommentAndQuestionSM.h"
#import "FHHouseSearcher.h"
#import "FHSearchChannelTypes.h"
#import "FHSearchHouseModel.h"
#import "FHNeighborhoodDetailRecommendSM.h"
#import "FHNeighborhoodDetailAgentSM.h"
#import "FHNeighborhoodDetailAgentSC.h"
#import "FHNeighborhoodDetailStrategySC.h"
#import "FHNeighborhoodDetailStrategySM.h"
#import "FHNeighborhoodDetailOwnerSellHouseSC.h"
#import "FHNeighborhoodDetailOwnerSellHouseSM.h"
#import "FHNeighborhoodDetailSurroundingSM.h"
#import <FHHouseBase/NSObject+FHOptimize.h>
#import "FHNeighborhoodDetailBaseInfoSM.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHNeighborhoodDetailSurroundingHouseSM.h"
#import "FHNeighborhoodDetailSurroundingNeighborSM.h"
#import "FHNeighborhoodDetailSurroundingNeighborSC.h"

@interface FHNeighborhoodDetailViewModel ()

@property (nonatomic, strong , nullable) FHDetailRelatedNeighborhoodResponseDataModel *relatedNeighborhoodData;// 周边小区
@property (nonatomic, strong , nullable) FHDetailRelatedHouseResponseDataModel *relatedHouseData; //周边房源
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *sameNeighborhoodErshouHouseData;// 同小区房源，二手房
@property (nonatomic, strong , nullable) FHSearchHouseDataModel *recommendHouseData; //推荐房源，猜你喜欢
@property (nonatomic, copy , nullable) NSString *neighborhoodId;// 周边小区房源id

@end

@implementation FHNeighborhoodDetailViewModel

- (void)startLoadData {
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestNeighborhoodDetail:self.houseId ridcode:self.ridcode realtorId:self.realtorId logPB:self.listLogPB query:nil extraInfo:self.extraInfo completion:^(FHDetailNeighborhoodModel * _Nullable model, NSError * _Nullable error) {
        if (model && error == NULL) {
            if (model.data) {
                [wSelf processDetailData:model];
                wSelf.detailController.hasValidateData = YES;
                [wSelf.detailController.emptyView hideEmptyView];
                wSelf.bottomBar.hidden = NO;
                NSString *neighborhoodId = model.data.neighborhoodInfo.id;
                [wSelf.navBar showMessageNumber];
                wSelf.neighborhoodId = neighborhoodId;
                // 周边数据请求

            } else {
                wSelf.detailController.isLoadingData = NO;
                wSelf.detailController.hasValidateData = NO;
                wSelf.bottomBar.hidden = YES;
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                [wSelf addDetailRequestFailedLog:model.status.integerValue message:@"empty"];
            }
        } else {
//            if (wSelf.detailController.instantData) {
//                SHOW_TOAST(@"请求失败");
//            }else{
                wSelf.detailController.isLoadingData = NO;
                wSelf.detailController.hasValidateData = NO;
                wSelf.bottomBar.hidden = YES;
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                [wSelf addDetailRequestFailedLog:model.status.integerValue message:error.domain];
//            }
        }
    }];
}

// 处理详情页数据
- (void)processDetailData:(FHDetailNeighborhoodModel *)model {
    self.detailData = model;
    self.contactViewModel.shareInfo = model.data.shareInfo;
    self.contactViewModel.followStatus = model.data.neighbordhoodStatus.neighborhoodSubStatus;


    FHDetailContactModel *contactPhone = nil;
    if (model.data.highlightedRealtor) {
        contactPhone = model.data.highlightedRealtor;
    } else {
        contactPhone = model.data.contact;
        contactPhone.unregistered = YES;
    }
    contactPhone.isInstantData = model.isInstantData;
    contactPhone.isFormReport = !contactPhone.enablePhone;
    self.contactViewModel.contactPhone = contactPhone;
    self.contactViewModel.shareInfo = model.data.shareInfo;
//    self.contactViewModel.followStatus = model.data.userStatus.houseSubStatus;
    self.contactViewModel.chooseAgencyList = model.data.chooseAgencyList;
    self.contactViewModel.highlightedRealtorAssociateInfo = model.data.highlightedRealtorAssociateInfo;

    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self addDetailCoreInfoExcetionLog];
        NSMutableArray *sectionModels = [NSMutableArray array];

        FHNeighborhoodDetailHeaderMediaSM *headerMediaSM = [[FHNeighborhoodDetailHeaderMediaSM alloc] initWithDetailModel:self.detailData];

        [headerMediaSM updateWithContactViewModel:self.contactViewModel];
        headerMediaSM.sectionType = FHNeighborhoodDetailSectionTypeHeader;
        [sectionModels addObject:headerMediaSM];

        if (model.data.name.length ||
            model.data.neighborhoodInfo.address.length ||
            model.data.neighborhoodInfo.id.length > 0 ||
            model.data.baseInfo.count > 0 ||
            ((model.data.neighborhoodInfo.gaodeLat.length > 0 && model.data.neighborhoodInfo.gaodeLng.length > 0 )|| model.data.neighborhoodInfo.baiduPanoramaUrl.length > 0)
            ) {
            FHNeighborhoodDetailCoreInfoSM *coreInfoSM = [[FHNeighborhoodDetailCoreInfoSM alloc] initWithDetailModel:self.detailData];
            
            coreInfoSM.sectionType = FHNeighborhoodDetailSectionTypeCoreInfo;
            [sectionModels addObject:coreInfoSM];
        }

        //小区测评
        if (model.data.strategy.articleList.count > 0) {
            FHNeighborhoodDetailStrategySM *strategyModel = [[FHNeighborhoodDetailStrategySM alloc] initWithDetailModel:self.detailData];
            strategyModel.sectionType = FHNeighborhoodDetailSectionTypeStrategy;
            strategyModel.detailTracerDic = self.detailTracerDic;
            NSString *searchId = self.listLogPB[@"search_id"];
            NSString *imprId = self.listLogPB[@"impr_id"];
            NSDictionary *extraDic = @{
                @"searchId":searchId?:@"be_null",
                @"imprId":imprId?:@"be_null",
                @"houseId":self.houseId,
                @"houseType":@(FHHouseTypeNeighborhood),
                @"channelId":@"f_hosue_wtt"
            };
            strategyModel.extraDic = extraDic;
            [strategyModel updateDetailModel:self.detailData];
            [sectionModels addObject:strategyModel];
        }

        //小区点评和问答
        if (model.data.comments.content.data.count > 0 || model.data.question) {
            FHNeighborhoodDetailCommentAndQuestionSM *commentAndQuestionModel = [[FHNeighborhoodDetailCommentAndQuestionSM alloc] initWithDetailModel:self.detailData];
            commentAndQuestionModel.sectionType = FHNeighborhoodDetailSectionTypeCommentAndQuestion;
            commentAndQuestionModel.detailTracerDic = self.detailTracerDic;
            NSString *searchId = self.listLogPB[@"search_id"];
            NSString *imprId = self.listLogPB[@"impr_id"];
            NSDictionary *extraDic = @{
                @"searchId":searchId?:@"be_null",
                @"imprId":imprId?:@"be_null",
                @"houseId":self.houseId,
                @"houseType":@(FHHouseTypeNeighborhood),
                @"channelId":@"f_hosue_wtt"
            };
            commentAndQuestionModel.extraDic = extraDic;
            [commentAndQuestionModel updateDetailModel:self.detailData];
            [sectionModels addObject:commentAndQuestionModel];
        }
        __weak typeof(self) weakSelf = self;
        //小区户型
        if(model.data.neighborhoodSaleHouseInfo.neighborhoodSaleHouseList.count) {
            FHNeighborhoodDetailFloorpanSM *floorpanSM = [[FHNeighborhoodDetailFloorpanSM alloc] initWithDetailModel:self.detailData];
            [floorpanSM updateWithDataModel:model.data.neighborhoodSaleHouseInfo];
            floorpanSM.sectionType = FHNeighborhoodDetailSectionTypeFloorpan;
            [sectionModels addObject:floorpanSM];
        }
        //经纪人
        if (model.data.recommendedRealtors.count > 0) {
            FHNeighborhoodDetailAgentSM *agentSM = [[FHNeighborhoodDetailAgentSM alloc] initWithDetailModel:self.detailData];
            agentSM.sectionType = FHNeighborhoodDetailSectionTypeAgent;
            [sectionModels addObject:agentSM];
        }
        
        //小区基本信息
        if (model.data.baseInfo.count) {
            FHNeighborhoodDetailBaseInfoSM *baseInfoSM = [[FHNeighborhoodDetailBaseInfoSM alloc] initWithDetailModel:self.detailData];
            baseInfoSM.sectionType = FHNeighborhoodDetailSectionTypeBaseInfo;
            [sectionModels addObject:baseInfoSM];
        }

        //周边 地图+均价走势
        if ((model.data.neighborhoodInfo.gaodeLat.length && model.data.neighborhoodInfo.gaodeLng.length)) {
            FHNeighborhoodDetailSurroundingSM *surroundingSM = [[FHNeighborhoodDetailSurroundingSM alloc] initWithDetailModel:self.detailData];
            surroundingSM.sectionType = FHNeighborhoodDetailSectionTypeSurrounding;
            [sectionModels addObject:surroundingSM];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sectionModels = [self formattSectionModels:sectionModels.copy];
            self.firstReloadInterval = CFAbsoluteTimeGetCurrent();
        });
        
        if (!model.isInstantData && model.data) {
            [weakSelf requestRelatedData:model.data.neighborhoodInfo.id];
        }
    });

    
    [self.detailController updateLayout:model.isInstantData];
}

// 周边数据请求，当网络请求都返回后刷新数据
- (void)requestRelatedData:(NSString *)neighborhoodId {
    if (neighborhoodId.length < 1) {
        return;
    }
    dispatch_queue_t relateQueue = dispatch_queue_create("requestRelatedDataNeighborhood", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t relateGroup = dispatch_group_create();

    // 同小区房源-二手房
    dispatch_group_enter(relateGroup);
    dispatch_async(relateQueue, ^{
        [self requestHouseInSameNeighborhoodSearchErShou:neighborhoodId completion:^{
             dispatch_group_leave(relateGroup);
        }];
        
    });
    
    //周边房源-二手房
    dispatch_group_enter(relateGroup);
    dispatch_async(relateQueue, ^{
        [self requestRelatedHouseSearch:neighborhoodId completion:^{
             dispatch_group_leave(relateGroup);
        }];
        
    });
    
    //周边小区
    dispatch_group_enter(relateGroup);
    dispatch_async(relateQueue, ^{
        [self requestRelatedNeighborhoodSearch:neighborhoodId completion:^{
             dispatch_group_leave(relateGroup);
        }];
        
    });
    
    dispatch_group_enter(relateGroup);
    dispatch_async(relateQueue, ^{
        //推荐房源-二手房
        [self requestHouseInRecommendHouse:neighborhoodId completion:^{
            dispatch_group_leave(relateGroup);
        }];
       
    });

    
    dispatch_group_notify(relateGroup, relateQueue, ^{
        [self processDetailRelatedData];
    });
    
}

// 处理详情页周边请求数据
- (void)processDetailRelatedData {
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.detailController.isLoadingData = NO;
        NSMutableArray *sectionModels = self.sectionModels.mutableCopy;
        
        //在售房源
        if (self.sameNeighborhoodErshouHouseData.items.count > 0) {
            FHNeighborhoodDetailHouseSaleSM *houseSaleSM = [[FHNeighborhoodDetailHouseSaleSM alloc] initWithDetailModel:self.detailData];
            [houseSaleSM updateWithDataModel:self.sameNeighborhoodErshouHouseData];
            houseSaleSM.sectionType = FHNeighborhoodDetailSectionTypeHouseSale;
            [sectionModels addObject:houseSaleSM];
        }
        // 周边小区
        if (self.relatedNeighborhoodData && self.relatedNeighborhoodData.items.count > 0) {
            FHNeighborhoodDetailSurroundingNeighborSM *surroundingNeighborSM = [[FHNeighborhoodDetailSurroundingNeighborSM alloc] initWithDetailModel:self.detailData];
            [surroundingNeighborSM updateWithDataModel:self.relatedNeighborhoodData];
            surroundingNeighborSM.sectionType = FHNeighborhoodDetailSectionTypeSurroundingNeighbor;
            [sectionModels addObject:surroundingNeighborSM];
        }
        //猜你喜欢
        if (self.recommendHouseData.items.count > 0) {
            FHNeighborhoodDetailRecommendSM *recommendSM = [[FHNeighborhoodDetailRecommendSM alloc] initWithDetailModel:self.detailData];
            [recommendSM updateWithDataModel:self.recommendHouseData];
            recommendSM.sectionType = FHNeighborhoodDetailSectionTypeRecommend;
            [sectionModels addObject:recommendSM];
        }
        //周边房源
        if (self.relatedHouseData.items.count > 0) {
            FHNeighborhoodDetailSurroundingHouseSM *SM = [[FHNeighborhoodDetailSurroundingHouseSM alloc] initWithDetailModel:self.detailData];
            [SM updateWithDataModel:self.relatedHouseData];
            SM.sectionType = FHNeighborhoodDetailSectionTypeSurroundingHouse;
            [sectionModels addObject:SM];
        }
        
        
        
        FHDetailNeighborhoodModel *model = self.detailData;
        FHDetailNeighborhoodSaleHouseEntranceModel *saleHouseEntrance = model.data.saleHouseEntrance;
        if(saleHouseEntrance.title.length > 0 && saleHouseEntrance.subtitle.length > 0 && saleHouseEntrance.buttonText.length > 0 && saleHouseEntrance.openUrl.length > 0) {
            FHNeighborhoodDetailOwnerSellHouseSM *ownerSellHouseSM = [[FHNeighborhoodDetailOwnerSellHouseSM alloc] initWithDetailModel:self.detailData];
            ownerSellHouseSM.sectionType = FHNeighborhoodDetailSectionTypeOwnerSellHouse;
            
            [sectionModels addObject:ownerSellHouseSM];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sectionModels = [self formattSectionModels:sectionModels.copy];
        });
        __weak typeof(self) weakSelf = self;
        [self executeOnce:^{
            [weakSelf addPageLoadLog];
        } token:FHExecuteOnceUniqueTokenForCurrentContext];
    });
    
}

- (NSArray *)formattSectionModels:(NSArray *)sectionModels {
    return [[sectionModels btd_filter:^BOOL(id  _Nonnull obj) {
        if (obj && [obj isKindOfClass:[FHNeighborhoodDetailSectionModel class]]) {
            return YES;
        }
        return NO;
    }] sortedArrayUsingComparator:^NSComparisonResult(FHNeighborhoodDetailSectionModel * _Nonnull obj1,FHNeighborhoodDetailSectionModel *  _Nonnull obj2) {
        // 因为满足sortedArrayUsingComparator方法的默认排序顺序，则不需要交换
        if ([obj1 sectionType] < [obj2 sectionType]) return NSOrderedAscending;
        return NSOrderedDescending;
    }];
}

// 推荐房源
- (void)requestHouseInRecommendHouse:(NSString *)neighborhoodId completion:(void (^)(void))completion{
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSMutableString *query = [[NSMutableString alloc] init];
    [query appendFormat:@"%@=%@",HOUSE_TYPE_KEY,@(FHHouseTypeSecondHandHouse)];
    param[@"neighborhood_id[]"] = neighborhoodId;
    query = [NSMutableString stringWithFormat:@"%@&%@=%@",query,CHANNEL_ID,CHANNEL_ID_NEIGHBORHOOD_RECOMMEND_HOUSE];
    __weak typeof(self) wSelf = self;
    [FHHouseSearcher houseSearchWithQuery:query param:param offset:0 class:[FHSearchHouseModel class] needCommonParams:YES callback:^(NSError * _Nullable error, id<FHBaseModelProtocol>  _Nullable model) {
        wSelf.recommendHouseData = ((FHSearchHouseModel *)model).data;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

// 同小区房源-二手房
- (void)requestHouseInSameNeighborhoodSearchErShou:(NSString *)neighborhoodId completion:(void (^)(void))completion{
    NSString *houseId = self.houseId;
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestHouseInSameNeighborhoodSearchByNeighborhoodId:neighborhoodId houseId:houseId searchId:nil offset:@"0" query:nil count:3 completion:^(FHDetailSameNeighborhoodHouseResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.sameNeighborhoodErshouHouseData = model.data;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
        
    }];
}

// 周边房源
- (void)requestRelatedHouseSearch:(NSString *)neighborhoodId completion:(void (^)(void))completion {
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestRelatedHouseSearch:nil neighborhoodId:neighborhoodId searchId:nil offset:@"0" query:nil count:3 completion:^(FHDetailRelatedHouseResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.relatedHouseData = model.data;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

// 周边小区
- (void)requestRelatedNeighborhoodSearch:(NSString *)neighborhoodId completion:(void (^)(void))completion{
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestRelatedNeighborhoodSearchByNeighborhoodId:neighborhoodId searchId:nil offset:@"0" query:nil count:5 completion:^(FHDetailRelatedNeighborhoodResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.relatedNeighborhoodData = model.data;
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}


- (NSString *)pageTypeString {
    return @"neighborhood_detail";
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
    info[@"house_type"] = @(self.houseType);
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


- (BOOL)isMissImage
{
    return NO;
}
- (BOOL)isMissTitle
{
    FHDetailNeighborhoodModel *model = (FHDetailNeighborhoodModel *)self.detailData;
    return model.data.neighborhoodInfo.name.length < 1;
}


- (BOOL)isMissCoreInfo
{
    // 小区详情页不必判断信息缺失
    return NO;
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
    attr[@"house_type"] = @(self.houseType);
    if (status != 0) {
        [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_core_info_error" status:status extra:attr];
    }
    
}

- (void)addDetailRequestFailedLog:(NSInteger)status message:(NSString *)message
{
    NSMutableDictionary *attr = @{}.mutableCopy;
    attr[@"message"] = message;
    attr[@"house_type"] = @(self.houseType);
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
            [[HMDTTMonitor defaultManager] hmdTrackService:@"pss_neighborhood_detail" metric:metricDict.copy category:@{@"status":@(0)} extra:nil];
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

@end
