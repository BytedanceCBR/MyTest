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

+ (NSArray<FHMultiMediaItemModel> *)getMultiMediaItem:(FHHouseDetailMediaTabInfo *)tabInfo rootName:(NSString *)rootName {
    NSMutableArray *groupModels = [NSMutableArray array];
    if (tabInfo.tabContent.count > 0) {
        for (FHHouseDetailMediaStruct *mediaStr in tabInfo.tabContent) {
            FHMultiMediaItemModel *item = [[FHMultiMediaItemModel alloc] init];
            if (mediaStr.vrInfo) {   //VR
                item.mediaType = FHMultiMediaTypeVRPicture;
                item.groupType = tabInfo.tabName;
                item.imageUrl = mediaStr.image.url;
                item.vrOpenUrl = mediaStr.vrInfo.openUrl;
                item.pictureTypeName = rootName;
                [groupModels addObject:item];
            } else {                        //图片
                item.mediaType = FHMultiMediaTypePicture;
                item.groupType = tabInfo.tabName;
                item.imageUrl = mediaStr.image.url;
                item.pictureTypeName = rootName;
                [groupModels addObject:item];
            }
        }
    } else if (tabInfo.subTab.count > 0) {
        for (FHHouseDetailMediaTabInfo *otherTabInfo in tabInfo.subTab) {
            NSArray *otherArr = [FHFloorPanDetailMediaHeaderDataHelper getMultiMediaItem:otherTabInfo rootName:rootName];
            [groupModels addObjectsFromArray:otherArr];
        }
    }
    return groupModels.copy;
}

+ (FHFloorPanDetailMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHFloorPanDetailMediaHeaderModel *)newMediaHeaderModel {
    FHFloorPanDetailMediaHeaderDataHelperHeaderViewData *headerViewData = [[FHFloorPanDetailMediaHeaderDataHelperHeaderViewData alloc] init];
    NSMutableArray *itemArray = [NSMutableArray array];
    for (FHHouseDetailMediaTabInfo *mediaTabInfo in newMediaHeaderModel.topImages.tabList) {
        [itemArray addObjectsFromArray:[FHFloorPanDetailMediaHeaderDataHelper getMultiMediaItem:mediaTabInfo rootName:mediaTabInfo.tabName]];
    }
    
    headerViewData.mediaItemArray = itemArray.copy;
    
    return headerViewData;
}

//大图详情页的数据
+ (FHFloorPanDetailMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHFloorPanDetailMediaHeaderModel *)newMediaHeaderModel {
    FHFloorPanDetailMediaHeaderDataHelperPictureDetailData *pictureDetailData = [[FHFloorPanDetailMediaHeaderDataHelperPictureDetailData alloc] init];
    FHDetailPictureModel *pictureModel = [[FHDetailPictureModel alloc] init];
    NSMutableArray *itemArray = [NSMutableArray array];
    NSMutableArray *itemList = [NSMutableArray array];

    for (FHHouseDetailMediaTabInfo *mediaTabInfo in newMediaHeaderModel.albumInfo.tabList) {
        [itemList addObjectsFromArray:[FHDetailPictureItemModel getPictureTabInfo:mediaTabInfo rootName:mediaTabInfo.tabName]];
    }
    for (FHHouseDetailMediaTabInfo *mediaTabInfo in newMediaHeaderModel.albumInfo.tabList) {
        [itemArray addObjectsFromArray:[FHFloorPanDetailMediaHeaderDataHelper getMultiMediaItem:mediaTabInfo rootName:mediaTabInfo.tabName]];
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

+ (FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHFloorPanDetailMediaHeaderModel *)newMediaHeaderModel {
    
    FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData *photoAlbumData = [[FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData alloc] init];
    
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

@implementation FHFloorPanDetailMediaHeaderDataHelperHeaderViewData

@end
@implementation FHFloorPanDetailMediaHeaderDataHelperPictureDetailData

@end
@implementation FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData

@end
