//
//  VideoSocialView.m
//  Video
//
//  Created by Kimi on 12-10-20.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoSocialView.h"
#import "VideoData.h"
#import "VideoSocialActionButton.h"
#import "VideoRepinButton.h"
#import "VideoDownloadView.h"
#import "UIColorAdditions.h"
#import "DetailActionRequestManager.h"
#import "VideoLocalFavoriteManager.h"
#import "SSListNotifyBarView.h"
#import "UIImageAdditions.h"
#import "ShareOneHelper.h"
#import "FastShareActionSheet.h"
#import "SSSimpleCache.h"
#import "VideoActivityIndicatorView.h"

#define TitleButtonTitleFontSize 15.f


@interface VideoSocialView () <DetailActionRequestManagerDelegate> {
    VideoSocialViewType _type;
}

@property (nonatomic, retain) DetailActionRequestManager *actionManager;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) VideoSocialActionButton *diggButton;
@property (nonatomic, retain) VideoSocialActionButton *buryButton;
@property (nonatomic, retain) VideoDownloadView *downloadView;
@property (nonatomic, retain) VideoSocialActionButton *favoriteButton;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *shareButton;

@end

@implementation VideoSocialView

- (void)dealloc
{
    self.delegate = nil;
    self.videoData = nil;
    self.trackEventName = nil;
    self.actionManager = nil;
    self.backgroundView = nil;
    self.diggButton = nil;
    self.buryButton = nil;
    self.downloadView = nil;
    self.favoriteButton = nil;
    self.backButton = nil;
    self.shareButton = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame type:(VideoSocialViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        
        self.actionManager = [[[DetailActionRequestManager alloc] init] autorelease];
        _actionManager.delegate = self;
        
        self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage centerStrechedImageNamed:@"toolbg_player"]] autorelease];
        [self addSubview:_backgroundView];
        
        self.diggButton = [VideoSocialActionButton buttonWithType:UIButtonTypeCustom];
        [_diggButton setTitle:@"顶" forState:UIControlStateNormal];
        [_diggButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_diggButton addZoomSubView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_one.png"]] autorelease]];
        [self addSubview:_diggButton];
        
        self.buryButton = [VideoSocialActionButton buttonWithType:UIButtonTypeCustom];
        [_buryButton setTitle:@"踩" forState:UIControlStateNormal];
        [_buryButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buryButton addZoomSubView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_one.png"]] autorelease]];
        [self addSubview:_buryButton];
        
        self.downloadView = [[[VideoDownloadView alloc] init] autorelease];
        [self addSubview:_downloadView];
        
        self.favoriteButton = [VideoRepinButton buttonWithType:UIButtonTypeCustom];
        [_favoriteButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_favoriteButton];
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        _backButton.titleLabel.font = ChineseFontWithSize(TitleButtonTitleFontSize);
        [_backButton setBackgroundImage:[UIImage imageNamed:@"backbtn_player"] forState:UIControlStateNormal];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"backbtn_player_press"] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setTitle:@"分享" forState:UIControlStateNormal];
        _shareButton.titleLabel.font = ChineseFontWithSize(TitleButtonTitleFontSize);
        [_shareButton setBackgroundImage:[UIImage imageNamed:@"sharebtn_player"] forState:UIControlStateNormal];
        [_shareButton setBackgroundImage:[UIImage imageNamed:@"sharebtn_player_press"] forState:UIControlStateHighlighted];
        [_shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareButton];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame type:VideoSocialViewTypeHalfScreen];
}

#pragma mark - private

- (void)showNotifyMessage:(NSString *)message
{
    CGRect notifyFrame = CGRectMake(0, 64, self.bounds.size.width, SSUIFloatNoDefault(@"vuListNotifyBarHeight"));
    
    UIImage *portraitNotifyBackgroundImage = [UIImage imageNamed:@"bar_syn.png"];
    portraitNotifyBackgroundImage = [portraitNotifyBackgroundImage stretchableImageWithLeftCapWidth:floorf(portraitNotifyBackgroundImage.size.width/2)
                                                                                       topCapHeight:floorf(portraitNotifyBackgroundImage.size.height/2)];
    UIImageView *portraitNotifyBackgroundImageView = [[[UIImageView alloc] initWithImage:portraitNotifyBackgroundImage] autorelease];
    portraitNotifyBackgroundImageView.frame = CGRectMake(0, 0, notifyFrame.size.width, notifyFrame.size.height);
    
    [[SSListNotifyBarView sharedView] showInRect:notifyFrame
                                         message:message
                                       textColor:SSUIStringNoDefault(@"vuStandardBlueColor")
                                 textShadowColor:SSUIStringNoDefault(@"vuStandardBlueColor")
                                textShadowOffset:CGSizeZero
                              bottomShadowHidden:YES
                          portraitBackgroundView:portraitNotifyBackgroundImageView
                         landscapeBackgroundView:nil];
}

