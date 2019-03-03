//已做修改，重新生成时需要注意
#import <JSONModel.h>
#import "FHHouseNeighborModel.h"
#import "FHHouseRentModel.h"
#import "FHSearchHouseModel.h"
#import "FHNewHouseItemModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FHFollowDataFollowItemsModel<NSObject>
@end

@protocol FHFollowDataFollowItemsTagsModel<NSObject>
@end

@interface FHFollowDataFollowItemsTagsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@protocol FHFollowDataFollowItemsImagesModel<NSObject>
@end

@interface FHFollowDataFollowItemsImagesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHFollowDataFollowItemsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *followId;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsTagsModel> *tags;
@property (nonatomic, copy , nullable) NSString *price;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *salesInfo;
@property (nonatomic, copy , nullable) NSString *pricePerSqm;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsHouseImageModel> *images;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *searchId;

- (FHHouseNeighborDataItemsModel *)toHouseNeighborModel;

- (FHSearchHouseDataItemsModel *)toHouseSecondHandModel;

- (FHNewHouseItemModel *)toHouseNewModel;

- (FHHouseRentDataItemsModel *)toHouseRentModel;

@end

@interface FHFollowDataModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *totalCount;
@property (nonatomic, strong , nullable) NSArray<FHFollowDataFollowItemsModel> *followItems;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHFollowModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHFollowDataModel *data ;

- (FHHouseNeighborModel *)toHouseNeighborModel;

- (FHSearchHouseModel *)toHouseSecondHandModel;

- (FHNewHouseListResponseModel *)toHouseNewModel;

- (FHHouseRentModel *)toHouseRentModel;

@end


NS_ASSUME_NONNULL_END
//END OF HEADER
