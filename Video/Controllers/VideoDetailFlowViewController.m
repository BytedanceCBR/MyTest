//
//  VideoDetailFlowViewController.m
//  Video
//
//  Created by Tianhang Yu on 12-7-20.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDetailFlowViewController.h"
#import "SSPageFlowView.h"
#import "SSTitleBarView.h"
#import "SSButton.h"
#import "SSSegmentControl.h"
#import "SSSegment.h"
#import "VideoDetailUnit.h"
#import "VideoActivityIndicatorView.h"

#import "VideoListDataOperation.h"
#import "ListDataHeader.h"
#import "VideoData.h"

#define TrackDetailPageEventString @"detail"

@interface VideoDetailFlowViewController () <SSPageFlowViewDelegate, SSPageFlowViewDataSource>
{
    DataSortType _sortType;
}

@property (nonatomic, retain) SSTitleBarView *titleBar;
@property (nonatomic, retain) SSSegmentControl *titleSegmentControl;
@property (nonatomic, retain) NSArray *segments;
@property (nonatomic, retain) SSPageFlowView *flowView;
@property (nonatomic, assign) VideoListDataOperation *dataOperation;
@property (nonatomic, retain) NSMutableDictionary *conditions;

@end


@implementation VideoDetailFlowViewController

@synthesize titleBar = _titleBar;
@synthesize titleSegmentControl = _titleSegmentControl;
@synthesize segments = _segments;
@synthesize startIndex = _startIndex;
@synthesize flowView = _flowView;
@synthesize dataOperation= _dataOperation;
@synthesize conditions = _conditions;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.titleBar = nil;
    self.titleSegmentControl = nil;
    self.segments = nil;
    self.flowView = nil;
    self.dataOperation = nil;
    self.conditions = nil;
    
    [super dealloc];
}

- (id)initWithConditions:(NSDictionary *)conditions
{
    self = [super init];
    if (self) {
        self.dataOperation = [VideoListDataOperation sharedOperation];
        self.conditions = [[conditions mutableCopy] autorelease];
        _sortType = [[_conditions objectForKey:kListDataConditionSortTypeKey] intValue];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(loadDataFinished:) 
                                                     name:ssGetListDataFinishedNotification 
                                                   object:nil];
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.titleBar = nil;
    self.titleSegmentControl = nil;
    self.segments = nil;
    self.flowView = nil;
    self.dataOperation = nil;
    self.conditions = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - View Lifecycle

- (void)loadView
{
    UIView *contentView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    self.view = contentView;
    
    CGRect vFrame = self.view.bounds;
    CGRect tmpFrame = vFrame;
    
    self.titleBar = [[[SSTitleBarView alloc] initWithFrame:tmpFrame] autorelease];
    _titleBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_titleBar];
    
    self.flowView = [[[SSPageFlowView alloc] initWithFrame:tmpFrame] autorelease];
    _flowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _flowView.ssDelegate = self;
    _flowView.dataSource = self;
    [self.view addSubview:_flowView];
    
    SSButton *backButton = [SSButton buttonWithSSButtonType:SSButtonTypeLeftBack];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBar setLeftView:backButton];
}

#pragma mark - private

- (void)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ListDataOperationNotification

- (void)loadDataFinished:(NSNotification*)notification
{
    NSDictionary *responseCondition = [[[notification userInfo] objectForKey:@"userInfo"] objectForKey:@"condition"];
    if(([responseCondition objectForKey:kListDataConditionSortTypeKey] != [_conditions objectForKey:kListDataConditionSortTypeKey]) ||
       ([responseCondition objectForKey:kListDataConditionTagKey] != [_conditions objectForKey:kListDataConditionTagKey])) {
        return;
    }
    
    NSNumber *finishLoad = [[[notification userInfo] objectForKey:@"userInfo"] objectForKey:@"finishLoad"];
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    
    if(error) {
        SSLog(@"detail controller load finished error");
    }
    else {        
        if (finishLoad) {
            [_flowView reloadDataAtStartIndex:_flowView.currentPageIndex];   
        }
    }
}

#pragma mark - SSPageFlowViewDataSource & delegate

- (NSInteger)numberOfUnitsInPageFlowView:(SSPageFlowView *)pageFlowView
{
    return [_dataOperation.originalDataList count];
}

- (SSPageFlowUnit *)pageFlowView:(SSPageFlowView *)pageFlowView unitForColumnAtIndex:(NSInteger)index
{
    VideoDetailUnit *unit = (VideoDetailUnit *)[pageFlowView dequeueReusableUnit];
    if (unit == nil) {
        unit = [[[VideoDetailUnit alloc] init] autorelease];
    }
    unit.index = index;
    // unit.reportAnyTapEnable = NO;
    unit.frame = _flowView.bounds;  // must set frame 
    
    VideoData *indexData = [(VideoData *)[_dataOperation.originalDataList objectAtIndex:index] retain];
    unit.videoData = indexData;
    [indexData release];
    
    return unit;
}

- (void)pageFlowView:(SSPageFlowView *)pageFlowView didArriveAtColumnAtIndex:(NSInteger)currentIndex fromIndex:(NSInteger)fromIndex
{
    BOOL flipEnd = currentIndex == fromIndex;
    BOOL flipForward = currentIndex > fromIndex;
    
    if (!flipEnd) {
        trackEvent([SSCommon appName], TrackDetailPageEventString, flipForward ? @"flip_back" : @"flip_forward");   
    }
    
    if (currentIndex == [_dataOperation dataCount] - 3 && flipForward) {
        if (_dataOperation.canLoadMore) {
            [_dataOperation startGetDataWithCondition:_conditions
                                              clear:NO
                               clearOrderedDataList:NO
                                          fromLocal:NO
                                         fromRemote:YES
                                            getMore:YES];
        }
    }
    else if (flipEnd && currentIndex == 0) {
        [[VideoActivityIndicatorView sharedView] showWithMessage:@"已经是第一条了"];
    }
    else if (flipEnd && currentIndex == [_dataOperation dataCount] - 1) {
        [[VideoActivityIndicatorView sharedView] showWithMessage:@"已经是最后一条了"];
    }
}

@end


