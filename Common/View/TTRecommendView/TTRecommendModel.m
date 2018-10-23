//
//  TTRecommendModel.m
//  Article
//
//  Created by zhaoqin on 18/12/2016.
//
//

#import "TTRecommendModel.h"

@implementation TTRecommendModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"user_id": @"userID",
                                                       @"is_following": @"isFollowing",
                                                       @"is_followed": @"isFollowed",
                                                       @"user_auth_info": @"userAuthInfo",
                                                       @"reason_description": @"reasonString",
                                                       @"name": @"nameString",
                                                       @"avatar_url": @"avatarUrlString",
                                                       }];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    if ([propertyName isEqualToString:@"isDisplay"]) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithUserInfoDict:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        if (SSIsEmptyDictionary(dict)) {
            return nil;
        }
        _userID = [dict tt_stringValueForKey:@"user_id"];
        _avatarUrlString = [dict tt_stringValueForKey:@"avatar_url"];
        _nameString = [dict tt_stringValueForKey:@"name"];
        _reasonString = [dict tt_stringValueForKey:@"recommend_reason"];
        _isFollowing = [dict tt_boolValueForKey:@"follow"];
        _userAuthInfo = [dict tt_stringValueForKey:@"user_auth_info"];
        _reason = @([dict tt_longValueForKey:@"recommend_type"]);
        _isFollowed = NO;
    }
    return self;
}
@end
