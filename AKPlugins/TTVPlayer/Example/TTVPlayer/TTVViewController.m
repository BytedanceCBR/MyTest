//
//  TTVViewController.m
//  TTVPlayer
//
//  Created by pxx914 on 12/12/2018.
//  Copyright (c) 2018 pxx914. All rights reserved.
//

#import "TTVViewController.h"
#import "TTVReplayDemoViewController.h"
#import "TTVHalfDemoViewController.h"
#import <UIViewAdditions.h>

@interface TTVViewController ()
@property (nonatomic, strong)UIButton * button;
@property (nonatomic, strong)UIButton * halfButton;

@end

@implementation TTVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *half = [UIButton buttonWithType:UIButtonTypeCustom];
    [half setTitle:@"HALF" forState:UIControlStateNormal];
    [half setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    half.frame = CGRectMake(0, 0, 100, 60);
    [half addTarget:self action:@selector(half) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:half];
    self.halfButton = half;
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitle:@"FULL" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.button.frame = CGRectMake(0, 0, 100, 60);
    [self.button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)click {
    TTVReplayDemoViewController * vc = [[TTVReplayDemoViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)half
{
    TTVHalfDemoViewController * vc = [[TTVHalfDemoViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewWillLayoutSubviews {
    self.button.center = CGPointMake(self.view.width/2.0, self.view.height/2.0);
    self.button.top += 100;
    
    self.halfButton.center = CGPointMake(self.view.width/2.0, self.view.height/2.0);
    self.halfButton.top -= 100;
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
