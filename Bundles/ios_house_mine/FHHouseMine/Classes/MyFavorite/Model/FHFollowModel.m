//GENERATED CODE , DON'T EDIT
#import "FHFollowModel.h"
@implementation FHFollowDataFollowItemsImagesModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"urlList": @"url_list",
  };
  return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
     return dict[keyName]?:keyName;
  }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFollowDataFollowItemsTagsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"backgroundColor": @"background_color",
    @"textColor": @"text_color",
  };
  return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
     return dict[keyName]?:keyName;
  }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFollowDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"hasMore": @"has_more",
    @"totalCount": @"total_count",
    @"followItems": @"follow_items",
    @"searchId": @"search_id",
  };
  return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
     return dict[keyName]?:keyName;
  }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHFollowModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (FHHouseNeighborModel *)toHouseNeighborModel {
    FHHouseNeighborModel *model = [[FHHouseNeighborModel alloc] init];
    model.status = self.status;
    model.message = self.message;
    
    FHFollowDataModel *dataModel = self.data;
    FHHouseNeighborDataModel *houseDataModel = [[FHHouseNeighborDataModel alloc] init];
    model.data = houseDataModel;
    
    houseDataModel.hasMore = dataModel.hasMore;
    houseDataModel.total = dataModel.totalCount;
    houseDataModel.searchId = dataModel.searchId;
    
    NSArray *followItemsModelArray = dataModel.followItems;
    NSMutableArray<FHHouseNeighborDataItemsModel> *houseItemsModelArray = [NSMutableArray<FHHouseNeighborDataItemsModel> array];
    houseDataModel.items = houseItemsModelArray;
    for (FHFollowDataFollowItemsModel *followItemsModel in followItemsModelArray) {
        [houseItemsModelArray addObject:[followItemsModel toHouseNeighborModel]];
    }
    
    return model;
}

- (FHSearchHouseModel *)toHouseSecondHandModel {
    FHSearchHouseModel *model = [[FHSearchHouseModel alloc] init];
    model.status = self.status;
    model.message = self.message;
    
    FHFollowDataModel *dataModel = self.data;
    FHSearchHouseDataModel *houseDataModel = [[FHSearchHouseDataModel alloc] init];
    model.data = houseDataModel;
    
    houseDataModel.hasMore = dataModel.hasMore;
    houseDataModel.total = dataModel.totalCount;
    houseDataModel.searchId = dataModel.searchId;
    
    NSArray *followItemsModelArray = dataModel.followItems;
    NSMutableArray<FHSearchHouseDataItemsModel> *houseItemsModelArray = [NSMutableArray<FHSearchHouseDataItemsModel> array];
    houseDataModel.items = houseItemsModelArray;
    for (FHFollowDataFollowItemsModel *followItemsModel in followItemsModelArray) {
        [houseItemsModelArray addObject:[followItemsModel toHouseSecondHandModel]];
    }
    
    return model;
}

- (FHNewHouseListResponseModel *)toHouseNewModel {
    FHNewHouseListResponseModel *model = [[FHNewHouseListResponseModel alloc] init];
    model.status = self.status;
    model.message = self.message;
    
    FHFollowDataModel *dataModel = self.data;
    FHNewHouseListDataModel *houseDataModel = [[FHNewHouseListDataModel alloc] init];
    model.data = houseDataModel;
    
    houseDataModel.hasMore = dataModel.hasMore;
    houseDataModel.total = dataModel.totalCount;
    houseDataModel.searchId = dataModel.searchId;
    
    NSArray *followItemsModelArray = dataModel.followItems;
    NSMutableArray<FHNewHouseItemModel> *houseItemsModelArray = [NSMutableArray<FHNewHouseItemModel> array];
    houseDataModel.items = houseItemsModelArray;
    for (FHFollowDataFollowItemsModel *followItemsModel in followItemsModelArray) {
        [houseItemsModelArray addObject:[followItemsModel toHouseNewModel]];
    }
    
    return model;
}

