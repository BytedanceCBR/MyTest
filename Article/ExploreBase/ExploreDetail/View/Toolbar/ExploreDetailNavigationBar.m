//
//  ExploreDetailNavigationBar.m
//  Article
//
//  Created by SunJiangting on 15/7/31.
//
//

#import "ExploreDetailNavigationBar.h"
#import "UIButton+TTAdditions.h"
#import "UIButton+WebCache.h"
#import "UIViewAdditions.h"
#import "ExploreSearchViewController.h"
#import "TTAdManager.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "UIImageview+WebCache.h"
#import "NSDictionary+TTAdditions.h"
#import "TTLabel.h"
#import "TTIconLabel+VerifyIcon.h"
#import "ExploreAvatarView+VerifyIcon.h"
#import <TTInstallJSONHelper.h>

#define AvatarViewHeightWithShowFans 36
#define AvatarViewHeightWithoutShowFans 24
#define TextFontSizeWithShowFans [TTDeviceUIUtils tt_fontSize:14.f]
#define TextFontSizeWithoutShowFans [TTDeviceUIUtils tt_fontSize:17.f]
#define FansTextFontSize [TTDeviceUIUtils tt_fontSize:12.f]
#define PaddingLeftSelf [TTDeviceUIUtils tt_padding:50]
#define PaddingRightAvatarView [TTDeviceUIUtils tt_padding:10]
#define PaddingRightText 20
#define PaddingBottomText 0
#define OffsetLeftTitleView 0

@interface ExploreDetailNavigationBar ()

@property(nonatomic, strong) TTAlphaThemedButton  *backButton;
@property(nonatomic, strong) SSThemedView         *functionView;
@property(nonatomic, strong) TTAlphaThemedButton  *moreButton;
@property(nonatomic, strong) ExploreAvatarView  *avatarView;
@property(nonatomic, assign) BOOL isNativeGallary;
@property(nonatomic, assign) BOOL hasShowFollowed;

@end

