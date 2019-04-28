//
//  TTVHalfDemoViewController.m
//  TTVPlayer_Example
//
//  Created by panxiang on 2019/4/11.
//  Copyright © 2019 pxx914. All rights reserved.
//

#import "TTVHalfDemoViewController.h"
#import "TTVPlayer.h"
#import <UIViewAdditions.h>
#import <TTVPlayer.h>
#import <TTVPlayer+Engine.h>
#import <Masonry/Masonry.h>
#import <TTVPlayerPod/TTVPlayerBottomToolBar.h>
//#import <TTVSpeedPart.h>
//#import <TTVConfiguredControlPart.h>

@interface TTVHalfDemoViewController ()<TTVPlayerDelegate,TTVReduxStateObserver, TTVPlayerCustomPartDelegate>
@property (nonatomic, strong) TTVPlayer * player;
@end

@implementation TTVHalfDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 44, 80, 40);
    [self.view addSubview:button];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.player.view];
    _player.videoTitle = @"五分钟告诉你,谁是通货膨胀的受害者和受益者五分钟告诉你,谁是通货膨胀的受害者和受益者五分钟告诉你,谁是通货膨胀的受害者和受益者";
    [self.player setVideoID:@"f860a7b9d56c4af3980f01db5fa13343" host:@"is.snssdk.com" commonParameters:nil];
    self.player.view.frame = CGRectMake(0, 100, 375,210);
    [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@100);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@210);
    }];
//    self.player.view.backgroundColor = [UIColor whiteColor];
//    self.player.view.center = CGPointMake(self.view.width / 2.0, self.player.view.centerY);
    [self.player.playerStore subscribe:self];
//    [self.player play];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (TTVPlayer *)player {
    if (!_player) {
//        _player = [[TTVPlayer alloc] initWithOwnPlayer:YES configFileName:@"TTVPlayerStyle.plist"];
        _player = [[TTVPlayer alloc] initWithOwnPlayer:YES style:TTVPlayerStyle_Simple_CanRotate];
        _player.delegate = self;
//        _player.customPartDelegate = self;
    }
    return _player;
}

