//
//  FHHouseOldDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseOldDetailViewModel.h"
#import "FHDetailBaseCell.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailPhotoHeaderCell.h"
#import "FHDetailOldModel.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"
#import "FHDetailGrayLineCell.h"
#import "FHDetailHouseNameCell.h"
#import "FHDetailErshouHouseCoreInfoCell.h"
#import "FHDetailPropertyListCell.h"
#import "FHDetailPriceChangeHistoryCell.h"
#import "FHDetailAgentListCell.h"
#import "FHDetailHouseOutlineInfoCell.h"
#import "FHDetailSuggestTipCell.h"
#import "FHDetailRelatedNeighborhoodCell.h"
#import "FHDetailRelatedHouseCell.h"
#import "FHDetailSameNeighborhoodHouseCell.h"
#import "FHDetailErshouPriceChartCell.h"
#import "FHDetailDisclaimerCell.h"
#import "FHDetailPriceRankCell.h"
#import "FHDetailPriceTrendCellModel.h"
#import "FHDetailPureTitleCell.h"
#import "FHDetailNeighborhoodInfoCell.h"
#import "FHDetailNeighborhoodMapInfoCell.h"
#import "FHDetailNeighborhoodEvaluateCell.h"
#import "FHDetailListEntranceCell.h"
#import "FHDetailHouseSubscribeCell.h"
#import "FHDetailAveragePriceComparisonCell.h"
#import "FHEnvContext.h"
#import "NSDictionary+TTAdditions.h"
#import "FHDetailMediaHeaderCell.h"
#import <FHHouseBase/FHHouseFollowUpHelper.h>
#import <FHHouseBase/FHMainApi+Contact.h>
#import <FHHouseBase/FHUserTrackerDefine.h>
#import "FHDetailNewModel.h"
#import "FHDetailOldNearbyMapCell.h"
#import "FHDetailOldEvaluateCell.h"
#import "FHDetailOldComfortCell.h"
#import "FHDetailCommunityEntryCell.h"
#import "FHDetailBlankLineCell.h"
#import <FHHouseBase/FHSearchHouseModel.h>
#import <FHHouseBase/FHHomeHouseModel.h>

extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHSubscribeHouseCacheKey;

@interface FHHouseOldDetailViewModel ()

@property (nonatomic, assign)   NSInteger       requestRelatedCount;
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *sameNeighborhoodHouseData;
@property (nonatomic, strong , nullable) FHDetailRelatedNeighborhoodResponseDataModel *relatedNeighborhoodData;
@property (nonatomic, strong , nullable) FHDetailRelatedHouseResponseDataModel *relatedHouseData;
@property (nonatomic, copy , nullable) NSString *neighborhoodId;// 周边小区房源id

@end

