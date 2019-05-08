//
//  TTVChangeResolutionAlertView.m
//  TTVideoEngine
//
//  Created by panxiang on 2017/11/15.
//

#import "TTVChangeResolutionAlertView.h"
#import "NSObject+FBKVOController.h"
#import "TTDeviceUIUtils.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import "TTVResolutionStore.h"

@interface TTVChangeResolutionAlertView()
@property (nonatomic, strong) UIView *backgroudView;
@property (nonatomic, strong) UILabel *alertText;
@property (nonatomic, assign) CGRect superViewFrame;
@end

@implementation TTVChangeResolutionAlertView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        _backgroudView = [[UIView alloc] init];
        _backgroudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _backgroudView.clipsToBounds = YES;
        [self addSubview:_backgroudView];
        
        _alertText = [[UILabel alloc] init];
        _alertText.backgroundColor = [UIColor clearColor];
        _alertText.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _alertText.textColor = [UIColor whiteColor];
        _alertText.textAlignment = NSTextAlignmentCenter;
        _alertText.numberOfLines = 1;
        [_alertText sizeToFit];
        [_backgroudView addSubview:_alertText];
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

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(id)state {
    if (![action isKindOfClass:[TTVPlayerStateAction class]]) {
        return;
    }
    
    if ([action isKindOfClass:[TTVPlayerStateAction class]]) {
        switch (action.actionType) {
            case TTVPlayerEventTypeSwitchResolution:
            {
                NSDictionary *dic = action.payload;
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    return;
                }
                if (!self.playerStateStore.state.enableSmothlySwitch){
                    return;
                }
                TTVPlayerResolutionType type = (TTVPlayerResolutionType)[[dic valueForKey:@"resolution_type"] integerValue];
                if (type != TTVPlayerResolutionTypeAuto && [TTVResolutionStore sharedInstance].userSelected) {
                    self.hidden = NO;
                }
                
                NSDictionary *attributeDict = @{NSFontAttributeName : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]],
                                                NSForegroundColorAttributeName:[UIColor whiteColor]
                                                };
                NSString *resolution = [TTVPlayerStateModel typeStringForType:type];
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"正在切换至%@，请稍后...",resolution] attributes:attributeDict];
                [string addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]],
                                        NSForegroundColorAttributeName:[UIColor colorWithRed:248.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1]
                                        } range:NSMakeRange(5, resolution.length)];
                _alertText.attributedText = string;
                [_alertText sizeToFit];
                [self layoutWithSuperViewFrame:self.superViewFrame];
                break;
            }
            default:
                break;
        }
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
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,resolutionState) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (self.playerStateStore.state.resolutionState == TTVResolutionStateChanging) {
            self.hidden = NO;
        }else if (self.playerStateStore.state.resolutionState == TTVResolutionStateEnd || self.playerStateStore.state.resolutionState == TTVResolutionStateError){
            
            NSDictionary *attributeDict = @{NSFontAttributeName : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]],
                                            NSForegroundColorAttributeName:[UIColor whiteColor]
                                            };
            NSString *resolution = [TTVPlayerStateModel typeStringForType:self.playerStateStore.state.currentResolution];
            NSMutableAttributedString *string = nil;
            if (self.playerStateStore.state.resolutionState == TTVResolutionStateError) {
                string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"清晰度切换失败，请重试"] attributes:attributeDict];
            }else{
                string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"您已切换到%@",resolution] attributes:attributeDict];
                [string addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]],
                                        NSForegroundColorAttributeName:[UIColor colorWithRed:248.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1]
                                        } range:NSMakeRange(5, resolution.length)];
            }
            _alertText.attributedText = string;
            [_alertText sizeToFit];
            [self layoutWithSuperViewFrame:self.superViewFrame];
            
            [UIView animateWithDuration:0.25 delay:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                self.alpha = 1;
                self.hidden = YES;
            }];
        }
    }];
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
    self.frame = CGRectMake([self leftSpace], top, CGRectGetMaxX(_alertText.frame) + CGRectGetHeight(_backgroudView.frame) / 2.0, 32);
    _backgroudView.frame = self.bounds;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    self.playerStateStore.state.resolutionAlertShowed = !hidden;
}

- (void)layoutWithSuperViewFrame:(CGRect)superViewFrame
{
    self.superViewFrame = superViewFrame;
    self.frame = CGRectMake([self leftSpace], superViewFrame.size.height - 8, 275, 32);
    _backgroudView.frame = self.bounds;
    _backgroudView.layer.cornerRadius = CGRectGetHeight(_backgroudView.frame) / 2.0;
    _alertText.frame = CGRectMake(CGRectGetHeight(_backgroudView.frame) / 2.0, 0, CGRectGetWidth(_alertText.frame), CGRectGetHeight(_backgroudView.frame));
    NSInteger lineViewHeight = 4;
    switch (self.playerStateStore.state.toolBarState) {
        case TTVPlayerControlViewToolBarStateDidShow:
            [self layoutSelfWithTop:self.superViewFrame.size.height - CGRectGetHeight(self.frame) - 32];
            break;
        case TTVPlayerControlViewToolBarStateDidHidden:
            [self layoutSelfWithTop:self.superViewFrame.size.height - CGRectGetHeight(self.frame) - 8];
            break;
        default:
            [self layoutSelfWithTop:self.superViewFrame.size.height - CGRectGetHeight(self.frame) - 8];
            break;
    }
}

@end


