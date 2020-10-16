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
#import "FHNeighborhoodDetailPropertyInfoCollectionCell.h"
#import "FHNeighborhoodDetailQuickEntryCollectionCell.h"
#import <FHHouseBase/FHMonitor.h>
#import "FHNeighborhoodDetailViewController.h"
@implementation FHNeighborhoodDetailCoreInfoSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inset = UIEdgeInsetsMake(-20, 15, 12, 15);
    }
    return self;
}

#pragma mark - DataSource
- (NSInteger)numberOfItems {
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        return [FHNeighborhoodDetailHeaderTitleCollectionCell cellSizeWithData:model.titleCellModel width:width];
    } else if (model.items[index] == model.subMessageModel) {
        return [FHNeighborhoodDetailSubMessageCollectionCell cellSizeWithData:model.subMessageModel width:width];
    } else if (model.items[index] == model.propertyInfoModel) {
        return [FHNeighborhoodDetailPropertyInfoCollectionCell cellSizeWithData:model.propertyInfoModel width:width];
    } else if (model.items[index] == model.quickEntryModel) {
        return [FHNeighborhoodDetailQuickEntryCollectionCell cellSizeWithData:model.quickEntryModel width:width];
    }
    return CGSizeZero;
}
- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    if (model.items[index] == model.titleCellModel) {
        FHNeighborhoodDetailHeaderTitleCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailHeaderTitleCollectionCell class] withReuseIdentifier:NSStringFromClass([model.titleCellModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.titleCellModel];
        return cell;
    } else if (model.items[index] == model.subMessageModel) {
        FHNeighborhoodDetailSubMessageCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailSubMessageCollectionCell class] withReuseIdentifier:NSStringFromClass([model.subMessageModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.subMessageModel];
        return cell;
    } else if (model.items[index] == model.propertyInfoModel) {
        FHNeighborhoodDetailPropertyInfoCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailPropertyInfoCollectionCell class] withReuseIdentifier:NSStringFromClass([model.propertyInfoModel class]) forSectionController:self atIndex:index];
        __weak FHNeighborhoodDetailCoreInfoSM *weakModelSM = model;
        [cell setFoldButtonActionBlock:^{
            weakModelSM.isFold = !weakModelSM.isFold;
            [weakSelf.detailViewController refreshSectionModel:weakModelSM animated:YES];
        }];
        [cell refreshWithData:model.propertyInfoModel];
        
        return cell;
    } else if (model.items[index] == model.quickEntryModel) {
        FHNeighborhoodDetailQuickEntryCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailQuickEntryCollectionCell class] withReuseIdentifier:NSStringFromClass([model.quickEntryModel class]) forSectionController:self atIndex:index];
        [cell refreshWithData:model.quickEntryModel];
        [cell setQuickEntryClickBlock:^(NSString * _Nonnull quickEntryName) {
            [weakSelf addQuickEntryClick:quickEntryName];
            if ([quickEntryName isEqualToString:@"街景"]) {
                [self gotoPanoramaDetail];
            } else {
                [self gotoMapDetail:quickEntryName];
            }
        }];
        return cell;
        
    }
    return nil;
}

- (void)gotoPanoramaDetail {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    NSMutableDictionary *tracerDict = self.detailTracerDict.mutableCopy;
    NSMutableDictionary *param = [NSMutableDictionary new];
    tracerDict[@"element_from"] = @"panorama";
    [tracerDict setObject:tracerDict[@"page_type"] forKey:@"enter_from"];
    param[TRACER_KEY] = tracerDict.copy;
    

    NSString *gaodeLat = model.quickEntryModel.gaodeLat;
    NSString *gaodeLon = model.quickEntryModel.gaodeLng;
    if (gaodeLat.length && gaodeLon.length) {
        param[@"gaodeLat"] = gaodeLat;
        param[@"gaodeLon"] = gaodeLon;
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://baidu_panorama_detail"]] userInfo:TTRouteUserInfoWithDict(param)];
    }
}

- (void)gotoMapDetail :(NSString *)quickEntryName {
    FHNeighborhoodDetailCoreInfoSM *model = (FHNeighborhoodDetailCoreInfoSM *)self.sectionModel;
    //地图页调用示例
    double longitude = [model.quickEntryModel.gaodeLng floatValue];
    double latitude = [model.quickEntryModel.gaodeLat floatValue];
    NSNumber *latitudeNum = @(latitude);
    NSNumber *longitudeNum = @(longitude);
    
    NSString *selectCategory = quickEntryName.copy;
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    [infoDict setValue:selectCategory forKey:@"category"];
    [infoDict setValue:latitudeNum forKey:@"latitude"];
    [infoDict setValue:longitudeNum forKey:@"longitude"];
    [infoDict setValue:model.quickEntryModel.mapCentertitle forKey:@"title"];
    if (model.quickEntryModel.baiduPanoramaUrl.length) {
        infoDict[@"baiduPanoramaUrl"] = model.quickEntryModel.baiduPanoramaUrl;
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



@end
