//
//  VideoFlowUnit.h
//  Video
//
//  Created by Tianhang Yu on 12-7-20.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSPageFlowUnit.h"

@class VideoData;

@interface VideoDetailUnit : SSPageFlowUnit

@property (nonatomic, retain) VideoData *videoData;
@property (nonatomic, copy) NSString *trackEventName;

- (void)playerPause;
- (void)refreshUI;
- (void)insertComment:(NSDictionary *)commentData;

@end
