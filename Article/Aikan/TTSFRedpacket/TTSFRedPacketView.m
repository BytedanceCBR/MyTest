//
//  TTSFRedPacketView.m
//  he_uidemo
//
//  Created by chenjiesheng on 2017/11/29.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import "TTSFRedPacketView.h"
#import <SSThemed.h>
#import <TTDeviceUIUtils.h>
#import <UIViewAdditions.h>
#import <NSDictionary+TTAdditions.h>
#import <BDWebImage/SDWebImageAdapter.h>
#import <TTLabelTextHelper.h>
#import "LOTAnimationView+TTSpringFestival.h"
#import "UIImage+TTSFResource.h"

#define kPaddingTopLogoImageView            [TTDeviceUIUtils tt_newPadding:40.f]
#define kPaddingTopNameLabel                [TTDeviceUIUtils tt_newPadding:10.f]
#define kPaddingTopNameSubLabel             [TTDeviceUIUtils tt_newPadding:4.f]

#define kSizeLogoImageView                  [TTDeviceUIUtils tt_newPadding:66.f]

#define kFontSizeNameLabel                  [TTDeviceUIUtils tt_newFontSize:17.f]
#define kFontSizeNameSubLabel               [TTDeviceUIUtils tt_newFontSize:14.f]
#define kFontSizeTitleLabel                 [TTDeviceUIUtils tt_newFontSize:17.f]

#define kTTRedPacketViewWidth              [TTDeviceUIUtils tt_newPadding:300.f]
#define kTTRedPacketViewHeight             [TTDeviceUIUtils tt_newPadding:410.f]
#define kTTRedPacketViewCornerRadius       [TTDeviceUIUtils tt_newPadding:8.f]
#define kTTHeaderViewHeight                [TTDeviceUIUtils tt_newPadding:300.f]
#define kTTFooterViewHeight                [TTDeviceUIUtils tt_newPadding:110.f]
#define kTTCloseButtonSize                 [TTDeviceUIUtils tt_newPadding:36.f]
#define kTTOpenRedPacketButtonSize         [TTDeviceUIUtils tt_newPadding:100.f]
#define kTTOpenRedPacketButtonMargin       [TTDeviceUIUtils tt_newPadding:246.f]

@implementation TTSFRedPacketParam

+ (TTSFRedPacketParam *)paramWithDict:(NSDictionary *)dict {
    if (!dict) {
        return nil;
    }
    
    TTSFRedPacketParam *param = [TTSFRedPacketParam new];
    param.redpacketId = [dict tt_stringValueForKey:@"redpack_id"];
    param.redpacketToken = [dict tt_stringValueForKey:@"redpack_token"];
    param.redpacketTitle = [dict tt_stringValueForKey:@"redpack_title"];
    param.redpacketLogoUrl = [dict tt_stringValueForKey:@"logo"];
    param.redpacketName = [dict tt_stringValueForKey:@"name"];
    param.showFollowSelectedButton = [dict tt_boolValueForKey:@"show_follow_button"];
    param.mpName = [dict tt_stringValueForKey:@"sponsor_mp_name"];
    return param;
}

@end

@interface TTSFRedPacketView ()

@property (nonatomic, strong)SSThemedLabel              *nameLabel;
@property (nonatomic, strong)SSThemedLabel              *nameSubLabel;
@property (nonatomic, strong)SSThemedLabel              *redpacketLabel;
@property (nonatomic, strong)SSThemedImageView          *logoImageView;
@property (nonatomic, strong)SSThemedLabel              *titleLabel;
@property (nonatomic, strong)UIImageView                *bottomDecorateImageView;
@property (nonatomic, strong)UIImageView                *leftCloudImageView;
@property (nonatomic, strong)UIImageView                *rightCloudImageView;
@property (nonatomic, strong)UIImageView                *topLayerImageView;
@property (nonatomic, strong)TTSFRedPacketParam         *param;
@property (nonatomic, strong, readwrite)UIButton                   *followSelectedButton;
@property (nonatomic, strong)SSThemedLabel              *bottomTipLabel;

