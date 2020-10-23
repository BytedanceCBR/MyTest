//
//  FHDetailNeighborhoodMediaHeaderDataHelper.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/14.
//

#import "FHDetailNeighborhoodMediaHeaderDataHelper.h"
#import "FHMultiMediaModel.h"
#import "FHDetailNeighborhoodMediaHeaderCell.h"
#import "FHFloorPanPicShowModel.h"

@interface FHDetailNeighborhoodMediaHeaderDataHelper ()

@property (nonatomic, strong, readwrite) FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData *headerViewData;
//提供给图片详情页的数据
@property (nonatomic, strong, readwrite) FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData *pictureDetailData;
//提供给图片相册的数据
@property (nonatomic, strong, readwrite) FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData *photoAlbumData;

@end

@implementation FHDetailNeighborhoodMediaHeaderDataHelper
- (void)setMediaHeaderModel:(FHDetailNeighborhoodMediaHeaderModel *)mediaHeaderModel {
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

#pragma mark - data manage

+ (FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHDetailNeighborhoodMediaHeaderModel *)newMediaHeaderModel {
FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData *headerViewData = [[FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData alloc] init];
    
    
    NSArray *houseImageDict = newMediaHeaderModel.houseImageDictList;
    NSMutableArray *itemArray = [NSMutableArray array];
    NSUInteger pictureNumber = 0;
    NSUInteger baiduPanoramaIndex = -1;
    NSUInteger videoNumer = 0;
    
    
    FHMultiMediaItemModel *videoModel = newMediaHeaderModel.vedioModel;
    FHMultiMediaItemModel *baiduPanoramaModel = newMediaHeaderModel.baiduPanoramaModel;
    
    if (videoModel && videoModel.videoID.length > 0) {
        videoNumer = 1;
        [itemArray addObject:videoModel];
    }
    
    if (baiduPanoramaModel && baiduPanoramaModel.imageUrl.length > 0) {
        baiduPanoramaIndex = itemArray.count;
        [itemArray addObject:baiduPanoramaModel];
    }
    
    for (FHHouseDetailImageListDataModel *listModel in houseImageDict) {
        NSString *groupType = @"图片";
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
    headerViewData.videoNumer = videoNumer;
    headerViewData.baiduPanoramaIndex = baiduPanoramaIndex;
    
    return headerViewData;
}

+ (FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHDetailNeighborhoodMediaHeaderModel *)newMediaHeaderModel {
    FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData *pictureDetailData = [[FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData alloc] init];
    
    FHDetailPictureModel *pictureModel = [[FHDetailPictureModel alloc] init];
    NSMutableArray *itemArray = [NSMutableArray array];
    
    NSMutableArray *pictureArray = [NSMutableArray array];
    
    FHMultiMediaItemModel *videoModel = newMediaHeaderModel.vedioModel;
    if (videoModel && videoModel.videoID.length > 0) {
        [itemArray addObject:videoModel];
        FHDetailPictureItemVideoModel *videoItemModel = [[FHDetailPictureItemVideoModel alloc] init];
        videoItemModel.itemType = FHDetailPictureModelTypeVideo;
        
        FHImageModel *image = [[FHImageModel alloc] init];
        image.url = videoModel.imageUrl;
        image.urlList = [NSArray arrayWithObject:videoModel.imageUrl];
        videoItemModel.image = image;
        
        FHVideoModel *pictureVideoModel = [[FHVideoModel alloc] init];
        pictureVideoModel.videoID = videoModel.videoID;
        pictureVideoModel.vWidth = videoModel.vWidth;
        pictureVideoModel.vHeight = videoModel.vHeight;
        pictureVideoModel.muted = NO;
        pictureVideoModel.repeated = NO;
        pictureVideoModel.isShowControl = YES;
        pictureVideoModel.isShowMiniSlider = YES;
        pictureVideoModel.isShowStartBtnWhenPause = YES;
        
        videoItemModel.videoModel = pictureVideoModel;
        videoItemModel.videoModel.coverImageUrl = videoModel.imageUrl;
        videoItemModel.rootGroupName = @"视频";
        [pictureArray addObject:videoItemModel];
        
    }
    
    NSArray *houseImageDict = newMediaHeaderModel.houseImageDictList;
    for (FHHouseDetailImageListDataModel *listModel in houseImageDict) {
        for (FHImageModel *imageModel in listModel.houseImageList) {
            if (imageModel.url.length > 0) {
                FHMultiMediaItemModel *itemModel = [[FHMultiMediaItemModel alloc] init];
                itemModel.mediaType = FHMultiMediaTypePicture;
                itemModel.imageUrl = imageModel.url;
                itemModel.pictureType = listModel.houseImageType;
                itemModel.pictureTypeName = listModel.houseImageTypeName;
                [itemArray addObject:itemModel];
                
                FHDetailPictureItemPictureModel *pictureModel = [[FHDetailPictureItemPictureModel alloc] init];
                pictureModel.image = imageModel;
                pictureModel.rootGroupName = listModel.houseImageTypeName;
                [pictureArray addObject:pictureModel];
            }
        }
    }
    
    pictureModel.itemList = pictureArray.copy;
    pictureDetailData.detailPictureModel = pictureModel;
    pictureDetailData.mediaItemArray = itemArray.copy;
    
    return pictureDetailData;
}

+ (FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHDetailNeighborhoodMediaHeaderModel *)newMediaHeaderModel {
    FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData *albumData = [[FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData alloc] init];
    FHFloorPanPicShowModel *picShowModel = [[FHFloorPanPicShowModel alloc] init];
    NSMutableArray *mArr = [NSMutableArray array];
    FHMultiMediaItemModel *videoModel = newMediaHeaderModel.vedioModel;
    if (videoModel.videoID.length) {
        FHFloorPanPicShowGroupModel *videoGroupModel = [[FHFloorPanPicShowGroupModel alloc] init];
        videoGroupModel.rootGroupName = videoModel.groupType;
        videoGroupModel.groupName = videoModel.groupType;
        FHFloorPanPicShowItemVideoModel *itemModel = [[FHFloorPanPicShowItemVideoModel alloc] init];
        FHImageModel *image = [[FHImageModel alloc] init];
        image.height = [@(videoModel.vHeight) stringValue];
        image.height = [@(videoModel.vWidth) stringValue];
        image.url = videoModel.imageUrl;
        itemModel.image = image;
        itemModel.itemType = FHFloorPanPicShowModelTypeVideo;
        videoGroupModel.items = [NSArray<FHFloorPanPicShowItemModel> arrayWithObject:itemModel];
        [mArr addObject:videoGroupModel];
        
    }
    
    for (FHHouseDetailMediaTabInfo *tabInfo in newMediaHeaderModel.albumInfo.tabList) {
        [mArr addObjectsFromArray:[FHFloorPanPicShowGroupModel getTabGroupInfo:tabInfo rootName:tabInfo.tabName]];
    }
    picShowModel.itemGroupList = mArr.copy;
    albumData.floorPanModel = picShowModel;
    return albumData;
}

@end

@implementation FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData

@end
@implementation FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData

@end
@implementation FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData

@end
