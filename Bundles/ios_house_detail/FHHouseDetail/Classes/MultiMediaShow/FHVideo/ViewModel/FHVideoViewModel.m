//
//  FHVideoViewModel.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/16.
//

#import "FHVideoViewModel.h"

@interface FHVideoViewModel ()

@property(nonatomic, strong) FHVideoView *view;
@property(nonatomic, weak) FHVideoViewController *viewController;
@property(nonatomic, strong) NSTimer *playbackTimer;

@end

@implementation FHVideoViewModel

- (instancetype)initWithView:(FHVideoView *)view controller:(FHVideoViewController *)viewController {
    self = [super init];
    if (self) {
        _view = view;
        _viewController = viewController;
    }
    return self;
}

#pragma mark -- playback timer

- (void)invalidatePlaybackTimer {
    [_playbackTimer invalidate];
    _playbackTimer = nil;
}

- (void)startPlayBackTimer {
    [self invalidatePlaybackTimer];
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                          target:self
                                                        selector:@selector(updatePlaybackTime:)
                                                        userInfo:nil
                                                         repeats:YES];
    if (_playbackTimer) {
        [[NSRunLoop currentRunLoop] addTimer:_playbackTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)updatePlaybackTime:(NSTimer *)timer {
    if(self.viewController.model.isShowMiniSlider){
        [self.view refreshMiniSlider];
    }
}

@end
