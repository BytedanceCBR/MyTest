//
//  TTUserData.m
//  Article
//
//  Created by 杨心雨 on 2017/1/17.
//
//

#import "TTUserData.h"

@implementation TTUserData

+ (NSInteger)dbVersion {
    return 2;
}

+ (NSString *)dbName {
    return @"tt_user";
}

+ (NSString *)primaryKey {
    return @"userId";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                      @"userId",
                      @"name",
                      @"avatarUrl",
                      @"screenName",
                      @"isBlocking",
                      @"userAuthInfo",
                      @"userDecoration"
                      ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"avatarUrl":@"avatar_url",
                       @"isBlocking":@"is_blocking",
                       @"name":@"name",
                       @"screenName":@"screen_name",
                       @"userId":@"user_id",
                       @"userAuthInfo":@"user_auth_info",
                       @"userDecoration":@"user_decoration"
                       };
    }
    return properties;
}

- (BOOL)isEqual:(id)object {
    if (self == object) { return YES; }
    
    if (!self.userId) { return NO; }
    
    if (![object isKindOfClass:[self class]]) { return NO; }
    
    TTUserData *userData = (TTUserData *)object;
    
    if ([userData.userId isEqualToString:self.userId]) {
        return YES;
    }
    return NO;
}

@end

@implementation TTUserDataResponse

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"user_id"    : @"userId",
                                                       @"name"       : @"name",
                                                       @"avatar_url" : @"avatarUrl",
                                                       @"screen_name" : @"screenName",
                                                       @"is_blocking" : @"isBlocking",
                                                       @"user_auth_info":@"userAuthInfo",
                                                       @"user_decoration":@"userDecoration"
                                                       }];
}

- (TTUserData *)transformToUserData {
    TTUserData *userData = [TTUserData objectForPrimaryKey:self.userId];
    if (userData == nil) {
        userData = [[TTUserData alloc] init];
    }
    userData.userId = self.userId;
    userData.name = self.name;
    userData.screenName = self.screenName;
    userData.avatarUrl = self.avatarUrl;
    if (self.isBlocking) {
        userData.isBlocking = self.isBlocking;
    }
    if (self.userAuthInfo) {
        userData.userAuthInfo = self.userAuthInfo;
    }
    if (self.userDecoration) {
        userData.userDecoration = self.userDecoration;
    }
    return userData;
}

@end

@implementation TTUsersDataResponse

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"data.user_infos"    : @"userInfos",
                                                       @"message"       : @"message",
                                                       }];
}

@end
