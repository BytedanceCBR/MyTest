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
    if (![mediaHeaderModel isKindOfClass:[FHDetailNewMediaHeaderModel class]]) {
        return;
    }
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

+ (NSArray<FHMultiMediaItemModel> *)getMultiMediaItem:(FHHouseDetailMediaTabInfo *)tabInfo rootName:(NSString *)rootName {
    NSMutableArray *groupModels = [NSMutableArray array];
    if (tabInfo.tabContent.count > 0) {
        for (FHHouseDetailMediaStruct *mediaStr in tabInfo.tabContent) {
            FHMultiMediaItemModel *item = [[FHMultiMediaItemModel alloc] init];
            if (mediaStr.videoInfo) {   //视频
                item.mediaType = FHMultiMediaTypeVideo;
                item.groupType = @"视频";
                item.imageUrl = mediaStr.image.url;
                item.videoID = mediaStr.videoInfo.vid;
                item.vHeight = mediaStr.videoInfo.vHeight;
                item.vWidth = mediaStr.videoInfo.vWidth;
                item.pictureTypeName = rootName;
                [groupModels addObject:item];
            } else if (mediaStr.vrInfo) {   //VR
                item.mediaType = FHMultiMediaTypeVRPicture;
                item.groupType = @"VR";
                item.imageUrl = mediaStr.image.url;
                item.vrOpenUrl = mediaStr.vrInfo.openUrl;
                item.pictureTypeName = rootName;
                [groupModels addObject:item];
            } else {                        //图片
                item.mediaType = FHMultiMediaTypePicture;
                item.groupType = @"图片";
                item.imageUrl = mediaStr.image.url;
                item.pictureTypeName = rootName;
                [groupModels addObject:item];
            }
        }
    } else if (tabInfo.subTab.count > 0) {
        for (FHHouseDetailMediaTabInfo *otherTabInfo in tabInfo.subTab) {
            NSArray *otherArr = [FHDetailNewMediaHeaderDataHelper getMultiMediaItem:otherTabInfo rootName:rootName];
            [groupModels addObjectsFromArray:otherArr];
        }
    }
    return groupModels.copy;
}

+ (FHDetailNewMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel {
    FHDetailNewMediaHeaderDataHelperHeaderViewData *headerViewData = [[FHDetailNewMediaHeaderDataHelperHeaderViewData alloc] init];
    
    NSMutableArray *itemArray = [NSMutableArray array];
    for (FHHouseDetailMediaTabInfo *mediaTabInfo in newMediaHeaderModel.albumInfo.tabList) {
        [itemArray addObjectsFromArray:[FHDetailNewMediaHeaderDataHelper getMultiMediaItem:mediaTabInfo rootName:mediaTabInfo.tabName]];
    }
    
    headerViewData.mediaItemArray = itemArray.copy;
    
    return headerViewData;
}

//大图详情页的数据
+ (FHDetailNewMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel {
    FHDetailNewMediaHeaderDataHelperPictureDetailData *pictureDetailData = [[FHDetailNewMediaHeaderDataHelperPictureDetailData alloc] init];
    FHDetailPictureModel *pictureModel = [[FHDetailPictureModel alloc] init];
    NSMutableArray *itemArray = [NSMutableArray array];
    NSMutableArray *itemList = [NSMutableArray array];

    for (FHHouseDetailMediaTabInfo *mediaTabInfo in newMediaHeaderModel.albumInfo.tabList) {
        [itemList addObjectsFromArray:[FHDetailPictureItemModel getPictureTabInfo:mediaTabInfo rootName:mediaTabInfo.tabName]];
    }
    for (FHHouseDetailMediaTabInfo *mediaTabInfo in newMediaHeaderModel.albumInfo.tabList) {
        [itemArray addObjectsFromArray:[FHDetailNewMediaHeaderDataHelper getMultiMediaItem:mediaTabInfo rootName:mediaTabInfo.tabName]];
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

+ (FHDetailNewMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel {
    
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
