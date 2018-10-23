//
//  TTCategoryAddToFirstPageData.m
//  Article
//
//  Created by xuzichao on 16/9/7.
//
//


#import "TTCategoryAddToFirstPageData.h"
#import "NSDictionary+TTAdditions.h"

@implementation TTCategoryAddToFirstActionData

+(JSONKeyMapper*)keyMapper
{
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}
@end

@implementation TTCategoryAddToFirstPageData

#pragma mark  --GYModelObject

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    
    TTCategoryAddToFirstPageData *object = [super objectWithDictionary:dictionary];

    object.uniqueID = [dictionary longlongValueForKey:@"id" defaultValue:123456789];
    
    return object;
}


+ (NSArray *)persistentProperties {
    
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties]
                      arrayByAddingObjectsFromArray:@[
                                                      @"behotTime",
                                                      @"cellType",
                                                      @"cursor",
                                                      @"cellId",
                                                      @"text",
                                                      @"action",
                                                      @"buttonText",
                                                      @"iconUrl",
                                                      @"openUrl",
                                                      @"jumpType"]];
    }
    return properties;
}

+ (GYCacheLevel)cacheLevel {
    return GYCacheLevelResident;
}


#pragma mark -- TTEntityBase

+ (NSDictionary *)keyMapping
{
    
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"action":@"action",
                                         @"behotTime":@"behot_time",
                                         @"buttonText":@"button_text",
                                         @"cellType":@"cell_type",
                                         @"cursor":@"cursor",
                                         @"iconUrl":@"icon_url",
                                         @"cellId":@"id",
                                         @"openUrl":@"open_url",
                                         @"text":@"text",
                                         @"jumpType":@"type",
                                         }
         ];
        properties = [dict copy];
    }
    return properties;
}

@end
