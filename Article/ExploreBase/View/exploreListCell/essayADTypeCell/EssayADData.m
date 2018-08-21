//
//  EssayADData.m
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "EssayADData.h"

@implementation EssayADData

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
            @"title",
            @"extTitle",
            @"URL",
            @"label",
            @"appID"
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
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (void)dealloc
{
}

- (void)updateWithDictionary:(NSDictionary *)dataDict
{
    [super updateWithDictionary:dataDict];

    NSDictionary *rawData = [dataDict tt_dictionaryValueForKey:@"raw_data"];
    if (rawData != nil) {
        self.title = [rawData tt_stringValueForKey:@"title"];
        self.extTitle = [rawData tt_stringValueForKey:@"abstract"];
        self.URL = [[rawData tt_dictionaryValueForKey:@"package"] tt_stringValueForKey:@"app_store_url"];
        self.label = [rawData tt_stringValueForKey:@"label"];
        self.appID = [[rawData tt_dictionaryValueForKey:@"package"] tt_stringValueForKey:@"app_id"];
    }
}

@end