- (void)actionButtonClicked:(id)sender
{
    if (sender == _diggButton) {
        
        [_diggButton showOnceZoomAnimation:SocialActionButtonActionAnimationTypeZoom];
        
        _videoData.userDigged = [NSNumber numberWithBool:YES];
        _videoData.diggCount = [NSNumber numberWithInt:[_videoData.diggCount intValue] + 1];
        [[SSModelManager sharedManager] save:nil];
        
        [self updateActionButtons];
        
        [_actionManager startItemActionByType:DetailActionTypeDig];
        
        trackEvent([SSCommon appName], _trackEventName, @"digg_button");
    }
    else if (sender == _buryButton) {
        
        [_buryButton showOnceZoomAnimation:SocialActionButtonActionAnimationTypeZoom];
        
        _videoData.userBuried = [NSNumber numberWithBool:YES];
        _videoData.buryCount = [NSNumber numberWithInt:[_videoData.buryCount intValue] + 1];
        [[SSModelManager sharedManager] save:nil];
        
        [self updateActionButtons];
        
        [_actionManager startItemActionByType:DetailActionTypeBury];
        
        trackEvent([SSCommon appName], _trackEventName, @"bury_button");
    }
    else if (sender == _favoriteButton) {
        trackEvent([SSCommon appName], _trackEventName, @"favorite_button");
        
        if ([_videoData.userRepined boolValue] == YES) {
            
            [[VideoLocalFavoriteManager sharedManager] unRepinData:_videoData];
            [self updateActionButtons];
            [_actionManager startItemActionByType:DetailActionTypeUnFavourite];
            
            [[VideoActivityIndicatorView sharedView] showWithMessage:@"已取消收藏" duration:1.f];
        }
        else {
            [[VideoLocalFavoriteManager sharedManager] repinData:_videoData];
            [self updateActionButtons];
            [_actionManager startItemActionByType:DetailActionTypeFavourite];
            
            [[VideoActivityIndicatorView sharedView] showWithMessage:@"已收藏" duration:1.f];
        }
    }
}

- (void)updateActionButtons
{
    [_diggButton setSubtitle:[NSString stringWithFormat:@"(%i)", [_videoData.diggCount intValue]]];
    [_buryButton setSubtitle:[NSString stringWithFormat:@"(%i)", [_videoData.buryCount intValue]]];
    
    if ([_videoData.userDigged boolValue]) {
        [_diggButton setTitle:@"已顶" forState:UIControlStateNormal];
        [_buryButton setTitle:@"踩" forState:UIControlStateNormal];
        
        [_diggButton setSocialActionButtonStatus:SocialActionButtonStatusHightlightedDisabled];
        [_buryButton setSocialActionButtonStatus:SocialActionButtonStatusUnHightlightedDisabled];
    }
    else if ([_videoData.userBuried boolValue]) {
        [_diggButton setTitle:@"顶" forState:UIControlStateNormal];
        [_buryButton setTitle:@"已踩" forState:UIControlStateNormal];
        
        [_buryButton setSocialActionButtonStatus:SocialActionButtonStatusHightlightedDisabled];
        [_diggButton setSocialActionButtonStatus:SocialActionButtonStatusUnHightlightedDisabled];
    }
    else {
        [_diggButton setTitle:@"顶" forState:UIControlStateNormal];
        [_buryButton setTitle:@"踩" forState:UIControlStateNormal];
        
        [_diggButton setSocialActionButtonStatus:SocialActionButtonStatusClean];
        [_buryButton setSocialActionButtonStatus:SocialActionButtonStatusClean];
    }
    
    _favoriteButton.selected = [_videoData.userRepined boolValue];
    
    [_diggButton refreshUI];
    [_buryButton refreshUI];
    [_favoriteButton refreshUI];
}

#pragma mark - Actions

- (void)backButtonClicked:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(videoSocialView:didClickedBackButton:)]) {
        [_delegate videoSocialView:self didClickedBackButton:sender];
    }
    
    trackEvent([SSCommon appName], @"fullscreen_tab", @"back_button");
}

#pragma mark - private

- (void)shareButtonClicked:(id)sender
{
    NSString *text = [ShareOneHelper shareTextWithDescription:_videoData.title
                                                    urlString:_videoData.shareURL
                                                      appName:NSLocalizedString(@"WeiboName", nil)
                                                    isComment:NO];
    
    NSString *subject = [NSString stringWithString:NSLocalizedString(@"EmailShareSubject", nil)];
    NSString *emailBody = [NSString stringWithFormat:NSLocalizedString(@"EmailShareBody", nil), NSLocalizedString(@"WeiboName", nil), _videoData.title, _videoData.shareURL];
    NSString *smsBody = [NSString stringWithFormat:NSLocalizedString(@"SmsShareBody", nil), NSLocalizedString(@"WeiboName", nil), _videoData.title, _videoData.shareURL];
    NSString * weixinDescStr = nil;
    if ([_videoData.title length] > 70) {
        weixinDescStr = [_videoData.title substringToIndex:70];
    }
    else {
        weixinDescStr = [NSString stringWithFormat:@"%@", _videoData.title];
    }
    
    UIViewController *topViewController = [SSCommon topViewControllerFor:self];
    
    [[FastShareActionSheet sharedActionsheet] showInView:topViewController.view
                                              targetRect:CGRectZero
                                                  animated:YES
                                                   groupID:[_videoData.groupID stringValue]
                                                       tag:SSLogicStringNODefault(@"vlTag")
                                                   message:text
                                              emailSubject:subject
                                              emailContent:emailBody
                                           emailAttachment:[[SSSimpleCache sharedCache] dataForUrl:_videoData.coverImageURL]
                                                SMSContent:smsBody
                                                  copyText:_videoData.title
                                               weiXinTitle:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                         weiXinDescription:weixinDescStr
                                    weiXinWebPageUrlString:_videoData.shareURL
                                      weixinThumbnailImage:[UIImage imageWithData:[[SSSimpleCache sharedCache] dataForUrl:_videoData.coverImageURL]]];
    
    trackEvent([SSCommon appName], _trackEventName, @"share_button");
}

