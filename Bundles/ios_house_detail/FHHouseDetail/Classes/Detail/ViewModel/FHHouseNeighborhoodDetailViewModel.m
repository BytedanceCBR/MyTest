//
//  FHHouseNeighborhoodDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseNeighborhoodDetailViewModel.h"
#import "FHDetailBaseCell.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailPhotoHeaderCell.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHNeighborhoodDetailSubMessageCell.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHRentSameNeighborhoodResponse.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"
#import "FHDetailNeighborPriceChartCell.h"
#import "FHDetailNeighborhoodNameCell.h"
#import "FHDetailGrayLineCell.h"
#import "FHDetailNeighborhoodStatsInfoCell.h"
#import "FHDetailNeighborhoodPropertyInfoCell.h"
#import "FHDetailRelatedNeighborhoodCell.h"
#import "FHDetailNeighborhoodHouseCell.h"
#import "FHDetailNeighborhoodTransationHistoryCell.h"
#import "FHDetailNeighborhoodEvaluateCell.h"
#import "FHDetailNearbyMapCell.h"
#import "FHDetailNewModel.h"
#import "FHDetailPureTitleCell.h"
#import "FHDetailCommunityEntryCell.h"
#import "FHDetailBlankLineCell.h"
#import "FHDetailAgentListCell.h"
#import "FHDetailStaticMapCell.h"
#import "FHOldDetailPhotoHeaderCell.h"
#import "FHDetailMediaHeaderCorrectingCell.h"
#import "HMDTTMonitor.h"
#import <FHHouseBase/FHHouseNeighborModel.h>
#import <FHHouseBase/FHHomeHouseModel.h>
#import <FHDetailMediaHeaderCell.h>
#import "FHNeighborhoodDetailModuleHelper.h"
#import "FHDetailNeighborhoodQACell.h"
#import "FHDetailQACellModel.h"
#import "TTDeviceHelper.h"

@interface FHHouseNeighborhoodDetailViewModel ()

@property (nonatomic, assign)   NSInteger       requestRelatedCount;
@property (nonatomic, strong , nullable) FHDetailRelatedNeighborhoodResponseDataModel *relatedNeighborhoodData;// 周边小区
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *sameNeighborhoodErshouHouseData;// 同小区房源，二手房
@property (nonatomic, strong , nullable) FHRentSameNeighborhoodResponseDataModel *sameNeighborhoodRentHouseData;// 同小区房源，租房
@property (nonatomic, copy , nullable) NSString *neighborhoodId;// 周边小区房源id


@end

@implementation FHHouseNeighborhoodDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    [self.tableView registerClass:[FHOldDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderModel class])];
    [self.tableView registerClass:[FHDetailMediaHeaderCorrectingCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailMediaHeaderCorrectingModel class])];
    [self.tableView registerClass:[FHDetailNeighborPriceChartCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPriceTrendCellModel class])];
//    [self.tableView registerClass:[FHDetailNeighborhoodNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodNameModel class])];
    [self.tableView registerClass:[FHNeighborhoodDetailSubMessageCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodSubMessageModel class])];
    [self.tableView registerClass:[FHDetailNearbyMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNearbyMapModel class])];
    [self.tableView registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineModel class])];
    [self.tableView registerClass:[FHDetailNeighborhoodStatsInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodStatsInfoModel class])];
    [self.tableView registerClass:[FHDetailNeighborhoodPropertyInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodPropertyInfoModel class])];
    [self.tableView registerClass:[FHDetailRelatedNeighborhoodCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRelatedNeighborhoodModel class])];
    [self.tableView registerClass:[FHDetailNeighborhoodHouseCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodHouseModel class])];
    [self.tableView registerClass:[FHDetailNeighborhoodTransationHistoryCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodTransationHistoryModel class])];
    [self.tableView registerClass:[FHDetailNeighborhoodEvaluateCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodEvaluateModel class])];
    [self.tableView registerClass:[FHDetailPureTitleCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPureTitleModel class])];
    [self.tableView registerClass:[FHDetailCommunityEntryCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailCommunityEntryModel class])];
    [self.tableView registerClass:[FHDetailBlankLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailBlankLineModel class])];
    [self.tableView registerClass:[FHDetailAgentListCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAgentListModel class])];
    [self.tableView registerClass:[FHDetailStaticMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailStaticMapCellModel class])];
    [self.tableView registerClass:[FHDetailNeighborhoodQACell class] forCellReuseIdentifier:NSStringFromClass([FHDetailQACellModel class])];

}

// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}
// 网络数据请求
- (void)startLoadData {    
    // 详情页数据-Main
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestNeighborhoodDetail:self.houseId logPB:self.listLogPB query:nil completion:^(FHDetailNeighborhoodModel * _Nullable model, NSError * _Nullable error) {
        if (model && error == NULL) {
            if (model.data) {
                [wSelf processDetailData:model];
                wSelf.detailController.hasValidateData = YES;
                [wSelf.detailController.emptyView hideEmptyView];
                wSelf.bottomBar.hidden = NO;
                NSString *neighborhoodId = model.data.neighborhoodInfo.id;
                wSelf.neighborhoodId = neighborhoodId;
                // 周边数据请求
                [wSelf requestRelatedData:neighborhoodId];
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


-(NSArray *)instantHouseImages
{
    id data = self.detailController.instantData;
    if ([data isKindOfClass:[FHHomeHouseDataItemsModel class]]) {
        
        FHHomeHouseDataItemsModel *item = (FHHomeHouseDataItemsModel *)data;
        return item.houseImage;
        
    }else if ([data isKindOfClass:[FHHouseNeighborDataItemsModel class]]){
        FHHouseNeighborDataItemsModel *item = (FHHouseNeighborDataItemsModel *)data;
        return item.images;
    }
    return nil;
}

-(BOOL)currentIsInstantData
{
    return [(FHDetailNeighborhoodModel *)self.detailData isInstantData];
}

// 处理详情页数据
- (void)processDetailData:(FHDetailNeighborhoodModel *)model {
    
    self.contactViewModel.shareInfo = model.data.shareInfo;
    self.contactViewModel.followStatus = model.data.neighbordhoodStatus.neighborhoodSubStatus;

//    [self.contactViewModel generateImParams:self.houseId houseTitle:model.data.title houseCover:imgUrl houseType:houseType  houseDes:houseDes housePrice:price houseAvgPrice:avgPrice];

    FHDetailContactModel *contactPhone = nil;
    if (model.data.highlightedRealtor) {
        contactPhone = model.data.highlightedRealtor;
    } else {
        contactPhone = model.data.contact;
        contactPhone.unregistered = YES;
    }
    contactPhone.isInstantData = model.isInstantData;

    if (contactPhone.phone.length > 0) {
        contactPhone.isFormReport = NO;
    }else {
        contactPhone.isFormReport = YES;
    }
    self.contactViewModel.contactPhone = contactPhone;
    self.contactViewModel.shareInfo = model.data.shareInfo;
//    self.contactViewModel.followStatus = model.data.userStatus.houseSubStatus;
    self.contactViewModel.chooseAgencyList = model.data.chooseAgencyList;



    self.detailData = model;
    [self addDetailCoreInfoExcetionLog];

    // 清空数据源
    [self.items removeAllObjects];
    
    BOOL hasVideo = NO;
    BOOL isInstant = model.isInstantData;
    if (model.data.neighborhoodVideo && model.data.neighborhoodVideo.videoInfos.count > 0) {
        hasVideo = YES;
    }
    FHDetailNeighborhoodSubMessageModel *neighborhoodInfoModel = [[FHDetailNeighborhoodSubMessageModel alloc] init];
    neighborhoodInfoModel.name = model.data.name;
    neighborhoodInfoModel.neighborhoodInfo = model.data.neighborhoodInfo;
    
    if (hasVideo) {
        
        FHVideoHouseVideoVideoInfosModel *info = model.data.neighborhoodVideo.videoInfos[0];
        FHMultiMediaItemModel * itemModel = [[FHMultiMediaItemModel alloc] init];
        itemModel.cellHouseType = FHMultiMediaCellHouseNeiborhood;
        itemModel.mediaType = FHMultiMediaTypeVideo;
        itemModel.videoID = info.vid;
        itemModel.imageUrl = info.coverImageUrl;
        itemModel.vWidth = info.vWidth;
        itemModel.vHeight = info.vHeight;
        itemModel.infoTitle = model.data.neighborhoodVideo.infoTitle;
        itemModel.infoSubTitle = model.data.neighborhoodVideo.infoSubTitle;
        itemModel.groupType = @"视频";
        
        
        FHDetailMediaHeaderCorrectingModel *headerCellModel = [[FHDetailMediaHeaderCorrectingModel alloc] init];
        FHDetailOldDataHouseImageDictListModel *houseImageDictList = [[FHDetailOldDataHouseImageDictListModel alloc] init];
        
        if ([model.data.neighborhoodImage isKindOfClass:[NSArray class]] && model.data.neighborhoodImage.count > 0) {
            houseImageDictList.houseImageList = model.data.neighborhoodImage;
            houseImageDictList.houseImageTypeName = @"图片";
            if ([houseImageDictList isKindOfClass:[FHDetailOldDataHouseImageDictListModel class]]) {
                headerCellModel.houseImageDictList = @[houseImageDictList];
            }
            if (!isInstant) {
                FHDetailOldDataHouseImageDictListModel *imgModel = [headerCellModel.houseImageDictList firstObject];
                imgModel.instantHouseImageList = [self instantHouseImages];
            }
        }
        FHDetailHouseTitleModel *houseTitleModel = [[FHDetailHouseTitleModel alloc] init];
        houseTitleModel.titleStr = model.data.name;
        __weak typeof(self)weakself = self;
        houseTitleModel.mapImageClick = ^{
            [weakself mapImageClick];
        };
        houseTitleModel.address = model.data.neighborhoodInfo.address;
//        houseTitleModel.tags = model.data.tags;
        headerCellModel.vedioModel = itemModel;// 添加视频模型数据
        headerCellModel.titleDataModel = houseTitleModel;
        headerCellModel.contactViewModel = self.contactViewModel;
        headerCellModel.isInstantData = model.isInstantData;
        houseTitleModel.neighborhoodInfoModel = neighborhoodInfoModel;
        [self.items addObject:headerCellModel];
    }else {
        // 添加头滑动图片
        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
        if (model.data.neighborhoodImage.count > 0) {
            headerCellModel.houseImage = model.data.neighborhoodImage;
            if (!model.isInstantData) {
                headerCellModel.instantHouseImages =  [self instantHouseImages];
            }
            FHDetailHouseTitleModel *houseTitleModel = [[FHDetailHouseTitleModel alloc] init];
            houseTitleModel.titleStr = model.data.name;
            houseTitleModel.address = model.data.neighborhoodInfo.address;
            houseTitleModel.neighborhoodInfoModel = neighborhoodInfoModel;
            __weak typeof(self)weakself = self;
            houseTitleModel.mapImageClick = ^{
                [weakself mapImageClick];
            };
//            houseTitleModel.tags = model.data.tags;
            headerCellModel.titleDataModel = houseTitleModel;
            headerCellModel.isInstantData = model.isInstantData;
        }else{
            //无图片时增加默认图
            FHImageModel *imgModel = [FHImageModel new];
            headerCellModel.houseImage = @[imgModel];
        }
        [self.items addObject:headerCellModel];
    }

    
    // 添加标题
    if (model.data && model.data.neighborhoodInfo.id.length > 0) {
        FHDetailNeighborhoodSubMessageModel *houseinfo = [[FHDetailNeighborhoodSubMessageModel alloc] init];
        houseinfo.houseModelType = FHPlotHouseModelTypeCoreInfo;
        houseinfo.neighborhoodInfo = model.data.neighborhoodInfo;
        [self.items addObject:houseinfo];
    }
    // 添加 在售（在租）信息
    if (model.data.statsInfo.count == 3) {
        FHDetailNeighborhoodStatsInfoModel *infoModel = [[FHDetailNeighborhoodStatsInfoModel alloc] init];
        infoModel.houseModelType = FHPlotHouseModelTypeCoreInfo;
        infoModel.showBottomLine = ! model.data.baseInfo.count > 0;
        infoModel.statsInfo = model.data.statsInfo;
        [self.items addObject:infoModel];
    }



    // 属性列表
    if (model.data.baseInfo.count > 0) {
        FHDetailNeighborhoodPropertyInfoModel *infoModel = [[FHDetailNeighborhoodPropertyInfoModel alloc] init];
        infoModel.houseModelType = FHPlotHouseModelTypeCoreInfo;
        infoModel.tableView = self.tableView;
        infoModel.baseInfo = model.data.baseInfo;
        [self.items addObject:infoModel];
    }
    
    //ugc 圈子入口
    BOOL showUgcEntry = model.data.ugcSocialGroup && model.data.ugcSocialGroup.activeCountInfo && model.data.ugcSocialGroup.activeInfo.count > 0;
    if(showUgcEntry){
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        model.data.ugcSocialGroup.houseType = FHHouseTypeNeighborhood;
        [self.items addObject:model.data.ugcSocialGroup];
    }
    // 小区评测
    if (model.data.evaluationInfo) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailNeighborhoodEvaluateModel *infoModel = [[FHDetailNeighborhoodEvaluateModel alloc] init];
        infoModel.log_pb = self.listLogPB; // listLogPB也是当前小区的logPb
        infoModel.evaluationInfo = model.data.evaluationInfo;
        [self.items addObject:infoModel];
    }

    //地图
    if(model.data.neighborhoodInfo.gaodeLat.length > 0 && model.data.neighborhoodInfo.gaodeLng.length > 0){
        FHDetailStaticMapCellModel *staticMapModel = [[FHDetailStaticMapCellModel alloc] init];
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];

        staticMapModel.mapCentertitle = model.data.neighborhoodInfo.name;
        staticMapModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
        staticMapModel.gaodeLng = model.data.neighborhoodInfo.gaodeLng;
        staticMapModel.houseId = model.data.neighborhoodInfo.id;
        staticMapModel.houseType = [NSString stringWithFormat:@"%d",FHHouseTypeNeighborhood];
        staticMapModel.title = model.data.neighborhoodInfo.name;
        staticMapModel.tableView = self.tableView;
        staticMapModel.staticImage = model.data.neighborhoodInfo.gaodeImage;
        staticMapModel.mapOnly = NO;
        [self.items addObject:staticMapModel];
    } else{
        NSString *eventName = @"detail_map_location_failed";
        NSDictionary *cat = @{@"status": @(1)};

        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
        [params setValue:@"经纬度缺失" forKey:@"reason"];
        [params setValue:model.data.neighborhoodInfo.id forKey:@"house_id"];
        [params setValue:@(FHHouseTypeNeighborhood) forKey:@"house_type"];
        [params setValue:model.data.neighborhoodInfo.name forKey:@"name"];

        [[HMDTTMonitor defaultManager] hmdTrackService:eventName metric:nil category:cat extra:params];
    }

    // 周边配套
//    if (model.data.neighborhoodInfo.gaodeLat && model.data.neighborhoodInfo.gaodeLng) {
//        // 添加分割线--当存在某个数据的时候在顶部添加分割线
//        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
//        [self.items addObject:grayLine];
//
//        FHDetailNearbyMapModel *nearbyMapModel = [[FHDetailNearbyMapModel alloc] init];
//        nearbyMapModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
//        nearbyMapModel.gaodeLng = model.data.neighborhoodInfo.gaodeLng;
//        nearbyMapModel.title = model.data.neighborhoodInfo.name;
//        //        nearbyMapModel.tableView = self.tableView;
//
//
//        if (!model.data.neighborhoodInfo.gaodeLat || !model.data.neighborhoodInfo.gaodeLng) {
//            NSMutableDictionary *params = [NSMutableDictionary new];
//            [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
//            [params setValue:@"经纬度缺失" forKey:@"reason"];
//            [params setValue:model.data.neighborhoodInfo.id forKey:@"house_id"];
//            [params setValue:@(4) forKey:@"house_type"];
//            [params setValue:model.data.neighborhoodInfo.name forKey:@"name"];
//            [[HMDTTMonitor defaultManager] hmdTrackService:@"detail_map_location_failed" attributes:params];
//        }
//
//
//        [self.items addObject:nearbyMapModel];
//
//        __weak typeof(self) wSelf = self;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if ((FHDetailNearbyMapCell *)nearbyMapModel.cell) {
//                ((FHDetailNearbyMapCell *)nearbyMapModel.cell).indexChangeCallBack = ^{
//                    [self reloadData];
//                };
//            }
//        });
//    }
    // 均价走势
    if (model.data.priceTrend.count > 0) {
        
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailPureTitleModel *titleModel = [[FHDetailPureTitleModel alloc] init];
        titleModel.title = @"均价走势";
        [self.items addObject:titleModel];
        FHDetailPriceTrendCellModel *priceTrendModel = [[FHDetailPriceTrendCellModel alloc] init];
        priceTrendModel.priceTrends = model.data.priceTrend;
        priceTrendModel.tableView = self.tableView;
        [self.items addObject:priceTrendModel];
    }
    
    // 小区问答
    if (model.data.question) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailQACellModel *qaModel = [[FHDetailQACellModel alloc] init];
//        [qaModel fakeData];
        qaModel.question = model.data.question;
        [self.items addObject:qaModel];
    }
    
    // 小区成交历史
    if (model.data.totalSales.list.count > 0) {
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailNeighborhoodTransationHistoryModel *infoModel = [[FHDetailNeighborhoodTransationHistoryModel alloc] init];
        infoModel.totalSalesCount = model.data.totalSalesCount;
        infoModel.totalSales = model.data.totalSales;
        infoModel.neighborhoodId = self.houseId;
        [self.items addObject:infoModel];
    }

    // 推荐经纪人
    if (model.data.recommendedRealtors.count > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailAgentListModel *agentListModel = [[FHDetailAgentListModel alloc] init];
        NSString *searchId = self.listLogPB[@"search_id"];
        NSString *imprId = self.listLogPB[@"impr_id"];
        agentListModel.tableView = self.tableView;
        agentListModel.belongsVC = self.detailController;
        agentListModel.recommendedRealtorsTitle = model.data.recommendedRealtorsTitle;
        agentListModel.recommendedRealtors = model.data.recommendedRealtors;

        /******* 这里的 逻辑   ********/
        agentListModel.phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeNeighborhood houseId:self.houseId];
//        [agentListModel.phoneCallViewModel generateImParams:self.houseId houseTitle:model.data.title :imgUrl houseType:houseType  houseDes:houseDes housePrice:price houseAvgPrice:avgPrice];
        NSMutableDictionary *paramsDict = @{}.mutableCopy;
        if (self.detailTracerDic) {
            [paramsDict addEntriesFromDictionary:self.detailTracerDic];
        }
        paramsDict[@"page_type"] = [self pageTypeString];
        agentListModel.phoneCallViewModel.tracerDict = paramsDict;
//        agentListModel.phoneCallViewModel.followUpViewModel = self.contactViewModel.followUpViewModel;
//        agentListModel.phoneCallViewModel.followUpViewModel.tracerDict = self.detailTracerDic;
        agentListModel.searchId = searchId;
        agentListModel.imprId = imprId;
        agentListModel.houseId = self.houseId;
        agentListModel.houseType = self.houseType;

        [self.items addObject:agentListModel];
        self.items = [FHNeighborhoodDetailModuleHelper moduleClassificationMethod:self.items];
//        self.agentListModel = agentListModel;
    }

    if (model.isInstantData) {
        [self.tableView reloadData];
    }else{
        [self reloadData];
    }
    
    [self.detailController updateLayout:model.isInstantData];
}
//小区顶部i地图按钮点击事件
- (void)mapImageClick {
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[FHDetailStaticMapCellModel class]]) {
           CGRect indexRect =  [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            CGPoint scrollPoint = CGPointMake(0, indexRect.origin.y-([TTDeviceHelper isIPhoneXSeries]?84:64));
            [self.tableView setContentOffset:scrollPoint animated:YES];
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
    
    
}
// 周边数据请求，当网络请求都返回后刷新数据
- (void)requestRelatedData:(NSString *)neighborhoodId {
    self.requestRelatedCount = 0;
    if (neighborhoodId.length < 1) {
        return;
    }
    // 周边小区
    [self requestRelatedNeighborhoodSearch:neighborhoodId];
    // 同小区房源-二手房
    [self requestHouseInSameNeighborhoodSearchErShou:neighborhoodId];
    // 同小区房源-租房
    [self requestHouseInSameNeighborhoodSearchRent:neighborhoodId];
}

// 处理详情页周边请求数据
- (void)processDetailRelatedData {
    if (self.requestRelatedCount >= 3) {
        self.detailController.isLoadingData = NO;
        // 周边小区
        if (self.relatedNeighborhoodData && self.relatedNeighborhoodData.items.count > 0) {
            // 添加分割线--当存在某个数据的时候在顶部添加分割线
            FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
            [self.items addObject:grayLine];
            FHDetailRelatedNeighborhoodModel *infoModel = [[FHDetailRelatedNeighborhoodModel alloc] init];
            infoModel.relatedNeighborhoodData = self.relatedNeighborhoodData;
            infoModel.neighborhoodId = self.neighborhoodId;
            [self.items addObject:infoModel];
        }
        // 小区房源
        if (self.sameNeighborhoodErshouHouseData.items.count > 0 || self.sameNeighborhoodRentHouseData.items.count > 0) {
            // 添加分割线--当存在某个数据的时候在顶部添加分割线
            FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
            [self.items addObject:grayLine];
            FHDetailNeighborhoodHouseModel *infoModel = [[FHDetailNeighborhoodHouseModel alloc] init];
            infoModel.tableView = self.tableView;
            infoModel.sameNeighborhoodErshouHouseData = self.sameNeighborhoodErshouHouseData;
            infoModel.sameNeighborhoodRentHouseData = self.sameNeighborhoodRentHouseData;
            // 租房详情页，或者地图租房半屏列表，进入小区详情
            if ([self.source isEqualToString:@"rent_detail"]) {
                if (self.sameNeighborhoodErshouHouseData.items.count > 0 && self.sameNeighborhoodRentHouseData.items.count > 0) {
                    // 既有二手房，同时有租房数据
                    infoModel.firstSelIndex = 1;
                }
            }
            [self.items addObject:infoModel];
        }
        self.items = [FHNeighborhoodDetailModuleHelper moduleClassificationMethod:self.items];
        [self reloadData];
    }
}

// 周边小区
- (void)requestRelatedNeighborhoodSearch:(NSString *)neighborhoodId {
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestRelatedNeighborhoodSearchByNeighborhoodId:neighborhoodId searchId:nil offset:@"0" query:nil count:5 completion:^(FHDetailRelatedNeighborhoodResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.requestRelatedCount += 1;
        wSelf.relatedNeighborhoodData = model.data;
        [wSelf processDetailRelatedData];
    }];
}

