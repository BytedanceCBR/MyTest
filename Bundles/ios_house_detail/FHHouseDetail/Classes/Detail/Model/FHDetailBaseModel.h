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

@interface FHDetailShareInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *coverImage;
@property (nonatomic, copy , nullable) NSString *isVideo;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *title;
@end


NS_ASSUME_NONNULL_END
