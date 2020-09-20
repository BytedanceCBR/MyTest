//
//  FHDetailNewMediaHeaderDataHelper.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/23.
//

#import "FHDetailNewMediaHeaderDataHelper.h"
#import "FHMultiMediaModel.h"
#import "FHDetailNewMediaHeaderCell.h"
#import "FHFloorPanPicShowModel.h"

@interface FHDetailNewMediaHeaderDataHelper ()

@property (nonatomic, strong, readwrite) FHDetailNewMediaHeaderDataHelperHeaderViewData *headerViewData;
//提供给图片详情页的数据
@property (nonatomic, strong, readwrite) FHDetailNewMediaHeaderDataHelperPictureDetailData *pictureDetailData;
//提供给图片相册的数据
@property (nonatomic, strong, readwrite) FHDetailNewMediaHeaderDataHelperPhotoAlbumData *photoAlbumData;

@end

@implementation FHDetailNewMediaHeaderDataHelper

- (void)setMediaHeaderModel:(FHDetailNewMediaHeaderModel *)mediaHeaderModel {
    _mediaHeaderModel = mediaHeaderModel;
    _headerViewData = nil;
    _pictureDetailData = nil;
    _photoAlbumData = nil;
}

- (FHDetailNewMediaHeaderDataHelperHeaderViewData *)headerViewData {
    if (!_headerViewData) {
        _headerViewData = [FHDetailNewMediaHeaderDataHelper generateMediaHeaderViewData:self.mediaHeaderModel];
    }
    return _headerViewData;
}

- (FHDetailNewMediaHeaderDataHelperPictureDetailData *)pictureDetailData {
    if (!_pictureDetailData) {
        _pictureDetailData = [FHDetailNewMediaHeaderDataHelper generatePictureDetailData:self.mediaHeaderModel];
    }
    return _pictureDetailData;
}

- (FHDetailNewMediaHeaderDataHelperPhotoAlbumData *)photoAlbumData {
    if (!_photoAlbumData) {
        _photoAlbumData = [FHDetailNewMediaHeaderDataHelper generatePhotoAlbumData:self.mediaHeaderModel];
    }
    return _photoAlbumData;
}

