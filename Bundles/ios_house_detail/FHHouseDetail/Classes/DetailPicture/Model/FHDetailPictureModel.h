//
//  FHDetailPictureModel.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/20.
//

#import <Foundation/Foundation.h>
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailBaseModel.h"
#import "FHVideoModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHDetailPictureModelType) {
    FHDetailPictureModelTypePicture = 0, //图片
    FHDetailPictureModelTypeVideo = 1, //视频
    FHDetailPictureModelTypeVR = 2 //VR
};



@protocol FHDetailPictureItemModel <NSObject>
@end

@interface FHDetailPictureItemModel : NSObject

@property (nonatomic, strong) FHImageModel *image;
@property (nonatomic, assign) FHDetailPictureModelType itemType;

@end



@interface FHDetailPictureItemPictureModel : FHDetailPictureItemModel

@end

@interface FHDetailPictureItemVideoModel : FHDetailPictureItemModel

@property (nonatomic, strong) FHVideoModel *videoModel;
@end

@interface FHDetailPictureItemVRModel : FHDetailPictureItemModel

@property (nonatomic, strong) FHDetailHouseVRDataModel *vrModel;

@end

@interface FHDetailPictureModel : NSObject

@property (nonatomic, strong) NSArray <FHDetailPictureItemModel> *itemList;


@end

NS_ASSUME_NONNULL_END
