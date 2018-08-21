//
//  VideoDownloadView.m
//  Video
//
//  Created by 于 天航 on 12-8-1.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDownloadView.h"
#import "VideoDownloadDataManager.h"
#import "VideoData.h"
#import "SSProgressView.h"
#import "UIColorAdditions.h"
#import "VideoActivityIndicatorView.h"

#define ProgressViewWidth SSUIFloatNoDefault(@"vuListCellProgressBarWidth")
#define ProgressViewHeight SSUIFloatNoDefault(@"vuListCellProgressBarHeight")
#define ProgressViewTextColor SSUIStringNoDefault(@"vuListCellProgressBarTextColor")
#define ProgressViewFontSize SSUIFloatNoDefault(@"vuListCellProgressBarFontSize")
#define ProgressViewProgressBarTopMargin SSUIFloatNoDefault(@"vuListCellProgressBarTopMargin")
#define DownloadButtonWidth SSUIFloatNoDefault(@"vuDownloadButtonWidth")
#define DownloadButtonHeight SSUIFloatNoDefault(@"vuDownloadButtonHeight")
#define DownloadButtonLargeFontSize SSUIFloatNoDefault(@"vuDownloadButtonLargeFontSize")
#define DownloadButtonMiddleFontSize SSUIFloatNoDefault(@"vuDownloadButtonMiddleFontSize")
#define DownloadButtonDownloadingStatusTitleLeftMargin SSUIFloatNoDefault(@"vuDownloadButtonDownloadingStatusTitleLeftMargin")

@interface VideoDownloadView ()

@property (nonatomic, retain) VideoData *video;
@property (nonatomic) VideoDownloadViewType type;
@property (nonatomic, assign) VideoDownloadDataStatus downloadDataStatus;
@property (nonatomic, retain) UIImageView *statusImageView;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UILabel *scheduleLabel;
@property (nonatomic, retain) SSProgressView *progressView;
@property (nonatomic, retain) UIButton *downloadButton;

@end

@implementation VideoDownloadView

@synthesize video = _video;
@synthesize trackEventName = _trackEventName;
@synthesize type = _type;
@synthesize statusImageView = _statusImageView;
@synthesize statusLabel = _statusLabel;
@synthesize scheduleLabel = _scheduleLabel;
@synthesize downloadDataStatus = _downloadDataStatus;
@synthesize progressView = _progressView;
@synthesize downloadButton = _downloadButton;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	self.video = nil;
    self.trackEventName = nil;
    self.statusImageView = nil;
    self.statusLabel = nil;
    self.scheduleLabel = nil;
	self.progressView = nil;
	self.downloadButton = nil;

	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.statusImageView = [[[UIImageView alloc] init] autorelease];
        [self addSubview:_statusImageView];
        
        self.statusLabel = [[[UILabel alloc] init] autorelease];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.font = ChineseFontWithSize(ProgressViewFontSize);
        _statusLabel.textColor = [UIColor colorWithHexString:ProgressViewTextColor];
        _statusLabel.hidden = YES;
        [self addSubview:_statusLabel];
        
        self.scheduleLabel = [[[UILabel alloc] init] autorelease];
        _scheduleLabel.backgroundColor = [UIColor clearColor];
        _scheduleLabel.font = ChineseFontWithSize(ProgressViewFontSize);
        _scheduleLabel.textColor = [UIColor colorWithHexString:ProgressViewTextColor];
        _scheduleLabel.hidden = YES;
        [self addSubview:_scheduleLabel];
        
    	self.progressView = [[[SSProgressView alloc] initWithProgressViewStyle:SSProgressViewStyleTowardRight] autorelease];
        _progressView.frame = CGRectMake(0, 0, ProgressViewWidth, ProgressViewHeight);
    	_progressView.progressBackgroundImage = [UIImage imageNamed:@"gray_schedule.png"];
    	_progressView.progressForegroundImage = [UIImage imageNamed:@"blue_schedule.png"];
    	_progressView.progressHeadImage = [UIImage imageNamed:@"shine.png"];
    	_progressView.hidden = YES;
    	[self addSubview:_progressView];
        
    	self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadButton addTarget:self action:@selector(downloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_downloadButton];
    }
    return self;
}

