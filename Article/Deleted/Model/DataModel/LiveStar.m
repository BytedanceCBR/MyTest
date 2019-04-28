//
//  LiveStar.m
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import "LiveStar.h"
#import "Live.h"

@implementation LiveStar

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"starId";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"covers",
                       @"icon",
                       @"name",
                       @"starId",
                       @"title",
                       @"url",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{@"starId" : @"id"};
    }
    return properties;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    LiveStar *other = (LiveStar *)object;
    
    if (self.starId != other.starId) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return (NSUInteger)(self.starId % NSUIntegerMax);
}

@end
