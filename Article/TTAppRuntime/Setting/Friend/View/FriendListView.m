//
//  FriendListView.m
//  Article
//
//  Created by Yu Tianhang on 12-11-5.
//
//

#import <MessageUI/MessageUI.h>
#import "FriendListView.h"
#import "FriendListCell.h"
#import "SSLoadMoreCell.h"
#import "TTIndicatorView.h"

#import "TTSandBoxHelper.h"

#import "ArticleFriend.h"
#import "FriendDataManager.h"
#import <TTAccountBusiness.h>
#import "NetworkUtilities.h"
#import "SSCommonLogic.h"

#import "UIImageAdditions.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTSandBoxHelper.h"

typedef enum {
    FriendSection = 0,
    InSiteUserSection
} SectionType;

#define sUsedFriendSectionHeaderTitle NSLocalizedString(@"已加入的好友", nil)
#define sNeedSuggestSctionHeaderTitle NSLocalizedString(@"值得关注", nil)
#define WidgetFriendSectionHeader(x) [NSString stringWithFormat:NSLocalizedString(@"已使用%@的好友", nil), x]

#define SectionHeaderHeight 23.f
#define WidgetSectionHeaderHeight 37.f
#define NotifyBarViewHeight 35.f

#pragma mark - InviteListViewCell
@interface InviteListViewCell : SSThemedTableViewCell
//@property (nonatomic, retain) UIImageView *backgroundImageView;
//@property (nonatomic, retain) UIImageView *selectedBackgroundImageView;
@property (nonatomic, retain) UIImageView *inviteIcon;
@property (nonatomic, retain) UILabel *inviteText;
@property (nonatomic, retain) UIImageView *arrowView;
@property (nonatomic, retain) UIView * bottomLineView;
- (void)refreshUI;
@end

@implementation InviteListViewCell
//@synthesize backgroundImageView;
//@synthesize selectedBackgroundImageView;
@synthesize inviteIcon, inviteText, arrowView;

- (void)dealloc
{
    self.bottomLineView = nil;
    //    self.backgroundImageView = nil;
    //    self.selectedBackgroundImageView = nil;
    self.inviteIcon = nil;
    self.inviteText = nil;
    self.arrowView = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.needMargin = YES;
        self.inviteText = [[UILabel alloc] init];
        inviteText.backgroundColor = [UIColor clearColor];
        inviteText.font = [UIFont systemFontOfSize:15.f];
        [self addSubview:inviteText];
        
        self.inviteIcon = [[UIImageView alloc] init];
        [self addSubview:inviteIcon];
        
        [self setAccessoryType:UITableViewCellAccessoryNone];
        UIImageView *accessoryImage = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"arrow_drawer.png"]];
        accessoryImage.highlightedImage = [UIImage themedImageNamed:@"arrow_drawer_press.png"];
        self.arrowView = accessoryImage;
        [self addSubview:arrowView];
        
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_bottomLineView];
        
        [self themeChanged:nil];
    }
    return self;
}

- (void)refreshUI
{
    _bottomLineView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"dddddd" nightColorName:@"464646"]];
    inviteText.textColor = [UIColor tt_themedColorForKey:kColorText2];
    UIImageView *accessoryImage = (UIImageView *)self.arrowView;
    accessoryImage.image = [UIImage themedImageNamed:@"arrow_drawer.png"];
    accessoryImage.highlightedImage = [UIImage themedImageNamed:@"arrow_drawer_press.png"];
    
    CGRect vFrame = self.bounds;
    vFrame.size.height = 44.f;
    
    CGFloat leftPadding = [TTDeviceHelper isPadDevice] ? 19.f : 8.f;
    CGRect tmpFrame = vFrame;
    tmpFrame.origin.x = leftPadding;
    tmpFrame.origin.y = 4.f;
    tmpFrame.size.width -= 2*leftPadding;
    tmpFrame.size.height -= 2*4.f;
    
    [inviteIcon sizeToFit];
    [inviteText sizeToFit];
    
    tmpFrame = inviteIcon.frame;
    tmpFrame.origin.x = leftPadding + 12.f;
    tmpFrame.origin.y = (vFrame.size.height - inviteIcon.frame.size.height)/2;
    inviteIcon.frame = tmpFrame;
    
    tmpFrame = inviteText.frame;
    tmpFrame.origin.x = CGRectGetMaxX(inviteIcon.frame) + 12.f;
    tmpFrame.origin.y = (vFrame.size.height - inviteText.frame.size.height)/2;
    inviteText.frame = tmpFrame;
    
    tmpFrame = arrowView.frame;
    tmpFrame.origin.x = vFrame.size.width - tmpFrame.size.width - leftPadding - 12.f;
    tmpFrame.origin.y = (vFrame.size.height - tmpFrame.size.height)/2;
    arrowView.frame = tmpFrame;
    
    _bottomLineView.frame = [self _bottomLineViewFrame];
}

