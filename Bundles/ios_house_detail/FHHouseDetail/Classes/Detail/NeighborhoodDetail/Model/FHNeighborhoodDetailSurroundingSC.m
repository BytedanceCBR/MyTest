//
//  FHNeighborhoodDetailSurroundingSC.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailSurroundingSC.h"
#import "FHNeighborhoodDetailSurroundingSM.h"
#import "FHNewHouseDetailMapCollectionCell.h"
#import "FHNewHouseDetailMapResultCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailStaticMap.h"
#import "MAMapKit.h"
#import "FHNeighborhoodDetailViewController.h"
#import "FHNeighborhoodDetailPriceTrendCollectionCell.h"

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
    [tracer setValue:clickType forKey:@"click_type"];
    [tracer setValue:@"map" forKey:@"element_from"];
    [tracer setObject:tracer[@"page_type"] forKey:@"enter_from"];
    [infoDict setValue:tracer forKey:@"tracer"];

    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fh_map_detail"] userInfo:info];
}

- (void)baiduPanoramaAction {
    NSMutableDictionary *param = [NSMutableDictionary new];
    FHNeighborhoodDetailSurroundingSM *model = (FHNeighborhoodDetailSurroundingSM *)self.sectionModel;
    FHNewHouseDetailMapCellModel *dataModel = [model mapCellModel];
    NSMutableDictionary *tracerDict = self.detailTracerDict.mutableCopy;
    tracerDict[@"element_from"] = @"map";
    tracerDict[@"enter_from"] = @"new_detail";
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

#pragma mark - datasource

- (NSInteger)numberOfItems {
    FHNeighborhoodDetailSurroundingSM *model = (FHNeighborhoodDetailSurroundingSM *)self.sectionModel;
    return model.dataItems.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailSurroundingSM *model = (FHNeighborhoodDetailSurroundingSM *)self.sectionModel;
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    if (model.dataItems[index] == model.mapCellModel) {
        return [FHNewHouseDetailMapCollectionCell cellSizeWithData:model.mapCellModel width:width];
    } else if ([model.dataItems[index] isKindOfClass:[FHStaticMapAnnotation class]]) {
        return [FHNewHouseDetailMapResultCollectionCell cellSizeWithData:model.dataItems[index] width:width];
    } else if ([model.dataItems[index] isKindOfClass:[NSString class]]) {
        NSString *emptyString = model.dataItems[index];
        if (emptyString && emptyString.length) {
            return [FHNewHouseDetailMapResultCollectionCell cellSizeWithData:model.dataItems[index] width:width];
        } else {
            return CGSizeMake(width, 20);
        }
    } else if (model.dataItems[index] == model.priceTrendModel) {
        return [FHNeighborhoodDetailPriceTrendCollectionCell cellSizeWithData:model.priceTrendModel width:width];
    }
    
    return CGSizeZero;
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNeighborhoodDetailSurroundingSM *model = (FHNeighborhoodDetailSurroundingSM *)self.sectionModel;
    if (model.dataItems[index] == model.mapCellModel) {
        FHNewHouseDetailMapCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMapCollectionCell class] withReuseIdentifier:NSStringFromClass([model.mapCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.mapCellModel];
        cell.categoryChangeBlock = ^(NSString * _Nonnull category) {
            model.curCategory = category;
        };
        cell.mapBtnClickBlock = ^(NSString * _Nonnull clickType) {
            [weakSelf mapMaskBtnClick:clickType];
        };
        [cell setRefreshActionBlock:^{
            [weakSelf.detailViewController refreshSectionModel:weakSelf.sectionModel animated:YES];
        }];
        [cell setBaiduPanoramaBlock:^{
            [weakSelf baiduPanoramaAction];
        }];
        return cell;
    } else if ([model.dataItems[index] isKindOfClass:[FHStaticMapAnnotation class]]) {
        FHStaticMapAnnotation *annotation = (FHStaticMapAnnotation *)model.dataItems[index];
        FHNewHouseDetailMapResultCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMapResultCollectionCell class] withReuseIdentifier:NSStringFromClass([annotation class]) forSectionController:self atIndex:index];
        
        
        NSString *stringName = @"暂无信息";
        if (annotation.title.length) {
            stringName = annotation.title;
        }
        
        NSString *stringDistance = @"未知";
        if (annotation) {
            MAMapPoint from = MAMapPointForCoordinate(CLLocationCoordinate2DMake([model.mapCellModel.gaodeLat floatValue], [model.mapCellModel.gaodeLng floatValue]));
            
            MAMapPoint to = MAMapPointForCoordinate(CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude));
            
            CLLocationDistance distance = MAMetersBetweenMapPoints(from, to);
            if (distance < 1000) {
                stringDistance = [NSString stringWithFormat:@"%d米", (int) distance];
            } else {
                stringDistance = [NSString stringWithFormat:@"%.1f公里", ((CGFloat) distance) / 1000.0];
            }
        }
        cell.titleLabel.text = stringName;
        cell.subTitleLabel.text = stringDistance;
        cell.titleLabel.hidden = NO;
        cell.subTitleLabel.hidden = NO;
        return cell;
    } else if ([model.dataItems[index] isKindOfClass:[NSString class]]) {
        NSString *emptyString = model.dataItems[index];
        FHNewHouseDetailMapResultCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMapResultCollectionCell class] withReuseIdentifier:NSStringFromClass([emptyString class]) forSectionController:self atIndex:index];
        cell.subTitleLabel.hidden = YES;
        if (emptyString.length) {
            cell.titleLabel.font = [UIFont themeFontRegular:17];
            cell.titleLabel.textColor = [UIColor themeGray3];
            cell.titleLabel.textAlignment = NSTextAlignmentCenter;
            cell.titleLabel.hidden = NO;
            cell.titleLabel.text = emptyString;
        } else {
            cell.titleLabel.hidden = YES;
        }
        return cell;
    } else if (model.dataItems[index] == model.priceTrendModel) {
        FHNeighborhoodDetailPriceTrendCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailPriceTrendCollectionCell class] withReuseIdentifier:NSStringFromClass([model.priceTrendModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.priceTrendModel];
        [cell setAddClickPriceTrendLogBlock:^{
            [weakSelf addClickPriceTrendLog];
        }];
        return cell;
    }
    return nil;
}

- (void)didSelectItemAtIndex:(NSInteger)index {

}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}


- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
//    FHNewHouseDetailSurroundingSM *model = (FHNewHouseDetailSurroundingSM *)self.sectionModel;
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:18];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    titleView.titleLabel.text = @"周边配套";
    // 设置下发标题
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 61);
    }
    return CGSizeZero;
}
@end
