//
//  AKProfileBenefitModel.m
//  Article
//
//  Created by chenjiesheng on 2018/3/8.
//

#import "AKProfileBenefitModel.h"

@implementation AKProfileBenefitReddotInfo

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"text" : @"reddot_text",
                           @"postUrl" : @"reddot_post_url",
                           @"needShow" : @"show_reddot"
                           };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:dict];
}

@end

@implementation AKProfileBenefitModel

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"digit" : @"amount",
                           @"openURL" : @"url",
                           @"benefitName" : @"text",
                           @"reddotInfo" : @"reddot_info",
                           @"type" : @"type"
                           };
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:dict];
}

@end
