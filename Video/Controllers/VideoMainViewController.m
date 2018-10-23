//
//  VideoMainViewController.m
//  Video
//
//  Created by Tianhang Yu on 12-7-24.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VideoMainViewController.h"
#import "SSTabBar.h"
#import "SSTabBarItem.h"
#import "UIColorAdditions.h"

#import "VideoMVListView.h"
#import "VideoDownloadListView.h"
#import "VideoMineView.h"
#import "VideoMoreView.h"
#import "VideoDownloadDataManager.h"

#define vuTabBarHeight SSUIFloatNoDefault(@"vuTabBarHeight")


@interface VideoBadgeView : UIView

@property (nonatomic, retain) UIImageView *badgeImageView;
@property (nonatomic, retain) UILabel *badgeLabel;

- (void)setBadgeText:(NSString *)text;

@end


@implementation VideoBadgeView
@synthesize badgeLabel = _badgeLabel;
@synthesize badgeImageView = _badgeImageView;

- (void)dealloc
{
    self.badgeImageView = nil;
    self.badgeLabel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame badgeText:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *badgeImage = [UIImage imageNamed:@"redpoint_tool.png"];
        badgeImage = [badgeImage stretchableImageWithLeftCapWidth:floorf(badgeImage.size.width/2)
                                                     topCapHeight:floorf(badgeImage.size.height/2)];
        self.badgeImageView = [[[UIImageView alloc] initWithImage:badgeImage] autorelease];
        [self addSubview:_badgeImageView];
        
        self.badgeLabel = [[[UILabel alloc] init] autorelease];
        _badgeLabel.backgroundColor = [UIColor clearColor];
//        _badgeLabel.textColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuStandardWhiteColor")];
//        _badgeLabel.font = ChineseFontWithSize(SSUIFloatNoDefault(@"vuTabBarBadgeTextFontSize"));
        _badgeLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
        _badgeLabel.shadowColor = [UIColor colorWithHexString:@"df4a51"];
        _badgeLabel.shadowOffset = CGSizeMake(0, 1.f);
        _badgeLabel.font = ChineseFontWithSize(10.f);
        [self addSubview:_badgeLabel];
        
        [self setBadgeText:text];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame badgeText:nil];
}

- (void)setBadgeText:(NSString *)text
{
    _badgeLabel.text = text;
    [_badgeLabel sizeToFit];
    
    CGRect vFrame = self.frame;
    CGRect tmpFrame = self.bounds;
    
    tmpFrame.size.width = MAX(_badgeImageView.bounds.size.width, _badgeLabel.bounds.size.width);
    tmpFrame.size.height = _badgeImageView.bounds.size.height;
    
    vFrame.size.width = tmpFrame.size.width;
    vFrame.size.height = tmpFrame.size.height;
    self.frame = vFrame;
    
    _badgeImageView.frame = tmpFrame;
    _badgeLabel.center = CGPointMake(self.bounds.size.width/2 + 0.2, self.bounds.size.height/2 - 0.3);
}

@end


@interface VideoMainViewController () <SSTabBarDelegate, AVAudioPlayerDelegate> {
    
    BOOL _playing;
    BOOL _hasLoadDownloadTabBadge;
}

@property (nonatomic, retain) SSTabBar *tabBar;
@property (nonatomic, retain) SSViewBase *currentView;
@property (nonatomic, retain) VideoMVListView *listView;
@property (nonatomic, retain) VideoDownloadListView *downloadView;
@property (nonatomic, retain) VideoMineView *mineView;
@property (nonatomic, retain) VideoMoreView *moreView;

@end