@property (nonatomic, strong)LOTAnimationView       *backAnimationView;
@property (nonatomic, strong)LOTAnimationView       *foreAnimationView;
@property (nonatomic, strong)LOTAnimationView       *colorsAnimationView;
@property (nonatomic, strong)UIImageView            *colorsImageView;

@end

@implementation TTSFRedPacketView

- (instancetype)initWithFrame:(CGRect)frame param:(TTSFRedPacketParam *)param
{
    self = [super initWithFrame:frame];
    if (self) {
        self.param = param;
        [self.headerView addSubview:self.nameLabel];
        [self.headerView addSubview:self.nameSubLabel];
        [self.headerView addSubview:self.redpacketLabel];
        [self.headerView addSubview:self.logoImageView];
        [self.headerView addSubview:self.titleLabel];
        [self addSubview:self.bottomDecorateImageView];
        [self addSubview:self.leftCloudImageView];
        [self addSubview:self.rightCloudImageView];
        [self bringSubviewToFront:self.containerView];
//        [self.containerView addSubview:self.topLayerImageView];
//        [self.containerView sendSubviewToBack:self.topLayerImageView];
        
        [self insertSubview:self.backAnimationView belowSubview:self.containerView];
        [self insertSubview:self.colorsImageView belowSubview:self.containerView];
        [self addSubview:self.foreAnimationView];
        [self addSubview:self.colorsAnimationView];
        [self addSubview:self.followSelectedButton];
        [self addSubview:self.bottomTipLabel];
    }
    return self;
}

- (void)refreshWithExeptionTitle:(NSString *)title
{
    self.nameSubLabel.hidden = YES;
    self.redpacketLabel.hidden = YES;
    self.openRedPacketButton.hidden = YES;
    
    self.param.redpacketTitle = title;
    [self refreshTitleLabel];
}

- (void)layoutSubviews
{
    [self.openRedPacketButton setImage:[UIImage ttsf_imageNamed:@"open_redpacket.png"] forState:UIControlStateNormal];
    [super layoutSubviews];
    [self refreshNameAndLogoRegion];
    [self refreshTitleLabel];
    [self refreshBgView];
//    [self refreshFollowButton];
}

- (void)refreshNameAndLogoRegion
{
    if (!isEmptyString(self.param.redpacketLogoUrl)) {
        [self.logoImageView sda_setImageWithURL:[NSURL URLWithString:self.param.redpacketLogoUrl]];
    } else {
        UIImage *image = [UIImage ttsf_imageNamed:@"rp_toutiao_icon"];
        self.logoImageView.image = image;
    }
    self.logoImageView.size = CGSizeMake(kSizeLogoImageView, kSizeLogoImageView);
    self.logoImageView.centerX = self.containerView.width/2;
    self.logoImageView.top = [TTDeviceUIUtils tt_newPadding:30.f];
    self.logoImageView.layer.cornerRadius = kSizeLogoImageView / 2;
    self.logoImageView.clipsToBounds = YES;
    
    self.nameLabel.text = !isEmptyString(self.param.redpacketName) ? self.param.redpacketName : @"今日头条";
    [self.nameLabel sizeToFit];
    self.nameLabel.height = [TTDeviceUIUtils tt_newPadding:24.f];
    self.nameLabel.top = self.logoImageView.bottom + kPaddingTopNameLabel;
    self.nameLabel.centerX = self.logoImageView.centerX;
    
    switch ((enum TTSFRedPacketViewType)self.param.type.integerValue) {
        case TTSFRedPacketViewTypeMahjongWinner:
            self.nameSubLabel.text = @"恭喜你获得一个";
            self.redpacketLabel.text = @"發财红包";
            break;
        case TTSFRedPacketViewTypeRain:
            self.nameSubLabel.text = @"恭喜你抢得一个";
            self.redpacketLabel.text = @"财神红包";
            break;
        case TTSFRedPacketViewTypePostTinyVideo:
            self.nameSubLabel.text = @"恭喜你获得一个";
            self.redpacketLabel.text = @"小视频拜年红包";
            break;
        case TTSFRedPacketViewTypeTinyVideo:
            self.nameSubLabel.text = @"送给你一个";
            self.redpacketLabel.text = @"小视频拜年红包";
            break;
        case TTSFRedPacketViewTypeInviteNewUser:
            self.nameSubLabel.text = @"恭喜你获得一个";
            self.redpacketLabel.text = @"邀请好友红包";
            break;
        case TTSFRedPacketViewTypeNewbee:
            self.nameSubLabel.text = @"恭喜你获得一个";
            self.redpacketLabel.text = @"新人红包";
            self.bottomTipLabel.text = @"登录成功后可领取红包";
            self.bottomTipLabel.hidden = NO;
            break;
        case TTSFRedPacketViewTypeSunshine:
            self.nameSubLabel.text = @"送给你一个";
            self.redpacketLabel.text = @"见面礼红包";
            break;
        default:
            break;
    }
    [self.nameSubLabel sizeToFit];
    self.nameSubLabel.height = [TTDeviceUIUtils tt_newPadding:20.f];
    self.nameSubLabel.top = self.nameLabel.bottom + kPaddingTopNameSubLabel;
    self.nameSubLabel.centerX = self.nameLabel.centerX;
    [self.redpacketLabel sizeToFit];
    self.redpacketLabel.top = self.nameSubLabel.bottom + [TTDeviceUIUtils tt_newPadding:18.f];
    self.redpacketLabel.centerX = self.nameSubLabel.centerX;
}

