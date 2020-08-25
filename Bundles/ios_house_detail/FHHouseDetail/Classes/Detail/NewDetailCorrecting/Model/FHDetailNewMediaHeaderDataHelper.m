//
//  FHDetailNewMediaHeaderDataHelper.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/23.
//

#import "FHDetailNewMediaHeaderDataHelper.h"
#import "FHMultiMediaModel.h"
#import "FHDetailNewMediaHeaderCell.h"
@implementation FHDetailNewMediaHeaderDataHelper

#pragma mark - data manage
//产出完整的头图内容 全部VR+全部视频+图片
+ (FHDetailNewMediaHeaderDataHelperData *)generateModel:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel {
    FHDetailNewMediaHeaderDataHelperData *data = [[FHDetailNewMediaHeaderDataHelperData alloc] init];

    NSMutableArray *itemArray = [NSMutableArray array];
    NSMutableArray *imageList = [NSMutableArray array];
    NSArray *houseImageDict = newMediaHeaderModel.houseImageDictList;
    FHDetailHouseVRDataModel *vrModel = newMediaHeaderModel.vrModel;
    if (vrModel && [vrModel isKindOfClass:[FHDetailHouseVRDataModel class]] && vrModel.hasVr) {
        FHMultiMediaItemModel *itemModelVR = [[FHMultiMediaItemModel alloc] init];
        itemModelVR.mediaType = FHMultiMediaTypeVRPicture;

        if (vrModel.vrImage.url) {
            itemModelVR.imageUrl = vrModel.vrImage.url;
        }
        itemModelVR.groupType = @"VR";
        [itemArray addObject:itemModelVR];
        [imageList addObject:itemModelVR];
    }
    for (FHHouseDetailImageListDataModel *listModel in houseImageDict) {
        NSString *groupType = nil;
        if (listModel.houseImageType == FHDetailHouseImageTypeApartment) {
            groupType = @"户型";
        } else {
            groupType = @"图片";
        }

        NSInteger index = 0;
        NSArray<FHImageModel> *instantHouseImageList = listModel.instantHouseImageList;

        for (FHImageModel *imageModel in listModel.houseImageList) {
            if (imageModel.url.length > 0) {
                FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
                itemModel.mediaType = FHMultiMediaTypePicture;
                itemModel.imageUrl = imageModel.url;
                itemModel.pictureType = listModel.houseImageType;
                itemModel.pictureTypeName = listModel.houseImageTypeName;
                itemModel.groupType = groupType;
                if (instantHouseImageList.count > index) {
                    FHImageModel *instantImgModel = instantHouseImageList[index];
                    itemModel.instantImageUrl = instantImgModel.url;
                }
                [itemArray addObject:itemModel];
                [imageList addObject:imageModel];
            }
            index++;
        }
    }

    data.itemArray = itemArray.copy;
    data.imageList = imageList.copy;
    return data;
}

//针对新版头图滑动数据改造
//对于每种VR只要一个可以用位运算，a|= 1<<x;



@end

@implementation FHDetailNewMediaHeaderDataHelperData

@end
