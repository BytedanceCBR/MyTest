//
//  SSTitleBarView.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SSTitleBarView.h"
#import "UIImage+TTThemeExtension.h"
#import "UIColor+TTThemeExtension.h"
#import "TTDeviceHelper.h"
 

#define EdgeInsetsLeftDefaultMargin 0.f
#define EdgeInsetsRightDefaultMargin 0.f

@interface SSTitleBarView()

@property(nonatomic, strong) CAGradientLayer * bottomShadowLayer;

@property(nonatomic, strong) UIView * backgroundView;
@property(nonatomic, strong) UIView * bottomView;
//外部实现， titleBar只负责修改Origin
@property (nonatomic, strong) UIView * titleBadgeView;


@property(nonatomic, strong, readwrite) UIView * baseView;


@end

@implementation SSTitleBarView

@synthesize titleBarEdgeInsets = _titleBarEdgeInsets;

@synthesize leftView = _leftView;
@synthesize rightView = _rightView;
@synthesize titleLabel = _titleLabel;
@synthesize centerView = _centerView;

@synthesize baseView = _baseView;

@synthesize backgroundView = _backgroundView;
@synthesize portraitBackgroundView = _portraitBackgroundView;
@synthesize landscapeBackgroundView = _landscapeBackgroundView;

@synthesize bottomView = _bottomView;
@synthesize landscapeBottomView = _landscapeBottomView;
@synthesize portraitBottomView = _portraitBottomView;

@synthesize bottomShadowLayer = _bottomShadowLayer;

+ (float)titleBarHeight
{
    return 64.f;
}

#pragma mark -- dealloc & init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self buildSubViews];
        
        NSString * defaultImageName = @"";
        if (!isEmptyString(defaultImageName)) {
            UIImage *portraitImage = [[UIImage themedImageNamed:defaultImageName] stretchableImageWithLeftCapWidth:0.5 topCapHeight:22];
            self.portraitBackgroundView = [[UIImageView alloc] initWithImage:portraitImage];
        }
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)buildSubViews
{
    self.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"cc3131" nightColorName:@"651414"]];
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_backgroundView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame), CGRectGetWidth(self.frame), 0)];
    _bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bottomView];
    
    CGRect baseViewFrame = [self frameForBaseView];
    self.baseView = [[UIView alloc] initWithFrame:baseViewFrame];
    _baseView.backgroundColor = [UIColor clearColor];
    [self addSubview:_baseView];
    
    self.titleBarEdgeInsets = UIEdgeInsetsMake(0, EdgeInsetsLeftDefaultMargin, 0, EdgeInsetsRightDefaultMargin);
    
    _baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"fafafa" nightColorName:@"b1b1b1"]];
    _titleLabel.hidden = YES;
    _titleLabel.backgroundColor = [UIColor clearColor];
    
    
    
    float titleSize = 20.f;
    
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:titleSize]];
    
    [self addSubview:_titleLabel];
    
    self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - [TTDeviceHelper ssOnePixel], self.frame.size.width, [TTDeviceHelper ssOnePixel])];
    _bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _bottomLineView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bottomLineView];
    
    self.titleLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_titleLabelButton];
    
}

#pragma mark -- private method

+ (void)removeAllSubViews:(UIView *) view
{
    for (UIView * v in [view subviews]) {
        [v removeFromSuperview];
    }
}

//if removed return yes
+ (BOOL)removeSubView:(UIView *)subView fromView:(UIView *)view
{
    BOOL isSubView = NO;
    for (UIView * v in [view subviews]) {
        if (v == subView) {
            isSubView = YES;
        }
    }
    if (isSubView) {
        [SSTitleBarView removeAllSubViews:subView];
    }
    return isSubView;
}

- (void)relayout
{
    [self changeBackgroundImageIfNeed];
    
    [self changeBottomImageViewIfNeed];
    
    CGRect bottomFrame = _bottomShadowLayer.frame;
    bottomFrame.size.width = self.frame.size.width;
    _bottomShadowLayer.frame = bottomFrame;
    self.bottomLineView.frame = CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
    [self refreshTitleLabelPosition];
}

#pragma mark -- public method

/*
 *  设置可拉伸的背景
 */
