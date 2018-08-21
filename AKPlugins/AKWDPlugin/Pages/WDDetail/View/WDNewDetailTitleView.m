//
//  WDNewDetailTitleView.m
//  Article
//
//  Created by 延晋 张 on 2016/12/6.
//
//

#import "WDNewDetailTitleView.h"
#import "WDFontDefines.h"
#import "WDDefines.h"
#import "WDUIHelper.h"
#import <TTAvatar/ExploreAvatarView+VerifyIcon.h>
#import <TTUIWidget/TTIconLabel+VerifyIcon.h>

#define AvatarViewHeightWithoutShowFans 24
#define AvatarViewHeightWithShowFans 36

@interface WDNewDetailTitleView () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) ExploreAvatarView    *logoView;
@property(nonatomic, strong) TTIconLabel  *titleLabel;
@property(nonatomic, strong) SSThemedLabel *fansLabel;
@property(nonatomic, copy) WDNewTitleViewTapHandler titleViewTapHandler;
@property(nonatomic, assign) BOOL isAnimating;
@property(nonatomic, assign) BOOL isShow;

@end

@implementation WDNewDetailTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = 44;
    self = [super initWithFrame:frame];
    if (self) {
        TTIconLabel * titleLabel = [[TTIconLabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColorThemeKey = kColorText1;
        titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        titleLabel.font = [UIFont systemFontOfSize:WDFontSize(17.0f)];
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
        fansLabel.font = [UIFont systemFontOfSize:WDFontSize(12.0f)];
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
        logoView.userInteractionEnabled = YES;
        logoView.enableBlackMaskView = YES;
        [logoView setupVerifyViewForLength:AvatarViewHeightWithoutShowFans adaptationSizeBlock:nil];
        [self addSubview:logoView];
        self.logoView = logoView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTitleView:)];
        tap.delegate = self;
        [logoView addGestureRecognizer:tap];
        
        [self show:NO animated:NO];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refreshUI];
}

- (void)refreshUI {
    CGFloat left = 0;
    
    if (self.titleLabel.alpha > 0 && !self.isAnimating) {
        self.logoView.centerY = self.height/2;
        self.titleLabel.centerY = self.height/2;
    }
    self.logoView.hidden = NO;
    self.titleLabel.hidden = YES;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:WDFontSize(14.0f)];
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
    left = self.logoView.right + WDPadding(10.0f);
    CGFloat maxTitleLabelWidth = self.width - left;
    self.titleLabel.left = left;
    if (self.titleLabel.width > maxTitleLabelWidth){
        self.titleLabel.width = maxTitleLabelWidth;
    }
    self.fansLabel.left = left;
    if (self.fansLabel.text){
        CGFloat totalHeight = self.titleLabel.height + self.fansLabel.height;
        self.titleLabel.top = (self.height - totalHeight) / 2;
        self.fansLabel.top = self.titleLabel.bottom;
    }else{
        self.titleLabel.centerY = self.logoView.centerY;
    }
    self.titleLabel.hidden = NO;
    self.fansLabel.hidden = NO;
    
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
}

- (void)updateNavigationTitle:(NSString *)title imageURL:(NSString *)url verifyInfo:(nonnull NSString *)verifyInfo decoration:(NSString *)decoration fansNum:(long long)fansNum
{
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    if (fansNum >= [self navBarShowFansMinNum]){
        fansNum = fansNum < 0 ? 0 : fansNum;
        self.fansLabel.text = [NSString stringWithFormat:@"%@粉丝",[TTBusinessManager formatCommentCount:fansNum]];
        [self.fansLabel sizeToFit];
    }else{
        self.fansLabel.text = nil;
    }
    
    BOOL logoViewIsHiden = (isEmptyString(url));
    [self showVerifyIconWithVerifyInfo:verifyInfo decoration:decoration logoViewIsHiden:logoViewIsHiden];
    
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
    self.width = CGRectGetWidth([UIScreen mainScreen].bounds);

    [self setNeedsLayout];
}

- (void)showVerifyIconWithVerifyInfo:(NSString *)verifyInfo decoration:(NSString *)decoration logoViewIsHiden:(BOOL)logoViewIsHiden {
    BOOL isVerified = [TTVerifyIconHelper isVerifiedOfVerifyInfo:verifyInfo];
    [self.titleLabel removeAllIcons];
    [self.logoView hideVerifyView];
    if(logoViewIsHiden){
        if (isVerified) {
            [self.titleLabel addIconWithVerifyInfo:verifyInfo];
        }
    }
    else{
        [self.logoView showOrHideVerifyViewWithVerifyInfo:verifyInfo decoratorInfo:decoration];
    }
    [self.titleLabel refreshIconView];
}

- (void)setTapHandler:(WDNewTitleViewTapHandler)tapHandler {
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
    if (!shouldReceiveTouch){
        CGPoint touchPoint = [touch locationInView:self];
        CGRect contentFrame = contentFrame = _titleLabel.frame;
        contentFrame = CGRectMake(_logoView.left,
                                  MIN(_logoView.top, _titleLabel.top),
                                  MAX(_titleLabel.right, _fansLabel.right) - _logoView.left,
                                  _logoView.height);
        shouldReceiveTouch = CGRectContainsPoint(contentFrame, touchPoint);
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
        
        self.logoView.centerY = destY;
        if (self.fansLabel.text){
            CGFloat totalHeight = self.titleLabel.height + self.fansLabel.height;
            self.titleLabel.top = (self.height - totalHeight) / 2;
            self.fansLabel.top = self.titleLabel.bottom;
        }else{
            self.titleLabel.centerY = self.logoView.centerY;
        }
        [UIView animateWithDuration:0.15 delay:0 options:option animations:^{
            [self setTitleAlpha:destAlpha];
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
        }];
    } else {
        self.logoView.centerY = destY;
        if (self.fansLabel.text){
            CGFloat totalHeight = self.titleLabel.height + self.fansLabel.height;
            self.titleLabel.top = (self.height - totalHeight) / 2;
            self.fansLabel.top = self.titleLabel.bottom;
        }else{
            self.titleLabel.centerY = self.logoView.centerY;
        }
        [self setTitleAlpha:destAlpha];
    }
    //    });
}

#pragma mark - Util

- (NSInteger)navBarShowFansMinNum
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kSSCommonLogicNavBarShowFansMinNumKey"]){
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"kSSCommonLogicNavBarShowFansMinNumKey"];
    }
    return 1;
}
@end
