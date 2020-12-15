//
//  FHNeighborhoodDetailSurroundingSC.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailSurroundingSC.h"
#import "FHNeighborhoodDetailSurroundingSM.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailStaticMap.h"
#import "MAMapKit.h"
#import "FHNeighborhoodDetailViewController.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNeighborhoodDetailMapCollectionCell.h"

@interface FHNeighborhoodDetailSurroundingSC ()<IGListSupplementaryViewSource>

@end

@implementation FHNeighborhoodDetailSurroundingSC

- (instancetype)init {
    if (self = [super init]) {
        self.supplementaryViewSource = self;
    }
    return self;
}

#pragma mark - Action
//跳转
- (void)mapMaskBtnClick:(NSString *)clickType {
    FHNeighborhoodDetailSurroundingSM *model = (FHNeighborhoodDetailSurroundingSM *)self.sectionModel;
    double longitude = model.centerPoint.longitude;
    double latitude = model.centerPoint.latitude;
    NSNumber *latitudeNum = @(latitude);
    NSNumber *longitudeNum = @(longitude);
    
    NSString *selectCategory = [model.curCategory isEqualToString:@"交通"] ? @"公交" : model.curCategory;
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    [infoDict setValue:selectCategory forKey:@"category"];
    [infoDict setValue:latitudeNum forKey:@"latitude"];
    [infoDict setValue:longitudeNum forKey:@"longitude"];
    [infoDict setValue:model.mapCentertitle forKey:@"title"];
    if (model.baiduPanoramaUrl.length) {
        infoDict[@"baiduPanoramaUrl"] = model.baiduPanoramaUrl;
    }
    NSMutableDictionary *tracer = [NSMutableDictionary dictionaryWithDictionary:self.detailTracerDict];
    tracer[@"click_type"] = clickType ?: @"be_null";
    tracer[UT_ELEMENT_FROM] = @"map";
    tracer[UT_ENTER_FROM] = tracer[@"page_type"] ?: @"be_null";
    [infoDict setValue:tracer forKey:@"tracer"];

    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fh_map_detail"] userInfo:info];
}

- (void)baiduPanoramaAction {
    NSMutableDictionary *param = [NSMutableDictionary new];
    FHNeighborhoodDetailSurroundingSM *model = (FHNeighborhoodDetailSurroundingSM *)self.sectionModel;
    FHNeighborhoodDetailMapCellModel *dataModel = [model mapCellModel];
    NSMutableDictionary *tracerDict = self.detailTracerDict.mutableCopy;
    tracerDict[@"element_from"] = @"map";
    tracerDict[@"enter_from"] = @"neighborhood_detail";
    param[TRACER_KEY] = tracerDict.copy;
    if (dataModel.gaodeLat.length && dataModel.gaodeLng.length) {
        param[@"gaodeLat"] = dataModel.gaodeLat;
        param[@"gaodeLon"] = dataModel.gaodeLng;
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://baidu_panorama_detail"]] userInfo:TTRouteUserInfoWithDict(param)];
    }
}

- (void)addClickPriceTrendLog
{
    //    1. event_type：house_app2c_v2
    //    2. page_type：页面类型,{'新房详情页': 'new_detail', '二手房详情页': 'old_detail', '小区详情页': 'neighborhood_detail'}
    //    3. rank
    //    4. origin_from
    //    5. origin_search_id
    //    6.log_pb
    NSMutableDictionary *params = @{}.mutableCopy;
    NSDictionary *traceDict = [self detailTracerDict];
    params[@"page_type"] = traceDict[@"page_type"] ? : @"be_null";
    params[@"rank"] = traceDict[@"rank"] ? : @"be_null";
    params[@"origin_from"] = traceDict[@"origin_from"] ? : @"be_null";
    params[@"origin_search_id"] = traceDict[@"origin_search_id"] ? : @"be_null";
    params[@"log_pb"] = traceDict[@"log_pb"] ? : @"be_null";
    [FHUserTracker writeEvent:@"click_price_trend" params:params];
}

- (void)didSelectItemAtIndex:(NSInteger)index {
//    FHNeighborhoodDetailSurroundingSM *model = (FHNeighborhoodDetailSurroundingSM *)self.sectionModel;
//    if ([model.dataItems[index] isKindOfClass:[FHStaticMapAnnotation class]] || [model.dataItems[index] isKindOfClass:[NSString class]]) {
//        [self mapMaskBtnClick:@"map_click"];
//    }
}

#pragma mark - datasource

