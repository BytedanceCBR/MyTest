//
//  FHShowVideoView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/23.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "TTPhotoScrollViewController.h"
#import "FHDetailMediaHeaderCell.h"
#import "TTShowImageView.h"
#import "FHVideoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class FHShowVideoView;

@protocol FHVideoViewDelegate <NSObject>

// 全屏按钮点击
- (void)videoViewFullScreenClick:(FHShowVideoView *)videoView;
// 默认是横屏视频
- (void)videoFrameChanged:(CGRect)videoFrame isVerticalVideo:(BOOL)isVerticalVideo;

@end

// 视频View
@interface FHShowVideoView : TTShowImageView

@property (nonatomic, weak)     id<FHVideoViewDelegate>    delegate;
@property (nonatomic, weak)     FHVideoViewController      *videoVC;
@property (nonatomic, weak)   UIView       *vedioView;
- (void)play;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
