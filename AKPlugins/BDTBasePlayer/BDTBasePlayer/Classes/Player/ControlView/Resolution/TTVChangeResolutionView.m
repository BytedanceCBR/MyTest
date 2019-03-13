//
//  TTVChangeResolutionView.m
//  TTVideoEngine
//
//  Created by panxiang on 2017/11/14.
//

#import "TTVChangeResolutionView.h"
#import "NSObject+FBKVOController.h"
#import "TTDeviceUIUtils.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import "TTVResolutionStore.h"

@interface TTVChangeResolutionView()
@property (nonatomic, strong) UIView *backgroudView;
@property (nonatomic, strong) UIButton *backgroudViewButton;
@property (nonatomic, strong) UILabel *alertText;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *changeButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) CGRect superViewFrame;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation TTVChangeResolutionView
- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _backgroudView = [[UIView alloc] init];
        _backgroudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _backgroudView.clipsToBounds = YES;
        [self addSubview:_backgroudView];
        
        _alertText = [[UILabel alloc] init];
        _alertText.backgroundColor = [UIColor clearColor];
        _alertText.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _alertText.textColor = [UIColor whiteColor];
        _alertText.textAlignment = NSTextAlignmentCenter;
        _alertText.text = @"网络卡，切换标清更流畅";
        _alertText.numberOfLines = 1;
        [_alertText sizeToFit];
        [_backgroudView addSubview:_alertText];
        
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [_backgroudView addSubview:_lineView];
        
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeButton.backgroundColor = [UIColor clearColor];
        [_changeButton addTarget:self action:@selector(changeResolution) forControlEvents:UIControlEventTouchUpInside];
        [_changeButton setTitle:@"立即切换" forState:UIControlStateNormal];
        [_changeButton setTitleColor:[UIColor colorWithRed:248.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1] forState:UIControlStateNormal];
        _changeButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        [_changeButton sizeToFit];
        [_backgroudView addSubview:_changeButton];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8.f, -8.f, -8.f, -8.f);
        [_closeButton setImage:[UIImage imageNamed:@"player_resolution_alert_close.png"] forState:UIControlStateNormal];
        _closeButton.backgroundColor = [UIColor clearColor];
        [_closeButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton sizeToFit];
        
        _backgroudViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backgroudViewButton.backgroundColor = [UIColor clearColor];
        [_backgroudViewButton addTarget:self action:@selector(changeResolution) forControlEvents:UIControlEventTouchUpInside];
        [_backgroudView addSubview:_backgroudViewButton];
        [_backgroudView addSubview:_closeButton];
    }
    return self;
}

- (void)changeResolution
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@([[self.playerStateStore.state minResolution] integerValue]) forKey:@"resolution_type"];
    [dic setValue:@(YES) forKey:@"is_auto_switch"];
    [dic setValue:@(YES) forKey:@"disable_clarity_auto_select_tracker"];
    [TTVResolutionStore sharedInstance].resolutionAlertClick = YES;
    [TTVResolutionStore sharedInstance].autoResolution = [[self.playerStateStore.state minResolution] integerValue];
    [self.playerStateStore sendAction:TTVPlayerEventTypeSwitchResolution payload:dic];
    [self.playerStateStore sendAction:TTVPlayerEventTypePlaybackChangeToLowResolutionClick payload:dic];
    self.hidden = YES;
}

