//
//  ArticleNoticeViewCell.m
//  Article
//
//  Created by SunJiangting on 14-5-26.
//
//

#import "ArticleNoticeViewCell.h"
#import "ArticleNotificationModel.h"
#import "SSUserModel.h"
#import "SSThemed.h"
#import "PGCAccount.h"
#import "ArticleMomentGroupModel.h"
#import "ArticleMomentProfileViewController.h"
#import "SSViewBase.h"
#import "STLinkLabel.h"
#import "NewsUserSettingManager.h"
#import "UIViewAdditions.h"
#import "TTLabelTextHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTDeviceHelper.h"
#import "SSWebViewController.h"

#import "TTRoute.h"


const CGSize ArticleNoticeDefaultSize = {320, 78};

static CGFloat ArticleNoticeNameButtonTitleSize = 16.f;
static CGFloat ArticleNoticeTimeLabelSize = 12.f;
static CGFloat ArticleNoticeBaseContextTextSize = 17.f;
static CGFloat ArticleNoticePGCButtonTextSize = 14.f;
static CGFloat ArticleNoticeAvatarTopMargin = 15.f;
static CGFloat ArticleNoticeAvatarHorizontalOffset = 9.f;
static CGFloat ArticleNoticeAvatarViewHeight = 36.f;
static CGFloat ArticleNoticeNameButtonTopMargin = 20.f;
static CGFloat ArticleNoticeContentLabelRightMargin = 15.f;
static CGFloat ArticleNoticeContentLabelTopOffset = 5.f;//fixed original 9
static CGFloat ArticleNoticeContentLabelLineHeight = 1.f;
static CGFloat ArticleNoticeTimeLabelNormalTopOffset = 10.f;
static CGFloat ArticleNoticeTimeLabelPGCTopOffset = 12.f;//fixed original10 这个数字可以调整
static CGFloat ArticleNoticeTimeLabelBottomOffset = 14.f;
static CGFloat ArticleNoticePGCButtonTopOffset = 12.f;
static CGFloat ArticleNoticePGCButtonHeight = 52.f;
static CGFloat ArticleNoticePGCButtonImageHeight = 42.f;
static CGFloat ArticleNoticePGCButtonImageOffset = 5.f;
static CGFloat ArticleNoticePGCButtonNameOffset = 9.f;
static CGFloat ArticleNoticePGCButtonNameHeight = 16.f;
static CGFloat ArticleNoticePGCButtonAbstractHeight = 34.f;

@interface ArticleNoticeViewCell () <STLinkLabelDelegate>

@property (nonatomic, retain) SSThemedView *separatorView;
@property (nonatomic, retain) SSThemedView *selectedView;

@end

@implementation ArticleNoticeViewCell

+ (CGFloat) heightForNoticeModel:(ArticleNotificationModel *) noticeModel constrainedToWidth:(CGFloat) width {
    CGFloat contentHeight = [STLinkLabel sizeWithText:noticeModel.content font:[UIFont systemFontOfSize:[self preferredContentTextSize]] constrainedToSize:CGSizeMake(width - [[self class] blankWidth], 9999) lineSpacing:[TTDeviceUIUtils tt_padding:ArticleNoticeContentLabelLineHeight] paragraphStyle:nil].height - 4.f;
    if (!noticeModel.pgcAccount && !noticeModel.group) {
        /// 没有引用
        CGFloat height = contentHeight + [[self class] normalCellHeightExceptContentLabel];
        return MAX(height, ArticleNoticeDefaultSize.height);
    } else {
        if (noticeModel.pgcAccount) {
            return [[self class] pgcCellHeightExceptContentLabel] + contentHeight;
        } else {
            if (noticeModel.group.thumbnailURLString.length > 0) {
                return [[self class] pgcCellHeightExceptContentLabel] + contentHeight;
            } else {
                CGFloat max = [[self class] pgcCellHeightExceptContentLabel] - [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonHeight];
                CGFloat absHeight = [TTLabelTextHelper heightOfText:noticeModel.group.title fontSize:[TTDeviceUIUtils tt_fontSize:ArticleNoticePGCButtonTextSize] forWidth:width - [[self class] blankWidth] - 16];
                return MIN([[self class] pgcCellHeightExceptContentLabel], max + absHeight) + contentHeight;
            }
        }
    }
}

- (void) dealloc {
    self.separatorView = nil;
    self.avatarView = nil;
    self.nameButton = nil;
    self.timeLabel = nil;
    self.contentLabel = nil;
    self.selectedView = nil;
}

