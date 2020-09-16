//
//  FHFloorPanDetailMediaHeaderDataHelper.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/7.
//

#import "FHFloorPanDetailMediaHeaderDataHelper.h"
#import "FHMultiMediaModel.h"
#import "FHFloorPanDetailMediaHeaderCell.h"

@interface FHFloorPanDetailMediaHeaderDataHelper ()

@property (nonatomic, strong, readwrite) FHFloorPanDetailMediaHeaderDataHelperHeaderViewData *headerViewData;
//提供给图片详情页的数据
@property (nonatomic, strong, readwrite) FHFloorPanDetailMediaHeaderDataHelperPictureDetailData *pictureDetailData;
//提供给图片相册的数据
@property (nonatomic, strong, readwrite) FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData *photoAlbumData;
@end


@implementation FHFloorPanDetailMediaHeaderDataHelper

- (void)setMediaHeaderModel:(FHFloorPanDetailMediaHeaderModel *)mediaHeaderModel {
    if (![mediaHeaderModel isKindOfClass:[FHFloorPanDetailMediaHeaderModel class]]) {
        return;
    }
    _mediaHeaderModel = mediaHeaderModel;
    _headerViewData = nil;
    _pictureDetailData = nil;
    _photoAlbumData = nil;
}

- (FHFloorPanDetailMediaHeaderDataHelperHeaderViewData *)headerViewData {
    if (!_headerViewData) {
        _headerViewData = [FHFloorPanDetailMediaHeaderDataHelper generateMediaHeaderViewData:self.mediaHeaderModel];
    }
    return _headerViewData;
}

- (FHFloorPanDetailMediaHeaderDataHelperPictureDetailData *)pictureDetailData {
    if (!_pictureDetailData) {
        _pictureDetailData = [FHFloorPanDetailMediaHeaderDataHelper generatePictureDetailData:self.mediaHeaderModel];
    }
    return _pictureDetailData;
}

- (FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData *)photoAlbumData {
    if (!_photoAlbumData) {
        _photoAlbumData = [FHFloorPanDetailMediaHeaderDataHelper generatePhotoAlbumData:self.mediaHeaderModel];
    }
    return _photoAlbumData;
}


+ (FHFloorPanDetailMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHFloorPanDetailMediaHeaderModel *)newMediaHeaderModel {
    FHFloorPanDetailMediaHeaderDataHelperHeaderViewData *headerViewData = [[FHFloorPanDetailMediaHeaderDataHelperHeaderViewData alloc] init];
    NSUInteger vrNumber = 0;
    NSUInteger pictureNumber = 0;
    NSMutableArray *itemArray = [NSMutableArray array];
    NSArray *houseImageDict = newMediaHeaderModel.houseImageDictList;
    FHDetailVRInfo *vrInfo = newMediaHeaderModel.vrModel;
    if (vrInfo.items.count > 0) {
        for (FHDetailHouseVRDataModel *vrData in vrInfo.items) {
            FHMultiMediaItemModel *itemModelVR = [[FHMultiMediaItemModel alloc] init];
            itemModelVR.mediaType = FHMultiMediaTypeVRPicture;
            if (vrData.vrImage.url.length > 0) {
                itemModelVR.imageUrl = vrData.vrImage.url;
            }
            itemModelVR.vrOpenUrl = vrData.openUrl;
            itemModelVR.pictureTypeName = @"VR";
            itemModelVR.groupType = @"VR";
            [itemArray addObject:itemModelVR];
            vrNumber += 1;
        }
    }
    for (FHHouseDetailImageListDataModel *listModel in houseImageDict) {
        NSString *groupType = nil;
        if (listModel.usedSceneType == FHHouseDetailImageListDataUsedSceneTypeFloorPan) {
            if (listModel.houseImageType == 2001) {
                groupType = @"户型";
            } else {
                groupType = @"样板间";
            }
        }
        for (FHImageModel *imageModel in listModel.houseImageList) {
            if (imageModel.url.length > 0) {
                FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
                itemModel.mediaType = FHMultiMediaTypePicture;
                itemModel.imageUrl = imageModel.url;
                itemModel.pictureType = listModel.houseImageType;
                itemModel.pictureTypeName = listModel.houseImageTypeName;
                itemModel.groupType = groupType;
                [itemArray addObject:itemModel];
                pictureNumber += 1;
            }
        }
    }
    headerViewData.mediaItemArray = itemArray.copy;
    headerViewData.pictureNumber = pictureNumber;
    headerViewData.vrNumber = vrNumber;
    return headerViewData;
}

//大图详情页的数据
+ (FHFloorPanDetailMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHFloorPanDetailMediaHeaderModel *)newMediaHeaderModel {
    FHFloorPanDetailMediaHeaderDataHelperPictureDetailData *pictureDetailData = [[FHFloorPanDetailMediaHeaderDataHelperPictureDetailData alloc] init];
    NSMutableArray<FHDetailPhotoHeaderModelProtocol> *imageList = [NSMutableArray<FHDetailPhotoHeaderModelProtocol> array];
    NSMutableArray *itemArray = [NSMutableArray array];
    NSArray *houseImageDict = newMediaHeaderModel.houseImageDictList;
    for (FHHouseDetailImageListDataModel *listModel in houseImageDict) {
        for (FHImageModel *imageModel in listModel.houseImageList) {
            if (imageModel.url.length > 0) {
                FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
                itemModel.mediaType = FHMultiMediaTypePicture;
                itemModel.imageUrl = imageModel.url;
                itemModel.pictureType = listModel.houseImageType;
                itemModel.pictureTypeName = listModel.houseImageTypeName;
                [imageList addObject:imageModel];
                [itemArray addObject:itemModel];
            }
        }
    }
    pictureDetailData.mediaItemArray = itemArray.copy;
    pictureDetailData.photoArray = imageList.copy;
    return pictureDetailData;
}

+ (FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHFloorPanDetailMediaHeaderModel *)newMediaHeaderModel {
    FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData *photoAlbumData = [[FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData alloc] init];
    
    return photoAlbumData;
}



@end

@implementation FHFloorPanDetailMediaHeaderDataHelperHeaderViewData

@end
@implementation FHFloorPanDetailMediaHeaderDataHelperPictureDetailData

@end
@implementation FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData

@end
