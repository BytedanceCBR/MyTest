//
//  TTVVolumeManager.m
//  Article
//
//  Created by zhengjiacheng on 2018/8/30.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Aspects/Aspects.h>
#import "TTVVolumeManager.h"
#import "TTVCustomVolumeView.h"
#import "TTVFullScreenVolumeView.h"
#import "TTVBrightnessManager.h"

@interface TTVVolumeManager()
@property (nonatomic, strong) MPVolumeView *systemVolumeView;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) float currentVolume;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, strong) TTVCustomVolumeView *customVolumeView;
@property (nonatomic, strong) TTVFullScreenVolumeView *fullScreenVolumeView;
@property (nonatomic, assign) BOOL hideStatusBarManual;
@property (nonatomic, assign) BOOL hideStatusBarWhenVolumeViewShow; // 表示音量视图show时是否在外界隐藏了状态栏
@property (nonatomic, weak) UIViewController *originVCL;
@end

@implementation TTVVolumeManager

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)shared{
    static TTVVolumeManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTVVolumeManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
        [self buildObserve];
        //fix 当音量键设置为调整铃声音量时，无法隐藏系统音量条
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    return self;
}

- (void)buildObserve{
    WeakSelf;
    [[RACObserve(self, currentVolume) throttle:0.8] subscribeNext:^(NSNumber *progress) {
        StrongSelf;
        [self dismissVolumeView];
    }];
    
    // 在这里hook，目的是防止外部隐藏了statusBar，而内部又在dismiss后展示statusBar
    [[UIApplication sharedApplication] aspect_hookSelector:@selector(setStatusBarHidden:withAnimation:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, BOOL hidden, UIStatusBarAnimation animation) {
        StrongSelf;
        if (hidden && self.hideStatusBarManual) {
            self.hideStatusBarManual = NO;
        }
    } error:nil];
}

- (void)enableCustomVolumeView:(BOOL)enable{
    _enableCustomVolumeView = enable;
    [self.systemVolumeView removeFromSuperview];
    if (enable) {
        [[TTUIResponderHelper mainWindow] addSubview:self.systemVolumeView];
        self.currentVolume = [AVAudioSession sharedInstance].outputVolume;
    } else {
        [self dismissVolumeView:0];
    }
}

- (void)enableFullScreen:(BOOL)fullScreen {
    _fullScreen = fullScreen;
    if (fullScreen) {
        _customVolumeView.hidden = YES;
        _fullScreenVolumeView.hidden = NO;
    } else {
        _customVolumeView.hidden = NO;
        _fullScreenVolumeView.hidden = YES;
    }
}

- (void)updateVolumeValue:(CGFloat)value {
    value = ceilf(value / 0.0625f) * 0.0625f; // 0.0625是音量实体按键调节一次的值
    
    // 当小于0后UISlider的setValue:会无效，主动调用一次展示方法使界面展示出来
    if (value <= 0) {
        [self showCustomVolumeView:0];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissVolumeView) object:nil];
        [self performSelector:@selector(dismissVolumeView) withObject:nil afterDelay:0.8];
    }
}

- (void)showCustomVolumeView:(CGFloat)newValue{
    [self hideStatusBarIfNeed];
    [self hookTopControllerViewWillDisappear:[TTUIResponderHelper visibleTopViewController]];
    // 优先展示音量，在这里让亮度视图消失
    if ([TTVBrightnessManager shared].isShowing) {
        [[TTVBrightnessManager shared] dismissBrightnessView:0];
    }
    
    if (self.fullScreen) {
        [self.fullScreenVolumeView showWithCurrentVolume:self.currentVolume newVolume:newValue];
    } else {
        [self.customVolumeView showWithStyle:[self getCurrentVolumeViewStyle] currentVolume:self.currentVolume newVolume:newValue];
    }
    self.isShowing = YES;
}

- (void)dismissVolumeView {
    if (!self.enableCustomVolumeView) {
        return;
    }
    [self dismissVolumeView:0.3];
    [self showStatusBarIfNeed];
    self.originVCL = nil;
}

