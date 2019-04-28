//
//  TTSFShareModel.m
//  Article
//
//  Created by 冯靖君 on 2017/12/6.
//

#import "TTSFShareModel.h"

@implementation TTSFShareModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"type":@"type",
                                                       @"title":@"title",
                                                       @"description":@"shareDescription",
                                                       @"image_url":@"imageURL",
                                                       @"target_url":@"targetURL"
                                                       }];
}

@end