- (void)setBackgroundImage:(UIImage *)image
{
    self.portraitBackgroundView = [[UIImageView alloc] initWithImage:image];
    self.portraitBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.portraitBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)setTitleText:(NSString *)title
{
    NSString * fixtitle = title;
    if ([fixtitle length] > 10 && ![TTDeviceHelper isPadDevice]) {
        fixtitle = [NSString stringWithFormat:@"%@...", [title substringToIndex:9]];
    }
    _titleLabel.hidden = [fixtitle length] > 0 ? NO : YES;
    _titleLabel.text = fixtitle;
    [_titleLabel sizeToFit];
    [self refreshTitleLabelPosition];
}

- (void)refreshTitleLabelPosition
{
    _titleLabel.center = self.center;
    _titleLabel.centerY = _titleLabel.centerY + 10;
    
    [self refreshTitleBadageFrame];
    self.titleLabelButton.frame = _titleLabel.frame;
}

- (void)refreshTitleBadageFrame {
    if (CGRectGetMaxX(_titleLabel.frame) == 0) {
        _titleBadgeView.center = self.center;
    }
    else {
        _titleBadgeView.origin = CGPointMake( CGRectGetMaxX(_titleLabel.frame) + 4, CGRectGetMinY(_titleLabel.frame));
    }
}

- (void)addTitleBadgeView:(UIView *)view
{
    self.titleBadgeView = view;
    [self addSubview:view];
    [self refreshTitleBadageFrame];
}

- (void)showBottomShadow
{
    if (_bottomShadowLayer != nil) {
        return;
    }
    UIColor *darkColor = [UIColor colorWithHexString:@"0000003f"];
    UIColor *lightColor = [UIColor clearColor];
    self.bottomShadowLayer = [[CAGradientLayer alloc] init];
    _bottomShadowLayer.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 4.f);
    _bottomShadowLayer.colors = [NSArray arrayWithObjects:(id)(darkColor.CGColor), (id)(lightColor.CGColor), nil];
    [self.layer addSublayer:_bottomShadowLayer];
}

#pragma mark -- change code

- (void)changeBackgroundImageIfNeed
{
    if (_landscapeBackgroundView == nil && _portraitBackgroundView == nil) return;
    
    if (_landscapeBackgroundView == nil) {
        [self setBackgroundViewSingleSubView:_portraitBackgroundView];
        return;
    }
    
    if (_portraitBackgroundView == nil) {
        [self setBackgroundViewSingleSubView:_landscapeBackgroundView];
        return;
    }
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [self setBackgroundViewSingleSubView:_portraitBackgroundView];
    }
    else {
        [self setBackgroundViewSingleSubView:_landscapeBackgroundView];
    }
}

- (void)changeBottomImageViewIfNeed
{
    if (_landscapeBottomView == nil && _portraitBottomView == nil) return;
    
    if (_landscapeBottomView == nil) {
        [self setBottomViewSingleSubView:_portraitBottomView];
        return;
    }
    
    if (_portraitBottomView == nil) {
        [self setBottomViewSingleSubView:_landscapeBottomView];
        return;
    }
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [self setBottomViewSingleSubView:_portraitBottomView];
    }
    else {
        [self setBottomViewSingleSubView:_landscapeBottomView];
    }
}

- (CGRect)frameForBaseView
{
    CGRect baseViewFrame = CGRectZero;
    baseViewFrame.origin = CGPointMake(_titleBarEdgeInsets.left, _titleBarEdgeInsets.top);
    baseViewFrame.size.width = CGRectGetWidth(self.frame) - _titleBarEdgeInsets.left - _titleBarEdgeInsets.right;
    baseViewFrame.size.height = CGRectGetHeight(self.frame) - _titleBarEdgeInsets.top - _titleBarEdgeInsets.bottom;
    return baseViewFrame;
}

#pragma mark -- setter
- (void)setTitleBarEdgeInsets:(UIEdgeInsets)titleBarEdgeInsets
{
    _titleBarEdgeInsets = titleBarEdgeInsets;
    
    CGRect baseViewFrame = [self frameForBaseView];
    _baseView.frame = baseViewFrame;
}

- (void)setLeftView:(UIView *)leftView
{
    if (_leftView != leftView) {
        [_leftView removeFromSuperview];
        _leftView = leftView;
        leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        float originalY = (CGRectGetHeight(_baseView.frame) - CGRectGetHeight(leftView.frame)) / 2;
        originalY += 10;
        
        leftView.frame = CGRectMake(0, originalY, CGRectGetWidth(leftView.frame), CGRectGetHeight(leftView.frame));
        [_baseView addSubview:leftView];
    }
}