// 同小区房源-二手房
- (void)requestHouseInSameNeighborhoodSearchErShou:(NSString *)neighborhoodId {
    NSString *houseId = self.houseId;
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestHouseInSameNeighborhoodSearchByNeighborhoodId:neighborhoodId houseId:houseId searchId:nil offset:@"0" query:nil count:5 completion:^(FHDetailSameNeighborhoodHouseResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.requestRelatedCount += 1;
        wSelf.sameNeighborhoodErshouHouseData = model.data;
        [wSelf processDetailRelatedData];
    }];
}

// 同小区房源-租房
- (void)requestHouseInSameNeighborhoodSearchRent:(NSString *)neighborhoodId {
    NSString *houseId = self.houseId;
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestHouseRentSameNeighborhood:houseId withNeighborhoodId:neighborhoodId completion:^(FHRentSameNeighborhoodResponseModel * _Nonnull model, NSError * _Nonnull error) {
        wSelf.requestRelatedCount += 1;
        wSelf.sameNeighborhoodRentHouseData = model.data;
        [wSelf processDetailRelatedData];
    }];
}

- (BOOL)isMissTitle
{
    FHDetailNeighborhoodModel *model = (FHDetailNeighborhoodModel *)self.detailData;
    return model.data.neighborhoodInfo.name.length < 1;
}

- (BOOL)isMissImage
{
    FHDetailNeighborhoodModel *model = (FHDetailNeighborhoodModel *)self.detailData;
    return model.data.neighborhoodImage.count < 1;
}

- (BOOL)isMissCoreInfo
{
    // 小区详情页不必判断信息缺失
    return NO;
}

@end
