//
//  TTHistoryEntryGroup.m
//  Article
//
//  Created by fengyadong on 16/11/16.
//
//

#import "TTHistoryEntryGroup.h"
#import "ExploreOrderedData+TTBusiness.h"

@implementation TTHistoryEntryGroup

- (NSString *)description {
    return [NSString stringWithFormat:@"%lld", self.dateIdentifier];
}

+ (NSString *)dbName {
    return @"tt_history_group";
}

+ (NSString *)primaryKey {
    return @"primaryKey";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"dayIdentifier",
                       @"headerText",
                       @"totalCount",
                       @"dataList",
                       ];
    }
    return properties;
}

- (BOOL)isEqual:(id)object {
    TTHistoryEntryGroup *other = (TTHistoryEntryGroup *)object;
    
    if (self.dateIdentifier <= 0 || other.dateIdentifier <= 0 || self.dateIdentifier != other.dateIdentifier) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%lld",self.dateIdentifier] hash];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    TTHistoryEntryGroup *group = [[TTHistoryEntryGroup alloc] init];
    
    NSString *primaryKey = [NSString stringWithFormat:@"%lld", [dictionary tt_longlongValueForKey:@"date"]];
    group.primaryKey = primaryKey;
    group.dateIdentifier = [dictionary tt_longlongValueForKey:@"date"];
    group.headerText = [dictionary tt_stringValueForKey:@"head_text"];
    group.totalCount = [dictionary tt_longValueForKey:@"count"];
    NSArray *orderedDataDictArray = [dictionary tt_arrayValueForKey:@"data"];
    NSArray *orderedDataModelArray = [ExploreOrderedData insertObjectsWithDataArray:orderedDataDictArray];
    group.orderedDataList = orderedDataModelArray;
    group.isDeleting = NO;
    group.isEntireDeleting = NO;
    group.excludeItems = [NSMutableSet set];
    group.deletingItems = [NSMutableSet set];
    
    return group;
}

+ (NSArray *)insertObjectsWithDataArray:(NSArray *)dataArray {
    NSMutableArray *results = [NSMutableArray array];
    [dataArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        TTEntityBase *entity = [self objectWithDictionary:dict];
//暂时不持久化
//        [entity save];
        [results addObject:entity];
    }];
    return [results copy];
}

- (void)save {
    [super save];
    for(ExploreOrderedData *data in self.orderedDataList) {
        [data save];
    }
}

@end
