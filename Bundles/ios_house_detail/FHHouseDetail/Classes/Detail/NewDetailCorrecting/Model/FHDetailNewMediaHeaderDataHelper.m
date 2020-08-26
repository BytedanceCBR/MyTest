//
//  FHDetailNewMediaHeaderDataHelper.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/23.
//

#import "FHDetailNewMediaHeaderDataHelper.h"
#import "FHMultiMediaModel.h"
#import "FHDetailNewMediaHeaderCell.h"

@interface FHDetailNewMediaHeaderDataHelper ()

@property (nonatomic, copy, readwrite) FHDetailNewMediaHeaderDataHelperHeaderViewData *headerViewData;
//提供给图片详情页的数据
@property (nonatomic, copy, readwrite) FHDetailNewMediaHeaderDataHelperPictureDetailData *pictureDetailData;
//提供给图片相册的数据
@property (nonatomic, copy, readwrite) FHDetailNewMediaHeaderDataHelperPhotoAlbumData *photoAlbumData;
@end

@implementation FHDetailNewMediaHeaderDataHelper

- (void)setNewMediaHeaderModel:(FHDetailNewMediaHeaderModel *)mediaHeaderModel {
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
    NSInteger vrNumber = 0;
    NSInteger pictureNumber = 0;
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
    return photoAlbumData;
}

@end

@implementation FHDetailNewMediaHeaderDataHelperHeaderViewData


@end
@implementation FHDetailNewMediaHeaderDataHelperPictureDetailData


@end
@implementation FHDetailNewMediaHeaderDataHelperPhotoAlbumData


@end
