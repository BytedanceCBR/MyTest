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
#import "FHDetailGrayLineCell.h"
#import "FHDetailNeighborhoodStatsInfoCell.h"
#import "FHDetailNeighborhoodPropertyInfoCell.h"
#import "FHDetailNewModel.h"
#import "FHDetailAgentListCell.h"
#import "FHDetailStaticMapCell.h"
#import "FHOldDetailPhotoHeaderCell.h"
#import "FHDetailNeighborhoodMediaHeaderCell.h"
#import "HMDTTMonitor.h"
#import <FHHouseBase/FHHouseNeighborModel.h>
#import <FHHouseBase/FHHomeHouseModel.h>
#import <FHDetailMediaHeaderCell.h>
#import "FHNeighborhoodDetailModuleHelper.h"
#import "FHDetailNeighborhoodQACell.h"
#import "FHDetailNeighborhoodAssessCell.h"
#import "FHDetailNeighborhoodCommentsCell.h"
#import "FHDetailQACellModel.h"
#import "FHDetailAccessCellModel.h"
#import "FHDetailCommentsCellModel.h"
#import "TTDeviceHelper.h"
#import "FHOldDetailStaticMapCell.h"
#import "FHDetailPriceChartCell.h"
#import "FHDetailNeighborhoodHouseSaleCell.h"
#import "FHDetailNeighborhoodHouseRentCell.h"
#import "FHDetailNeighborhoodHouseStatusModel.h"
#import "FHDetailSurroundingAreaCell.h"
#import "TTAccountManager.h"
#import "FHDetailNeighborhoodOwnerSellHouseCell.h"
#import <FHHouseBase/FHSearchChannelTypes.h>

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
    //轮播图
    [self.tableView registerClass:[FHDetailNeighborhoodMediaHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodMediaHeaderModel class])];
    //信息cell
    [self.tableView registerClass:[FHNeighborhoodDetailSubMessageCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodSubMessageModel class])];
    //状态cell
    [self.tableView registerClass:[FHDetailNeighborhoodStatsInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodStatsInfoModel class])];
    //属性cell
     [self.tableView registerClass:[FHDetailNeighborhoodPropertyInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodPropertyInfoModel class])];
    //小区地图
    [self.tableView registerClass:[FHOldDetailStaticMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailStaticMapCellModel class])];
    //均价走势
    [self.tableView registerClass:[FHDetailPriceChartCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPriceTrendCellModel class])];
    //小区问答
    [self.tableView registerClass:[FHDetailNeighborhoodQACell class] forCellReuseIdentifier:NSStringFromClass([FHDetailQACellModel class])];
    //推荐经纪人
    [self.tableView registerClass:[FHDetailAgentListCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAgentListModel class])];
    [self.tableView registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineModel class])];
    //帮我卖房入口
    [self.tableView registerClass:[FHDetailNeighborhoodOwnerSellHouseCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodOwnerSellHouseModel class])];
    //在售房源
    [self.tableView registerClass:[FHDetailNeighborhoodHouseSaleCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodHouseSaleModel class])];
    //在租房源
    [self.tableView registerClass:[FHDetailNeighborhoodHouseRentCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodHouseRentModel class])];
   //周边小区
    [self.tableView registerClass:[FHDetailSurroundingAreaCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailSurroundingAreaModel class])];
    
    [self.tableView registerClass:[FHDetailNeighborhoodCommentsCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailCommentsCellModel class])];
    
    [self.tableView registerClass:[FHDetailNeighborhoodAssessCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAccessCellModel class])];
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
    [FHHouseDetailAPI requestNeighborhoodDetail:self.houseId ridcode:self.ridcode realtorId:self.realtorId logPB:self.listLogPB query:nil extraInfo:self.extraInfo completion:^(FHDetailNeighborhoodModel * _Nullable model, NSData * _Nullable resultData, NSError * _Nullable error) {
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


- (void)vc_viewDidAppear:(BOOL)animated
{
    [super vc_viewDidAppear:animated];
    if (self.contactViewModel.isShowLogin && ![TTAccountManager isLogin]) {
        [[ToastManager manager] showToast:@"需要先登录才能进行操作哦"];
        self.contactViewModel.isShowLogin = NO;
    }
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
    contactPhone.isFormReport = !contactPhone.enablePhone;
    self.contactViewModel.contactPhone = contactPhone;
    self.contactViewModel.shareInfo = model.data.shareInfo;
//    self.contactViewModel.followStatus = model.data.userStatus.houseSubStatus;
    self.contactViewModel.chooseAgencyList = model.data.chooseAgencyList;
    self.contactViewModel.highlightedRealtorAssociateInfo = model.data.highlightedRealtorAssociateInfo;



    self.detailData = model;
    [self addDetailCoreInfoExcetionLog];

    // 清空数据源
    [self.items removeAllObjects];

    BOOL showTitleMapBtn = NO;
    FHDetailNeighborhoodSubMessageModel *neighborhoodInfoModel = [[FHDetailNeighborhoodSubMessageModel alloc] init];
    neighborhoodInfoModel.name = model.data.name;
    neighborhoodInfoModel.neighborhoodInfo = model.data.neighborhoodInfo;
    if (neighborhoodInfoModel.neighborhoodInfo.gaodeLat.length>0 && neighborhoodInfoModel.neighborhoodInfo.gaodeLng.length>0) {
        showTitleMapBtn = YES;
    }else {
        showTitleMapBtn = NO;
    }
    FHDetailNeighborhoodMediaHeaderModel *headerCellModel = [[FHDetailNeighborhoodMediaHeaderModel alloc] init];
    headerCellModel.albumInfo = model.data.albumInfo;
    headerCellModel.neighborhoodTopImage = model.data.neighborhoodTopImages;
    
    FHDetailHouseTitleModel *houseTitleModel = [[FHDetailHouseTitleModel alloc] init];
    houseTitleModel.titleStr = model.data.name;
    __weak typeof(self)weakself = self;
    houseTitleModel.mapImageClick = ^{
        [weakself mapImageClick];
    };
    houseTitleModel.address = model.data.neighborhoodInfo.address;
//        houseTitleModel.tags = model.data.tags;
    
    headerCellModel.titleDataModel = houseTitleModel;
    headerCellModel.contactViewModel = self.contactViewModel;
    houseTitleModel.neighborhoodInfoModel = neighborhoodInfoModel;
    houseTitleModel.showMapBtn = showTitleMapBtn;
    houseTitleModel.housetype = self.houseType;
    
    [self.items addObject:headerCellModel];
    

    
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
        [model.data.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isSingle = YES;
        }];
        infoModel.houseModelType = FHPlotHouseModelTypeCoreInfo;
        infoModel.tableView = self.tableView;
        infoModel.baseInfo = model.data.baseInfo;
        infoModel.baseInfoFoldCount = model.data.baseInfoFoldCount;
        [self.items addObject:infoModel];
    }
    

    // 小区评测
    if (model.data.strategy && model.data.strategy.articleList.count > 0) {
    
        FHDetailAccessCellModel *cellModel = [[FHDetailAccessCellModel alloc] init];
        cellModel.houseModelType = FHPlotHouseModelTypeLocationPeriphery;
        cellModel.strategy = model.data.strategy;

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
        cellModel.tracerDic = paramsDict;
        [self.items addObject:cellModel];
    }

    //地图
    if(model.data.neighborhoodInfo.gaodeLat.length > 0 && model.data.neighborhoodInfo.gaodeLng.length > 0){
        FHDetailStaticMapCellModel *staticMapModel = [[FHDetailStaticMapCellModel alloc] init];
        staticMapModel.baiduPanoramaUrl = model.data.neighborhoodInfo.baiduPanoramaUrl;
        staticMapModel.mapCentertitle = model.data.neighborhoodInfo.name;
        staticMapModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
        staticMapModel.gaodeLng = model.data.neighborhoodInfo.gaodeLng;
         staticMapModel.houseModelType = FHPlotHouseModelTypeLocationPeriphery;
        staticMapModel.houseId = model.data.neighborhoodInfo.id;
        staticMapModel.houseType = [NSString stringWithFormat:@"%d",FHHouseTypeNeighborhood];
        staticMapModel.title = @"周边配套";
        staticMapModel.tableView = self.tableView;
        staticMapModel.staticImage = model.data.neighborhoodInfo.gaodeImage;
        //小区攻略底部有10px的留白，防止滑动时，放大的卡片底部被下面的cell挡住，所以这里的高度根据留白距离减10
        if([[self.items lastObject] isKindOfClass:[FHDetailAccessCellModel class]]){
            staticMapModel.topMargin = 20;
        }else{
            staticMapModel.topMargin = 30;
        }
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

    // 均价走势
    if (model.data.priceTrend.count > 0) {
//        FHDetailPureTitleModel *titleModel = [[FHDetailPureTitleModel alloc] init];
//        titleModel.title = @"均价走势";
//        [self.items addObject:titleModel];
        FHDetailPriceTrendCellModel *priceTrendModel = [[FHDetailPriceTrendCellModel alloc] init];
        priceTrendModel.housetype  = self.houseType;
        priceTrendModel.houseModelType = FHPlotHouseModelTypeLocationPeriphery;
        priceTrendModel.priceTrends = model.data.priceTrend;
        priceTrendModel.tableView = self.tableView;
        [self.items addObject:priceTrendModel];
    }

    // 推荐经纪人
    if (model.data.recommendedRealtors.count > 0) {
        FHDetailAgentListModel *agentListModel = [[FHDetailAgentListModel alloc] init];
        NSString *searchId = self.listLogPB[@"search_id"];
        NSString *imprId = self.listLogPB[@"impr_id"];
        agentListModel.tableView = self.tableView;
        agentListModel.belongsVC = self.detailController;
        agentListModel.houseModelType = FHPlotHouseModelTypeAgentlist;
        agentListModel.recommendedRealtorsTitle = model.data.recommendedRealtorsTitle;
        agentListModel.recommendedRealtors = model.data.recommendedRealtors;
        agentListModel.associateInfo = model.data.recommendRealtorsAssociateInfo;

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
//        self.agentListModel = agentListModel;
    }
    //帮我卖房入口
    FHDetailNeighborhoodSaleHouseEntranceModel *saleHouseEntrance = model.data.saleHouseEntrance;
    if(saleHouseEntrance.img.url.length > 0 && saleHouseEntrance.openUrl.length > 0) {
        FHDetailNeighborhoodOwnerSellHouseModel *ownerSellHouseModel = [[FHDetailNeighborhoodOwnerSellHouseModel alloc] init];
        ownerSellHouseModel.imgUrl = saleHouseEntrance.img.url;
        ownerSellHouseModel.helpMeSellHouseOpenUrl = saleHouseEntrance.openUrl;
        [self.items addObject:ownerSellHouseModel];
    }

    self.items = [FHNeighborhoodDetailModuleHelper moduleClassificationMethod:self.items];
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
        // 小区房源(二手房)
        if (self.sameNeighborhoodErshouHouseData.items.count>0){
            FHDetailNeighborhoodHouseSaleModel *infoModel = [[FHDetailNeighborhoodHouseSaleModel alloc] init];
            infoModel.houseModelType = FHPlotHouseModelTypeSold;
            infoModel.neighborhoodSoldHouseData = self.sameNeighborhoodErshouHouseData;
            [self.items addObject:infoModel];
        }
        //小区房源租房
        if (self.sameNeighborhoodRentHouseData.items.count > 0) {
            FHDetailNeighborhoodHouseRentModel *infoModel = [[FHDetailNeighborhoodHouseRentModel alloc] init];
            infoModel.houseModelType = FHPlotHouseModelTypeSold;
            infoModel.sameNeighborhoodRentHouseData = self.sameNeighborhoodRentHouseData;
            [self.items addObject:infoModel];
        }
        FHDetailNeighborhoodModel *model = (FHDetailNeighborhoodModel *)self.detailData;
        // 小区点评
        if(model.data.comments) {
            FHDetailCommentsCellModel *commentsModel = [[FHDetailCommentsCellModel alloc] init];
            NSMutableDictionary *paramsDict = @{}.mutableCopy;
            if (self.detailTracerDic) {
                [paramsDict addEntriesFromDictionary:self.detailTracerDic];
            }
            paramsDict[@"page_type"] = [self pageTypeString];
            commentsModel.tracerDict = paramsDict;
            commentsModel.neighborhoodId = self.houseId;
            commentsModel.comments = model.data.comments;
             commentsModel.houseModelType = FHPlotHouseModelTypeNeighborhoodComment;
            [self.items addObject:commentsModel];
        }
        // 小区问答
        if (model.data.question) {
            // 添加分割线--当存在某个数据的时候在顶部添加分割线
            FHDetailQACellModel *qaModel = [[FHDetailQACellModel alloc] init];
            NSMutableDictionary *paramsDict = @{}.mutableCopy;
            if (self.detailTracerDic) {
                [paramsDict addEntriesFromDictionary:self.detailTracerDic];
            }
            paramsDict[@"page_type"] = [self pageTypeString];
            qaModel.tracerDict = paramsDict;
            qaModel.neighborhoodId = self.houseId;
            qaModel.question = model.data.question;
            qaModel.houseModelType = FHPlotHouseModelTypeNeighborhoodQA;
            [self.items addObject:qaModel];
        }
        // 周边小区
        if (self.relatedNeighborhoodData && self.relatedNeighborhoodData.items.count > 0) {
            FHDetailSurroundingAreaModel *infoModel = [[FHDetailSurroundingAreaModel alloc] init];
            infoModel.relatedNeighborhoodData = self.relatedNeighborhoodData;
            infoModel.houseModelType = FHPlotHouseModelTypePeriphery;
            infoModel.neighborhoodId = self.neighborhoodId;
            [self.items addObject:infoModel];
        }

        self.items = [FHNeighborhoodDetailModuleHelper moduleClassificationMethod:self.items];
        [self reloadData];
    }
}

// 周边小区
- (void)requestRelatedNeighborhoodSearch:(NSString *)neighborhoodId {
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestRelatedNeighborhoodSearchByNeighborhoodId:neighborhoodId isShowNeighborhood:NO searchId:nil offset:@"0" query:nil count:5 completion:^(FHDetailRelatedNeighborhoodResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.requestRelatedCount += 1;
        wSelf.relatedNeighborhoodData = model.data;
        [wSelf processDetailRelatedData];
    }];
}

// 同小区房源-二手房
- (void)requestHouseInSameNeighborhoodSearchErShou:(NSString *)neighborhoodId {
    NSString *houseId = self.houseId;
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestHouseInSameNeighborhoodSearchByNeighborhoodId:neighborhoodId houseId:houseId searchId:nil offset:@"0" query:nil count:5 channel:CHANNEL_ID_SAME_NEIGHBORHOOD_HOUSE_NEIGHBOR completion:^(FHDetailSameNeighborhoodHouseResponseModel * _Nullable model, NSError * _Nullable error) {
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


- (BOOL)isMissCoreInfo
{
    // 小区详情页不必判断信息缺失
    return NO;
}

@end
