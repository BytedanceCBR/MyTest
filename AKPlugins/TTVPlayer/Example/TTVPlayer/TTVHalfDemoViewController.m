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
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTVPlayerTokenManager.h"


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
    
    UIView * containerView = [UIView new];
    [self.view addSubview:containerView];
    containerView.frame = CGRectMake(10, 100, self.view.width-20, self.view.width*9/16.0);
    
    UIView * c2 = [UIView new];
    [containerView addSubview:c2];
    c2.frame = containerView.bounds;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:self.player];
    [c2 addSubview:self.player.view];

    _player.videoTitle = @"五分钟告诉你,谁是通货膨胀的受害者和受益者五分钟告诉你,谁是通货膨胀的受害者和受益者五分钟告诉你,谁是通货膨胀的受害者和受益者";
    [self.player setVideoID:@"v02031400000bhvlhtg2sajc474op28g" host:@"is.snssdk.com" commonParameters:nil];
    [self.player setPlayAuthToken:nil authToken:@"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTcyNTIyMDMsInZlciI6InYxIiwiYWsiOiI1Y2UxNmY1YWFmMTU0NjE4OTUyMDc2ZjM2ODEwMDVmNSIsInN1YiI6InBnY19sZWFybmluZ19lbmNyeXB0In0.Ke7ZE8Py6WZVMUiGeVXSOJr2vjIUH-T9Uxg6fw5LB7s" businessToken:@"HMAC-SHA1:2.0:1557252203303112495:5ce16f5aaf154618952076f3681005f5:W0N5/Q+Q8wtdwT5Fnl5KKT9JquI="];
    self.player.view.frame = c2.bounds;//CGRectMake(0, 100, 375,210);//;
  
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
        _player = [[TTVPlayer alloc] initWithOwnPlayer:YES configFileName:@"TTVPlayerStyle.plist"];
//        _player = [[TTVPlayer alloc] initWithOwnPlayer:YES style:TTVPlayerStyle_Simple_CanRotate];
        _player.delegate = self;
//        _player.customPartDelegate = self;
    }
    return _player;
}