- (void)refreshTitleLabel
{
    self.titleLabel.text = self.param.redpacketTitle;
    
    CGFloat maxWidth = 233.f;
    CGFloat lineHeight = [TTDeviceUIUtils tt_newFontSize:24.f];
    CGFloat height = [TTLabelTextHelper heightOfText:self.titleLabel.text fontSize:self.titleLabel.font.pointSize forWidth:maxWidth forLineHeight:lineHeight];
    self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:self.titleLabel.text fontSize:self.titleLabel.font.pointSize lineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping isBoldFontStyle:NO firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
    
    self.titleLabel.height = height;
    self.titleLabel.width = maxWidth;
    
    self.titleLabel.centerX = self.nameLabel.centerX;
    CGFloat titleTopPadding = isEmptyString(self.nameLabel.text) ? [TTDeviceUIUtils tt_newPadding:30.f] : [TTDeviceUIUtils tt_newPadding:52.f];
    self.titleLabel.top = self.nameLabel.bottom + titleTopPadding;
}

- (void)refreshBgView
{
    self.topLayerImageView.centerX = self.containerView.width/2;
    self.topLayerImageView.top = 0;
    
    self.bottomDecorateImageView.size = CGSizeMake(self.containerView.width, self.containerView.width * self.bottomDecorateImageView.height / self.bottomDecorateImageView.width);
    self.bottomDecorateImageView.centerX = self.width / 2;
    self.bottomDecorateImageView.bottom = self.containerView.bottom;
    
    self.leftCloudImageView.right = self.width / 2 - [TTDeviceUIUtils tt_newPadding:50.f];
    self.leftCloudImageView.bottom = self.containerView.bottom - [TTDeviceUIUtils tt_newPadding:33.f];
    
    self.rightCloudImageView.left = self.width / 2 + [TTDeviceUIUtils tt_newPadding:66.f];
    self.rightCloudImageView.bottom = self.containerView.bottom - [TTDeviceUIUtils tt_newPadding:78.f];
    switch ((enum TTSFRedPacketViewType)self.param.type.integerValue) {
        case TTSFRedPacketViewTypeMahjongWinner:
        case TTSFRedPacketViewTypeRain:
        case TTSFRedPacketViewTypePostTinyVideo:
        case TTSFRedPacketViewTypeTinyVideo:
            self.colorsImageView.hidden = NO;
            self.colorsImageView.centerX = self.containerView.centerX;
            self.colorsImageView.top = self.containerView.top - [TTDeviceUIUtils tt_newPadding:54.f];
            break;
        default:
            self.colorsImageView.hidden = YES;
            break;
    }
}

