//
//  SurveyListData.m
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "SurveyListData.h"

@implementation SurveyListData

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
            @"title"
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
        self.evaluateID = [rawData tt_objectForKey:@"evaluate_id"];
        self.title = [rawData tt_stringValueForKey:@"title"];
        self.selectionInfos = [[NSMutableArray alloc] init];
        NSArray *infoArray = [rawData tt_arrayValueForKey:@"action_list"];
        for (NSDictionary *dic in infoArray) {
            SurveySelectionInfo *selectionInfo = [[SurveySelectionInfo alloc] init];
            selectionInfo.infoID = [dic tt_intValueForKey:@"id"];
            selectionInfo.label = [dic tt_stringValueForKey:@"label"];
            [self.selectionInfos addObject:selectionInfo];
        }
    }
}

@end


@implementation SurveySelectionInfo

@end
