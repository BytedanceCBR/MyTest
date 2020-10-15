//
//  FHNeighborhoodDetailSurroundingSM.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailSurroundingSM.h"
#import "FHNewHouseDetailMapCollectionCell.h"
#import "FHNewHouseDetailMapResultCollectionCell.h"

@implementation FHNeighborhoodDetailSurroundingSM

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    NSMutableArray *items = [NSMutableArray array];
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
        [items addObject:staticMapModel];
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
    
    self.items = items.copy;
}

- (NSArray *)dataItems {
    if (self.mapCellModel.annotations.count) {
        return [[[NSArray arrayWithArray:self.items] arrayByAddingObjectsFromArray:self.mapCellModel.annotations] arrayByAddingObject:@""];
    }
    return [[NSArray arrayWithArray:self.items] arrayByAddingObject:self.mapCellModel.emptyString?:@"附近没有交通信息"];
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
