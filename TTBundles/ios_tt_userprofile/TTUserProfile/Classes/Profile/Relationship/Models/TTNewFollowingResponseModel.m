//
//  TTNewFollingResponseModel.m
//  Article
//
//  Created by lizhuoli on 17/1/8.
//
//

#import "TTNewFollowingResponseModel.h"

#define IsEqualString(x, y) ((!x && !y) || (x && [y isEqualToString:x]))

@implementation TTFollowingMergeResponseModel

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"description": @"userDescription",
                                                       @"icon": @"avatarURLString"}];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[TTFollowingMergeResponseModel class]]) {
        return NO;
    }
    
    TTFollowingMergeResponseModel *other = (TTFollowingMergeResponseModel *)object;
    BOOL equal = IsEqualString(self.name, other.name)
    && IsEqualString(self.url, other.url)
    && IsEqualString(self.type, other.type)
    && IsEqualString(self.avatarURLString, other.avatarURLString);
    
    return equal;
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.name hash];
    result = prime * result + [self.url hash];
    result = prime * result + [self.type hash];
    result = prime * result + [self.avatarURLString hash];
    
    return result;
}

@end

@implementation TTFollowingResponseModel

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"user_id": @"userID",
                                                       @"media_id": @"mediaID",
                                                       @"is_verified": @"isVerified",
                                                       @"user_auth_info": @"userAuthInfo",
                                                       @"icon": @"avatarURLString",
                                                       @"description": @"userDescription",
                                                       @"user_decoration":@"userDecoration",
                                                       @"tips_count": @"tipsCount",
                                                       @"mid_description": @"midDescription"}];
}

@end

@implementation TTNewFollowingResponseModel

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"has_more": @"hasMore",
                                                       @"merge_data": @"mergeData"}];
}

@end