- (void)dismissSelf
{
    self.alpha = 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.alpha = 1;
        self.hidden = YES;
    }];
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,toolBarState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        switch (self.playerStateStore.state.toolBarState) {
            case TTVPlayerControlViewToolBarStateWillShow:
                [self layoutSelfWithTop:self.superViewFrame.size.height - self.frame.size.height - 32];
                break;
            case TTVPlayerControlViewToolBarStateWillHidden:
                [self layoutSelfWithTop:self.superViewFrame.size.height - self.frame.size.height - 8];
                break;
            default:
                break;
        }
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self layoutWithSuperViewFrame:self.superViewFrame];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,playbackState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.playerStateStore.state == TTVVideoPlaybackStateFinished ||
            self.playerStateStore.state == TTVVideoPlaybackStateBreak ||
            self.playerStateStore.state == TTVVideoPlaybackStateError) {
            [self hiddenSelf];
        }
    }];
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if (![action isKindOfClass:[TTVPlayerStateAction class]] || ![state isKindOfClass:[TTVPlayerStateModel class]]) {
        return;
    }
    switch (action.actionType) {
        case TTVPlayerEventTypePlaybackChangeToLowResolutionShow:{
            self.hidden = NO;
        }
            break;
        case TTVPlayerEventTypeFinished:
        case TTVPlayerEventTypeEncounterError:{
            self.hidden = YES;
        }
            break;
        default:
            break;
    }
}

- (NSInteger)leftSpace
{
    if ([TTDeviceHelper isIPhoneXDevice] && self.playerStateStore.state.isFullScreen) {
        return 15 + 32;
    }
    return 15;
}

- (void)layoutSelfWithTop:(NSInteger)top
{
    if (self.playerStateStore.state.isFullScreen) {
        self.frame = CGRectMake([self leftSpace], top, CGRectGetMaxX(_closeButton.frame) + CGRectGetHeight(_backgroudView.frame) / 2.0, 32);
    }else{
        self.frame = CGRectMake([self leftSpace], top, CGRectGetMaxX(_closeButton.frame) + CGRectGetHeight(_backgroudView.frame) / 2.0, 32);
    }
    self.center = CGPointMake(self.superViewFrame.size.width / 2.0, self.center.y);
    _backgroudView.frame = self.bounds;
    _backgroudViewButton.frame = CGRectMake(0, 0, self.changeButton.left, self.backgroudView.height);
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    self.playerStateStore.state.resolutionAlertShowed = !hidden;
    __unused __strong typeof(self) strongSelf = self;
    if (self.timer) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenSelf) object:nil];
        [self.timer invalidate];
        self.timer = nil;
    }
    if (!hidden) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hiddenSelf) userInfo:nil repeats:NO];
    }
}

- (void)hiddenSelf
{    
    self.hidden = YES;
}

- (void)layoutWithSuperViewFrame:(CGRect)superViewFrame
{
    self.superViewFrame = superViewFrame;
    self.frame = CGRectMake([self leftSpace], superViewFrame.size.height - 8, 275, 32);
    _backgroudView.frame = self.bounds;
    _backgroudView.layer.cornerRadius = CGRectGetHeight(_backgroudView.frame) / 2.0;
    _alertText.frame = CGRectMake(CGRectGetHeight(_backgroudView.frame) / 2.0, 0, CGRectGetWidth(_alertText.frame), CGRectGetHeight(_backgroudView.frame));
    NSInteger lineViewHeight = 4;
    _lineView.frame = CGRectMake(CGRectGetMaxX(_alertText.frame) + 12, (CGRectGetHeight(_backgroudView.frame) - lineViewHeight) / 2.0, 1.0/[UIScreen mainScreen].scale, lineViewHeight);
    _changeButton.frame = CGRectMake(CGRectGetMaxX(_lineView.frame) + 12, 0, CGRectGetWidth(_changeButton.frame), CGRectGetHeight(_backgroudView.frame));
    _closeButton.frame = CGRectMake(CGRectGetMaxX(_changeButton.frame) + 6, 0, CGRectGetWidth(_closeButton.frame), CGRectGetHeight(_backgroudView.frame));
    switch (self.playerStateStore.state.toolBarState) {
        case TTVPlayerControlViewToolBarStateDidShow:
            [self layoutSelfWithTop:self.superViewFrame.size.height - CGRectGetHeight(self.frame) - 32];
            break;
        case TTVPlayerControlViewToolBarStateDidHidden:
            [self layoutSelfWithTop:self.superViewFrame.size.height - CGRectGetHeight(self.frame) - 8];
            break;
        default:
            [self layoutSelfWithTop:self.superViewFrame.size.height - 40];
            break;
    }
}
@end

