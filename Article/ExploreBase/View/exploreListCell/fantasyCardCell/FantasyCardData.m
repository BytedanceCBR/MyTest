//
//  FantasyCardData.m
//  Article
//
//  Created by chenren on 1/02/18.
//
//

#import "FantasyCardData.h"

@implementation FantasyCardData

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
            @"imageURL",
            @"startTime",
            @"title",
            @"content",
            @"bigWords",
            @"bigWordsTail",
            @"buttonText",
            @"jumpURL"
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
    if (rawData != nil && [rawData isKindOfClass:[NSDictionary class]]) {
        self.imageURL = [rawData tt_stringValueForKey:@"image_url"];
        self.startTime = [rawData tt_longlongValueForKey:@"start_time"];
        self.title = [rawData tt_stringValueForKey:@"title"];
        self.content = [rawData tt_stringValueForKey:@"desc"];
        self.bigWords = [rawData tt_stringValueForKey:@"content_prefix"];
        self.bigWordsTail = [rawData tt_stringValueForKey:@"content_suffix"];
        self.buttonText = [rawData tt_stringValueForKey:@"button_text"];
        self.jumpURL = [rawData tt_stringValueForKey:@"schema"];
    }
}

@end
