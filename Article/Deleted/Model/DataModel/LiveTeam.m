//
//  LiveTeam.m
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import "LiveTeam.h"
#import "LiveMatch.h"

@implementation LiveTeam

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"teamId";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"icon",
                       @"name",
                       @"teamId",
                       @"url",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{@"teamId" : @"id"};
    }
    return properties;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    LiveTeam *other = (LiveTeam *)object;
    
    if (self.teamId != other.teamId) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return (NSUInteger)(self.teamId % NSUIntegerMax);
}

@end
