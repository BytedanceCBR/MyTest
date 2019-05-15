//
//  TTXiguaLiveCardHorizontal.m
//  Article
//
//  Created by lipeilun on 2017/11/30.
//

#import "TTXiguaLiveCardHorizontal.h"

@interface TTXiguaLiveCardHorizontal()

@end

@implementation TTXiguaLiveCardHorizontal

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[@"dataArray"]];
    }

    return properties;
}

+ (NSDictionary *)keyMapping {
    return @{};
}

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    if (!self.managedObjectContext) return;

    [super updateWithDictionary:dataDict];
    NSDictionary *rawData = [dataDict tt_dictionaryValueForKey:@"raw_data"];
    if (rawData != nil) {
        self.dataArray = [rawData tt_arrayValueForKey:@"data"];
    }
}


- (NSArray<TTXiguaLiveModel *> *)modelArray {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:2];
    for (NSDictionary *dict in self.dataArray) {
        TTXiguaLiveModel *model = [[TTXiguaLiveModel alloc] initWithDictionary:dict];
        [result addObject:model];
    }
    return result.copy;
}

@end



















