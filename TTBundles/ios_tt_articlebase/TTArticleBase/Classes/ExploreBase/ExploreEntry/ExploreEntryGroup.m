//
//  ExploreEntryGroup.m
//  Article
//
//  Created by Zhang Leonardo on 14-11-19.
//
//

#import "ExploreEntryGroup.h"
#import "ExploreEntry.h"

@implementation ExploreEntryGroup

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.name];
}

+ (NSString *)dbName {
    return @"tt_entry";
}

+ (NSString *)primaryKey {
    return @"name";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"entryGroupID",
                       @"name",
                       @"orderIndex",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{@"entryGroupID" : @"id"};
    }
    return properties;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    ExploreEntryGroup *other = (ExploreEntryGroup *)object;
    
    if ((self.name || other.name) && ![self.name isEqualToString:other.name]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return [self.name hash];
}

@end
