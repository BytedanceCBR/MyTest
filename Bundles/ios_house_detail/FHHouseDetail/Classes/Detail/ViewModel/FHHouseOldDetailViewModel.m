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
    [self.tableView registerClass:[FHDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderCell class])];
    [self.tableView registerClass:[FHDetailMediaHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailMediaHeaderCell class])];
    [self.tableView registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineCell class])];
    [self.tableView registerClass:[FHDetailHouseNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseNameCell class])];
    [self.tableView registerClass:[FHDetailErshouHouseCoreInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailErshouHouseCoreInfoCell class])];
    [self.tableView registerClass:[FHDetailPropertyListCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPropertyListCell class])];
    [self.tableView registerClass:[FHDetailPriceChangeHistoryCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPriceChangeHistoryCell class])];
    [self.tableView registerClass:[FHDetailAgentListCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAgentListCell class])];
    [self.tableView registerClass:[FHDetailHouseOutlineInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseOutlineInfoCell class])];
    [self.tableView registerClass:[FHDetailSuggestTipCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailSuggestTipCell class])];
    [self.tableView registerClass:[FHDetailRelatedNeighborhoodCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRelatedNeighborhoodCell class])];
    [self.tableView registerClass:[FHDetailRelatedHouseCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRelatedHouseCell class])];
    [self.tableView registerClass:[FHDetailSameNeighborhoodHouseCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailSameNeighborhoodHouseCell class])];
    [self.tableView registerClass:[FHDetailDisclaimerCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailDisclaimerCell class])];
    [self.tableView registerClass:[FHDetailErshouPriceChartCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailErshouPriceChartCell class])];
    [self.tableView registerClass:[FHDetailPriceRankCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPriceRankCell class])];
    [self.tableView registerClass:[FHDetailPureTitleCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPureTitleCell class])];
    [self.tableView registerClass:[FHDetailNeighborhoodInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodInfoCell class])];
    [self.tableView registerClass:[FHDetailNeighborhoodMapInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodMapInfoCell class])];
    [self.tableView registerClass:[FHDetailNeighborhoodEvaluateCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodEvaluateCell class])];
    [self.tableView registerClass:[FHDetailListEntranceCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailListEntranceCell class])];
    [self.tableView registerClass:[FHDetailHouseSubscribeCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseSubscribeCell class])];
    [self.tableView registerClass:[FHDetailAveragePriceComparisonCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAveragePriceComparisonCell class])];

}
// cell class
- (Class)cellClassForEntity:(id)model {
    // 兼容旧版本 头部滑动图片
    if ([model isKindOfClass:[FHDetailPhotoHeaderModel class]]) {
        return [FHDetailPhotoHeaderCell class];
    }
    // 新版本 头部滑动图片
    if ([model isKindOfClass:[FHDetailMediaHeaderModel class]]) {
        return [FHDetailMediaHeaderCell class];
    }
    // 标题
    if ([model isKindOfClass:[FHDetailHouseNameModel class]]) {
        return [FHDetailHouseNameCell class];
    }
    // 灰色分割线
    if ([model isKindOfClass:[FHDetailGrayLineModel class]]) {
        return [FHDetailGrayLineCell class];
    }
    // Core Info
    if ([model isKindOfClass:[FHDetailErshouHouseCoreInfoModel class]]) {
        return [FHDetailErshouHouseCoreInfoCell class];
    }
    // 价格变动
    if ([model isKindOfClass:[FHDetailPriceChangeHistoryModel class]]) {
        return [FHDetailPriceChangeHistoryCell class];
    }
    // 属性列表
    if ([model isKindOfClass:[FHDetailPropertyListModel class]]) {
        return [FHDetailPropertyListCell class];
    }
    // 推荐经纪人
    if ([model isKindOfClass:[FHDetailAgentListModel class]]) {
        return [FHDetailAgentListCell class];
    }
    // 房源概况
    if ([model isKindOfClass:[FHDetailHouseOutlineInfoModel class]]) {
        return [FHDetailHouseOutlineInfoCell class];
    }
    // 小区信息
    if ([model isKindOfClass:[FHDetailNeighborhoodInfoModel class]]) {
        return [FHDetailNeighborhoodInfoCell class];
    }
    // 小区评测
    if ([model isKindOfClass:[FHDetailNeighborhoodEvaluateModel class]]) {
        return [FHDetailNeighborhoodEvaluateCell class];
    }
    // 小区地图
    if ([model isKindOfClass:[FHDetailNeighborhoodMapInfoModel class]]) {
        return [FHDetailNeighborhoodMapInfoCell class];
    }
    // 购房小建议
    if ([model isKindOfClass:[FHDetailSuggestTipModel class]]) {
        return [FHDetailSuggestTipCell class];
    }
    // 同小区房源
    if ([model isKindOfClass:[FHDetailSameNeighborhoodHouseModel class]]) {
        return [FHDetailSameNeighborhoodHouseCell class];
    }
    // 周边小区
    if ([model isKindOfClass:[FHDetailRelatedNeighborhoodModel class]]) {
        return [FHDetailRelatedNeighborhoodCell class];
    }
    // 周边房源
    if ([model isKindOfClass:[FHDetailRelatedHouseModel class]]) {
        return [FHDetailRelatedHouseCell class];
    }
    // 免责声明
    if ([model isKindOfClass:[FHDetailDisclaimerModel class]]) {
        return [FHDetailDisclaimerCell class];
    }
    // 价格分析
    if ([model isKindOfClass:[FHDetailPureTitleModel class]]) {
        return [FHDetailPureTitleCell class];
    }
    if ([model isKindOfClass:[FHDetailPriceTrendCellModel class]]) {
        return [FHDetailErshouPriceChartCell class];
    }
    // 均价走势
    if ([model isKindOfClass:[FHDetailPriceRankModel class]]) {
        return [FHDetailPriceRankCell class];
    }
    // 房源榜单
    if ([model isKindOfClass:[FHDetailListEntranceModel class]]) {
        return [FHDetailListEntranceCell class];
    }
    // 订阅房源动态
    if ([model isKindOfClass:[FHDetailHouseSubscribeModel class]]) {
        return [FHDetailHouseSubscribeCell class];
    }
    // 均价对比
    if ([model isKindOfClass:[FHDetailAveragePriceComparisonModel class]]) {
        return [FHDetailAveragePriceComparisonCell class];
    }
    return [FHDetailBaseCell class];
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
            wSelf.detailController.isLoadingData = NO;
            wSelf.detailController.hasValidateData = NO;
            wSelf.bottomBar.hidden = YES;
            [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            NSDictionary *userInfo = error.userInfo;
            [wSelf addDetailRequestFailedLog:model.status.integerValue message:error.domain];
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
- (void)processDetailData:(FHDetailOldModel *)model {
    
    self.detailData = model;
    if (model.data.status != -1) {
        [self addDetailCoreInfoExcetionLog];
    }
    // 清空数据源
    [self.items removeAllObjects];
    // 添加头滑动图片 && 视频
    BOOL hasVideo = NO;
    
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
                            FHDetailHouseDataItemsHouseImageModel *imageModel = item.houseImageList[0];
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
        headerCellModel.vedioModel = itemModel;// 添加视频模型数据
        headerCellModel.contactViewModel = self.contactViewModel;
        [self.items addObject:headerCellModel];
    }else{
        // 添加头滑动图片
        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
        if (model.data.houseImage.count > 0) {            
            headerCellModel.houseImage = model.data.houseImage;
        }else{
            //无图片时增加默认图
            FHDetailHouseDataItemsHouseImageModel *imgModel = [FHDetailHouseDataItemsHouseImageModel new];
            headerCellModel.houseImage = @[imgModel];
        }
        
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
    if (model.data.baseInfo || model.data.certificate) {
        FHDetailPropertyListModel *propertyModel = [[FHDetailPropertyListModel alloc] init];
        propertyModel.baseInfo = model.data.baseInfo;
        propertyModel.certificate = model.data.certificate;
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
        FHDetailHouseDataItemsHouseImageModel *imageInfo = model.data.houseImage[0];
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
        FHSearchHouseDataItemsTagsModel *tagInfo = model.data.tags[0];
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
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailNeighborhoodInfoModel *infoModel = [[FHDetailNeighborhoodInfoModel alloc] init];
        infoModel.neighborhoodInfo = model.data.neighborhoodInfo;
        infoModel.tableView = self.tableView;
        [self.items addObject:infoModel];
    }
    // 小区评测
    if (model.data.neighborhoodInfo.evaluationInfo) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailNeighborhoodEvaluateModel *infoModel = [[FHDetailNeighborhoodEvaluateModel alloc] init];
        infoModel.evaluationInfo = model.data.neighborhoodInfo.evaluationInfo;
        infoModel.log_pb = model.data.neighborhoodInfo.logPb;
        [self.items addObject:infoModel];
    }
    // 地图
    if (model.data.neighborhoodInfo.gaodeLat.length > 0 && model.data.neighborhoodInfo.gaodeLng.length > 0) {
        FHDetailNeighborhoodMapInfoModel *infoModel = [[FHDetailNeighborhoodMapInfoModel alloc] init];
        infoModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
        infoModel.gaodeLng = model.data.neighborhoodInfo.gaodeLng;
        infoModel.title = model.data.neighborhoodInfo.name;
        infoModel.category = @"公交";
        
        [self.items addObject:infoModel];
    }

//    if (model.data.housePricingRank.analyseDetail.length > 0) {
//        
//        // 价格分析
//        FHDetailPureTitleModel *titleModel = [[FHDetailPureTitleModel alloc] init];
//        titleModel.title = @"价格分析";
//        [self.items addObject:titleModel];
//        if (model.data.housePricingRank.analyseDetail.length > 0) {
//            FHDetailPriceRankModel *priceRankModel = [[FHDetailPriceRankModel alloc] init];
//            priceRankModel.priceRank = model.data.housePricingRank;
//            [self.items addObject:priceRankModel];
//        }
//    }
    // 均价走势
    FHDetailPriceTrendCellModel *priceTrendModel = [[FHDetailPriceTrendCellModel alloc] init];
    priceTrendModel.priceTrends = model.data.priceTrend;
    priceTrendModel.neighborhoodInfo = model.data.neighborhoodInfo;
    priceTrendModel.pricingPerSqmV = model.data.pricingPerSqmV;
    priceTrendModel.hasSuggestion = (model.data.housePricingRank.buySuggestion.content.length > 0) ? YES : NO;
    priceTrendModel.tableView = self.tableView;
    [self.items addObject:priceTrendModel];
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

@end