@implementation FHHouseOldDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    [self.tableView registerClass:[FHDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderModel class])];
    [self.tableView registerClass:[FHDetailMediaHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailMediaHeaderModel class])];
    [self.tableView registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineModel class])];
    [self.tableView registerClass:[FHDetailHouseNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseNameModel class])];
    [self.tableView registerClass:[FHDetailErshouHouseCoreInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailErshouHouseCoreInfoModel class])];
    [self.tableView registerClass:[FHDetailPropertyListCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPropertyListModel class])];
    [self.tableView registerClass:[FHDetailPriceChangeHistoryCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPriceChangeHistoryModel class])];
    [self.tableView registerClass:[FHDetailAgentListCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAgentListModel class])];
    [self.tableView registerClass:[FHDetailHouseOutlineInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseOutlineInfoModel class])];
    [self.tableView registerClass:[FHDetailSuggestTipCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailSuggestTipModel class])];
    [self.tableView registerClass:[FHDetailRelatedNeighborhoodCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRelatedNeighborhoodModel class])];
    [self.tableView registerClass:[FHDetailRelatedHouseCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRelatedHouseModel class])];
    [self.tableView registerClass:[FHDetailSameNeighborhoodHouseCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailSameNeighborhoodHouseModel class])];
    [self.tableView registerClass:[FHDetailDisclaimerCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailDisclaimerModel class])];
    [self.tableView registerClass:[FHDetailErshouPriceChartCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPriceTrendCellModel class])];
    [self.tableView registerClass:[FHDetailPriceRankCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPriceRankModel class])];
    [self.tableView registerClass:[FHDetailPureTitleCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPureTitleModel class])];
    [self.tableView registerClass:[FHDetailNeighborhoodInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodInfoModel class])];
    [self.tableView registerClass:[FHDetailOldEvaluateCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailOldEvaluateModel class])];
    [self.tableView registerClass:[FHDetailListEntranceCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailListEntranceModel class])];
    [self.tableView registerClass:[FHDetailHouseSubscribeCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseSubscribeModel class])];
    [self.tableView registerClass:[FHDetailAveragePriceComparisonCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAveragePriceComparisonModel class])];
    [self.tableView registerClass:[FHDetailOldNearbyMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailOldNearbyMapModel class])];
    [self.tableView registerClass:[FHDetailOldComfortCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailOldComfortModel class])];    
    [self.tableView registerClass:[FHDetailNeighborhoodMapInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodMapInfoModel class])];
    [self.tableView registerClass:[FHDetailCommunityEntryCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailCommunityEntryModel class])];
    [self.tableView registerClass:[FHDetailBlankLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailBlankLineModel class])];
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
    [FHHouseDetailAPI requestOldDetail:self.houseId ridcode:self.ridcode realtorId:self.realtorId logPB:self.listLogPB completion:^(FHDetailOldModel * _Nullable model, NSError * _Nullable error) {

        if (model && error == NULL) {
            if (model.data) {
                [wSelf processDetailData:model];
                // 0 正常显示，1 二手房源正常下架（如已卖出等），-1 二手房非正常下架（如法律风险、假房源等）
                wSelf.detailController.hasValidateData = YES;
                [wSelf.detailController.emptyView hideEmptyView];
                wSelf.bottomBar.hidden = NO;
                [wSelf handleBottomBarStatus:model.data.status];
                NSString *neighborhoodId = model.data.neighborhoodInfo.id;
                wSelf.neighborhoodId = neighborhoodId;
                // 周边数据请求
                [wSelf requestRelatedData:neighborhoodId];
                wSelf.contactViewModel.imShareInfo = model.data.imShareInfo;
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
            NSDictionary *userInfo = error.userInfo;
            [wSelf addDetailRequestFailedLog:model.status.integerValue message:error.domain];
//            }
        }
    }];
}

