//
//  TTRedPacketBaseView.m
//  Article
//
//  Created by Jiyee Sheng on 8/1/17.
//
//

#import "TTRedPacketBaseView.h"
#import "TTUIResponderHelper.h"
//#import "UIImage+TTSFResource.h"
#import <UIViewAdditions.h>
#import <TTDeviceUIUtils.h>
#import <TTDeviceHelper.h>
#import <TTThemeManager.h>

#define kTTRedPacketViewWidth              [TTDeviceUIUtils tt_newPadding:300.f]
#define kTTRedPacketViewHeight             [TTDeviceUIUtils tt_newPadding:410.f]
#define kTTRedPacketViewCornerRadius       [TTDeviceUIUtils tt_newPadding:8.f]
#define kTTHeaderViewHeight                [TTDeviceUIUtils tt_newPadding:300.f]
#define kTTFooterViewHeight                [TTDeviceUIUtils tt_newPadding:110.f]
#define kTTCloseButtonSize                 [TTDeviceUIUtils tt_newPadding:36.f]
#define kTTOpenRedPacketButtonSize         [TTDeviceUIUtils tt_newPadding:100.f]
#define kTTOpenRedPacketButtonMargin       [TTDeviceUIUtils tt_newPadding:246.f]

@interface TTRedPacketBaseView () <CAAnimationDelegate>

@end

@implementation TTRedPacketBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.width = [TTUIResponderHelper screenSize].width;
        self.height = [TTUIResponderHelper screenSize].height;
        
        self.tintColor = [UIColor clearColor];
        
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.headerView];
        [self.containerView addSubview:self.footerView];
        
        [self.containerView addSubview:self.closeButton];
        [self.containerView addSubview:self.openRedPacketButton];
        [self.containerView addSubview:self.coinsAnimationImageView];
        
        [self drawRedPacketLayer];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.center = self.center;
    self.headerView.frame = CGRectMake(0, 0, self.containerView.width, kTTHeaderViewHeight);
    self.footerView.frame = CGRectMake(0, self.containerView.height - kTTFooterViewHeight, self.containerView.width, kTTFooterViewHeight);
    
    self.closeButton.top = 0;
    self.closeButton.right = self.containerView.width;
    self.openRedPacketButton.centerX = self.containerView.width / 2;
    self.openRedPacketButton.top = kTTOpenRedPacketButtonMargin;
    self.coinsAnimationImageView.frame = self.openRedPacketButton.frame;
}