@implementation ExploreDetailNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // recomLabel推荐图集
        _recomLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), 44.0f)];
        _recomLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _recomLabel.text = NSLocalizedString(@"图集推荐", nil);
        _recomLabel.textColor = [UIColor tt_defaultColorForKey:kColorText8];
        _recomLabel.textAlignment = NSTextAlignmentCenter;
        _recomLabel.font = [UIFont systemFontOfSize:17.0f];
        _recomLabel.alpha = 0.f;
        [self addSubview:_recomLabel];
        
        // adLabel推广
        _adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), 44.0f)];
        _adLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _adLabel.text = NSLocalizedString([TTAdManageInstance photoAlbum_getImagePageTitle], nil);
        _adLabel.textColor = [UIColor tt_defaultColorForKey:kColorText8];
        _adLabel.textAlignment = NSTextAlignmentCenter;
        _adLabel.font = [UIFont systemFontOfSize:17.0f];
        _adLabel.alpha = 0.f;
        [self addSubview:_adLabel];
        
        _backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _backButton.imageName = @"white_lefterbackicon_titlebar";
        [self addSubview:_backButton];
        
        _functionView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, 100, 0)];
        [self addSubview:_functionView];
        
        _moreButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _moreButton.imageName = @"new_morewhite_titlebar";
        _moreButton.enableNightMask = NO;
        [_functionView addSubview:_moreButton];
        
        _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
        
        _showFollowedButton = NO;
        _hasShowFollowed = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_barType == ExploreDetailNavigationBarTypeShowFans){
        _mediaName.font = [UIFont systemFontOfSize:TextFontSizeWithShowFans];
        [_mediaName sizeToFit];
    }else{
        _mediaName.font = [UIFont systemFontOfSize:17];
        [_mediaName sizeToFit];
    }
    BOOL isIPad = [TTDeviceHelper isPadDevice];
    CGFloat topSafeInset = self.tt_safeAreaInsets.top;
    if (topSafeInset <= 0){
        topSafeInset = [UIApplication sharedApplication].statusBarFrame.size.height;
        if (![TTDeviceHelper isIPhoneXDevice] && topSafeInset <= 0) {
            topSafeInset = 20;
        }
    }
    _adLabel.top = topSafeInset;
    CGFloat iconSize = isIPad ? 28 : 22;
    CGFloat originYOfIcon = (44 - iconSize) / 2 + topSafeInset;
    //    CGFloat buttonPadding = isIPad ? 37 : 22;
    static CGFloat functionButtonRightMargin = 10;
    CGFloat followExt = 0;
    CGFloat widthOfFunctionView = 0;
    self.backButton.frame = CGRectMake(isIPad ? /*(rightMarginOfFunctonView - 6)*/ 20 : 12 + self.tt_safeAreaInsets.left, originYOfIcon, iconSize, iconSize);
    self.recomLabel.top = self.height - self.recomLabel.height;
    if (_barType == ExploreDetailNavigationBarTypeDefault){
        self.mediaName.font = [UIFont tt_fontOfSize:17];
        if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
            if (_showFollowedButton) {
                CGFloat maxExtWidth = CGRectGetWidth(self.frame) - (/*isIPad ? 10 : */4) - functionButtonRightMargin - iconSize - 17 - _followButton.width - 18 - (/*isIPad ? 20 :*/6) - iconSize - 18;
                CGFloat maxWidth = maxExtWidth - 24 - 6;
                if (_mediaName.width > maxWidth){
                    _mediaName.width = maxWidth;
                }
                widthOfFunctionView = CGRectGetWidth(self.frame) - (/*isIPad ? 10 : */4) - (/*isIPad ? 20 :*/6) - iconSize - 17 - (maxExtWidth - _mediaName.width - 24 - 6) / 2;
            } else {
                widthOfFunctionView = CGRectGetWidth(self.frame) / 2 - (/*isIPad ? 10 : */4) + followExt;
            }
        } else {
            if (_showFollowedButton) {
                CGFloat maxExtWidth = CGRectGetWidth(self.frame) / 2 - (isIPad ? 10 : 4) - functionButtonRightMargin - iconSize - 17 - _followButton.width - 18;
                CGFloat maxWidth = maxExtWidth * 2 - 24 - 6;
                if (_mediaName.width > maxWidth){
                    _mediaName.width = maxWidth;
                }
                followExt = (24 + 6 + _mediaName.width) / 2;
            }
            widthOfFunctionView = CGRectGetWidth(self.frame) / 2 - (isIPad ? 10 : 4) + followExt;
        }
        widthOfFunctionView = widthOfFunctionView - self.tt_safeAreaInsets.left - self.tt_safeAreaInsets.right;
        self.functionView.frame = CGRectMake(CGRectGetWidth(self.frame) - /*rightMarginOfFunctonView*/ (isIPad ? 10 : 4) - widthOfFunctionView, 0, widthOfFunctionView, CGRectGetHeight(self.frame));
        self.moreButton.frame = CGRectMake(CGRectGetWidth(_functionView.frame) - iconSize - functionButtonRightMargin, originYOfIcon, iconSize, iconSize);
        if (_hasShowFollowed) {
            self.avatarView.frame = CGRectMake(0, CGRectGetMinY(_moreButton.frame), 24, 24);
            self.mediaName.left = self.avatarView.right + 6;
            self.mediaName.centerY = self.avatarView.centerY;
            self.followButton.centerY = self.avatarView.centerY;
            self.followButton.right = self.moreButton.left - 17;
        } else {
            self.avatarView.frame = CGRectMake(CGRectGetMinX(_moreButton.frame) - 24 - 24, CGRectGetMinY(_moreButton.frame), 24, 24);
        }
        [self.avatarView setupVerifyViewForLength:24 adaptationSizeBlock:nil];
        CGRect bounds = self.avatarView.bounds;
        self.avatarView.decoratorView.frame = CGRectMake(kDecoratorOriginFactor * bounds.size.width, kDecoratorOriginFactor * bounds.size.height, kDecoratorSizeFactor * bounds.size.width, kDecoratorSizeFactor * bounds.size.height);
        self.fansLabel.hidden = YES;
    }
    else if(_barType == ExploreDetailNavigationBarTypeShowFans){
        CGFloat left = PaddingLeftSelf + self.tt_safeAreaInsets.left;
        widthOfFunctionView = self.width - left - self.tt_safeAreaInsets.right;
        self.functionView.frame = CGRectMake(left, 0, widthOfFunctionView, CGRectGetHeight(self.frame));
        self.moreButton.frame = CGRectMake(self.functionView.width - iconSize - functionButtonRightMargin, originYOfIcon, iconSize, iconSize);
        self.followButton.centerY = self.backButton.centerY;
        self.followButton.right = self.moreButton.left - 17;
        self.fansLabel.hidden = NO;
        self.avatarView.size = CGSizeMake(AvatarViewHeightWithShowFans, AvatarViewHeightWithShowFans);
        [self.avatarView setupVerifyViewForLength:AvatarViewHeightWithShowFans adaptationSizeBlock:nil];
        CGRect bounds = self.avatarView.bounds;
        self.avatarView.decoratorView.frame = CGRectMake(kDecoratorOriginFactor * bounds.size.width, kDecoratorOriginFactor * bounds.size.height, kDecoratorSizeFactor * bounds.size.width, kDecoratorSizeFactor * bounds.size.height);
        self.avatarView.centerY = self.backButton.centerY;
        self.avatarView.left = 0;
        left = self.avatarView.right + PaddingRightAvatarView;
        CGFloat maxTitleLabelWidth = self.followButton.left - left - PaddingRightText;
        self.mediaName.left = left;
        if (self.mediaName.width > maxTitleLabelWidth){
            self.mediaName.width = maxTitleLabelWidth;
        }
        self.fansLabel.left = left;
        if (self.fansLabel.text){
            CGFloat totalHeight = self.mediaName.height + self.fansLabel.height + PaddingBottomText;
            self.mediaName.top = (self.height - totalHeight - topSafeInset) / 2 + topSafeInset;
            self.fansLabel.top = self.mediaName.bottom + PaddingBottomText;
        }else{
            self.mediaName.centerY = self.avatarView.centerY;
        }
    }
}

