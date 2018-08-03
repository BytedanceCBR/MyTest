//
//  WenDaBaseData.m
//  Article
//
//  Created by xuzichao on 2016/12/6.
//
//

#import "WenDaBaseData.h"
#import "WDDataBaseManager.h"
#import "WDDefines.h"

@implementation WenDaBaseData

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if([object isKindOfClass:[WenDaBaseData class]])
    {
        WenDaBaseData *obj = (WenDaBaseData *)object;
        return (self.qid == obj.qid);
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [self.qid hash];
}

#pragma mark  --GYModelObject

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
    WenDaBaseData *object = [super objectWithDictionary:dictionary];
    if ([[dictionary objectForKey:@"question"] isKindOfClass:[NSDictionary class]]) {
        object.question = [WDQuestionEntity objectWithDictionary:[dictionary objectForKey:@"question"]];
        object.question.dataBaseType = WDDataBasePageType_Category;
    }
    if ([[dictionary objectForKey:@"answer"] isKindOfClass:[NSDictionary class]]){
        object.answer = [WDAnswerEntity objectWithDictionary:[dictionary objectForKey:@"answer"]];
    }
    object.requestTime = [[NSDate date] timeIntervalSince1970];
    object.uniqueID = object.question.qid.longLongValue;
    object.ansid = object.answer.ansid;
    object.qid = object.question.qid;
    
    return object;
}

+ (NSString *)dbName
{
    return [WDDataBaseManager wenDaDBName];
}

+ (NSArray *)persistentProperties {
    
    static NSArray *properties = nil;
    if (!properties) {
        properties = [[super persistentProperties]
                      arrayByAddingObjectsFromArray:@[
                                                      @"behotTime",
                                                      @"cellType",
                                                      @"cursor",
                                                      @"qid",
                                                      @"ansid",
                                                      @"showTopSeparator",
                                                      @"showBottomSeparator",
                                                      @"showDislike",
                                                      @"filterWords",
                                                      @"showLayer",
                                                      @"extra"]];
    }
    return properties;
}

+ (GYCacheLevel)cacheLevel {
    return GYCacheLevelResident;
}

+ (NSInteger)dbVersion
{
    return [WDDataBaseManager wenDaDBVersion];
}

- (void)save
{
    [super save];
    [self.question save];
    [self.answer save];
}

+ (void)deleteDBFileIfNeeded
{
    [super deleteDBFileIfNeeded];
    [WDQuestionEntity deleteDBFileIfNeeded];
    [WDAnswerEntity deleteDBFileIfNeeded];
}

#pragma mark -- TTEntityBase

+ (NSDictionary *)keyMapping
{
    static NSDictionary *properties = nil;
    if (!properties) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[super keyMapping]];
        [dict addEntriesFromDictionary:@{
                                         @"answer":@"answer",
                                         @"behotTime":@"behot_time",
                                         @"cellType":@"cell_type",
                                         @"cursor":@"cursor",
                                         @"extra":@"extra",
                                         @"filterWords":@"filter_words",
                                         @"cellId":@"id",
                                         @"question":@"question",
                                         @"showBottomSeparator":@"show_bottom_separator",
                                         @"showDislike":@"show_dislike",
                                         @"showLayer":@"show_layer",
                                         @"showTopSeparator":@"show_top_separator",
                                         }
         ];
        properties = [dict copy];
    }
    return properties;
}

#pragma mark -- self
- (WDQuestionEntity *)question
{
    if (!_question && !isEmptyString(self.qid)) {
        _question = [WDQuestionEntity objectForPrimaryKey:self.qid];
    }
    
    return _question;
}

- (WDAnswerEntity *)answer
{
    if (!_answer && !isEmptyString(self.ansid)) {
        _answer = [WDAnswerEntity generateAnswerEntityFromAnsid:self.ansid];
    }
    return _answer;
}

@end