- (void)handleBottomBarStatus:(NSInteger)status
{
    if (status == 1) {
        self.bottomStatusBar.hidden = NO;
        [self.navBar showRightItems:YES];
        //        self.
        [self.bottomStatusBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
        }];
    }else if (status == -1) {
        self.bottomStatusBar.hidden = YES;
        [self.navBar showRightItems:NO];
        [self.bottomStatusBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.detailController.emptyView showEmptyWithTip:@"该房源已下架" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
    }else {
        self.bottomStatusBar.hidden = YES;
        [self.navBar showRightItems:YES];
        [self.bottomStatusBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}


// 处理详情页数据
- (void)processDetailData:(FHDetailOldModel *)model{
    
    self.detailData = model;
    if (model.data.status != -1) {
        [self addDetailCoreInfoExcetionLog];
    }
    // 清空数据源
    [self.items removeAllObjects];
    // 添加头滑动图片 && 视频
    BOOL hasVideo = NO;
    BOOL isInstant = model.isInstantData;
    if (model.data.houseVideo && model.data.houseVideo.videoInfos.count > 0) {
        hasVideo = YES;
    }
    if (model.data.houseImageDictList.count > 0 || hasVideo) {
        FHMultiMediaItemModel *itemModel = nil;
        if (hasVideo) {
            FHVideoHouseVideoVideoInfosModel *info = model.data.houseVideo.videoInfos[0];
            itemModel = [[FHMultiMediaItemModel alloc] init];
            itemModel.mediaType = FHMultiMediaTypeVideo;
            // 测试id
            // @"v03004b60000bh57qrtlt63p5lgd20d0";
            // @"v0200c940000bh9r6mna1haoho053neg";
            if (info.coverImageUrl.length <= 0) {
                // 视频没有url
                if (model.data.houseImageDictList.count > 0) {
                    for (int i = 0; i < model.data.houseImageDictList.count; i++) {
                        FHDetailOldDataHouseImageDictListModel *item = model.data.houseImageDictList[i];
                        if (item.houseImageList.count > 0) {
                            FHImageModel *imageModel = item.houseImageList[0];
                            if (imageModel.url.length > 0) {
                                info.coverImageUrl = imageModel.url;
                                break;
                            }
                        }
                    }
                }
            }
            itemModel.videoID = info.vid;
            itemModel.imageUrl = info.coverImageUrl;
            itemModel.vWidth = info.vWidth;
            itemModel.vHeight = info.vHeight;
            itemModel.infoTitle = model.data.houseVideo.infoTitle;
            itemModel.infoSubTitle = model.data.houseVideo.infoSubTitle;
            itemModel.groupType = @"视频";
        }
        
        FHDetailMediaHeaderModel *headerCellModel = [[FHDetailMediaHeaderModel alloc] init];
        headerCellModel.houseImageDictList = model.data.houseImageDictList;
        if (!isInstant) {
            FHDetailOldDataHouseImageDictListModel *imgModel = [headerCellModel.houseImageDictList firstObject];
            imgModel.instantHouseImageList = [self instantHouseImages];
        }
        headerCellModel.vedioModel = itemModel;// 添加视频模型数据
        headerCellModel.contactViewModel = self.contactViewModel;
        headerCellModel.isInstantData = model.isInstantData;
        [self.items addObject:headerCellModel];
    }else{
        // 添加头滑动图片
        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
        if (model.data.houseImage.count > 0) {            
            headerCellModel.houseImage = model.data.houseImage;
            if (!isInstant) {
                headerCellModel.instantHouseImages = [self instantHouseImages];
            }
        }else{
            //无图片时增加默认图
            FHImageModel *imgModel = [FHImageModel new];
            headerCellModel.houseImage = @[imgModel];
        }
        headerCellModel.isInstantData = model.isInstantData;
        [self.items addObject:headerCellModel];
        
    }
    // 添加标题
    if (model.data) {
        FHDetailHouseNameModel *houseName = [[FHDetailHouseNameModel alloc] init];
        houseName.type = 1;
        houseName.name = model.data.title;
        houseName.aliasName = nil;
        houseName.tags = model.data.tags;
        [self.items addObject:houseName];
    }
    // 添加core info
    if (model.data.coreInfo) {
        FHDetailErshouHouseCoreInfoModel *coreInfoModel = [[FHDetailErshouHouseCoreInfoModel alloc] init];
        coreInfoModel.coreInfo = model.data.coreInfo;
        [self.items addObject:coreInfoModel];
    }
    // 价格变动
    if (model.data.priceChangeHistory) {
        FHDetailPriceChangeHistoryModel *priceChangeHistoryModel = [[FHDetailPriceChangeHistoryModel alloc] init];
        priceChangeHistoryModel.priceChangeHistory = model.data.priceChangeHistory;
        priceChangeHistoryModel.baseViewModel = self;
        [self.items addObject:priceChangeHistoryModel];
    }
    // 添加属性列表
    if (model.data.baseInfo || model.data.certificate || model.data.baseExtra) {
        FHDetailPropertyListModel *propertyModel = [[FHDetailPropertyListModel alloc] init];
        propertyModel.baseInfo = model.data.baseInfo;
        propertyModel.certificate = model.data.certificate;
        propertyModel.extraInfo = model.data.baseExtra;
        [self.items addObject:propertyModel];
    }
    
    //添加订阅房源动态卡片
    if([self isShowSubscribe]){
        FHDetailHouseSubscribeModel *subscribeModel = [[FHDetailHouseSubscribeModel alloc] init];
        subscribeModel.tableView = self.tableView;
        [self.items addObject:subscribeModel];
        
        __weak typeof(self) wSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ((FHDetailHouseSubscribeCell *)subscribeModel.cell) {
                ((FHDetailHouseSubscribeCell *)subscribeModel.cell).subscribeBlock = ^(NSString * _Nonnull phoneNum) {
                    [wSelf subscribeFormRequest:phoneNum subscribeModel:subscribeModel];
                };
            }
        });
    }
    
    //生成IM卡片的schema用 个人认为server应该加接口
    NSString *imgUrl = @"";
    if (model.data.houseImage.count > 0) {
        FHImageModel *imageInfo = model.data.houseImage[0];
        imgUrl = imageInfo.url ?: @"";
    }
    NSString *area = @"";
    NSString *price = @"";
    if (model.data.coreInfo.count >= 3) {
        FHDetailOldDataCoreInfoModel *areaInfo = model.data.coreInfo[2];
        area = areaInfo.value ?: @"";
        FHDetailOldDataCoreInfoModel *priceInfo = model.data.coreInfo[0];
        price = priceInfo.value ?: @"";
    }
    NSString *face = @"";
    NSString *avgPrice = @"";
    if (model.data.baseInfo.count >= 3) {
        FHDetailOldDataCoreInfoModel *baseInfo = model.data.baseInfo[2];
        face = baseInfo.value ?: @"";
        FHDetailOldDataCoreInfoModel *avgPriceInfo = model.data.baseInfo[0];
        avgPrice = avgPriceInfo.value ?: @"";
    }
    NSString *tag = @"";
    if (model.data.tags > 0) {
        FHHouseTagsModel *tagInfo = model.data.tags[0];
        tag = tagInfo.content ?: @"";
    }
    NSString *houseType = [NSString stringWithFormat:@"%d", self.houseType];
    NSString *houseDes = [NSString stringWithFormat:@"%@/%@/%@", area, face, tag];
    
    // 房源榜单
    if (model.data.listEntrance.count > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailListEntranceModel *entranceModel = [[FHDetailListEntranceModel alloc] init];
        entranceModel.listEntrance = model.data.listEntrance;
        [self.items addObject:entranceModel];
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
        agentListModel.recommendedRealtors = model.data.recommendedRealtors;
        agentListModel.phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeSecondHandHouse houseId:self.houseId];
        [agentListModel.phoneCallViewModel generateImParams:self.houseId houseTitle:model.data.title houseCover:imgUrl houseType:houseType  houseDes:houseDes housePrice:price houseAvgPrice:avgPrice];
        agentListModel.phoneCallViewModel.tracerDict = self.detailTracerDic.mutableCopy;
//        agentListModel.phoneCallViewModel.followUpViewModel = self.contactViewModel.followUpViewModel;
//        agentListModel.phoneCallViewModel.followUpViewModel.tracerDict = self.detailTracerDic;
        agentListModel.searchId = searchId;
        agentListModel.imprId = imprId;
        agentListModel.houseId = self.houseId;
        agentListModel.houseType = self.houseType;
        [self.items addObject:agentListModel];
    }
    // 房源概况
    if (model.data.houseOverreview.list.count > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailHouseOutlineInfoModel *infoModel = [[FHDetailHouseOutlineInfoModel alloc] init];
        infoModel.houseOverreview = model.data.houseOverreview;
        infoModel.baseViewModel = self;
        [self.items addObject:infoModel];
    }

    // 小区信息
    if (model.data.neighborhoodInfo.id.length > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        //ugc 圈子入口,写在这儿是因为如果小区模块移除，那么圈子入口也不展示
        BOOL showUgcEntry = model.data.ugcSocialGroup && model.data.ugcSocialGroup.activeCountInfo && model.data.ugcSocialGroup.activeInfo.count > 0;
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        if(showUgcEntry){
            model.data.ugcSocialGroup.houseType = FHHouseTypeSecondHandHouse;
            [self.items addObject:model.data.ugcSocialGroup];
        } else{
            FHDetailBlankLineModel *whiteLine = [[FHDetailBlankLineModel alloc] init];
            [self.items addObject:whiteLine];
        }

        FHDetailNeighborhoodInfoModel *infoModel = [[FHDetailNeighborhoodInfoModel alloc] init];
        infoModel.neighborhoodInfo = model.data.neighborhoodInfo;
        infoModel.tableView = self.tableView;
        [self.items addObject:infoModel];
    }
    // 小区评测
    if (model.data.neighborhoodInfo.evaluationInfo) {
        FHDetailOldEvaluateModel *infoModel = [[FHDetailOldEvaluateModel alloc] init];
        infoModel.evaluationInfo = model.data.neighborhoodInfo.evaluationInfo;
        infoModel.log_pb = model.data.neighborhoodInfo.logPb;
        [self.items addObject:infoModel];
    }
    // 舒适指数
    if (model.data.comfortInfo) {
        FHDetailOldComfortModel *comfortModel = [[FHDetailOldComfortModel alloc]init];
        comfortModel.comfortInfo = model.data.comfortInfo;
        [self.items addObject:comfortModel];
    }
    // 周边地图
    if (model.data.neighborhoodInfo.gaodeLat.length > 0 && model.data.neighborhoodInfo.gaodeLng.length > 0) {
        FHDetailOldNearbyMapModel *infoModel = [[FHDetailOldNearbyMapModel alloc] init];
        infoModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
        infoModel.gaodeLng = model.data.neighborhoodInfo.gaodeLng;
        infoModel.title = model.data.neighborEval.title;
        infoModel.mapCentertitle = model.data.neighborhoodInfo.name;
        infoModel.score = model.data.neighborEval.score;
        
        [self.items addObject:infoModel];
        
        __weak typeof(self) wSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ((FHDetailOldNearbyMapCell *)infoModel.cell) {
                ((FHDetailOldNearbyMapCell *)infoModel.cell).indexChangeCallBack = ^{
                    [wSelf reloadData];
                };
            }
        });
    }

    // 均价走势
    if (model.data.priceTrend.count > 0) {
        FHDetailPriceTrendCellModel *priceTrendModel = [[FHDetailPriceTrendCellModel alloc] init];
        priceTrendModel.priceTrends = model.data.priceTrend;
        priceTrendModel.neighborhoodInfo = model.data.neighborhoodInfo;
        priceTrendModel.pricingPerSqmV = model.data.pricingPerSqmV;
        priceTrendModel.priceAnalyze = model.data.priceAnalyze;
        if (model.data.neighborhoodPriceRange && model.data.priceAnalyze) {
            priceTrendModel.bottomHeight = 0;
        }else {
            priceTrendModel.bottomHeight = (model.data.housePricingRank.buySuggestion.content.length > 0) ? 0 : 20;
        }
        priceTrendModel.tableView = self.tableView;
        [self.items addObject:priceTrendModel];
    }
    // 均价对比
    if(model.data.neighborhoodPriceRange && model.data.priceAnalyze){
        FHDetailAveragePriceComparisonModel *infoModel = [[FHDetailAveragePriceComparisonModel alloc] init];
        infoModel.neighborhoodId = model.data.neighborhoodInfo.id;
        infoModel.neighborhoodName = model.data.neighborhoodInfo.name;
        infoModel.analyzeModel = model.data.priceAnalyze;
        infoModel.rangeModel = model.data.neighborhoodPriceRange;
        [self.items addObject:infoModel];
    }
    // 购房小建议
    if (model.data.housePricingRank.buySuggestion.content.length > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailSuggestTipModel *infoModel = [[FHDetailSuggestTipModel alloc] init];
        infoModel.buySuggestion = model.data.housePricingRank.buySuggestion;
        [self.items addObject:infoModel];
    }
    
    // --
    [self.contactViewModel generateImParams:self.houseId houseTitle:model.data.title houseCover:imgUrl houseType:houseType  houseDes:houseDes housePrice:price houseAvgPrice:avgPrice];
    
    FHDetailContactModel *contactPhone = nil;
    if (model.data.highlightedRealtor) {
        contactPhone = model.data.highlightedRealtor;
    }else {
        contactPhone = model.data.contact;
        contactPhone.unregistered = YES;
    }
    if (contactPhone.phone.length > 0) {
        
        if ([self isShowSubscribe]) {
            contactPhone.isFormReport = YES;
        }else {
            contactPhone.isFormReport = NO;
        }
    }else {
        contactPhone.isFormReport = YES;
    }
    self.contactViewModel.contactPhone = contactPhone;
    self.contactViewModel.shareInfo = model.data.shareInfo;
    self.contactViewModel.followStatus = model.data.userStatus.houseSubStatus;
    self.contactViewModel.chooseAgencyList = model.data.chooseAgencyList;
    [self reloadData];
}