@implementation VideoMainViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.tabBar = nil;
    self.currentView = nil;
    self.listView = nil;
    self.downloadView = nil;
    self.mineView = nil;
    self.moreView = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportVideoDownloadTabAddOneNotification:)
                                                     name:VideoDownloadTabAddOneNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportVideoDownloadTabCompleteNotification:)
                                                     name:VideoDownloadTabCompleteNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportVideoDownloadTabUpdateBadgeNotification:)
                                                     name:VideoDownloadTabUpdateBadgeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportVideoMVTabUpdateBadgeNotification:)
                                                     name:VideoMVTabUpdateBadgeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reportVideoMainPlayingNotification:)
                                                     name:VideoMainPlayingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeViewNotification:) name:VideoMainViewChangeViewNotification object:nil];
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.listView = nil;
    self.downloadView = nil;
    self.mineView = nil;
    self.moreView = nil;
    self.tabBar = nil;
    self.currentView = nil;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    UIView *contentView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
    
    CGRect vFrame = self.view.bounds;
    CGRect tmpFrame = vFrame;
    tmpFrame.size.height -= vuTabBarHeight;
    
    self.listView = [[[VideoMVListView alloc] initWithFrame:tmpFrame] autorelease];
    self.downloadView = [[[VideoDownloadListView alloc] initWithFrame:tmpFrame] autorelease];
    self.mineView = [[[VideoMineView alloc] initWithFrame:tmpFrame] autorelease];
    self.moreView = [[[VideoMoreView alloc] initWithFrame:tmpFrame] autorelease];
    
    tmpFrame.origin.y = vFrame.size.height - vuTabBarHeight;
    tmpFrame.size.height = vuTabBarHeight;
    
    self.tabBar = [[[SSTabBar alloc] initWithFrame:tmpFrame] autorelease];
    _tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _tabBar.delegate = self;
    UIImage *backgroundImage = [UIImage imageNamed:@"dock.png"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:floorf(backgroundImage.size.width/2)
                                                           topCapHeight:floorf(backgroundImage.size.height/2)];
    _tabBar.backgroundImage = backgroundImage;
    [_tabBar setSelectedForegroundImage:[UIImage imageNamed:@"selected_highlight.png"]];
    
    [self addTabBarItem:@"视频" image:@"video.png" highlightImage:@"video_press.png"];
    [self addTabBarItem:@"下载" image:@"download.png" highlightImage:@"download_press.png"];
    [self addTabBarItem:@"我的" image:@"myself.png" highlightImage:@"myself_press.png"];
    [self addTabBarItem:@"更多" image:@"more.png" highlightImage:@"more_press.png"];
    
    [self.view addSubview:_tabBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!_hasLoadDownloadTabBadge) {
        _hasLoadDownloadTabBadge = YES;
        [self updateDownloadTabBadge];
    }
    
    if ([_currentView isKindOfClass:[VideoMoreView class]]) {
        [_currentView didAppear];
    }
}

#pragma mark - private

- (void)downloadTabAddOneAnimation
{
    UIImageView *addOneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_one.png"]];
    addOneImageView.center = CGPointMake(self.view.bounds.size.width/2 + 24.f, _tabBar.frame.origin.y - 10.f);
    [self.view addSubview:addOneImageView];
    
    CGFloat duration = 1.f;
    [UIView animateWithDuration:duration
                     animations:^{
                         addOneImageView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                     }
                     completion:^(BOOL finished) {
                         [addOneImageView removeFromSuperview];
                         [addOneImageView release];
                     }];
}

- (void)downloadTabCompleteAnimation
{
    UIView *completeView = [[UIView alloc] init];
    
    UILabel *completeLabel = [[[UILabel alloc] init] autorelease];
    completeLabel.backgroundColor = [UIColor clearColor];
    completeLabel.text = @"下载完成";
    completeLabel.textColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuStandardBlueColor")];
    completeLabel.font = ChineseFont;
    [completeLabel sizeToFit];
    [completeView addSubview:completeLabel];
    
    UIImageView *addOneImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_one.png"]] autorelease];
    [completeView addSubview:addOneImageView];
    
    CGRect tmpFrame = CGRectMake(0,
                                 0,
                                 completeLabel.bounds.size.width + addOneImageView.bounds.size.width,
                                 MAX(completeLabel.bounds.size.height, addOneImageView.bounds.size.height));
    completeView.frame = tmpFrame;
    
    tmpFrame = completeLabel.frame;
    tmpFrame.origin.y = (completeView.bounds.size.height - completeLabel.bounds.size.height)/2;
    completeLabel.frame = tmpFrame;
    
    tmpFrame = addOneImageView.frame;
    tmpFrame.origin.x = CGRectGetMaxX(completeLabel.frame);
    tmpFrame.origin.y = (completeView.bounds.size.height - addOneImageView.bounds.size.height)/2;
    addOneImageView.frame = tmpFrame;
    
    completeView.center = CGPointMake(self.view.bounds.size.width/2 + 10.f, _tabBar.frame.origin.y - 10.f);
    [self.view addSubview:completeView];
    
    CGFloat duration = 2.f;
    [UIView animateWithDuration:duration
                     animations:^{
                         completeView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                     }
                     completion:^(BOOL finished) {
                         [completeView removeFromSuperview];
                         [completeView release];
                     }];
    
    // play done sound
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"download_done"
                                                          ofType:@"mp3"];
    if (musicPath) {
        NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL
                                                                            error:nil];
        audioPlayer.delegate = self;
        
        if (_playing) {
            audioPlayer.volume = 0.3f;
        }
        else {
            audioPlayer.volume = 0.7f;
        }
        
        [audioPlayer play];
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [player autorelease];
}

