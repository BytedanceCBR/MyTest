//
//  RNData.m
//  
//
//  Created by Chen Hong on 16/7/25.
//
//

#import "RNData.h"

@implementation RNData

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"uniqueID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties] arrayByAddingObjectsFromArray:@[
                       @"filterWords",
                       @"actionList",
                       @"rawData",
                       @"moduleName",
                       @"typeId",
                       @"typeName",
                       @"data",
                       @"dataUrl",
                       @"refreshInterval",
                       @"dataContent",
                       @"lastUpdateTime",
                       ]];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"actionList":@"action_list",
                       @"filterWords":@"filter_words",
                       @"rawData":@"raw_data",
                       };
    }
    return properties;
}

- (void)updateWithDataContentObj:(NSDictionary *)content {
    if (![content isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    self.dataContent = content;
    self.lastUpdateTime = [NSDate date];
    
    [self save];
}

- (void)updateWithDictionary:(NSDictionary *)dataDict {
    [super updateWithDictionary:dataDict];

    NSDictionary *rawData = [dataDict tt_dictionaryValueForKey:@"raw_data"];
    // 增加ExploreOrderedDataCellTypeDynamicRN类型之前，`data`属性为解析，增加类型后，`data`属性在`raw_data`数据结构中
    self.rawData = rawData;
    self.data = [rawData tt_dictionaryValueForKey:@"data"];
    self.moduleName = [rawData tt_stringValueForKey:@"module_name"];
    self.typeId = [rawData tt_objectForKey:@"type_id"];
    self.typeName = [rawData tt_objectForKey:@"type_name"];
    self.dataUrl = [rawData tt_stringValueForKey:@"data_url"];
    self.refreshInterval = [rawData tt_objectForKey:@"refresh_interval"];
    
//    self.filterWords = [dataDict tt_arrayValueForKey:@"filter_words"];
//    
//    self.actionList = [dataDict tt_arrayValueForKey:@"action_list"];
}

@end
