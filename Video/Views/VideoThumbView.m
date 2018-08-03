//
//  VideoThumbView.m
//  Video
//
//  Created by Tianhang Yu on 12-7-25.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "VideoThumbView.h"
#import "SSLazyImageView.h"
#import "VideoPlayViewController.h"
#import "UIColorAdditions.h"
#import "VideoActivityIndicatorView.h"
#import "NetworkUtilities.h"

#define DurationLabelHeight SSUIFloatNoDefault(@"vuThumbViewDurationLabelHeight")
#define DurationLabelFontSize SSUIFloatNoDefault(@"vuThumbViewDurationLabelFontSize")
#define MarkImageViewOverFrame 3.f

@interface VideoThumbView () {
    
    VideoThumbViewType _type;
}

@property (nonatomic, retain) SSLazyImageView *thumbImageView;
@property (nonatomic, retain) UILabel *durationLabel;
@property (nonatomic, retain) UIImageView *durationBackView;
@property (nonatomic, retain) UIImageView *markImageView;
@property (nonatomic, retain) UIButton *coverButton;
@property (nonatomic, retain) VideoPlayViewController *player;
@property (nonatomic, retain) UIImageView *recomImageView;
@property (nonatomic, retain) UIImageView *hotImageView;

@end

@implementation VideoThumbView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.videoData = nil;
    self.trackEventName = nil;
    self.thumbImageView = nil;
    self.durationLabel = nil;
    self.durationBackView = nil;
    self.markImageView = nil;
    self.coverButton = nil;
    self.player = nil;
    self.recomImageView = nil;
    self.hotImageView = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame type:(VideoThumbViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        
        self.thumbImageView = [[[SSLazyImageView alloc] init] autorelease];
        _thumbImageView.clipType = SSLazyImageViewClipTypeRemainTop;
        _thumbImageView.defaultView = [[[UIImageView alloc] initWithImage:
                                        [UIImage imageNamed:type == VideoThumbViewTypeList ?
                                                             @"pic_loading.png" :
                                                             @"pic_details_loading.png"]] autorelease];
        [self addSubview:_thumbImageView];
        
        UIImage *durationBackImage = [UIImage imageNamed:@"time_background.png"];
        durationBackImage = [durationBackImage stretchableImageWithLeftCapWidth:floorf(durationBackImage.size.width)/2
                                                                   topCapHeight:floorf(durationBackImage.size.height)/2];
        self.durationBackView = [[[UIImageView alloc] initWithImage:durationBackImage] autorelease];
        [self addSubview:_durationBackView];
        
        self.durationLabel = [[[UILabel alloc] init] autorelease];
        _durationLabel.textAlignment = UITextAlignmentRight;
        _durationLabel.font = BoldChineseFontWithSize(DurationLabelFontSize);
        _durationLabel.textColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuStandardWhiteColor")];
        _durationLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_durationLabel];
        
        self.markImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"collect.png"]] autorelease];
        _markImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_markImageView];
        
        self.coverButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_coverButton addTarget:self action:@selector(coverButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_coverButton];
        
        self.recomImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recomicon.png"]] autorelease];
        [self addSubview:_recomImageView];
        
        self.hotImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hoticon.png"]] autorelease];
        [self addSubview:_hotImageView];
        
        [self bringSubviewToFront:_coverButton];
        [self bringSubviewToFront:_markImageView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame type:VideoThumbViewTypeList];
}

#pragma makr - public

- (void)refreshUI
{
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    
    _thumbImageView.frame = tmpFrame;
    _coverButton.frame = tmpFrame;
    
    tmpFrame.origin.y = vFrame.size.height - DurationLabelHeight;
    tmpFrame.size.height = DurationLabelHeight;
    _durationBackView.frame = tmpFrame;
    
    tmpFrame.size.width -= SSUIFloatNoDefault(@"vuThumbViewDurationLabelLeftMargin");
    _durationLabel.frame = tmpFrame;
    
    if (_recomImageView.hidden == NO) {
        tmpFrame.size.width = DurationLabelHeight;
        _recomImageView.frame = tmpFrame;
    }
    else {
        _recomImageView.frame = CGRectZero;
    }
    
    if (_hotImageView.hidden = NO) {
        tmpFrame.size.width = DurationLabelHeight;
        if (_recomImageView.hidden == NO) {
            tmpFrame.origin.x = CGRectGetMaxX(_recomImageView.frame);
        }
        _hotImageView.frame = tmpFrame;
    }
    else {
        _hotImageView.frame = CGRectZero;
    }
    
    tmpFrame = _markImageView.frame;
    tmpFrame.origin.x = -MarkImageViewOverFrame;
    tmpFrame.origin.y = -MarkImageViewOverFrame;
    _markImageView.frame = tmpFrame;
}

- (void)setVideoData:(VideoData *)videoData
{
    if (_videoData) {
        [_videoData removeObserver:self forKeyPath:@"userRepined"];
    }
    
    [_videoData release];
    _videoData = [videoData retain];
    
    if (_videoData) {
        
        _thumbImageView.netImageUrl = _videoData.coverImageURL;
        
        _durationLabel.text = [NSString stringWithFormat:@"%02i:%02i", [_videoData.duration intValue]/60, [_videoData.duration intValue]%60];
        _markImageView.hidden = _type == VideoThumbViewTypeDetail || ![_videoData.userRepined boolValue];
        
        // hide cover button from version 1.2
        _coverButton.hidden = YES;
        if (_coverButton.hidden == NO && ([_videoData.downloadDataStatus intValue] == VideoDownloadDataStatusDeadLink
                                          || [_videoData.downloadDataStatus intValue] == VideoDownloadDataStatusNoDownloadURL)) {
            switch (_type) {
                case VideoThumbViewTypeDetail:
                    [_coverButton setImage:[UIImage imageNamed:@"broadcast_fail_details.png"] forState:UIControlStateNormal];
                    break;
                case VideoThumbViewTypeList:
                    [_coverButton setImage:[UIImage imageNamed:@"broadcast_fail.png"] forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
        }
        else {
            switch (_type) {
                case VideoThumbViewTypeDetail:
                    [_coverButton setImage:[UIImage imageNamed:@"broadcast_details.png"] forState:UIControlStateNormal];
                    break;
                case VideoThumbViewTypeList:
                    [_coverButton setImage:[UIImage imageNamed:@"broadcast.png"] forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
        }
        
        if (([_videoData.tip intValue] & 1) > 0) {
            _hotImageView.hidden = NO;
            _recomImageView.hidden = YES;
        }
        else if (([_videoData.tip intValue] & 2) > 0) {
            _hotImageView.hidden = YES;
            _recomImageView.hidden = NO;
        }
        else if (([_videoData.tip intValue] & 3) > 0) {
            _hotImageView.hidden = NO;
            _recomImageView.hidden = NO;
        }
        else {
            _hotImageView.hidden = YES;
            _recomImageView.hidden = YES;
        }
        
        [_videoData addObserver:self forKeyPath:@"userRepined" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - private

- (void)coverButtonClicked:(id)sender
{
    // play video in version 1.0
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userRepined"]) {
        _markImageView.hidden = _type == VideoThumbViewTypeDetail || ![_videoData.userRepined boolValue];    
    }
}

@end