- (void)linkLabel:(STLinkLabel *)linkLabel didSelectLinkObject:(STLinkObject *)linkObject {
    NSURL *URL = linkObject.URL;
    NSString *URLString = URL.absoluteString;
    if ([URLString hasPrefix:TTLocalScheme] || [URLString hasPrefix:@"snssdk"]) {
        [[TTRoute sharedRoute] openURLByPushViewController:URL];
    }
    else if ([URLString hasPrefix:@"http://"] || [URLString hasPrefix:@"https://"]) {
        UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
        ssOpenWebView(URL, @"", topController.navigationController, NO, nil);
    }
    else {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

- (void)settingViewsData
{
    ArticleNotificationModel *noticeModel = self.noticeModel;
    NSString * name = noticeModel.user.name;
    if ((NSUInteger)noticeModel.type > 40) {
        self.avatarView.placeholder = @"system_notice_icon";
        self.nameButton.titleColorThemeKey = kColorText4;
        if (name.length == 0) {
            name = NSLocalizedString(@"系统通知", nil);
        }
    } else {
        self.avatarView.placeholder = @"big_defaulthead_head";
        self.nameButton.titleColorThemeKey = kColorText5;
    }
    [self.nameButton setTitle:name forState:UIControlStateNormal];
    self.nameButton.enabled = (noticeModel.type <= 40);
    self.avatarView.userInteractionEnabled = (noticeModel.type <= 40);
    NSString *userAuthInfo = noticeModel.user.userAuthInfo;
    if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:userAuthInfo]) {
        [self.avatarView showVerifyViewWithVerifyInfo:userAuthInfo];
    } else {
        [self.avatarView hideVerifyView];
    }
    
    [self.avatarView setImageWithURLString:noticeModel.user.avatarURLString];
    self.contentLabel.text = noticeModel.content;
    self.timeLabel.text = (noticeModel.createTime > 0) ? [TTBusinessManager customtimeStringSince1970:noticeModel.createTime] : @" ";
    self.contentLabel.userInteractionEnabled = (noticeModel.type == ArticleNotificationTypeSystemNotification);
}

- (void) setNoticeModel:(ArticleNotificationModel *)noticeModel {
    _noticeModel = noticeModel;
    [self settingViewsData];
    [self setNeedsLayout];
}

- (void) userNameActionFired:(id) sender {
    /// 大于40 的为系统通知，不反映
    if (self.noticeModel.type > 40) {
        return;
    }
    ArticleMomentProfileViewController * viewController = [[ArticleMomentProfileViewController alloc] initWithUserModel:self.noticeModel.user];
    /// 点击用户名称
    [self.navigationController pushViewController:viewController animated:YES];
    //////////////////TODO:  友盟统计
    wrapperTrackEvent(@"information", @"click_name");
}


- (void) themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.contentLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"000000" nightColorName:@"707070"]];
}

- (void) userAvatarActionFired:(id) sender {
    /// 大于40 的为系统通知，点击头像不跳转
    if (self.noticeModel.type > 40) {
        return;
    }
    ArticleMomentProfileViewController * viewController = [[ArticleMomentProfileViewController alloc] initWithUserModel:self.noticeModel.user];
    /// 点击头像
    [self.navigationController pushViewController:viewController animated:YES];
    //////////////////TODO:  友盟统计
    wrapperTrackEvent(@"information", @"click_avatar");
}

- (CGRect)_avatarViewFrame
{
    return CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticeAvatarHorizontalOffset], [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarTopMargin], [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight], [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight]);
}

- (CGRect)_timeLabelFrame
{
    return CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticeAvatarHorizontalOffset] * 2 + [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight], [TTDeviceUIUtils tt_padding:ArticleNoticeNameButtonTopMargin], 100, [TTDeviceUIUtils tt_fontSize:ArticleNoticeTimeLabelSize]);
}

- (CGRect)_nameButtonFrame
{
    CGRect frame = CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticeAvatarHorizontalOffset] * 2 + [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight], [TTDeviceUIUtils tt_padding:ArticleNoticeNameButtonTopMargin], [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth], [TTDeviceUIUtils tt_fontSize:ArticleNoticeNameButtonTitleSize]);
    
    if (isEmptyString(self.noticeModel.user.name)) {
        return frame;
    }
    
    CGSize nameButtonSize = [self.noticeModel.user.name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                  attributes:@{NSFontAttributeName:self.nameButton.titleLabel.font}
                                                                     context:nil].size;
    
    if (nameButtonSize.width > frame.size.width) {
        nameButtonSize.width = frame.size.width;
        if (nameButtonSize.width < 0) nameButtonSize.width = 0;
    }
    
    frame.size.width = nameButtonSize.width;
    
    return frame;
}