// 周边数据请求，当网络请求都返回后刷新数据
- (void)requestRelatedData:(NSString *)neighborhoodId {
    self.requestRelatedCount = 0;
    if (neighborhoodId.length > 0) {
        // 同小区房源
        [self requestHouseInSameNeighborhoodSearch:neighborhoodId];
        // 周边小区
        [self requestRelatedNeighborhoodSearch:neighborhoodId];
    }
    // 周边房源
    [self requestRelatedHouseSearch];
}

// 处理详情页周边请求数据
- (void)processDetailRelatedData {
    if (self.requestRelatedCount >= 3) {
         self.detailController.isLoadingData = NO;
        //  同小区房源
        if (self.sameNeighborhoodHouseData && self.sameNeighborhoodHouseData.items.count > 0) {
            // 添加分割线--当存在某个数据的时候在顶部添加分割线
            FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
            [self.items addObject:grayLine];
            FHDetailSameNeighborhoodHouseModel *infoModel = [[FHDetailSameNeighborhoodHouseModel alloc] init];
            infoModel.sameNeighborhoodHouseData = self.sameNeighborhoodHouseData;
            [self.items addObject:infoModel];
        }
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
        // 周边房源
        if (self.relatedHouseData && self.relatedHouseData.items.count > 0) {
            // 添加分割线--当存在某个数据的时候在顶部添加分割线
            FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
            [self.items addObject:grayLine];
            FHDetailRelatedHouseModel *infoModel = [[FHDetailRelatedHouseModel alloc] init];
            infoModel.relatedHouseData = self.relatedHouseData;
            [self.items addObject:infoModel];
        }
        // 免责声明
        FHDetailOldModel * model = (FHDetailOldModel *)self.detailData;
        if (model.data.contact || model.data.disclaimer) {
            FHDetailDisclaimerModel *infoModel = [[FHDetailDisclaimerModel alloc] init];
            infoModel.disclaimer = model.data.disclaimer;
            if (!model.data.highlightedRealtor) {
                 // 当且仅当没有合作经纪人时，才在disclaimer中显示 经纪人 信息
                infoModel.contact = model.data.contact;
            } else {
                infoModel.contact = nil;
            }
            [self.items addObject:infoModel];
        }
        //
        [self reloadData];
    }
}

