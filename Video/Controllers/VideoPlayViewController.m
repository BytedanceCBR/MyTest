//
//  VideoPlayViewController.m
//  Video
//
//  Created by Tianhang Yu on 12-7-19.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoPlayViewController.h"
#import "VideoPlayerView.h"
#import "ShareOneHelper.h"
#import "FastShareMenuController.h"
#import "SSSimpleCache.h"
#import "VideoData.h"

#define TrackFullscreenTabEventName @"fullscreen_tab"

@interface VideoPlayViewController ()
@property (nonatomic, retain) VideoData *video;
@end

@implementation VideoPlayViewController

- (void)dealloc
{
    self.video = nil;
    self.playerView = nil;
    [super dealloc];
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

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIInterfaceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
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
    UIView *contentView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_playerView];
    
    self.video = _playerView.video;
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
    trackEvent([SSCommon appName], TrackFullscreenTabEventName, @"enter");
    
    
    if (_needDismiss) {
        if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self dismissModalViewControllerAnimated:YES];
        }
        NSLog(@"unit appear:%@", self);
    }
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

@end









