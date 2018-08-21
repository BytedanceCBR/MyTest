//
//  VideoRepinViewController.m
//  Video
//
//  Created by 于 天航 on 12-8-9.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoRepinViewController.h"
#import "VideoRepinView.h"

@interface VideoRepinViewController ()

@property (nonatomic, retain) VideoRepinView *repinView;

@end


@implementation VideoRepinViewController

@synthesize repinView = _repinView;

- (void)dealloc
{
    self.repinView = nil;
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.repinView = nil;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    UIView *contentView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    self.view = contentView;
    
    CGRect vFrame = self.view.bounds;
    CGRect tmpFrame = vFrame;
    
    self.repinView = [[[VideoRepinView alloc] initWithFrame:tmpFrame] autorelease];
    [self.view addSubview:_repinView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_repinView didAppear];
}

@end