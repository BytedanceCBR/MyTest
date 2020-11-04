//
//  FHDetailNeighborhoodMediaHeaderDataHelper.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/14.
//

#import "FHDetailNeighborhoodMediaHeaderDataHelper.h"
#import "FHMultiMediaModel.h"
#import "FHNeighborhoodDetailHeaderMediaCollectionCell.h"
#import "FHFloorPanPicShowModel.h"

@interface FHDetailNeighborhoodMediaHeaderDataHelper ()

@property (nonatomic, strong, readwrite) FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData *headerViewData;
//提供给图片详情页的数据
@property (nonatomic, strong, readwrite) FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData *pictureDetailData;
//提供给图片相册的数据
@property (nonatomic, strong, readwrite) FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData *photoAlbumData;

@end

@implementation FHDetailNeighborhoodMediaHeaderDataHelper
- (void)setMediaHeaderModel:(FHNeighborhoodDetailHeaderMediaModel *)mediaHeaderModel {
    _mediaHeaderModel = mediaHeaderModel;
    _headerViewData = nil;
    _pictureDetailData = nil;
    _photoAlbumData = nil;
}

- (FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData *)headerViewData {
    if (!_headerViewData) {
        _headerViewData = [FHDetailNeighborhoodMediaHeaderDataHelper generateMediaHeaderViewData:self.mediaHeaderModel];
    }
    return _headerViewData;
}

- (FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData *)pictureDetailData {
    if (!_pictureDetailData) {
        _pictureDetailData = [FHDetailNeighborhoodMediaHeaderDataHelper generatePictureDetailData:self.mediaHeaderModel];
    }
    return _pictureDetailData;
}

- (FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData *)photoAlbumData {
    if (!_photoAlbumData) {
        _photoAlbumData = [FHDetailNeighborhoodMediaHeaderDataHelper generatePhotoAlbumData:self.mediaHeaderModel];
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

+ (FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHNeighborhoodDetailHeaderMediaModel *)newMediaHeaderModel {
FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData *headerViewData = [[FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData alloc] init];
    NSMutableArray *itemArray = [NSMutableArray array];
    for (FHHouseDetailMediaTabInfo *mediaTabInfo in newMediaHeaderModel.neighborhoodTopImage.tabList) {
        [itemArray addObjectsFromArray:[FHMultiMediaItemModel getMultiMediaItem:mediaTabInfo rootName:mediaTabInfo.tabName]];
    }
    
    headerViewData.mediaItemArray = itemArray.copy;
    return headerViewData;
}

+ (FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHNeighborhoodDetailHeaderMediaModel *)newMediaHeaderModel {
    FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData *pictureDetailData = [[FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData alloc] init];
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
    return pictureDetailData;
}

+ (FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHNeighborhoodDetailHeaderMediaModel *)newMediaHeaderModel {
    FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData *photoAlbumData = [[FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData alloc] init];
    FHFloorPanPicShowModel *picShowModel = [[FHFloorPanPicShowModel alloc] init];
    NSMutableArray *mArr = [NSMutableArray array];
    for (FHHouseDetailMediaTabInfo *tabInfo in newMediaHeaderModel.albumInfo.tabList) {
        [mArr addObjectsFromArray:[FHFloorPanPicShowGroupModel getTabGroupInfo:tabInfo rootName:tabInfo.tabName]];
    }
    picShowModel.itemGroupList = mArr.copy;
    
    photoAlbumData.floorPanModel = picShowModel;
    return photoAlbumData;
}

@end

@implementation FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData

@end
@implementation FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData

@end
@implementation FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData

@end
