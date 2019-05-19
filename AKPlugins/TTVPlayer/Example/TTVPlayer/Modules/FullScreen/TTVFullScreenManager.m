//
//  TTVFullScreenManager.m
//  Article
//
//  Created by panxiang on 2018/8/24.
//

#import "TTVFullScreenManager.h"
#import "TTPlayerFullScreenController.h"
#import "TTVPlayerStateFullScreenPrivate.h"
#import "UIView+TTVPlayerSortPriority.h"
#import "UIView+TTVViewKey.h"

@interface TTVFullScreenManager()
@property (nonatomic ,strong)TTPlayerFullScreenController *fullScreenController;
@property (nonatomic, strong) UIButton *fullButton;
@property (nonatomic, strong) UIButton *fullbackButton;
@end

@implementation TTVFullScreenManager
@synthesize store = _store;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_fullScreenController endMonitor];
    _fullScreenController.enableFullScreen = NO;
    _fullScreenController.supportsPortaitFullScreen = NO;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}


- (void)registerPartWithStore:(TTVPlayerStore *)store
{
    if (store == self.store) {

        if (!self.fullScreenController) {
            self.fullScreenController = [[TTPlayerFullScreenController alloc] initWithPlayerView:self.store.player.playerView inViewController:self.store.player];
            self.fullScreenController.enableFullScreen = NO;
            [self.fullScreenController beginMonitor];
        }
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVPlayerActionTypeRotatePlayer]) {
                NSDictionary *info = action.info;
                void(^completeBlock)(BOOL finish) = info[@"complete_block"];
                NSNumber *fullscreen = info[@"full_screen"];
                NSNumber *animated = info[@"animated"];
                [self setFullScreen:[fullscreen isKindOfClass:[NSNumber class]] ? [fullscreen boolValue] : NO animated:[animated isKindOfClass:[NSNumber class]] ? [animated boolValue] : YES completion:completeBlock ? completeBlock : ^void(BOOL isFinish){
                    
                }];
            }
        }];
        [self ttv_bindsObserve];
        if (!self.fullButton) {
            self.fullButton = [self createFullButton];
        }
        if (!self.fullbackButton) {
            self.fullbackButton = [self createFullbackButton];
        }
        if (self.fullButton) {
            [self.store.player.controlView.containerView.bottomView.noFullScreenRightContainerView addView:self.fullButton];
        }
        if (self.fullbackButton) {
            [self.store.player.controlView.containerView.topView.leftViewsContainerView addView:self.fullbackButton];
        }
        
        [self ttvl_observer];
    }
}

- (void)ttvl_observer
{
    //绑定 按钮图片 和 fullScreen 属性
    @weakify(self);
    [RACObserve(self.store.state.fullScreen, isFullScreen) subscribeNext:^(NSNumber *fullScreen) {
        @strongify(self);
        self.fullbackButton.hidden = !self.store.state.fullScreen.isFullScreen;
        self.fullButton.hidden = self.store.state.fullScreen.isFullScreen;
        [self.fullButton setBackgroundImage:[UIImage imageNamed:[fullScreen boolValue] ? @"shrink_video" : @"enlarge_video"] forState:UIControlStateNormal];
        [self.fullButton sizeToFit];
        [self.store.player.controlView.containerView setNeedsLayout];
    }];
}

#pragma mark - create func

- (UIButton *)createFullButton {
    UIButton *fullButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fullButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -8, -20, -30);
    [fullButton setImage:[UIImage imageNamed:@"enlarge_video"] forState:UIControlStateNormal];
    fullButton.exclusiveTouch = YES;
    [fullButton addTarget:self action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    fullButton.ttvPlayerSortContainerPriority = 0;
    fullButton.ttvPlayerLayoutViewKey = TTVFullScreenManager_fullButton;
    return fullButton;
}

- (UIButton *)createFullbackButton {
    UIButton *fullbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fullbackButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    [fullbackButton setImage:[UIImage imageNamed:@"player_back"] forState:UIControlStateNormal];
    [fullbackButton sizeToFit];
    [fullbackButton addTarget:self action:@selector(fullbackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    fullbackButton.ttvPlayerSortContainerPriority = 0;
    fullbackButton.ttvPlayerLayoutViewKey = TTVFullScreenManager_fullbackButton;
    return fullbackButton;
}

#pragma mark - set & get

- (void)setFullButton:(UIButton *)fullButton
{
    if (_fullButton != fullButton) {
        [_fullButton removeFromSuperview];
        _fullButton = fullButton;
        [self.store.player.controlView addSubview:_fullButton];
    }
}

- (void)customFullButton:(UIButton *)fullButton
{
    self.fullButton = fullButton;
}

#pragma mark - action

- (void)fullbackButtonClicked:(UIButton *)button {
    [self _setFullScreen:NO];
}

- (void)fullScreenButtonClicked:(UIButton *)button
{
    [self _setFullScreen:!self.store.state.fullScreen.isFullScreen];
}

- (void)ttv_bindsObserve {
    RAC(self.store.state.fullScreen, isFullScreen) = RACObserve(self.fullScreenController, fullScreen);
    RAC(self.store.state.fullScreen, supportsPortaitFullScreen) = RACObserve(self.fullScreenController, supportsPortaitFullScreen);
    RAC(self.store.state.fullScreen, isTransitioning) = RACObserve(self.fullScreenController, isTransitioning);
}

//- (void)ttv_observerFullScreen
//{
//    @weakify(self);
//    [[RACObserve(self.fullScreenController, fullScreen) skip:1] subscribeNext:^(id  _Nullable x) {
//        @strongify(self);
//        if ([x isKindOfClass:[NSNumber class]]) {
//            self.store.state.fullScreen.isFullScreen = [x boolValue];
//        }
//    }];
//
//}


- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    //note：iOS8、9下全屏状态从后台回来，会导致方向错误；iOS10下偶尔会导致导航栏高度不对，所以在退到后台时主动退出全屏
    if (self.store.state.fullScreen.isFullScreen) {
        [self.fullScreenController setFullScreen:NO animated:NO];
    }
    //在iPhoneX下，视频全屏播放设备竖屏下进入后台再进入应用，应用View的safeAreaInsets的left和right值变成44，导致整个应用UI异常，在这里重设状态栏为竖向，就可以在每次应用进入前台时重置应用界面的safeAreaInsets
    if ([TTDeviceHelper isIPhoneXSeries]) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    }
}

#pragma mark - util

- (void)_setFullScreen:(BOOL)fullscreen {
    //全屏状态和目前需要设置的一致时返回
    if (self.store.state.fullScreen.isFullScreen == fullscreen) {
        return;
    }
    [self setFullScreen:fullscreen animated:YES completion:^(BOOL finished) {
        
    }];
}

- (void)setFullScreen:(BOOL)fullScreen animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    [self.fullScreenController setFullScreen:fullScreen animated:animated completion:completion];
}

- (void)setSupportsPortaitFullScreen:(BOOL)supportsPortaitFullScreen
{
    self.store.state.fullScreen.supportsPortaitFullScreen = supportsPortaitFullScreen;
    self.fullScreenController.supportsPortaitFullScreen = supportsPortaitFullScreen;
}

@end


@implementation TTVPlayer (FullScreenManager)

- (TTVFullScreenManager *)fullScreenManager;
{
    return nil;

//    return [self partManagerFromClass:[TTVFullScreenManager class]];
}

@end