#pragma mark - TTVPlayerDelegate
// control layout的代理
- (void)playerViewDidLayoutSubviews:(TTVPlayer *)player state:(TTVPlayerState *)state {
   
//    BOOL fullScreen = state.fullScreenState.fullScreen;
//    CGRectEdge leftEdge = fullScreen ? 20 : 12;
//    CGRectEdge topEdge = 12;
//
//    TTVPlayerBottomToolBar *topBar = (TTVPlayerBottomToolBar *)[player partControlForKey:TTVPlayerPartControlKey_TopBar];
//    topBar.width = topBar.superview.width;
//    topBar.height = fullScreen ? 130 : 70;
//    topBar.left = 0;
//    topBar.top = 0;
//
//    UIView * defaultBackButton = [player partControlForKey:TTVPlayerPartControlKey_BackButton];
//    UIView * defaultTitleLable = [player partControlForKey:TTVPlayerPartControlKey_TitleLabel];
//    [defaultTitleLable sizeToFit];
//
    UIView * playCenter = [player partControlForKey:TTVPlayerPartControlKey_PlayCenterToggledButton];
//    [playCenter sizeToFit];
//    playCenter.center = CGPointMake(player.view.width / 2.0, player.view.height / 2.0);
//
//    if (fullScreen) {
//        defaultBackButton.size = CGSizeMake(24, 24);
//        defaultBackButton.top = 32;
//        defaultBackButton.left = 12;
//        defaultTitleLable.frame = CGRectMake(defaultBackButton.right, 0, player.view.width - 2 * leftEdge, defaultTitleLable.height);
//        defaultTitleLable.centerY = defaultBackButton.centerY;
//    }else{
//        defaultTitleLable.frame = CGRectMake(leftEdge, topEdge, player.view.width - 2 * leftEdge, defaultTitleLable.height);
//    }
//
//    UIEdgeInsets safeInset = UIEdgeInsetsZero;
//    if (@available(iOS 11.0, *)) {
//        if (fullScreen) {
//            safeInset = [[[UIApplication sharedApplication] delegate] window].safeAreaInsets;
//        }
//    }
//
//    UIView *toolbar = [player partControlForKey:TTVPlayerPartControlKey_BottomBar];
//    toolbar.width = player.view.width;
//    toolbar.height = fullScreen ? 130 : 70;
//    toolbar.left = 0;
//    toolbar.bottom = player.view.height;
//
//    UIView *currentTimeLabel = [player partControlForKey:TTVPlayerPartControlKey_TimeCurrentLabel];
//    UIView *slider = [player partControlForKey:TTVPlayerPartControlKey_Slider];
//    UIView *totalTimeLabel = [player partControlForKey:TTVPlayerPartControlKey_TimeTotalLabel];
//    UIView *fullScreenBtn = [player partControlForKey:TTVPlayerPartControlKey_FullToggledButton];
//    //只有进度条 ，全屏功能的时候
//    [currentTimeLabel sizeToFit];
//    currentTimeLabel.left = leftEdge;
//    currentTimeLabel.centerY = (toolbar.height - safeInset.bottom - (fullScreen ? 25.5 : 16));
//
//    NSInteger right = 0;
//    fullScreenBtn.hidden = fullScreen == YES;
//    if (fullScreenBtn && !fullScreenBtn.hidden) {
//        fullScreenBtn.width = 32;
//        fullScreenBtn.height = 32;
//        fullScreenBtn.right = toolbar.width - 10;
//        fullScreenBtn.centerY = currentTimeLabel.centerY;
//        right = fullScreenBtn.left;
//    }else{
//        right = player.view.width - leftEdge;
//    }
//
//    [totalTimeLabel sizeToFit];
//    totalTimeLabel.right = right - 10;
//    totalTimeLabel.centerY = currentTimeLabel.centerY;
//
//    NSInteger sliderEdge = 8;
//    slider.width = totalTimeLabel.left - sliderEdge * 2 - currentTimeLabel.right;
//    slider.height = 12;
//    slider.left = currentTimeLabel.right + sliderEdge;
//    slider.centerY = currentTimeLabel.centerY;
    
    // speed
    UIView * speed = [player partControlForKey:TTVPlayerPartControlKey_SpeedChangeButton];
    speed.width = 100;
    speed.height = 40;
    speed.center = playCenter.center;
    speed.centerX -= 80;
}

- (void)stateDidChangedToNew:(NSObject<TTVReduxStateProtocol> *)newState lastState:(NSObject<TTVReduxStateProtocol> *)lastState store:(NSObject<TTVReduxStoreProtocol> *)store {
    
    TTVFullScreenState *lastFullScreenState = ((TTVPlayerState*)lastState).fullScreenState;
    TTVFullScreenState *newFullScreenState = ((TTVPlayerState*)newState).fullScreenState;
    if (newFullScreenState.fullScreen != lastFullScreenState.fullScreen) {
        [UIApplication sharedApplication].statusBarHidden = !newFullScreenState.fullScreen;
    }

}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//- (NSObject<TTVPlayerPartProtocol> *)customPartForKey:(TTVPlayerPartKey)key {
//    if (key == TTVPlayerPartKey_Speed) {
//        TTVConfiguredControlPart * part = [[TTVConfiguredControlPart alloc] initWithPart:[[TTVSpeedPart alloc] init]];
//        return part;
//    }
//    return nil;
//}
//
//- (NSArray<NSNumber *> *)additionalPartKeysWhenInitForMode:(TTVPlayerDisplayMode)mode {
//    if (mode == TTVPlayerDisplayMode_Fullscreen) {
//        return @[@(TTVPlayerPartKey_Speed)];
//    }
//    return nil;
//}


@end