#pragma mark - public

- (void)setTrackEventName:(NSString *)trackEventName
{
    [_trackEventName release];
    _trackEventName = [trackEventName copy];
    
    if (_downloadView) {
        _downloadView.trackEventName = _trackEventName;
    }
}

- (void)setVideoData:(VideoData *)videoData
{
    [_videoData release];
    _videoData = [videoData retain];
    
    if (_videoData) {
        [_downloadView setVideo:_videoData type:VideoDownloadViewTypeNormal];
       
        [self updateActionButtons];
        
        // action manager
        NSMutableDictionary *actionRequestCondition = [[NSMutableDictionary alloc] initWithCapacity:10];
        [actionRequestCondition setObject:[NSString stringWithFormat:@"%@", _videoData.groupID] forKey:kDetailActionItemIDKey];
        
        [_actionManager setCondition:actionRequestCondition];
        [actionRequestCondition release];
    }
}

- (void)refreshUI
{
    CGFloat leftPadding = _type == VideoSocialViewTypeHalfScreen ? 10.f : 0.f;
    CGFloat topPadding = 7.f;
    CGFloat buttonMargin = (_type == VideoSocialViewTypeHalfScreen ? 10.f : 20.f);
    
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    
    _backgroundView.frame = tmpFrame;
    
    if (_type == VideoSocialViewTypeFullScreen) {
        _backButton.hidden = NO;
        _shareButton.hidden = NO;
        [_backButton sizeToFit];
        [_shareButton sizeToFit];
        
        tmpFrame = _backButton.frame;
        tmpFrame.origin.y = (vFrame.size.height - tmpFrame.size.height)/2;
        _backButton.frame = tmpFrame;
        
        tmpFrame.origin.x = 90.f;
    }
    else {
        _backButton.hidden = YES;
        _shareButton.hidden = YES;
        tmpFrame.origin.x = leftPadding;
    }
    
    tmpFrame.origin.y = topPadding;
    tmpFrame.size.width = SSUIFloatNoDefault(@"vuDownloadButtonWidth");
    tmpFrame.size.height = SSUIFloatNoDefault(@"vuDownloadButtonHeight");
    _downloadView.frame = tmpFrame;
    
    tmpFrame.origin.x = CGRectGetMaxX(_downloadView.frame) + buttonMargin;
    _favoriteButton.frame = tmpFrame;
    
    if (_type == VideoSocialViewTypeFullScreen) {
        tmpFrame.origin.x = CGRectGetMaxX(_favoriteButton.frame) + 20.f;
    }
    else {
        tmpFrame.origin.x = vFrame.size.width - 2*SSUIFloatNoDefault(@"vuDownloadButtonWidth") - leftPadding - buttonMargin;
    }
    _diggButton.frame = tmpFrame;
    
    tmpFrame.origin.x = CGRectGetMaxX(_diggButton.frame) + buttonMargin;
    _buryButton.frame = tmpFrame;
    
    if (_type == VideoSocialViewTypeFullScreen) {
        tmpFrame = _shareButton.frame;
        tmpFrame.origin.x = vFrame.size.width - tmpFrame.size.width;
        tmpFrame.origin.y = (vFrame.size.height - tmpFrame.size.height)/2;
        _shareButton.frame = tmpFrame;
    }
    
    [_downloadView refreshUI];
    [_favoriteButton refreshUI];
    [_diggButton refreshUI];
    [_buryButton refreshUI];
}

#pragma mark - DetailActionRequestManagerDelegate

- (void)detailActionRequestManager:(DetailActionRequestManager *)manager itemSummaryGotUserInfo:(id)userInfo error:(NSError *)error
{
    if ([[userInfo objectForKey:@"id"] intValue] == [_videoData.groupID intValue]) {
        if (!error) {
            [self updateActionButtons];
        }
    }
}

- (void)detailActionRequestManager:(DetailActionRequestManager *)manager itemActionGotUserInfo:(id)userInfo error:(NSError *)error
{
    if ([[userInfo objectForKey:@"id"] intValue] == [_videoData.groupID intValue]) {
        if (!error) {
            [self updateActionButtons];
        }
    }
}

@end
