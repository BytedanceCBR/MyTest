//
//  FHFloorPanPicShowModel.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/10.
//

#import "FHFloorPanPicShowModel.h"

@implementation FHFloorPanPicShowModel

@end

@implementation FHFloorPanPicShowItemModel

@end

@implementation FHFloorPanPicShowItemPictureModel


@end

@implementation FHFloorPanPicShowItemVideoModel



@end

@implementation FHFloorPanPicShowItemVRModel



@end

@implementation FHFloorPanPicShowGroupModel

+ (NSArray<FHFloorPanPicShowGroupModel> *)getTabGroupInfo:(FHHouseDetailImageTabInfo *)tabInfo rootName:(NSString *)rootName {
    NSMutableArray *groupModels = [[NSMutableArray alloc] init];
    if (tabInfo.tabContent) {
        FHFloorPanPicShowGroupModel *groupModel = [[FHFloorPanPicShowGroupModel alloc] init];
        groupModel.groupName = tabInfo.tabName;
        groupModel.rootGroupName = rootName;
        NSMutableArray *itemModels = [[NSMutableArray alloc] init];
        for (FHHouseDetailImageStruct *imageStruct in tabInfo.tabContent) {
            FHFloorPanPicShowItemPictureModel *itemModel = [[FHFloorPanPicShowItemPictureModel alloc] init];
            itemModel.image = imageStruct.smallImage;
            itemModel.itemType = FHFloorPanPicShowModelTypePicture;
            [itemModels addObject:itemModel];
        }
        groupModel.items = itemModels.copy;
        [groupModels addObject:groupModel];
    } else if (tabInfo.subTab) {
        for (FHHouseDetailImageTabInfo *otherTabInfo in tabInfo.subTab) {
            NSArray *otherArr = [FHFloorPanPicShowGroupModel getTabGroupInfo:otherTabInfo rootName:rootName];
            [groupModels addObjectsFromArray:otherArr];
        }
    }
    return groupModels.copy;
}

@end