// 同小区房源
- (void)requestHouseInSameNeighborhoodSearch:(NSString *)neighborhoodId {
    NSString *houseId = self.houseId;
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestHouseInSameNeighborhoodSearchByNeighborhoodId:neighborhoodId houseId:houseId searchId:nil offset:@"0" query:nil count:5 completion:^(FHDetailSameNeighborhoodHouseResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.requestRelatedCount += 1;
        wSelf.sameNeighborhoodHouseData = model.data;
        [wSelf processDetailRelatedData];
    }];
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

// 周边房源
- (void)requestRelatedHouseSearch {
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestRelatedHouseSearch:self.houseId offset:@"0" query:nil count:5 completion:^(FHDetailRelatedHouseResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.requestRelatedCount += 1;
        wSelf.relatedHouseData = model.data;
        [wSelf processDetailRelatedData];
    }];
}

- (BOOL)isMissTitle
{
    FHDetailOldModel *model = (FHDetailOldModel *)self.detailData;
    return model.data.title.length < 1;
}

- (BOOL)isMissImage
{
    FHDetailOldModel *model = (FHDetailOldModel *)self.detailData;
    return model.data.houseImage.count < 1;
}

- (BOOL)isMissCoreInfo
{
    FHDetailOldModel *model = (FHDetailOldModel *)self.detailData;
    return model.data.coreInfo.count < 1;
}

