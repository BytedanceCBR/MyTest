//
//  VideoPlayViewController.h
//  Video
//
//  Created by Tianhang Yu on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoPlayerView;
@interface VideoPlayViewController : UIViewController
@property (nonatomic, retain) VideoPlayerView *playerView;
@property (nonatomic) BOOL needDismiss;
@end
