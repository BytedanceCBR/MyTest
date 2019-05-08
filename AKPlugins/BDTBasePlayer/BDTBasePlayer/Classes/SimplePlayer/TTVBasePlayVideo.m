//
//  TTVBasePlayVideo.m
//  Article
//
//  Created by panxiang on 2017/5/11.
//
//

#import "TTVBasePlayVideo.h"
#import "TTVPlayerController.h"
#import "TTMovieStore.h"
#import "TTVDemanderTrackerManager.h"
#import "TTVPlayerUrlTracker.h"
#import "TTImageView.h"
#import <TTNetBusiness/TTNetworkUtilities.h>
#import "SSAppStore.h"
#import "TTModuleBridge.h"
extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern NSString * const TTStrongPushNotificationWillShowNotification;
extern NSString * const TTStrongPushNotificationWillHideNotification;
extern NSString* const TTAdAppointAlertViewShowKey;
extern NSString* const TTAdAppointAlertViewCloseKey;

static __weak TTVBasePlayVideo *currentTTVBasePlayVideo_ = nil;

@interface TTVBasePlayVideo ()
@property (nonatomic, strong) TTImageView *logoImageView;
@property (nonatomic, strong) TTVBasePlayerModel *playerModel;

@end

@implementation TTVBasePlayVideo
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player stop];
}

- (instancetype)initWithFrame:(CGRect)frame playerModel:(TTVBasePlayerModel *)playerModel
{
    self = [super initWithFrame:frame];
    if (self) {
        _player = [[TTVBaseDemandPlayer alloc] initWithFrame:self.bounds];
        [self addSubview:_player];
        [TTVBasePlayVideo setCurrentPlayingPlayVideo:self];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[TTMovieStore shareTTMovieStore] addMovie:self];
        self.playerModel = playerModel;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(strongPushNotificationWillShowNotification:) name:TTStrongPushNotificationWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(strongPushNotificationWillHideNotification:) name:TTStrongPushNotificationWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidAppear:) name:SKStoreProductViewDidAppearKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:SKStoreProductViewDidDisappearKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appointAlertViewShow:) name:TTAdAppointAlertViewShowKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appointAlertViewHide:) name:TTAdAppointAlertViewCloseKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_openRedPackert:) name:@"TTOpenRedPackertNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_closeRedPackert:) name:@"TTCloseRedPackertNotification" object:nil];
    }
    return self;
}


- (void)ttv_openRedPackert:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)ttv_closeRedPackert:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

- (void)appointAlertViewShow:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)appointAlertViewHide:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

- (void)skStoreViewDidAppear:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)skStoreViewDidDisappear:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

- (void)strongPushNotificationWillShowNotification:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePause payload:nil];
}

- (void)strongPushNotificationWillHideNotification:(NSNotification *)notification
{
    [_player sendAction:TTVPlayerEventTypeVirtualStackValuePlay payload:nil];
}

- (void)setPlayerModel:(TTVBasePlayerModel *)playerModel
{
    if (_playerModel != playerModel) {
//        playerModel.urlBaseParameter = [TTNetworkUtilities commonURLParameters];
        playerModel.enableResolution = playerModel.enableResolution;
        _playerModel = playerModel;
        [self ttv_addPlayer];
    }
}

- (void)resetPlayerModel:(TTVBasePlayerModel *)playerModel
{
    self.playerModel = playerModel;
    [self.player reset];
    [self.player readyToPlay];
}

- (void)ttv_addPlayer
{
    _player.playerModel = self.playerModel;
    _player.rotateView = self;
}

- (TTVDemanderTrackerManager *)commonTracker
{
    return _player.commonTracker;
}

- (void)setVideoLargeImageDict:(NSDictionary *)videoLargeImageDict
{
    if (!_logoImageView) {
        _logoImageView = [[TTImageView alloc] initWithFrame:self.frame];
        _logoImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _logoImageView.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground5];
        _logoImageView.userInteractionEnabled = YES;
        _logoImageView.imageView.userInteractionEnabled = YES;
        [self.player setLogoImageView:_logoImageView];
    }
    [_logoImageView setImageWithModel:[self logoImageModel:videoLargeImageDict]];;
}

- (void)setVideoLargeImageUrl:(NSString *)imageUrl
{
    if (!_logoImageView) {
        _logoImageView = [[TTImageView alloc] initWithFrame:self.frame];
        _logoImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _logoImageView.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground5];
        _logoImageView.userInteractionEnabled = YES;
        _logoImageView.imageView.userInteractionEnabled = YES;
        [self.player setLogoImageView:_logoImageView];
    }
    if (!isEmptyString(imageUrl)) {
        [_logoImageView setImageWithURLString:imageUrl];;
    }
}

- (TTImageInfosModel *)logoImageModel:(NSDictionary *)imageDict
{
    if (imageDict) {
        if (imageDict.count <= 0) {
            return nil;
        }
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:imageDict];
        return model;
    }
    return nil;
}


- (void)layoutSubviews
{
    _player.frame = self.bounds;
    [super layoutSubviews];
}

/**
 TTMovieStoreAction 为了满足协议
 */

- (void)stopWithFinishedBlock:(TTVStopFinished)finishedBlock
{
    [self.player stop];
}

- (void)stop
{
    [self stopWithFinishedBlock:nil];
}

- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion
{
    [self.player exitFullScreen:animated completion:completion];
}

+ (void)removeExcept:(UIView <TTMovieStoreAction> *)video
{
    [[TTMovieStore shareTTMovieStore] removeExcept:video];
}

+ (void)removeAll
{
    [[TTMovieStore shareTTMovieStore] removeAll];
}

+ (void)setCurrentPlayingPlayVideo:(TTVBasePlayVideo *)playVideo
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    currentTTVBasePlayVideo_ = playVideo;
}

+ (TTVBasePlayVideo *)currentPlayingPlayVideo
{
    NSAssert([NSThread isMainThread], @"must be called in main thread");
    return currentTTVBasePlayVideo_;
}

@end
