//
//  SSBaseAlertModel.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-8.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "SSBaseAlertModel.h"

@implementation SSBaseAlertModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                      @"content":@"message",
                                                      @"latency_seconds":@"delayTime"
                                                       }];
}
@end
