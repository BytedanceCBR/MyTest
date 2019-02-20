//
//  FHRentSameNeighborhoodResponse.h
//  NewsLite
//
//  Created by leo on 2018/11/22.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "FHSearchHouseModel.h"
#import "FHHouseRentModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol FHRentSameNeighborhoodResponseDataItemsModel<NSObject>

@end

@protocol FHRentSameNeighborhoodResponseDataItemsHouseImageModel<NSObject>

@end


@interface  FHRentSameNeighborhoodResponseDataItemsHouseImageModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@protocol FHRentSameNeighborhoodResponseDataItemsTagsModel<NSObject>

@end


@interface  FHRentSameNeighborhoodResponseDataItemsTagsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHRentSameNeighborhoodResponseDataItemsHouseImageTagModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;

@end


@interface  FHRentSameNeighborhoodResponseDataItemsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *subtitle;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray<FHRentSameNeighborhoodResponseDataItemsHouseImageModel> *houseImage;
@property (nonatomic, strong , nullable) NSArray<FHRentSameNeighborhoodResponseDataItemsTagsModel> *tags;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *pricing;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong , nullable) FHRentSameNeighborhoodResponseDataItemsHouseImageTagModel *houseImageTag ;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *searchId;

@end


@interface  FHRentSameNeighborhoodResponseDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHHouseRentDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;

@end


@interface  FHRentSameNeighborhoodResponseModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHRentSameNeighborhoodResponseDataModel *data ;

@end




NS_ASSUME_NONNULL_END
