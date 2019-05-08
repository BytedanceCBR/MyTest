//
//  TTVPlayerControlTipView.m
//  Article
//
//  Created by panxiang on 2017/5/16.
//
//

#import "TTVPlayerControlTipView.h"
#import "TTDeviceHelper.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "TTVPlayerTipCreator.h"
#import "KVOController.h"
#import "TTVPlayerStateStore.h"
#import "TTVPlayerStateAction.h"
#import "TTVPalyerTrafficAlert.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TTVPlayerControlTipView ()
@property (nonatomic, strong)UIView <TTVPlayerTipRetry> *retryView;
@property (nonatomic, strong)UIView <TTVPlayerTipLoading> *loadingView;
@property (nonatomic, strong)UIView <TTVPlayerTipFinished>  *finishedView;
@property(nonatomic, assign)BOOL isFullScreen;
@property (nonatomic, strong) RACDisposable *showFinishedViewDisposable;
@end



@implementation TTVPlayerControlTipView

- (void)dealloc
{
    [self.loadingView stopLoading];
    [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tipType = TTVPlayerControlTipViewTypeUnknow;
        self.isFullScreen = NO;
    }
    return self;
}


- (void)createViewsWithCreator:(id <TTVPlayerTipCreator>)tipCreator
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _loadingView = [tipCreator tip_loadingViewWithFrame:self.bounds];
    _loadingView.hidden = YES;
    _retryView = [tipCreator tip_retryViewWithFrame:self.bounds];
    _retryView.hidden = YES;
    _finishedView = [tipCreator tip_finishedViewWithFrame:self.bounds];
    _finishedView.hidden = YES;
    _finishedView.playerStateStore = self.playerStateStore;
    
    tipCreator.tipLoadinView = _loadingView;
    tipCreator.tipRetryView = _retryView;
    tipCreator.tipFinishedView = _finishedView;
    
    if (_loadingView) {
        [self addSubview:_loadingView];
    }
    if (_retryView) {
        [self addSubview:_retryView];
    }
    if (_finishedView) {
        [self addSubview:_finishedView];
    }
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
        self.finishedView.playerStateStore = playerStateStore;
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,playbackState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        TTVVideoPlaybackState state = [[change valueForKey:NSKeyValueChangeNewKey] longLongValue];
        switch (state) {
            case TTVVideoPlaybackStateError:{
                [self showTipView:TTVPlayerControlTipViewTypeRetry];
            }
                break;
            case TTVVideoPlaybackStatePaused:{
            }
                break;
            case TTVVideoPlaybackStateFinished:{//stop 也会走,只有正常播放完毕才会显示TTVPlayerControlTipViewTypeFinished
                if (self.playerStateStore.state.resolutionState != TTVResolutionStateChanging) {
                    [self showTipView:TTVPlayerControlTipViewTypeFinished];
                }
            }
                break;
            default:
                break;
        }
    }];

    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,loadingState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        TTVPlayerLoadState state = [[change valueForKey:NSKeyValueChangeNewKey] longLongValue];
        switch (state) {
            case TTVPlayerLoadStateStalled:{
                //首祯没有播放前 & 禁止loading, 则不出loading
                if(!self.playerStateStore.state.showVideoFirstFrame && self.playerStateStore.state.banLoading){
                }else{
                    [self showTipView:TTVPlayerControlTipViewTypeLoading];
                }
            }
                break;
            case TTVPlayerLoadStatePlayable:{
                [self showTipView:TTVPlayerControlTipViewTypeNone];
            }
                break;
            case TTVPlayerLoadStateUnknown:

                break;
            default:
                break;
        }
    }];

    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,showVideoFirstFrame) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        BOOL beginPlay = [[change valueForKey:NSKeyValueChangeNewKey] boolValue];
        if (beginPlay) {
            [self showTipView:TTVPlayerControlTipViewTypeNone];
        }
    }];

    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.isFullScreen = self.playerStateStore.state.isFullScreen;
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,resolutionState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.playerStateStore.state.resolutionState == TTVResolutionStateChanging) {
            if (!self.playerStateStore.state.enableSmothlySwitch) {
                [self showTipView:TTVPlayerControlTipViewTypeLoading];
            }
        }else if (self.playerStateStore.state.resolutionState == TTVResolutionStateEnd ||
                  self.playerStateStore.state.resolutionState == TTVResolutionStateError){
            [self showTipView:TTVPlayerControlTipViewTypeNone];
        }
    }];
    
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if ([action isKindOfClass:[TTVPlayerStateAction class]] && ([state isKindOfClass:[TTVPlayerStateModel class]] || state == nil)) {
        switch (action.actionType) {
            case TTVPlayerEventTypeRetry:
            case TTVPlayerEventTypeFinishUIReplay:{
                [self showTipView:TTVPlayerControlTipViewTypeLoading];
            }
                break;
            case TTVPlayerEventTypeEncounterError:{
                if ([action.payload isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = action.payload;
                    self.retryView.errorCode = [[dic valueForKey:@"errorCode"] integerValue];
                }else{   //加载失败时，默认errorCode
                    self.retryView.errorCode = 0;
                }
            }
                break;
            default:
                break;
        }
    }

}

