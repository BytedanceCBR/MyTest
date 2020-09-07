//
//  FHFloorPanDetailMediaHeaderDataHelper.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/7.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"
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
@property (nonatomic, assign) NSUInteger pictureNumber;
@property (nonatomic, assign) NSUInteger vrNumber;
@end

@interface FHFloorPanDetailMediaHeaderDataHelperPictureDetailData : NSObject

@property (nonatomic, copy) NSArray<FHMultiMediaItemModel*> *mediaItemArray;
@property (nonatomic, copy) NSArray<FHDetailPhotoHeaderModelProtocol> *photoArray;
@end

@interface FHFloorPanDetailMediaHeaderDataHelperPhotoAlbumData : NSObject
@property (nonatomic, copy) NSArray<FHHouseDetailImageGroupModel *> *photoAlbumArray;
@end

NS_ASSUME_NONNULL_END