#pragma mark - TTVPlayerDelegate
// control layout的代理
- (void)playerViewDidLayoutSubviews:(TTVPlayer *)player state:(TTVPlayerState *)state {
   
    BOOL fullScreen = state.fullScreenState.fullScreen;
    CGRectEdge leftEdge = fullScreen ? 20 : 12;
    CGRectEdge topEdge = 12;

    TTVPlayerBottomToolBar *topBar = (TTVPlayerBottomToolBar *)[player partControlForKey:TTVPlayerPartControlKey_TopBar];
    topBar.width = topBar.superview.width;
    topBar.height = fullScreen ? 130 : 70;
    topBar.left = 0;
    topBar.top = 0;

    UIView * defaultBackButton = [player partControlForKey:TTVPlayerPartControlKey_BackButton];
    UIView * defaultTitleLable = [player partControlForKey:TTVPlayerPartControlKey_TitleLabel];
    [defaultTitleLable sizeToFit];
//
    UIView * playCenter = [player partControlForKey:TTVPlayerPartControlKey_PlayCenterToggledButton];
    [playCenter sizeToFit];
    playCenter.center = CGPointMake(player.view.width / 2.0, player.view.height / 2.0);

    if (fullScreen) {
        defaultBackButton.size = CGSizeMake(24, 24);
        defaultBackButton.top = 32;
        defaultBackButton.left = 12;
        defaultTitleLable.frame = CGRectMake(defaultBackButton.right, 0, player.view.width - 2 * leftEdge, defaultTitleLable.height);
        defaultTitleLable.centerY = defaultBackButton.centerY;
    }else{
        defaultTitleLable.frame = CGRectMake(leftEdge, topEdge, player.view.width - 2 * leftEdge, defaultTitleLable.height);
    }

    UIEdgeInsets safeInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        if (fullScreen) {
            safeInset = [[[UIApplication sharedApplication] delegate] window].safeAreaInsets;
        }
    }

    UIView *toolbar = [player partControlForKey:TTVPlayerPartControlKey_BottomBar];
    toolbar.width = player.view.width;
    toolbar.height = fullScreen ? 130 : 70;
    toolbar.left = 0;
    toolbar.bottom = player.view.height;

    UIView * speed = [player partControlForKey:TTVPlayerPartControlKey_SpeedChangeButton];
    BOOL isSimple = YES;
    CGFloat centerY = (toolbar.height - safeInset.bottom - (fullScreen ? 24 : 19));
    if (speed) {
        isSimple = NO;
        centerY = (toolbar.height - safeInset.bottom - (fullScreen ? 56 : 19));
    }
    UIView *currentTimeLabel = [player partControlForKey:TTVPlayerPartControlKey_TimeCurrentLabel];
    UIView *slider = [player partControlForKey:TTVPlayerPartControlKey_Slider];
    UIView *totalTimeLabel = [player partControlForKey:TTVPlayerPartControlKey_TimeTotalLabel];
    UIView *fullScreenBtn = [player partControlForKey:TTVPlayerPartControlKey_FullToggledButton];
    
    //只有进度条 ，全屏功能的时候  , 半屏的时候
    [currentTimeLabel sizeToFit];
    currentTimeLabel.left = leftEdge;
    currentTimeLabel.centerY = centerY;
    
    fullScreenBtn.hidden = fullScreen == YES;
    NSInteger right = 0;
    if (fullScreenBtn && !fullScreenBtn.hidden) {
        fullScreenBtn.width = 32;
        fullScreenBtn.height = 32;
        fullScreenBtn.right = toolbar.width - 10;
        fullScreenBtn.centerY = currentTimeLabel.centerY;
        right = fullScreenBtn.left;
    }else{
        right = player.view.width - leftEdge;
    }
    
    [totalTimeLabel sizeToFit];
    totalTimeLabel.right = right - 10;
    totalTimeLabel.centerY = currentTimeLabel.centerY;
    
    NSInteger sliderEdge = 8;
    slider.width = totalTimeLabel.left - sliderEdge * 2 - currentTimeLabel.right;
    slider.height = 12;
    slider.left = currentTimeLabel.right + sliderEdge;
    slider.centerY = currentTimeLabel.centerY;
    
    UIView * playBottom = [player partControlForKey:TTVPlayerPartControlKey_PlayBottomToggledButton];
    UIView * currentAndTotal = [player partControlForKey:TTVPlayerPartControlKey_TimeCurrentAndTotalLabel];
    
    [playBottom sizeToFit];

    //有复杂功能 ,倍数 ,高清的时候.重新布局
    if (fullScreen && !isSimple) {
        currentTimeLabel.hidden = YES;
        totalTimeLabel.hidden = YES;
        playCenter.hidden = YES;
        
        slider.width = self.player.view.width - leftEdge * 2;
        slider.left = leftEdge;
        
        CGFloat centerSpeedY = slider.bottom + (toolbar.height - slider.bottom) / 2.0;

        [playBottom sizeToFit];
        playBottom.hidden = NO;
        playBottom.left = slider.left - 11;
        playBottom.centerY = centerSpeedY;
        
        [currentAndTotal sizeToFit];
        currentAndTotal.left = playBottom.right + 30;
        currentAndTotal.width = MAX(120, currentTimeLabel.width);
        currentAndTotal.height = MAX(15, currentTimeLabel.height);
        currentAndTotal.centerY = centerSpeedY;
        
        // speed
        CGRect rect = [slider.superview convertRect:slider.frame toView:self.player.view];
        [speed sizeToFit];
        speed.width = speed.width;
        speed.height = 34;
        speed.right = slider.right;
        speed.centerY = (self.player.view.height - CGRectGetMaxY(rect)) / 2.0 + CGRectGetMaxY(rect);
    }else{
        currentTimeLabel.hidden = NO;
        totalTimeLabel.hidden = NO;
        playCenter.hidden = NO;
        playBottom.hidden = YES;
    }
    
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

- (NSString *)playerV2URL:(TTVPlayer *)player path:(NSString *)path
{
    return [[TTNetworkManager shareInstance] getBestHostFromTTNet:@"/vod/get_play_info"];
}

- (void)player:(TTVPlayer *)player requestPlayTokenCompletion:(void (^ __nullable)(NSError *error, NSString *authToken, NSString *bizToken))completion
{
    //短视频
    [TTVPlayerTokenManager requestPlayTokenWithVideoID:player.videoID completion:^(NSError *error, NSString *authToken, NSString *bizToken) {
        if (completion) {
            completion(error ,authToken ,bizToken);
        }
    }];
    //长视频
}
@end