//
//  TTVideoVolumeService.m
//  Article
//
//  Created by liuty on 2017/1/9.
//
//

#import "TTVideoVolumeService.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TTPlayerVolumeView.h"
#import "TTSettingsManager.h"

@interface TTVideoVolumeService () 

@property (nonatomic, strong) MPVolumeView *systemVolumeView;
@property (nonatomic, strong) TTPlayerVolumeView *customVolumeView;

@property (nonatomic, assign) CGFloat preVolume;
@property (nonatomic, assign) CGFloat changedBySystemVolumeButton;
@property (nonatomic, assign) BOOL volumeViewDisabled;

@end

@implementation TTVideoVolumeService

- (void)dealloc {
    [_systemVolumeView removeFromSuperview];
    _systemVolumeView = nil;
    [_customVolumeView removeFromSuperview];
    _customVolumeView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _preVolume = -1;
        _changedBySystemVolumeButton = YES;
        
        [[TTUIResponderHelper mainWindow] addSubview:self.systemVolumeView];
        [[TTUIResponderHelper mainWindow] addSubview:self.customVolumeView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
        
        [self _buildConstraints];
    }
    return self;
}

#pragma mark -
#pragma mark public methods

- (void)updateVolumeValue:(CGFloat)value {
    self.changedBySystemVolumeButton = NO;
    
    value = ceilf(value / 0.0625f) * 0.0625f; // 0.0625是音量实体按键调节一次的值
    
    // iOS 11下如果频繁设置volumeSlider的值会导致机器崩溃，所以这里做一个频控
    if (_preVolume < 0) {
        _preVolume = value;
    } else {
        if (_preVolume == value) return;
        _preVolume = value;
    }
    
    UISlider *volumeViewSlider = [self _volumeSlider];
    //value from 0 to 1
    [volumeViewSlider setValue:value animated:NO];
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)updateVolumeValueWithoutTipsShow:(CGFloat)value {
    self.volumeViewDisabled = YES;
    
    [self updateVolumeValue:value];
}

- (CGFloat)currentVolume {
    UISlider *volumeViewSlider = [self _volumeSlider];
    return volumeViewSlider.value;
}

- (void)showAnimated:(BOOL)animated {
    [self.customVolumeView.layer removeAllAnimations];
    
    [[TTUIResponderHelper mainWindow] bringSubviewToFront:self.customVolumeView];
    
    [self.customVolumeView showAnimated:animated];
}

- (void)dismissAnimated:(BOOL)animated {
    [self.customVolumeView.layer removeAllAnimations];
    
    [self.customVolumeView dismissAnimated:animated];
}

- (void)dismiss {
    [self dismissAnimated:YES];
}

- (void)rotate:(CGAffineTransform)rotation {
    [self.customVolumeView.layer removeAllAnimations];
    
    [self.customVolumeView.superview bringSubviewToFront:self.customVolumeView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.customVolumeView.transform = rotation;
                     } completion:^(BOOL finished) {
                     }];
}

#pragma mark -
#pragma mark private methods

- (void)_buildConstraints {
    [self.customVolumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.customVolumeView.superview);
        make.size.mas_equalTo(CGSizeMake(155.0f, 155.0f));
    }];
}

- (UISlider *)_volumeSlider {
    UISlider *volumeViewSlider = nil;
    for (UIView *view in self.systemVolumeView.subviews) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    return volumeViewSlider;
}

- (void)_volumeChanged:(NSNotification *)noti {
    NSString *reasonKey = @"AVSystemController_AudioVolumeChangeReasonNotificationParameter";
    NSString *reason = noti.userInfo[reasonKey];
    if (![reason isEqualToString:@"ExplicitVolumeChange"]) {
        // 如果不是音量变化引起的通知，直接return (该通知可能被category_change, route_change等事件触发)
        return;
    }
        
    NSString *volumeKey = @"AVSystemController_AudioVolumeNotificationParameter";
    float volume = [noti.userInfo[volumeKey] floatValue];
    [self.customVolumeView updateVolumeValue:volume];
    
    if (self.volumeDidChange) {
        self.volumeDidChange(volume, self.changedBySystemVolumeButton, !self.volumeViewDisabled);
    }
    
    self.changedBySystemVolumeButton = YES;
    self.volumeViewDisabled = NO;
}

#pragma mark -
#pragma mark getters

- (MPVolumeView *)systemVolumeView {
    if (!_systemVolumeView) {
        _systemVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, 0, 0)];
    }
    return _systemVolumeView;
}

- (TTPlayerVolumeView *)customVolumeView {
    if (!_customVolumeView) {
        _customVolumeView = [[TTPlayerVolumeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 155.0f, 155.0f)];
        _customVolumeView.alpha = 0.0f;
    }
    return _customVolumeView;
}

@end
