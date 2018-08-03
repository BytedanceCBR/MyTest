//
//  VideoDetailView.m
//  Video
//
//  Created by 于 天航 on 12-8-3.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDetailView.h"
#import "SSTitleBarView.h"
#import "VideoTitleBarButton.h"
#import "VideoTitleLabel.h"
#import "SSButton.h"
#import "VideoDetailUnit.h"
#import "FastShareMenuController.h"
#import "CommentInputViewController.h"
#import "VideoData.h"
#import "UIColorAdditions.h"
#import "SSActivityIndicatorView.h"
#import "AuthorityViewController.h"
#import "AccountManager.h"
#import "NetworkUtilities.h"
#import "ShareOneHelper.h"
#import "SSSimpleCache.h"
#import "VideoHistoryManager.h"

#define InputViewHeight SSUIFloatNoDefault(@"vuDetailUnitInputViewHeight")
#define InputViewTitleFontSize SSUIFloatNoDefault(@"vuDetailUnitInputViewTitleFontSize")
#define InputViewTitleColor SSUIStringNoDefault(@"vuDetailUnitInputViewTitleColor")
#define InputViewCountLabelWidth 70.f

#define TrackDetailPageEventName @"detail_tab"

@interface VideoDetailView () <AuthorityViewControllerDelegate, CommentInputViewControllerDelegate>

@property (nonatomic, retain) VideoData *video;
@property (nonatomic, retain) SSTitleBarView *titleBar;
@property (nonatomic, retain) VideoDetailUnit *unit;
@property (nonatomic, retain) UIImageView *inputBackgroundImageView;
@property (nonatomic, retain) UIButton *inputButton;
@property (nonatomic, retain) CommentInputViewController *commentViewController;

@end


@implementation VideoDetailView

