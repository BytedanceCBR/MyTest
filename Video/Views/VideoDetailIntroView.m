//
//  VideoDetailIntroView.m
//  Video
//
//  Created by Kimi on 12-10-21.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDetailIntroView.h"
#import "VideoData.h"
#import "UIColorAdditions.h"
#import "UILabel+UILabelAdditions.h"
#import "UIImageAdditions.h"
#import "SVWebViewController.h"

#define TitleLabelBottomMargin 2.f
#define SourceButtonHeight 12.f
#define TitleLabelDetailTextColor SSUIStringNoDefault(@"vuIntroViewTitleLabelDetailTextColor")

@interface VideoDetailIntroView () {
    VideoDetailIntroViewType _type;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) UIButton *sourceUrlButton;
@property (nonatomic, retain) SVModalWebViewController *webViewController;
@end

@implementation VideoDetailIntroView

- (void)dealloc
{
    self.backgroundView = nil;
    self.sourceUrlButton = nil;
    self.webViewController = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame type:(VideoDetailIntroViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        
        self.titleLabel = [[[UILabel alloc] init] autorelease];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = ChineseFontWithSize(SSUIFloatNoDefault(@"vuDetailIntroViewTitleFontSize"));
        _titleLabel.textColor = [UIColor colorWithHexString:TitleLabelDetailTextColor];
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        
        self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage centerStrechedImageNamed:@"textbg_halfscreen_player"]] autorelease];
        [self addSubview:_backgroundView];
        
        self.sourceUrlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sourceUrlButton.titleLabel.font = ChineseFontWithSize(10.f);
        [_sourceUrlButton setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"vuIntroViewSourceButtonTitleColor")] forState:UIControlStateNormal];
        [_sourceUrlButton addTarget:self action:@selector(sourceUrlButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sourceUrlButton];
        
        [self sendSubviewToBack:_backgroundView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame type:VideoDetailIntroViewTypeHalfScreen];
}

#pragma mark - private

- (void)sourceUrlButtonClicked:(id)sender
{
    if (_videoData.url) {
        NSURL *URL = [NSURL URLWithString:_videoData.url];
        SVModalWebViewController *webViewController = [[[SVModalWebViewController alloc] initWithURL:URL] autorelease];
        self.webViewController = webViewController;
        webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        webViewController.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink;
        
        UIViewController *topViewController = [SSCommon topViewControllerFor:self];
        [topViewController presentModalViewController:webViewController animated:YES];
    }
}

#pragma mark - public

- (void)setVideoData:(VideoData *)videoData
{
    [_videoData release];
    _videoData = [videoData retain];
    
    if (_videoData) {
        _titleLabel.text = _videoData.title;
        [_sourceUrlButton setTitle:[NSString stringWithFormat:@"来自%@", _videoData.source] forState:UIControlStateNormal];
    }
}

- (void)refreshUI
{
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    
    CGFloat topPadding = _type == VideoDetailIntroViewTypeHalfScreen ? 7.f : 15.f;
    CGFloat bottomPadding = _type == VideoDetailIntroViewTypeHalfScreen ? 10.f : 15.f;
    CGFloat leftPadding = _type == VideoDetailIntroViewTypeHalfScreen ? 10.f : 15.f;
    
    if (_type == VideoDetailIntroViewTypeFullScreen) {
        _backgroundView.image = [UIImage centerStrechedImageNamed:@"textbg_fullscreen_player"];
    }
    else {
        _backgroundView.image = [UIImage centerStrechedImageNamed:@"textbg_halfscreen_player"];
    }

    _backgroundView.frame = vFrame;
    [_sourceUrlButton sizeToFit];
    [_titleLabel heightThatFitsWidth:(vFrame.size.width + 10.f)];
    
    if (_titleLabel.frame.size.height < 20.f) {
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    else {
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    tmpFrame.origin.x = topPadding;
    tmpFrame.origin.y = leftPadding;
    tmpFrame.size.width -= 2*leftPadding;
    tmpFrame.size.height = MIN(_titleLabel.frame.size.height, vFrame.size.height - topPadding - bottomPadding - SourceButtonHeight - TitleLabelBottomMargin);
    _titleLabel.frame = tmpFrame;
    
    tmpFrame = _sourceUrlButton.frame;
    tmpFrame.origin.x = vFrame.size.width - tmpFrame.size.width - leftPadding;
    tmpFrame.origin.y = CGRectGetMaxY(_titleLabel.frame) + TitleLabelBottomMargin;
    tmpFrame.size.height = SourceButtonHeight;
    _sourceUrlButton.frame = tmpFrame;
}

@end
