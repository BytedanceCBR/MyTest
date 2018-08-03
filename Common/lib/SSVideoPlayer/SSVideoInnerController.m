//
//  SSVideoInnerController.m
//  Video
//
//  Created by Tianhang Yu on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSVideoInnerController.h"
#import "SSSimpleCache.h"
#import "UIImage+TTThemeExtension.h"
 
#import "TTThemeManager.h"

#define TrackFullscreenTabEventName @"fullscreen_tab"

@interface SSVideoInnerController ()
@property (nonatomic, retain) SSVideoModel *video;
@property(nonatomic, retain)UIButton * backButton;
@property(nonatomic, retain)UIView * nightModelCoverView;
@end

@implementation SSVideoInnerController

@synthesize video = _video;
@synthesize backButton = _backButton;
@synthesize delegate = _delegate;
@synthesize nightModelCoverView = _nightModelCoverView;

- (void)dealloc
{
    self.nightModelCoverView = nil;
    self.delegate = nil;
    self.backButton = nil;
    self.video = nil;
    self.playerView = nil;
}

- (id)initWithPlayer:(SSVideoPlayerView *)playerView
{
    self = [super init];
    if (self) {
        self.playerView = playerView;

    }
    return self;
}

// for iOS6
- (BOOL)shouldAutorotate
{
    return YES;
}

// for pre iOS5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
        return currentOrientation;
    }
    else {
        return UIInterfaceOrientationLandscapeRight;
    }
}

#pragma mark - View Lifecycle

- (void)loadView
{
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = contentView;
    
//    NSLog(@"ssVideoInnerController contentView%@", contentView);
    
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _playerView.controlViewPositionType = SSVideoPlayerViewControlViewInnerBottom;
    
    if ([_playerView superclass]) {
        [_playerView removeFromSuperview];
    }
    [self.view addSubview:_playerView];

    self.view.backgroundColor = [UIColor blackColor];
    
    self.video = _playerView.video;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setBackgroundImage:[UIImage themedImageNamed:@"backbtn_player.png"] forState:UIControlStateNormal];
    [_backButton setBackgroundImage:[UIImage themedImageNamed:@"backbtn_player_press.png"] forState:UIControlStateHighlighted];
    [_backButton setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    [_backButton.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
    [_backButton sizeToFit];
    [_backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    self.nightModelCoverView = [[UIView alloc] initWithFrame:self.view.bounds];
    _nightModelCoverView.frame = self.view.bounds;
    _nightModelCoverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _nightModelCoverView.userInteractionEnabled = NO;
    _nightModelCoverView.backgroundColor = [UIColor blackColor];
    _nightModelCoverView.alpha = ([[TTThemeManager sharedInstance_tt] currentThemeMode] != TTThemeModeNight) ? 0.f : 0.5f;
    [self.view addSubview:_nightModelCoverView];

}

- (void)refreshUI
{
    _playerView.frame = self.view.bounds;
    _backButton.frame = CGRectMake(0, 0, _backButton.frame.size.width, _backButton.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _playerView.frame = self.view.bounds;
    [_playerView refreshUI];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    ssTrackEvent(TrackFullscreenTabEventName, @"enter");
    
    
    if (_needDismiss) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self refreshUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)goBack:(id)sender
{
    if ([_delegate respondsToSelector:@selector(videoPlayControllerBackButtonClicked:)]) {
        [_delegate performSelector:@selector(videoPlayControllerBackButtonClicked:) withObject:self];
    }
}

#pragma mark -- notification target

//- (void)themeChanged:(NSNotification*)notification
//{
//}


@end