- (CGRect)_contentLabelFrame
{
    return CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticeAvatarHorizontalOffset] * 2 + [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight], [TTDeviceUIUtils tt_padding:ArticleNoticeNameButtonTopMargin] + [TTDeviceUIUtils tt_fontSize:ArticleNoticeNameButtonTitleSize] + [TTDeviceUIUtils tt_padding:ArticleNoticeContentLabelTopOffset], [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth], [TTDeviceUIUtils tt_fontSize:ArticleNoticeBaseContextTextSize]);
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.frame = CGRectMake(0, 0, ArticleNoticeDefaultSize.width, ArticleNoticeDefaultSize.height);
        self.needMargin = YES;
        
        self.avatarView = [[ExploreAvatarView alloc] initWithFrame:[self _avatarViewFrame]];
        self.avatarView.contentMode = UIViewContentModeScaleAspectFit;
        self.avatarView.enableRoundedCorner = YES;
        self.avatarView.imageView.layer.borderWidth = 1.f;
        UIColor *borderColor = SSGetThemedColorInArray(@[[UIColor colorWithRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:0.5], [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:0.5]]);
        self.avatarView.imageView.layer.borderColor = borderColor.CGColor;
        
        [self.avatarView setupVerifyViewForLength:ArticleNoticeAvatarViewHeight adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_size:standardSize];
        }];
        
        [self.avatarView addTouchTarget:self action:@selector(userAvatarActionFired:)];
        [self.contentView addSubview:self.avatarView];
        
        self.nameButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.nameButton.frame = [self _nameButtonFrame];
        self.nameButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.nameButton.backgroundColor = [UIColor clearColor];
        self.nameButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:ArticleNoticeNameButtonTitleSize]];
        self.nameButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.nameButton addTarget:self action:@selector(userNameActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.nameButton];
        
        self.timeLabel = [[SSThemedLabel alloc] initWithFrame:[self _timeLabelFrame]];
        self.timeLabel.verticalAlignment = ArticleVerticalAlignmentBottom;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:ArticleNoticeTimeLabelSize]];
        self.timeLabel.textColorThemeKey = kColorText3;
        [self.contentView addSubview:self.timeLabel];
        
        self.contentLabel = [[STLinkLabel alloc] initWithFrame:[self _contentLabelFrame]];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.textCheckingTypes = NSTextCheckingTypeLink | STTextCheckingTypeCustomLink;
        self.contentLabel.userInteractionEnabled = YES;
        self.contentLabel.linkColor = [UIColor blueColor];
        self.contentLabel.highlightedLinkColor = [UIColor redColor];
        self.contentLabel.highlightedLinkBackgroundColor = [UIColor lightGrayColor];
        self.contentLabel.lineSpacing = [TTDeviceUIUtils tt_padding:ArticleNoticeContentLabelLineHeight];
        self.contentLabel.delegate = self;
        self.contentLabel.font = [UIFont systemFontOfSize:[[self class] preferredContentTextSize]];
        [self.contentView addSubview:self.contentLabel];
        
        SSThemedView * selectedBackgroundView = [[SSThemedView alloc] initWithFrame:self.contentView.bounds];
        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        selectedBackgroundView.backgroundColors = SSThemedColors(@"eeeeee", @"303030");
        [self.contentView addSubview:selectedBackgroundView];
        [self.contentView sendSubviewToBack:selectedBackgroundView];
        self.selectedView = selectedBackgroundView;
        
        self.separatorView = [[SSThemedView alloc] init];
        self.separatorView.backgroundColorThemeKey = kColorLine1;
        [self.contentView addSubview:self.separatorView];
        
        
        [self themeChanged:nil];
        
        
    }
    return self;
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    _selectedView.hidden = !highlighted;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentHeight = [STLinkLabel sizeWithText:self.contentLabel.text font:[UIFont systemFontOfSize:[[self class] preferredContentTextSize]] constrainedToSize:CGSizeMake(CGRectGetWidth(self.contentView.frame) - [[self class] blankWidth], 9999) lineSpacing:[TTDeviceUIUtils tt_padding:ArticleNoticeContentLabelLineHeight] paragraphStyle:nil].height;
    CGRect contentRect = self.contentLabel.frame;
    contentRect.size.width = CGRectGetWidth(self.contentView.frame) - [[self class] blankWidth];
    contentRect.size.height = contentHeight;
    self.contentLabel.frame = contentRect;
    
    self.selectedView.frame = self.contentView.bounds;
    self.timeLabel.bottom = self.selectedView.bottom - [TTDeviceUIUtils tt_padding:ArticleNoticeTimeLabelBottomOffset];
    self.nameButton.width = [self _nameButtonFrame].size.width;

    self.separatorView.frame = CGRectMake(0, self.contentView.frame.size.height - [TTDeviceHelper ssOnePixel], self.contentView.frame.size.width, [TTDeviceHelper ssOnePixel]);
}

