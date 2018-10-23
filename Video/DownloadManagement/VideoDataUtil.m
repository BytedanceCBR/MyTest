//
//  VideoDataUtil.m
//  Video
//
//  Created by Dianwei on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDataUtil.h"

@implementation VideoDataUtil

static NSString *s_basePath;
+ (NSString*)localBasePath
{
    @synchronized(self)
    {
        if(!s_basePath)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docDirectory = [paths objectAtIndex:0];
            s_basePath = [[docDirectory stringByAppendingPathComponent:@"/video"] copy];
        }
        
        return s_basePath;
    }
}

+ (NSString*)localBaseURLString
{
    return [NSString stringWithFormat:@"http://localhost:%@/video", SSLogicStringNODefault(@"vlHTTPServerPort")];
//    return @"http://localhost:12345/video";
}

+ (NSString*)localBaseTempPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/"];
}

+ (NSString*)destinationBasePathForGroupID:(int)groupID
{
    return [[VideoDataUtil localBasePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", groupID]];
}

+ (NSString*)temporaryBasePathForGroupID:(int)groupID
{
    return [[VideoDataUtil localBaseTempPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", groupID]];
}

@end
