//
//  FHNeighborhoodDetailSurroundingSM.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailSurroundingSM.h"
#import "FHNewHouseDetailMapCollectionCell.h"
#import "FHNewHouseDetailMapResultCollectionCell.h"
#import "FHNeighborhoodDetailPriceTrendCollectionCell.h"

@implementation FHNeighborhoodDetailSurroundingSM

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    self.centerPoint = CLLocationCoordinate2DMake(39.98269504123264, 116.3078908962674);
    //地图
    if(model.data.neighborhoodInfo.gaodeLat.length && model.data.neighborhoodInfo.gaodeLng.length){
        FHNewHouseDetailMapCellModel *staticMapModel = [[FHNewHouseDetailMapCellModel alloc] init];
        staticMapModel.baiduPanoramaUrl = model.data.neighborhoodInfo.baiduPanoramaUrl;
        staticMapModel.mapCentertitle = model.data.neighborhoodInfo.name;
        staticMapModel.gaodeLat = model.data.neighborhoodInfo.gaodeLat;
        staticMapModel.gaodeLng = model.data.neighborhoodInfo.gaodeLng;
        staticMapModel.houseId = model.data.neighborhoodInfo.id;
        staticMapModel.houseType = [NSString stringWithFormat:@"%ld",(long)FHHouseTypeNeighborhood];
        staticMapModel.staticImage = model.data.neighborhoodInfo.gaodeImage;
        self.baiduPanoramaUrl = staticMapModel.baiduPanoramaUrl;
        self.centerPoint = CLLocationCoordinate2DMake([staticMapModel.gaodeLat floatValue], [staticMapModel.gaodeLng floatValue]);
        self.mapCentertitle = staticMapModel.mapCentertitle;
        self.mapCellModel = staticMapModel;
    } else{
        NSString *eventName = @"detail_map_location_failed";
        NSDictionary *cat = @{@"status": @(1)};
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
        [params setValue:@"经纬度缺失" forKey:@"reason"];
        [params setValue:model.data.neighborhoodInfo.id forKey:@"house_id"];
        [params setValue:@(FHHouseTypeNeighborhood) forKey:@"house_type"];
        [params setValue:model.data.neighborhoodInfo.name forKey:@"name"];
        
        [[HMDTTMonitor defaultManager] hmdTrackService:eventName metric:nil category:cat extra:params];
    }
    
    // 均价走势
    if (model.data.priceTrend.count > 0) {
        FHNeighborhoodDetailPriceTrendCellModel *priceTrendModel = [[FHNeighborhoodDetailPriceTrendCellModel alloc] init];
//        priceTrendModel.housetype  = self.houseType;
//        priceTrendModel.houseModelType = FHPlotHouseModelTypeLocationPeriphery;
        priceTrendModel.priceTrends = model.data.priceTrend;
//        priceTrendModel.tableView = self.tableView;
        self.priceTrendModel = priceTrendModel;
    }
}

- (NSArray *)dataItems {
    NSMutableArray *items = [NSMutableArray array];
    if (self.mapCellModel) {
        [items addObject:self.mapCellModel];
    }
    if (self.mapCellModel.annotations.count) {
        [items addObjectsFromArray:self.mapCellModel.annotations];
        if (!self.priceTrendModel.priceTrends.count) {
            [items addObject:@""];
        }
    } else {
        [items addObject:self.mapCellModel.emptyString?:@"附近没有交通信息"];
    }
    if (self.priceTrendModel) {
        [items addObject:self.priceTrendModel];
    }
    return items.copy;
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