+ (CGFloat)preferredContentTextSize {
    return [TTDeviceUIUtils tt_fontSize:ArticleNoticeBaseContextTextSize];
}

+ (CGFloat)normalCellHeightExceptContentLabel {
    return [TTDeviceUIUtils tt_padding:ArticleNoticeNameButtonTopMargin] + [TTDeviceUIUtils tt_fontSize:ArticleNoticeNameButtonTitleSize] + [TTDeviceUIUtils tt_padding:ArticleNoticeContentLabelTopOffset] + [TTDeviceUIUtils tt_padding:ArticleNoticeTimeLabelNormalTopOffset]
    + [TTDeviceUIUtils tt_fontSize:ArticleNoticeTimeLabelSize] + [TTDeviceUIUtils tt_padding:ArticleNoticeTimeLabelBottomOffset];
}

+ (CGFloat)pgcCellHeightExceptContentLabel {
    return [[self class] normalCellHeightExceptContentLabel] - [TTDeviceUIUtils tt_padding:ArticleNoticeTimeLabelNormalTopOffset] + [TTDeviceUIUtils tt_padding:ArticleNoticeTimeLabelPGCTopOffset] + [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonTopOffset] + [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonHeight];
}

+ (CGFloat)blankWidth {
    return [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarHorizontalOffset] * 2 + [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight] + [TTDeviceUIUtils tt_padding:ArticleNoticeContentLabelRightMargin];
}

@end

@implementation ArticlePGCNoticeViewCell

- (void) dealloc {
    self.thumbView = nil;
    self.titleLabel = nil;
    self.abstractLabel = nil;
    self.backgroundButton = nil;
    self.delegate = nil;
}

- (CGRect)_backgroundButtonFrame
{
    return CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticeAvatarHorizontalOffset] * 2 + [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight], 0, [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonHeight]);
}

- (CGRect)_thumbViewFrame
{
    return CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageHeight], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageHeight]);
}

- (CGRect)_titleLabelFrame
{
    return CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonHeight], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonNameOffset], [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth] - [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight] - 2 * [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonNameHeight]);
}

- (CGRect)_abstractLabelFrame
{
    return CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonHeight], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonNameOffset], [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth] - [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight] - 2 * [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonAbstractHeight]);
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        SSThemedButton *backgroundButton = [[SSThemedButton alloc] initWithFrame:[self _backgroundButtonFrame]];
        backgroundButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:backgroundButton];
        backgroundButton.backgroundColorThemeKey = kColorBackground3;
        self.backgroundButton = backgroundButton;
        [backgroundButton addTarget:self action:@selector(backgroundButtonActionFired:) forControlEvents:UIControlEventTouchUpInside];
        
        self.thumbView = [[TTImageView alloc] initWithFrame:[self _thumbViewFrame]];
        self.thumbView.clipsToBounds = YES;
        self.thumbView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbView.backgroundColor = [UIColor darkGrayColor];
        self.thumbView.contentMode = UIViewContentModeScaleAspectFit;
        [backgroundButton addSubview:self.thumbView];
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:[self _titleLabelFrame]];
        self.titleLabel.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:ArticleNoticePGCButtonTextSize]];
        self.titleLabel.textColorThemeKey = kColorText1;
        [backgroundButton addSubview:self.titleLabel];
        
        self.abstractLabel = [[SSThemedLabel alloc] initWithFrame:[self _abstractLabelFrame]];
        self.abstractLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.abstractLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        self.abstractLabel.backgroundColor = [UIColor clearColor];
        self.abstractLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:ArticleNoticePGCButtonTextSize]];
        self.abstractLabel.numberOfLines = 2;
        self.abstractLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.abstractLabel.textColorThemeKey = kColorText3;
        [backgroundButton addSubview:self.abstractLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self pgcDoLayoutSubviews];
}