- (void)dismissVolumeView:(CGFloat)duration{
    if (!self.isShowing) {
        return;
    }
    WeakSelf;
    if (_fullScreenVolumeView) {
        [self.fullScreenVolumeView dismissWithDuration:duration completion:^{
            StrongSelf;
            self.fullScreenVolumeView = nil;
            self.isShowing = NO;
        }];
    }
    if (_customVolumeView) {
        [self.customVolumeView dismissWithDuration:duration completion:^{
            StrongSelf;
            self.customVolumeView = nil;
            self.isShowing = NO;
        }];
    }
}

- (void)showStatusBarIfNeed {
    // 当状态栏最初显示 且 音量调节视图展示时外界没有隐藏状态栏时，才重新展示状态栏
    if (self.hideStatusBarManual && !self.hideStatusBarWhenVolumeViewShow) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    self.hideStatusBarManual = NO;
    self.hideStatusBarWhenVolumeViewShow = NO;
}

- (void)hideStatusBarIfNeed{
    TTVCustomVolumeStyle style = [self getCurrentVolumeViewStyle];
    if (self.hideStatusBarManual || [UIApplication sharedApplication].isStatusBarHidden) {
        return;
    }
    if (style != TTVCustomVolumeStyleLight ) {
        return;
    }
    //如果是light样式 && 没有hidden，则先隐藏statusbar，在willdisappear 时重置回去
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.hideStatusBarManual = YES;
}

- (void)hookTopControllerViewWillDisappear:(UIViewController *)topController{
    if (![topController isKindOfClass:[UIViewController class]]) {
        return;
    }
    if (self.originVCL == topController) {
        return;
    }
    self.originVCL = topController;
    
    UIStatusBarStyle statusbarStyle = [UIApplication sharedApplication].statusBarStyle;
    WeakSelf;
    [self.originVCL aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated){
        StrongSelf;
        if (!self.enableCustomVolumeView) {
            return;
        }
        [self dismissVolumeView:0];
        if (self.hideStatusBarManual) {
            [[UIApplication sharedApplication] setStatusBarStyle:statusbarStyle];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            self.hideStatusBarManual = NO;
        }
    } error:nil];
}

- (TTVCustomVolumeStyle)getCurrentVolumeViewStyle{
    UIStatusBarStyle statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    TTVCustomVolumeStyle volumeStyle = statusBarStyle == UIStatusBarStyleDefault ? TTVCustomVolumeStyleDefault : TTVCustomVolumeStyleLight;
    if ([UIApplication sharedApplication].isStatusBarHidden) {
        volumeStyle = TTVCustomVolumeStyleLight;
    }
    return volumeStyle;
}

#pragma mark - notification
- (void)volumeChanged:(NSNotification *)notification{
    if (!self.enableCustomVolumeView) {
        return;
    }
    
    NSString *reasonKey = @"AVSystemController_AudioVolumeChangeReasonNotificationParameter";
    NSString *reason = notification.userInfo[reasonKey];
    if (![reason isEqualToString:@"ExplicitVolumeChange"]) {
        // 如果不是音量变化引起的通知，直接return (该通知可能被category_change, route_change等事件触发)
        return;
    }
    
    float new = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    [self showCustomVolumeView:new];
    self.currentVolume = new;
}

#pragma mark - getter
- (MPVolumeView *)systemVolumeView {
    if (!_systemVolumeView) {
        _systemVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, 0, 0)];
    }
    return _systemVolumeView;
}

- (TTVCustomVolumeView *)customVolumeView{
    if (!_customVolumeView) {
        _customVolumeView = [[TTVCustomVolumeView alloc]init];
    }
    return _customVolumeView;
}

- (TTVFullScreenVolumeView *)fullScreenVolumeView {
    if (!_fullScreenVolumeView) {
        _fullScreenVolumeView = [[TTVFullScreenVolumeView alloc] init];
    }
    return _fullScreenVolumeView;
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

@end
