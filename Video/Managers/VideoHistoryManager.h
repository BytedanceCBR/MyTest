//
//  VideoHistoryManager.h
//  Video
//
//  Created by Kimi on 12-10-22.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoData;

@interface VideoHistoryManager : NSObject

+ (VideoHistoryManager *)sharedManager;
- (NSArray *)historyDataList;
- (void)addHistory:(VideoData *)video;


@end
