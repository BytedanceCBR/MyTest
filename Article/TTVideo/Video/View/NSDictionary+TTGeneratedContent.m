//
//  NSDictionary+TTGeneratedContent.m
//  Article
//
//  Created by songxiangwu on 2016/10/24.
//
//

#import "NSDictionary+TTGeneratedContent.h"

static NSString *const kUserId = @"user_id";
static NSString *const kMediaId = @"media_id";
static NSString *const kAvatarURL = @"avatar_url";
static NSString *const kName = @"name";
static NSString *const kFansCount = @"fans_count";
static NSString *const kDescription = @"description";
static NSString *const kSubcribed = @"subcribed";
static NSString *const kFollow = @"follow";
static NSString *const kUserAuthInfo = @"user_auth_info";


@implementation NSDictionary (TTGeneratedContent)

- (TTGeneratedContentType)ttgc_contentType {
    if (!isEmptyString([self tt_stringValueForKey:kUserId])) {
        return TTGeneratedContentTypeUGC;
    } else {
        return TTGeneratedContentTypePGC;
    }
}

- (NSString *)ttgc_mediaID
{
    return [self tt_stringValueForKey:kMediaId];
}

- (NSString *)ttgc_contentID {
    if (!isEmptyString([self tt_stringValueForKey:kUserId])) {
        return [self tt_stringValueForKey:kUserId];
    } else {
        return [self tt_stringValueForKey:kMediaId];
    }
}

- (NSString *)ttgc_contentName {
    return [self stringValueForKey:kName defaultValue:@""];
}

- (long long )ttgc_fansCount {
    return [self longValueForKey:kFansCount defaultValue:0];
}

- (NSString *)ttgc_contentAvatarURL {
    return [self stringValueForKey:kAvatarURL defaultValue:@""];
}

- (NSString *)ttgc_contentDescription {
    return [self stringValueForKey:kDescription defaultValue:@""];
}

- (BOOL)ttgc_isSubCribed {
    if ([[self allKeys] containsObject:kFollow]) {
        return [self tt_boolValueForKey:kFollow];
    }else if ([[self allKeys] containsObject:kSubcribed]){
        return [self tt_boolValueForKey:kSubcribed];
    }
    return NO;
}

- (NSString *)ttgc_userAuthInfo {
    return [self tt_stringValueForKey:kUserAuthInfo];
}

@end