- (CGRect)_bottomLineViewFrame
{
    return CGRectMake(15, CGRectGetHeight(self.frame) - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.frame) - 30, [TTDeviceHelper ssOnePixel]);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bottomLineView.frame = [self _bottomLineViewFrame];
}
@end

#pragma mark - FriendListViewHeaderView
@interface FriendListViewHeaderView : SSViewBase
//@property (nonatomic, retain) UIImageView *bgImageView;
@property (nonatomic, retain) UILabel *textLabel;
- (id)initWithFrame:(CGRect)frame text:(NSString *)text;
@end
@implementation FriendListViewHeaderView
@synthesize textLabel;

- (id)initWithFrame:(CGRect)frame text:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.textLabel = [[UILabel alloc] init];
        textLabel.font = [UIFont systemFontOfSize:12];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = text;
        [textLabel sizeToFit];
        CGRect rect = textLabel.frame;
        rect.origin.x = 15.f;
        textLabel.frame = rect;
        textLabel.center = CGPointMake(textLabel.center.x, self.frame.size.height/2);
        [self addSubview:textLabel];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"eeeeee" nightColorName:@"2b2b2b"]];
    textLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"303030" nightColorName:@"707070"]];
}

@end

#pragma mark - WidgetFriendListViewHeaderView
@interface WidgetFriendListViewHeaderView : SSViewBase
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UIImageView *alternationView;
- (id)initWithFrame:(CGRect)frame text:(NSString *)text;
@end
@implementation WidgetFriendListViewHeaderView
@synthesize textLabel, alternationView;

- (id)initWithFrame:(CGRect)frame text:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel = [[UILabel alloc] init];
        textLabel.font = [UIFont boldSystemFontOfSize:12.f];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.text = text;
        
        [self addSubview:textLabel];
        
        self.alternationView = [[UIImageView alloc] initWithImage:[UIImage centerStrechedresourceImageNamed:@"alternation_friend.png"]];
        [self addSubview:alternationView];
        
        [self reloadThemeUI];
    }
    return self;
}

- (CGRect)_alternationViewFrame
{
    return CGRectMake(15, 37.f - 1.f, [TTUIResponderHelper splitViewFrameForView:self].size.width - 30, 1.f);
}

- (void)settingTextLabelFrame
{
    [textLabel sizeToFit];
    CGRect rect = textLabel.frame;
    rect.origin.x = 39.f + [TTUIResponderHelper splitViewFrameForView:self].origin.x;
    rect.origin.y = 10.f;
    textLabel.frame = rect;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self settingTextLabelFrame];
    self.alternationView.frame = [self _alternationViewFrame];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
    alternationView.image = [UIImage centerStrechedresourceImageNamed:@"alternation_friend.png"];
    textLabel.textColor = [UIColor colorWithHexString:@"444444"];
}

@end

#pragma mark - FriendListView
@interface FriendListView () <UITableViewDataSource, UITableViewDelegate, FriendDataManagerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, TTWeChatShareDelegate> {
    
    BOOL _needShowNotify;
    
    NSInteger _weixinIndex;
    NSInteger _messageIndex;
    NSInteger _mailIndex;
    
    // for widget track event
    BOOL _hasSentScrollEvent;
}

@property (nonatomic, retain, readwrite) UITableView *friendView;
@property (nonatomic, retain) NSMutableArray *friends;
@property (nonatomic, retain) NSMutableArray *inSiteUsers;
@property (nonatomic) BOOL hasAppear;

@end