- (void)dealloc
{
    self.video = nil;
    self.titleBar = nil;
    self.unit = nil;
    self.inputBackgroundImageView = nil;
    self.inputButton = nil;
    self.commentViewController = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame video:(VideoData *)video
{
    self = [super initWithFrame:frame];
    if (self) {
        self.video = video;
        [self loadView];
    }
    return self;
}

#pragma mark - View Lifecycle

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
    
    VideoTitleBarButton *backButton = [VideoTitleBarButton buttonWithType:VideoTitleBarButtonTypeLeftBack];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBar setLeftView:backButton];
    
    VideoTitleBarButton *shareButton = [VideoTitleBarButton buttonWithType:VideoTitleBarButtonTypeRightNormalNarrow];
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBar setRightView:shareButton];
    
    VideoTitleLabel *titleLabel = [[[VideoTitleLabel alloc] init] autorelease];
    titleLabel.text = @"视频详情";
    [titleLabel sizeToFit];
    [_titleBar setCenterView:titleLabel];
    
    tmpFrame.origin.y = CGRectGetMaxY(_titleBar.frame);
    tmpFrame.size.height = vFrame.size.height - _titleBar.frame.size.height - InputViewHeight;
    
    self.unit = [[[VideoDetailUnit alloc] initWithFrame:tmpFrame] autorelease];
    _unit.videoData = _video;
    [self addSubview:_unit];
    _unit.trackEventName = TrackDetailPageEventName;
    
    [_unit refreshUI];
    
    tmpFrame.origin.y = CGRectGetMaxY(_unit.frame);
    tmpFrame.size.height = InputViewHeight;
    
    self.inputBackgroundImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dock_comment.png"]] autorelease];
    _inputBackgroundImageView.frame = tmpFrame;
    [self addSubview:_inputBackgroundImageView];
    
    CGFloat countLabelTopMargin = 6.f;
    
    UILabel *commentTitleLabel = [[[UILabel alloc] init] autorelease];
    commentTitleLabel.backgroundColor = [UIColor clearColor];
    commentTitleLabel.textAlignment = UITextAlignmentCenter;
    commentTitleLabel.text = @"评论";
    commentTitleLabel.textColor = [UIColor whiteColor];
    commentTitleLabel.font = ChineseFontWithSize(12.f);
    tmpFrame.origin.y = CGRectGetMinY(_inputBackgroundImageView.frame) + countLabelTopMargin;
    tmpFrame.size.height = InputViewHeight/2 - countLabelTopMargin;
    tmpFrame.size.width = InputViewCountLabelWidth;
    commentTitleLabel.frame = tmpFrame;
    [self addSubview:commentTitleLabel];
    
    UILabel *commentCountLabel = [[[UILabel alloc] init] autorelease];
    commentCountLabel.backgroundColor = [UIColor clearColor];
    commentCountLabel.textAlignment = UITextAlignmentCenter;
    commentCountLabel.text = [_video.commentCount stringValue];
    commentCountLabel.textColor = [UIColor whiteColor];
    commentCountLabel.font = ChineseFontWithSize(12.f);
    tmpFrame.origin.y = CGRectGetMaxY(commentTitleLabel.frame);
    commentCountLabel.frame = tmpFrame;
    [self addSubview:commentCountLabel];
    
    self.inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tmpFrame.origin.x = InputViewCountLabelWidth;
    tmpFrame.origin.y = CGRectGetMinY(_inputBackgroundImageView.frame);
    tmpFrame.size.width = vFrame.size.width - InputViewCountLabelWidth;
    tmpFrame.size.height = InputViewHeight;
    _inputButton.frame = tmpFrame;
    [_inputButton setImage:[UIImage imageNamed:@"write.png"] forState:UIControlStateNormal];
    [_inputButton setTitle:@"写评论" forState:UIControlStateNormal];
    [_inputButton setTitleColor:[UIColor colorWithHexString:InputViewTitleColor] forState:UIControlStateNormal];
    _inputButton.titleLabel.font = ChineseFontWithSize(InputViewTitleFontSize);
    [_inputButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_inputButton setImageEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
    [_inputButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
    [_inputButton addTarget:self action:@selector(inputButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_inputButton];
    
    [self bringSubviewToFront:_titleBar];
}

- (void)didAppear
{
    [super didAppear];
    
    if (_video) {
        if (![_video.hasRead boolValue] && [_video.downloadDataStatus intValue] == VideoDownloadDataStatusHasDownload) {
            _video.hasRead = [NSNumber numberWithBool:YES];
            [[SSModelManager sharedManager] save:nil];
        }
        
        _video.playCount = [NSNumber numberWithInt:[_video.playCount intValue] + 1];
        [[SSModelManager sharedManager] save:nil];
        [[VideoHistoryManager sharedManager] addHistory:_video];
    }
    
    [_unit didAppear];
    
    trackEvent([SSCommon appName], TrackDetailPageEventName, @"enter");
}

- (void)didDisappear
{
    [super didDisappear];
    [_unit didDisappear];
}

#pragma mark - private

- (void)syncCommentInputViewControllerCondition
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    [dict setObject:[NSString stringWithFormat:@"%@", _video.groupID] forKey:kQuickInputViewConditionItemID];
    [dict setObject:[NSNumber numberWithInt:CommentInputMessageTypeCommentForItem] forKey:kQuickInputViewConditionInputMessageTypeKey];
//    [dict setObject:[ShareOneHelper quickInputTextDescription:_video.title] forKey:kQuickInputViewConditionInputViewText];
    
    [_commentViewController setCondition:dict];
    [dict release];
}

- (void)buildCommentInputViewController
{
    if(!_commentViewController)
    {
        self.commentViewController = [[[CommentInputViewController alloc] init] autorelease];
        _commentViewController.delegate = self;
        
        VideoTitleLabel *titleLabel = [[[VideoTitleLabel alloc] init] autorelease];
        titleLabel.text = @"评论视频";
        [titleLabel sizeToFit];
        [_commentViewController.titleBarView setCenterView:titleLabel];
    }
}

#pragma mark - protected

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

#pragma mark - private

- (void)sendMail:(id)sender
{
    [[FastShareMenuController sharedController] sendMail:sender];
}

- (void)sendMessage:(id)sender
{
    [[FastShareMenuController sharedController] sendMessage:sender];
}

- (void)sendSNS:(id)sender
{
    [[FastShareMenuController sharedController] sendSNS:sender];
}

//- (void)textCopy:(id)sender
//{
//    [[FastShareMenuController sharedController] textCopy:sender];
//}

- (void)sendWeiXin:(id)sender
{
    [[FastShareMenuController sharedController] sendWeiXin:sender];
}

#pragma mark - Actions

- (void)backButtonClicked:(id)sender
{
    UIViewController *topViewController = [SSCommon topViewControllerFor:self];
    [topViewController.navigationController popViewControllerAnimated:YES];
}

- (void)inputButtonClicked:(id)sender
{
    if (!SSNetworkConnected()) {
        [[SSActivityIndicatorView sharedView] showInCenterWithMessage:@"没有网络连接，不能评论"];
    }
    else {
        [_unit playerPause];
        
        [self buildCommentInputViewController];
        [self syncCommentInputViewControllerCondition];
        UIViewController *topController = [SSCommon topViewControllerFor:self];
        [topController presentModalViewController:_commentViewController animated:YES];
        trackEvent([SSCommon appName], TrackDetailPageEventName, @"comment_button");
    }
}

- (void)shareButtonClicked:(id)sender
{
    NSString *text = [ShareOneHelper shareTextWithDescription:_video.title
                                                    urlString:_video.shareURL
                                                      appName:NSLocalizedString(@"WeiboName", nil)
                                                    isComment:NO];
    
    NSString *subject = [NSString stringWithString:NSLocalizedString(@"EmailShareSubject", nil)];
    NSString *emailBody = [NSString stringWithFormat:NSLocalizedString(@"EmailShareBody", nil), NSLocalizedString(@"WeiboName", nil), _video.title, _video.shareURL];
    NSString *smsBody = [NSString stringWithFormat:NSLocalizedString(@"SmsShareBody", nil), NSLocalizedString(@"WeiboName", nil), _video.title, _video.shareURL];
    NSString * weixinDescStr = nil;
    if ([_video.title length] > 70) {
        weixinDescStr = [_video.title substringToIndex:70];
    }
    else {
        weixinDescStr = [NSString stringWithFormat:@"%@", _video.title];
    }
    
    CGRect taregetRect = _titleBar.rightView.frame;
    [[FastShareMenuController sharedController] showInView:self
                                                targetRect:taregetRect
                                                  animated:YES
                                                   groupID:[_video.groupID stringValue]
                                                       tag:SSLogicStringNODefault(@"vlTag")
                                                   message:text
                                              emailSubject:subject
                                              emailContent:emailBody
                                           emailAttachment:[[SSSimpleCache sharedCache] dataForUrl:_video.coverImageURL]
                                                SMSContent:smsBody
                                                  copyText:_video.title
                                               weiXinTitle:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                         weiXinDescription:weixinDescStr
                                    weiXinWebPageUrlString:_video.shareURL
                                      weixinThumbnailImage:[UIImage imageWithData:[[SSSimpleCache sharedCache] dataForUrl:_video.coverImageURL]]];
    
    trackEvent([SSCommon appName], TrackDetailPageEventName, @"share_button");
}

#pragma mark - CommentInputViewDelegate

- (void)commentInputViewController:(CommentInputViewController *)controller responsedReceived:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    if([[userInfo objectForKey:kActionTypeKey] intValue] == ActionTypePostMessage
       && [[userInfo objectForKey:kResponseTypeKey] intValue] == ResponseTypeSuccess) {
        NSMutableDictionary *commentData = [NSMutableDictionary dictionaryWithDictionary:[userInfo objectForKey:@"data"]];
        [_unit insertComment:commentData];
    }
    
    [controller dismissModalViewControllerAnimated:YES];
    
    self.commentViewController.delegate = nil;
    self.commentViewController = nil;
}

- (void)commentInputViewControllerCancelled:(CommentInputViewController *)controller
{
    [controller dismissModalViewControllerAnimated:YES];
    
    self.commentViewController.delegate = nil;
    self.commentViewController = nil;
}

#pragma mark - AuthorityViewControllerDelegate

- (void)authorityViewControllerDone:(AuthorityViewController *)controller userInfo:(id)userinfo
{
    //must after animation finished, then invoke dismissModalView, otherwise will have bug
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    [dict setObject:controller forKey:@"controller"];
    if (userinfo)
    {
        [dict setObject:userinfo forKey:@"userinfo"];
    }
    [self performSelector:@selector(dismissAuthorityModalView:) withObject:dict afterDelay:0.5f];
    [dict release];
}

- (void)dismissAuthorityModalView:(NSDictionary *)infoDict
{
    AuthorityViewController *controller = (AuthorityViewController *)[infoDict objectForKey:@"controller"];
    [controller dismissModalViewControllerAnimated:YES];

    if([[AccountManager sharedManager] loggedIn])
    {
        [controller dismissModalViewControllerAnimated:NO];
        UIViewController *topController = [SSCommon topViewControllerFor:self];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [topController presentModalViewController:_commentViewController animated:YES];
        });
    }
}

@end


