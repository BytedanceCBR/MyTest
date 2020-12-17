//
//  FHNewHouseDetailCoreInfoSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailCoreInfoSC.h"
#import "FHNewHouseDetailCoreInfoSM.h"
#import "FHNewHouseDetailHeaderTitleCollectionCell.h"
#import "FHNewHouseDetailPropertyListCollectionCell.h"
#import "FHNewHouseDetailAddressInfoCollectionCell.h"
#import "FHNewHouseDetailPriceNotifyCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"
#import <FHHouseBase/FHMonitor.h>
#import "FHNewHouseDetailViewController.h"
#import "FHNewHouseDetailViewModel.h"
#import "FHHouseDetailContactViewModel.h"

@implementation FHNewHouseDetailCoreInfoSC

- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(-20, 15, 12, 15);
//        self.minimumLineSpacing = 20;
    }
    return self;
}

#pragma mark - Action
- (void)goToInfoDetail {
    FHNewHouseDetailPropertyListCellModel *model = [(FHNewHouseDetailCoreInfoSM *)self.sectionModel propertyListCellModel];
    
    NSString *courtId = model.courtId;
    if (courtId.length) {
        NSDictionary *dictTrace = self.detailTracerDict.copy;
        
        NSMutableDictionary *mutableDict = [NSMutableDictionary new];
        [mutableDict setValue:dictTrace[@"page_type"] forKey:@"page_type"];
        [mutableDict setValue:dictTrace[@"rank"] forKey:@"rank"];
        [mutableDict setValue:dictTrace[@"origin_from"] forKey:@"origin_from"];
        [mutableDict setValue:dictTrace[@"origin_search_id"] forKey:@"origin_search_id"];
        [mutableDict setValue:dictTrace[@"log_pb"] forKey:@"log_pb"];
        
        [FHUserTracker writeEvent:@"click_house_info" params:mutableDict];
        
        NSMutableDictionary *infoDict = [NSMutableDictionary new];
        [infoDict addEntriesFromDictionary:self.subPageParams];
        [infoDict setValue:model.houseName forKey:@"courtInfo"];
        if (model.disclaimerModel) {
            [infoDict setValue:model.disclaimerModel forKey:@"disclaimerInfo"];
        }
        
        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_coreinfo_detail?court_id=%@",courtId]] userInfo:info];
    }
}

- (void)goToMapDetail {
//    地图页调用示例
    FHNewHouseDetailAddressInfoCellModel *model = [(FHNewHouseDetailCoreInfoSM *)self.sectionModel addressInfoCellModel];
    double longitude = [model.gaodeLng doubleValue] ? [model.gaodeLng doubleValue] : 0;
    double latitude = [model.gaodeLat doubleValue] ? [model.gaodeLat doubleValue] : 0;
    NSNumber *latitudeNum = @(latitude);
    NSNumber *longitudeNum = @(longitude);
    
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    [infoDict setValue:@"公交" forKey:@"category"];
    [infoDict setValue:latitudeNum forKey:@"latitude"];
    [infoDict setValue:longitudeNum forKey:@"longitude"];
    if (model.name) {
        [infoDict setValue:model.name forKey:@"title"];
    }
    
    if (!longitude || !latitude) {
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
        [params setValue:@"经纬度缺失" forKey:@"reason"];
        [params setValue:model.courtId forKey:@"house_id"];
        [params setValue:@(1) forKey:@"house_type"];
        [params setValue:infoDict[@"title"] forKey:@"name"];
        [FHMonitor hmdTrackService:@"detail_map_location_failed" metric:params.copy category:nil extra:params.copy];
    }
    
    NSMutableDictionary *tracer = self.detailTracerDict.mutableCopy;
    [tracer setValue:@"address" forKey:@"click_type"];
    [tracer setValue:@"house_info" forKey:@"element_from"];
    [tracer setObject:tracer[@"page_type"] forKey:@"enter_from"];
    [infoDict setValue:tracer forKey:@"tracer"];
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fh_map_detail"] userInfo:info];
}