- (FHHouseRentModel *)toHouseRentModel {
    FHHouseRentModel *model = [[FHHouseRentModel alloc] init];
    model.status = self.status;
    model.message = self.message;
    
    FHFollowDataModel *dataModel = self.data;
    FHHouseRentDataModel *houseDataModel = [[FHHouseRentDataModel alloc] init];
    model.data = houseDataModel;
    
    houseDataModel.hasMore = dataModel.hasMore;
    houseDataModel.total = dataModel.totalCount;
    houseDataModel.searchId = dataModel.searchId;
    
    NSArray *followItemsModelArray = dataModel.followItems;
    NSMutableArray<FHHouseRentDataItemsModel> *houseItemsModelArray = [NSMutableArray<FHHouseRentDataItemsModel> array];
    houseDataModel.items = houseItemsModelArray;
    for (FHFollowDataFollowItemsModel *followItemsModel in followItemsModelArray) {
        [houseItemsModelArray addObject:[followItemsModel toHouseRentModel]];
    }
    
    return model;
}

@end

@implementation FHFollowDataFollowItemsModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"followId": @"follow_id",
    @"logPb": @"log_pb",
    @"searchId": @"search_id",
    @"pricePerSqm": @"price_per_sqm",
    @"imprId": @"impr_id",
    @"houseType": @"house_type",
    @"groupId": @"group_id",
    @"salesInfo": @"sales_info",
    @"desc": @"description",
  };
  return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
     return dict[keyName]?:keyName;
  }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (FHHouseNeighborDataItemsModel *)toHouseNeighborModel {
    FHHouseNeighborDataItemsModel *houseItemsModel = [[FHHouseNeighborDataItemsModel alloc] init];
    houseItemsModel.logPb = self.logPb;
    houseItemsModel.id = self.followId;
    houseItemsModel.searchId = self.searchId;
    houseItemsModel.houseType = self.houseType;
    houseItemsModel.imprId = self.imprId;
    houseItemsModel.displayTitle = self.title;
    houseItemsModel.displaySubtitle = self.desc;
    houseItemsModel.displayPrice = self.pricePerSqm;
    houseItemsModel.displayPricePerSqm = self.pricePerSqm;
    houseItemsModel.displayStatsInfo = self.salesInfo;
    houseItemsModel.images = self.images;
    
    return houseItemsModel;
}

- (FHSearchHouseDataItemsModel *)toHouseSecondHandModel {
    FHSearchHouseDataItemsModel *houseItemsModel = [[FHSearchHouseDataItemsModel alloc] init];
    houseItemsModel.logPb = self.logPb;
    houseItemsModel.hid = self.followId;
    houseItemsModel.searchId = self.searchId;
    houseItemsModel.houseType = self.houseType;
    houseItemsModel.imprId = self.imprId;
    houseItemsModel.displayTitle = self.title;
    houseItemsModel.displaySubtitle = self.desc;
    houseItemsModel.displayPrice = self.price;
    houseItemsModel.displayPricePerSqm = self.pricePerSqm;
//    houseItemsModel.displayStatsInfo = self.salesInfo;
    houseItemsModel.houseImage = self.images;
    houseItemsModel.tags = self.tags;
    
    return houseItemsModel;
}

- (FHNewHouseItemModel *)toHouseNewModel {
    FHNewHouseItemModel *houseItemsModel = [[FHNewHouseItemModel alloc] init];
    houseItemsModel.logPb = self.logPb;
    houseItemsModel.houseId = self.followId;
    houseItemsModel.searchId = self.searchId;
    houseItemsModel.houseType = self.houseType;
    houseItemsModel.imprId = self.imprId;
    houseItemsModel.displayTitle = self.title;
    houseItemsModel.displayDescription = self.desc;
    houseItemsModel.displayPricePerSqm = self.pricePerSqm;
    houseItemsModel.images = self.images;
    houseItemsModel.tags = self.tags;
    
    return houseItemsModel;
}

- (FHHouseRentDataItemsModel *)toHouseRentModel {
    FHHouseRentDataItemsModel *houseItemsModel = [[FHHouseRentDataItemsModel alloc] init];
    houseItemsModel.logPb = self.logPb;
    houseItemsModel.id = self.followId;
    houseItemsModel.searchId = self.searchId;
    houseItemsModel.houseType = self.houseType;
    houseItemsModel.imprId = self.imprId;
    houseItemsModel.title = self.title;
    houseItemsModel.subtitle = self.desc;
    houseItemsModel.pricing = self.price;
    houseItemsModel.houseImage = self.images;
    houseItemsModel.tags = self.tags;
    
    return houseItemsModel;
}

@end