- (void)updateAvartarViewWithArticleInfo:(Article *)article isSelf:(BOOL)isSelf {
    NSDictionary *mediaInfo = article.mediaInfo;
    NSDictionary *userInfo = article.userInfo;
    [self showAvartarViewWithUrl:[mediaInfo tt_stringValueForKey:@"avatar_url"]];
    NSString *userAuthInfo = [userInfo tt_stringValueForKey:@"user_auth_info"];
    if (isEmptyString(userAuthInfo)) userAuthInfo = [mediaInfo tt_stringValueForKey:@"user_auth_info"];
    [self showVerifyIconWithVerifyInfo:userAuthInfo decorationURL:article.userDecoration userID:[userInfo tt_stringValueForKey:@"user_id"]];
    if (self.barType == ExploreDetailNavigationBarTypeShowFans){
        long long fansNum = [userInfo tt_longlongValueForKey:@"fans_count"];
        if (fansNum >= [SSCommonLogic navBarShowFansMinNum]){
            fansNum = fansNum < 0 ? 0 : fansNum;
            self.fansLabel.text = [NSString stringWithFormat:@"%@粉丝",[TTBusinessManager formatCommentCount:fansNum]];
            [self.fansLabel sizeToFit];
        }else{
            self.fansLabel.text = nil;
        }
    }
    if ([SSCommonLogic isPicsFollowEnabled]
        && ![mediaInfo tt_boolValueForKey:@"subcribed"]
        && !isSelf) {
        _showFollowedButton = YES;
        _hasShowFollowed = YES;
        [self setupMediaName];
        _mediaName.text = [mediaInfo tt_stringValueForKey:@"name"]; 
        [_mediaName sizeToFit];
        [self setupFollowButton];
        _mediaName.hidden = NO;
        
        _followButton.hidden = NO;
        _followButton.alpha = 1;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"top_title_bar" forKey:@"position"];
        [params setValue:@"gallery_detail" forKey:@"source"];
        [params setValue:article.mediaUserID forKey:@"user_id"];
        [params setValue:[article groupModel].groupID forKey:@"group_id"];
        [TTTrackerWrapper eventV3:@"follow_show" params:params];
        
        _mediaName.alpha = 1;
        [self setNeedsLayout];
    }
}

