//
//  TTVPlayerTipAdFinished.m
//  Article
//
//  Created by panxiang on 2017/5/25.
//
//

#import "TTVPlayerTipAdFinished.h"

#import "SSThemed.h"
#import "TTImageView.h"
#import <StoreKit/StoreKit.h>

#import "UIViewController+TTMovieUtil.h"
#import "TTAdManager.h"
#import "TTURLTracker.h"

#import "TTVPlayerStateStore.h"
#import "KVOController.h"

static const CGFloat kAvatarWidth = 44;
static const CGFloat kPadding1 = 6;
static const CGFloat kPadding2 = 20;

@interface TTVPlayerTipAdFinished ()
@end

@implementation TTVPlayerTipAdFinished


- (void)dealloc
{
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backView = [[UIView alloc] init];
        UIColor *color = [UIColor tt_defaultColorForKey:kColorBackground15];
        _backView.backgroundColor = [color colorWithAlphaComponent:0.8];
        [self addSubview:_backView];
        _logoImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, kAvatarWidth, kAvatarWidth)];
        _logoImageView.userInteractionEnabled = YES;
        _logoImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _logoImageView.backgroundColorThemeKey = kColorBackground1;
        _logoImageView.layer.cornerRadius = kAvatarWidth / 2;
        _logoImageView.layer.masksToBounds = YES;
        [_backView addSubview:_logoImageView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLogoImageViewTapped)];
        [_logoImageView addGestureRecognizer:tapGesture];
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_backView addSubview:_titleLabel];
    }
    return self;
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
    __weak typeof(self) wself = self;
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        self.isFullScreen = self.playerStateStore.state.isFullScreen;
    }];
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if ([action isKindOfClass:[TTVPlayerStateAction class]] && ([state isKindOfClass:[TTVPlayerStateModel class]] || state == nil)) {
        switch (action.actionType) {
            case TTVPlayerEventTypeFinishUIReplay:{
                
            }
                break;
            case TTVPlayerEventTypeFinished:
            case TTVPlayerEventTypeFinishedBecauseUserStopped:{
                if (!self.playerStateStore.state.playerModel.isLoopPlay) {
                    self.hidden = NO;
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    _backView.frame = self.bounds;
    CGFloat totalH = kAvatarWidth + kPadding1 + _titleLabel.height + kPadding2 + [self onGetActionBtn].height;
    _logoImageView.top = (self.height - totalH) / 2;
    _logoImageView.centerX = self.width / 2;
    _titleLabel.top = _logoImageView.bottom + kPadding1;
    _titleLabel.centerX = self.width / 2;
    [self onGetActionBtn].top = _titleLabel.bottom + kPadding2;
    [self onGetActionBtn].centerX = self.width / 2;
    [super layoutSubviews];
}

- (void)onLogoImageViewTapped
{
    
}

- (UIView *)onGetActionBtn
{
    return nil;
}

- (SSThemedLabel *)placeholderViewWithTitle:(NSString *)title {
    NSString *firstName = @"";
    if (title.length >= 1) {
        firstName = [title substringToIndex:1];
    }
    SSThemedLabel *view = [[SSThemedLabel alloc] init];
    view.text = firstName;
    view.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:19]];
    view.textColor = [UIColor tt_defaultColorForKey:kColorText12];
    [view sizeToFit];
    return view;
}


@end
