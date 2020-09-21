//
//  FHNewHouseDetailSurroundingSM.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSurroundingSM.h"
#import "FHNewHouseDetailSurroundingCollectionCell.h"
#import "FHNewHouseDetailMapCollectionCell.h"
#import "FHNewHouseDetailMapResultCollectionCell.h"

@implementation FHNewHouseDetailSurroundingSM

- (void)updateDetailModel:(FHDetailNewModel *)model {
    NSMutableArray *items = [NSMutableArray array];
    self.centerPoint = CLLocationCoordinate2DMake(39.98269504123264, 116.3078908962674);
    if (model.data.surroundingInfo) {
        FHNewHouseDetailSurroundingCellModel *cellModel = [[FHNewHouseDetailSurroundingCellModel alloc] init];
        cellModel.surroundingInfo = model.data.surroundingInfo;
        [items addObject:cellModel];
        self.surroundingCellModel = cellModel;
    }
    
    //地图
    if(model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng){
        FHNewHouseDetailMapCellModel *staticMapModel = [[FHNewHouseDetailMapCellModel alloc] init];
        staticMapModel.baiduPanoramaUrl = model.data.coreInfo.baiduPanoramaUrl;
        staticMapModel.mapCentertitle = model.data.coreInfo.name;
        staticMapModel.gaodeLat = model.data.coreInfo.gaodeLat;
        staticMapModel.gaodeLng = model.data.coreInfo.gaodeLng;
        staticMapModel.houseId = model.data.coreInfo.id;
        staticMapModel.houseType = [NSString stringWithFormat:@"%ld",(long)FHHouseTypeNewHouse];
        staticMapModel.staticImage = model.data.coreInfo.gaodeImage;
        staticMapModel.mapOnly = NO;
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
        [params setValue:model.data.coreInfo.id forKey:@"house_id"];
        [params setValue:@(FHHouseTypeNewHouse) forKey:@"house_type"];
        [params setValue:model.data.coreInfo.name forKey:@"name"];
        
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
