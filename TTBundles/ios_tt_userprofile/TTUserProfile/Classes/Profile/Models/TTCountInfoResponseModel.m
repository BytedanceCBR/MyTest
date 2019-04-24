//
//  TTCountInfoResponseModel.m
//  Article
//
//  Created by fengyadong on 16/12/21.
//
//

#import "TTCountInfoResponseModel.h"

@implementation TTCountInfoResponseModel

@end

@implementation TTCountInfoResponseDataModel : JSONModel

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"show_info" : @"showInfo",
                           @"dongtai_count"    : @"momentItem",
                           @"followings_count"      : @"followingsItem",
                           @"followers_count"   : @"followerItem",
                           @"mplatform_followers_count"   : @"multiplatformFollowerItem",
                           @"visit_count_recent"      : @"visitorItem"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    self = [super initWithDictionary:dict error:err];
    
    if (self) {
        NSArray * array = dict[@"followers_detail"];
        self.followerDetail = nil;
        NSError * error = nil;
        self.followerDetail = [TTFollowerDetailModel arrayOfModelsFromDictionaries:array error:&error];
    }
    return self;
}

@end

@implementation TTCountInfoItemModel : JSONModel

@end

@implementation TTFollowerDetailModel : JSONModel

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"apple_id" : @"appID",
                           @"download_url"    : @"downloadURL",
                           @"fans_count"      : @"fansCount",
                           @"icon" : @"iconURL",
                           @"name"    : @"appName",
                           @"app_name"    : @"trackName",
                           @"open_url"   : @"openURL",
                           @"package_name"      : @"packageName"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end
