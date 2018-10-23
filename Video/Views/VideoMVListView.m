//
//  VideoListView.m
//  Video
//
//  Created by 于 天航 on 12-8-2.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoMVListView.h"
#import "VideoListView.h"
#import "SSTitleBarView.h"
#import "VideoTitleBarButton.h"
#import "SSSegmentControl.h"
#import "VideoTitleBarSegment.h"
#import "UIColorAdditions.h"
#import "ListDataHeader.h"

#define TitleSegmentControlWidth 2*SSUIFloatNoDefault(@"vuTitleBarSegmentWidth")
#define TrackVideoTabEventName @"video_tab"

@interface VideoMVListView () <SSSegmentControlDelegate>

@property (nonatomic, retain) SSTitleBarView *titleBar;
@property (nonatomic, retain) VideoListView *listView;
@property (nonatomic, retain) SSSegmentControl *titleSegmentControl;
@property (nonatomic, retain) NSArray *segments;

@property (nonatomic, retain) VideoListView *recentListView;
@property (nonatomic, retain) VideoListView *topListView;

@end


@implementation VideoMVListView

@synthesize titleBar = _titleBar;
@synthesize listView = _listView;
@synthesize titleSegmentControl = _titleSegmentControl;
@synthesize segments = _segments;

@synthesize recentListView = _recentListView;
@synthesize topListView = _topListView;

- (void)dealloc
{
    self.titleBar = nil;
    self.listView = nil;
    self.titleSegmentControl = nil;
    self.segments = nil;

    self.recentListView = nil;
    self.topListView = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        VideoTitleBarSegment *recentSegment = [VideoTitleBarSegment buttonWithType:UIButtonTypeCustom];
        [recentSegment setTitle:@"新鲜" forState:UIControlStateNormal];
        
        VideoTitleBarSegment *topSegment = [VideoTitleBarSegment buttonWithType:UIButtonTypeCustom];
        [topSegment setTitle:@"热门" forState:UIControlStateNormal];
        
        self.segments = [NSArray arrayWithObjects:recentSegment, topSegment, nil];

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
//    [_titleBar showBottomShadow];
    [self addSubview:_titleBar];
    
    tmpFrame.origin.y = CGRectGetMaxY(_titleBar.frame);
    tmpFrame.size.height = vFrame.size.height - _titleBar.frame.size.height;

    self.recentListView = [[[VideoListView alloc] initWithFrame:tmpFrame
                                                      condition:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [NSNumber numberWithInt:ListDataTypeVideo], kListDataTypeKey,
                                                                 [NSNumber numberWithInt:DataSortTypeRecent], kListDataConditionSortTypeKey,
                                                                 nil]] autorelease];
    _recentListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _recentListView.backgroundColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuBackgroundColor")];
    _recentListView.trackEventName = TrackVideoTabEventName;

    self.topListView = [[[VideoListView alloc] initWithFrame:tmpFrame
                                                   condition:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [NSNumber numberWithInt:ListDataTypeVideo], kListDataTypeKey,
                                                              [NSNumber numberWithInt:DataSortTypeHot], kListDataConditionSortTypeKey,
                                                              nil]] autorelease];
    _topListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _topListView.backgroundColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuBackgroundColor")];
    _topListView.trackEventName = TrackVideoTabEventName;
    
    if ([self.subviews containsObject:_listView]) {
        [_listView removeFromSuperview];
    }

    self.listView = _recentListView;
    [self addSubview:_listView];

    self.titleSegmentControl = [[[SSSegmentControl alloc] initWithFrame:CGRectMake(0,
                                                                                   0,
                                                                                   TitleSegmentControlWidth,
                                                                                   _titleBar.bounds.size.height)
                                                                   type:SSSegmentControlTypeSlide] autorelease];
    _titleSegmentControl.delegate = self;
    _titleSegmentControl.segments = _segments;
    _titleSegmentControl.slideImage = [UIImage imageNamed:@"change.png"];
    [_titleBar setCenterView:_titleSegmentControl];
    
    VideoTitleBarButton *refreshButton = [VideoTitleBarButton buttonWithType:VideoTitleBarButtonTypeRefresh];
    [refreshButton addTarget:self action:@selector(refreshButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBar setRightView:refreshButton];
    
    [self bringSubviewToFront:_titleBar];
}

- (void)didAppear   // will not be invoke in viewController's viewWillAppear method
{
	[super didAppear];
    [_listView didAppear];
    
    trackEvent([SSCommon appName], TrackVideoTabEventName, @"enter");
}

#pragma mark - Actions

- (void)refreshButtonClicked:(id)sender
{
    [_listView refresh];
    trackEvent([SSCommon appName], TrackVideoTabEventName, @"refresh_button");
}


#pragma mark - SSSegmentControl

- (void)ssSegmentControl:(SSSegmentControl *)ssSegmentControl didSelectAtIndex:(NSInteger)index
{
    if ([self.subviews containsObject:_listView]) {
        [_listView removeFromSuperview];
    }

    switch (index) {
        case 0:
        {
            self.listView = _recentListView;
            [self addSubview:_listView];
            
            trackEvent([SSCommon appName], TrackVideoTabEventName, @"new_tab");
        }
            break;
        case 1:
        {
            self.listView = _topListView;
            [self addSubview:_listView];
            
            trackEvent([SSCommon appName], TrackVideoTabEventName, @"hot_tab");
        }
            break;
        default:
            break;
    }
    
    [_listView didAppear];
    [self sendSubviewToBack:_listView];
}

@end