- (void)refreshFollowButton
{
    _followSelectedButton.hidden = !self.param.showFollowSelectedButton;
    NSString *buttonTitle = [NSString stringWithFormat:@"同时关注%@",self.param.mpName];
    [self.followSelectedButton setTitle:buttonTitle forState:UIControlStateNormal];
    [self.followSelectedButton sizeToFit];
    self.followSelectedButton.centerX = self.width / 2 + 4.f;//由于间距，向右偏移4.f
    self.followSelectedButton.bottom = self.containerView.bottom - [TTDeviceUIUtils tt_newPadding:15.f];
    
    //更新底部提示label
    [self.bottomTipLabel sizeToFit];
    self.bottomTipLabel.bottom = self.containerView.bottom - [TTDeviceUIUtils tt_newPadding:15.f];
    self.bottomTipLabel.centerX = self.width / 2;
}

- (void)startTransitionAnimation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketWillStartTransitionAnimation)]) {
        [self.delegate redPacketWillStartTransitionAnimation];
    }
    
    self.closeButton.hidden = YES;
    self.openRedPacketButton.hidden = YES;
    self.coinsAnimationImageView.hidden = YES;
    self.shadowLayer.hidden = YES;
    self.bottomDecorateImageView.hidden = YES;
    self.leftCloudImageView.hidden = YES;
    self.rightCloudImageView.hidden = YES;
    self.followSelectedButton.hidden = YES;
    self.topLayerImageView.hidden = YES;
    self.bottomTipLabel.hidden = YES;
    
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

- (void)drawRedPacketLayer
{
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

#pragma private

- (UIImage *)logoImageWithURL:(NSString *)url
{
    return [UIImage ttsf_imageNamed:@"sf_red_packet_logo"];
}

#pragma Getter

- (SSThemedLabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[SSThemedLabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:kFontSizeNameLabel];
        _nameLabel.textColor = [UIColor colorWithHexString:@"0xfff3bc"];
    }
    return _nameLabel;
}

- (SSThemedLabel *)nameSubLabel
{
    if (_nameSubLabel == nil) {
        _nameSubLabel = [[SSThemedLabel alloc] init];
        _nameSubLabel.font = [UIFont systemFontOfSize:kFontSizeNameSubLabel];
        _nameSubLabel.textColor = [UIColor colorWithHexString:@"0xfff3bc"];
    }
    return _nameSubLabel;
}

- (SSThemedImageView *)logoImageView
{
    if (_logoImageView == nil) {
        _logoImageView = [[SSThemedImageView alloc] init];
        _logoImageView.enableNightCover = NO;
    }
    return _logoImageView;
}

- (SSThemedLabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:kFontSizeTitleLabel];
        _titleLabel.textColor = [UIColor colorWithHexString:@"0xfff3bc"];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (SSThemedLabel *)redpacketLabel
{
    if (_redpacketLabel == nil) {
        _redpacketLabel = [[SSThemedLabel alloc] init];
        _redpacketLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:28.f]];
        _redpacketLabel.textColor = [UIColor colorWithHexString:@"FFF3BC"];
    }
    return _redpacketLabel;
}

- (UIImageView *)bottomDecorateImageView
{
    if (_bottomDecorateImageView == nil) {
        _bottomDecorateImageView = [[UIImageView alloc] initWithImage:[UIImage ttsf_imageNamed:@"redpacket_bottom_cloud"]];
        [_bottomDecorateImageView sizeToFit];
        _bottomDecorateImageView.userInteractionEnabled = NO;
    }
    return _bottomDecorateImageView;
}

- (UIImageView *)leftCloudImageView
{
    if (_leftCloudImageView == nil) {
        _leftCloudImageView = [[UIImageView alloc] init];
        _leftCloudImageView.image = [UIImage ttsf_imageNamed:@"redpacket_bottom_left_cloud"];
        [_leftCloudImageView sizeToFit];
        _leftCloudImageView.userInteractionEnabled = NO;
    }
    return _leftCloudImageView;
}

- (UIImageView *)rightCloudImageView
{
    if (_rightCloudImageView == nil) {
        _rightCloudImageView = [[UIImageView alloc] init];
        _rightCloudImageView.image = [UIImage ttsf_imageNamed:@"redpacket_bottom_right_cloud"];
        [_rightCloudImageView sizeToFit];
        _rightCloudImageView.userInteractionEnabled = NO;
    }
    return _rightCloudImageView;
}

