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
                [self.detailController.emptyView hideEmptyView];
                wSelf.bottomBar.hidden = NO;
                // 0 正常显示，1 二手房源正常下架（如已卖出等），-1 二手房非正常下架（如法律风险、假房源等）
                [wSelf handleBottomBarStatus:model.data.status];
                NSString *neighborhoodId = model.data.neighborhoodInfo.id;
                wSelf.neighborhoodId = neighborhoodId;
                // 周边数据请求
                [wSelf requestRelatedData:neighborhoodId];
            } else {
                wSelf.detailController.hasValidateData = NO;
                wSelf.bottomBar.hidden = YES;
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            }
        } else {
            wSelf.detailController.hasValidateData = NO;
            wSelf.bottomBar.hidden = YES;
            [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
        }
    }];
}

- (void)handleBottomBarStatus:(NSInteger)status
{
    if (status == 1) {
        self.bottomStatusBar.hidden = NO;
        [self.navBar showRightItems:NO];
        //        self.
        [self.bottomStatusBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
        }];
    }else if (status == -1) {
        self.bottomStatusBar.hidden = YES;
        [self.navBar showRightItems:YES];
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
- (void)processDetailData:(FHRentDetailResponseModel *)model {

    self.contactViewModel.contactPhone = model.data.contact;
    self.contactViewModel.shareInfo = model.data.shareInfo;
    self.contactViewModel.followStatus = model.data.userStatus.houseSubStatus;
    
    self.detailData = model;
    self.logPB = model.data.logPb;
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


@end

