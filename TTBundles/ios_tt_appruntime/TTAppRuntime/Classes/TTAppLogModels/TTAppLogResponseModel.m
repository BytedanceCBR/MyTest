//
//  TTAppLogResponseModel.m
//  Article
//
//  Created by fengyadong on 16/12/14.
//
//

#import "TTAppLogResponseModel.h"

@implementation TTAppLogResponseModel

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"magic_tag": @"magicTag",
                                                       @"message": @"message",
                                                       @"server_time": @"serverTime",
                                                       @"blacklist":@"blackList"
                                                       }];
}

@end