- (void)subscribeFormRequest:(NSString *)phoneNum subscribeModel:(FHDetailHouseSubscribeModel *)subscribeModel {
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    NSString *houseId = self.houseId;
    NSString *from = @"app_oldhouse_subscription";
    [FHMainApi requestSendPhoneNumbserByHouseId:houseId phone:phoneNum from:from agencyList:nil completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (model.status.integerValue == 0 && !error) {
            [[ToastManager manager] showToast:@"提交成功，经纪人将尽快与您联系"];
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache setObject:phoneNum forKey:kFHPhoneNumberCacheKey];
            
            YYCache *subscribeHouseCache = [[FHEnvContext sharedInstance].generalBizConfig subscribeHouseCache];
            [subscribeHouseCache setObject:@"1" forKey:self.houseId];
            
            [wself.items removeObject:subscribeModel];
            [wself reloadData];
        }else {
            [[ToastManager manager] showToast:[NSString stringWithFormat:@"提交失败 %@",model.message]];
        }
    }];
    // 静默关注功能
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.detailTracerDic) {
        [params addEntriesFromDictionary:self.detailTracerDic];
    }
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:params error:nil];
    configModel.houseType = self.houseType;
    configModel.followId = self.houseId;
    configModel.actionType = self.houseType;
    
    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];
}

- (BOOL)isShowSubscribe {
    BOOL isShow = NO;
    NSDictionary *fhSettings = [self fhSettings];
    BOOL oldHouseSubscribe =  [fhSettings tt_boolValueForKey:@"f_is_show_house_sub_entry"];
    //根据服务器setting设置和本地缓存，已经订阅过的house不再显示
    YYCache *subscribeHouseCache = [[FHEnvContext sharedInstance].generalBizConfig subscribeHouseCache];
    if(oldHouseSubscribe && ![subscribeHouseCache containsObjectForKey:self.houseId]){
        isShow = YES;
    }
    return isShow;
}

