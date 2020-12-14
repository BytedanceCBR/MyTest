//
//  FHNeighborhoodDetailCoreInfoSC.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailCoreInfoSC.h"
#import "FHNeighborhoodDetailCoreInfoSM.h"
#import "FHNeighborhoodDetailHeaderTitleCollectionCell.h"
#import "FHNeighborhoodDetailSubMessageCollectionCell.h"
#import "FHNeighborhoodDetailQuickEntryCollectionCell.h"
#import <FHHouseBase/FHMonitor.h>
#import "FHNeighborhoodDetailViewController.h"
#import <TTRoute/TTRoute.h>
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHSearchHouseModel.h"
#import <Flutter/Flutter.h>

@interface FHNeighborhoodDetailCoreInfoSC ()

@end


@implementation FHNeighborhoodDetailCoreInfoSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inset = UIEdgeInsetsMake(12, 9, 12, 9);
    }
    return self;
}

#pragma mark - DataSource
- (NSInteger)numberOfItems {
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 9 * 2;
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        return [FHNeighborhoodDetailHeaderTitleCollectionCell cellSizeWithData:model.titleCellModel width:width];
    } else if (model.items[index] == model.subMessageModel) {
        return [FHNeighborhoodDetailSubMessageCollectionCell cellSizeWithData:model.subMessageModel width:width];
    }
    return CGSizeZero;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        FHNeighborhoodDetailHeaderTitleCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailHeaderTitleCollectionCell class] withReuseIdentifier:NSStringFromClass([model.titleCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.titleCellModel];
        cell.mapBtnClickBlock = ^{
            [weakSelf gotoMapDetail:model.titleCellModel.titleStr];
        };
        return cell;
    } else if (model.items[index] == model.subMessageModel) {
        FHNeighborhoodDetailSubMessageCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailSubMessageCollectionCell class] withReuseIdentifier:NSStringFromClass([model.subMessageModel class]) forSectionController:self atIndex:index];
        cell.clickSoldblock = ^{
            [weakSelf addSoldClick:model.subMessageModel.soldUrl];
        };
        cell.clickOnSaleblock = ^{
            [weakSelf addOnSaleClick];
        };
        cell.clickAveragePriceblock = ^{
            [weakSelf addAveragePriceClick];
        };
        [cell refreshWithData:model.subMessageModel];
        return cell;
    }
//    else if (model.items[index] == model.propertyInfoModel) {
//        FHNeighborhoodDetailPropertyInfoCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailPropertyInfoCollectionCell class] withReuseIdentifier:NSStringFromClass([model.propertyInfoModel class]) forSectionController:self atIndex:index];
//        [cell setFoldButtonActionBlock:^{
//            [weakSelf foldAction];
//        }];
//        [cell refreshWithData:model.propertyInfoModel];
//
//        return cell;
//    } else if (model.items[index] == model.quickEntryModel) {
//        FHNeighborhoodDetailQuickEntryCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailQuickEntryCollectionCell class] withReuseIdentifier:NSStringFromClass([model.quickEntryModel class]) forSectionController:self atIndex:index];
//        [cell refreshWithData:model.quickEntryModel];
//        [cell setQuickEntryClickBlock:^(NSString * _Nonnull quickEntryName) {
//            [weakSelf addQuickEntryClick:quickEntryName];
//            if ([quickEntryName isEqualToString:@"街景"]) {
//                [self gotoPanoramaDetail];
//            } else {
//                [self gotoMapDetail:quickEntryName];
//            }
//        }];
//        return cell;
//
//    }
    return [super defaultCellAtIndex:index];
}

//- (void)gotoPanoramaDetail {
//    if (![TTReachability isNetworkConnected]) {
//        [[ToastManager manager] showToast:@"网络异常"];
//        return;
//    }
//    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
//    NSMutableDictionary *tracerDict = self.detailTracerDict.mutableCopy;
//    NSMutableDictionary *param = [NSMutableDictionary new];
//    tracerDict[@"element_from"] = @"panorama";
//    [tracerDict setObject:tracerDict[@"page_type"] forKey:@"enter_from"];
//    param[TRACER_KEY] = tracerDict.copy;
//
//
//    NSString *gaodeLat = model.quickEntryModel.gaodeLat;
//    NSString *gaodeLon = model.quickEntryModel.gaodeLng;
//    if (gaodeLat.length && gaodeLon.length) {
//        param[@"gaodeLat"] = gaodeLat;
//        param[@"gaodeLon"] = gaodeLon;
//        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://baidu_panorama_detail"]] userInfo:TTRouteUserInfoWithDict(param)];
//    }
//}

