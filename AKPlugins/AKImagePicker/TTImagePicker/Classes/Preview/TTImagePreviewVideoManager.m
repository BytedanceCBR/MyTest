//
//  TTImagePreviewVideoManager.m
//  Article
//
//  Created by SongChai on 2017/4/12.
//
//

#import "TTImagePreviewVideoManager.h"
#import "TTBaseMacro.h"

#define CenterX (15+[[UIScreen mainScreen] bounds].size.width*.5)

@implementation TTImagePreviewVideoManager {
    __weak TTImagePreviewVideoView *_videoView;
    
    NSTimer *timer;
    
    BOOL  isTracking;
    
    BOOL  isShowInWindow;
    
    NSMutableArray *_registeredNotifications;
    
    
    TTImagePreviewVideoState _lastState;
}

-(void)destory {
    [self unregisterApplicationObservers];
    [timer invalidate];
    timer = nil;
    _videoPlayer = nil;
}

-(instancetype)init {
    if (self = [super init]) {
        
        timer = [NSTimer scheduledTimerWithTimeInterval:.3
                                                 target:self
                                               selector:@selector(checkPlayState)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        isTracking = NO;
        isShowInWindow = NO;
        _registeredNotifications = [[NSMutableArray alloc] init];
        
        _videoPlayer = [[TTImagePreviewVideoLayerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _videoPlayer.userInteractionEnabled = NO;
        _videoPlayer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _videoPlayer.autoresizesSubviews = YES;
        _videoPlayer.backgroundColor = [UIColor clearColor];
        for(UIView *aSubView in _videoPlayer.subviews) {
            aSubView.backgroundColor = [UIColor clearColor];
        }
        [self registerApplicationObservers];
        
        _lastState = TTImagePreviewVideoStateNormal;
    }
    return self;
}

-(void)setVideoView:(TTImagePreviewVideoView *)view{
    _videoView = view;
}

- (void)removeVideoView {
    _videoView = nil;
    [timer invalidate];
}

-(void)resetVideoPlayWithAsset:(id)asset
{
    if (_videoPlayer == nil || _videoPlayer.superview == nil || _videoPlayer.asset != asset || _videoPlayer.state == TTImagePreviewVideoStateNormal) {
        [self removeVideoPlayer];
        _videoPlayer = [[TTImagePreviewVideoLayerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _videoPlayer.userInteractionEnabled = NO;
        _videoPlayer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _videoPlayer.autoresizesSubviews = YES;
        _videoPlayer.backgroundColor = [UIColor clearColor];
        for(UIView *aSubView in _videoPlayer.subviews) {
            aSubView.backgroundColor = [UIColor clearColor];
        }
        [_videoView addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(void)removeVideoPlayer
{
    [_videoPlayer shutdown];
    
    @try {
        [_videoPlayer removeObserver:self forKeyPath:@"state"];
    } @catch (NSException *exception) {
    } @finally {
    }
    
    
    _videoPlayer = nil;
}

-(void)checkPlayState
{
    @autoreleasepool {
        BOOL showInWindow = _videoView.window == nil ? NO : YES;
        isShowInWindow = showInWindow;
        
        BOOL tracking = [NSRunLoop currentRunLoop].currentMode == UITrackingRunLoopMode;
        if (tracking && !isTracking) {
            [self beginTrack];
        }
        if (tracking) {
            [self onTracking];
        }
        if (!tracking && isTracking) {
            [self endTrack];
        }
        isTracking = tracking;
    }
}

-(void)beginTrack
{
    //开始滑
    NSLog(@"beginTrack");
}


-(void)onTracking
{
    //滑动过程
    if (_videoView && ![self isDisplayedInScreen:_videoView]) {
        [_videoView pause];
    }
}

-(void)endTrack {
    if (_videoView && ![self isDisplayedInScreen:_videoView]) {
        [_videoView pause];
    }
}


// 判断View是否显示在屏幕上
-(BOOL)isDisplayedInScreen:(UIView *)view
{
    
    if (view.window == nil) {
        return NO;
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect rect = [view convertRect:view.frame toView:[UIApplication sharedApplication].keyWindow];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return NO;
    }
    
    if (view.hidden) {
        return NO;
    }
    
    if (view.superview == nil) {
        return NO;
    }
    
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return  NO;
    }
    
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return NO;
    }
    return YES;
}


- (void)registerApplicationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [_registeredNotifications addObject:UIApplicationWillEnterForegroundNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [_registeredNotifications addObject:UIApplicationDidBecomeActiveNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [_registeredNotifications addObject:UIApplicationWillResignActiveNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [_registeredNotifications addObject:UIApplicationDidEnterBackgroundNotification];
    
    [self.videoPlayer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)unregisterApplicationObservers
{
    
    @try {
        for (NSString *name in _registeredNotifications) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:name
                                                          object:nil];
        }
        
        [self.videoPlayer removeObserver:self forKeyPath:@"state"];

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}


- (void)applicationWillEnterForeground{
}

- (void)applicationDidBecomeActive{
    if (self.videoPlayer.state == TTImagePreviewVideoStatePlaying) {
        [self.videoPlayer resume];
    }
}

- (void)applicationWillResignActive{
    if (self.videoPlayer.state == TTImagePreviewVideoStatePlaying) {
        [self.videoPlayer pause];
        if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.f) { //低端手机继续播放手机太卡了，用操作系统的方式进行的保护，其实不严谨，以后可以搞成根据手机
            self.videoPlayer.state = TTImagePreviewVideoStatePlaying;
        }
    }
}

- (void)applicationDidEnterBackground{
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    WeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        StrongSelf;
        if (object == self.videoPlayer) {
            if ([keyPath isEqualToString:@"state"]) {
                TTImagePreviewVideoState state = self.videoPlayer.state;
                if (state != self->_lastState) {
                    self->_lastState = state;
                    if (self.stateBlock) {
                        self.stateBlock(state);
                    }
                }
            }
        }
    });
}

@end