- (void)openNotifyAction {
    FHHouseDetailContactViewModel *contactViewModel = self.detailViewController.viewModel.contactViewModel;
    FHNewHouseDetailPriceNotifyCellModel *model = [(FHNewHouseDetailCoreInfoSM *)self.sectionModel priceNotifyCellModel];
    NSString *title = @"开盘通知";
    NSString *subtitle = @"订阅开盘通知，楼盘开盘信息会及时发送到您的手机。";
    NSString *btnTitle = @"提交";
    NSMutableDictionary *associateParamDict = @{}.mutableCopy;
    associateParamDict[kFHAssociateInfo] = model.openAssociateInfo.reportFormInfo;
    NSMutableDictionary *reportParamsDict = [contactViewModel baseParams].mutableCopy;
    reportParamsDict[@"position"] = @"on_sell";
    associateParamDict[kFHReportParams] = reportParamsDict;

    associateParamDict[@"title"] = title;
    associateParamDict[@"subtitle"] = subtitle;
    associateParamDict[@"btn_title"] = btnTitle;
    associateParamDict[@"toast"] = @"订阅成功，稍后会有置业顾问联系您";

    [contactViewModel fillFormActionWithParams:associateParamDict];
}

- (void)priceChangedNotifyAction {
    FHHouseDetailContactViewModel *contactViewModel = self.detailViewController.viewModel.contactViewModel;
    FHNewHouseDetailPriceNotifyCellModel *model = [(FHNewHouseDetailCoreInfoSM *)self.sectionModel priceNotifyCellModel];
    NSString *title = @"变价通知";
    NSString *subtitle = @"订阅变价通知，楼盘变价信息会及时发送到您的手机。";
    NSString *btnTitle = @"提交";
    NSMutableDictionary *associateParamDict = @{}.mutableCopy;
    associateParamDict[kFHAssociateInfo] = model.priceAssociateInfo.reportFormInfo;
    NSMutableDictionary *reportParamsDict = [contactViewModel baseParams].mutableCopy;
    reportParamsDict[@"position"] = @"change_price";
    associateParamDict[kFHReportParams] = reportParamsDict;
    
    associateParamDict[@"title"] = title;
    associateParamDict[@"subtitle"] = subtitle;
    associateParamDict[@"btn_title"] = btnTitle;
    associateParamDict[@"toast"] = @"订阅成功，稍后会有置业顾问联系您";
    
    [contactViewModel fillFormActionWithParams:associateParamDict];
}

#pragma mark - DataSource
- (NSInteger)numberOfItems {
    FHNewHouseDetailCoreInfoSM *model = (FHNewHouseDetailCoreInfoSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNewHouseDetailCoreInfoSM *model = (FHNewHouseDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        return [FHNewHouseDetailHeaderTitleCollectionCell cellSizeWithData:model.titleCellModel width:width];
    } else if (model.items[index] == model.propertyListCellModel) {
        return [FHNewHouseDetailPropertyListCollectionCell cellSizeWithData:model.propertyListCellModel width:width];
    } else if (model.items[index] == model.addressInfoCellModel) {
        return [FHNewHouseDetailAddressInfoCollectionCell cellSizeWithData:model.addressInfoCellModel width:width];
    } else if (model.items[index] == model.priceNotifyCellModel) {
        return [FHNewHouseDetailPriceNotifyCollectionCell cellSizeWithData:model.priceNotifyCellModel width:width];
    }
    return CGSizeZero;
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNewHouseDetailCoreInfoSM *model = (FHNewHouseDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        FHNewHouseDetailHeaderTitleCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailHeaderTitleCollectionCell class] withReuseIdentifier:NSStringFromClass([model.titleCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.titleCellModel];
        return cell;
    } else if (model.items[index] == model.propertyListCellModel) {
        FHNewHouseDetailPropertyListCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailPropertyListCollectionCell class] withReuseIdentifier:NSStringFromClass([model.propertyListCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.propertyListCellModel];
        return cell;
    } else if (model.items[index] == model.addressInfoCellModel) {
        FHNewHouseDetailAddressInfoCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailAddressInfoCollectionCell class] withReuseIdentifier:NSStringFromClass([model.addressInfoCellModel class]) forSectionController:self atIndex:index];
        [cell setMapDetailActionBlock:^{
            [weakSelf goToMapDetail];
        }];
        [cell setPropertyDetailActionBlock:^{
            [weakSelf goToInfoDetail];
        }];
        [cell refreshWithData:model.addressInfoCellModel];
        return cell;

    } else if (model.items[index] == model.priceNotifyCellModel) {
        FHNewHouseDetailPriceNotifyCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailPriceNotifyCollectionCell class] withReuseIdentifier:NSStringFromClass([model.priceNotifyCellModel class]) forSectionController:self atIndex:index];
        [cell setOpenNotifyActionBlock:^{
            [weakSelf openNotifyAction];
        }];
        [cell setPriceChangedNotifyActionBlock:^{
            [weakSelf priceChangedNotifyAction];
        }];
        [cell refreshWithData:model.priceNotifyCellModel];
        return cell;
    }
    return [super defaultCellAtIndex:index];
}

@end
