//
//  FHDetailNewMediaHeaderDataHelper.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/23.
//
//负责头图部分的数据处理，包括轮播图数据，大图展示数据，图片相册数据

//数据包括了，埋点所需的数据，展示的数据，一些数组。
#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"
#import "FHDetailPictureModel.h"
@class FHMultiMediaItemModel,FHDetailNewMediaHeaderDataHelperHeaderViewData,FHDetailNewMediaHeaderDataHelperPictureDetailData,FHDetailNewMediaHeaderDataHelperPhotoAlbumData;
NS_ASSUME_NONNULL_BEGIN
@class FHDetailNewMediaHeaderDataHelperData,FHNewHouseDetailHeaderMediaModel,FHHouseDetailImageGroupModel;
@class FHFloorPanPicShowModel;
@interface FHDetailNewMediaHeaderDataHelper : NSObject
//提供给头图的数据
@property (nonatomic, strong, readonly) FHDetailNewMediaHeaderDataHelperHeaderViewData *headerViewData;
//提供给图片详情页的数据
@property (nonatomic, strong, readonly) FHDetailNewMediaHeaderDataHelperPictureDetailData *pictureDetailData;
//提供给图片相册的数据
@property (nonatomic, strong, readonly) FHDetailNewMediaHeaderDataHelperPhotoAlbumData *photoAlbumData;





@property (nonatomic, strong) FHNewHouseDetailHeaderMediaModel *mediaHeaderModel;


+ (FHDetailNewMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHNewHouseDetailHeaderMediaModel *)newMediaHeaderModel;
+ (FHDetailNewMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHNewHouseDetailHeaderMediaModel *)newMediaHeaderModel;
+ (FHDetailNewMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHNewHouseDetailHeaderMediaModel *)newMediaHeaderModel;

@end


@interface FHDetailNewMediaHeaderDataHelperHeaderViewData : NSObject
@property (nonatomic, copy) NSArray<FHMultiMediaItemModel*> *mediaItemArray;
@end

@interface FHDetailNewMediaHeaderDataHelperPictureDetailData : NSObject

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

@interface FHDetailNewMediaHeaderDataHelperPhotoAlbumData : NSObject
@property (nonatomic, strong) FHFloorPanPicShowModel *floorPanModel;
//相册线索
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *imageAlbumAssociateInfo;
//经纪人信息
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;
@end


NS_ASSUME_NONNULL_END
