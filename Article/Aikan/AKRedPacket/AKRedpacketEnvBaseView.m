//
//  AKRedpacketEnvBaseView.m
//  Article
//
//  Created by 冯靖君 on 2018/3/8.
//

#import "AKRedpacketEnvBaseView.h"
#import <TTLabelTextHelper.h>

#define kTTRedPacketViewWidth              [TTDeviceUIUtils tt_newPadding:300.f]
#define kTTRedPacketViewHeight             [TTDeviceUIUtils tt_newPadding:410.f]
#define kTTRedPacketViewCornerRadius       [TTDeviceUIUtils tt_newPadding:8.f]
#define kTTHeaderViewHeight                [TTDeviceUIUtils tt_newPadding:300.f]
#define kTTFooterViewHeight                [TTDeviceUIUtils tt_newPadding:110.f]
#define kTTCloseButtonSize                 [TTDeviceUIUtils tt_newPadding:36.f]
#define kTTOpenRedPacketButtonSize         [TTDeviceUIUtils tt_newPadding:100.f]
#define kTTOpenRedPacketButtonMargin       [TTDeviceUIUtils tt_newPadding:246.f]

#define kPaddingTopNameLabel                [TTDeviceUIUtils tt_newPadding:62.f]
#define kPaddingTopAmountLabel              [TTDeviceUIUtils tt_newPadding:30.5f]
#define kPaddingBottomImageView             [TTDeviceUIUtils tt_newPadding:18.f]

#define kFontSizeNameLabel                  [TTDeviceUIUtils tt_newFontSize:18.f]

#define kTTRedPacketViewWidth              [TTDeviceUIUtils tt_newPadding:300.f]
#define kTTRedPacketViewHeight             [TTDeviceUIUtils tt_newPadding:410.f]
#define kTTRedPacketViewCornerRadius       [TTDeviceUIUtils tt_newPadding:8.f]
#define kTTHeaderViewHeight                [TTDeviceUIUtils tt_newPadding:300.f]
#define kTTFooterViewHeight                [TTDeviceUIUtils tt_newPadding:110.f]
#define kTTCloseButtonSize                 [TTDeviceUIUtils tt_newPadding:36.f]
#define kTTOpenRedPacketButtonSize         [TTDeviceUIUtils tt_newPadding:100.f]
#define kTTOpenRedPacketButtonMargin       [TTDeviceUIUtils tt_newPadding:246.f]

@implementation AKRedpacketEnvViewModel

- (instancetype)initWithAmount:(NSInteger)amount
                    detailInfo:(NSDictionary *)detailInfo
                     shareInfo:(NSDictionary *)shareInfo
{
    self = [super init];
    if (self) {
        self.amount = [NSString stringWithFormat:@"%.2f",amount / 100.0];
        self.customDetailInfo = [detailInfo copy];
        self.shareInfo = [shareInfo copy];
    }
    return self;
}

@end

@interface AKRedpacketEnvBaseView ()

@property (nonatomic, strong) AKRedpacketEnvViewModel *viewModel;

@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *amountLabel;
@property (nonatomic, strong) UIImageView *topLayerImageView;
@property (nonatomic, strong) UIImageView *bottomImageView;

@end

