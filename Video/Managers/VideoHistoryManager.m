//
//  VideoHistoryManager.m
//  Video
//
//  Created by Kimi on 12-10-22.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoHistoryManager.h"
#import "SSModelManager.h"
#import "VideoData.h"

#define LoadCount 200

@implementation VideoHistoryManager

static VideoHistoryManager *_sharedManager;
+ (VideoHistoryManager *)sharedManager
{
    @synchronized(self) {
        if (!_sharedManager) {
            _sharedManager = [[VideoHistoryManager alloc] init];
        }
    }
    return _sharedManager;
}

- (NSArray *)historyDataList
{
    NSError *error = nil;
    NSArray *result = [[SSModelManager sharedManager] entitiesWithQuery:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                         @YES, @"addHistory",
                                                                         nil]
                                                      entityDescription:[VideoData entityDescription]
                                                             unFaulting:NO
                                                                 offset:0
                                                                  count:LoadCount
                                                        sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"historyTime"
                                                                                                        ascending:NO]]
                                                                  error:&error];
    if (!error) {
        return result;
    }
    else {
        return nil;
    }
}

- (void)addHistory:(VideoData *)video
{
    if ([video.addHistory boolValue] == NO) {
        video.addHistory = @YES;
        video.historyTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        [[SSModelManager sharedManager] save:nil];
    }
}

@end
