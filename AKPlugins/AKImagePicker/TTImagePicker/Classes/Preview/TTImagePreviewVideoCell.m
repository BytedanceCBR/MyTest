//
//  TTImagePreviewVideoCell.m
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

#import "TTImagePreviewVideoCell.h"
#import "TTImagePickerManager.h"
#import "TTImagePreviewVideoView.h"
#import "UIViewAdditions.h"
#import "TTBaseMacro.h"

@interface TTImagePreviewVideoCell ()

@property(nonatomic, strong) TTImagePreviewVideoView* videoView;
@property(nonatomic, strong) UIButton* playButton;
@end

@implementation TTImagePreviewVideoCell

- (void)configVideoView {
    if (_videoView == nil) {
        _videoView = [[TTImagePreviewVideoView alloc] initWithFrame:self.bounds withManager:self.videoManager];
        [self addSubview:_videoView];
        _videoView.center = CGPointMake(self.width/2, self.height/2);
        [_videoView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    }
    for (UIView* view in _videoView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)willDisplay {
    [self configMoviePlayer];
}

- (void)configMoviePlayer {
    [self configVideoView];
    self.videoView.asset = self.model.asset;
    self.videoManager.asset = self.model.asset;
    [[TTImagePickerManager manager] getPhotoWithAsset:self.model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (photo) {
            self.videoView.image = photo;
        }
    }];
    [self.videoView prepare];
    [self configPlayButton];
}

- (void)configPlayButton {
    if (_playButton == nil) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(0, 64, self.width, self.height - 64 - 44);
        [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
    }
    [self bringSubviewToFront:_playButton];
    [_playButton setImage:[UIImage imageNamed:@"ImgPic_play"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"ImgPic_play"] forState:UIControlStateHighlighted];
}

- (void)playButtonClick {
    WeakSelf;
    self.videoManager.stateBlock = ^(TTImagePreviewVideoState state) {
        [wself.playButton setImage:state == TTImagePreviewVideoStatePlaying? nil: [UIImage imageNamed:@"ImgPic_play"] forState:UIControlStateNormal];
        if (wself.singleTapGestureBlock) {
            wself.singleTapGestureBlock(wself);
        }
    };
    
    [self.videoManager setVideoView:self.videoView];
    if (self.videoView.state == TTImagePreviewVideoStatePlaying) {
        [self.videoView pause];
    } else {
        [self.videoView play];
    }
}

@end
