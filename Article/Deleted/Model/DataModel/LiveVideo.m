//
//  LiveVideo.m
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import "LiveVideo.h"
#import "Live.h"

@implementation LiveVideo

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"videoId";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"covers",
                       @"videoId",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{@"videoId" : @"id"};
    }
    return properties;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    LiveVideo *other = (LiveVideo *)object;
    
    if (self.videoId != other.videoId) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return (NSUInteger)(self.videoId % NSUIntegerMax);
}

@end
