//
//  TTHotNewsData.m
//  Article
//
//  Created by Sunhaiyuan on 2018/1/22.
//

#import "TTHotNewsData.h"
#import "ExploreListIItemDefine.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTEntityBase.h"
#import "ExploreOrderedData.h"


@implementation TTHotNewsData {
    ExploreOrderedData *_cachedOrderedData;
}
+ (NSString *)dbName
{
    return @"tt_news";
}

+ (NSString *)primaryKey
{
    return @"uniqueID";
}

+ (NSArray *)persistentProperties
{
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"groupId",
                       @"showMoreDesc",
                       @"showMoreSchemaUrl",
                       @"aggrType",
                       @"behotTime",
                       @"rawData",
                       @"label",
                       @"showDislike",
                       @"commentCount"
                       ];
    }
    
    return properties;
}

+ (NSDictionary *)keyMapping
{
    return @{};
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc
{
    
}

- (ExploreOrderedData *)internalData {
    
    if (_cachedOrderedData) {
        return _cachedOrderedData;
    }
    
    if (!SSIsEmptyDictionary(self.rawData)) {
        ExploreOrderedData *orderedData = [ExploreOrderedData objectWithDictionary:self.rawData];
        orderedData.article.uniqueID = self.uniqueID;
        return orderedData;
    }
    return nil;
}

-(void)updateWithDictionary:(NSDictionary *)dictionary
{
    [super updateWithDictionary:dictionary];
    
    if ([dictionary objectForKey:@"id"]) {
        self.groupId = [dictionary tt_intValueForKey:@"id"];
    }
    
    if ([dictionary objectForKey:@"behot_time"]) {
        self.behotTime = [dictionary tt_longValueForKey:@"behot_time"];
    }

    NSDictionary *rawData = [dictionary tt_dictionaryValueForKey:@"raw_data"];
    
    if (rawData != nil && [rawData isKindOfClass:[NSDictionary class]]) {
        if ([rawData objectForKey:@"show_more"]) {
            NSDictionary *showMore_dict = [rawData tt_dictionaryValueForKey:@"show_more"];
            self.showMoreDesc = [showMore_dict tt_stringValueForKey:@"desc"];
            self.showMoreSchemaUrl = [showMore_dict tt_stringValueForKey:@"schema"];
        }
        
        if ([rawData objectForKey:@"aggr_type"]) {
            self.aggrType = [rawData  tt_longValueForKey:@"aggr_type"];
        }
        
        if ([rawData objectForKey:@"label"]) {
            self.label = [rawData  tt_stringValueForKey:@"label"];
        }
        
        if ([rawData objectForKey:@"comment_count"]) {
            self.commentCount = [rawData  tt_intValueForKey:@"comment_count"];
        }
        
        if ([rawData objectForKey:@"show_dislike"]) {
            self.showDislike = [rawData  tt_boolValueForKey:@"show_dislike"];
        }
        
        self.rawData = rawData;
    }

    if ([dictionary objectForKey:@"log_pb"]) {
        self.internalData.logPb = [dictionary tt_dictionaryValueForKey:@"log_pb"];
    }
}


@end