@implementation AKRedpacketEnvBaseView

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(AKRedpacketEnvViewModel *)viewModel
{
    if (self = [super initWithFrame:frame]) {
        _viewModel = viewModel;
        self.width = [TTUIResponderHelper screenSize].width;
        self.height = [TTUIResponderHelper screenSize].height;
        
        self.tintColor = [UIColor clearColor];
        
        [self addSubview:self.containerView];
        [self bringSubviewToFront:self.containerView];
        
        [self.headerView addSubview:self.nameLabel];
        [self.headerView addSubview:self.amountLabel];
        
        [self.footerView addSubview:self.bottomImageView];

        [self.containerView addSubview:self.headerView];
        [self.containerView addSubview:self.footerView];
        
        [self.containerView addSubview:self.closeButton];
        [self.containerView addSubview:self.openRedPacketButton];
//        [self.containerView addSubview:self.coinsAnimationImageView];
        
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
//    self.coinsAnimationImageView.frame = self.openRedPacketButton.frame;
    
    [self.openRedPacketButton setImage:[UIImage imageNamed:@"red_env_open"] forState:UIControlStateNormal];
    
    self.bottomImageView.centerX = self.footerView.width/2;
    self.bottomImageView.top = self.footerView.height - kPaddingBottomImageView - self.bottomImageView.height;
    
    [self refreshHeaderView];
    [self refreshBgView];
}

- (void)refreshHeaderView
{
    self.nameLabel.text = @"恭喜！你收到一个现金红包";
    [self.nameLabel sizeToFit];
    self.nameLabel.top = kPaddingTopNameLabel;
    self.nameLabel.centerX = self.containerView.width/2;

    self.amountLabel.attributedText = [self amountLabelAttributedText:self.viewModel.amount];
    [self.amountLabel sizeToFit];
    self.amountLabel.top = self.nameLabel.bottom + kPaddingTopAmountLabel;
    self.amountLabel.centerX = self.containerView.width/2;
}

- (NSAttributedString *)amountLabelAttributedText:(NSString *)amount {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:amount attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:60]]}];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" 元" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]]}]];
    
    return [attributedString copy];
}

- (void)refreshBgView
{
    self.topLayerImageView.centerX = self.containerView.width/2;
    self.topLayerImageView.top = 0;
}

- (void)drawRedPacketLayer
{
    self.containerView.center = self.center;
    
    CGFloat originX = self.containerView.origin.x;
    CGFloat originY = self.containerView.origin.y;
    
    CGFloat maskLayerWidth = self.containerView.size.width;
    CGFloat maskLayerHeight = [TTDeviceUIUtils tt_newPadding:270];
    
    __unused CGFloat gradientLayerWidth = self.containerView.size.width;
    CGFloat gradientLayerHeight = [TTDeviceUIUtils tt_newPadding:300];
    
    // 1. 绘制 bottomLayer
    UIBezierPath *bottomLayerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(originX, originY + maskLayerHeight, maskLayerWidth, self.containerView.size.height - maskLayerHeight)
                                                          byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                                cornerRadii:CGSizeMake(kTTRedPacketViewCornerRadius, kTTRedPacketViewCornerRadius)];
    [bottomLayerPath moveToPoint:CGPointMake(originX, originY + maskLayerHeight)];
    [bottomLayerPath addQuadCurveToPoint:CGPointMake(originX + maskLayerWidth, originY + maskLayerHeight) controlPoint:CGPointMake(originX + maskLayerWidth / 2, originY + gradientLayerHeight + 30)]; // 控制点是切线焦点
    
    self.bottomLayer = [CAShapeLayer layer];
    self.bottomLayer.path = bottomLayerPath.CGPath;
    self.bottomLayer.zPosition = -3;
    [self.bottomLayer setFillColor:[UIColor colorWithHexString:@"E13D35"].CGColor];
    
    [self.layer addSublayer:self.bottomLayer];
    
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
    
    self.maskLayer = [CAShapeLayer layer];
    self.maskLayer.path = maskLayerPath.CGPath;
    
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = CGRectMake(0, 0, self.width, originY + gradientLayerHeight);
    [self.gradientLayer setColors:@[
                                    (id) [UIColor colorWithHexString:@"F88981"].CGColor,
                                    (id) [UIColor colorWithHexString:@"F36962"].CGColor,
                                    (id) [UIColor colorWithHexString:@"EF514A"].CGColor
                                    ]];
    [self.gradientLayer setLocations:@[@(0), @(0.1), @(.5)]];
    [self.gradientLayer setStartPoint:CGPointMake(originX / self.gradientLayer.frame.size.width + 0.05, originY / self.gradientLayer.frame.size.height - 0.02)];
    [self.gradientLayer setEndPoint:CGPointMake((originX + maskLayerWidth * .6) / self.gradientLayer.frame.size.width, (originY + maskLayerHeight) / self.gradientLayer.frame.size.height)];
    [self.gradientLayer setMask:self.maskLayer];
    self.gradientLayer.zPosition = -1;
    
    
    [self.layer addSublayer:self.gradientLayer];
    
    // 3. 绘制 shadowLayer
    self.shadowLayer = [CAShapeLayer layer];
    self.shadowLayer.path = maskLayerPath.CGPath;
    self.shadowLayer.zPosition = -2;
    [self.shadowLayer setFillColor:[UIColor colorWithHexString:@"EA2336"].CGColor];
    [self.shadowLayer setShadowColor:[UIColor colorWithHexString:@"B90505"].CGColor];
    [self.shadowLayer setShadowOffset:CGSizeMake(0, 3)];
    [self.shadowLayer setShadowOpacity:.5];
    [self.shadowLayer setShadowRadius:6];
    
    [self.layer addSublayer:self.shadowLayer];
}