@implementation FriendListView
@synthesize friendView;
@synthesize friends;
@synthesize inSiteUsers;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.umengEventName = nil;
    self.friendView = nil;
    
    self.friends = nil;
    self.inSiteUsers = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame dataType:FriendDataListTypePlatformFriends];
}

- (id)initWithFrame:(CGRect)frame dataType:(FriendDataListType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.umengEventName = @"add_friends";
        
        [self initializeInviteSectionRowIndex];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRelationActionSuccessNotification:) name:RelationActionSuccessNotification object:nil];
        
        [self loadView];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [friendView reloadData];
}

- (void)layoutSubviews
{
    if ([TTDeviceHelper isPadDevice]) {
        [self trySSLayoutSubviews];
    }
}

- (void)ssLayoutSubviews
{
    friendView.frame = self.bounds;
    [friendView reloadData];
}

#pragma mark -- protocol

- (void)setHasAppear:(BOOL)appear
{
    _hasAppear = appear;
}

- (void)setScrollsEnable:(BOOL)scrollEnable
{
    self.friendView.scrollsToTop = scrollEnable;
}

#pragma mark View Lifecycles

- (void)loadView
{
    self.friendView = [[UITableView alloc] initWithFrame:self.bounds
                                                   style:UITableViewStylePlain];
    friendView.delegate = self;
    friendView.dataSource = self;
    friendView.backgroundColor = [UIColor clearColor];
    friendView.backgroundView = nil;
    friendView.separatorStyle = UITableViewCellSeparatorStyleNone;
    friendView.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) {
        friendView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
    }
    [self addSubview:friendView];
    
    CGRect tmpFrame = friendView.bounds;
    tmpFrame.origin.y = 0 - tmpFrame.size.height;
}

- (void)didAppear
{
    [super didAppear];
    
    if (!_hasAppear) {
        _hasAppear = YES;
    }
}

- (void)willDisappear
{
    [super willDisappear];
}

- (void)didDisappear
{
    [super didDisappear];
}

#pragma mark notifications

- (void)handleRelationActionSuccessNotification:(NSNotification *)notification
{
    [self.friendView reloadData];
}

#pragma mark private

- (void)initializeInviteSectionRowIndex
{
    _weixinIndex = -1;
    _messageIndex = -1;
    _mailIndex = -1;
    
    if ([TTAccountAuthWeChat isAppAvailable]) {
        _weixinIndex ++;
    }
    
    if ([MFMessageComposeViewController canSendText]) {
        _messageIndex = _weixinIndex + 1;
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        if (_messageIndex >= 0) {
            _mailIndex = _messageIndex+1;
        }
        else {
            _mailIndex = _weixinIndex+1;
        }
    }
}

- (CGFloat)inviteSectionHeight
{
    CGFloat ret = 0.f;
    CGFloat inviteCellHeight = 44.f;
    if ([TTAccountAuthWeChat isAppAvailable]) {
        ret += inviteCellHeight;
    }
    
    if ([MFMessageComposeViewController canSendText]) {
        ret += inviteCellHeight;
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        ret += inviteCellHeight;
    }
    return ret;
}

#pragma mark  UITableViewDataSource

