//
//  FHDetailBaseModel.h
//  Pods
//
//  Created by 张静 on 2019/1/31.
//

#import <Foundation/Foundation.h>
#import "FHHouseListModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHDetailPhotoHeaderModelProtocol <AbstractJSONModelProtocol>

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray *urlList;

@end

@protocol FHDetailHouseDataItemsHouseImageModel<NSObject>
@end

@interface  FHDetailHouseDataItemsHouseImageModel  : JSONModel<FHDetailPhotoHeaderModelProtocol>

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end

@interface FHDetailBaseModel : NSObject

@end

@interface FHDetailPhotoHeaderModel : FHDetailBaseModel
@property (nonatomic, strong , nullable) NSArray<FHDetailHouseDataItemsHouseImageModel *> *houseImage;
@end

// cell底部灰条
@interface FHDetailGrayLineModel : FHDetailBaseModel

@property (nonatomic, assign)   CGFloat       lineHeight;

@end

NS_ASSUME_NONNULL_END