#pragma mark - data manage
//针对新版头图滑动数据改造
//对于每种VR只要一个可以用位运算，a|= 1<<x;
//全部VR + 图片
+ (FHDetailNewMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel {
    FHDetailNewMediaHeaderDataHelperHeaderViewData *headerViewData = [[FHDetailNewMediaHeaderDataHelperHeaderViewData alloc] init];
    NSUInteger vrNumber = 0;
    NSUInteger pictureNumber = 0;
    NSMutableArray *itemArray = [NSMutableArray array];
    NSArray *houseImageDict = newMediaHeaderModel.houseImageDictList;
    FHDetailNewVRInfo *vrInfo = newMediaHeaderModel.vrModel;
    if (vrInfo.items.count > 0 && newMediaHeaderModel.isShowTopImageTab) {
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
        if (listModel.houseImageType == FHDetailHouseImageTypeApartment && !newMediaHeaderModel.isShowTopImageTab) {
            groupType = @"户型";
        } else {
            groupType = @"图片";
        }
        for (FHImageModel *imageModel in listModel.houseImageList) {
            if (pictureNumber >= 5 && newMediaHeaderModel.isShowTopImageTab) {
                break;
            }
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
+ (FHDetailNewMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel {
    FHDetailNewMediaHeaderDataHelperPictureDetailData *pictureDetailData = [[FHDetailNewMediaHeaderDataHelperPictureDetailData alloc] init];
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

+ (FHDetailNewMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel {
    
    FHDetailNewMediaHeaderDataHelperPhotoAlbumData *photoAlbumData = [[FHDetailNewMediaHeaderDataHelperPhotoAlbumData alloc] init];

    if (newMediaHeaderModel.isShowTopImageTab) {
        //新房新的数据版本
        FHFloorPanPicShowModel *newFloorPanPicShowModel = [[FHFloorPanPicShowModel alloc] init];
        NSMutableArray *newFloorPanArr = [NSMutableArray array];
        for (FHDetailNewTopImage *topImage in newMediaHeaderModel.topImages) {
            FHFloorPanPicShowGroupModel *showGroupModel = [[FHFloorPanPicShowGroupModel alloc] init];
            showGroupModel.rootGroupName = topImage.name;

            NSMutableArray *smallImageList = [NSMutableArray array];
            for (FHHouseDetailImageGroupModel *smallGoupModel in topImage.smallImageGroup) {
                for (FHImageModel *image in smallGoupModel.images) {
                    FHFloorPanPicShowItemPictureModel *pictureModel = [[FHFloorPanPicShowItemPictureModel alloc] init];
                    pictureModel.image = image;
                    pictureModel.itemType = FHFloorPanPicShowModelTypePicture;
                    [smallImageList addObject:pictureModel];
                }
                if (topImage.type == FHDetailHouseImageTypeApartment) {
                    FHFloorPanPicShowGroupModel *newGroupModel = [[FHFloorPanPicShowGroupModel alloc] init];
                    newGroupModel.rootGroupName = showGroupModel.rootGroupName;
                    newGroupModel.groupName = smallGoupModel.name;
                    newGroupModel.items = smallImageList.copy;
                    newGroupModel.showQuantity = NO;
                    [newFloorPanArr addObject:newGroupModel];
                    [smallImageList removeAllObjects];
                    continue;
                }
            }
            if (smallImageList.count) {
                showGroupModel.items = smallImageList.copy;
                showGroupModel.groupName = topImage.name;
                [newFloorPanArr addObject:showGroupModel];
            }
        }
        newFloorPanPicShowModel.itemGroupList = newFloorPanArr.copy;
        photoAlbumData.floorPanModel = newFloorPanPicShowModel;
    } else {
        //新房旧的数据版本
        NSMutableArray <FHHouseDetailImageGroupModel *> *pictsArray = [NSMutableArray array];
        //之前传入fisrtTopImage 表示数据不全，需要全部传入
        for (FHDetailNewTopImage *topImage in newMediaHeaderModel.topImages) {
            for (FHHouseDetailImageGroupModel *groupModel in topImage.smallImageGroup) {
                //type类型相同的数据归为一类
                __block NSUInteger index = NSNotFound;
                [pictsArray enumerateObjectsUsingBlock:^(FHHouseDetailImageGroupModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                    if ([obj.type isEqualToString:groupModel.type]) {
                        index = idx;
                        *stop = YES;
                    }
                }];
                if (index != NSNotFound) {
                    FHHouseDetailImageGroupModel *existGroupModel = pictsArray[index];
                    existGroupModel.images = [[NSArray arrayWithArray:existGroupModel.images] arrayByAddingObjectsFromArray:groupModel.images];
                } else {
                    [pictsArray addObject:groupModel.copy];
                }
            }
        }

        photoAlbumData.photoAlbumArray = pictsArray.copy;
        FHHouseDetailAlbumInfo *albumInfo = [[FHHouseDetailAlbumInfo alloc] init];
        NSMutableArray *tabArr = [NSMutableArray array];
        for (FHHouseDetailImageGroupModel *groupModel in photoAlbumData.photoAlbumArray) {
            FHHouseDetailImageTabInfo *tabInfoModel = [[FHHouseDetailImageTabInfo alloc] init];
            tabInfoModel.tabName = groupModel.name;
            NSMutableArray *tabContent = [NSMutableArray arrayWithCapacity:groupModel.images.count];
            for (FHImageModel *image in groupModel.images) {
                FHHouseDetailImageStruct *imageStruct = [[FHHouseDetailImageStruct alloc] init];
                imageStruct.smallImage = image;
                [tabContent addObject:imageStruct];
            }
            tabInfoModel.tabContent = tabContent.copy;
            [tabArr addObject:tabInfoModel];
        }
        albumInfo.tabList = tabArr.copy;
        photoAlbumData.detailAlbumInfo = albumInfo;
        FHFloorPanPicShowModel *picShowModel = [[FHFloorPanPicShowModel alloc] init];
        NSMutableArray *mArr = [NSMutableArray array];
        for (FHHouseDetailImageTabInfo *tabInfo in albumInfo.tabList) {
            [mArr addObjectsFromArray:[FHFloorPanPicShowGroupModel getTabGroupInfo:tabInfo rootName:tabInfo.tabName]];
        }
        picShowModel.itemGroupList = mArr.copy;
        photoAlbumData.floorPanModel = picShowModel;
    }
    return photoAlbumData;
}

@end

@implementation FHDetailNewMediaHeaderDataHelperHeaderViewData

@end
@implementation FHDetailNewMediaHeaderDataHelperPictureDetailData

@end
@implementation FHDetailNewMediaHeaderDataHelperPhotoAlbumData

@end
