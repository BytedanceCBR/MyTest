//
//  VideoURLSetting.m
//  Video
//
//  Created by Dianwei on 12-7-27.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoURLSetting.h"

@implementation VideoURLSetting

+ (NSString*)recentURLString
{
    return [NSString stringWithFormat:@"%@/2/video/v2/recent/", [self baseURL]];
}

+ (NSString*)topURLString
{
    return [NSString stringWithFormat:@"%@/2/video/v2/top/", [self baseURL]];
}

+ (NSString*)hotURLString
{
    return [NSString stringWithFormat:@"%@/2/video/v2/hot/", [self baseURL]];
}

+ (NSString*)getStatsURLString
{
    return [NSString stringWithFormat:@"%@/2/video/get_stats/", [self baseURL]];
}

+ (NSString*)getUpdatesString
{
    return [NSString stringWithFormat:@"%@/2/data/get_updates/", [self SNSBaseURL]];
}

+ (NSString*)getFavoritesURLString
{
    return [NSString stringWithFormat:@"%@/2/data/v2/get_favorites/", [self SNSBaseURL]];
}

+ (NSString*)videoFailedFeedbackURLString
{
    return [NSString stringWithFormat:@"%@/feedback/1/video_url/", [self baseURL]];
}

@end