#pragma mark - public

- (void)setVideo:(VideoData *)video type:(VideoDownloadViewType)type
{
	self.type = type;
	self.video = video;
}

- (void)refreshUI
{
    if (_progressView.hidden) {
        _statusImageView.frame = CGRectZero;
        _statusLabel.frame = CGRectZero;
        _scheduleLabel.frame = CGRectZero;
        _progressView.frame = CGRectZero;

        CGRect vFrame = self.bounds;
        CGRect tmpFrame = CGRectZero;

        tmpFrame.size.width = DownloadButtonWidth;
        tmpFrame.size.height = DownloadButtonHeight;
        tmpFrame.origin.x = vFrame.size.width - DownloadButtonWidth;
        _downloadButton.frame = tmpFrame;
    }
    else {
        CGRect vFrame = self.bounds;
        CGRect tmpFrame = CGRectZero;
        
        [_statusImageView sizeToFit];
        [_statusLabel sizeToFit];
        [_scheduleLabel sizeToFit];
        
        tmpFrame = _statusImageView.frame;
        tmpFrame.origin.y = vFrame.size.height - ProgressViewHeight - _statusImageView.frame.size.height - ProgressViewProgressBarTopMargin;
        _statusImageView.frame = tmpFrame;
        
        tmpFrame = _statusLabel.frame;
        tmpFrame.origin.x = CGRectGetMaxX(_statusImageView.frame);
        tmpFrame.origin.y = vFrame.size.height - ProgressViewHeight - _statusLabel.frame.size.height - ProgressViewProgressBarTopMargin;
        _statusLabel.frame = tmpFrame;
        
        tmpFrame = _scheduleLabel.frame;
        tmpFrame.origin.x = ProgressViewWidth - _scheduleLabel.frame.size.width;
        tmpFrame.origin.y = vFrame.size.height - ProgressViewHeight - _scheduleLabel.frame.size.height;
        _scheduleLabel.frame = tmpFrame;
        
        tmpFrame.origin.x = 0.f;
        tmpFrame.origin.y = CGRectGetMaxY(_statusLabel.frame) + ProgressViewProgressBarTopMargin;
        tmpFrame.size.width = ProgressViewWidth;
        tmpFrame.size.height = ProgressViewHeight;
        _progressView.frame = tmpFrame;
        
        tmpFrame.origin.x = vFrame.size.width - DownloadButtonWidth;
        tmpFrame.origin.y = 0.f;
        tmpFrame.size.width = DownloadButtonWidth;
        tmpFrame.size.height = DownloadButtonHeight;
        _downloadButton.frame = tmpFrame;
    }
}

#pragma mark - private

