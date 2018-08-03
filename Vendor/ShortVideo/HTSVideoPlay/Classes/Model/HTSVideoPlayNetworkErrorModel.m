//
//  HTSVideoPlayNetworkErrorModel.m
//  LiveStreaming
//
//  Created by Quan Quan on 16/2/26.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "HTSVideoPlayNetworkErrorModel.h"

@implementation HTSVideoPlayNetworkErrorModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"code"    : @"status_code",
             @"message" : @"data.message",
             @"prompts" : @"data.prompts",
             @"url"     : @"extra.download_url"};
}

@end
