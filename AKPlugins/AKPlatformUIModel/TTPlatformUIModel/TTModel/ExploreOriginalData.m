//
//  ExploreOriginalData.m
//  Article
//
//  Created by Yu Tianhang on 13-2-25.
//
//

#import "ExploreOriginalData.h"


@implementation ExploreOriginalData

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"userBury",
                       @"userDigg",
                       @"userRepined",
                       @"userRepinTime",
                       
                       @"buryCount",
                       @"commentCount",
                       @"diggCount",
                       @"groupFlags",
                       @"hasRead",
                       @"notInterested",
                       @"repinCount",
                       @"shareURL",
                       @"infoDesc",
                       
                       @"hasShown",
                       @"showAddForum",
                       @"likeCount",
                       @"userLike",
                       @"likeDesc",
                       @"requestTime",
                       ];
    };
    return properties;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    ExploreOriginalData *other = (ExploreOriginalData *)object;
    
    if (self.uniqueID != other.uniqueID) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return (NSUInteger)(self.uniqueID % NSUIntegerMax);
}


+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"buryCount":@"bury_count",
                       @"commentCount":@"comment_count",
                       @"diggCount":@"digg_count",
                       @"groupFlags":@"group_flags",
                       @"hasRead":@"has_read",
                       @"infoDesc":@"info_desc",
                       @"likeCount":@"like_count",
                       @"likeDesc":@"like_desc",
                       @"notInterested":@"not_interested",
                       @"repinCount":@"repin_count",
                       @"shareURL":@"share_url",
                       @"userBury":@"user_bury",
                       @"userDigg":@"user_digg",
                       @"userLike":@"user_like",
                       @"userRepined":@"user_repin",
                       @"userRepinTime":@"user_repin_time",
                       };
    }
    return properties;
}

@end