- (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

#pragma mark - instant data
-(void)handleInstantData:(id)data
{

    FHDetailOldModel *model = [FHDetailOldModel new];
    model.isInstantData = YES;
    FHDetailOldDataModel *dataModel = [[FHDetailOldDataModel alloc] init];
    if ([data isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)data;
        dataModel.title = item.title;
        dataModel.id = item.hid;
        dataModel.imprId = item.imprId;
        dataModel.houseImage = item.houseImage;
        dataModel.coreInfo = item.coreInfo;
        dataModel.baseInfo = item.baseInfo;
        dataModel.tags = item.tags;
        dataModel.status = 0;
        dataModel.logPb = item.logPb;
        
    }else if ([data isKindOfClass:[FHHomeHouseDataItemsModel class]]){
        FHHomeHouseDataItemsModel *item = (FHHomeHouseDataItemsModel *)data;
        dataModel.title = item.title;
        dataModel.id = item.idx;
        dataModel.imprId = item.imprId;
        dataModel.houseImage = item.houseImage;
        dataModel.coreInfo = item.coreInfoList;
        dataModel.baseInfo = item.baseInfo;
        dataModel.tags = item.tags;
        dataModel.status = 0;        
        dataModel.logPb = item.logPb;
        
    }else{
        self.detailController.instantData = nil;
        return;
    }
    
    dataModel.contact = [FHDetailContactModel new];
    dataModel.contact.isInstantData = YES;
    model.data = dataModel;
    self.bottomBar.hidden = NO;
    [self processDetailData:model];
    
}

-(BOOL)currentIsInstantData
{
    return [(FHDetailOldModel *)self.detailData isInstantData];
}

-(NSArray *)instantHouseImages
{
    id data = self.detailController.instantData;
    if ([data isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)data;
        return  item.houseImage;
        
    }else if ([data isKindOfClass:[FHHomeHouseDataItemsModel class]]){
        FHHomeHouseDataItemsModel *item = (FHHomeHouseDataItemsModel *)data;
        return item.houseImage;
    }
    return nil;
}


#pragma mark - poplayer
- (void)onShowPoplayerNotification:(NSNotification *)notification
{
    UITableViewCell *cell = notification.userInfo[@"cell"];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    
    id model = notification.userInfo[@"model"];
    
    FHDetailPropertyListModel *propertyModel = nil;
    for (id item in self.items) {
        if ([item isKindOfClass:[FHDetailPropertyListModel class]]) {
            propertyModel = (FHDetailPropertyListModel *)item;
            break;
        }
    }
    
    if (!propertyModel) {
        return;
    }

    NSMutableDictionary *trackInfo = [NSMutableDictionary new];
    trackInfo[UT_PAGE_TYPE] = self.detailTracerDic[UT_PAGE_TYPE];
    trackInfo[UT_ELEMENT_FROM] = self.detailTracerDic[UT_ELEMENT_FROM]?:UT_BE_NULL;
    trackInfo[UT_ORIGIN_FROM] = self.detailTracerDic[UT_ORIGIN_FROM];
    trackInfo[UT_ORIGIN_SEARCH_ID] = self.detailTracerDic[UT_ORIGIN_SEARCH_ID];
    trackInfo[UT_LOG_PB] = self.detailTracerDic[UT_LOG_PB];
    trackInfo[@"rank"] = self.detailTracerDic[@"rank"];
    
    NSString *position = nil;
    FHDetailHalfPopLayer *popLayer = [self popLayer];
    if ([model isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        position = @"official_inspection";
        trackInfo[UT_ENTER_FROM] = position;
        [popLayer showWithOfficialData:(FHDetailDataBaseExtraOfficialModel *)model trackInfo:trackInfo];
        
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
        position = @"happiness_eye";
        trackInfo[UT_ENTER_FROM] = position;
        [popLayer showDetectiveData:(FHDetailDataBaseExtraDetectiveModel *)model trackInfo:trackInfo];
        
    }
    [self addClickOptionLog:position];
    self.tableView.scrollsToTop = NO;
    [self enableController:NO];
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

@end
