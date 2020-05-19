//
//  FHHouseNewDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseNewDetailViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailNewModel.h"
#import "FHDetailBaseCell.h"
#import "FHDetailNearbyMapCell.h"
#import "FHDetailPhotoHeaderCell.h"
#import "FHDetailHouseNameCell.h"
#import "FHDetailNewTimeLineItemCell.h"
//#import "FHDetailNewHouseCoreInfoCell.h"
#import "FHDetailNewHouseNewsCell.h"
#import "FHDetailTimelineItemCorrectingCell.h"

#import "FHDetailNewMutiFloorPanCell.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHDetailRelatedCourtModel.h"
#import "FHNewHouseItemModel.h"
#import "FHDetailDisclaimerCell.h"

#import "FHDetailStaticMapCell.h"
#import "HMDTTMonitor.h"
#import <FHHouseBase/FHCommonDefines.h>
#import "FHDetailNewUGCSocialCell.h"
#import "FHDetailSocialEntranceView.h"
#import "FHHouseFillFormHelper.h"
#import "FHHouseContactConfigModel.h"
#import "FHDetailNoticeAlertView.h"
#import "TTDeviceHelper+FHHouse.h"
#import "TTUIResponderHelper.h"
#import "FHDetailAgentListCell.h"
#import "FHDetailMediaHeaderCorrectingCell.h"
#import "FHNewDetailModuleHelper.h"
#import "FHDetailCourtInfoCell.h"
#import "FHDetailListSectionTitleCell.h"
#import "FHOldDetailStaticMapCell.h""
#import "FHDetailSalesCell.h"
#import "FHDetailNewAddressInfoCell.h"
#import "FHDetailNewPriceNotifyCell.h"
#import "FHDetailNewPropertyListCell.h"
#import "FHOldDetailDisclaimerCell.h"
#import "FHHouseListBaseItemCell.h"
#import "FHHouseListBaseItemModel.h"
#import "FHDetailNewRelatedCell.h"
#import "FHDetailNeighborhoodAssessCell.h"
#import "FHDetailAccessCellModel.h"

@interface FHHouseNewDetailViewModel ()

@property (nonatomic, strong , nullable) FHListResultHouseModel *relatedHouseData;

@property (nonatomic, strong , nullable) FHDetailNewModel *dataModel;

//@property (nonatomic, strong , nullable) FHDetailNewModel *newDetailDataModel;
@property (nonatomic, weak)     FHHouseNewsSocialModel       *weakSocialInfo;

@end

@implementation FHHouseNewDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    
//    [self.tableView registerClass:[FHDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderModel class])];
    [self.tableView registerClass:[FHDetailMediaHeaderCorrectingCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailMediaHeaderCorrectingModel class])];
    
//    [self.tableView registerClass:[FHDetailHouseNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseNameModel class])];
    
//    [self.tableView registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineModel class])];
        
    [self.tableView registerClass:[FHDetailNewMutiFloorPanCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewMutiFloorPanCellModel class])];
    [self.tableView registerClass:[FHDetailNewHouseNewsCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewHouseNewsCellModel class])];
    
    [self.tableView registerClass:[FHOldDetailDisclaimerCell class] forCellReuseIdentifier:NSStringFromClass([FHOldDetailDisclaimerModel class])];
    
    [self.tableView registerClass:[FHDetailTimelineItemCorrectingCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewTimeLineItemCorrectingModel class])];
    
//    [self.tableView registerClass:[FHDetailNearbyMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNearbyMapModel class])];
    
    
    [self.tableView registerClass:[FHOldDetailStaticMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailStaticMapCellModel class])];
    
    [self.tableView registerClass:[FHDetailNewUGCSocialCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewUGCSocialCellModel class])];
    //推荐经纪人
    [self.tableView registerClass:[FHDetailAgentListCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAgentListModel class])];
    
    [self.tableView registerClass:[FHDetailCourtInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailCourtInfoCellModel class])];
    [self.tableView registerClass:[FHDetailListSectionTitleCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailListSectionTitleModel class])];
    [self.tableView registerClass:[FHDetailSalesCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailSalesCellModel class])];
    
    [self.tableView registerClass:[FHDetailNewAddressInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewAddressInfoCellModel class])];
    [self.tableView registerClass:[FHDetailNewPriceNotifyCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewPriceNotifyCellModel class])];
    [self.tableView registerClass:[FHDetailNewPropertyListCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewPropertyListCellModel class])];
    
    //周边新盘上标题