- (void)setVideo:(VideoData *)video
{
    if (_video) {
        [_video removeObserver:self forKeyPath:@"downloadDataStatus"];
        [_video removeObserver:self forKeyPath:@"size"];
    }
    
    [_video release];
    _video = [video retain];
    
    if (_video) {
        _scheduleLabel.text = [NSString stringWithFormat:@"%0.1fM/%0.1fM", [_video.size floatValue]*[_video.downloadProgress floatValue], [_video.size floatValue]];
        _scheduleLabel.hidden = (_type != VideoDownloadViewTypeDownloading) || [_video.size floatValue] == 0.f;
        [_progressView setProgress:[_video.downloadProgress floatValue]*100 animated:YES];
        
        self.downloadDataStatus = [_video.downloadDataStatus intValue];
        
        [_video addObserver:self forKeyPath:@"downloadDataStatus" options:NSKeyValueObservingOptionNew context:nil];
        [_video addObserver:self forKeyPath:@"size" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)setType:(VideoDownloadViewType)type
{
    _type = type;
    
    _statusLabel.hidden = !(_type == VideoDownloadViewTypeDownloading);
    _scheduleLabel.hidden = !(_type == VideoDownloadViewTypeDownloading);
    _progressView.hidden = !(_type == VideoDownloadViewTypeDownloading);
}

- (void)setDownloadDataStatus:(VideoDownloadDataStatus)downloadDataStatus
{
    _downloadDataStatus = downloadDataStatus;
    
    NSString *titleColorString = SSUIStringNoDefault(@"vuStandardWhiteColor");
    NSString *normalBackgroundImageName = nil;
    NSString *highlightBackgroundImageName = nil;
    NSString *normalImageName = nil;
    NSString *titleString = nil;
    NSString *statusString = nil;
    NSString *statusImageName = nil;
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsZero;
    
    _progressView.progressStop = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    switch (_type) {
        case VideoDownloadViewTypeNormal:
        {
            switch (_downloadDataStatus) {
                case VideoDownloadDataStatusNone:
                {
                    titleString = @"下载";
                    normalBackgroundImageName = @"btn_blue_video.png";
                    highlightBackgroundImageName = @"btn_blue_press_video.png";
                    _downloadButton.enabled = YES;
                }
                    break;
                case VideoDownloadDataStatusDownloading:
                case VideoDownloadDataStatusWaiting:
                case VideoDownloadDataStatusPaused:
                {
                    titleString = @"下载中";
                    normalBackgroundImageName = @"downloading_video.png";
                    highlightBackgroundImageName = @"downloading_video.png";
                    _downloadButton.enabled = NO;
                }
                    break;
                case VideoDownloadDataStatusHasDownload:
                {
                    titleString = @"已下载";
                    normalBackgroundImageName = @"download_video.png";
                    highlightBackgroundImageName = @"download_video.png";
                    _downloadButton.enabled = NO;
                }
                    break;
                case VideoDownloadDataStatusDeadLink:
                {
                    titleString = @"已下架";
                    normalBackgroundImageName = @"download_video.png";
                    highlightBackgroundImageName = @"download_video.png";
                    _downloadButton.enabled = NO;
                }
                    break;
                case VideoDownloadDataStatusNoDownloadURL:
                {
                    titleString = @"下载";
                    normalBackgroundImageName = @"download_video.png";
                    highlightBackgroundImageName = @"download_video.png";
                    _downloadButton.enabled = NO;
                }
                    break;
                case VideoDownloadDataStatusDownloadFailed:
                {
                    titleString = @"下载失败";
                    titleColorString = SSUIStringNoDefault(@"vuDownloadButtonFailedStatusTitleColor");
                    normalBackgroundImageName = @"fail_download.png";
                    highlightBackgroundImageName = @"fail_download.png";
                    _downloadButton.enabled = NO;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case VideoDownloadViewTypeDownloading:
        {
            switch (_downloadDataStatus) {
                case VideoDownloadDataStatusDownloading:
                {
                    _progressView.progressStop = NO;
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(reportDownloadDataManagerNewProgress:)
                                                                 name:VideoDownloadDataManagerNewProgressNotification
                                                               object:nil];
                }
                case VideoDownloadDataStatusWaiting:
                {
                    titleString = @"暂停";
                    statusString = @"下载中";
                    normalBackgroundImageName = @"btn_blue_video.png";
                    highlightBackgroundImageName = @"btn_blue_press_video.png";
                    normalImageName = @"pause_video.png";
                    _downloadButton.enabled = YES;
                    
                    imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
                    titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
                }
                    break;
                case VideoDownloadDataStatusPaused:
                {
                    titleString = @"继续";
                    statusString = @"已暂停";
                    normalBackgroundImageName = @"btn_blue_video.png";
                    highlightBackgroundImageName = @"btn_blue_press_video.png";
                    normalImageName = @"play_video.png";
                    _downloadButton.enabled = YES;
                    
                    imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
                    titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
                }
                    break;
                case VideoDownloadDataStatusDownloadFailed:
                {
                    titleString = @"重试";
                    statusImageName = @"fail_icon.png";
                    normalBackgroundImageName = @"btn_blue_video.png";
                    highlightBackgroundImageName = @"btn_blue_press_video.png";
                    normalImageName = @"play_video.png";
                    _downloadButton.enabled = YES;
                    
                    imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
                    titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
                }
                    break;
                case VideoDownloadDataStatusDeadLink:
                {
                    titleString = @"已下架";
                    statusString = @"已下架";
                    normalBackgroundImageName = @"download_video.png";
                    highlightBackgroundImageName = @"download_video.png";
                    _downloadButton.enabled = NO;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    _statusImageView.image = [UIImage imageNamed:statusImageName];
    _statusLabel.text = statusString;
    
    [_downloadButton setTitleColor:[UIColor colorWithHexString:titleColorString] forState:UIControlStateNormal];
    [_downloadButton setTitle:titleString forState:UIControlStateNormal];
    [_downloadButton setBackgroundImage:[UIImage imageNamed:normalBackgroundImageName] forState:UIControlStateNormal];
    [_downloadButton setBackgroundImage:[UIImage imageNamed:highlightBackgroundImageName] forState:UIControlStateHighlighted];
    [_downloadButton setBackgroundImage:[UIImage imageNamed:highlightBackgroundImageName] forState:UIControlStateDisabled];
    [_downloadButton setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    
    [_downloadButton setImageEdgeInsets:imageEdgeInsets];
    [_downloadButton setTitleEdgeInsets:titleEdgeInsets];
    
    if ([_downloadButton.titleLabel.text length] > 2) {
        _downloadButton.titleLabel.font = ChineseFontWithSize(DownloadButtonMiddleFontSize);
    }
    else {
        _downloadButton.titleLabel.font = ChineseFontWithSize(DownloadButtonLargeFontSize);
    }
}

- (void)downloadButtonClicked:(id)sender
{
    if (_video) {
        NSString *trackLabel = nil;
        NSString *showMessage = nil;
        switch (_downloadDataStatus) {
            case VideoDownloadDataStatusNone:
            {
                trackLabel = @"download_button";
                showMessage = @"开始下载";
                [[VideoDownloadDataManager sharedManager] startWithVideoData:_video];
            }
                break;
            case VideoDownloadDataStatusPaused:
            {
                trackLabel = @"continue_button";
                showMessage = @"开始下载";
                [[VideoDownloadDataManager sharedManager] startWithVideoData:_video];
            }
                break;
            case VideoDownloadDataStatusDownloadFailed:
            {
                trackLabel = @"restart_button";
                showMessage = @"开始下载";
                [[VideoDownloadDataManager sharedManager] retryWithVideoData:_video];
            }
                break;
            case VideoDownloadDataStatusDownloading:
            case VideoDownloadDataStatusWaiting:
            {
                [[VideoDownloadDataManager sharedManager] stopWithVideoData:_video];
                trackLabel = @"pause_button";
            }
                break;
            
            default:
                break;
        }
        
        if (trackLabel) {
            trackEvent([SSCommon appName], _trackEventName, trackLabel);
        }
        
        if (showMessage) {
            [[VideoActivityIndicatorView sharedView] showWithMessage:showMessage duration:1.f];
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"downloadDataStatus"]) {
        self.downloadDataStatus = [[change valueForKey:NSKeyValueChangeNewKey] intValue];
        [self refreshUI];
    }
    else if ([keyPath isEqualToString:@"size"]) {
        if ([_video.size floatValue] != 0.f && _type == VideoDownloadViewTypeDownloading) {
            _scheduleLabel.text = [NSString stringWithFormat:@"%0.1fM/%0.1fM", [_video.size floatValue]*[_video.downloadProgress floatValue], [_video.size floatValue]];
            _scheduleLabel.hidden = NO;
        }
    }
}

- (void)reportDownloadDataManagerNewProgress:(NSNotification *)notification
{
    NSNumber *newProgress = [notification.userInfo objectForKey:kVideoDownloadDataManagerNewProgressNumberKey];
    
    if ([newProgress floatValue] != 0.f) {
        if ([_video.size floatValue] > 0) {
            _scheduleLabel.text = [NSString stringWithFormat:@"%0.1fM/%0.1fM", [_video.size floatValue]*[_video.downloadProgress floatValue], [_video.size floatValue]];
        }
        
        [_progressView setProgress:[newProgress floatValue]*100 animated:YES];
//        SSLog(@"item progress:%@ size:%@", newProgress, _video.size);
    }
}

@end