- (void)pgcDoLayoutSubviews
{
    ArticleNotificationModel *noticeModel = self.noticeModel;
    CGFloat absHeight = 0;
    
    CGFloat contentHeight = [STLinkLabel sizeWithText:noticeModel.content font:[UIFont systemFontOfSize:[[self class] preferredContentTextSize]] constrainedToSize:CGSizeMake(CGRectGetWidth(self.contentView.frame) - [[self class] blankWidth], 9999) lineSpacing:[TTDeviceUIUtils tt_padding:ArticleNoticeContentLabelLineHeight] paragraphStyle:nil].height;
    CGRect contentRect = self.contentLabel.frame;
    contentRect.size.width = CGRectGetWidth(self.contentView.frame) - [[self class] blankWidth];
    contentRect.size.height = contentHeight;
    self.contentLabel.frame = contentRect;
    
    CGFloat height = [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonHeight];
    if (noticeModel.pgcAccount || noticeModel.group.thumbnailURLString.length > 0) {
        height = [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonHeight];
    } else {
        absHeight = [TTLabelTextHelper heightOfText:noticeModel.group.title fontSize: [TTDeviceUIUtils tt_fontSize:ArticleNoticePGCButtonTextSize] forWidth: [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth] - 16];
        height = MIN([TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonHeight], absHeight);
    }
    
    CGFloat contentBottom = CGRectGetMaxY(self.contentLabel.frame);
    CGRect frame = self.backgroundButton.frame;
    frame.origin.y = contentBottom + [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonTopOffset];
    frame.size.width = [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth];
    frame.size.height = height;
    self.backgroundButton.frame = frame;
    
    self.titleLabel.width = [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth] - [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight] - 4 * [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset];
    
    if (noticeModel.pgcAccount) {
        self.thumbView.hidden = NO;
        if (noticeModel.pgcAccount.avatarURLString.length > 0) {
            [self.thumbView setImageWithURLString:noticeModel.pgcAccount.avatarURLString];
            self.thumbView.hidden = NO;
            self.thumbView.frame = CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageHeight], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageHeight]);
            self.abstractLabel.frame = CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonHeight], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonNameOffset], [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth] - [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight] - 4 * [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonAbstractHeight]);
        } else {
            self.thumbView.hidden = YES;
            self.abstractLabel.frame = CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonNameOffset], [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth] - 2 * [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonAbstractHeight]);
        }
        
        self.abstractLabel.numberOfLines = 1;
        self.titleLabel.text = noticeModel.pgcAccount.screenName;
        self.abstractLabel.text = noticeModel.pgcAccount.userDesc;
        
        
        self.abstractLabel.height = [TTDeviceUIUtils tt_fontSize:ArticleNoticePGCButtonTextSize];
        self.abstractLabel.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_padding:6.f];
    } else {
        if (noticeModel.group.thumbnailURLString.length > 0) {
            [self.thumbView setImageWithURLString:noticeModel.group.thumbnailURLString];
            self.thumbView.hidden = NO;
            self.thumbView.frame = CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageHeight], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageHeight]);
            self.abstractLabel.frame = CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonHeight], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonNameOffset], [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth] - [TTDeviceUIUtils tt_padding:ArticleNoticeAvatarViewHeight] - 4 * [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], absHeight);
        } else {
            self.thumbView.hidden = YES;
            self.abstractLabel.frame = CGRectMake([TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonNameOffset], [TTUIResponderHelper splitViewFrameForView:self.contentView].size.width - [[self class] blankWidth] - 2 * [TTDeviceUIUtils tt_padding:ArticleNoticePGCButtonImageOffset], absHeight);
        }
        self.titleLabel.text = nil;
        self.abstractLabel.text = noticeModel.group.title;
        CGRect absFrame = self.abstractLabel.frame;
        absFrame.origin.y = 0;
        absFrame.size.height = height;
        self.abstractLabel.frame = absFrame;
        self.abstractLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    }
}

- (void) backgroundButtonActionFired:(id) sender {
    if ([self.delegate respondsToSelector:@selector(articlePGCNoticeViewActionFired:)]) {
        [self.delegate articlePGCNoticeViewActionFired:self];
    }
}

@end
NSString * const ArticleNoticeCellIdentifier = @"ArticleNoticeCellIdentifier";
NSString * const ArticlePGCNoticeCellIdentifier = @"ArticlePGCNoticeCellIdentifier";
