//
//  FHDetailNewMediaHeaderDataHelper.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/23.
//
//负责头图部分的数据处理，包括轮播图数据，大图展示数据，图片相册数据
#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"
@class FHMultiMediaItemModel,FHDetailNewMediaHeaderDataHelperHeaderViewData,FHDetailNewMediaHeaderDataHelperPictureDetailData,FHDetailNewMediaHeaderDataHelperPhotoAlbumData;
NS_ASSUME_NONNULL_BEGIN
@class FHDetailNewMediaHeaderDataHelperData,FHDetailNewMediaHeaderModel,FHHouseDetailImageGroupModel;
@class FHFloorPanPicShowModel;
@interface FHDetailNewMediaHeaderDataHelper : NSObject
//提供给头图的数据
@property (nonatomic, strong, readonly) FHDetailNewMediaHeaderDataHelperHeaderViewData *headerViewData;
//提供给图片详情页的数据
@property (nonatomic, strong, readonly) FHDetailNewMediaHeaderDataHelperPictureDetailData *pictureDetailData;
//提供给图片相册的数据
@property (nonatomic, strong, readonly) FHDetailNewMediaHeaderDataHelperPhotoAlbumData *photoAlbumData;





@property (nonatomic, strong) FHDetailNewMediaHeaderModel *mediaHeaderModel;


+ (FHDetailNewMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel;
+ (FHDetailNewMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel;
+ (FHDetailNewMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHDetailNewMediaHeaderModel *)newMediaHeaderModel;

@end


@interface FHDetailNewMediaHeaderDataHelperHeaderViewData : NSObject
@property (nonatomic, copy) NSArray<FHMultiMediaItemModel*> *mediaItemArray;
@property (nonatomic, assign) NSUInteger pictureNumber;
@property (nonatomic, assign) NSUInteger vrNumber;
@end

@interface FHDetailNewMediaHeaderDataHelperPictureDetailData : NSObject

@property (nonatomic, copy) NSArray<FHMultiMediaItemModel*> *mediaItemArray;
@property (nonatomic, copy) NSArray<FHDetailPhotoHeaderModelProtocol> *photoArray;
@end

@interface FHDetailNewMediaHeaderDataHelperPhotoAlbumData : NSObject
@property (nonatomic, copy) NSArray<FHHouseDetailImageGroupModel *> *photoAlbumArray;
@property (nonatomic, strong) FHHouseDetailAlbumInfo *detailAlbumInfo;
@property (nonatomic, strong) FHFloorPanPicShowModel *floorPanModel;
@property (nonatomic, strong) FHFloorPanPicShowModel *newFloorPanModel;
@end


NS_ASSUME_NONNULL_END