- (void)setSuperViewFrame:(CGRect)superViewFrame
{
    _superViewFrame = superViewFrame;
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)updateFrame {
    CGRect frame = self.frame;
    CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
    self.retryView.frame = self.bounds;
    self.finishedView.frame = self.bounds;
    if (!CGRectEqualToRect(CGRectZero, self.superViewFrame) && !CGRectEqualToRect(CGRectNull, self.superViewFrame)) {
        self.loadingView.frame = self.superViewFrame;
        self.loadingView.center = CGPointMake(self.superViewFrame.size.width/2, self.superViewFrame.size.height/2);
    }else{
        self.loadingView.frame = self.bounds;
        self.loadingView.center = center;
    }
    self.retryView.center = center;
    self.finishedView.center = center;
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    self.loadingView.isFullScreen = isFullScreen;
    self.retryView.isFullScreen = isFullScreen;
}

- (void)showTipView:(TTVPlayerControlTipViewType)type
{
    if (self.tipType != type) {
        self.hidden = NO;
        self.playerStateStore.state.tipType = type;
        self.tipType = type;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}

- (void)ttv_refreshType:(TTVPlayerControlTipViewType)type
{
    //加载中
    if (TTVPlayerControlTipViewTypeLoading == type) {
        self.loadingView.userInteractionEnabled = NO;
        self.userInteractionEnabled = NO;
    }else{
        self.loadingView.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
    }
    if (type == TTVPlayerControlTipViewTypeLoading) {
        NSString *tipText = ([TTVPlayerFreeFlowTipStatusManager shouldShowFreeFlowLoadingTip]) ? @"免流量加载中": nil;
        if (!self.playerStateStore.state.forbidLoadingAnimtaion) {
            [self.loadingView startLoading:tipText];
        }
        self.retryView.hidden = YES;
        self.finishedView.hidden = YES;
        self.hidden = NO;
    }
    //加载失败重新加载
    else if (type == TTVPlayerControlTipViewTypeRetry) {
        self.retryView.hidden = NO;
        self.userInteractionEnabled = YES;
        self.finishedView.hidden = YES;
        [self.loadingView stopLoading];
        self.hidden = NO;
    }
    //播放中
    else if (type == TTVPlayerControlTipViewTypeNone) {
        [self.loadingView stopLoading];
        self.hidden = YES;
        self.retryView.hidden = YES;
        self.finishedView.hidden = YES;
    }
    //播放结束
    else if (type == TTVPlayerControlTipViewTypeFinished) {
        [self.showFinishedViewDisposable dispose];
        @weakify(self);
        self.showFinishedViewDisposable = [[[[[[RACSignal return:@YES] delay:0.01]
                                              concat:RACObserve(self.playerStateStore.state, pasterFadeAnimationExecuting)]
                                             ignore:@YES]
                                            take:1]
                                           subscribeNext:^(id x) {
                                               @strongify(self);
                                               [self.loadingView stopLoading];
                                               if (self.playerStateStore.state.playerModel.disableFinishUIShow) {
                                                   self.finishedView.hidden = YES;
                                                   return ;
                                               }
                                               self.retryView.hidden = YES;
                                               self.finishedView.hidden = NO;
                                               [self.playerStateStore sendAction:TTVPlayerEventTypeFinishUIShow payload:nil];
                                               self.hidden = NO;
                                           }];
    }
}

- (void)setTipType:(TTVPlayerControlTipViewType)tipType
{
    if (tipType != _tipType) {
        _tipType = tipType;
        [self ttv_refreshType:tipType];
    }
}

@end

