//
//  FHDetailNeighborhoodMediaHeaderDataHelper.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/14.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"
#import "FHDetailPictureModel.h"
@class FHMultiMediaItemModel,FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData,FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData,FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData;
NS_ASSUME_NONNULL_BEGIN
@class FHDetailNewMediaHeaderDataHelperData,FHNeighborhoodDetailHeaderMediaModel,FHHouseDetailImageGroupModel;
@class FHFloorPanPicShowModel;



@interface FHDetailNeighborhoodMediaHeaderDataHelper : NSObject
//提供给头图的数据
@property (nonatomic, strong, readonly) FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData *headerViewData;
//提供给图片详情页的数据
@property (nonatomic, strong, readonly) FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData *pictureDetailData;
//提供给图片相册的数据
@property (nonatomic, strong, readonly) FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData *photoAlbumData;

@property (nonatomic, strong) FHNeighborhoodDetailHeaderMediaModel *mediaHeaderModel;

- (NSInteger) getPictureDetailIndexFromMediaHeaderIndex:(NSInteger)index;

- (NSInteger) getMediaHeaderIndexFromPictureDetailIndex:(NSInteger)index;


+ (FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData *)generateMediaHeaderViewData:(FHNeighborhoodDetailHeaderMediaModel *)newMediaHeaderModel;
+ (FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData *)generatePictureDetailData:(FHNeighborhoodDetailHeaderMediaModel *)newMediaHeaderModel;
+ (FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData *)generatePhotoAlbumData:(FHNeighborhoodDetailHeaderMediaModel *)newMediaHeaderModel;

@end

@interface FHDetailNeighborhoodMediaHeaderDataHelperHeaderViewData : NSObject
@property (nonatomic, copy) NSArray<FHMultiMediaItemModel*> *mediaItemArray;
@property (nonatomic, assign) NSUInteger pictureNumber;
@property (nonatomic, assign) NSUInteger videoNumer;
@property (nonatomic, assign) NSUInteger baiduPanoramaIndex;
@end

@interface FHDetailNeighborhoodMediaHeaderDataHelperPictureDetailData : NSObject

@property (nonatomic, copy) NSArray<FHMultiMediaItemModel*> *mediaItemArray;
@property (nonatomic, strong) FHDetailPictureModel *detailPictureModel;
@end

@interface FHDetailNeighborhoodMediaHeaderDataHelperPhotoAlbumData : NSObject
@property (nonatomic, strong) FHFloorPanPicShowModel *floorPanModel;
@end

NS_ASSUME_NONNULL_END