//- (void)startLoadingAnimation {
//    self.openRedPacketButton.enabled = NO;
//    self.coinsAnimationImageView.image = [UIImage imageNamed:@"coins_fall_0"];
//    self.coinsAnimationImageView.hidden = NO;
//    [self.coinsAnimationImageView startAnimating];
//}
//
//- (void)stopLoadingAnimation {
//    self.openRedPacketButton.enabled = YES;
//    [self.coinsAnimationImageView stopAnimating];
//    self.coinsAnimationImageView.image = [UIImage imageNamed:@"coins_fall_20"];
//    self.coinsAnimationImageView.hidden = YES;
//}

- (void)coinsAnimationDidFinished {
    [self performSelector:@selector(startTransitionAnimation) withObject:nil afterDelay:1];
}

- (void)startTransitionAnimation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketWillStartTransitionAnimation)]) {
        [self.delegate redPacketWillStartTransitionAnimation];
    }
    
    self.closeButton.hidden = YES;
    self.openRedPacketButton.hidden = YES;
//    self.coinsAnimationImageView.hidden = YES;
    self.shadowLayer.hidden = YES;
    self.topLayerImageView.hidden = YES;
    self.bottomImageView.hidden = YES;
    
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
    [self.bottomLayer addAnimation:bottomLayerPathAnimation forKey:nil];
    
    // 2. 通过对 maskLayer 执行动画来改变 gradientLayer 显示效果
    CGFloat curveLayerHeight = self.width * 142.f/375.f;
    CGFloat gradientLayerTargetY = curveLayerHeight - [TTDeviceUIUtils tt_newPadding:38.f];
    CGFloat maskLayerOriginX = self.gradientLayer.frame.origin.x;
    CGFloat maskLayerOriginY = gradientLayerTargetY - gradientLayerHeight * scale;
    CGFloat maskLayerWidth = self.gradientLayer.frame.size.width;
    __unused CGFloat maskLayerHeight = gradientLayerHeight * scale;
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
    [maskLayerPath addQuadCurveToPoint:CGPointMake(maskLayerWidth, gradientLayerTargetY) controlPoint:CGPointMake(maskLayerWidth / 2, curveLayerHeight + 45.f)];
    [maskLayerPath closePath];
    
    CABasicAnimation *maskLayerPathAnimation = [CABasicAnimation animation];
    maskLayerPathAnimation.keyPath = @"path";
    maskLayerPathAnimation.toValue = (__bridge id) maskLayerPath.CGPath;
    maskLayerPathAnimation.duration = 0.4;
    maskLayerPathAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.32 :0.94 :0.6 :1];
    maskLayerPathAnimation.fillMode = kCAFillModeBoth;
    maskLayerPathAnimation.removedOnCompletion = NO;
    maskLayerPathAnimation.delegate = self;
    [self.maskLayer addAnimation:maskLayerPathAnimation forKey:@"pathAnim"];
    
    CABasicAnimation *gradientLayerColorAnimation = [CABasicAnimation animation];
    gradientLayerColorAnimation.keyPath = @"colors";
    gradientLayerColorAnimation.toValue = @[
                                            (id) [UIColor colorWithHexString:@"EF514A"].CGColor,
                                            (id) [UIColor colorWithHexString:@"EF514A"].CGColor,
                                            (id) [UIColor colorWithHexString:@"EF514A"].CGColor
                                            ];
    
    
    CABasicAnimation *gradientLayerLocationAnimation = [CABasicAnimation animation];
    gradientLayerLocationAnimation.keyPath = @"locations";
    gradientLayerLocationAnimation.toValue = @[@(0),@((curveLayerHeight + 70.f) / CGRectGetHeight(self.gradientLayer.frame)),@(1)];
    
    CAAnimationGroup *gradientLayerAnimationGroup = [CAAnimationGroup animation];
    gradientLayerAnimationGroup.animations = @[gradientLayerLocationAnimation,gradientLayerColorAnimation];
    gradientLayerAnimationGroup.duration = .4;
    gradientLayerAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.32 :0.94 :0.6 :1];
    gradientLayerAnimationGroup.fillMode = kCAFillModeBoth;
    gradientLayerAnimationGroup.removedOnCompletion = NO;
    [self.gradientLayer addAnimation:gradientLayerAnimationGroup forKey:@"gradientAnimation"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketDidStartTransitionAnimation)]) {
        [self.delegate redPacketDidStartTransitionAnimation];
    }
    self.headerView.hidden = YES;
    self.footerView.hidden = YES;
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

