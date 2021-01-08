//
//  FHShowVideoView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/23.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "TTPhotoScrollViewController.h"
#import "TTShowImageView.h"
#import "FHVideoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class FHShowVideoView;

@protocol FHVideoViewDelegate <NSObject>

// 默认是横屏视频
- (void)videoFrameChanged:(CGRect)videoFrame isVerticalVideo:(BOOL)isVerticalVideo;
// 进入全屏
- (void)playerDidEnterFullscreen;
// 离开全屏
- (void)playerDidExitFullscreen;

@end

// 视频View
@interface FHShowVideoView : TTShowImageView

@property (nonatomic, weak)     id<FHVideoViewDelegate>    delegate;
@property (nonatomic, strong)     FHVideoViewController      *videoVC;
@property (nonatomic, weak)   UIView       *vedioView;
- (void)play;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
