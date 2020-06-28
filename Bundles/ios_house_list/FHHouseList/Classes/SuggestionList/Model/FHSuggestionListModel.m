//
//  FHSuggestionListModel.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListModel.h"

//for implementation
@implementation  FHSuggestionClearHistoryResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end




//for implementation
@implementation  FHSuggestionResponseDataInfoModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"areaId": @"area_id",
                           @"neighborhoodName": @"neighborhood_name",
                           @"cityId": @"city_id",
                           @"recallType": @"recall_type",
                           @"areaName": @"area_name",
                           @"oldName": @"old_name",
                           @"userOriginEnter": @"user_origin_enter",
                           @"districtId": @"district_id",
                           @"recallId": @"recall_id",
                           @"isCut": @"is_cut",
                           @"districtName": @"district_name",
                           @"houseType": @"house_type",
                           @"neigbordId": @"neigbord_id",
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


@implementation  FHSuggestionResponseDataLogPbModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"imprId": @"impr_id",
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


@implementation  FHSuggestionResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHSuggestionResponseDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"logPb": @"log_pb",
                           @"openUrl": @"open_url",
                           @"houseType": @"house_type",
                           @"oldName":@"old_name",
                           @"recallType":@"recall_type",
                           @"countDisplay":@"count_display",
                           @"cardType": @"card_type",
                           @"buttonText": @"button_text",
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




//for implementation
@implementation  FHSuggestionSearchHistoryResponseDataModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHSuggestionSearchHistoryResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end


@implementation  FHSuggestionSearchHistoryResponseDataDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
                           @"openUrl": @"open_url",
                           @"listText": @"list_text",
                           @"userOriginEnter": @"user_origin_enter",
                           @"historyId": @"history_id",
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



//for implementation
@implementation FHGuessYouWantResponseDataDataRecommendReasonModel

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

@implementation FHGuessYouWantResponseDataDataRecommendTypeModel
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

@implementation FHGuessYouWantResponseDataDataModel

+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"logPb": @"log_pb",
    @"openUrl": @"open_url",
    @"displayPrice": @"display_price",
    @"recommendType": @"recommend_type",
    @"imageUrl": @"image_url",
    @"guessSearchId": @"guess_search_id",
    @"houseType": @"house_type",
    @"guessSearchType": @"guess_search_type",
    @"recommendReason": @"recommend_reason",
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

@implementation FHGuessYouWantResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation FHGuessYouWantResponseDataModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"extraInfo": @"extra_info",
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

@implementation FHGuessYouWantExtraInfoModel

+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
        @"backgroundColor": @"background_color",
        @"textColor": @"text_color",
        @"openUrl": @"open_url",
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