//    [self.tableView registerClass:[FHDetailListSectionTitleCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailListSectionTitleModel class])]
    [self.tableView registerClass:[FHDetailNewRelatedCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewRelatedCellModel class])];
    //楼盘攻略
    [self.tableView registerClass:[FHDetailNeighborhoodAssessCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailAccessCellModel class])];
}

// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

// 是否弹出ugc表单
- (BOOL)needShowSocialInfoForm:(id)model {
    if (self.houseType == FHHouseTypeNewHouse && self.weakSocialInfo) {
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
        UIViewController * viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: self.detailController];
        if (viewController != self.detailController) {
            return NO;
        }
        
        if ([model isKindOfClass:[FHHouseFillFormConfigModel class]]) {
            FHHouseFillFormConfigModel *configModel = (FHHouseFillFormConfigModel *)model;
            FHHouseType houseType = configModel.houseType;
            NSString *houseId = configModel.houseId;
            if (houseId.length > 0 && houseType == self.houseType && [self.houseId isEqualToString:houseId]) {
                // 同一个房源
            } else {
                return NO;
            }
        }
        if ([model isKindOfClass:[FHHouseContactConfigModel class]]) {
            FHHouseContactConfigModel *configModel = (FHHouseContactConfigModel *)model;
            FHHouseType houseType = configModel.houseType;
            NSString *houseId = configModel.houseId;
            if (houseId.length > 0 && houseType == self.houseType && [self.houseId isEqualToString:houseId]) {
                // 同一个房源
            } else {
                return NO;
            }
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
    CGFloat width = 280.0 * [TTDeviceHelper scaleToScreen375];
    if (![TTDeviceHelper isScreenWidthLarge320]) {
        width = 280;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startLoadData
{
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestNewDetail:self.houseId logPB:self.listLogPB extraInfo:self.extraInfo completion:^(FHDetailNewModel * _Nullable model, NSError * _Nullable error) {
        if ([model isKindOfClass:[FHDetailNewModel class]] && !error) {
            if (model.data) {
                wSelf.dataModel = model;
                wSelf.detailController.hasValidateData = YES;
                [wSelf.detailController.emptyView hideEmptyView];
                wSelf.bottomBar.hidden = NO;
                [wSelf processDetailData:model];
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


-(BOOL)currentIsInstantData
{
    return [(FHDetailNewModel *)self.detailData isInstantData];
}

-(NSArray *)instantHouseImages
{
    id data = self.detailController.instantData;
    if ([data isKindOfClass:[FHNewHouseItemModel class ]]) {
        
        FHNewHouseItemModel *item = (FHNewHouseItemModel *)data;
        return item.images;
        
    }else if ([data isKindOfClass:[FHHomeHouseDataItemsModel class]]){
        FHHomeHouseDataItemsModel *item = (FHHomeHouseDataItemsModel *)data;
        return item.images;
    }
    return nil;
}

- (void)processDetailData:(FHDetailNewModel *)model{
    self.detailData = model;
    [self addDetailCoreInfoExcetionLog];
    
    // 清空数据源
    [self.items removeAllObjects];
    FHDetailContactModel *contactPhone = nil;
    
    if (model.data.highlightedRealtor) {
        contactPhone = model.data.highlightedRealtor;
    }else {
        contactPhone = model.data.contact;
    }
    if (contactPhone.phone.length > 0) {
        contactPhone.isFormReport = NO;
    }else {
        contactPhone.isFormReport = YES;
    }
    self.contactViewModel.contactPhone = contactPhone;
    self.contactViewModel.shareInfo = model.data.shareInfo;
    self.contactViewModel.followStatus = model.data.userStatus.courtSubStatus;
    self.contactViewModel.chooseAgencyList = model.data.chooseAgencyList;
    self.contactViewModel.socialInfo = model.data.socialInfo;
    self.contactViewModel.highlightedRealtorAssociateInfo = model.data.highlightedRealtorAssociateInfo;
    self.weakSocialInfo = model.data.socialInfo;
    
    __weak typeof(self) wSelf = self;
    if (!model.isInstantData && model.data) {
        [FHHouseDetailAPI requestRelatedFloorSearch:self.houseId offset:@"0" query:nil count:0 completion:^(FHListResultHouseModel * _Nullable model, NSError * _Nullable error) {
            wSelf.relatedHouseData = model;
            [wSelf processDetailRelatedData];
        }];
    }
    BOOL hasVideo = NO;
    BOOL hasVR = NO;
    BOOL isInstant = model.isInstantData;
    BOOL showTitleMapBtn = NO;
    if (model.data.coreInfo.gaodeLat.length>0 && model.data.coreInfo.gaodeLng.length>0) {
        showTitleMapBtn = YES;
    }else {
        showTitleMapBtn = NO;
    }
    // 添加头滑动图片 && 视频
    if (1) {
        FHMultiMediaItemModel *itemModel = nil;
        
        FHDetailMediaHeaderCorrectingModel *headerCellModel = [[FHDetailMediaHeaderCorrectingModel alloc] init];
        headerCellModel.houseImageAssociateInfo = model.data.imageGroupAssociateInfo;
        headerCellModel.isShowTopImageTab = model.data.isShowTopImageTab;
        if ([model.data.topImages isKindOfClass:[NSArray class]] && model.data.topImages.count > 0) {
            NSMutableArray *houseImageList = @[].mutableCopy;
            headerCellModel.topImages = model.data.topImages;
            for (NSInteger index = 0; index < model.data.topImages.count; index++) {
                FHDetailNewTopImage *topImage = model.data.topImages[index];
                FHHouseDetailImageListDataModel *houseImageDictList = [[FHHouseDetailImageListDataModel alloc] init];
                NSMutableArray *houseImages = [NSMutableArray new];
                for (NSInteger i = 0; i < topImage.imageGroup.count; i++) {
                    FHDetailNewDataImageGroupModel * groupModel = topImage.imageGroup[i];
                    for (NSInteger j = 0; j < groupModel.images.count; j++) {
                        [houseImages addObject:groupModel.images[j]];
                    }
                }
                if (headerCellModel.isShowTopImageTab) {
                    houseImageDictList.houseImageTypeName = topImage.name;
                }
                houseImageDictList.usedSceneType = FHHouseDetailImageListDataUsedSceneTypeNew;
                houseImageDictList.houseImageList = houseImages;
                houseImageDictList.houseImageType = topImage.type;
                [houseImageList addObject:houseImageDictList];
            }
            headerCellModel.houseImageDictList = houseImageList;
        }
        
        FHDetailHouseTitleModel *houseTitleModel = [[FHDetailHouseTitleModel alloc] init];
        houseTitleModel.advantage = model.data.topBanner.advantage;
        houseTitleModel.businessTag = model.data.topBanner.businessTag;
        houseTitleModel.titleStr = model.data.coreInfo.name;
        houseTitleModel.tags = model.data.tags;
        houseTitleModel.housetype = self.houseType;
        headerCellModel.vedioModel = itemModel;// 添加视频模型数据
        headerCellModel.contactViewModel = self.contactViewModel;
        headerCellModel.isInstantData = model.isInstantData;
        headerCellModel.titleDataModel = houseTitleModel;
        [self.items addObject:headerCellModel];
    }else {
        // 添加头滑动图片
        
        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
        if (model.data.imageGroup.count > 0) {
            NSMutableArray *arrayHouseImage = [NSMutableArray new];
            for (NSInteger i = 0; i < model.data.imageGroup.count; i++) {
                FHDetailNewDataImageGroupModel * groupModel = model.data.imageGroup[i];
                for (NSInteger j = 0; j < groupModel.images.count; j++) {
                    [arrayHouseImage addObject:groupModel.images[j]];
                }
            }
            //            headerCellModel.isNewHouse = YES;
            //            headerCellModel.smallImageGroup = model.data.smallImageGroup;
            headerCellModel.houseImage = arrayHouseImage;
            //            FHDetailHouseTitleModel *houseTitleModel = [[FHDetailHouseTitleModel alloc] init];
            //            houseTitleModel.titleStr = model.data.coreInfo.name;
            //            houseTitleModel.address = model.data.coreInfo.courtAddress;
            //            houseTitleModel.showMapBtn = showTitleMapBtn;
            //            houseTitleModel.housetype = self.houseType;
            ////            houseTitleModel.neighborhoodInfoModel = model.data.coreInfo;
            //            __weak typeof(self)weakself = self;
            ////            houseTitleModel.mapImageClick = ^{
            ////                [weakself mapImageClick];
            ////            };
            //            houseTitleModel.tags = model.data.tags;
            //            headerCellModel.titleDataModel = houseTitleModel;
            //            headerCellModel.isInstantData = model.isInstantData;
        }else{
            //无图片时增加默认图
            FHImageModel *imgModel = [FHImageModel new];
            headerCellModel.houseImage = @[imgModel];
        }
        [self.items addObject:headerCellModel];
        
    }
    //    FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
    //    if (model.data.imageGroup) {
    //        NSMutableArray *arrayHouseImage = [NSMutableArray new];
    //        for (NSInteger i = 0; i < model.data.imageGroup.count; i++) {
    //            FHDetailNewDataImageGroupModel * groupModel = model.data.imageGroup[i];
    //            for (NSInteger j = 0; j < groupModel.images.count; j++) {
    //                [arrayHouseImage addObject:groupModel.images[j]];
    //            }
    //        }
    //
    //        headerCellModel.isNewHouse = YES;
    //        headerCellModel.smallImageGroup = model.data.smallImageGroup;
    //        headerCellModel.houseImage = arrayHouseImage;
    //        if (!model.isInstantData) {
    //            headerCellModel.instantHouseImages = [self instantHouseImages];
    //        }
    //        headerCellModel.isInstantData = model.isInstantData;
    //
    //    }else{
    //        //无图片时增加默认图
    //        FHImageModel *imgModel = [FHImageModel new];
    //        headerCellModel.houseImage = @[imgModel];
    //    }
    //    [self.items addObject:headerCellModel];
    //
    FHDetailHouseNameModel *houseName = [[FHDetailHouseNameModel alloc] init];
    // 添加标题
    if (model.data) {
        houseName.type = 1;
        houseName.name = model.data.coreInfo.name;
        houseName.aliasName = model.data.coreInfo.aliasName;
        houseName.type = 2;
        houseName.tags = model.data.tags;
        //        [self.items addObject:houseName];
    }
    
    //核心信息
    //    if (model.data.coreInfo) {
    //        FHDetailNewHouseCoreInfoModel *houseCore = [[FHDetailNewHouseCoreInfoModel alloc] init];
    //        houseCore.pricingPerSqm = model.data.coreInfo.pricingPerSqm;
    //        houseCore.constructionOpendate = model.data.coreInfo.constructionOpendate;
    //        houseCore.courtAddress = model.data.coreInfo.courtAddress;
    //        houseCore.pricingSubStauts = model.data.userStatus.pricingSubStatus;
    //        houseCore.gaodeLat = model.data.coreInfo.gaodeLat;
    //        houseCore.gaodeLng = model.data.coreInfo.gaodeLng;
    //        houseCore.courtId = model.data.coreInfo.id;
    //        houseCore.houseName = houseName;
    //        houseCore.contactModel = self.contactViewModel;
    ////        houseCore.houseModelType = FHHouseModelTypeNewCoreInfo;
    //        houseCore.disclaimerModel = [[FHDisclaimerModel alloc] initWithData:[self.dataModel.data.disclaimer toJSONData] error:nil];
    //
    //        [self.items addObject:houseCore];
    //    }
    
    // 基础信息
    if (model.data.baseInfo) {
        FHDetailNewPropertyListCellModel *houseCore = [[FHDetailNewPropertyListCellModel alloc] init];
        houseCore.houseModelType = FHHouseModelTypeNewCoreInfo;
        houseCore.baseInfo = model.data.baseInfo;
        FHDetailDisclaimerModel *disclaimerModel = [[FHDetailDisclaimerModel alloc]init];
        disclaimerModel.disclaimer =  [[FHDisclaimerModel alloc] initWithData:[model.data.disclaimer toJSONData] error:nil];
        disclaimerModel.contact = model.data.contact ;
        houseCore.disclaimerModel = disclaimerModel;
        houseCore.houseName = houseName;
        houseCore.courtId = model.data.coreInfo.id;
        [self.items addObject:houseCore];
        
    }
    
    // 地址信息
    FHDetailNewAddressInfoCellModel *addressInfo = [[FHDetailNewAddressInfoCellModel alloc] init];
    addressInfo.houseModelType = FHHouseModelTypeNewCoreInfo;
    addressInfo.name = model.data.coreInfo.name;
    addressInfo.courtId = model.data.coreInfo.id;
    addressInfo.gaodeLat = model.data.coreInfo.gaodeLat;
    addressInfo.gaodeLng = model.data.coreInfo.gaodeLng;
    addressInfo.courtAddress = model.data.coreInfo.courtAddress;
    addressInfo.courtAddressIcon = model.data.coreInfo.courtAddressIcon;
    [self.items addObject:addressInfo];
    
    // 变价通知
    FHDetailNewPriceNotifyCellModel *priceInfo = [[FHDetailNewPriceNotifyCellModel alloc] init];
    priceInfo.houseModelType = FHHouseModelTypeNewCoreInfo;
    priceInfo.contactModel = self.contactViewModel;
    priceInfo.priceAssociateInfo = model.data.changePriceNotifyAssociateInfo;
    priceInfo.openAssociateInfo = model.data.beginSellingNotifyAssociateInfo;
    [self.items addObject:priceInfo];
    
    // 优惠信息
    if (model.data.discountInfo) {
        FHDetailSalesCellModel *salesModel = [[FHDetailSalesCellModel alloc] init];
        salesModel.discountInfo = model.data.discountInfo;
        salesModel.houseModelType = FHHouseModelTypeNewSales;
        salesModel.contactViewModel = self.contactViewModel;
        [self.items addObject:salesModel];
    }
    
    //楼盘户型
    if ([model.data.floorpanList.list isKindOfClass:[NSArray class]] && model.data.floorpanList.list.count > 0) {
        
        FHDetailNewMutiFloorPanCellModel *floorPan = [[FHDetailNewMutiFloorPanCellModel alloc]init];
        floorPan.floorPanList.courtId = model.data.coreInfo.id;
        floorPan.floorPanList = model.data.floorpanList;
        floorPan.houseModelType = FHHouseModelTypeNewFloorPlan;
        [self.items addObject:floorPan];
    }
    
    // 小区评测
    if (model.data.strategy && model.data.strategy.articleList.count > 0) {
    
        FHDetailAccessCellModel *cellModel = [[FHDetailAccessCellModel alloc] init];
        cellModel.houseModelType = FHHouseModelTypeNewAccess;
        cellModel.strategy = model.data.strategy;
        cellModel.bottomMargin = 30;
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
    // 推荐经纪人
    if (model.data.recommendedRealtors.count > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailAgentListModel *agentListModel = [[FHDetailAgentListModel alloc] init];
        NSString *searchId = self.listLogPB[@"search_id"];
        NSString *imprId = self.listLogPB[@"impr_id"];
        agentListModel.tableView = self.tableView;
        agentListModel.belongsVC = self.detailController;
        agentListModel.houseModelType = FHHouseModelTypeNewAgentList;
        agentListModel.recommendedRealtorsTitle = model.data.recommendedRealtorsTitle;
        agentListModel.recommendedRealtorsSubTitle = model.data.recommendedRealtorsSubTitle;
        agentListModel.recommendedRealtors = model.data.recommendedRealtors;
        agentListModel.associateInfo = model.data.recommendRealtorsAssociateInfo;

        /******* 这里的 逻辑   ********/
        agentListModel.phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeNewHouse houseId:self.houseId];
        NSMutableDictionary *paramsDict = @{}.mutableCopy;
        if (self.detailTracerDic) {
            [paramsDict addEntriesFromDictionary:self.detailTracerDic];
        }
        paramsDict[@"page_type"] = [self pageTypeString];
        agentListModel.phoneCallViewModel.tracerDict = paramsDict;
        agentListModel.searchId = searchId;
        agentListModel.imprId = imprId;
        agentListModel.houseId = self.houseId;
        agentListModel.houseType = self.houseType;
        
        [self.items addObject:agentListModel];
    }
    // UGC社区入口
    if (model.data.socialInfo && model.data.socialInfo.socialGroupInfo && model.data.socialInfo.socialGroupInfo.socialGroupId.length > 0) {
        
        FHDetailNewUGCSocialCellModel *socialInfoCM = [[FHDetailNewUGCSocialCellModel alloc]init];
        socialInfoCM.houseModelType = FHHouseModelTypeNewSocialInfo;
        socialInfoCM.socialInfo = model.data.socialInfo;
        [self.items addObject:socialInfoCM];
    }

    //楼盘动态
    if (model.data.timeline.list.count != 0) {
        
        FHDetailNewHouseNewsCellModel *newsCellModel = [[FHDetailNewHouseNewsCellModel alloc] init];
        newsCellModel.hasMore = model.data.timeline.hasMore;
        newsCellModel.titleText = @"楼盘动态";
        newsCellModel.courtId = model.data.coreInfo.id;
        newsCellModel.clickEnable = YES;
        newsCellModel.houseModelType = FHHouseModelTypeNewTimeline;
        [self.items addObject:newsCellModel];
        
        for (NSInteger i = 0; i < model.data.timeline.list.count; i++) {
            FHDetailNewDataTimelineListModel *itemModel = model.data.timeline.list[i];
            FHDetailNewTimeLineItemCorrectingModel *item = [[FHDetailNewTimeLineItemCorrectingModel alloc] init];
            item.desc = itemModel.desc;
            item.title = itemModel.title;
            item.createdTime = itemModel.createdTime;
            item.isFirstCell = (i == 0);
            item.isLastCell = (i == model.data.timeline.list.count - 1);
            item.courtId = model.data.coreInfo.id;
            item.houseModelType = FHHouseModelTypeNewTimeline;
            [self.items addObject:item];
        }
    }
    
    if (model.data.surroundingInfo) {
        FHDetailCourtInfoCellModel *infoModel = [[FHDetailCourtInfoCellModel alloc] init];
        infoModel.surroundingInfo = model.data.surroundingInfo;
        infoModel.houseModelType = FHHouseModelTypeNewLocation;
        infoModel.tableView = self.tableView;
        infoModel.contactViewModel = self.contactViewModel;
        [self.items addObject:infoModel];
    }
    //地图
    if(model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng){
        FHDetailStaticMapCellModel *staticMapModel = [[FHDetailStaticMapCellModel alloc] init];
        staticMapModel.mapCentertitle = model.data.coreInfo.name;
        staticMapModel.gaodeLat = model.data.coreInfo.gaodeLat;
        staticMapModel.gaodeLng = model.data.coreInfo.gaodeLng;
        staticMapModel.houseId = model.data.coreInfo.id;
        staticMapModel.houseType = [NSString stringWithFormat:@"%d",FHHouseTypeNewHouse];
        //        staticMapModel.title = model.data.coreInfo.name;
        staticMapModel.tableView = self.tableView;
        staticMapModel.staticImage = model.data.coreInfo.gaodeImage;
        staticMapModel.mapOnly = NO;
        staticMapModel.houseModelType = FHHouseModelTypeNewLocation;
        [self.items addObject:staticMapModel];
        
    } else{
        NSString *eventName = @"detail_map_location_failed";
        NSDictionary *cat = @{@"status": @(1)};
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
        [params setValue:@"经纬度缺失" forKey:@"reason"];
        [params setValue:model.data.coreInfo.id forKey:@"house_id"];
        [params setValue:@(FHHouseTypeNewHouse) forKey:@"house_type"];
        [params setValue:model.data.coreInfo.name forKey:@"name"];
        
        [[HMDTTMonitor defaultManager] hmdTrackService:eventName metric:nil category:cat extra:params];
    }
    
    //    //周边配套
    //    if (model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng) {
    //        // 添加分割线--当存在某个数据的时候在顶部添加分割线
    //        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
    //        [self.items addObject:grayLine];
    //
    //        FHDetailNearbyMapModel *nearbyMapModel = [[FHDetailNearbyMapModel alloc] init];
    //        nearbyMapModel.gaodeLat = model.data.coreInfo.gaodeLat;
    //        nearbyMapModel.gaodeLng = model.data.coreInfo.gaodeLng;
    //        nearbyMapModel.title = model.data.coreInfo.name;
    //
    //
    //        if (!model.data.coreInfo.gaodeLat || !model.data.coreInfo.gaodeLng) {
    //            NSMutableDictionary *params = [NSMutableDictionary new];
    //            [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
    //            [params setValue:@"经纬度缺失" forKey:@"reason"];
    //            [params setValue:model.data.coreInfo.id forKey:@"house_id"];
    //            [params setValue:@(1) forKey:@"house_type"];
    //            [params setValue:model.data.coreInfo.name forKey:@"name"];
    //            [[HMDTTMonitor defaultManager] hmdTrackService:@"detail_map_location_failed" attributes:params];
    //        }
    //
    //
    ////        nearbyMapModel.tableView = self.tableView;
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
    self.items = [FHNewDetailModuleHelper moduleClassificationMethod:self.items];
    
    if (model.isInstantData) {
        [self.tableView reloadData];
    }else{
        [self reloadData];
    }
    
    [self.detailController updateLayout:model.isInstantData];
}

// 处理详情页周边新盘请求数据
- (void)processDetailRelatedData {
    self.detailController.isLoadingData = NO;
    if(_relatedHouseData.data && self.relatedHouseData.data.items.count > 0)
    {
        FHDetailNewRelatedCellModel *infoModel = [[FHDetailNewRelatedCellModel alloc] init];
        infoModel.houseModelType = FHHouseModelTypeNewRelated;
        infoModel.relatedHouseData = self.relatedHouseData.data;
        [self.items addObject:infoModel];
        
//        for(NSInteger i = 0;i < _relatedHouseData.data.items.count; i++)
//        {
//            NSString *data = [(_relatedHouseData.data.items[i]) toJSONString];
//            NSError *error = nil;
//            FHHouseListBaseItemModel *itemModel = [[FHHouseListBaseItemModel alloc] initWithString:data error:&error];
//            itemModel.houseModelType = FHHouseModelTypeNewRelated;
//            //            FHNewHouseItemModel *itemModels = [[FHNewHouseItemModel alloc] initWithString:data error:nil];
//            //            FHNewHouseItemModel *itemModels = [[FHNewHouseItemModel alloc] initWithData:data error:nil];
//            itemModel.index = i;
//            if (i == _relatedHouseData.data.items.count - 1) {
//                itemModel.isLast = YES;
//            }
//            if (i == 0) {
//                itemModel.isFirst = YES;
//            }
//            [self.items addObject:itemModel];
//        }
    }
    // 免责声明
    FHDetailNewModel * model = (FHDetailNewModel *)self.detailData;
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
    self.items = [FHNewDetailModuleHelper moduleClassificationMethod:self.items];
    //    //楼盘版权信息
    //    if ([self.dataModel.data.disclaimer isKindOfClass:[FHDetailNewDataDisclaimerModel class]]){
    //        FHDetailDisclaimerModel *disclaimerModel = [[FHDetailDisclaimerModel alloc] init];
    //        disclaimerModel.disclaimer = [[FHDisclaimerModel alloc] initWithData:[self.dataModel.data.disclaimer toJSONData] error:nil];
    //        [self.items addObject:disclaimerModel];
    //    }
    
    [self reloadData];
}

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FHDetailBaseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.didClickCellBlk) {
        cell.didClickCellBlk();
    }
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

@end
