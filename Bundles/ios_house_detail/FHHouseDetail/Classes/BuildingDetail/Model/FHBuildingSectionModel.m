//
//  FHBuildingSectionModel.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/3.
//

#import "FHBuildingSectionModel.h"
#import "FHBuildingDetailInfoCollectionViewCell.h"
#import "FHBuildingDetailFloorCollectionViewCell.h"
#import "FHBuildingDetailHeaderCollectionViewCell.h"
#import "FHBuildingDetailEmptyFloorCollectionViewCell.h"

@implementation FHBuildingSectionModel

- (NSString *)className {
    switch (self.sectionType) {
        case FHBuildingSectionTypeEmpty:
            return NSStringFromClass([FHBuildingDetailEmptyFloorCollectionViewCell class]);
            break;
        case FHBuildingSectionTypeHeader:
            return NSStringFromClass([FHBuildingDetailHeaderCollectionViewCell class]);
            break;
        case FHBuildingSectionTypeInfo:
            return NSStringFromClass([
                                      FHBuildingDetailInfoCollectionViewCell class]
);
            break;
        case FHBuildingSectionTypeFloor:
            return NSStringFromClass([FHBuildingDetailFloorCollectionViewCell class]);
            break;
        default:
            break;
    }
}

@end
