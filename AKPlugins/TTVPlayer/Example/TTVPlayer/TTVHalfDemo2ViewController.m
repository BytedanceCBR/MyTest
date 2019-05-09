//
//  TTVHalfDemo2ViewController.m
//  TTVPlayer_Example
//
//  Created by 谢思铭 on 2019/5/5.
//  Copyright © 2019 pxx914. All rights reserved.
//

#import "TTVHalfDemo2ViewController.h"
#import "FHVideoViewController.h"
#import <UIViewAdditions.h>

@interface TTVHalfDemo2ViewController ()

@property(nonatomic, strong) FHVideoViewController *videoVC;

@end

@implementation TTVHalfDemo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 44, 80, 40);
    [self.view addSubview:button];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initVideoVC];
    
    UIView * testRotateView = [UIView new];
    testRotateView.frame = CGRectMake(70, self.videoVC.view.bottom+50, 100, 100);
    testRotateView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:testRotateView];
}

- (void)initVideoVC {
    self.videoVC = [[FHVideoViewController alloc] init];
    _videoVC.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_videoVC.view];
    _videoVC.view.frame = CGRectMake(0, 100, self.view.width, self.view.width*9/16.0);
    [self.videoVC updateData];
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
