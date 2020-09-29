//
//  FHFloorPanDetailMediaHeaderDataHelper.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/7.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"
#import "FHDetailPictureModel.h"
#import "FHFloorPanPicShowModel.h"
@class FHMultiMediaItemModel,FHFloorPanDetailMediaHeaderDataHelperHeaderViewData,FHFloorPanDetailMediaHeaderDataHelperPictureDetailData,FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData,FHFloorPanDetailMediaHeaderModel;
NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanDetailMediaHeaderDataHelper : NSObject
//提供给头图的数据
@property (nonatomic, strong, readonly) FHFloorPanDetailMediaHeaderDataHelperHeaderViewData *headerViewData;
//提供给图片详情页的数据
@property (nonatomic, strong, readonly) FHFloorPanDetailMediaHeaderDataHelperPictureDetailData *pictureDetailData;
//提供给图片相册的数据
@property (nonatomic, strong, readonly) FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData *photoAlbumData;

@property (nonatomic, strong) FHFloorPanDetailMediaHeaderModel *mediaHeaderModel;


+ (FHFloorPanDetailMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHFloorPanDetailMediaHeaderModel *)newMediaHeaderModel;
+ (FHFloorPanDetailMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHFloorPanDetailMediaHeaderModel *)newMediaHeaderModel;
+ (FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHFloorPanDetailMediaHeaderModel *)newMediaHeaderModel;

@end

@interface FHFloorPanDetailMediaHeaderDataHelperHeaderViewData : NSObject
@property (nonatomic, copy) NSArray<FHMultiMediaItemModel*> *mediaItemArray;
@end

@interface FHFloorPanDetailMediaHeaderDataHelperPictureDetailData : NSObject

@property (nonatomic, copy) NSArray<FHMultiMediaItemModel*> *mediaItemArray;
@property (nonatomic, strong) FHDetailPictureModel *detailPictureModel;

//大图图片线索
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *imageGroupAssociateInfo;
//VR线索
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *vrImageAssociateInfo;
//视频线索
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *videoImageAssociateInfo;
//经纪人信息
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;

@end

@interface FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData : NSObject
@property (nonatomic, strong) FHFloorPanPicShowModel *floorPanModel;
//相册线索
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *imageAlbumAssociateInfo;
//经纪人信息
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@end

NS_ASSUME_NONNULL_END
