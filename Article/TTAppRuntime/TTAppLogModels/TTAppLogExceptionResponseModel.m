//
//  TTAppLogExceptionResponseModel.m
//  Article
//
//  Created by chenjiesheng on 16/12/15.
//
//

#import "TTAppLogExceptionResponseModel.h"

@implementation TTAppLogExceptionResponseModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                      @"magic_tag" : @"magicTag"
                                                      }];
}
@end
