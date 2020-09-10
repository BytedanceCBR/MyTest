//
//  FHFloorPanPicShowModel.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/10.
//

#import <Foundation/Foundation.h>
#import "FHDetailBaseModel.h"
NS_ASSUME_NONNULL_BEGIN
@class FHFloorPanPicShowGroupModel;
typedef NS_ENUM(NSUInteger, FHFloorPanPicShowModelType) {
    FHFloorPanPicShowModelTypePicture = 0, //图片
    FHFloorPanPicShowModelTypeVideo = 1, //视频
    FHFloorPanPicShowModelTypeVR = 2 //VR
};



@protocol FHFloorPanPicShowItemModel <NSObject>
@end

@interface FHFloorPanPicShowItemModel : NSObject
@property (nonatomic, strong) FHImageModel *image;
@property (nonatomic, assign) FHFloorPanPicShowModelType itemType;
@end

@protocol FHFloorPanPicShowGroupModel <NSObject>

@end

@interface FHFloorPanPicShowGroupModel : NSObject
@property (nonatomic, strong) NSArray<FHFloorPanPicShowItemModel> *items;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *rootGroupName;
@property (nonatomic, copy) NSString *type;

+ (NSArray<FHFloorPanPicShowGroupModel> *)getTabGroupInfo:(FHHouseDetailImageTabInfo *)tabInfo rootName:(NSString *)rootName;
@end



//留下这些继承关系主要是为了在其中储存一些有益的参数
@interface FHFloorPanPicShowItemPictureModel : FHFloorPanPicShowItemModel

@end

@interface FHFloorPanPicShowItemVideoModel : FHFloorPanPicShowItemModel

@end

@interface FHFloorPanPicShowItemVRModel : FHFloorPanPicShowItemModel

@end

@interface FHFloorPanPicShowModel : NSObject

@property (nonatomic, strong) NSArray<FHFloorPanPicShowGroupModel> *itemGroupList;

@end
NS_ASSUME_NONNULL_END
