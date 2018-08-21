//
//  TSVUserRecommendationModel.m
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/15.
//

#import "TSVUserRecommendationModel.h"
#import <RACEXTKeyPathCoding.h>

@implementation TSVUserRecommendationModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    TSVUserRecommendationModel *model;
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"recommend_reason" : @keypath(model, recommendReason),
                                                       @"recommend_type" : @keypath(model, recommendType),
                                                       @"stats_place_holder" : @keypath(model, statsPlaceHolder),
                                                       @"user" : @keypath(model, user),
                                                       }];
}

@end
