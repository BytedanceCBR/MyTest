//
//  VideoIntroView.m
//  Video
//
//  Created by Tianhang Yu on 12-7-26.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoListIntroView.h"
#import "VideoData.h"
#import "VideoRateView.h"
#import "UIColorAdditions.h"
#import "UILabel+UILabelAdditions.h"

#define LowerPartLabelsFontSize SSUIFloatNoDefault(@"vuIntroViewLowerPartTextFontSize")
#define LowerPartLabelsTextColorString SSUIStringNoDefault(@"vuIntroViewLowerPartTextColor")
#define TitleLabelNormalTextColor SSUIStringNoDefault(@"vuIntroViewTitleLabelNormalTextColor")
#define TitleLabelReadedTextColor SSUIStringNoDefault(@"vuIntroViewTitleLabelHasReadTextColor")
#define RateViewHeight SSUIFloatNoDefault(@"vuIntroViewRateViewHeight")
#define RateViewWidth SSUIFloatNoDefault(@"vuIntroViewRateViewWidth")

@interface VideoListIntroView () {
    VideoIntroViewType _type;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) VideoRateView *rateView;
@property (nonatomic, retain) UILabel *playCountLabel;
@property (nonatomic, retain) UILabel *behotTimeLabel;

@end

@implementation VideoListIntroView

