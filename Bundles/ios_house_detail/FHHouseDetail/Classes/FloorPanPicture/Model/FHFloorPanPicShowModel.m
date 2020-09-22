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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showQuantity = YES;
    }
    return self;
}

+ (NSArray<FHFloorPanPicShowGroupModel> *)getTabGroupInfo:(FHHouseDetailMediaTabInfo *)tabInfo rootName:(NSString *)rootName {
    NSMutableArray *groupModels = [[NSMutableArray alloc] init];
    if (tabInfo.tabContent.count > 0) {
        FHFloorPanPicShowGroupModel *groupModel = [[FHFloorPanPicShowGroupModel alloc] init];
        groupModel.groupName = tabInfo.tabName;
        groupModel.rootGroupName = rootName;
        NSMutableArray *itemModels = [[NSMutableArray alloc] init];
        for (FHHouseDetailMediaStruct *mediaStr in tabInfo.tabContent) {
            if (mediaStr.videoInfo) {   //视频
                FHFloorPanPicShowItemVideoModel *videoItemModel = [[FHFloorPanPicShowItemVideoModel alloc] init];
                videoItemModel.itemType = FHFloorPanPicShowModelTypeVideo;
                videoItemModel.image = mediaStr.smallImage;
                [itemModels addObject:videoItemModel];
            } else if (mediaStr.vrInfo) {   //VR
                FHFloorPanPicShowItemVRModel *vrItemModel = [[FHFloorPanPicShowItemVRModel alloc] init];
                vrItemModel.itemType = FHFloorPanPicShowModelTypeVR;
                vrItemModel.image = mediaStr.smallImage;
                [itemModels addObject:vrItemModel];
            } else {                        //图片
                FHFloorPanPicShowItemPictureModel *pictureItemModel = [[FHFloorPanPicShowItemPictureModel alloc] init];
                pictureItemModel.itemType = FHFloorPanPicShowModelTypePicture;
                pictureItemModel.image = mediaStr.smallImage;
                [itemModels addObject:pictureItemModel];
            }
        }
        groupModel.items = itemModels.copy;
        [groupModels addObject:groupModel];
    } else if (tabInfo.subTab.count > 0) {
        for (FHHouseDetailMediaTabInfo *otherTabInfo in tabInfo.subTab) {
            NSArray *otherArr = [FHFloorPanPicShowGroupModel getTabGroupInfo:otherTabInfo rootName:rootName];
            [groupModels addObjectsFromArray:otherArr];
        }
    }
    return groupModels.copy;
}

@end