//- (UIImageView *)coinsAnimationImageView {
//    if (!_coinsAnimationImageView) {
//        _coinsAnimationImageView = [[SSThemedImageView alloc] initWithFrame:self.openRedPacketButton.frame];
//        _coinsAnimationImageView.layer.cornerRadius = kTTOpenRedPacketButtonSize / 2;
//        _coinsAnimationImageView.clipsToBounds = YES;
//        NSMutableArray *images = [NSMutableArray array];
//        for (NSInteger count = 0; count <= 20; count++) {
//            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"coins_fall_%ld", count]];
//            [images addObject:image];
//        }
//        _coinsAnimationImageView.image = [UIImage imageNamed:@"coins_fall_0"];
//        _coinsAnimationImageView.animationImages = [images copy];
//        _coinsAnimationImageView.animationDuration = 0.4;
//        _coinsAnimationImageView.hidden = YES;
//    }
//
//    return _coinsAnimationImageView;
//}

- (SSThemedButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, kTTCloseButtonSize, kTTCloseButtonSize)];
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -8, -8, 0);
        _closeButton.layer.zPosition = 2;
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        SSThemedImageView *closeImageView = [[SSThemedImageView alloc] init];
        closeImageView.imageName = @"red_env_close";
        closeImageView.enableNightCover = NO;
        closeImageView.frame = CGRectMake(0, 0, closeImageView.image.size.width, closeImageView.image.size.height);
        closeImageView.center = CGPointMake(_closeButton.width / 2, _closeButton.height / 2);
        [_closeButton addSubview:closeImageView];
    }
    
    return _closeButton;
}

- (SSThemedLabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[SSThemedLabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:kFontSizeNameLabel];
        _nameLabel.textColor = [UIColor colorWithHexString:@"0xfff3bc"];
    }
    return _nameLabel;
}

- (SSThemedLabel *)amountLabel
{
    if (_amountLabel == nil) {
        _amountLabel = [[SSThemedLabel alloc] init];
        _amountLabel.textAlignment = NSTextAlignmentCenter;
        _amountLabel.textColor = [UIColor colorWithHexString:@"FFF3BC"];
    }
    return _amountLabel;
}

- (UIImageView *)bottomImageView
{
    if (_bottomImageView == nil) {
        _bottomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_env_bottom"]];
        [_bottomImageView sizeToFit];
    }
    return _bottomImageView;
}

- (UIImageView *)topLayerImageView
{
    if (_topLayerImageView == nil) {
        _topLayerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rp_top_layer.png"]];
        [_topLayerImageView sizeToFit];
    }
    return _topLayerImageView;
}

@end