- (void)showAvartarViewWithUrl:(NSString *)url {
    [self setupAvatarView];
    [self.avatarView setImageWithURLString:url];
    [self setNeedsLayout];
}

- (void)showVerifyIconWithVerifyInfo:(NSString *)verifyInfo decorationURL:(NSString *)url userID:(NSString *)uid {
    self.avatarView.clipsToBounds = NO;
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:verifyInfo decoratorInfo:url sureQueryWithID:YES userID:uid];
}

- (void)setupAvatarView {
    if (!_avatarView) {
        _avatarView = [[ExploreAvatarView alloc] init];
        _avatarView.size = CGSizeMake(24, 24);
        _avatarView.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
        _avatarView.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
        _avatarView.borderColorThemeKey = kColorLine11;
        [_functionView addSubview:_avatarView];
    }
}

- (void)setupFollowButton {
    if (!_followButton) {
        //图集详情页顶部，背景是黑色，已关注要用103样式
        _followButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101 followedType:TTFollowedType103];
        _followButton.hidden = YES;
        [_functionView addSubview:_followButton];
    }
}

- (void)setupMediaName {
    if (!_mediaName) {
        _mediaName = [[SSThemedLabel alloc] init];
        _mediaName.textColorThemeKey = kColorText12;
        _mediaName.verticalAlignment = ArticleVerticalAlignmentMiddle;
        _mediaName.font = [UIFont systemFontOfSize:17];
        _mediaName.hidden = YES;
        [_functionView addSubview:_mediaName];
    }
}

- (SSThemedLabel *)fansLabel
{
    if (_fansLabel == nil){
        _fansLabel = [[SSThemedLabel alloc] init];
        _fansLabel.textColorThemeKey = kColorText12;
        _fansLabel.font = [UIFont systemFontOfSize:FansTextFontSize];
        _fansLabel.textAlignment = NSTextAlignmentLeft;
        _fansLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        _fansLabel.hidden = YES;
        [_functionView addSubview:_fansLabel];
    }
    return _fansLabel;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
}

- (void)setupFollowedButtonWithScrollPercent:(CGFloat)scrollPercent {
    //    _hasShowFollowed = (scrollPercent > 0.9);
    //    if (scrollPercent > 0.9 || scrollPercent < 0.1) {
    //        _mediaName.hidden = !_hasShowFollowed;
    //        _followButton.hidden = !_hasShowFollowed;
    //        _mediaName.alpha = 1;
    //        _followButton.alpha = 1;
    //        [self setNeedsLayout];
    //    } else {
    //        scrollPercent = (scrollPercent - 0.1) / 0.8;
    //        _mediaName.hidden = NO;
    //        _followButton.hidden = NO;
    //        _avatarView.left = (_moreButton.left - 24 - 24) * (1 - scrollPercent);
    //        _mediaName.left = _avatarView.right + 6;
    //        _mediaName.centerY = _avatarView.centerY;
    //        _followButton.right = _moreButton.left - 17;
    //        _followButton.centerY = _avatarView.centerY;
    //        CGFloat percent = 1 - (_followButton.left - _mediaName.width - 6 - 24) / (_moreButton.left - 24 - 24);
    //        CGFloat alpha = (scrollPercent < percent ? 0 : (scrollPercent - percent) / (1 - percent));
    //        _mediaName.alpha = alpha;
    //        _followButton.alpha = alpha;
    //    }
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    
}

@end

#pragma mark TTArticleDetailNavigationTitleView -

@interface TTArticleDetailNavigationTitleView () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) ExploreAvatarView    *logoView;
@property(nonatomic, strong) TTIconLabel  *titleLabel;
@property(nonatomic, strong) SSThemedLabel *fansLabel;
@property(nonatomic, copy) TitleViewTapHandler titleViewTapHandler;
@property(nonatomic, assign) BOOL isAnimating;
@property(nonatomic, assign) BOOL isShow;

@end

@implementation TTArticleDetailNavigationTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = 44;
    self = [super initWithFrame:frame];
    if (self) {
        TTIconLabel * titleLabel = [[TTIconLabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColorThemeKey = kColorText1;
        titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        titleLabel.font = [UIFont systemFontOfSize:TextFontSizeWithoutShowFans];
        titleLabel.iconMaxHeight = ceil([TTDeviceUIUtils tt_fontSize:17.f] / 17.f * 14.f);
        titleLabel.backgroundColor = [UIColor clearColor];
        //default header titlelable set to invisiable.
        titleLabel.alpha = 0.f;
        //titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        SSThemedLabel *fansLabel = [[SSThemedLabel alloc] init];
        fansLabel.textAlignment = NSTextAlignmentLeft;
        fansLabel.textColorThemeKey = kColorText1;
        fansLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        fansLabel.font = [UIFont systemFontOfSize:FansTextFontSize];
        fansLabel.backgroundColor = [UIColor clearColor];
        fansLabel.alpha = 0.f;
        [self addSubview:fansLabel];
        self.fansLabel = fansLabel;
        
        ExploreAvatarView *logoView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake(0, 0, AvatarViewHeightWithoutShowFans, AvatarViewHeightWithoutShowFans)];
        logoView.enableRoundedCorner = YES;
        logoView.imageView.borderColorThemeKey = kColorLine1;
        logoView.imageView.backgroundColorThemeKey = kColorBackground2;
        logoView.imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        logoView.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        logoView.hidden = YES;
        logoView.userInteractionEnabled = NO;
        logoView.enableBlackMaskView = YES;
        [logoView setupVerifyViewForLength:24.f adaptationSizeBlock:nil];
        [self addSubview:logoView];
        self.logoView = logoView;
   
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTitleView:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        [self show:NO animated:NO];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refreshUI];
}

- (void)refreshUI {
    CGFloat left = 0, padding = 9, w;
    if(self.type != TTArticleDetailNavigationTitleViewTypeShowFans){
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:TextFontSizeWithoutShowFans];
        [self.titleLabel sizeToFit];
        self.logoView.size = CGSizeMake(AvatarViewHeightWithoutShowFans, AvatarViewHeightWithoutShowFans);
        [self.logoView setupVerifyViewForLength:AvatarViewHeightWithoutShowFans adaptationSizeBlock:nil];
        [self.logoView refreshDecoratorView];
        self.fansLabel.hidden = YES;
    }
    
    if (self.titleLabel.alpha > 0 && !self.isAnimating) {
        self.logoView.centerY = self.height/2;
        self.titleLabel.centerY = self.height/2;
    }
    
    if (self.type == TTArticleDetailNavigationTitleViewTypeFollow) {
        self.logoView.hidden = YES;
        
        w = self.titleLabel.width;
        
        if (w <= self.width) {
            left = (self.width - w)/2;
        } else {
            self.titleLabel.width = self.width;
        }
        
        self.titleLabel.left = left;
    }
    else if (self.type == TTArticleDetailNavigationTitleViewTypeShowFans){
        self.logoView.hidden = NO;
        self.titleLabel.hidden = YES;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:TextFontSizeWithShowFans];
        [self.titleLabel sizeToFit];
        self.logoView.size = CGSizeMake(AvatarViewHeightWithShowFans, AvatarViewHeightWithShowFans);
        [self.logoView setupVerifyViewForLength:AvatarViewHeightWithShowFans adaptationSizeBlock:nil];
        [self.logoView refreshDecoratorView];
        if (self.logoView.imageView.layer.borderWidth){
            self.logoView.imageView.layer.borderWidth = 0;
        }
        left = 2;
        self.logoView.left = left;
        self.logoView.centerY = self.height / 2;
        left = self.logoView.right + PaddingRightAvatarView;
        CGFloat maxTitleLabelWidth = self.width - left - OffsetLeftTitleView;
        self.titleLabel.left = left;
        if (self.titleLabel.width > maxTitleLabelWidth){
            self.titleLabel.width = maxTitleLabelWidth;
        }
        self.fansLabel.left = left;
        if (self.fansLabel.text){
            CGFloat totalHeight = self.titleLabel.height + self.fansLabel.height + PaddingBottomText;
            self.titleLabel.top = (self.height - totalHeight) / 2;
            self.fansLabel.top = self.titleLabel.bottom + PaddingBottomText;
        }else{
            self.titleLabel.centerY = self.logoView.centerY;
        }
        self.titleLabel.hidden = NO;
        self.fansLabel.hidden = NO;
    }
    else if (self.type == TTArticleDetailNavigationTitleViewTypeFollowLeft){
        left = 2;
        self.logoView.hidden = YES;
        self.titleLabel.left = left;
    }
    else {
        w = self.logoView.width + padding + self.titleLabel.width;
        
        if (w <= self.width) {
            left = (self.width - w)/2;
        } else {
            if (w <= self.width) {
                left = (self.width - w)/2;
            } else {
                self.titleLabel.width = self.width - self.logoView.width - padding;
            }
            
            self.logoView.left = left;
            self.titleLabel.left = self.logoView.right + padding;
        }
        
    }
    if(self.type == TTArticleDetailNavigationTitleViewTypeShowFans || self.type == TTArticleDetailNavigationTitleViewTypeFollowLeft){
        
    }
    else if (self.logoView.hidden) {
        w = self.titleLabel.width;
        
        if (w <= self.width) {
            left = (self.width - w)/2;
        } else {
            self.titleLabel.width = self.width;
        }
        
        self.titleLabel.left = left;
        
    }
    else {
        w = self.logoView.width + padding + self.titleLabel.width;
        
        if (w <= self.width) {
            left = (self.width - w)/2;
        } else {
            self.titleLabel.width = self.width - self.logoView.width - padding;
        }
        
        self.logoView.left = left;
        self.titleLabel.left = self.logoView.right + padding;
    }
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
}