- (void)setRightView:(UIView *)rightView
{
    if (_rightView != rightView) {
        [_rightView removeFromSuperview];
        _rightView = rightView;
        _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        CGRect frame = _rightView.frame;
        frame.origin.x = CGRectGetWidth(_baseView.frame) - CGRectGetWidth(_rightView.frame);
        
        float originalY = (CGRectGetHeight(_baseView.frame) - CGRectGetHeight(rightView.frame)) / 2;
        originalY += 10;
        
        frame.origin.y = originalY;
        _rightView.frame = frame;
        [_baseView addSubview:_rightView];
    }
}

- (void)setCenterView:(UIView *)centerView
{
    if (_centerView != centerView) {
        [_centerView removeFromSuperview];
        _centerView = centerView;
        [_baseView addSubview:_centerView];
        _centerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    CGRect frame = _centerView.frame;
    frame.origin.x = (CGRectGetWidth(_baseView.frame) - CGRectGetWidth(_centerView.frame)) / 2;
    float originalY = (CGRectGetHeight(_baseView.frame) - CGRectGetHeight(centerView.frame)) / 2;;
    originalY += 10;
    frame.origin.y = originalY;
    _centerView.frame = frame;
}

- (void)setBottomViewSingleSubView:(UIView *)bottomView
{
    BOOL isSubView = NO;
    for (UIView * view in [_bottomView subviews]) {
        if (view == bottomView) {
            isSubView = YES;
        }
    }
    if (!isSubView) {
        [SSTitleBarView removeAllSubViews:_bottomView];
        [_bottomView addSubview:bottomView];
    }
}

- (void)setBackgroundViewSingleSubView:(UIView *)backgroundView
{
    BOOL isSubView = NO;
    for (UIView * view in [_backgroundView subviews]) {
        if (view == backgroundView) {
            isSubView = YES;
        }
    }
    if (!isSubView) {
        [SSTitleBarView removeAllSubViews:_backgroundView];
        [_backgroundView addSubview:backgroundView];
    }
}

- (void)setPortraitBackgroundView:(UIView *)portraitBackgroundView
{
    if (_portraitBackgroundView != portraitBackgroundView) {
        [SSTitleBarView removeSubView:_portraitBackgroundView fromView:_backgroundView];
        _portraitBackgroundView = portraitBackgroundView;
    }
    
    if (_landscapeBackgroundView == nil || UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [self setBackgroundViewSingleSubView:_portraitBackgroundView];
    }
    _portraitBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _portraitBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)setLandscapeBackgroundView:(UIView *)landscapeBackgroundView
{
    if (_landscapeBackgroundView != landscapeBackgroundView) {
        [SSTitleBarView removeSubView:_landscapeBackgroundView fromView:_backgroundView];
        _landscapeBackgroundView = landscapeBackgroundView;
    }
    
    if (_portraitBackgroundView == nil || UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        [self setBackgroundViewSingleSubView:_landscapeBottomView];
    }
}

- (void)setPortraitBottomView:(UIView *)portraitBottomView
{
    if (_portraitBottomView != portraitBottomView) {
        [SSTitleBarView removeSubView:_portraitBottomView fromView:_bottomView];
        _portraitBottomView = portraitBottomView;
    }
    if (_landscapeBottomView == nil || UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [self setBottomViewSingleSubView:_portraitBottomView];
    }
}

- (void)setLandscapeBottomView:(UIView *)landscapeBottomView
{
    if (_landscapeBottomView != landscapeBottomView) {
        [SSTitleBarView removeSubView:_landscapeBottomView fromView:_bottomView];
        _landscapeBottomView = landscapeBottomView;
    }
    
    if (_portraitBottomView == nil || UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        [self setBottomViewSingleSubView:_landscapeBottomView];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayout];
}

- (void)themeChanged:(NSNotification *)notification
{
    UIImageView *imageView = (UIImageView*)self.portraitBackgroundView;
    
    NSString * defaultImageName = @"";
    
    if (!isEmptyString(defaultImageName)) {
        [imageView setImage:[[UIImage themedImageNamed:defaultImageName] stretchableImageWithLeftCapWidth:0.5 topCapHeight:22]];
    }
    
    self.titleLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"fafafa" nightColorName:@"b1b1b1"]];
    self.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"cc3131" nightColorName:@"651414"]];
    NSString * bottomLineViewColorName = @"";
    if (!isEmptyString(bottomLineViewColorName)) {
        _bottomLineView.backgroundColor = [UIColor colorWithHexString:bottomLineViewColorName];
    }
}


@end