- (void)drawRedPacketLayer {
    self.containerView.center = self.center;
    
    CGFloat originX = self.containerView.origin.x;
    CGFloat originY = self.containerView.origin.y;
    
    CGFloat maskLayerWidth = self.containerView.size.width;
    CGFloat maskLayerHeight = [TTDeviceUIUtils tt_newPadding:270];
    
    CGFloat gradientLayerWidth = self.containerView.size.width;
    CGFloat gradientLayerHeight = [TTDeviceUIUtils tt_newPadding:300];
    
    // 1. 绘制 bottomLayer
    UIBezierPath *bottomLayerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(originX, originY + maskLayerHeight, maskLayerWidth, self.containerView.size.height - maskLayerHeight)
                                                          byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                                cornerRadii:CGSizeMake(kTTRedPacketViewCornerRadius, kTTRedPacketViewCornerRadius)];
    [bottomLayerPath moveToPoint:CGPointMake(originX, originY + maskLayerHeight)];
    [bottomLayerPath addQuadCurveToPoint:CGPointMake(originX + maskLayerWidth, originY + maskLayerHeight) controlPoint:CGPointMake(originX + maskLayerWidth / 2, originY + gradientLayerHeight + 30)]; // 控制点是切线焦点
    
    _bottomLayer = [CAShapeLayer layer];
    _bottomLayer.path = bottomLayerPath.CGPath;
    _bottomLayer.zPosition = -3;
    [_bottomLayer setFillColor:[UIColor colorWithHexString:@"E13D35"].CGColor];
    
    [self.layer addSublayer:_bottomLayer];
    
    // 2. 绘制 gradientLayer
    CGFloat radius = 8.f;
    UIBezierPath *maskLayerPath = [UIBezierPath bezierPath];
    [maskLayerPath moveToPoint:CGPointMake(originX + maskLayerWidth, originY + radius)];
    [maskLayerPath addArcWithCenter:CGPointMake(originX + maskLayerWidth - radius, originY + radius)
                             radius:radius
                         startAngle:(CGFloat) (0 * M_PI / 180)
                           endAngle:(CGFloat) (-90 * M_PI / 180)
                          clockwise:NO];
    [maskLayerPath addLineToPoint:CGPointMake(originX + radius, originY)];
    [maskLayerPath addArcWithCenter:CGPointMake(originX + radius, originY + radius)
                             radius:radius
                         startAngle:(CGFloat) (-90 * M_PI / 180)
                           endAngle:(CGFloat) (-180 * M_PI / 180)
                          clockwise:NO];
    [maskLayerPath addLineToPoint:CGPointMake(originX, originY + maskLayerHeight)];
    [maskLayerPath addQuadCurveToPoint:CGPointMake(originX + maskLayerWidth, originY + maskLayerHeight) controlPoint:CGPointMake(originX + maskLayerWidth / 2, originY + gradientLayerHeight + 30)]; // 控制点是切线焦点
    [maskLayerPath closePath];
    
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.path = maskLayerPath.CGPath;
    
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = CGRectMake(0, 0, self.width, originY + gradientLayerHeight);
    [_gradientLayer setColors:@[
                                (id) [UIColor colorWithHexString:@"F88981"].CGColor,
                                (id) [UIColor colorWithHexString:@"F36962"].CGColor,
                                (id) [UIColor colorWithHexString:@"EF514A"].CGColor
                                ]];
    [_gradientLayer setLocations:@[@(0), @(0.1), @(0.4)]];
    [_gradientLayer setStartPoint:CGPointMake(originX / _gradientLayer.frame.size.width, originY / _gradientLayer.frame.size.height)];
    [_gradientLayer setEndPoint:CGPointMake((originX + maskLayerWidth) / _gradientLayer.frame.size.width, (originY + maskLayerHeight) / _gradientLayer.frame.size.height)];
    [_gradientLayer setMask:_maskLayer];
    _gradientLayer.zPosition = -2;
    
    [self.layer addSublayer:_gradientLayer];
    
    // 3. 绘制 shadowLayer
    _shadowLayer = [CAShapeLayer layer];
    _shadowLayer.path = maskLayerPath.CGPath;
    _shadowLayer.zPosition = -1;
    [_shadowLayer setFillColor:[UIColor clearColor].CGColor];
    [_shadowLayer setShadowColor:[UIColor blackColor].CGColor];
    [_shadowLayer setShadowOffset:CGSizeMake(0, 1)];
    [_shadowLayer setShadowOpacity:0.07];
    [_shadowLayer setShadowRadius:8];
    
    [self.layer addSublayer:_shadowLayer];
}

- (void)startLoadingAnimation {
    self.openRedPacketButton.enabled = NO;
    self.coinsAnimationImageView.image = [UIImage imageNamed:@"coins_fall_0"];
    self.coinsAnimationImageView.hidden = NO;
    [self.coinsAnimationImageView startAnimating];
}

- (void)stopLoadingAnimation {
    self.openRedPacketButton.enabled = YES;
    [self.coinsAnimationImageView stopAnimating];
    self.coinsAnimationImageView.image = [UIImage imageNamed:@"coins_fall_20"];
    self.coinsAnimationImageView.hidden = YES;
}

- (void)coinsAnimationDidFinished {
    [self performSelector:@selector(startTransitionAnimation) withObject:nil afterDelay:1];
}