//- (void)updateNavigationTitle:(NSString *)title imageURL:(NSString *)url
//{
//    self.titleLabel.text = title;
//    [self.titleLabel sizeToFit];
//
//    if (!isEmptyString(url)) {
//        [self.logoView setImageWithURLString:url];
//        self.logoView.hidden = NO;
//    } else {
//        [self.logoView setImageWithURLString:nil];
//        self.logoView.hidden = YES;
//    }
//
//    if (self.logoView.hidden) {
//        self.width = self.titleLabel.width;
//    } else {
//        self.width = self.titleLabel.width + 9 + self.logoView.width;
//    }
//
//    [self setNeedsLayout];
//}

- (void)updateNavigationTitle:(NSString *)title imageURL:(NSString *)url verifyInfo:(nonnull NSString *)verifyInfo decoratorURL:(NSString *)decoratorURL fansNum:(long long)fansNum
{
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    if (fansNum >= [SSCommonLogic navBarShowFansMinNum]){
        fansNum = fansNum < 0 ? 0 : fansNum;
        self.fansLabel.text = [NSString stringWithFormat:@"%@粉丝",[TTBusinessManager formatCommentCount:fansNum]];
        [self.fansLabel sizeToFit];
    }else{
        self.fansLabel.text = nil;
    }
    
    BOOL logoViewIsHiden = (self.type == TTArticleDetailNavigationTitleViewTypeFollow || self.type == TTArticleDetailNavigationTitleViewTypeFollowLeft || isEmptyString(url));
    [self showVerifyIconWithVerifyInfo:verifyInfo decoratorURL:decoratorURL logoViewIsHiden:logoViewIsHiden];
    
    if (!isEmptyString(url)) {
        [self.logoView setImageWithURLString:url];
        //        self.logoView.hidden = NO;
    } else {
        [self.logoView setImageWithURLString:nil];
        //        self.logoView.hidden = YES;
    }
    
    if (self.logoView.hidden) {
        self.width = self.titleLabel.width;
    } else {
        self.width = self.titleLabel.width + 9 + self.logoView.width;
    }
    if (self.type == TTArticleDetailNavigationTitleViewTypeShowFans || self.type == TTArticleDetailNavigationTitleViewTypeFollowLeft){
        self.width = CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    
    [self setNeedsLayout];
}

- (void)showVerifyIconWithVerifyInfo:(NSString *)verifyInfo decoratorURL:(NSString *)decoratorURL logoViewIsHiden:(BOOL)logoViewIsHiden{
    BOOL isVerified = [TTVerifyIconHelper isVerifiedOfVerifyInfo:verifyInfo];
    [self.titleLabel removeAllIcons];
    [self.logoView showOrHideVerifyViewWithVerifyInfo:nil decoratorInfo:nil];
    if(logoViewIsHiden){
        if (isVerified) {
            [self.titleLabel addIconWithVerifyInfo:verifyInfo];
        }
    }
    else{
        [self.logoView showOrHideVerifyViewWithVerifyInfo:verifyInfo decoratorInfo:decoratorURL sureQueryWithID:YES userID:nil];
    }
    [self.titleLabel refreshIconView];
}

- (void)setTapHandler:(TitleViewTapHandler)tapHandler {
    self.titleViewTapHandler = tapHandler;
}

- (void)clickTitleView:(UIGestureRecognizer *)gesture {
    if (self.titleViewTapHandler) {
        self.titleViewTapHandler();
    }
}

- (void)setTitleAlpha:(CGFloat)alpha {
    self.titleLabel.alpha = alpha;
    self.logoView.alpha = alpha;
    self.fansLabel.alpha = alpha;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL shouldReceiveTouch = YES;
    if (_type == TTArticleDetailNavigationTitleViewTypeShowFans || _type == TTArticleDetailNavigationTitleViewTypeFollowLeft){
        shouldReceiveTouch = touch.view == _logoView || touch.view == _titleLabel || touch.view == _fansLabel;
        if (!shouldReceiveTouch){
            CGPoint touchPoint = [touch locationInView:self];
            CGRect contentFrame = contentFrame = _titleLabel.frame;
            if (_type == TTArticleDetailNavigationTitleViewTypeShowFans){
                contentFrame = CGRectMake(_logoView.left,
                                          MIN(_logoView.top, _titleLabel.top),
                                          MAX(_titleLabel.right, _fansLabel.right) - _logoView.left,
                                          _logoView.height);
            }
            shouldReceiveTouch = CGRectContainsPoint(contentFrame, touchPoint);
        }
    }
    return self.titleLabel.alpha > 0 && shouldReceiveTouch;
}

- (void)show:(BOOL)bShow animated:(BOOL)animated
{
    if (bShow && animated && self.isAnimating) {
        return;
    }
    
    if (self.isShow && bShow) {
        return;
    }
    
    self.isShow = bShow;
    
    CGFloat destY = self.height / 2;
    CGFloat destAlpha = bShow ? 1 : 0;
    self.logoView.hidden = NO;
    //    dispatch_async(dispatch_get_main_queue(), ^{
    if (animated) {
        _isAnimating = YES;
        
        UIViewAnimationOptions option = bShow ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn;
        
        if (self.type == TTArticleDetailNavigationTitleViewTypeShowFans){
            self.logoView.centerY = destY;
            if (self.fansLabel.text){
                CGFloat totalHeight = self.titleLabel.height + self.fansLabel.height + PaddingBottomText;
                self.titleLabel.top = (self.height - totalHeight) / 2;
                self.fansLabel.top = self.titleLabel.bottom + PaddingBottomText;
            }else{
                self.titleLabel.centerY = self.logoView.centerY;
            }
        }else{
            self.titleLabel.centerY = destY;
            self.logoView.centerY = destY;
        }
        [UIView animateWithDuration:0.15 delay:0 options:option animations:^{
            [self setTitleAlpha:destAlpha];
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
        }];
        
    } else {
       
        if (self.type == TTArticleDetailNavigationTitleViewTypeShowFans){
             self.logoView.centerY = destY;
            if (self.fansLabel.text){
                CGFloat totalHeight = self.titleLabel.height + self.fansLabel.height + PaddingBottomText;
                self.titleLabel.top = (self.height - totalHeight) / 2;
                self.fansLabel.top = self.titleLabel.bottom + PaddingBottomText;
            }else{
                self.titleLabel.centerY = self.logoView.centerY;
            }
        }else{
            self.titleLabel.centerY = destY;
            self.logoView.centerY = destY;
        }
        [self setTitleAlpha:destAlpha];
    }
    //    });
}

@end

