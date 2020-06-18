//
//  FHHouseOldDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//
#import "FHHouseOldDetailViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHOldDetailPhotoHeaderCell.h"
#import "FHDetailOldModel.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"
#import "FHDetailSameNeighborhoodHouseResponseModel.h"
#import "FHDetailGrayLineCell.h"
#import "FHDetailHouseNameCell.h"
#import "FHDetailErshouHouseCoreInfoCell.h"
#import "FHDetailPropertyListCorrectingCell.h"
#import "FHDetailPriceChangeHistoryCell.h"
#import "FHDetailAgentListCell.h"
#import "FHDetailHouseOutlineInfoCell.h"
#import "FHDetailSuggestTipCell.h"
#import "FHDetailSurroundingAreaCell.h"
#import "FHDetailRelatedHouseCell.h"
#import "FHDetailSameNeighborhoodHouseCell.h"
#import "FHDetailPriceChartCell.h"
#import "FHOldDetailDisclaimerCell.h"
#import "FHDetailPriceTrendCellModel.h"
#import "FHDetailPureTitleCell.h"
#import "FHDetailNeighborhoodInfoCorrectingCell.h"
#import "FHDetailMediaHeaderCorrectingCell.h"
#import "FHDetailNeighborhoodMapInfoCell.h"
#import "FHDetailNeighborhoodEvaluateCell.h"
#import "FHDetailListEntranceCell.h"
#import "FHDetailHouseSubscribeCorrectingCell.h"
#import "FHDetailAveragePriceComparisonCell.h"
#import "FHEnvContext.h"
#import "NSDictionary+TTAdditions.h"
#import <FHHouseBase/FHHouseFollowUpHelper.h>
#import <FHHouseBase/FHMainApi+Contact.h>
#import <FHHouseBase/FHUserTrackerDefine.h>
#import "FHDetailNewModel.h"
#import "FHODetailCommunityEntryCorrectingCell.h"
#import "FHDetailBlankLineCell.h"
#import "FHDetailDetectiveCell.h"
#import "FHDetailHouseReviewCommentCell.h"
#import "FHDetailUserHouseCommentCell.h"
#import <FHHouseBase/FHSearchHouseModel.h>
#import <FHHouseBase/FHHomeHouseModel.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "FHDetailQuestionPopView.h"
#import "FHDetailHouseTitleModel.h"
#import "FHDetailHouseOutlineInfoCorrectingCell.h"
#import "FHDetailListSectionTitleCell.h"
#import "FHOldDetailModuleHelper.h"
#import "FHDetailStaticMapCell.h"
#import "FHOldDetailStaticMapCell.h"
#import "FHDetailAccessCellModel.h"
#import "FHDetailNeighborhoodQACell.h"
#import "FHDetailNeighborhoodAssessCell.h"
#import "FHDetailNeighborhoodCommentsCell.h"
#import "FHDetailRecommendedCourtCell.h"
#import "FHDetailQACellModel.h"
#import "FHDetailAccessCellModel.h"
#import "FHDetailCommentsCellModel.h"
#import "FHDetailAdvisoryLoanCell.h"
#import "FHDetailPriceChangeNoticeCell.h"
#import "FHVRPreloadManager.h"
#import "TTSettingsManager.h"

extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHSubscribeHouseCacheKey;
extern NSString *const kFHPLoginhoneNumberCacheKey;
@interface FHHouseOldDetailViewModel ()
@property (nonatomic, assign)   NSInteger       requestRelatedCount;
@property (nonatomic, strong , nullable) FHDetailSameNeighborhoodHouseResponseDataModel *sameNeighborhoodHouseData;
@property (nonatomic, strong , nullable) FHDetailRelatedNeighborhoodResponseDataModel *relatedNeighborhoodData;
@property (nonatomic, strong , nullable) FHDetailRelatedHouseResponseDataModel *relatedHouseData;
@property (nonatomic, strong , nullable) FHHouseListDataModel *oldHouseRecommendedCourtData;
@property (nonatomic, copy , nullable) NSString *neighborhoodId;// 周边小区房源id
@property (nonatomic, weak , nullable) FHDetailAgentListModel *agentListModel;
@end
@implementation FHHouseOldDetailViewModel
// 注册cell类型
- (void)registerCellClasses {
    //顶部轮播
    [self.tableView registerClass:[FHOldDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderModel class])];
    //FHDetailMediaHeaderCell -----FHDetailMediaHeaderModel
    [self.tableView registerClass:[FHDetailMediaHeaderCorrectingCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailMediaHeaderCorrectingModel class])];
   //属性模块
    [self.tableView registerClass:[FHDetailErshouHouseCoreInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailErshouHouseCoreInfoModel class])];
    [self.tableView registerClass:[FHDetailPropertyListCorrectingCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPropertyListCorrectingModel class])];
    [self.tableView registerClass:[FHDetailPriceChangeHistoryCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPriceChangeHistoryModel class])];
    [self.tableView registerClass:[FHDetailPriceChangeNoticeCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPriceNoticeModel class])];
    
    //首付及月供
    [self.tableView registerClass:[FHDetailAdvisoryLoanCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAdvisoryLoanModel class])];
    //推荐经纪人
    [self.tableView registerClass:[FHDetailAgentListCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAgentListModel class])];
    //用户房源评价
    [self.tableView registerClass:[FHDetailUserHouseCommentCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailUserHouseCommentModel class])];
    //房源概况
    [self.tableView registerClass:[FHDetailHouseOutlineInfoCorrectingCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseOutlineInfoCorrectingModel class])];
    //购房小建议
    [self.tableView registerClass:[FHDetailSuggestTipCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailSuggestTipModel class])];
    [self.tableView registerClass:[FHDetailSurroundingAreaCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailSurroundingAreaModel class])];
    //周边房源
    [self.tableView registerClass:[FHDetailRelatedHouseCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRelatedHouseModel class])];
    //同小区房源
    [self.tableView registerClass:[FHDetailSameNeighborhoodHouseCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailSameNeighborhoodHouseModel class])];
    [self.tableView registerClass:[FHOldDetailDisclaimerCell class] forCellReuseIdentifier:NSStringFromClass([FHOldDetailDisclaimerModel class])];
    //推荐新盘
    [self.tableView registerClass:[FHDetailRecommendedCourtCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRecommendedCourtModel class])];
    //价格指数
    [self.tableView registerClass:[FHDetailPriceChartCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPriceTrendCellModel class])];
    //小区详情上标题
    [self.tableView registerClass:[FHDetailListSectionTitleCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailListSectionTitleModel class])];
    //小区详情
    [self.tableView registerClass:[FHDetailNeighborhoodInfoCorrectingCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodInfoCorrectingModel class])];
    // 房源榜单
    [self.tableView registerClass:[FHDetailListEntranceCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailListEntranceModel class])];
    //表单订阅
    [self.tableView registerClass:[FHDetailHouseSubscribeCorrectingCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseSubscribeCorrectingModel class])];
    //均价对比
    [self.tableView registerClass:[FHDetailAveragePriceComparisonCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAveragePriceComparisonModel class])];
    [self.tableView registerClass:[FHOldDetailStaticMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailStaticMapCellModel class])];
    //舒适指数
    [self.tableView registerClass:[FHDetailNeighborhoodMapInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodMapInfoModel class])];
    //ugc入口
    [self.tableView registerClass:[FHODetailCommunityEntryCorrectingCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailCommunityEntryModel class])];
    //经纪人带看房评
    [self.tableView registerClass:[FHDetailHouseReviewCommentCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseReviewCommentCellModel class])];
    //小区问答
    [self.tableView registerClass:[FHDetailNeighborhoodQACell class] forCellReuseIdentifier:NSStringFromClass([FHDetailQACellModel class])];
    //小区点评
    [self.tableView registerClass:[FHDetailNeighborhoodCommentsCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailCommentsCellModel class])];
    //小区攻略
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
    [FHHouseDetailAPI requestOldDetail:self.houseId ridcode:self.ridcode realtorId:self.realtorId bizTrace:self.detailController.bizTrace
logPB:self.listLogPB extraInfo:self.extraInfo completion:^(FHDetailOldModel * _Nullable model, NSError * _Nullable error) {
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
                [wSelf.navBar showMessageNumber];
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
    if (model.data.vouchModel && model.data.vouchModel.vouchStatus == 1) {
        [self.navBar configureVouchStyle];
    }
    // 清空数据源
    [self.items removeAllObjects];
    BOOL hasVideo = NO;
    BOOL hasVR = NO;
    BOOL isInstant = model.isInstantData;
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
    self.houseInfoBizTrace = model.data.bizTrace;
    self.contactViewModel.houseInfoBizTrace = model.data.bizTrace;
    // 添加头滑动图片 && 视频
    if (model.data.houseVideo && model.data.houseVideo.videoInfos.count > 0) {
        hasVideo = YES;
    }
    
    if (model.data.vrData && model.data.vrData.hasVr) {
        hasVR = YES;
        
        NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
        BOOL boolSwitchCityHome = [fhSettings tt_boolValueForKey:@"f_webview_preload_close"];
        
        if(!boolSwitchCityHome){
            [[FHVRPreloadManager sharedInstance] requestForSimilarHouseId:model.data.id];
        }
    }
    
    if (model.data.houseImageDictList.count > 0 || hasVideo || hasVR) {
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
                        FHHouseDetailImageListDataModel *item = model.data.houseImageDictList[i];
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

        FHDetailMediaHeaderCorrectingModel *headerCellModel = [[FHDetailMediaHeaderCorrectingModel alloc] init];
        headerCellModel.houseImageAssociateInfo = model.data.houseImageAssociateInfo;
        headerCellModel.houseImageDictList = model.data.houseImageDictList;
        if (!isInstant) {
            FHHouseDetailImageListDataModel *imgModel = [headerCellModel.houseImageDictList firstObject];
            imgModel.instantHouseImageList = [self instantHouseImages];
        }
        FHDetailHouseTitleModel *houseTitleModel = [[FHDetailHouseTitleModel alloc] init];
        houseTitleModel.housetype = self.houseType;
        houseTitleModel.titleStr = model.data.title;
        houseTitleModel.tags = model.data.tags;
        if (model.data.vouchModel && model.data.vouchModel.vouchStatus == 1) {
            houseTitleModel.businessTag = @"企业担保";
            houseTitleModel.advantage = model.data.vouchModel.vouchText;
        }
        headerCellModel.vrModel = model.data.vrData;
        headerCellModel.vedioModel = itemModel;// 添加视频模型数据
        headerCellModel.contactViewModel = self.contactViewModel;
        headerCellModel.isInstantData = model.isInstantData;
        headerCellModel.titleDataModel = houseTitleModel;
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
        FHDetailHouseTitleModel *houseTitleModel = [[FHDetailHouseTitleModel alloc] init];
        houseTitleModel.titleStr = model.data.title;
        houseTitleModel.tags = model.data.tags;
        if (model.data.vouchModel && model.data.vouchModel.vouchStatus == 1) {
            houseTitleModel.businessTag = @"企业担保";
            houseTitleModel.advantage = model.data.vouchModel.vouchText;
        }
        
        headerCellModel.titleDataModel = houseTitleModel;
        headerCellModel.isInstantData = model.isInstantData;
        [self.items addObject:headerCellModel];
        
    }
    if (model.data.quickQuestion.questionItems.count > 0) {
        self.questionBtn.hidden = NO;
        [self.questionBtn updateTitle:model.data.quickQuestion.buttonContent];
    }
    // 添加core info
    if (model.data.coreInfo) {
        FHDetailErshouHouseCoreInfoModel *coreInfoModel = [[FHDetailErshouHouseCoreInfoModel alloc] init];
        coreInfoModel.coreInfo = model.data.coreInfo;
        coreInfoModel.houseModelType = FHHouseModelTypeCoreInfo;
        [self.items addObject:coreInfoModel];
    }
    // 价格变动
    if (model.data.priceChangeHistory && !model.data.priceChangeNotice) {
        FHDetailPriceChangeHistoryModel *priceChangeHistoryModel = [[FHDetailPriceChangeHistoryModel alloc] init];
        priceChangeHistoryModel.priceChangeHistory = model.data.priceChangeHistory;
        priceChangeHistoryModel.houseModelType = FHHouseModelTypeCoreInfo;
        priceChangeHistoryModel.baseViewModel = self;
        [self.items addObject:priceChangeHistoryModel];
    }
    
        // 价格变动
        if (model.data.priceChangeNotice && model.data.priceChangeNotice.showType != 0) {
            FHDetailPriceNoticeModel *priceChangeNoticeModel = [[FHDetailPriceNoticeModel alloc] init];
            priceChangeNoticeModel.priceChangeNotice = model.data.priceChangeNotice;
            priceChangeNoticeModel.houseModelType = FHHouseModelTypeCoreInfo;
            priceChangeNoticeModel.associateInfo =  model.data.middleSubscriptionAssociateInfo;
            priceChangeNoticeModel.baseViewModel = self;
            priceChangeNoticeModel.contactModel = self.contactViewModel;
            [self.items addObject:priceChangeNoticeModel];
        }
    // 添加属性列表
    if (model.data.baseInfo || model.data.certificate || model.data.baseExtra) {
        FHDetailPropertyListCorrectingModel *propertyModel = [[FHDetailPropertyListCorrectingModel alloc] init];
        propertyModel.baseInfo = model.data.baseInfo;
        propertyModel.certificate = model.data.certificate;
        propertyModel.houseModelType = FHHouseModelTypeCoreInfo;
        propertyModel.extraInfo = model.data.baseExtra;
        propertyModel.contactViewModel = self.contactViewModel;
        [self.items addObject:propertyModel];
    }
    // 首付及月供模块
    if (model.data.downPaymentInfo) {
        FHDetailAdvisoryLoanModel *advisoryLoanModel = [[FHDetailAdvisoryLoanModel alloc]init];
        advisoryLoanModel.houseModelType = FHHouseModelTypeAdvisoryLoan;
        advisoryLoanModel.downPayment = model.data.downPaymentInfo;
         advisoryLoanModel.contactModel = self.contactViewModel;
        advisoryLoanModel.baseViewModel = self;
         [self.items addObject:advisoryLoanModel];
    }
    //添加订阅房源动态卡片
    if(([self isShowSubscribe]) && !model.data.downPaymentInfo){
        FHDetailHouseSubscribeCorrectingModel *subscribeModel = [[FHDetailHouseSubscribeCorrectingModel alloc] init];
        subscribeModel.tableView = self.tableView;
        subscribeModel.houseModelType = FHHouseModelTypeSubscribe;
        subscribeModel.associateInfo = model.data.middleSubscriptionAssociateInfo;
        [self.items addObject:subscribeModel];
        
        __weak typeof(self) wSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ((FHDetailHouseSubscribeCorrectingCell *)subscribeModel.cell) {
                ((FHDetailHouseSubscribeCorrectingCell *)subscribeModel.cell).subscribeBlock = ^(NSString * _Nonnull phoneNum) {
                    [wSelf subscribeFormRequest:phoneNum subscribeModel:subscribeModel];
                };
                ((FHDetailHouseSubscribeCorrectingCell *)subscribeModel.cell).legalAnnouncementClickBlock = ^() {
                    NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
                    NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
                    [[TTRoute sharedRoute]openURLByPushViewController:url];
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
//    // 幸福天眼
//    __weak typeof(self)wself = self;
//    if (model.data.baseExtra.detective) {
//        FHDetailDetectiveModel *detectiveModel = [[FHDetailDetectiveModel alloc] init];
//        detectiveModel.detective = model.data.baseExtra.detective;
//        detectiveModel.feedBack = ^(NSInteger type, id  _Nonnull data, void (^ _Nonnull compltion)(BOOL)) {
//            [wself poplayerFeedBack:data type:type completion:compltion];
//        };
//        [self.items addObject:detectiveModel];
//    }
    // 房源概况
    if (model.data.houseOverreview.list.count > 0) {        
        FHDetailHouseOutlineInfoCorrectingModel *infoModel = [[FHDetailHouseOutlineInfoCorrectingModel alloc] init];
        infoModel.houseOverreview = model.data.houseOverreview;
        infoModel.baseViewModel = self;
        infoModel.tableView = self.tableView;
        infoModel.houseModelType = FHHouseModelTypeOutlineInfo;
        infoModel.hideReport = NO;
        [self.items addObject:infoModel];
    }
    // 房源榜单
    if (model.data.listEntrance.count > 0) {
        FHDetailListEntranceModel *entranceModel = [[FHDetailListEntranceModel alloc] init];
        entranceModel.houseModelType = FHHouseModelTypeBillBoard;
        entranceModel.listEntrance = model.data.listEntrance;
        [self.items addObject:entranceModel];
    }
    
    // 推荐经纪人
    if (model.data.recommendedRealtors.count > 0) {
        FHDetailAgentListModel *agentListModel = [[FHDetailAgentListModel alloc] init];
        NSString *searchId = self.listLogPB[@"search_id"];
        NSString *imprId = self.listLogPB[@"impr_id"];
        agentListModel.tableView = self.tableView;
        agentListModel.belongsVC = self.detailController;
        agentListModel.houseModelType = FHHouseModelTypeAgentlist;
        agentListModel.recommendedRealtorsTitle = model.data.recommendedRealtorsTitle;
        agentListModel.recommendedRealtors = model.data.recommendedRealtors;
        agentListModel.associateInfo = model.data.recommendRealtorsAssociateInfo;
        agentListModel.phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeSecondHandHouse houseId:self.houseId];
        [agentListModel.phoneCallViewModel generateImParams:self.houseId houseTitle:model.data.title houseCover:imgUrl houseType:houseType  houseDes:houseDes housePrice:price houseAvgPrice:avgPrice];
        agentListModel.phoneCallViewModel.tracerDict = self.detailTracerDic.mutableCopy;
        //        agentListModel.phoneCallViewModel.followUpViewModel = self.contactViewModel.followUpViewModel;
        //        agentListModel.phoneCallViewModel.followUpViewModel.tracerDict = self.detailTracerDic;
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
        self.agentListModel = agentListModel;
    }
    
    if(model.data.houseReviewComment.count > 0){
        
        NSString *searchId = self.listLogPB[@"search_id"];
        NSString *imprId = self.listLogPB[@"impr_id"];
        
        FHDetailHouseReviewCommentCellModel * houseReviewCommentModel = [[FHDetailHouseReviewCommentCellModel alloc] init];
        houseReviewCommentModel.tableView = self.tableView;
        houseReviewCommentModel.belongsVC = self.detailController;
        houseReviewCommentModel.houseModelType = FHHouseModelTypeHousingEvaluation;
        houseReviewCommentModel.houseReviewComment = model.data.houseReviewComment;
        houseReviewCommentModel.phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeSecondHandHouse houseId:self.houseId];
        [houseReviewCommentModel.phoneCallViewModel generateImParams:self.houseId houseTitle:model.data.title houseCover:imgUrl houseType:houseType  houseDes:houseDes housePrice:price houseAvgPrice:avgPrice];
        houseReviewCommentModel.phoneCallViewModel.tracerDict = self.detailTracerDic.mutableCopy;
        houseReviewCommentModel.searchId = searchId;
        houseReviewCommentModel.imprId = imprId;
        houseReviewCommentModel.houseId = self.houseId;
        houseReviewCommentModel.houseType = self.houseType;
        houseReviewCommentModel.associateInfo = model.data.houseReviewCommentAssociateInfo;
        [self.items addObject:houseReviewCommentModel];
    }
    
    
    //用户房源评价
    if (model.data.userHouseComments.count > 0) {
        FHDetailUserHouseCommentModel *userHouseCommentModel = [[FHDetailUserHouseCommentModel alloc] init];
        userHouseCommentModel.houseModelType = FHHouseModelTypeHousingEvaluation;
        userHouseCommentModel.userComments = model.data.userHouseComments;
        [self.items addObject:userHouseCommentModel];
    }
    
    BOOL hasOtherNeighborhoodInfo = NO;
    if ((model.data.strategy && model.data.strategy.articleList.count > 0) || (model.data.comments) || (model.data.question)) {
        hasOtherNeighborhoodInfo = YES;
    }
    
    // 小区信息
    if (model.data.neighborhoodInfo.id.length > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        //ugc 圈子入口,写在这儿是因为如果小区模块移除，那么圈子入口也不展示
//        BOOL showUgcEntry = model.data.ugcSocialGroup && model.data.ugcSocialGroup.activeCountInfo && model.data.ugcSocialGroup.activeInfo.count > 0;
        FHDetailNeighborhoodInfoCorrectingModel *infoModel = [[FHDetailNeighborhoodInfoCorrectingModel alloc] init];
        infoModel.neighborhoodInfo = model.data.neighborhoodInfo;
        if(hasOtherNeighborhoodInfo){
            infoModel.houseModelType = FHHouseModelTypeNeighborhoodInfo;
        }else{
            infoModel.houseModelType = FHHouseModelTypeLocationPeriphery;
        }
        infoModel.tableView = self.tableView;
        infoModel.contactViewModel = self.contactViewModel;
        [self.items addObject:infoModel];
        //这个功能不要了 by xsm
//        if(showUgcEntry){
//            model.data.ugcSocialGroup.houseType = FHHouseTypeSecondHandHouse;
//            if(hasOtherNeighborhoodInfo){
//                model.data.ugcSocialGroup.houseModelType = FHHouseModelTypeNeighborhoodInfo;
//            }else{
//                model.data.ugcSocialGroup.houseModelType = FHHouseModelTypeLocationPeriphery;
//            }
//            [self.items addObject:model.data.ugcSocialGroup];
//        } else{
            //            FHDetailBlankLineModel *whiteLine = [[FHDetailBlankLineModel alloc] init];
            //            [self.items addObject:whiteLine];
//        }
        
    }
    
    // 小区评测
    if (model.data.strategy && model.data.strategy.articleList.count > 0) {
        
        FHDetailAccessCellModel *cellModel = [[FHDetailAccessCellModel alloc] init];
        cellModel.houseModelType = FHPlotHouseModelTypeNeighborhoodStrategy;
        cellModel.strategy = model.data.strategy;
        cellModel.topMargin = 0.0f;
        
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
    
    // 小区点评
    if(model.data.comments) {
        FHDetailCommentsCellModel *commentsModel = [[FHDetailCommentsCellModel alloc] init];
        commentsModel.neighborhoodId = model.data.neighborhoodInfo.id;
        commentsModel.houseId = self.houseId;
        NSMutableDictionary *paramsDict = @{}.mutableCopy;
        if (self.detailTracerDic) {
            [paramsDict addEntriesFromDictionary:self.detailTracerDic];
        }
        paramsDict[@"page_type"] = [self pageTypeString];
        commentsModel.tracerDict = paramsDict;
        commentsModel.topMargin = 12;
        commentsModel.bottomMargin = 22.0f;
        commentsModel.comments = model.data.comments;
        commentsModel.houseModelType = FHPlotHouseModelTypeNeighborhoodComment;
        [self.items addObject:commentsModel];
    }
    
    // 小区问答
    if (model.data.question) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailQACellModel *qaModel = [[FHDetailQACellModel alloc] init];
        qaModel.neighborhoodId = model.data.neighborhoodInfo.id;
        NSMutableDictionary *paramsDict = @{}.mutableCopy;
        if (self.detailTracerDic) {
            [paramsDict addEntriesFromDictionary:self.detailTracerDic];
        }
        paramsDict[@"page_type"] = [self pageTypeString];
        qaModel.tracerDict = paramsDict;
        qaModel.topMargin = 0.0f;
        qaModel.question = model.data.question;
        qaModel.houseModelType = FHPlotHouseModelTypeNeighborhoodQA;
        [self.items addObject:qaModel];
    }
    

    //地图
    if(model.data.neighborhoodInfo.gaodeLat.length > 0 && model.data.neighborhoodInfo.gaodeLng.length > 0){
        FHDetailStaticMapCellModel *staticMapModel = [[FHDetailStaticMapCellModel alloc] init];
        staticMapModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
        staticMapModel.gaodeLng = model.data.neighborhoodInfo.gaodeLng;
        staticMapModel.houseModelType = FHHouseModelTypeLocationPeriphery;
        staticMapModel.houseId = model.data.id;
        staticMapModel.houseType = [NSString stringWithFormat:@"%d",FHHouseTypeSecondHandHouse];
        //todo zlj review check
        staticMapModel.mapCentertitle = model.data.neighborhoodInfo.name;
        staticMapModel.title = model.data.neighborEval.title;
        staticMapModel.score = model.data.neighborEval.score;
        staticMapModel.tableView = self.tableView;
        staticMapModel.staticImage = model.data.neighborhoodInfo.gaodeImage;
        staticMapModel.mapOnly = NO;
        if(hasOtherNeighborhoodInfo){
            staticMapModel.topMargin = 30;
            staticMapModel.bottomMargin = 0;
        }else{
            staticMapModel.topMargin = 0;
            staticMapModel.bottomMargin = 30;
        }
        [self.items addObject:staticMapModel];
    } else{
        NSString *eventName = @"detail_map_location_failed";
        NSDictionary *cat = @{@"status": @(1)};

        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
        [params setValue:@"经纬度缺失" forKey:@"reason"];
        [params setValue:model.data.id forKey:@"house_id"];
        [params setValue:@(FHHouseTypeSecondHandHouse) forKey:@"house_type"];
        [params setValue:model.data.neighborhoodInfo.name forKey:@"name"];

        [[HMDTTMonitor defaultManager] hmdTrackService:eventName metric:nil category:cat extra:params];
    }
    // 均价走势
    if (model.data.priceTrend.count > 0) {
        FHDetailPriceTrendCellModel *priceTrendModel = [[FHDetailPriceTrendCellModel alloc] init];
        priceTrendModel.housetype = self.houseType;
        priceTrendModel.priceTrends = model.data.priceTrend;
        priceTrendModel.neighborhoodInfo = model.data.neighborhoodInfo;
        priceTrendModel.pricingPerSqmV = model.data.pricingPerSqmV;
        priceTrendModel.priceAnalyze = model.data.priceAnalyze;
        priceTrendModel.houseModelType = FHHouseModelTypeLocationPeriphery;
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
        infoModel.houseModelType =  FHHouseModelTypeLocationPeriphery;
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
        NSMutableDictionary *paramsDict = @{}.mutableCopy;
        if (self.detailTracerDic) {
            [paramsDict addEntriesFromDictionary:self.detailTracerDic];
        }
        paramsDict[@"page_type"] = [self pageTypeString];
        infoModel.buySuggestion = model.data.housePricingRank.buySuggestion;
                infoModel.extraInfo = model.data.baseExtra;
        infoModel.contactViewModel = self.contactViewModel;
        infoModel.contactPhone = contactPhone;
        infoModel.houseModelType = FHHouseModelTypeTips;
        [self.items addObject:infoModel];
    }
    self.items = [FHOldDetailModuleHelper moduleClassificationMethod:self.items];
    
    // --
    [self.contactViewModel generateImParams:self.houseId houseTitle:model.data.title houseCover:imgUrl houseType:houseType  houseDes:houseDes housePrice:price houseAvgPrice:avgPrice];
    

    self.contactViewModel.contactPhone = contactPhone;
    self.contactViewModel.shareInfo = model.data.shareInfo;
    self.contactViewModel.subTitle = model.data.reportToast;
    self.contactViewModel.toast = model.data.reportDoneToast;
    self.contactViewModel.followStatus = model.data.userStatus.houseSubStatus;
    self.contactViewModel.chooseAgencyList = model.data.chooseAgencyList;
    self.contactViewModel.highlightedRealtorAssociateInfo = model.data.highlightedRealtorAssociateInfo;
    if (model.isInstantData) {
        [self.tableView reloadData];
    }else{
        [self reloadData];
    }
    
    [self.detailController updateLayout:model.isInstantData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTAppStoreStarManagerShowNotice" object:nil userInfo:@{@"trigger":@"old_detail"}];
    });
    
}

- (void)vc_viewDidDisappear:(BOOL)animated
{
    [super vc_viewDidDisappear:animated];
    [self.agentListModel.phoneCallViewModel vc_viewDidDisappear:animated];
}

- (void)vc_viewDidAppear:(BOOL)animated
{
    [super vc_viewDidAppear:animated];
    [self.agentListModel.phoneCallViewModel vc_viewDidAppear:animated];
}

// 周边数据请求，当网络请求都返回后刷新数据
- (void)requestRelatedData:(NSString *)neighborhoodId {
    self.requestRelatedCount = 0;
    if (neighborhoodId.length > 0) {
        // 同小区房源
        [self requestHouseInSameNeighborhoodSearch:neighborhoodId];
        // 周边小区
        [self requestRelatedNeighborhoodSearch:neighborhoodId];
    } else {
        self.requestRelatedCount = 2;
    }
    // 周边房源
    [self requestRelatedHouseSearch];
    // 推荐新房
    [self requestOldHouseRecommendedCourtSearch];
}

// 处理详情页周边请求数据
- (void)processDetailRelatedData {
    if (self.requestRelatedCount >= 4) {
        self.detailController.isLoadingData = NO;
        //  同小区房源
        if (self.sameNeighborhoodHouseData && self.sameNeighborhoodHouseData.items.count > 0) {
            FHDetailSameNeighborhoodHouseModel *infoModel = [[FHDetailSameNeighborhoodHouseModel alloc] init];
            infoModel.houseModelType = FHHouseModelTypePlot;
            infoModel.sameNeighborhoodHouseData = self.sameNeighborhoodHouseData;
            [self.items addObject:infoModel];
        }
        // 周边小区
        if (self.relatedNeighborhoodData && self.relatedNeighborhoodData.items.count > 0) {
            FHDetailSurroundingAreaModel *infoModel = [[FHDetailSurroundingAreaModel alloc] init];
            infoModel.relatedNeighborhoodData = self.relatedNeighborhoodData;
            infoModel.houseModelType = FHHouseModelTypePlot;
            infoModel.neighborhoodId = self.neighborhoodId;
            [self.items addObject:infoModel];
        }
        // 推荐新房
        if (self.oldHouseRecommendedCourtData && self.oldHouseRecommendedCourtData.items.count >0) {
            FHDetailRecommendedCourtModel *infoModel = [[FHDetailRecommendedCourtModel alloc] init];
            infoModel.recommendedCourtData = self.oldHouseRecommendedCourtData;
            infoModel.houseModelType = FHHouseeModelTypeOldHouseRecommendedCourt;
            [self.items addObject:infoModel];

        }
        // 周边房源
        if (self.relatedHouseData && self.relatedHouseData.items.count > 0) {
            FHDetailRelatedHouseModel *infoModel = [[FHDetailRelatedHouseModel alloc] init];
            infoModel.houseModelType = FHHouseModelTypePeriphery;
            infoModel.relatedHouseData = self.relatedHouseData;
            [self.items addObject:infoModel];
        }
        // 免责声明
        FHDetailOldModel * model = (FHDetailOldModel *)self.detailData;
        if (model.data.contact || model.data.disclaimer) {
            FHOldDetailDisclaimerModel *infoModel = [[FHOldDetailDisclaimerModel alloc] init];
            infoModel.disclaimer = model.data.disclaimer;
            infoModel.houseModelType = FHHouseModelTypeDisclaimer;
            if (!model.data.highlightedRealtor) {
                // 当且仅当没有合作经纪人时，才在disclaimer中显示 经纪人 信息
                infoModel.contact = model.data.contact;
            } else {
                infoModel.contact = nil;
            }
            [self.items addObject:infoModel];
        }
         self.items = [FHOldDetailModuleHelper moduleClassificationMethod:self.items];
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
    [FHHouseDetailAPI requestRelatedHouseSearch:self.houseId searchId:nil offset:@"0" query:nil count:5 completion:^(FHDetailRelatedHouseResponseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.requestRelatedCount += 1;
        wSelf.relatedHouseData = model.data;
        [wSelf processDetailRelatedData];
    }];
}

//推荐新房
- (void)requestOldHouseRecommendedCourtSearch {
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestOldHouseRecommendedCourtSearch:self.houseId offset:@"0" query:nil count:5 completion:^(FHListResultHouseModel * _Nullable model, NSError * _Nullable error) {
        wSelf.requestRelatedCount += 1;
        wSelf.oldHouseRecommendedCourtData = model.data;
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

- (void)subscribeFormRequest:(NSString *)phoneNum subscribeModel:(FHDetailHouseSubscribeCorrectingModel *)subscribeModel {
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    NSString *houseId = self.houseId;
    NSString *from = @"app_oldhouse_subscription";
    NSDictionary *extraInfo = nil;
    
    if (self.houseInfoBizTrace) {
        extraInfo = @{@"biz_trace":self.houseInfoBizTrace};
    }

    [FHMainApi requestCallReportByHouseId:houseId phone:phoneNum from:nil cluePage:nil clueEndpoint:nil targetType:nil reportAssociate:subscribeModel.associateInfo.reportFormInfo agencyList:nil extraInfo:extraInfo completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {

//    [FHMainApi requestSendPhoneNumbserByHouseId:houseId phone:phoneNum from:from cluePage:nil clueEndpoint:nil targetType:nil agencyList:nil completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (model.status.integerValue == 0 && !error) {
            FHDetailOldModel * model = (FHDetailOldModel *)self.detailData;
            NSString *toast =@"提交成功，经纪人将尽快与您联系";
            if (model.data.subscriptionToast && model.data.subscriptionToast.length > 0) {
                toast = model.data.subscriptionToast;
            }
            [[ToastManager manager] showToast:toast];
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache setObject:phoneNum forKey:kFHPhoneNumberCacheKey];
            
            YYCache *subscribeHouseCache = [[FHEnvContext sharedInstance].generalBizConfig subscribeHouseCache];
            [subscribeHouseCache setObject:@"1" forKey:wself.houseId];
            
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
    
    NSMutableDictionary *trackInfo = [NSMutableDictionary new];
    trackInfo[UT_PAGE_TYPE] = self.detailTracerDic[UT_PAGE_TYPE];
    trackInfo[UT_ELEMENT_FROM] = self.detailTracerDic[UT_ELEMENT_FROM]?:UT_BE_NULL;
    trackInfo[UT_ORIGIN_FROM] = self.detailTracerDic[UT_ORIGIN_FROM];
    trackInfo[UT_ORIGIN_SEARCH_ID] = self.detailTracerDic[UT_ORIGIN_SEARCH_ID];
    trackInfo[UT_LOG_PB] = self.detailTracerDic[UT_LOG_PB];
    trackInfo[@"rank"] = self.detailTracerDic[@"rank"];
    trackInfo[UT_ENTER_FROM] = self.detailTracerDic[UT_ENTER_FROM];
    
    NSString *position = nil;
    FHDetailHalfPopLayer *popLayer = [self popLayer];
    if ([model isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        position = @"official_inspection";
        trackInfo[UT_ENTER_FROM] = position;
        [popLayer showWithOfficialData:(FHDetailDataBaseExtraOfficialModel *)model trackInfo:trackInfo];
        
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]]) {
        position = @"low_price_cause";
        //        trackInfo[UT_ENTER_FROM] = position;
        [popLayer showDetectiveReasonInfoData:(FHDetailDataBaseExtraDetectiveReasonInfo *)model trackInfo:trackInfo];
    }
        else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
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

- (void)addPopShowLog:(NSString *)position
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
