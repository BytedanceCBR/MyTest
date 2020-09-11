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
}

@end
