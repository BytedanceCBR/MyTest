//
//  RecommendViewController.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "VideoRecommendViewController.h"
#import "UIColorAdditions.h"
#import "AppCompModel.h"
#import "SSPageControl.h"
#import "SSTitleBarView.h"
#import "VideoTitleBarButton.h"
#import "VideoTitleLabel.h"

#define UMENG_EVENT_NAME @"recommend"

@interface VideoRecommendViewController () <RecommendViewDelegate>

@property (nonatomic, retain) SSTitleBarView *titleBar;

@end


@implementation VideoRecommendViewController

@synthesize recomView = _recomView;
@synthesize titleBar = _titleBar;

- (void)dealloc
{
    self.recomView = nil;
    self.titleBar = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.recomView = nil;
    self.titleBar = nil;
}

#pragma mark - View Lifecycles

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[[UIView alloc] initWithFrame:applicationFrame] autorelease];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = contentView;
    
    CGRect vFrame = self.view.bounds;
    CGRect tmpFrame = vFrame;
    tmpFrame.size.height = SSUIFloatNoDefault(@"vuTitleBarHeight");
    
    self.titleBar = [[[SSTitleBarView alloc] initWithFrame:tmpFrame orientation:self.interfaceOrientation] autorelease];
    _titleBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _titleBar.titleBarEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIImage *portraitBackgroundImage = [UIImage imageNamed:@"titlebarbg.png"];
    portraitBackgroundImage = [portraitBackgroundImage stretchableImageWithLeftCapWidth:portraitBackgroundImage.size.width/2
                                                                           topCapHeight:1.f];
    UIImageView *portraitBackgroundView = [[[UIImageView alloc] initWithImage:portraitBackgroundImage] autorelease];
    portraitBackgroundView.frame = _titleBar.bounds;
    _titleBar.portraitBackgroundView = portraitBackgroundView;
    [self.view addSubview:_titleBar];
    
    VideoTitleBarButton *backButton = [VideoTitleBarButton buttonWithType:VideoTitleBarButtonTypeLeftBack];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBar setLeftView:backButton];
    
    VideoTitleLabel *titleLabel = [[[VideoTitleLabel alloc] init] autorelease];
    titleLabel.text = @"应用推荐";
    [titleLabel sizeToFit];
    [_titleBar setCenterView:titleLabel];

    tmpFrame.origin.y = CGRectGetMaxY(_titleBar.frame);
    tmpFrame.size.height = vFrame.size.height - _titleBar.frame.size.height;

    self.recomView = [[[RecommendView alloc] initWithFrame:tmpFrame] autorelease];
    _recomView.umengEvent = UMENG_EVENT_NAME;
    _recomView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    _recomView.delegate = self;
    [self.view addSubview:_recomView];
    
    [self.recomView.pageFlowView.pageControl setBackgroundImage:[UIImage imageNamed:@"pagebg.png"] forState:SSPageControlStateNormal];
    [self.recomView.pageFlowView.pageControl setBackgroundImage:[UIImage imageNamed:@"pagebg_selected.png"] forState:SSPageControlStateHighlighted];
    [self.recomView.pageFlowView.pageControl setTextColor:[UIColor colorWithHexString:@"#ffffff"] forState:SSPageControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_recomView willAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_recomView didAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_recomView willDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_recomView didDisappear];
}

#pragma mark - Actions

- (void)backButtonClicked:(id)sender
{
    UIViewController *topViewController = [SSCommon topViewControllerFor:self.view];
    [topViewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RecommendViewDelegate

- (void)componentDidSelected:(AppCompModel *)comp
{
    switch (comp.actionType) {
        case ComponentActionTypeDownload:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[comp.actionURLs objectAtIndex:0]]];    
        }
            break;
        case ComponentActionTypeAPI:
            break;
        case ComponentActionTypeAPIList:
            break;
        default:
            break;
    }
}

@end
