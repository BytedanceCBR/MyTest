//
//  FHShowVideoView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/23.
//

#import "FHShowVideoView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "FHCommonDefines.h"

@interface FHShowVideoView ()<FHVideoViewControllerDelegate>

@property (nonatomic, assign)   BOOL       isVerticalVideo;

@end

@implementation FHShowVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _isVerticalVideo = NO;
}

- (void)setVideoVC:(FHVideoViewController *)videoVC {
    if (videoVC != _videoVC) {
        _videoVC = videoVC;
        videoVC.delegate = self;
        // 状态维护
        videoVC.model.isShowControl = YES;
        videoVC.model.isShowStartBtnWhenPause = NO;
        videoVC.model.isShowMiniSlider = NO;
        [self.videoVC updateData:videoVC.model];
        _videoVC.view.backgroundColor = [UIColor clearColor];
        _vedioView = _videoVC.view;
        
        [self addSubview:_vedioView];
    }
}

// 不支持手势放大
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

// 获取当前视频的frame
- (CGRect)videoFrame:(CGRect)tempFrame {
    CGRect vframe = tempFrame;
    if (self.videoVC.videoWidth > 0 && self.videoVC.videoHeight > 0) {
        CGFloat winWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat radio = self.videoVC.videoWidth / winWidth;
        CGFloat tempW = self.videoVC.videoWidth / radio;
        CGFloat tempH = self.videoVC.videoHeight / radio;
        CGFloat offsetX = (vframe.size.width - tempW) / 2;
        CGFloat offsetY = (vframe.size.height - tempH) / 2;
        vframe.origin.x += offsetX;
        vframe.origin.y += offsetY;
        vframe.size.width = tempW;
        vframe.size.height = tempH;
        if (self.videoVC.videoHeight > self.videoVC.videoWidth) {
            self.isVerticalVideo = YES;
        } else {
            self.isVerticalVideo = NO;
        }
    }
    return vframe;
}

- (CGRect)showVideoFrame {
    CGRect frame = self.videoVC.videoFrame;
    self.currentImageView.frame = frame;
    self.currentImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    frame = self.currentImageView.frame;
    if (self.videoVC.playbackState != TTVPlaybackState_Stopped) {
        frame = [self videoFrame:frame];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoFrameChanged:isVerticalVideo:)]) {
        [self.delegate videoFrameChanged:frame isVerticalVideo:self.isVerticalVideo];
    }
    return frame;
}

// 动画用(进入以及退出动画)
- (UIView *)displayImageView
{
    UIImageView *displayV = [super displayImageView];
    displayV.hidden = YES;
    CGRect imageViewFrame = [self showVideoFrame];
    self.vedioView.frame = imageViewFrame;
    return self.vedioView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height){
        return;
    }
    
    CGRect imageViewFrame = [self showVideoFrame];
    if (self.vedioView.superview == self) {
        self.currentImageView.hidden = YES;
        self.vedioView.frame = imageViewFrame;
        [self.vedioView.superview bringSubviewToFront:self.vedioView];// 需要播放的时候把当前页面移动到前面
    }
}

- (void)play {
    [_videoVC play];
}

- (void)pause {
    [_videoVC pause];
}


// 播放状态改变
- (void)playbackStateDidChanged:(TTVPlaybackState)playbackState {
    if (TTVPlaybackState_Playing == playbackState || TTVPlaybackState_Stopped == playbackState) {
        [self setNeedsLayout];
    }
}

// 很不乐意这样加，为了进入和退出全屏，要传递多层代理，balala...
// 进入全屏
- (void)playerDidEnterFullscreen {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidEnterFullscreen)]) {
        [self.delegate playerDidEnterFullscreen];
    }
}

// 离开全屏
- (void)playerDidExitFullscreen {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidExitFullscreen)]) {
        [self.delegate playerDidExitFullscreen];
    }
}

@end
