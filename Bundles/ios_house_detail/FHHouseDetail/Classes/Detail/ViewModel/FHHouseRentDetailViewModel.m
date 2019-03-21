//
//  FHHouseRentDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseRentDetailViewModel.h"
#import "FHDetailBaseCell.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailPhotoHeaderCell.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHDetailRentModel.h"
#import "FHHouseRentRelatedResponse.h"
#import "FHRentSameNeighborhoodResponse.h"
#import "FHDetailGrayLineCell.h"
#import "FHDetailHouseNameCell.h"
#import "FHDetailRentHouseCoreInfoCell.h"
#import "FHDetailPropertyListCell.h"
#import "FHDetailRentFacilityCell.h"
#import "FHDetailRentHouseOutlineInfoCell.h"
#import "FHDetailRentSameNeighborhoodHouseCell.h"
#import "FHDetailRentRelatedHouseCell.h"
#import "FHDetailDisclaimerCell.h"
#import "FHDetailNeighborhoodInfoCell.h"
#import "FHDetailNeighborhoodMapInfoCell.h"
#import "FHDetailHouseSubscribeCell.h"
#import "FHEnvContext.h"
#import "NSDictionary+TTAdditions.h"
#import "FHHouseDetailFollowUpViewModel.h"

extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHSubscribeHouseCacheKey;

@interface FHHouseRentDetailViewModel ()

@property (nonatomic, assign)   NSInteger       requestRelatedCount;
@property (nonatomic, strong , nullable) FHRentSameNeighborhoodResponseDataModel *sameNeighborhoodHouseData;
@property (nonatomic, strong , nullable) FHHouseRentRelatedResponseDataModel *relatedHouseData;
@property (nonatomic, copy , nullable) NSString *neighborhoodId;// 周边小区房源id

@end