- (BOOL)needInviteSection
{
    BOOL ret = NO;
    if (!(_weixinIndex == -1 && _messageIndex == -1 && _mailIndex == -1)) {
        ret = YES;
    }
    return ret;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
     return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = (_weixinIndex != -1) + (_messageIndex != -1) + (_mailIndex != -1);
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *text = @"";
    FriendListViewHeaderView *tView = [[FriendListViewHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, SectionHeaderHeight)
                                                                                 text:text];
    return tView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *inviteCellID = @"inviteCellIndentifier";
    InviteListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:inviteCellID];
    if (cell == nil) {
        cell = [[InviteListViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:inviteCellID];
    }
    
    if (indexPath.row == _weixinIndex) {
        cell.inviteText.text = NSLocalizedString(@"微信告诉朋友", nil);
        cell.inviteIcon.image = [UIImage themedImageNamed:@"weixinicon_invite.png"];
    }
    else if (indexPath.row == _messageIndex) {
        cell.inviteText.text = NSLocalizedString(@"短信告诉朋友", nil);
        cell.inviteIcon.image = [UIImage themedImageNamed:@"messagesicon_invite.png"];
    }
    else if (indexPath.row == _mailIndex) {
        cell.inviteText.text = NSLocalizedString(@"邮件告诉朋友", nil);
        cell.inviteIcon.image = [UIImage themedImageNamed:@"mailicon_invite.png"];
    }
    
    CGRect tFrame = cell.frame;
    tFrame.size.width = tableView.frame.size.width;
    cell.frame = tFrame;
    [cell refreshUI];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *topNav = [TTUIResponderHelper topNavigationControllerFor: self];
    if (indexPath.row == _weixinIndex) {
        [TTWeChatShare sharedWeChatShare].delegate = self;
        [[TTWeChatShare sharedWeChatShare] sendWebpageToScene:WXSceneSession
                                               withWebpageURL:@"http://app.toutiao.com/news_article/?utm_from=direct&tt_from=weixin"
                                               thumbnailImage:[self defaultIconImg]
                                                        title:[NSString stringWithFormat:NSLocalizedString(@"推荐应用《%@》给你", nil), [TTSandBoxHelper appDisplayName]]
                                                  description:[NSString stringWithFormat:NSLocalizedString(@"推荐应用《%@》给你，每天看最热门的资讯，最犀利的网友评论，一起来看看吧！", nil), [TTSandBoxHelper appDisplayName]]
                                       customCallbackUserInfo:nil];
        wrapperTrackEvent(_umengEventName, @"invite_weixin");
    }
    else if (indexPath.row == _messageIndex) {
        
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.messageComposeDelegate = self;
        controller.body = [NSString stringWithFormat:NSLocalizedString(@"推荐应用《%@》给你，每天看最热门的资讯，最犀利的网友评论，一起来看看吧！下载地址：http://app.toutiao.com/news_article/", nil), [TTSandBoxHelper appDisplayName]];
        if (controller) {
            [topNav presentViewController:controller animated:YES completion:NULL];
        }
        wrapperTrackEvent(_umengEventName, @"invite_sms");
    }
    else if (indexPath.row == _mailIndex) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.mailComposeDelegate = self;
        
        [controller setSubject:[NSString stringWithFormat:NSLocalizedString(@"推荐应用《%@》给你", nil), [TTSandBoxHelper appDisplayName]]];
        [controller setMessageBody:[NSString stringWithFormat:NSLocalizedString(@"推荐应用《%@》给你，每天看最热门的资讯，最犀利的网友评论，一起来看看吧！下载地址：http://app.toutiao.com/news_article/", nil), [TTSandBoxHelper appDisplayName]] isHTML:NO];
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"LaunchImage-700@2x" ofType:@"png"];
        NSData * data = [NSData dataWithContentsOfFile:imagePath];
        if (data) {
            [controller addAttachmentData:data mimeType:@"image/png" fileName:@"share.png"];
        }
        if (controller) {
            [topNav presentViewController:controller animated:YES completion:NULL];
        }
        wrapperTrackEvent(_umengEventName, @"invite_mail");
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark TTWeChatShareDelegate

- (void)weChatShare:(TTWeChatShare *)weChatShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo {
    NSString *errMsg = nil;
    if(error) {
        switch (error.code) {
            case kTTWeChatShareErrorTypeNotInstalled:
                errMsg = NSLocalizedString(@"您未安装微信", nil);
                break;
            case kTTWeChatShareErrorTypeNotSupportAPI:
                errMsg = NSLocalizedString(@"您的微信版本过低，无法支持分享", nil);
                break;
            case kTTWeChatShareErrorTypeExceedMaxImageSize:
                errMsg = NSLocalizedString(@"图片过大，分享图片不能超过10M", nil);
                break;
            default:
                errMsg = NSLocalizedString(@"发送失败", nil);
                break;
        }
    }else {
        errMsg = NSLocalizedString(@"发送成功", nil);
    }
    
    if (!isEmptyString(errMsg)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:errMsg
                                 indicatorImage:[UIImage themedImageNamed:error ? @"close_popup_textpage" : @"doneicon_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
    }
}

#pragma mark MFDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)defaultIconImg
{
    UIImage * img;
    //优先使用share_icon.png分享
    if (!img) {
        img = [UIImage imageNamed:@"share_icon.png"];
    }
    if (!img) {
        img = [UIImage imageNamed:@"Icon.png"];
    }
    return img;
}

@end

