//
//  FHHouseNeighborModel.h
//  FHHouseBase
//
//  Created by 张静 on 2018/12/13.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseNeighborDataItemsModel<NSObject>

@end


@protocol FHHouseNeighborDataItemsImagesModel<NSObject>

@end


@interface  FHHouseNeighborDataItemsImagesModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end


@interface  FHHouseNeighborDataItemsBaseInfoMapModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *builtYear;

@end


@interface  FHHouseNeighborDataItemsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, copy , nullable) NSString *displayPrice;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *address;
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy , nullable) NSString *displayBuiltYear;
@property (nonatomic, strong , nullable) NSArray<FHHouseNeighborDataItemsImagesModel> *images;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *displayStatsInfo;
@property (nonatomic, strong , nullable) FHHouseNeighborDataItemsBaseInfoMapModel *baseInfoMap ;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *displaySubtitle;

@end


@interface  FHHouseNeighborDataModel  : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHHouseNeighborDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *houseListOpenUrl;
@property (nonatomic, copy , nullable) NSString *refreshTip;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;

@end


@interface  FHHouseNeighborModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseNeighborDataModel *data ;

@end





NS_ASSUME_NONNULL_END
