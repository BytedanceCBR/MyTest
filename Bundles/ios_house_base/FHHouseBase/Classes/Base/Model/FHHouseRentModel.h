//
//  FHHouseRentModel.h
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/22.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseRentDataItemsModel<NSObject>

@end

@protocol FHHouseRentDataItemsHouseImageModel<NSObject>

@end


@interface  FHHouseRentDataItemsHouseImageModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@protocol FHHouseRentDataItemsTagsModel<NSObject>

@end


@interface  FHHouseRentDataItemsTagsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHHouseRentDataItemsHouseImageTagModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHHouseRentDataItemsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *subtitle;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHHouseRentDataItemsHouseImageModel> *houseImage;
@property (nonatomic, strong , nullable) NSArray<FHHouseRentDataItemsTagsModel> *tags;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong , nullable) FHHouseRentDataItemsHouseImageTagModel *houseImageTag ;
@property (nonatomic, copy , nullable) NSString *id;

@end


@interface  FHHouseRentDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHHouseRentDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *houseListOpenUrl;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *mapFindHouseOpenUrl;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;

@end


@interface  FHHouseRentModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseRentDataModel *data ;

@end

NS_ASSUME_NONNULL_END