- (NSInteger)numberOfItems {
    FHNeighborhoodDetailSurroundingSM *model = (FHNeighborhoodDetailSurroundingSM *)self.sectionModel;
    return model.dataItems.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailSurroundingSM *model = (FHNeighborhoodDetailSurroundingSM *)self.sectionModel;
    CGFloat width = self.collectionContext.containerSize.width - 9 * 2;
    if (model.dataItems[index] == model.mapCellModel) {
        return [FHNeighborhoodDetailMapCollectionCell cellSizeWithData:model.mapCellModel width:width];
    }
//    else if ([model.dataItems[index] isKindOfClass:[FHStaticMapAnnotation class]]) {
//        return [FHNewHouseDetailMapResultCollectionCell cellSizeWithData:model.dataItems[index] width:width];
//    }
//    else if ([model.dataItems[index] isKindOfClass:[NSString class]]) {
//        NSString *emptyString = model.dataItems[index];
//        if (emptyString && emptyString.length) {
//            return [FHNewHouseDetailMapResultCollectionCell cellSizeWithData:model.dataItems[index] width:width];
//        } else {
//            return CGSizeMake(width, 20);
//        }
//    }
//    else if (model.dataItems[index] == model.priceTrendModel) {
//        return [FHNeighborhoodDetailPriceTrendCollectionCell cellSizeWithData:model.priceTrendModel width:width];
//    }
    
    return CGSizeZero;
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNeighborhoodDetailSurroundingSM *model = (FHNeighborhoodDetailSurroundingSM *)self.sectionModel;
    if (index >= model.dataItems.count) {
        return [super defaultCellAtIndex:index];
    }
    if (model.dataItems[index] == model.mapCellModel) {
        FHNeighborhoodDetailMapCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailMapCollectionCell class] withReuseIdentifier:NSStringFromClass([model.mapCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.mapCellModel];
        [cell setCategoryClickBlock:^(NSString * _Nonnull category) {
            model.curCategory = category;
            NSMutableDictionary *tracerDict = weakSelf.detailTracerDict.mutableCopy;
            tracerDict[UT_ELEMENT_TYPE] = @"map";
            tracerDict[UT_PAGE_TYPE] = @"neighborhood_detail";
            NSString *click_position = nil;
            if ([category isEqualToString:@"教育"]) {
                click_position = @"education";
            } else if ([category isEqualToString:@"生活"]) {
                click_position = @"life";
            } else if ([category isEqualToString:@"交通"]) {
                click_position = @"traffic";
            } else if ([category isEqualToString:@"医疗"]) {
                click_position = @"hostital";
            } else if ([category isEqualToString:@"休闲"]) {
                click_position = @"entertaiment";
            }
            tracerDict[UT_CLICK_POSITION] = click_position ?: @"be_null";
            tracerDict[UT_ELEMENT_FROM] = @"be_null";
            [FHUserTracker writeEvent:@"click_options" params:tracerDict.copy];
            [weakSelf mapMaskBtnClick:nil];
        }];
        cell.mapBtnClickBlock = ^(NSString * _Nonnull clickType) {
            [weakSelf mapMaskBtnClick:clickType];
        };

        [cell setBaiduPanoramaBlock:^{
            [weakSelf baiduPanoramaAction];
        }];
//        [cell setClickFacilitiesBlock:^(NSString * _Nonnull position) {
//            NSMutableDictionary *tracerDic = weakSelf.detailTracerDict.mutableCopy;
//            tracerDic[@"element_type"] = @"map";
//            tracerDic[@"click_position"] = position ?: @"be_null";
//            [FHUserTracker writeEvent:@"click_facilities" params:tracerDic.copy];
//        }];
        return cell;
    }
//    else if ([model.dataItems[index] isKindOfClass:[FHStaticMapAnnotation class]]) {
//        FHStaticMapAnnotation *annotation = (FHStaticMapAnnotation *)model.dataItems[index];
//        FHNewHouseDetailMapResultCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMapResultCollectionCell class] withReuseIdentifier:NSStringFromClass([annotation class]) forSectionController:self atIndex:index];
//
//
//        NSString *stringName = @"暂无信息";
//        if (annotation.title.length) {
//            stringName = annotation.title;
//        }
//
//        NSString *stringDistance = @"未知";
//        if (annotation) {
//            MAMapPoint from = MAMapPointForCoordinate(CLLocationCoordinate2DMake([model.mapCellModel.gaodeLat floatValue], [model.mapCellModel.gaodeLng floatValue]));
//
//            MAMapPoint to = MAMapPointForCoordinate(CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude));
//
//            CLLocationDistance distance = MAMetersBetweenMapPoints(from, to);
//            if (distance < 1000) {
//                stringDistance = [NSString stringWithFormat:@"%d米", (int) distance];
//            } else {
//                stringDistance = [NSString stringWithFormat:@"%.1f公里", ((CGFloat) distance) / 1000.0];
//            }
//        }
//        cell.titleLabel.text = stringName;
//        cell.subTitleLabel.text = stringDistance;
//        cell.titleLabel.hidden = NO;
//        cell.subTitleLabel.hidden = NO;
//        return cell;
//    }
//    else if ([model.dataItems[index] isKindOfClass:[NSString class]]) {
//        NSString *emptyString = model.dataItems[index];
//        FHNewHouseDetailMapResultCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMapResultCollectionCell class] withReuseIdentifier:NSStringFromClass([emptyString class]) forSectionController:self atIndex:index];
//        cell.subTitleLabel.hidden = YES;
//        if (emptyString.length) {
//            cell.titleLabel.font = [UIFont themeFontRegular:17];
//            cell.titleLabel.textColor = [UIColor themeGray3];
//            cell.titleLabel.textAlignment = NSTextAlignmentCenter;
//            cell.titleLabel.hidden = NO;
//            cell.titleLabel.text = emptyString;
//        } else {
//            cell.titleLabel.hidden = YES;
//        }
//        return cell;
//    }
//    else if (model.dataItems[index] == model.priceTrendModel) {
//        FHNeighborhoodDetailPriceTrendCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailPriceTrendCollectionCell class] withReuseIdentifier:NSStringFromClass([model.priceTrendModel class]) forSectionController:self atIndex:index];
//        [cell refreshWithData:model.priceTrendModel];
//        [cell setAddClickPriceTrendLogBlock:^{
//            [weakSelf addClickPriceTrendLog];
//        }];
//        return cell;
//    }
    return [super defaultCellAtIndex:index];
}



#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}


- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
//    FHNewHouseDetailSurroundingSM *model = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    [titleView setupNeighborhoodDetailStyle];
    titleView.titleLabel.text = @"周边配套";
    // 设置下发标题
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 9 * 2, 46);
    }
    return CGSizeZero;
}

@end
