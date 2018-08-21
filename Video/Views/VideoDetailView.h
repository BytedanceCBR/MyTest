//
//  VideoDetailView.h
//  Video
//
//  Created by 于 天航 on 12-8-3.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSViewBase.h"

@class VideoData;

@interface VideoDetailView : SSViewBase

- (id)initWithFrame:(CGRect)frame video:(VideoData *)video;

@end
