//
//  SurveyPairData.m
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "SurveyPairData.h"

@implementation Article (GroupID)

- (void)setGroupID:(NSString *)groupID
{
    objc_setAssociatedObject(self, @selector(groupID), groupID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)groupID
{
    return (NSString *)objc_getAssociatedObject(self, @selector(groupID));
}

@end

@implementation SurveyPairData

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
        NSArray *acticleArray = [rawData tt_arrayValueForKey:@"data"];
        if ([acticleArray isKindOfClass:[NSArray class]] && acticleArray.count > 1) {
            NSDictionary *dic1 = [acticleArray objectAtIndex:0];
            NSDictionary *dic2 = [acticleArray objectAtIndex:1];
            self.article1 = [Article objectWithDictionary:dic1];
            self.article1.groupID = dic1[@"group_id"];
            self.article2 = [Article objectWithDictionary:dic2];
            self.article2.groupID = dic2[@"group_id"];
        }
    }
}

@end
