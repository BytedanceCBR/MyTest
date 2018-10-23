//
//  TTImagePreviewVideoView.m
//  Article
//
//  Created by SongChai on 2017/4/12.
//
//

#import "TTImagePreviewVideoView.h"
#import "TTImagePickerManager.h"
#import "TTImagePreviewVideoManager.h"
#import "TTImagePickerTrackManager.h"
#import "TTBaseMacro.h"
#import "TTImagePreviewViewController.h"
#import "TTImagePickerAlert.h"

@interface TTImagePreviewVideoView () {
    UIImage* _cover;
}
@property(nonatomic, strong) TTImagePreviewVideoManager* manager;

@end



@implementation TTImagePreviewVideoView

- (id)initWithFrame:(CGRect)frame withManager:(TTImagePreviewVideoManager *)manager {
    if(self = [super initWithFrame:frame]) {
        _manager = manager;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setCover:(UIImage *)cover {
    _cover = cover;
    self.image = cover;
}

- (TTImagePreviewVideoState)state {
    if (_asset == self.manager.asset) {
        if (self.manager.videoPlayer.superview == self) { //还在当前页面跑
            return self.manager.videoPlayer.state;
        }
        return TTImagePreviewVideoStateNormal;
    } else {
        return TTImagePreviewVideoStateNormal;
    }
}

- (void)prepare {
    if (_asset == self.manager.asset) {
        if (self.manager.videoPlayer.superview == self) {
            if (self.manager.videoPlayer.state == TTImagePreviewVideoStateNormal) {
                [self.manager.videoPlayer prepare];
            }
        } else {
            self.manager.videoPlayer.asset = _asset;
            [self.manager.videoPlayer removeFromSuperview];
            self.manager.videoPlayer.frame = self.bounds;
            [self addSubview:self.manager.videoPlayer];
            [self.manager.videoPlayer prepare];
        }
    }
}

- (void)play {
    if (_asset == self.manager.asset) {
        if (self.manager.videoPlayer.superview == self) {
            if (self.manager.videoPlayer.state == TTImagePreviewVideoStateNormal) {
                [self.manager.videoPlayer play];
            } else if (self.manager.videoPlayer.state == TTImagePreviewVideoStatePause) {
                [self.manager.videoPlayer resume];
            }
        } else {
            self.manager.videoPlayer.asset = _asset;
            [self.manager.videoPlayer removeFromSuperview];
            self.manager.videoPlayer.frame = self.bounds;
            [self addSubview:self.manager.videoPlayer];
            [self.manager.videoPlayer play];
        }
    }
}

- (void)pause {
    if (_asset == self.manager.asset && _asset == self.manager.videoPlayer.asset) {
        if (self.manager.videoPlayer.superview == self) {
            [self.manager.videoPlayer pause];
        }
    }
}

- (void)stop {
    if (_asset == self.manager.asset && _asset == self.manager.videoPlayer.asset) {
        if (self.manager.videoPlayer.superview == self) {
            [self.manager.videoPlayer shutdown];
        }
    }
}

@end

@interface TTImagePreviewVideoLayerView()

@property (nonatomic,strong)TTImagePickerLoadingView *loadingView;
@property (nonatomic,strong)AVPlayerItem *playerItem;

@end


@implementation TTImagePreviewVideoLayerView{
    NSString* _videoFillMode;
    id _currentPlayAsset;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _videoFillMode = @"AVLayerVideoGravityResizeAspect";
        _state = TTImagePreviewVideoStateNormal;
    }
    return self;
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
    [self setVideoFillMode:_videoFillMode];
}

- (void)setVideoFillMode:(NSString *)fillMode
{
    _videoFillMode = fillMode;
    
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
            [self setVideoFillMode:AVLayerVideoGravityResize];
            break;
        case UIViewContentModeCenter:
            [self setVideoFillMode:AVLayerVideoGravityResizeAspect];
            break;
        case UIViewContentModeScaleAspectFill:
            [self setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
            break;
        case UIViewContentModeScaleAspectFit:
            [self setVideoFillMode:AVLayerVideoGravityResizeAspect];
        default:
            break;
    }
}

- (void)shutdown {
    self.hidden = YES;
    _currentPlayAsset = nil;
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    self.state = TTImagePreviewVideoStateNormal;
}

- (void)playComplete {
    self.state = TTImagePreviewVideoStateNormal;
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    [self prepare];
}

- (void)pause {

    if (_currentPlayAsset != self.asset) {
        return;
    }
    TTImagePickerTrack(TTImagePickerTrackKeyVideoPreviewPause, nil);

    [self.player pause];
    self.state = TTImagePreviewVideoStatePause;
}

- (void)resume {
    if (_currentPlayAsset != self.asset) {
        return;
    }
    if (!self.player && self.playerItem) {
        [self _initPlayer:self.playerItem];
    }
    [self.player play];
    self.state = TTImagePreviewVideoStatePlaying;
}

- (void)prepare {
    
    [self _initLoadingView];
    if (_currentPlayAsset == self.asset) {
        return;
    }
    if (self.state != TTImagePreviewVideoStateNormal) {
        [self shutdown];
    }
    self.hidden = YES;
    [[TTImagePickerManager manager] getVideoWithAsset:self.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        
        if (playerItem) {
            [self _initPlayer:playerItem];
            self.playerItem = playerItem;
        }else{
            _loadingView.isFailed = YES;
            return ;
        }
        self.myVC.canComplete = YES;

        _currentPlayAsset = self.asset;
        
        if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.f) { //低版本视频显示和错略图有出入，做一下延迟处理
            self.hidden = NO;
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.hidden = NO;
            });
        }
        _loadingView.hidden = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playComplete) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        
        NSLog(@"%f",progress);
        _loadingView.progress = progress;

    }];
}



- (void)play {
    if (self.state != TTImagePreviewVideoStateNormal) {
        [self shutdown];
    }
    
    
    if (_currentPlayAsset != self.asset) {
        if (_loadingView.isFailed) {
            [TTImagePickerAlert showWithTitle:@"iCloud同步失败"];
        }else{
            [TTImagePickerAlert showWithTitle:@"iCloud同步中"];
        }
        return;
    }
    if (!self.player && self.playerItem) {
        [self _initPlayer:self.playerItem];
    }
    self.hidden = NO;
    [self.player play];
    TTImagePickerTrack(TTImagePickerTrackKeyVideoPreviewPlay, nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playComplete) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    self.state = TTImagePreviewVideoStatePlaying;
    
}

- (void)_initPlayer:(AVPlayerItem *)playerItem
{
    if (self.player == nil) {
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = self.bounds;
        [self.layer addSublayer:playerLayer];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    }
}

- (void)_initLoadingView
{
    self.myVC.loadingView = nil;
    _loadingView = nil;
    _loadingView = [[TTImagePickerLoadingView alloc]initWithFrame:CGRectMake(12, KScreenHeight - 32 -12, 32, 32)];
    _loadingView.inset = 3;
    _loadingView.isShowFailedLabel = YES;
    _loadingView.autoDismissWhenCompleted = NO;
    WeakSelf;
    _loadingView.retry = ^{
        StrongSelf;
        //重新开始加载视频
        [self prepare];
    };
    self.myVC.loadingView = _loadingView;
    self.myVC.loadingView.hidden = YES;
    self.myVC.canComplete = NO;
    
}
@end
