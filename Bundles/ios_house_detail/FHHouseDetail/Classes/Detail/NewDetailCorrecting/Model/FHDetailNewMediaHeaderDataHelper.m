//
//  FHDetailNewMediaHeaderDataHelper.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/23.
//

#import "FHDetailNewMediaHeaderDataHelper.h"
#import "FHMultiMediaModel.h"
#import "FHNewHouseDetailHeaderMediaCollectionCell.h"
#import "FHFloorPanPicShowModel.h"

@interface FHDetailNewMediaHeaderDataHelper ()

@property (nonatomic, strong, readwrite) FHDetailNewMediaHeaderDataHelperHeaderViewData *headerViewData;
//提供给图片详情页的数据
@property (nonatomic, strong, readwrite) FHDetailNewMediaHeaderDataHelperPictureDetailData *pictureDetailData;
//提供给图片相册的数据
@property (nonatomic, strong, readwrite) FHDetailNewMediaHeaderDataHelperPhotoAlbumData *photoAlbumData;

@end

@implementation FHDetailNewMediaHeaderDataHelper

- (void)setMediaHeaderModel:(FHNewHouseDetailHeaderMediaModel *)mediaHeaderModel {
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

- (NSInteger) getPictureDetailIndexFromMediaHeaderIndex:(NSInteger)index {
    NSUInteger detailIndex = 0;
    if (index < 0 || index >= self.headerViewData.mediaItemArray.count) {
        return detailIndex;
    }
    FHMultiMediaItemModel *itemModel = self.headerViewData.mediaItemArray[index];

    for (NSInteger i = 0; i < self.pictureDetailData.mediaItemArray.count; i++) {
        FHMultiMediaItemModel *nextModel = self.pictureDetailData.mediaItemArray[i];
        if ([itemModel isEqualWithOtherMediaItemModel:nextModel]) {
            detailIndex = i;
            break;
        }
    }
    return detailIndex;
}

- (NSInteger)getMediaHeaderIndexFromPictureDetailIndex:(NSInteger)index {
    NSUInteger mediaHeaderIndex = 0;
    if (index < 0 || index >= self.pictureDetailData.mediaItemArray.count) {
        return mediaHeaderIndex;
    }
    FHMultiMediaItemModel *itemModel = self.pictureDetailData.mediaItemArray[index];

    
    for (NSInteger i = 0; i < self.headerViewData.mediaItemArray.count; i++) {
        FHMultiMediaItemModel *nextModel = self.headerViewData.mediaItemArray[i];
        if ([itemModel isEqualWithOtherMediaItemModel:nextModel]) {
            mediaHeaderIndex = i;
            break;
        }
    }
    return mediaHeaderIndex;
}

#pragma mark - data manage
//针对新版头图滑动数据改造
//对于每种VR只要一个可以用位运算，a|= 1<<x;
//全部VR + 图片

+ (FHDetailNewMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHNewHouseDetailHeaderMediaModel *)newMediaHeaderModel {
    FHDetailNewMediaHeaderDataHelperHeaderViewData *headerViewData = [[FHDetailNewMediaHeaderDataHelperHeaderViewData alloc] init];
    
    NSMutableArray *itemArray = [NSMutableArray array];
    for (FHHouseDetailMediaTabInfo *mediaTabInfo in newMediaHeaderModel.courtTopImage.tabList) {
        [itemArray addObjectsFromArray:[FHMultiMediaItemModel getMultiMediaItem:mediaTabInfo rootName:mediaTabInfo.tabName]];
    }
    
    headerViewData.mediaItemArray = itemArray.copy;
    
    return headerViewData;
}

//大图详情页的数据
+ (FHDetailNewMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHNewHouseDetailHeaderMediaModel *)newMediaHeaderModel {
    FHDetailNewMediaHeaderDataHelperPictureDetailData *pictureDetailData = [[FHDetailNewMediaHeaderDataHelperPictureDetailData alloc] init];
    FHDetailPictureModel *pictureModel = [[FHDetailPictureModel alloc] init];
    NSMutableArray *itemArray = [NSMutableArray array];
    NSMutableArray *itemList = [NSMutableArray array];

    for (FHHouseDetailMediaTabInfo *mediaTabInfo in newMediaHeaderModel.albumInfo.tabList) {
        [itemList addObjectsFromArray:[FHDetailPictureItemModel getPictureTabInfo:mediaTabInfo rootName:mediaTabInfo.tabName]];
    }
    for (FHHouseDetailMediaTabInfo *mediaTabInfo in newMediaHeaderModel.albumInfo.tabList) {
        [itemArray addObjectsFromArray:[FHMultiMediaItemModel getMultiMediaItem:mediaTabInfo rootName:mediaTabInfo.tabName]];
    }
    
    pictureModel.itemList = itemList.copy;
    pictureDetailData.mediaItemArray = itemArray.copy;
    pictureDetailData.detailPictureModel = pictureModel;
    
    pictureDetailData.imageGroupAssociateInfo = newMediaHeaderModel.albumInfo.imageGroupAssociateInfo;
    pictureDetailData.vrImageAssociateInfo = newMediaHeaderModel.albumInfo.vrImageAssociateInfo;
    pictureDetailData.videoImageAssociateInfo = newMediaHeaderModel.albumInfo.videoImageAssociateInfo;
    pictureDetailData.contactViewModel = newMediaHeaderModel.contactViewModel;
    
    return pictureDetailData;
}

+ (FHDetailNewMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHNewHouseDetailHeaderMediaModel *)newMediaHeaderModel {
    
    FHDetailNewMediaHeaderDataHelperPhotoAlbumData *photoAlbumData = [[FHDetailNewMediaHeaderDataHelperPhotoAlbumData alloc] init];
    
    FHFloorPanPicShowModel *picShowModel = [[FHFloorPanPicShowModel alloc] init];
    NSMutableArray *mArr = [NSMutableArray array];
    for (FHHouseDetailMediaTabInfo *tabInfo in newMediaHeaderModel.albumInfo.tabList) {
        [mArr addObjectsFromArray:[FHFloorPanPicShowGroupModel getTabGroupInfo:tabInfo rootName:tabInfo.tabName]];
    }
    picShowModel.itemGroupList = mArr.copy;
    
    photoAlbumData.floorPanModel = picShowModel;
    photoAlbumData.imageAlbumAssociateInfo = newMediaHeaderModel.albumInfo.imageAlbumAssociateInfo;
    photoAlbumData.contactViewModel = newMediaHeaderModel.contactViewModel;
    
    return photoAlbumData;
}

@end

@implementation FHDetailNewMediaHeaderDataHelperHeaderViewData

@end
@implementation FHDetailNewMediaHeaderDataHelperPictureDetailData

@end
@implementation FHDetailNewMediaHeaderDataHelperPhotoAlbumData

@end
