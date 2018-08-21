//
//  TTPersonalHomeUserInfoResponseModel.m
//  Article
//
//  Created by wangdi on 2017/3/20.
//
//

#import "TTPersonalHomeUserInfoResponseModel.h"

@implementation TTPersonalHomeUserInfoRequestModel

- (instancetype)init
{
    if(self = [super init]) {
        self._host = [CommonURLSetting baseURL];
        self._uri = @"/user/profile/homepage/v6/";
        self._method = @"GET";
        self._response = NSStringFromClass([TTPersonalHomeUserInfoResponseModel class]);
        self.refer = @"default";
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    if(!isEmptyString(self.user_id)) {
        dict[@"user_id"] = self.user_id;
    }
    if(!isEmptyString(self.media_id)) {
        dict[@"media_id"] = self.media_id;
    }
    
    if(!isEmptyString(self.refer)) {
        dict[@"refer"] = self.refer;
    }
    NSString *followButtonColorSetting = [SSCommonLogic followButtonColorStringForWap];

    if (followButtonColorSetting) {
        dict[@"followbtn_template"] = followButtonColorSetting;
    }

    return dict;
}

@end

@implementation TTPersonalHomeUserInfoDataResponseModel

+(JSONKeyMapper*)keyMapper
{
    TTPersonalHomeUserInfoDataResponseModel *model;
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"description" : @"desc",
                                                       @"mplatform_followers_count" : @keypath(model, multiplePlatformFollowersCount),
                                                       @"followers_detail" : @keypath(model, platformFollowersInfoArr),
                                                       }];
}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTPersonalHomeUserInfoExtraDataResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTPersonalHomeUserInfoResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTPersonalHomeUserInfoDataItemResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTPersonalHomeUserInfoDataBottomItemResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTPersonalHomeStarUserDataItemResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTPersonalHomeUserDataLiveDataItemResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTPersonalHomeLiveDataLiveInfoItemResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTPersonalHomeLiveInfoItemStreamUrlResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
