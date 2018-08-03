//
//  VideoDetailViewController.m
//  Video
//
//  Created by Tianhang Yu on 12-7-20.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "VideoDetailView.h"

@interface VideoDetailViewController ()

@property (nonatomic, retain) VideoDetailView *detailView;

@end


@implementation VideoDetailViewController

@synthesize video = _video;
@synthesize detailView = _detailView;

- (void)dealloc
{
    self.video = nil;
    self.detailView = nil;
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.video = nil;
    self.detailView = nil;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    UIView *contentView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    self.view = contentView;
    
    CGRect vFrame = self.view.bounds;
    CGRect tmpFrame = vFrame;
    
    self.detailView = [[[VideoDetailView alloc] initWithFrame:tmpFrame video:_video] autorelease];
    [self.view addSubview:_detailView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_detailView didAppear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_detailView didDisappear];
}

@end