- (void)dealloc
{
    self.videoData = nil;
    self.titleLabel = nil;
    self.rateView = nil;
    self.playCountLabel = nil;
    self.behotTimeLabel = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame type:(VideoIntroViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        _showGrayForRead = NO;
        
        self.titleLabel = [[[UILabel alloc] init] autorelease];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = ChineseFontWithSize(SSUIFloatNoDefault(@"vuListIntroViewTitleFontSize"));
        _titleLabel.textColor = [UIColor colorWithHexString:TitleLabelNormalTextColor];
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        
        if (_type != VideoIntroViewTypeDownloadingList) {
            
            self.rateView = [[[VideoRateView alloc] init] autorelease];
            _rateView.backgroundColor = [UIColor clearColor];
            [self addSubview:_rateView];
            
            self.playCountLabel = [[[UILabel alloc] init] autorelease];
            _playCountLabel.backgroundColor = [UIColor clearColor];
            _playCountLabel.font = ChineseFontWithSize(LowerPartLabelsFontSize);
            _playCountLabel.textColor = [UIColor colorWithHexString:LowerPartLabelsTextColorString];
            [self addSubview:_playCountLabel];
            
            self.behotTimeLabel = [[[UILabel alloc] init] autorelease];
            _behotTimeLabel.backgroundColor = [UIColor clearColor];
            _behotTimeLabel.font = ChineseFontWithSize(LowerPartLabelsFontSize);
            _behotTimeLabel.textColor = [UIColor colorWithHexString:LowerPartLabelsTextColorString];
            [self addSubview:_behotTimeLabel];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame type:VideoIntroViewTypeList];
}

#pragma mark - public 

- (void)refreshUI
{
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    CGPoint tmpCenter;
    
    [_titleLabel heightThatFitsWidth:vFrame.size.width];
    [_playCountLabel sizeToFit];
    [_behotTimeLabel sizeToFit];
    
    CGFloat titleLabelBottomMargin = 0.f;
    CGFloat titleLabelHeight = 0.f;
    titleLabelBottomMargin = 10.f;
    
    if (_type != VideoIntroViewTypeDownloadingList) {
        titleLabelHeight = MIN(_titleLabel.bounds.size.height,
                               vFrame.size.height - RateViewHeight - titleLabelBottomMargin);
    }
    else {
        titleLabelHeight = MIN(_titleLabel.bounds.size.height,
                               vFrame.size.height - titleLabelBottomMargin);
    }
    
    tmpFrame.size.height = titleLabelHeight;
    _titleLabel.frame = tmpFrame;
    
    if (_type != VideoIntroViewTypeDownloadingList) {
        
        tmpFrame.size.width = RateViewWidth;
        tmpFrame.size.height = RateViewHeight;
        tmpFrame.origin.y = CGRectGetMaxY(_titleLabel.frame) + titleLabelBottomMargin;
        _rateView.frame = tmpFrame;
        
        tmpFrame = _playCountLabel.frame;
        tmpFrame.size.height = RateViewHeight;
        tmpFrame.origin.x = CGRectGetMaxX(_rateView.frame) + 10.f;
        tmpFrame.origin.y = CGRectGetMinY(_rateView.frame);
        _playCountLabel.frame = tmpFrame;
        
        tmpCenter = _playCountLabel.center;
        tmpCenter.y = _rateView.center.y + 1;
        _playCountLabel.center = tmpCenter;
        
        tmpFrame = _behotTimeLabel.frame;
        tmpFrame.origin.x = vFrame.size.width - _behotTimeLabel.frame.size.width;
        tmpFrame.size.height = RateViewHeight;
        _behotTimeLabel.frame = tmpFrame;
        
        tmpCenter = _behotTimeLabel.center;
        tmpCenter.y = _rateView.center.y + 1;
        _behotTimeLabel.center = tmpCenter;
    }
    else {
        _rateView.frame = CGRectZero;
        _rateView.hidden = YES;
        _playCountLabel.frame = CGRectZero;
        _behotTimeLabel.frame = CGRectZero;
    }
    
    [self updateTitleColor];
}

- (void)setVideoData:(VideoData *)videoData type:(VideoIntroViewType)type
{
    _type = type;
    self.videoData = videoData;
}

- (void)setVideoData:(VideoData *)videoData
{
    if (_videoData) {
        [_videoData removeObserver:self forKeyPath:@"hasRead"];
        [_videoData removeObserver:self forKeyPath:@"rate"];
        [_videoData removeObserver:self forKeyPath:@"playCount"];
    }

    [_videoData release];
    _videoData = [videoData retain];
    
    if (_videoData) {
        _titleLabel.text = _videoData.title;
        
        _rateView.rate = _videoData.rate;
        _playCountLabel.text = [NSString stringWithFormat:@"%d人看过", [_videoData.playCount intValue]];
        
        NSDate *behotTime = [NSDate dateWithTimeIntervalSince1970:[_videoData.behotTime doubleValue]];
        NSDate *morning = [YearToDayFormatter() dateFromString:[YearToDayFormatter() stringFromDate:[NSDate date]]];
        
        NSString *behotTimeString = nil;
        if ([[behotTime earlierDate:morning] isEqualToDate:morning]) {
            behotTimeString = [NSString stringWithFormat:@"今天 %@", [HourToMiniteFormatter() stringFromDate:behotTime]];
        }
        else {
            behotTimeString = [YearToDayFormatter() stringFromDate:behotTime];
        }
        
        _behotTimeLabel.text = behotTimeString;
        
        [_videoData addObserver:self forKeyPath:@"hasRead" options:NSKeyValueObservingOptionNew context:nil];
        [_videoData addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
        [_videoData addObserver:self forKeyPath:@"playCount" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - private

- (void)updateTitleColor
{
    if(!_videoData.hasRead || !_showGrayForRead) {
        _titleLabel.textColor = [UIColor colorWithHexString:TitleLabelNormalTextColor];
    }
    else {
        _titleLabel.textColor = [UIColor colorWithHexString:TitleLabelReadedTextColor];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"hasRead"]) {
        
        NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        
        if(newValue && ![newValue isKindOfClass:[NSNull class]]) {
            [self updateTitleColor];
        }
    }
    else if ([keyPath isEqualToString:@"rate"]) {
        _rateView.rate = _videoData.rate;
    }
    else if ([keyPath isEqualToString:@"playCount"]) {
        _playCountLabel.text = [NSString stringWithFormat:@"%d人看过", [_videoData.playCount intValue]];
    }
}

@end