- (UIButton *)followSelectedButton
{
    if (_followSelectedButton == nil) {
        _followSelectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followSelectedButton.adjustsImageWhenHighlighted = NO;
        [_followSelectedButton setImage:[UIImage ttsf_imageNamed:@"redpacket_bottom_follow_selected"] forState:UIControlStateSelected];
        [_followSelectedButton setImage:[UIImage ttsf_imageNamed:@"redpacket_bottom_follow_unselected"] forState:UIControlStateNormal];
        _followSelectedButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
        [_followSelectedButton setTitleColor:[UIColor colorWithHexString:@"fff3bc"] forState:UIControlStateNormal];
        _followSelectedButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        [_followSelectedButton setSelected:YES];
        WeakSelf;
        [_followSelectedButton addTarget:self withActionBlock:^{
            StrongSelf;
            self.followSelectedButton.selected = !self.followSelectedButton.selected;
        } forControlEvent:UIControlEventTouchUpInside];
    }
    return _followSelectedButton;
}

- (SSThemedLabel *)bottomTipLabel
{
    if (_bottomTipLabel == nil) {
        _bottomTipLabel = [[SSThemedLabel alloc] init];
        _bottomTipLabel.textColor = [UIColor colorWithHexString:@"fff3bc"];
        _bottomTipLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:12.f]];
        _bottomTipLabel.hidden = YES;
    }
    return _bottomTipLabel;
}

- (UIImageView *)topLayerImageView
{
    if (_topLayerImageView == nil) {
        _topLayerImageView = [[UIImageView alloc] initWithImage:[UIImage ttsf_imageNamed:@"rp_top_layer.png"]];
        [_topLayerImageView sizeToFit];
    }
    return _topLayerImageView;
}

- (LOTAnimationView *)colorsAnimationView
{
    if (_colorsAnimationView == nil) {
        _colorsAnimationView = [LOTAnimationView animationFromJSONName:@"lottie_pre_heat_colors"];
        _colorsAnimationView.contentMode = UIViewContentModeScaleAspectFit;
        _colorsAnimationView.userInteractionEnabled = NO;
    }
    return _colorsAnimationView;
}

- (LOTAnimationView *)backAnimationView
{
    if (_backAnimationView == nil) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"lottie_pre_heat_after" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]];
        _backAnimationView = [LOTAnimationView animationFromJSON:dict];
        _backAnimationView.contentMode = UIViewContentModeScaleAspectFill;
        [_backAnimationView sizeToFit];
        _backAnimationView.userInteractionEnabled = NO;
    }
    return _backAnimationView;
}

- (LOTAnimationView *)foreAnimationView
{
    if (_foreAnimationView == nil) {
        _foreAnimationView = [LOTAnimationView animationFromJSONName:@"lottie_pre_heat_pre"];
        _foreAnimationView.contentMode = UIViewContentModeScaleAspectFill;
        [_foreAnimationView sizeToFit];
        _foreAnimationView.userInteractionEnabled = NO;
    }
    return _foreAnimationView;
}

- (UIImageView *)colorsImageView
{
    if (_colorsImageView == nil) {
        _colorsImageView = [[UIImageView alloc] init];
        _colorsImageView.image = [UIImage ttsf_imageNamed:@"pre_heat_background_colors_image"];
        _colorsImageView.hidden = YES;
        [_colorsImageView sizeToFit];
        _colorsImageView.size = CGSizeMake([TTUIResponderHelper mainWindow].width, [TTUIResponderHelper mainWindow].width * _colorsImageView.height / _colorsImageView.width);
    }
    return _colorsImageView;
}

- (void)playLottieView
{
    self.backAnimationView.center = self.center;
    self.foreAnimationView.center = self.center;
    self.colorsAnimationView.frame = self.bounds;

    [self.backAnimationView playWithCompletion:^(BOOL animationFinished) {
        [self.backAnimationView removeFromSuperview];
    }];
    [self.foreAnimationView playWithCompletion:^(BOOL animationFinished) {
        [self.foreAnimationView removeFromSuperview];
    }];
    [self.colorsAnimationView playWithCompletion:^(BOOL animationFinished) {
        [self.colorsAnimationView removeFromSuperview];
    }];
}

@end
