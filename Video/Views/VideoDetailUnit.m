//
//  VideoFlowUnit.m
//  Video
//
//  Created by Tianhang Yu on 12-7-20.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDetailUnit.h"
#import "VideoPlayerView.h"
#import "VideoPlayViewController.h"
#import "CommentDetailListView.h"
#import "VideoData.h"
#import "UIColorAdditions.h"
#import "VideoDetailIntroView.h"

@interface VideoDetailUnit () <CommentDetailViewDelegate, UIScrollViewDelegate, VideoPlayerViewDelegate> {
    BOOL _hasPrepareToPlay;
}

@property (nonatomic, retain) VideoPlayerView *playerView;
@property (nonatomic, retain) UIScrollView *commentContainer;
@property (nonatomic, retain) CommentDetailListView *commentListView;
@property (nonatomic, retain) VideoPlayViewController *playViewController;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeRight;
@property (nonatomic, retain) NSMutableDictionary *commentQueryCondition;

@end


@implementation VideoDetailUnit

- (void)dealloc
{
    self.videoData = nil;
    self.trackEventName = nil;
    
    self.playerView = nil;
    self.playViewController = nil;
    self.commentContainer = nil;
    self.commentListView = nil;
    self.swipeRight = nil;
    self.commentQueryCondition = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.reportAnyTapEnable = NO;
       
        self.playerView = [[[VideoPlayerView alloc] init] autorelease];
        _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _playerView.delegate = self;
        [self addSubview:_playerView];
        
        CGRect tmpFrame = CGRectMake(0, 0, 320, 200);
        self.commentContainer = [[[UIScrollView alloc] initWithFrame:tmpFrame] autorelease];
        _commentContainer.delegate = self;
        [self addSubview:_commentContainer];
        
        self.commentListView = [[[CommentDetailListView alloc] initWithFrame:tmpFrame expandable:YES] autorelease];
        _commentListView.delegate = self;
        _commentListView.noCommentImage = [UIImage imageNamed:@"sofa.png"];
        _commentListView.noCommentText = @"";
        [_commentContainer addSubview:_commentListView];
        
        self.swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonClicked:)] autorelease];
        _swipeRight.numberOfTouchesRequired = 1;
        _swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_commentContainer addGestureRecognizer:_swipeRight];
       
        self.commentQueryCondition = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
    }
    return self;
}

- (void)didAppear
{
    [super didAppear];
    [_playerView didAppear];
    
    if (!_hasPrepareToPlay) {
        
        [_playerView prepareToPlay];
        _hasPrepareToPlay = YES;
    }
}

- (void)didDisappear
{
    [super didDisappear];
    
    if (!_playViewController) {
        [_playerView didDisappear];
    }
}

#pragma mark - Actions

- (void)backButtonClicked:(id)sender
{
    UIViewController *topViewController = [SSCommon topViewControllerFor:self];
    [topViewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark - public

- (void)setTrackEventName:(NSString *)trackEventName
{
    [_trackEventName release];
    _trackEventName = [trackEventName copy];
    
    if (_playerView) {
        _playerView.trackEventName = _trackEventName;
    }
}

- (void)setVideoData:(VideoData *)videoData
{
    [_videoData release];
    _videoData = [videoData retain];
    
    if (_videoData) {
        _playerView.video = _videoData;

        [_commentQueryCondition setObject:[NSString stringWithFormat:@"%@", _videoData.groupID] forKey:kQueryCommentConditionGroupID];
        [_commentQueryCondition setObject:_videoData.tag forKey:kQueryCommentConditionTag];
        [_commentQueryCondition setObject:[NSNumber numberWithInt:CommentSortTypeHot] forKey:kSortTypeConditionKey];
        [_commentListView startLoadCommentsWithCondition:_commentQueryCondition];
    }
}

- (void)insertComment:(NSDictionary *)commentData
{
    [_commentListView insertComment:commentData];
//    [_commentListView startLoadCommentsWithCondition:_commentQueryCondition];
}

- (void)playerPause
{
    [_playerView pause];
}

- (void)refreshUI
{
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    
    tmpFrame.size.height = PlayerViewHalfScreenHeight;
    _playerView.frame = tmpFrame;
    
    tmpFrame.origin.y = CGRectGetMaxY(_playerView.frame);
    tmpFrame.size.height = vFrame.size.height - CGRectGetMaxY(_playerView.frame);
    _commentContainer.frame = tmpFrame;
    
    tmpFrame = _commentContainer.bounds;
    _commentListView.frame = tmpFrame;
    
    [_playerView refreshUI];
}

#pragma mark - VideoPlayerViewDelegate

- (void)videoPlayerView:(VideoPlayerView *)playerView didChangeFullscreen:(BOOL)fullscreen
{
    if (fullscreen) {
        
        _playerView.trackEventName = @"fullscreen_tab";
        
        VideoPlayViewController *control = [[[VideoPlayViewController alloc] init] autorelease];
        self.playViewController = control;
        _playViewController.needDismiss = NO;
        control.playerView = _playerView;
        
        UIViewController *topViewController = [SSCommon topViewControllerFor:self];
        if ([topViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [topViewController.navigationController presentViewController:control animated:NO completion:nil];
        }
        else {
            [topViewController.navigationController presentModalViewController:control animated:NO];
        }
    }
    else {
        
        _playerView.trackEventName = _trackEventName;
        
        if (_playViewController) {
            _playViewController.needDismiss = YES;
            
            if ([_playViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
                [_playViewController dismissViewControllerAnimated:NO completion:nil];
            }
            else {
                [_playViewController dismissModalViewControllerAnimated:NO];
            }
            
            self.playViewController = nil;
            
            CGRect vFrame = self.bounds;
            CGRect tmpFrame = vFrame;
            tmpFrame.size.height = PlayerViewHalfScreenHeight;
            _playerView.frame = tmpFrame;
            [self addSubview:_playerView];
            [_playerView refreshUI];
        }
    }
}

- (void)videoPlayerView:(VideoPlayerView *)playerView handleSwipeRightGesture:(UISwipeGestureRecognizer *)swipeRight
{
    [self backButtonClicked:nil];
}

#pragma mark - CommentDetailListViewDelegate

- (void)socialViewSizeChanged:(CGSize)viewSize
{
    CGSize contentSize = _commentContainer.contentSize;
    contentSize.height = viewSize.height;
    _commentContainer.contentSize = contentSize;
    
    _commentListView.noFavView.center = CGPointMake(190.f, CGRectGetHeight(_commentContainer.frame) / 2);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.size.height - 60.f) {
        [_commentListView manualLoadMore];
    }
}

@end
