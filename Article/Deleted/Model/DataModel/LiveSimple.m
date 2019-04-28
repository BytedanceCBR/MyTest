//
//  LiveSimple.m
//  Article
//
//  Created by 王双华 on 16/9/19.
//
//

#import "LiveSimple.h"
#import "Live.h"

@implementation LiveSimple

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"simpleId";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"covers",
                       @"simpleId",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{@"simpleId" : @"id"};
    }
    return properties;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    LiveSimple *other = (LiveSimple *)object;
    
    if (self.simpleId != other.simpleId) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return (NSUInteger)(self.simpleId % NSUIntegerMax);
}

@end