- (void)addOnSaleClick {
    FHDetailNeighborhoodModel *detailModel = (FHDetailNeighborhoodModel*)self.detailViewController.viewModel.detailData;
    NSString *neighborhood_id = @"be_null";
    if (detailModel && detailModel.data.neighborhoodInfo.id.length > 0) {
        neighborhood_id = detailModel.data.neighborhoodInfo.id;
    }
    NSMutableDictionary *tracerDic = [[self detailTracerDict] mutableCopy];
    tracerDic[@"enter_type"] = @"click";
    tracerDic[@"page_type"] = @"old_list";
    tracerDic[@"log_pb"] = self.detailViewController.viewModel.listLogPB;
    tracerDic[@"category_name"] = @"old_list";
    tracerDic[@"element_from"] = @"sale_house";
    tracerDic[@"enter_from"] = @"neighborhood_detail";
    [tracerDic removeObjectForKey:@"card_type"];
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    userInfo[@"tracer"] = tracerDic;
    userInfo[@"house_type"] = @(FHHouseTypeSecondHandHouse);
    if (detailModel.data.neighborhoodInfo.name.length > 0) {
        userInfo[@"title"] = detailModel.data.neighborhoodInfo.name;
    } else {
        userInfo[@"title"] = @"小区房源";// 默认值
    }
    if (neighborhood_id.length > 0) {
        userInfo[@"neighborhood_id"] = neighborhood_id;
    }
    if (self.detailViewController.viewModel.houseId.length > 0) {
        userInfo[@"house_id"] = self.detailViewController.viewModel.houseId;
    }
    userInfo[@"list_vc_type"] = @(5);
    
    TTRouteUserInfo *userInf = [[TTRouteUserInfo alloc] initWithInfo:userInfo];
    NSString * urlStr = [NSString stringWithFormat:@"snssdk1370://house_list_in_neighborhood"];
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInf];
    }
}

- (void)addAveragePriceClick {
    NSMutableDictionary *params = @{}.mutableCopy;
    
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    userInfo[@"route"] = @"/neighbor_price_detail";
    
//    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    //{"average_price_detail":"均价详情页"}
    NSMutableDictionary *tracerDict = self.detailTracerDict.mutableCopy;
    tracerDict[@"element_from"] = @"average_price_detail";
    tracerDict[@"enter_from"] = @"neighborhood_detail";
    params[@"report_params"] = [tracerDict btd_jsonStringEncoded];
    
    if (self.detailViewController.viewModel.oritinDetailData) {
        params[@"neighbor_info"] = [FlutterStandardTypedData typedDataWithBytes:self.detailViewController.viewModel.oritinDetailData];
    } else if (self.detailViewController.viewModel.detailData) {
        params[@"neighbor_info"] = [[self.detailViewController.viewModel.detailData.data toDictionary] btd_safeJsonStringEncoded];
    }
    
    userInfo[@"params"] = params;
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://flutter"]] userInfo:TTRouteUserInfoWithDict(userInfo)];
}

- (void)addSoldClick:(NSString *)url {
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url] userInfo:nil];
}

- (void)gotoMapDetail :(NSString *)quickEntryName {
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    //地图页调用示例
    double longitude = [model.titleCellModel.gaodeLng floatValue];
    double latitude = [model.titleCellModel.gaodeLat floatValue];
    NSNumber *latitudeNum = @(latitude);
    NSNumber *longitudeNum = @(longitude);
    
    NSString *selectCategory = quickEntryName.copy;
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    [infoDict setValue:selectCategory forKey:@"category"];
    [infoDict setValue:latitudeNum forKey:@"latitude"];
    [infoDict setValue:longitudeNum forKey:@"longitude"];
    [infoDict setValue:model.titleCellModel.mapCentertitle forKey:@"title"];
    if (model.titleCellModel.baiduPanoramaUrl.length) {
        infoDict[@"baiduPanoramaUrl"] = model.titleCellModel.baiduPanoramaUrl;
    }
    
    NSMutableDictionary *tracer = self.detailTracerDict.mutableCopy;
    
    [tracer setObject:@"map_detail" forKey:@"page_type"];
    [tracer setValue:@"top_map" forKey:@"element_from"];
    [tracer setObject:@"neighborhood_detail" forKey:@"enter_from"];
    [tracer setObject:@"be_null" forKey:@"element_type"];
    [infoDict setValue:tracer forKey:@"tracer"];
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fh_map_detail"] userInfo:info];
}

- (void)addQuickEntryClick:(NSString *)quickEntryName {
    NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
    
    tracerDic[@"page_type"] = @"neighborhood_detail";
    tracerDic[@"click_position"] = [self clickPositionFromQucikEntryName:quickEntryName];
    [FHUserTracker writeEvent:@"click_options" params:tracerDic];
}

- (NSString *)clickPositionFromQucikEntryName:(NSString *)quickEntryName {
    if ([quickEntryName isEqualToString:@"地图"]) {
        return @"map";
    }
    if ([quickEntryName isEqualToString:@"街景"]) {
        return @"panorama";
    }
    if ([quickEntryName isEqualToString:@"教育"]) {
        return @"education";
    }
    if ([quickEntryName isEqualToString:@"交通"]) {
        return @"traffic";
    }
    if ([quickEntryName isEqualToString:@"生活"]) {
        return @"life";
    }
    if ([quickEntryName isEqualToString:@"医疗"]) {
        return @"hospital";
    }
    return @"be_null";
}

//- (void)foldAction {
//    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
//
//    if (model.propertyInfoModel && [model.propertyInfoModel isKindOfClass:[FHNeighborhoodDetailPropertyInfoModel class]]) {
//
//        FHNeighborhoodDetailPropertyInfoModel *newInfoModel = [model.propertyInfoModel transformFoldStatus];
//
//        NSMutableArray *newArray = [NSMutableArray arrayWithArray:model.items];
//
//
//
//        [newArray btd_replaceObjectAtIndex:[newArray indexOfObject:model.propertyInfoModel] withObject:newInfoModel];
//        model.items = newArray.copy;
//        model.propertyInfoModel = newInfoModel;
//
//
//        [self updateAnimated:YES completion:^(BOOL updated) {
//
//        }];
//    }
//
//}

@end
