//
//  TTVBrightnessManager.m
//  Article
//
//  Created by mazhaoxiang on 2018/11/12.
//

#import <ReactiveObjC/ReactiveObjC.h>
#import <Aspects/Aspects.h>

#import "TTVBrightnessManager.h"
#import "TTPlayerBrightnessView.h"
#import "TTVFullScreenBrightnessView.h"
#import "TTVVolumeManager.h"

@interface TTVBrightnessManager ()

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) float currentBrightness;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, strong) TTPlayerBrightnessView *brightnessView;
@property (nonatomic, strong) TTVFullScreenBrightnessView *fullScrrenBrightnessView;
@property (nonatomic, assign) BOOL hideStatusBarManual;
@property (nonatomic, assign) BOOL hideStatusBarWhenBrightnessViewShow; // 表示亮度视图show时是否在外界隐藏了状态栏

@end

@implementation TTVBrightnessManager

- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
}

+ (instancetype)shared{
    static TTVBrightnessManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTVBrightnessManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.currentBrightness = [UIScreen mainScreen].brightness;;
        [self buildObserve];
    }
    return self;
}

- (void)buildObserve {
    WeakSelf;
    [[RACObserve(self, currentBrightness) throttle:0.8] subscribeNext:^(id  _Nullable x) {
        StrongSelf;
        [self dismissBrightnessView:0.3];
        [self showStatusBarIfNeeded];
    }];
    
    [[UIScreen mainScreen] addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionNew context:NULL];
    
    // 在这里hook，目的是防止外部隐藏了statusBar，而内部又在dismiss后展示statusBar
    [[UIApplication sharedApplication] aspect_hookSelector:@selector(setStatusBarHidden:withAnimation:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, BOOL hidden, UIStatusBarAnimation animation) {
        StrongSelf;
        if (hidden && self.hideStatusBarManual) {
            self.hideStatusBarWhenBrightnessViewShow = YES;
        }
    } error:nil];
}

- (void)enableFullScreen:(BOOL)fullScreen {
    _fullScreen = fullScreen;
    if (fullScreen) {
        _brightnessView.hidden = YES;
        _fullScrrenBrightnessView.hidden = NO;
    } else {
        _brightnessView.hidden = NO;
        _fullScrrenBrightnessView.hidden = YES;
    }
}

- (void)updateBrightnessValue:(CGFloat)value {
    CGFloat validValue = MIN(MAX(0.0f, value), 1.0f);
    
    [[UIScreen mainScreen] setBrightness:validValue];
}

- (void)showBrightnessView:(CGFloat)value {
    [self hideStatusBarIfNeeded];
    // 当音量调节视图存在时，不显示亮度调节视图
    if ([TTVVolumeManager shared].isShowing) {
        return;
    }
    CGFloat validValue = MIN(MAX(0.0f, value), 1.0f);
    if (self.fullScreen) {
        [self.fullScrrenBrightnessView showWithCurrentBrightness:self.currentBrightness newBrightness:validValue];
    } else {
        [self.brightnessView showWithCurrentBrightness:self.currentBrightness newBrightness:validValue];
    }
    self.isShowing = YES;
}

- (void)dismissBrightnessView:(CGFloat)duration {
    if (!self.isShowing) {
        return;
    }
    WeakSelf;
    if (_fullScrrenBrightnessView) {
        [self.fullScrrenBrightnessView dismissWithDuration:duration completion:^{
            StrongSelf;
            self.fullScrrenBrightnessView = nil;
            self.isShowing = NO;
        }];
    }
    if (_brightnessView) {
        [self.brightnessView dismissWithDuration:duration completion:^{
            StrongSelf;
            self.brightnessView = nil;
            self.isShowing = NO;
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGFloat value = [change[@"new"] floatValue];
    [self showBrightnessView:value];
    self.currentBrightness = value;
}

- (void)showStatusBarIfNeeded {
    // 当状态栏最初显示 且 亮度调节视图展示时外界没有隐藏状态栏时，才重新展示状态栏
    if (self.hideStatusBarManual && !self.hideStatusBarWhenBrightnessViewShow) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    self.hideStatusBarManual = NO;
    self.hideStatusBarWhenBrightnessViewShow = NO;
}

- (void)hideStatusBarIfNeeded {
    // 非全屏且非X设备
    BOOL notFullScreen = !self.fullScreen && ![TTDeviceHelper isIPhoneXSeries];
    if (self.hideStatusBarManual || [UIApplication sharedApplication].isStatusBarHidden || notFullScreen) {
        return;
    }

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.hideStatusBarManual = YES;
}

#pragma mark - Getter
- (TTPlayerBrightnessView *)brightnessView {
    if (!_brightnessView) {
        _brightnessView = [[TTPlayerBrightnessView alloc] init];
    }
    return _brightnessView;
}

- (TTVFullScreenBrightnessView *)fullScrrenBrightnessView {
    if (!_fullScrrenBrightnessView) {
        _fullScrrenBrightnessView = [[TTVFullScreenBrightnessView alloc] init];
    }
    return _fullScrrenBrightnessView;
}

@end