- (void)updateDownloadTabBadge
{
    NSUInteger badgeCount = [VideoDownloadDataManager downloadTabCount];
    
    VideoBadgeView *badgeView = nil;
    if (badgeCount != 0) {
        if (badgeCount > 99) {
            badgeCount = 99;
        }
        
        badgeView = [[[VideoBadgeView alloc] initWithFrame:CGRectMake(8, 3 + SSUIFloatNoDefault(@"vuTabBarBadgeTopMargin"), 0, 0) badgeText:[NSString stringWithFormat:@"%d", badgeCount]] autorelease];
    }
    
    if (badgeView) {
        // fix SSTabBarItem bug
        [(SSTabBarItem*)[_tabBar.items objectAtIndex:1] setBadgeView:nil];
    }
    [(SSTabBarItem*)[_tabBar.items objectAtIndex:1] setBadgeView:badgeView];
}

- (void)updateMVTabBadge:(NSUInteger)badgeCount
{
    VideoBadgeView *badgeView = nil;
    if (badgeCount != 0) {
        if (badgeCount > 99) {
            badgeCount = 99;
        }
        
        badgeView = [[[VideoBadgeView alloc] initWithFrame:CGRectMake(8, 3 + SSUIFloatNoDefault(@"vuTabBarBadgeTopMargin"), 0, 0) badgeText:[NSString stringWithFormat:@"%d", badgeCount]] autorelease];
    }
    
    if (badgeView) {
        // fix SSTabBarItem bug
        [(SSTabBarItem*)[_tabBar.items objectAtIndex:0] setBadgeView:nil];
    }
    [(SSTabBarItem*)[_tabBar.items objectAtIndex:0] setBadgeView:badgeView];
}

- (void)addTabBarItem:(NSString *)title image:(NSString *)imageName highlightImage:(NSString *)highlightImageName
{
    SSTabBarItem *item = [[[SSTabBarItem alloc] init] autorelease];
    [item setTitle:title forTabBarItemState:SSTabBarControlStateNormal];
    [item setTextColor:[UIColor colorWithHexString:@"828282"] forTabBarItemState:SSTabBarControlStateNormal];
    [item setTextColor:[UIColor colorWithHexString:@"00c2f1"] forTabBarItemState:SSTabBarControlStateHighlighted];
    [item setImage:[UIImage imageNamed:imageName] forTabBarItemState:SSTabBarControlStateNormal];
    [item setImage:[UIImage imageNamed:highlightImageName] forTabBarItemState:SSTabBarControlStateHighlighted];
    
    [_tabBar addTabBarItem:item];
}

#pragma mark - Actions

- (void)changeViewNotification:(NSNotification *)notification
{
    if ([notification.object isEqualToString:kVideoMainViewChangeToMoreView]) {
        _tabBar.selectedIndex = 3;
    }
    else if([notification.object isEqualToString:kVideoMainViewChangeToDownloadView]) {
        _tabBar.selectedIndex = 1;
    }
    else if ([notification.object isEqualToString:kVideoMainViewChangeToMineView]) {
        _tabBar.selectedIndex = 2;
    }
    else if ([notification.object isEqualToString:kVideoMainViewChangeToMVView]) {
        _tabBar.selectedIndex = 0;
    }
}

- (void)reportVideoMainPlayingNotification:(NSNotification *)notification
{
    _playing = [[notification.userInfo objectForKey:kVideoMainPlayingNotificationPlayingKey] boolValue];
}

- (void)reportVideoMVTabUpdateBadgeNotification:(NSNotification *)notification
{
    [self updateMVTabBadge:[[notification.userInfo objectForKey:kVideoMVTabUpdateBadgeNotificationValueKey] intValue]];
}

- (void)reportVideoDownloadTabAddOneNotification:(NSNotification *)notification
{
    [self downloadTabAddOneAnimation];
    [self updateDownloadTabBadge];
}

- (void)reportVideoDownloadTabCompleteNotification:(NSNotification *)notification
{
    [self downloadTabCompleteAnimation];
    [self updateDownloadTabBadge];
}

- (void)reportVideoDownloadTabUpdateBadgeNotification:(NSNotification *)notification
{
    [self updateDownloadTabBadge];
}

#pragma mark - SSTabBarDelegate

- (void)ssTabBar:(SSTabBar *)tabBar didSelectItemAtIndex:(int)index
{
    if ([self.view.subviews containsObject:_currentView]) {
        [_currentView removeFromSuperview];
    }
    
    switch (index) {
        case 0:
            self.currentView = _listView;
            break;
        case 1:
            self.currentView = _downloadView;
            break;
        case 2:
            self.currentView = _mineView;
            break;
        case 3:
            self.currentView = _moreView;
            break;
    }

    [self.view addSubview:_currentView];
    [_currentView didAppear];
    
    [self.view bringSubviewToFront:_tabBar];
}

- (void)ssTabBar:(SSTabBar *)tabBar didSelectHightlightItemAtIndex:(int)index
{
    if (_currentView == _listView) {
        [_listView refreshButtonClicked:nil];
    }
}

@end



