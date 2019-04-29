//
//  TTVReplayDemoViewController.m
//  TTVPlayer_Example
//
//  Created by lisa on 2019/2/14.
//  Copyright © 2019 pxx914. All rights reserved.
//

#import "TTVReplayDemoViewController.h"
#import <TTVPlayerKitHeader.h>
#import <Masonry/Masonry.h>
#import <UIViewAdditions.h>
#import <TTVPlayer+Engine.h>
#import <TTVPlayer+BecomeResignActive.h>
#import <TTVLoadingPart.h>
#import <TTVLPlayerLoadingView.h>


@interface TTVReplayDemoViewController () <TTVPlayerDelegate, TTVPlayerCustomPartDelegate>

@property (nonatomic, strong) TTVPlayer * player;

@end

@implementation TTVReplayDemoViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"我是按钮" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.center = CGPointMake(self.view.width/2.0, 150);
//    [self.view addSubview:button];
    
    [self.view addSubview:self.player.view];
    _player.videoTitle = @"五分钟告诉你,谁是通货膨胀的受害者和受益者";//f860a7b9d56c4af3980f01db5fa13343
    [self.player setVideoID:@"f860a7b9d56c4af3980f01db5fa13343" host:@"is.snssdk.com" commonParameters:nil];
//    [self.player.playerStore subscribe:self];
//    [self.player addViewUnderPlayerControl:button];
    // 默认不展示 control，需要手动设置
//    [self.player play];
//    [self.player.containerView showControl:YES];
//    [self.player addPeriodicTimeObserverForInterval:0.2 queue:dispatch_get_main_queue() usingBlock:^{
//        NSLog(@"---");
//    }];
//    [self.player removePartForKey:TTVPlayerPartKey_Gesture];
}

- (void)onButtonClicked:(id)sender {
    Debug_NSLog(@"Bu rtton Clicked!");
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.player.view.frame = self.view.bounds;
}

#pragma mark - getters & setters
- (TTVPlayer *)player {
    if (!_player) {
        _player = [[TTVPlayer alloc] initWithOwnPlayer:YES configFileName:@"TTVPlayerStyle-EV.plist"];
//        _player = [[TTVPlayer alloc] initWithOwnPlayer:YES style:TTVPlayerStyle_Simple_NoRotate];
        _player.delegate = self;
        _player.showPlaybackControlsOnViewFirstLoaded = YES;
        _player.supportBackgroundPlayback = YES;
        _player.startPlayFromLastestCache = YES;
        _player.customPartDelegate = self;
        _player.customViewDelegate = self;
//        _player.enableNoPlaybackStatus = YES;
//        _player.supportPlaybackControlAutohide = NO;
        [_player setTitle:@"静态检测定制化"];
    }
    return _player;
}

#pragma mark - TTVPlayerDelegate
// control layout的代理
- (void)playerViewDidLayoutSubviews:(TTVPlayer *)player state:(TTVPlayerState *)state {
    
    player.playerView.frame = CGRectMake(CGRectGetMaxX(self.view.bounds) - 200*3/4.0 - 20, 30, 200, 200*3/4.0);
    
    UIView *navigationBar = [self.player partControlForKey:TTVPlayerPartControlKey_TopBar];
    navigationBar.width = self.player.controlView.width;
    navigationBar.height = 130;
    navigationBar.top = 0;
    navigationBar.left = 0;
//    [navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.equalTo(navigationBar.superview);
//        make.height.equalTo(@130);
//    }];
    
    UIView * lock = [self.player partControlForKey:TTVPlayerPartControlKey_LockToggledButton];
    [lock sizeToFit];
    
    UIView *backButton = [self.player partControlForKey:TTVPlayerPartControlKey_BackButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(@16);
        make.width.height.equalTo(@24);
    }];
    
    UIView *titleLabel = [self.player partControlForKey:TTVPlayerPartControlKey_TitleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backButton.mas_right).offset(10);
        make.centerY.equalTo(backButton);
    }];
    
    // bottom toolbar
    UIView *toolbar = [self.player partControlForKey:TTVPlayerPartControlKey_BottomBar];
    if (!toolbar) {
        return;
    }
    
    toolbar.width = self.player.controlView.width;
    toolbar.height = 130;
    toolbar.top = self.player.controlView.height - toolbar.height;
    toolbar.left = 0;
//    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(toolbar.superview);
//        make.height.equalTo(@100);
//    }];
    
    UIView * lockButton = [self.player partControlForKey:TTVPlayerPartControlKey_LockToggledButton];
    lockButton.center = self.player.view.center;
    lockButton.left = 50;
    
    UIView * bottomPlayButton = [self.player partControlForKey:TTVPlayerPartControlKey_PlayBottomToggledButton];
    if (bottomPlayButton) {
        [bottomPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(toolbar).offset(20);
            make.bottom.equalTo(toolbar).offset(-20);
            make.width.height.equalTo(@24);
        }];
        [bottomPlayButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
        UIView *currentTimeLabel = [self.player partControlForKey:TTVPlayerPartControlKey_TimeCurrentLabel];
        [currentTimeLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bottomPlayButton.mas_right).offset(20);
            make.centerY.equalTo(bottomPlayButton);
        }];
        
        UIView *slider = [self.player partControlForKey:TTVPlayerPartControlKey_Slider];
        [slider setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(currentTimeLabel.mas_right).offset(12);
            make.centerY.equalTo(bottomPlayButton);
            make.height.equalTo(@(24));// TODO, 会影响默认高度
        }];
        
        UIView *totalTimeLabel = [self.player partControlForKey:TTVPlayerPartControlKey_TimeTotalLabel];
        [totalTimeLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(slider.mas_right).offset(12);
            make.centerY.equalTo(bottomPlayButton);
            make.right.equalTo(toolbar).offset(-20);
        }];
    }

}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}


- (NSObject<TTVPlayerPartProtocol> *)customPartForKey:(TTVPlayerPartKey)key {
    if (key == TTVPlayerPartKey_Loading) {
        TTVLoadingPart *part = [[TTVLoadingPart alloc] init];
        return part;
    }
    return nil;
}

- (NSArray<NSNumber *> *)additionalPartKeysWhenInitForMode:(TTVPlayerDisplayMode)mode {
    if (mode == TTVPlayerDisplayMode_All) {
        return @[@(TTVPlayerPartKey_Loading)];
    }
    return nil;
}
- (UIView <TTVPlayerLoadingViewProtocol> *)customLoadingView {
    return [TTVLPlayerLoadingView new];
}
@end
