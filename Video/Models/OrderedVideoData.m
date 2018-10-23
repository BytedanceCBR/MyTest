//
//  OrderedVideoData.m
//  Video
//
//  Created by Tianhang Yu on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "OrderedVideoData.h"
#import "VideoData.h"
#import "ListDataHeader.h"
#import "VideoListDataHeader.h"


@implementation OrderedVideoData

+ (NSString *)entityName
{
    return @"OrderedVideoData";
}

+ (NSDictionary*)keyMapping
{
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"rangeType", @"sortType", @"tag", @"group_id", nil]
                                       forKeys:[NSArray arrayWithObjects:@"rangeType", @"sortType", @"originalData.tag", @"originalData.groupID", nil]];
}

- (void)updateWithDictionary:(NSDictionary *)dataDict
{
    [super updateWithDictionary:dataDict];
    VideoData *originalData = [VideoData insertEntityWithDictionary:dataDict];
    self.originalData = originalData;
}

+ (NSArray *)entitiesWithCondition:(NSDictionary *)condition count:(NSUInteger)count offset:(NSUInteger)offset
{
    NSMutableArray *predicates = [[NSMutableArray alloc] initWithCapacity:20];
    
    NSMutableDictionary *equalQuery = [NSMutableDictionary dictionary];
    if ([condition.allKeys containsObject:kListDataConditionSortTypeKey]) {
        [equalQuery setObject:[condition objectForKey:kListDataConditionSortTypeKey] forKey:@"sortType"];
    }
    if ([condition.allKeys containsObject:kListDataConditionRangeTypeKey]) {
        [equalQuery setObject:[condition objectForKey:kListDataConditionRangeTypeKey] forKey:@"rangeType"];
    }
    if ([condition.allKeys containsObject:kListDataConditionTagKey]) {
        [equalQuery setObject:[condition objectForKey:kListDataConditionTagKey] forKey:@"originalData.tag"];
    }
    
    
    for (NSString *key in equalQuery)
    {
        NSExpression *le = [NSExpression expressionForKeyPath:key];
        NSExpression *re = [NSExpression expressionForConstantValue:[equalQuery objectForKey:key]];
        NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le rightExpression:re modifier:NSDirectPredicateModifier type:NSEqualToPredicateOperatorType options:0];
        [predicates addObject:comparePredicate];
    }
    
    // less than query
    NSMutableDictionary *lessThanOrEqualQuery = [NSMutableDictionary dictionary];
    if ([condition.allKeys containsObject:kVideoListDataConditionLatestKey]) {
        [lessThanOrEqualQuery setObject:[condition objectForKey:kVideoListDataConditionLatestKey]
                                 forKey:@"originalData.behotTime"];
    }
    
    for (NSString *key in lessThanOrEqualQuery)
    {
        NSExpression *le = [NSExpression expressionForKeyPath:key];
        NSExpression *re = [NSExpression expressionForConstantValue:[lessThanOrEqualQuery objectForKey:key]];
        NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le rightExpression:re modifier:NSDirectPredicateModifier type:NSLessThanOrEqualToPredicateOperatorType options:0];
        [predicates addObject:comparePredicate];
    }
    
    // greater than
    NSMutableDictionary *greaterThanOrEqualQuery = [NSMutableDictionary dictionary];
    if ([condition.allKeys containsObject:kVideoListDataConditionEarliestKey]) {
        [greaterThanOrEqualQuery setObject:[condition objectForKey:kVideoListDataConditionEarliestKey]
                                    forKey:@"originalData.behotTime"];
    }
    
    for (NSString *key in greaterThanOrEqualQuery) {
        NSExpression *le = [NSExpression expressionForKeyPath:key];
        NSExpression *re = [NSExpression expressionForConstantValue:[greaterThanOrEqualQuery objectForKey:key]];
        NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le rightExpression:re modifier:NSDirectPredicateModifier type:NSGreaterThanOrEqualToPredicateOperatorType options:0];
        [predicates addObject:comparePredicate];
    }
    
    // not equal
    NSDictionary *notEqualQuery = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                              forKey:@"originalData.groupID"];
    
    for (NSString *key in notEqualQuery) {
        NSExpression *le = [NSExpression expressionForKeyPath:key];
        NSExpression *re = [NSExpression expressionForConstantValue:[notEqualQuery objectForKey:key]];
        NSPredicate *comparePredicate = [NSComparisonPredicate predicateWithLeftExpression:le rightExpression:re modifier:NSDirectPredicateModifier type:NSNotEqualToPredicateOperatorType options:0];
        [predicates addObject:comparePredicate];
    }
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    [predicates release];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *fetchPredicate = compoundPredicate;
    [request setEntity:[OrderedVideoData entityDescription]];
    [request setPredicate:fetchPredicate];
    [request setReturnsObjectsAsFaults:YES];
    [request setFetchLimit:count];
    [request setFetchOffset:offset];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderIndex" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sd]];
    
    NSError *error = nil;
    NSArray *result = [[SSModelManager sharedManager] entitiesWithFetch:request error:&error];
    
    [request release];
    
    if (!error) {
        return result;
    }
    else {
        return nil;
    }
}

@end
