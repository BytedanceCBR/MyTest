//
//  VideoRepinView.m
//  Video
//
//  Created by 于 天航 on 12-8-9.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoRepinView.h"
#import "VideoListView.h"
#import "SSTitleBarView.h"
#import "VideoTitleBarButton.h"
#import "VideoTitleLabel.h"
#import "UIColorAdditions.h"
#import "ListDataHeader.h"

#define TrackFavoriteTabEventName @"favorite_tab"

@interface VideoRepinView ()

@property (nonatomic, retain) SSTitleBarView *titleBar;
@property (nonatomic, retain) VideoListView *listView;

@end


@implementation VideoRepinView

@synthesize titleBar = _titleBar;
@synthesize listView = _listView;

- (void)dealloc
{
    self.titleBar = nil;
    self.listView = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadView];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    CGRect vFrame = self.bounds;
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
    [self addSubview:_titleBar];

    VideoTitleBarButton *backButton = [VideoTitleBarButton buttonWithType:VideoTitleBarButtonTypeLeftBack];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBar setLeftView:backButton];

    VideoTitleBarButton *synchronizeButton = [VideoTitleBarButton buttonWithType:VideoTitleBarButtonTypeRightNormalNarrow];
    [synchronizeButton setTitle:@"同 步" forState:UIControlStateNormal];
    [synchronizeButton addTarget:self action:@selector(synchronizeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBar setRightView:synchronizeButton];
    
    VideoTitleLabel *titleLabel = [[[VideoTitleLabel alloc] init] autorelease];
    titleLabel.text = @"我的收藏";
    [titleLabel sizeToFit];
    [_titleBar setCenterView:titleLabel];
    
    tmpFrame.origin.y = CGRectGetMaxY(_titleBar.frame);
    tmpFrame.size.height = vFrame.size.height - _titleBar.frame.size.height;
    
    self.listView = [[[VideoListView alloc] initWithFrame:tmpFrame
                                                      condition:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [NSNumber numberWithInt:ListDataTypeVideo], kListDataTypeKey,
                                                                 [NSNumber numberWithInt:DataSortTypeFavorite], kListDataConditionSortTypeKey,
                                                                 nil]] autorelease];
    _listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _listView.trackEventName = TrackFavoriteTabEventName;
    [self addSubview:_listView];
}

- (void)didAppear
{
    [super didAppear];
    [_listView didAppear];
}

#pragma mark - Actions

- (void)backButtonClicked:(id)sender
{
    UIViewController *topViewController = [SSCommon topViewControllerFor:self];
    [topViewController.navigationController popViewControllerAnimated:YES];
}

- (void)synchronizeButtonClicked:(id)sender
{
    [_listView refresh];
    
    trackEvent([SSCommon appName], TrackFavoriteTabEventName, @"fav_sync");
}

@end

