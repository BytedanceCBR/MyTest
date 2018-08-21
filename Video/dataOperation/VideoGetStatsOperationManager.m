//
//  VideoGetStatsOperationManager.m
//  Video
//
//  Created by Kimi on 12-10-11.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoGetStatsOperationManager.h"
#import "VideoListDataHeader.h"
#import "VideoGetStatsDataOperation.h"
#import "VideoURLSetting.h"

@implementation VideoGetStatsOperationManager

static VideoGetStatsOperationManager *s_operation;
+ (VideoGetStatsOperationManager*)sharedOperation
{
    @synchronized(self) {
        if(!s_operation) {
            s_operation = [[VideoGetStatsOperationManager alloc] init];
        }
        
        return s_operation;
    }
}

- (id)init
{
    self = [super init];
    if(self) {
        VideoGetStatsDataOperation *getStatsOperation = [[VideoGetStatsDataOperation alloc] init];
        [self addOperation:getStatsOperation];
        [getStatsOperation release];
    }
    return self;
}
@end