- (void)startTransitionAnimation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketWillStartTransitionAnimation)]) {
        [self.delegate redPacketWillStartTransitionAnimation];
    }
    
    self.closeButton.hidden = YES;
    self.openRedPacketButton.hidden = YES;
    self.coinsAnimationImageView.hidden = YES;
    self.shadowLayer.hidden = YES;
    
    CGFloat gradientLayerWidth = self.containerView.size.width;
    CGFloat gradientLayerHeight = [TTDeviceUIUtils tt_newPadding:300];
    
    CGFloat scale = self.width / gradientLayerWidth;
    
    // 1. 将 bottomLayer 移出屏幕
    UIBezierPath *bottomLayerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, self.height, self.width, (self.height - gradientLayerHeight) * scale)
                                                          byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                                cornerRadii:CGSizeMake(kTTRedPacketViewCornerRadius, kTTRedPacketViewCornerRadius)];
    [bottomLayerPath moveToPoint:CGPointMake(0, self.height)];
    [bottomLayerPath addQuadCurveToPoint:CGPointMake(self.width, self.height) controlPoint:CGPointMake(self.width / 2, (self.height + 70) * scale)];
    
    CABasicAnimation *bottomLayerPathAnimation = [CABasicAnimation animation];
    bottomLayerPathAnimation.keyPath = @"path";
    bottomLayerPathAnimation.toValue = (__bridge id) bottomLayerPath.CGPath;
    bottomLayerPathAnimation.duration = 0.3; // 加快动画，让 bottomLayer 提早消失
    bottomLayerPathAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.32 :0.94 :0.6 :1];
    bottomLayerPathAnimation.fillMode = kCAFillModeForwards;
    bottomLayerPathAnimation.removedOnCompletion = NO;
    [_bottomLayer addAnimation:bottomLayerPathAnimation forKey:nil];
    
    // 2. 通过对 maskLayer 执行动画来改变 gradientLayer 显示效果
    CGFloat gradientLayerTargetY = 20 + 44 + [TTDeviceUIUtils tt_newPadding:43];
    CGFloat maskLayerOriginX = _gradientLayer.frame.origin.x;
    CGFloat maskLayerOriginY = gradientLayerTargetY - gradientLayerHeight * scale;
    CGFloat maskLayerWidth = _gradientLayer.frame.size.width;
    CGFloat maskLayerHeight = gradientLayerHeight * scale;
    CGFloat radius = 8.f;
    
    UIBezierPath *maskLayerPath = [UIBezierPath bezierPath];
    [maskLayerPath moveToPoint:CGPointMake(maskLayerOriginX + maskLayerWidth, maskLayerOriginY + radius)];
    [maskLayerPath addArcWithCenter:CGPointMake(maskLayerOriginX + maskLayerWidth - radius, maskLayerOriginY + radius)
                             radius:radius
                         startAngle:(CGFloat) (0 * M_PI / 180)
                           endAngle:(CGFloat) (-90 * M_PI / 180)
                          clockwise:NO];
    [maskLayerPath addLineToPoint:CGPointMake(maskLayerOriginX + radius, maskLayerOriginY)];
    [maskLayerPath addArcWithCenter:CGPointMake(maskLayerOriginX + radius, maskLayerOriginY + radius)
                             radius:radius
                         startAngle:(CGFloat) (-90 * M_PI / 180)
                           endAngle:(CGFloat) (-180 * M_PI / 180)
                          clockwise:NO];
    [maskLayerPath addLineToPoint:CGPointMake(0, gradientLayerTargetY)];
    [maskLayerPath addQuadCurveToPoint:CGPointMake(maskLayerWidth, gradientLayerTargetY) controlPoint:CGPointMake(maskLayerWidth / 2, gradientLayerTargetY + 70)];
    [maskLayerPath closePath];
    
    CABasicAnimation *maskLayerPathAnimation = [CABasicAnimation animation];
    maskLayerPathAnimation.keyPath = @"path";
    maskLayerPathAnimation.toValue = (__bridge id) maskLayerPath.CGPath;
    maskLayerPathAnimation.duration = 0.4;
    maskLayerPathAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.32 :0.94 :0.6 :1];
    maskLayerPathAnimation.fillMode = kCAFillModeForwards;
    maskLayerPathAnimation.removedOnCompletion = NO;
    maskLayerPathAnimation.delegate = self;
    [_maskLayer addAnimation:maskLayerPathAnimation forKey:@"pathAnim"];
    
    // 3. 同步改变渐变颜色
    NSString *color = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight ? @"8A3B37" : @"EF514A";
    CABasicAnimation *gradientLayerColorsAnimation = [CABasicAnimation animation];
    gradientLayerColorsAnimation.keyPath = @"colors";
    gradientLayerColorsAnimation.toValue = @[
                                             (__bridge id) [UIColor colorWithHexString:color].CGColor,
                                             (__bridge id) [UIColor colorWithHexString:color].CGColor,
                                             (__bridge id) [UIColor colorWithHexString:color].CGColor
                                             ];
    gradientLayerColorsAnimation.duration = 0.4;
    gradientLayerColorsAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.32 :0.94 :0.6 :1];
    gradientLayerColorsAnimation.fillMode = kCAFillModeForwards;
    gradientLayerColorsAnimation.removedOnCompletion = NO;
    [_gradientLayer addAnimation:gradientLayerColorsAnimation forKey:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketDidStartTransitionAnimation)]) {
        [self.delegate redPacketDidStartTransitionAnimation];
    }
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([anim isEqual:[self.maskLayer animationForKey:@"pathAnim"]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketDidFinishTransitionAnimation)]) {
            [self.delegate redPacketDidFinishTransitionAnimation];
        }
    }
}

