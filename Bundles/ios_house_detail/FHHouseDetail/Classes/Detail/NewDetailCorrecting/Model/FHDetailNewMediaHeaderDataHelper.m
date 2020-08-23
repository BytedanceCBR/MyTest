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

+ (FHDetailNewMediaHeaderDataHelperData *)generateModel:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel {
    FHDetailNewMediaHeaderDataHelperData *data = [[FHDetailNewMediaHeaderDataHelperData alloc] init];
    
    NSMutableArray *itemArray = [NSMutableArray array];
    NSMutableArray *imageList = [NSMutableArray array];
    NSArray *houseImageDict = newMediaHeaderModel.houseImageDictList;
    FHMultiMediaItemModel *vedioModel = newMediaHeaderModel.vedioModel;
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
        
       // [self trackVRElementShow];//这应该在一开始就特判？//不应该在这展示
    }
    
    if (vedioModel && vedioModel.videoID.length > 0) {
       // self.vedioCount = 1;
        [itemArray addObject:vedioModel];
    }
    
    for (FHHouseDetailImageListDataModel *listModel in houseImageDict) {
        NSString *groupType = nil;
        if (listModel.usedSceneType == FHHouseDetailImageListDataUsedSceneTypeFloorPan) {
            if (listModel.houseImageType == 2001) {
                groupType = @"户型";
            } else {
                groupType = @"样板间";
            }
        } else {
            if(listModel.houseImageType == FHDetailHouseImageTypeApartment){
                groupType = @"户型";
            }else{
                groupType = @"图片";
            }
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
@end

@implementation FHDetailNewMediaHeaderDataHelperData


@end
