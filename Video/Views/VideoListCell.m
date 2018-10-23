//
//  VideoListCell.m
//  Video
//
//  Created by Tianhang Yu on 12-7-20.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoListCell.h"
#import "VideoData.h"
#import "VideoThumbView.h"
#import "VideoListIntroView.h"
#import "VideoDownloadView.h"
#import "VideoDownloadDataManager.h"
#import "UIColorAdditions.h"

#define ListCellLeftPadding SSUIFloatNoDefault(@"vuListCellLeftPadding")
#define ListCellTopPadding SSUIFloatNoDefault(@"vuListCellTopPadding")
#define ThumbViewWidth SSUIFloatNoDefault(@"vuListCellThumbViewWidth")
#define ThumbViewHeight SSUIFloatNoDefault(@"vuListCellThumbViewHeight")
#define ThumbViewLeftMargin SSUIFloatNoDefault(@"vuListCellThumbViewRightMargin")
#define DownloadButtonWidth SSUIFloatNoDefault(@"vuDownloadButtonWidth")
#define DownloadButtonHeight SSUIFloatNoDefault(@"vuDownloadButtonHeight")
#define SocialActionLabelTopMargin SSUIFloatNoDefault(@"vuSocialActionLabelTopMargin")
#define SocialActionLabelHeight SSUIFloatNoDefault(@"vuSocialActionLabelHeight")

@interface VideoListCell () {
    VideoListCellType _type;
}

@property (nonatomic, retain, readwrite) VideoData *videoData;
@property (nonatomic, retain) VideoThumbView *thumbView;
@property (nonatomic, retain) VideoListIntroView *introView;
@property (nonatomic, retain) UIButton *coverButton;
@property (nonatomic, retain) UILabel *socialActionLabel;
@property (nonatomic, retain) VideoDownloadView *downloadView;

@end

@implementation VideoListCell

- (void)dealloc
{
    self.trackEventName = nil;
    self.videoData = nil;
    self.thumbView = nil;
    self.introView = nil;
    self.socialActionLabel = nil;
    self.downloadView = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier type:VideoListCellTypeNormal];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(VideoListCellType)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _type = type;
        
        UIView *selBackView = [[[UIView alloc] init] autorelease];
        selBackView.backgroundColor = [UIColor colorWithHexString:@"cccccc"];
        self.selectedBackgroundView = selBackView;
        
        self.thumbView = [[[VideoThumbView alloc] initWithFrame:CGRectZero type:VideoThumbViewTypeList] autorelease];
        [self.contentView addSubview:_thumbView];
        
        self.introView = [[[VideoListIntroView alloc] init] autorelease];
        [self.contentView addSubview:_introView];
        
        self.downloadView = [[[VideoDownloadView alloc] init] autorelease];
        [self.contentView addSubview:_downloadView];
        
        self.socialActionLabel = [[[UILabel alloc] init] autorelease];
        _socialActionLabel.numberOfLines = 1;
        _socialActionLabel.font = ChineseFontWithSize(9.f);
        _socialActionLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _socialActionLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_socialActionLabel];
    }
    return self;
}

#pragma mark - public

- (void)setTrackEventName:(NSString *)trackEventName
{
    [_trackEventName release];
    _trackEventName = [trackEventName copy];
    
    if (_thumbView) {
        _thumbView.trackEventName = _trackEventName;
        _downloadView.trackEventName = _trackEventName;
    }
}

- (void)setVideoData:(VideoData *)videoData type:(VideoListCellType)type
{
    _type = type;
    self.videoData = videoData;
}

- (void)setVideoData:(VideoData *)videoData
{
    [_videoData release];
    _videoData = [videoData retain];
    
    if (_videoData) {
        _thumbView.videoData = _videoData;

        VideoIntroViewType introViewType = VideoIntroViewTypeList;
        
        if (_type == VideoListCellTypeDownloading) {
            introViewType = VideoIntroViewTypeDownloadingList;
        }
        
        [_introView setVideoData:_videoData type:introViewType];
        
        [_downloadView setVideo:_videoData type:VideoDownloadViewTypeDownloading];
        
        switch (_type) {
            case VideoListCellTypeHasDownload:
                _introView.showGrayForRead = YES;
                break;
            case VideoListCellTypeNormal:
            case VideoListCellTypeDownloading:
                _introView.showGrayForRead = NO;
                
            default:
                break;
        }
        
        _socialActionLabel.text = _videoData.socialActionStr;
    }
}

- (void)refreshUI
{
    CGRect vFrame = self.bounds;
    vFrame.size.height = SSUIFloatNoDefault(@"vuListCellHeight");
    if ([_videoData.socialActionStr length] > 0) {
        vFrame.size.height += SSUIFloatNoDefault(@"vuSocialActionLabelHeight") + SSUIFloatNoDefault(@"vuSocialActionLabelTopMargin");
    }

    CGRect tmpFrame = vFrame;
    
    tmpFrame.origin.x = ListCellLeftPadding;
    tmpFrame.origin.y = ListCellTopPadding;
    tmpFrame.size.width = ThumbViewWidth;
    tmpFrame.size.height = ThumbViewHeight;
    _thumbView.frame = tmpFrame;
    
    tmpFrame.origin.x = CGRectGetMaxX(_thumbView.frame) + ThumbViewLeftMargin;
    tmpFrame.size.width = vFrame.size.width - ThumbViewWidth - ThumbViewLeftMargin - 2*ListCellLeftPadding;
    
    if (_type == VideoDownloadViewTypeDownloading) {
        tmpFrame.size.height = _thumbView.frame.size.height - DownloadButtonHeight;
    }
    else {
        tmpFrame.size.height = _thumbView.frame.size.height;
    }
    _introView.frame = tmpFrame;
    
    if (_type == VideoListCellTypeDownloading) {
        tmpFrame.origin.y = CGRectGetMaxY(_introView.frame);
        tmpFrame.size.height = SSUIFloatNoDefault(@"vuDownloadButtonHeight");
        _downloadView.frame = tmpFrame;
        _downloadView.hidden = NO;
    }
    else {
        _downloadView.frame = CGRectZero;
        _downloadView.hidden = YES;
    }
    
    if ([_videoData.socialActionStr length] > 0) {
        tmpFrame.origin.x = ListCellLeftPadding;
        tmpFrame.origin.y = CGRectGetMaxY(_thumbView.frame) + SocialActionLabelTopMargin;
        tmpFrame.size.width = vFrame.size.width - 2*ListCellLeftPadding;
        tmpFrame.size.height = SocialActionLabelHeight;
        _socialActionLabel.frame = tmpFrame;
    }
    else {
        _socialActionLabel.frame = CGRectZero;
    }
    
    [_thumbView refreshUI];
    [_introView refreshUI];
    [_downloadView refreshUI];
}

@end