#pragma mark - actions

- (void)openRedPacketAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketDidClickOpenRedPacketButton)]) {
        [self.delegate redPacketDidClickOpenRedPacketButton];
    }
}

- (void)closeAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketDidClickCloseButton)]) {
        [self.delegate redPacketDidClickCloseButton];
    }
}

#pragma mark - getter and setter

- (SSThemedView *)containerView {
    if (!_containerView) {
        _containerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, kTTRedPacketViewWidth, kTTRedPacketViewHeight)];
    }
    
    return _containerView;
}

- (SSThemedView *)headerView {
    if (!_headerView) {
        _headerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, kTTRedPacketViewWidth, kTTHeaderViewHeight)];
    }
    
    return _headerView;
}

- (SSThemedView *)footerView {
    if (!_footerView) {
        _footerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, kTTRedPacketViewHeight - kTTFooterViewHeight, kTTRedPacketViewWidth, kTTFooterViewHeight)];
    }
    
    return _footerView;
}

- (SSThemedButton *)openRedPacketButton {
    if (!_openRedPacketButton) {
        _openRedPacketButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _openRedPacketButton.frame = CGRectMake(0, 0, kTTOpenRedPacketButtonSize, kTTOpenRedPacketButtonSize);
        _openRedPacketButton.layer.cornerRadius = kTTOpenRedPacketButtonSize / 2;
        _openRedPacketButton.clipsToBounds = YES;
        [_openRedPacketButton setImage:[UIImage imageNamed:@"open_redpacket"] forState:UIControlStateNormal];
        [_openRedPacketButton addTarget:self action:@selector(openRedPacketAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _openRedPacketButton;
}

- (UIImageView *)coinsAnimationImageView {
    if (!_coinsAnimationImageView) {
        _coinsAnimationImageView = [[SSThemedImageView alloc] initWithFrame:self.openRedPacketButton.frame];
        _coinsAnimationImageView.layer.cornerRadius = kTTOpenRedPacketButtonSize / 2;
        _coinsAnimationImageView.clipsToBounds = YES;
        NSMutableArray *images = [NSMutableArray array];
        for (NSInteger count = 0; count <= 20; count++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"coins_fall_%ld", count]];
            [images addObject:image];
        }
        _coinsAnimationImageView.image = [UIImage imageNamed:@"coins_fall_0"];
        _coinsAnimationImageView.animationImages = [images copy];
        _coinsAnimationImageView.animationDuration = 0.4;
        _coinsAnimationImageView.hidden = YES;
    }
    
    return _coinsAnimationImageView;
}

- (SSThemedButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, kTTCloseButtonSize, kTTCloseButtonSize)];
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -8, -8, 0);
        _closeButton.layer.zPosition = 2;
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        SSThemedImageView *closeImageView = [[SSThemedImageView alloc] init];
        closeImageView.imageName = @"close_redpacket";
        closeImageView.enableNightCover = NO;
        closeImageView.frame = CGRectMake(0, 0, closeImageView.image.size.width, closeImageView.image.size.height);
        closeImageView.center = CGPointMake(_closeButton.width / 2, _closeButton.height / 2);
        [_closeButton addSubview:closeImageView];
    }
    
    return _closeButton;
}

@end

