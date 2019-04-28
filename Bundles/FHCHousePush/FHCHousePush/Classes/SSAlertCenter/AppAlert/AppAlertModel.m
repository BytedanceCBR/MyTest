//
//  AppAlertModel.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-8.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "AppAlertModel.h"

@implementation AppAlertModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                      @"rule_id":@"ruleId",
                                                      @"image":@"imageURLString",
                                                      @"expected_index":@"expectedIndex",
                                                      @"mobile_alert":@"mobileAlert",
                                                      @"content":@"message",
                                                      @"latency_seconds":@"delayTime"
                                                       }];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.expectedIndex = @(NSNotFound);
    }
    
    return self;
}

@end
