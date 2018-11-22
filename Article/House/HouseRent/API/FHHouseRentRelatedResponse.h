//
//  FHHouseRentRelatedResponse.h
//  Article
//
//  Created by leo on 2018/11/22.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseRentRelatedResponseDataItemsModel<NSObject>

@end


@interface  FHHouseRentRelatedResponseDataItemsLogPbModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *groupId;

@end


@protocol FHHouseRentRelatedResponseDataItemsHouseImageModel<NSObject>

@end


@interface  FHHouseRentRelatedResponseDataItemsHouseImageModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@protocol FHHouseRentRelatedResponseDataItemsTagsModel<NSObject>

@end


@interface  FHHouseRentRelatedResponseDataItemsTagsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHHouseRentRelatedResponseDataItemsHouseImageTagModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHHouseRentRelatedResponseDataItemsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) FHHouseRentRelatedResponseDataItemsLogPbModel *logPb ;
@property (nonatomic, copy , nullable) NSString *subtitle;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHHouseRentRelatedResponseDataItemsHouseImageModel> *houseImage;
@property (nonatomic, strong , nullable) NSArray<FHHouseRentRelatedResponseDataItemsTagsModel> *tags;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong , nullable) FHHouseRentRelatedResponseDataItemsHouseImageTagModel *houseImageTag ;
@property (nonatomic, copy , nullable) NSString *id;

@end


@interface  FHHouseRentRelatedResponseDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHHouseRentRelatedResponseDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;

@end


@interface  FHHouseRentRelatedResponseModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseRentRelatedResponseDataModel *data ;

@end

NS_ASSUME_NONNULL_END
