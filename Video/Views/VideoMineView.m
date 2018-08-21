//
//  VideoMineView.m
//  Video
//
//  Created by Kimi on 12-10-22.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoMineView.h"
#import "SSTitleBarView.h"
#import "SSSegmentControl.h"
#import "VideoTitleBarSegment.h"
#import "VideoListView.h"
#import "AuthorityView.h"
#import "AccountManagerView.h"
#import "VideoHistoryView.h"

#import "SSAlertCenter.h"
#import "AccountManager.h"
#import "ListDataHeader.h"
#import "UIColorAdditions.h"

#define TitleSegmentControlWidth 3*SSUIFloatNoDefault(@"vuTitleBarSegmentWidth")
#define TrackAccountTabEventName @"my_tab"

@interface VideoMineView () <SSSegmentControlDelegate> {
    BOOL _hasAppearOnce;
    BOOL _hasLoginSuccess;
}

@property (nonatomic, retain) SSTitleBarView *titleBar;
@property (nonatomic, retain) SSViewBase *listView;
@property (nonatomic, retain) SSSegmentControl *titleSegmentControl;
@property (nonatomic, retain) NSArray *segments;

@property (nonatomic, retain) VideoListView *repinView;
@property (nonatomic, retain) VideoHistoryView *historyView;
@property (nonatomic, retain) AuthorityView *authorityView;
@property (nonatomic, retain) AccountManagerView *accountManagerView;

@end

@implementation VideoMineView

- (void)dealloc
{
    [[SSAlertCenter defaultCenter] resumeAlertCenter];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.titleBar = nil;
    self.listView = nil;
    self.titleSegmentControl = nil;
    self.segments = nil;
    
    self.repinView = nil;
    self.historyView = nil;
    self.authorityView = nil;
    self.accountManagerView = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accountManagerResponsedReceived:)
                                                     name:kResponseReceviedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLogoutUserNotification:)
                                                     name:kLogoutUserNotification
                                                   object:nil];
        
        VideoTitleBarSegment *repinSegment = [VideoTitleBarSegment buttonWithType:UIButtonTypeCustom];
        [repinSegment setTitle:@"收藏" forState:UIControlStateNormal];
        
        VideoTitleBarSegment *historySegment = [VideoTitleBarSegment buttonWithType:UIButtonTypeCustom];
        [historySegment setTitle:@"历史" forState:UIControlStateNormal];

        VideoTitleBarSegment *accountSegment = [VideoTitleBarSegment buttonWithType:UIButtonTypeCustom];
        [accountSegment setTitle:@"账户" forState:UIControlStateNormal];
        
        self.segments = [NSArray arrayWithObjects:repinSegment, historySegment, accountSegment, nil];
        
        [self loadView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportThemeDidChangeNotification:)
                                                     name:SSResourceManagerThemeModeChangedNotification
                                                   object:nil];
    }
    return self;
}

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
    
    tmpFrame.origin.y = CGRectGetMaxY(_titleBar.frame);
    tmpFrame.size.height = vFrame.size.height - _titleBar.frame.size.height;
    
    self.repinView = [[[VideoListView alloc] initWithFrame:tmpFrame
                                                condition:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:ListDataTypeVideo], kListDataTypeKey,
                                                           [NSNumber numberWithInt:DataSortTypeFavorite], kListDataConditionSortTypeKey,
                                                           nil]] autorelease];
    _repinView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _repinView.trackEventName = @"favorite_tab";
    
    self.historyView = [[[VideoHistoryView alloc] initWithFrame:tmpFrame] autorelease];
    self.authorityView = [[[AuthorityView alloc] initWithFrame:tmpFrame] autorelease];
    [_authorityView hideWhyLabel];
    self.accountManagerView = [[[AccountManagerView alloc] initWithFrame:tmpFrame] autorelease];
    
    if ([self.subviews containsObject:_listView]) {
        [_listView removeFromSuperview];
    }
    
    self.listView = _repinView;
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
    
    [self bringSubviewToFront:_titleBar];
}

- (void)didAppear   // will not be invoke in viewController's viewWillAppear method
{
	[super didAppear];
    
    if (!_hasAppearOnce) {
        if (![[AccountManager sharedManager] loggedIn]) {
            [_titleSegmentControl selectAtIndex:2];
        }
        else {
            [_titleSegmentControl selectAtIndex:0];
        }
    }
    else if (_hasLoginSuccess && !_hasAppearOnce) {
        [_titleSegmentControl selectAtIndex:0];
    }
    else {
        [_listView didAppear];
    }
    
    _hasAppearOnce = YES;
    
    trackEvent([SSCommon appName], TrackAccountTabEventName, @"enter");
}

- (void)willDisappear
{
    [super willDisappear];
    [_listView willDisappear];
}

- (void)didDisappear
{
    [super didDisappear];
    [_listView didDisappear];
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
            self.listView = _repinView;
            [self addSubview:_listView];
            
            trackEvent([SSCommon appName], @"favorite_tab", @"enter");
        }
            break;
        case 1:
        {
            self.listView = _historyView;
            [self addSubview:_listView];
            
            trackEvent([SSCommon appName], @"history_tab", @"enter");
        }
            break;
        case 2:
        {
            if ([[AccountManager sharedManager] loggedIn]) {
                self.listView = _accountManagerView;
            }
            else {
                self.listView = _authorityView;
            }
            [self addSubview:_listView];
            
            trackEvent([SSCommon appName], @"account_tab", @"enter");
        }
            break;
        default:
            break;
    }
    
    if (_listView == _authorityView || _listView == _accountManagerView) {
        [[SSAlertCenter defaultCenter] pauseAlertCenter];
    }
    else {
        [[SSAlertCenter defaultCenter] resumeAlertCenter];
    }
    
    [_listView willAppear];
    [_listView didAppear];
    [self sendSubviewToBack:_listView];
}

#pragma mark - AccountManagerNotification

- (void)accountManagerResponsedReceived:(NSNotification*)notification
{
    AccountActionType actionType = [[[notification userInfo] objectForKey:kActionTypeKey] intValue];
    AccountResponseType responseType = [[[notification userInfo] objectForKey:kResponseTypeKey] intValue];
    
    switch (actionType) {
        case ActionTypeGetStates:
        {
            switch (responseType) {
                case ResponseTypeSuccess:
                    // 登陆成功
                    if ([self.subviews containsObject:_listView]) {
                        [_listView removeFromSuperview];
                    }
                    self.listView = _accountManagerView;
                    [self addSubview:_listView];
                    [_listView didAppear];
                    [self sendSubviewToBack:_listView];
                    
                    _hasLoginSuccess = YES;
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case ActionTypeUpdate:
        {
            switch (responseType) {
                case ResponseTypeSessionExpired:
                    // session 过期
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

- (void)handleLogoutUserNotification:(NSNotification*)notification
{
    if ([self.subviews containsObject:_listView]) {
        [_listView removeFromSuperview];
    }
    self.listView = _authorityView;
    [self addSubview:_listView];
    [_listView didAppear];
    [self sendSubviewToBack:_listView];
}

@end
