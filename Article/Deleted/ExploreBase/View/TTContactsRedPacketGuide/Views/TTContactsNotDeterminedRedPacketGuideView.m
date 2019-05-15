//
//  TTContactsNotDeterminedRedPacketGuideView.m
//  Article
//
//  Created by Jiyee Sheng on 7/31/17.
//
//

#define kTTTitleLabelWidth           [TTDeviceUIUtils tt_newPadding:260.f]
#define kTTTitleLabelHeight          [TTDeviceUIUtils tt_newPadding:24.f]

#import "TTContactsNotDeterminedRedPacketGuideView.h"
#import "TTContactsUserDefaults.h"


@interface TTContactsNotDeterminedRedPacketGuideView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *shadowLayer;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;

@end

@implementation TTContactsNotDeterminedRedPacketGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.containerView addSubview:self.imageView];
        [self.containerView addSubview:self.titleLabel];

        self.titleLabel.text = [[TTContactsUserDefaults dictionaryOfContactsRedPacketContents] stringValueForKey:@"open_contact" defaultValue:@"你的通讯录好友给你发来红包"];
        [self.submitButton setTitle:@"开启通讯录并领取红包" forState:UIControlStateNormal];

        self.imageView.centerX = self.containerView.width / 2;
        self.imageView.top = [TTDeviceUIUtils tt_newPadding:74];

        self.titleLabel.centerX = self.containerView.width / 2;
        self.titleLabel.top = [TTDeviceUIUtils tt_newPadding:223];

        [self drawBackgroundLayer];
    }

    return self;
}

- (void)drawBackgroundLayer {
    CGFloat maskLayerWidth = self.containerView.size.width;
    CGFloat maskLayerHeight = [TTDeviceUIUtils tt_newPadding:100];

    CGFloat gradientLayerWidth = self.containerView.size.width;
    CGFloat gradientLayerHeight = [TTDeviceUIUtils tt_newPadding:130];

    CGFloat radius = 8.f;
    UIBezierPath *strokePath = [UIBezierPath bezierPath];
    [strokePath moveToPoint:CGPointMake(maskLayerWidth, radius)];
    [strokePath addArcWithCenter:CGPointMake(maskLayerWidth - radius, radius)
                          radius:radius
                      startAngle:(CGFloat) (0 * M_PI / 180)
                        endAngle:(CGFloat) (-90 * M_PI / 180)
                       clockwise:NO];
    [strokePath addLineToPoint:CGPointMake(radius, 0)];
    [strokePath addArcWithCenter:CGPointMake(radius, radius)
                          radius:radius
                      startAngle:(CGFloat) (-90 * M_PI / 180)
                        endAngle:(CGFloat) (-180 * M_PI / 180)
                       clockwise:NO];
    [strokePath addLineToPoint:CGPointMake(0, maskLayerHeight)];
    [strokePath addQuadCurveToPoint:CGPointMake(maskLayerWidth, maskLayerHeight) controlPoint:CGPointMake(maskLayerWidth / 2, gradientLayerHeight + 30)]; // 控制点是切线焦点
    [strokePath closePath];

    _maskLayer = [CAShapeLayer layer];
    _maskLayer.path = strokePath.CGPath;

    _gradientLayer = [CAGradientLayer layer];
    [_gradientLayer setColors:@[
        (id) [UIColor colorWithHexString:@"F88981"].CGColor,
        (id) [UIColor colorWithHexString:@"F36962"].CGColor,
        (id) [UIColor colorWithHexString:@"EF514A"].CGColor
    ]];
    [_gradientLayer setLocations:@[@(0), @(0.1), @(0.4)]];
    [_gradientLayer setStartPoint:CGPointMake(0, 0)];
    [_gradientLayer setEndPoint:CGPointMake(1, 1)];
    [_gradientLayer setMask:_maskLayer];
    _gradientLayer.zPosition = -1;
    _gradientLayer.frame = CGRectMake(0, 0, gradientLayerWidth, gradientLayerHeight);

    [self.containerView.layer addSublayer:_gradientLayer];

    _shadowLayer = [CAShapeLayer layer];
    _shadowLayer.path = strokePath.CGPath;
    _shadowLayer.zPosition = -1;
    [_shadowLayer setFillColor:[UIColor clearColor].CGColor];
    [_shadowLayer setShadowColor:[UIColor blackColor].CGColor];
    [_shadowLayer setShadowOffset:CGSizeMake(0, 1)];
    [_shadowLayer setShadowOpacity:0.07];
    [_shadowLayer setShadowRadius:8];

    [self.containerView.layer addSublayer:_shadowLayer];
}

#pragma mark - getter and setter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_red_packet_rmb"]];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }

    return _imageView;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, kTTTitleLabelWidth, kTTTitleLabelHeight)];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"FFF3BC"];
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]];
    }

    return _titleLabel;
}

@end