@implementation FHHouseRentDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    [self.tableView registerClass:[FHDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderCell class])];
    [self.tableView registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineCell class])];
    [self.tableView registerClass:[FHDetailHouseNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseNameCell class])];
    [self.tableView registerClass:[FHDetailRentHouseCoreInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRentHouseCoreInfoCell class])];
    [self.tableView registerClass:[FHDetailPropertyListCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPropertyListCell class])];
    [self.tableView registerClass:[FHDetailRentFacilityCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRentFacilityCell class])];
    [self.tableView registerClass:[FHDetailRentHouseOutlineInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRentHouseOutlineInfoCell class])];
    [self.tableView registerClass:[FHDetailRentSameNeighborhoodHouseCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRentSameNeighborhoodHouseCell class])];
    [self.tableView registerClass:[FHDetailRentRelatedHouseCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailRentRelatedHouseCell class])];
    [self.tableView registerClass:[FHDetailDisclaimerCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailDisclaimerCell class])];
    [self.tableView registerClass:[FHDetailNeighborhoodInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodInfoCell class])];
    [self.tableView registerClass:[FHDetailNeighborhoodMapInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodMapInfoCell class])];
    [self.tableView registerClass:[FHDetailHouseSubscribeCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseSubscribeCell class])];
}
// cell class
- (Class)cellClassForEntity:(id)model {
    // 头部滑动图片
    if ([model isKindOfClass:[FHDetailPhotoHeaderModel class]]) {
        return [FHDetailPhotoHeaderCell class];
    }
    // 标题
    if ([model isKindOfClass:[FHDetailHouseNameModel class]]) {
        return [FHDetailHouseNameCell class];
    }
    // 灰色分割线
    if ([model isKindOfClass:[FHDetailGrayLineModel class]]) {
        return [FHDetailGrayLineCell class];
    }
    // coreInfo
    if ([model isKindOfClass:[FHDetailRentHouseCoreInfoModel class]]) {
        return [FHDetailRentHouseCoreInfoCell class];
    }
    // 属性列表
    if ([model isKindOfClass:[FHDetailPropertyListModel class]]) {
        return [FHDetailPropertyListCell class];
    }
    // 房屋设施
    if ([model isKindOfClass:[FHDetailRentFacilityModel class]]) {
        return [FHDetailRentFacilityCell class];
    }
    // 房源概况
    if ([model isKindOfClass:[FHDetailRentHouseOutlineInfoModel class]]) {
        return [FHDetailRentHouseOutlineInfoCell class];
    }
    // 小区信息
    if ([model isKindOfClass:[FHDetailNeighborhoodInfoModel class]]) {
        return [FHDetailNeighborhoodInfoCell class];
    }
    // 小区地图
    if ([model isKindOfClass:[FHDetailNeighborhoodMapInfoModel class]]) {
        return [FHDetailNeighborhoodMapInfoCell class];
    }
    // 同小区房源
    if ([model isKindOfClass:[FHDetailRentSameNeighborhoodHouseModel class]]) {
        return [FHDetailRentSameNeighborhoodHouseCell class];
    }
    // 周边房源
    if ([model isKindOfClass:[FHDetailRentRelatedHouseModel class]]) {
        return [FHDetailRentRelatedHouseCell class];
    }
    // 免责声明
    if ([model isKindOfClass:[FHDetailDisclaimerModel class]]) {
        return [FHDetailDisclaimerCell class];
    }
    // 订阅房源动态
    if ([model isKindOfClass:[FHDetailHouseSubscribeModel class]]) {
        return [FHDetailHouseSubscribeCell class];
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

    [FHHouseDetailAPI requestRentDetail:self.houseId completion:^(FHRentDetailResponseModel * _Nullable model, NSError * _Nullable error) {
        if (model && error == NULL) {
            if (model.data) {
                [wSelf processDetailData:model];
                
                wSelf.detailController.hasValidateData = YES;
                [wSelf.detailController.emptyView hideEmptyView];
                wSelf.bottomBar.hidden = NO;
                // 0 正常显示，1 二手房源正常下架（如已卖出等），-1 二手房非正常下架（如法律风险、假房源等）
                [wSelf handleBottomBarStatus:model.data.status];
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
            wSelf.detailController.isLoadingData = NO;
            wSelf.detailController.hasValidateData = NO;
            wSelf.bottomBar.hidden = YES;
            [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
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
        self.bottomStatusBar.text = @"停止出租";
    }else if (status == -1) {
        self.bottomStatusBar.hidden = YES;
        [self.navBar showRightItems:NO];
        [self.bottomStatusBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.detailController.emptyView showEmptyWithTip:@"该房源已下架" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
    }else if (status == 2) {
        self.bottomStatusBar.hidden = NO;
        [self.navBar showRightItems:YES];
        //        self.
        [self.bottomStatusBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
        }];
        self.bottomStatusBar.text = @"该房源已出租";
    }else {
        self.bottomStatusBar.hidden = YES;
        [self.navBar showRightItems:YES];
        [self.bottomStatusBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

// 处理详情页数据
- (void)processDetailData:(FHRentDetailResponseModel *)model {

    self.contactViewModel.contactPhone = model.data.contact;
    self.contactViewModel.shareInfo = model.data.shareInfo;
    self.contactViewModel.followStatus = model.data.userStatus.houseSubStatus;
    
    self.detailData = model;
    [self addDetailCoreInfoExcetionLog];

    // 清空数据源
    [self.items removeAllObjects];
    if (model.data.houseImage) {
        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
        headerCellModel.houseImage = model.data.houseImage;
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
        FHDetailRentHouseCoreInfoModel *coreInfoModel = [[FHDetailRentHouseCoreInfoModel alloc] init];
        coreInfoModel.coreInfo = model.data.coreInfo;
        [self.items addObject:coreInfoModel];
    }
    // 添加属性列表
    if (model.data.baseInfo) {
        FHDetailPropertyListModel *propertyModel = [[FHDetailPropertyListModel alloc] init];
        propertyModel.baseInfo = model.data.baseInfo;
        [self.items addObject:propertyModel];
    }
    // 添加房屋配置
    if (model.data.facilities.count > 0) {
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailRentFacilityModel *infoModel = [[FHDetailRentFacilityModel alloc] init];
        infoModel.facilities = model.data.facilities;
        [self.items addObject:infoModel];
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
    // 房源概况
    if (model.data.houseOverview.list.count > 0) {
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailRentHouseOutlineInfoModel *infoModel = [[FHDetailRentHouseOutlineInfoModel alloc] init];
        infoModel.houseOverreview = model.data.houseOverview;
        infoModel.baseViewModel = self;
        [self.items addObject:infoModel];
    }
    // 小区信息
    if (model.data.neighborhoodInfo.id.length > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        FHDetailNeighborhoodInfoModel *infoModel = [[FHDetailNeighborhoodInfoModel alloc] init];
        infoModel.rent_neighborhoodInfo = model.data.neighborhoodInfo;
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
 
    //生成IM卡片的schema用 个人认为server应该加接口
    NSString *imgUrl = @"";
    if (model.data.houseImage.count > 0) {
        FHDetailHouseDataItemsHouseImageModel *imageInfo = model.data.houseImage[0];
        imgUrl = imageInfo.url ?: @"";
    }
    NSString *area = @"";
    NSString *area2 = @"";
    if (model.data.coreInfo.count >= 3) {
        FHDetailOldDataCoreInfoModel *areaInfo = model.data.coreInfo[1];
        area = areaInfo.value ?: @"";
        FHDetailOldDataCoreInfoModel *areaInfo2 = model.data.coreInfo[2];
        area2 = areaInfo2.value ?: @"";
    }
    
    NSString *face = @"";
    if (model.data.baseInfo.count >= 2) {
        FHDetailOldDataCoreInfoModel *baseInfo = model.data.baseInfo[1];
        face = baseInfo.value ?: @"";
    }
    NSString *tag = model.data.neighborhoodInfo.name ?: @"";
    NSString *houseType = [NSString stringWithFormat:@"%d", self.houseType];
    NSString *houseDes = [NSString stringWithFormat:@"%@/%@/%@/%@", area, area2, face, tag];
    NSString *price = model.data.pricing ?: @"";
    [self.contactViewModel generateImParams:self.houseId houseTitle:model.data.title houseCover:imgUrl houseType:houseType  houseDes:houseDes housePrice:price houseAvgPrice:@""];
    
    [self reloadData];
 
}

// 周边数据请求，当网络请求都返回后刷新数据
- (void)requestRelatedData:(NSString *)neighborhoodId {
    self.requestRelatedCount = 0;
    // 同小区房源
    [self requestHouseInSameNeighborhoodSearch:neighborhoodId];
    // 周边房源
    [self requestRelatedHouseSearch];
}

// 处理详情页周边请求数据
- (void)processDetailRelatedData {
    if (self.requestRelatedCount >= 2) {
         self.detailController.isLoadingData = NO;
        //  同小区房源
        if (self.sameNeighborhoodHouseData && self.sameNeighborhoodHouseData.items.count > 0) {
            // 添加分割线--当存在某个数据的时候在顶部添加分割线
            FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
            [self.items addObject:grayLine];
            FHDetailRentSameNeighborhoodHouseModel *infoModel = [[FHDetailRentSameNeighborhoodHouseModel alloc] init];
            infoModel.sameNeighborhoodHouseData = self.sameNeighborhoodHouseData;
            [self.items addObject:infoModel];
        }
        // 周边房源
        if (self.relatedHouseData && self.relatedHouseData.items.count > 0) {
            // 添加分割线--当存在某个数据的时候在顶部添加分割线
            FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
            [self.items addObject:grayLine];
            FHDetailRentRelatedHouseModel *infoModel = [[FHDetailRentRelatedHouseModel alloc] init];
            infoModel.relatedHouseData = self.relatedHouseData;
            [self.items addObject:infoModel];
        }
        // 免责声明
        FHRentDetailResponseModel * model = (FHRentDetailResponseModel *)self.detailData;
        if (model.data.contact || model.data.disclaimer) {
            FHDetailDisclaimerModel *infoModel = [[FHDetailDisclaimerModel alloc] init];
            infoModel.disclaimer = model.data.disclaimer;
            infoModel.contact = model.data.contact;
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
     [FHHouseDetailAPI requestHouseRentSameNeighborhood:houseId withNeighborhoodId:neighborhoodId completion:^(FHRentSameNeighborhoodResponseModel * _Nonnull model, NSError * _Nonnull error) {
         wSelf.requestRelatedCount += 1;
         wSelf.sameNeighborhoodHouseData = model.data;
         [wSelf processDetailRelatedData];
     }];
 }

 // 周边房源
 - (void)requestRelatedHouseSearch {
     __weak typeof(self) wSelf = self;
     [FHHouseDetailAPI requestHouseRentRelated:self.houseId completion:^(FHHouseRentRelatedResponseModel * _Nonnull model, NSError * _Nonnull error) {
         wSelf.requestRelatedCount += 1;
         wSelf.relatedHouseData = model.data;
         [wSelf processDetailRelatedData];
     }];
 }

- (BOOL)isMissTitle
{
    FHRentDetailResponseModel *model = (FHRentDetailResponseModel *)self.detailData;
    return model.data.title.length < 1;
}

- (BOOL)isMissImage
{
    FHRentDetailResponseModel *model = (FHRentDetailResponseModel *)self.detailData;
    return model.data.houseImage.count < 1;
}

- (BOOL)isMissCoreInfo
{
    FHRentDetailResponseModel *model = (FHRentDetailResponseModel *)self.detailData;
    return model.data.coreInfo.count < 1;
}

- (void)subscribeFormRequest:(NSString *)phoneNum subscribeModel:(FHDetailHouseSubscribeModel *)subscribeModel {
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    NSString *houseId = self.houseId;
    NSString *from = @"app_renthouse_subscription";
    [FHHouseDetailAPI requestSendPhoneNumbserByHouseId:houseId phone:phoneNum from:from completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {
        
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
    [self.contactViewModel.followUpViewModel silentFollowHouseByFollowId:self.houseId houseType:self.houseType actionType:self.houseType showTip:NO];
}

- (BOOL)isShowSubscribe {
    BOOL isShow = NO;
    NSDictionary *fhSettings = [self fhSettings];
    BOOL rentHouseSubscribe =  [fhSettings tt_boolValueForKey:@"f_is_show_house_sub_entry"];
    //根据服务器setting设置和本地缓存，已经订阅过的house不再显示
    YYCache *subscribeHouseCache = [[FHEnvContext sharedInstance].generalBizConfig subscribeHouseCache];
    if(rentHouseSubscribe && ![subscribeHouseCache containsObjectForKey:self.houseId]){
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

