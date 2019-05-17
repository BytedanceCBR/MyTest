//
//  TTCategory.m
//  Article
//
//  Created by Chen Hong on 16/8/11.
//
//

#import "TTCategory.h"

@implementation TTCategory

+ (NSString *)dbName {
    return @"tt_news_category";
}

+ (NSString *)tableName {
    return @"Category";
}

+ (NSString *)primaryKey {
    return @"categoryID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"categoryID",
                       @"concernID",
                       @"name",
                       @"iconURL",
                       @"webURLStr",
                       @"tipNew",
                       @"listDataType",
                       @"subscribed",
                       @"orderIndex",
                       @"ttDeleted",
                       @"flags",
                       @"topCategoryType",
                       @"isPreFixedCategory",
                       @"shortVideoSubCategory",
                       ];
    };
    return properties;
}

+ (NSInteger)dbVersion {
    return 2;
}


//+ (NSDictionary *)defaultValues {
//    static NSDictionary *properties = nil;
//    if (!properties) {
//        properties = @{
//                       @"tipNew" : @(0),
//                       @"listDataType": @(0),
//                       @"subscribed": @(0),
//                       @"ttDeleted": @(0),
//                       @"flags": @(0),
//                       @"topCategoryType": @(0)
//                       };
//    }
//    return properties;
//
//}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    TTCategory *other = (TTCategory *)object;
    
    if ((self.categoryID || other.categoryID) &&
        ![self.categoryID isEqualToString:other.categoryID]) {
        return NO;
    }
    
    if ((self.shortVideoSubCategory != other.shortVideoSubCategory)) {
        return NO;
    }
    
//    if ((self.concernID || other.concernID) &&
//        ![self.concernID isEqualToString:other.concernID]) {
//        return NO;
//    }
    
    return YES;
}

- (NSUInteger)hash {
    return [self.categoryID hash];
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"categoryID":@"category",
                       @"concernID":@"concern_id",
                       @"flags":@"flags",
                       @"iconURL":@"icon_url",
                       @"name":@"name",
                       @"orderIndex":@"order_index",
                       @"subscribed":@"subscribed",
                       @"tipNew":@"tip_new",
                       @"topCategoryType":@"topCategoryType",
                       @"listDataType":@"type",
                       @"webURLStr":@"web_url",
                       @"shortVideoSubCategory":@"shortVideoSubCategory"
                       };

    }
    return properties;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setValue:self.categoryID forKey:@"category"];
    [dict setValue:self.concernID forKey:@"concern_id"];
    [dict setValue:self.name forKey:@"name"];
    [dict setValue:self.iconURL forKey:@"icon_url"];
    [dict setValue:self.webURLStr forKey:@"web_url"];
    [dict setValue:@(self.tipNew) forKey:@"tip_new"];
    [dict setValue:@(self.listDataType) forKey:@"type"];
    [dict setValue:@(self.subscribed) forKey:@"subscribed"];
    [dict setValue:@(self.flags) forKey:@"flags"];
    [dict setValue:@(self.orderIndex) forKey:@"order_index"];
    [dict setValue:@(self.topCategoryType) forKey:@"topCategoryType"];
    
    // Used in [ArticleCategoryManagerView applyOptimizedCategories]
    [dict setValue:@(self.subscribed) forKey:@"default_add"];
    
    [dict setValue:@(self.isPreFixedCategory) forKey:@"isPreFixedCategory"];
    [dict setValue:@(self.shortVideoSubCategory) forKey:@"shortVideoSubCategory"];
    
    return dict;
}

- (NSString * _Nullable)shortVideoUniqueID
{
    return [NSString stringWithFormat:@"%@%ld", self.categoryID, self.shortVideoSubCategory];
}
@end
