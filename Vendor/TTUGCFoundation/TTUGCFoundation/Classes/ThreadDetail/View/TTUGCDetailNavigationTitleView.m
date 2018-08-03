//
//  TTUGCDetailNavigationTitleView.m
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/2/1.
//

#import "TTUGCDetailNavigationTitleView.h"
#import <ExploreAvatarView.h>
#import <TTIconLabel.h>
#import <TTDeviceUIUtils.h>
#import <ExploreAvatarView+VerifyIcon.h>
#import <UIViewAdditions.h>
#import <TTBusinessManager+StringUtils.h>
#import <TTIconLabel+VerifyIcon.h>
#import <TTUGCPodBridge.h>

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


@interface TTUGCDetailNavigationTitleView () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) ExploreAvatarView    *logoView;
@property(nonatomic, strong) TTIconLabel  *titleLabel;
@property(nonatomic, strong) SSThemedLabel *fansLabel;
@property(nonatomic, copy) TitleViewTapHandler titleViewTapHandler;
@property(nonatomic, assign) BOOL isAnimating;
@property(nonatomic, assign) BOOL isShow;

@end

@implementation TTUGCDetailNavigationTitleView

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
    if(self.type != TTUGCDetailNavigationTitleViewTypeShowFans){
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
    
    if (self.type == TTUGCDetailNavigationTitleViewTypeFollow) {
        self.logoView.hidden = YES;
        
        w = self.titleLabel.width;
        
        if (w <= self.width) {
            left = (self.width - w)/2;
        } else {
            self.titleLabel.width = self.width;
        }
        
        self.titleLabel.left = left;
    }
    else if (self.type == TTUGCDetailNavigationTitleViewTypeShowFans){
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
    else if (self.type == TTUGCDetailNavigationTitleViewTypeFollowLeft){
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
    if(self.type == TTUGCDetailNavigationTitleViewTypeShowFans || self.type == TTUGCDetailNavigationTitleViewTypeFollowLeft){
        
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
    if (fansNum >= [[TTUGCPodBridge sharedInstance] navBarShowFansMinNum]) {
        fansNum = fansNum < 0 ? 0 : fansNum;
        self.fansLabel.text = [NSString stringWithFormat:@"%@粉丝",[TTBusinessManager formatCommentCount:fansNum]];
        [self.fansLabel sizeToFit];
    } else {
        self.fansLabel.text = nil;
    }
    
    BOOL logoViewIsHiden = (self.type == TTUGCDetailNavigationTitleViewTypeFollow || self.type == TTUGCDetailNavigationTitleViewTypeFollowLeft || isEmptyString(url));
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
    if (self.type == TTUGCDetailNavigationTitleViewTypeShowFans || self.type == TTUGCDetailNavigationTitleViewTypeFollowLeft){
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
    if (_type == TTUGCDetailNavigationTitleViewTypeShowFans || _type == TTUGCDetailNavigationTitleViewTypeFollowLeft){
        shouldReceiveTouch = touch.view == _logoView || touch.view == _titleLabel || touch.view == _fansLabel;
        if (!shouldReceiveTouch){
            CGPoint touchPoint = [touch locationInView:self];
            CGRect contentFrame = contentFrame = _titleLabel.frame;
            if (_type == TTUGCDetailNavigationTitleViewTypeShowFans){
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
        
        if (self.type == TTUGCDetailNavigationTitleViewTypeShowFans){
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
        
        if (self.type == TTUGCDetailNavigationTitleViewTypeShowFans){
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
