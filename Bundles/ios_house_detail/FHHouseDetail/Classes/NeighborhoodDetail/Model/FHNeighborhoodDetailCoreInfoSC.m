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
            [weakSelf addOnSaleClick:model.subMessageModel.onSaleUrl];
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

- (void)addOnSaleClick:(NSString *)url {
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url] userInfo:nil];
}

- (void)addAveragePriceClick {
    NSMutableDictionary *params = @{}.mutableCopy;
    
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    userInfo[@"route"] = [@"/neighbor_price_detail" btd_stringByURLEncode];
    
//    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    //{"average_price_detail":"均价详情页"}
    NSMutableDictionary *tracerDict = self.detailTracerDict.mutableCopy;
    tracerDict[@"element_from"] = @"average_price_detail";
    tracerDict[@"enter_from"] = @"neighborhood_detail";
    params[@"report_params"] = [tracerDict btd_jsonStringEncoded];
    
    if (self.detailViewController.viewModel.detailData) {
        params[@"neighbor_info"] = [[self.detailViewController.viewModel.detailData toDictionary] btd_safeJsonStringEncoded];
    }
    
    userInfo[@"params"] = [params btd_jsonStringEncoded];
    
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
    
    
    [tracer setValue:[self clickPositionFromQucikEntryName:quickEntryName] forKey:@"element_from"];
    [tracer setObject:tracer[@"page_type"] forKey:@"enter_from"];
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
