//
//  FHDetailTopBannerView.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/13.
//

#import "FHDetailTopBannerView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UILabel+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "FHUIAdaptation.h"
#import <ByteDanceKit/UIDevice+BTDAdditions.h>
#import <TTRoute.h>

@interface FHDetailTopBannerView ()
@property (nonatomic, strong) UIImageView *shadowImage;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIImageView *leftIcon;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, copy) NSString *clickUrl;

@end

@implementation FHDetailTopBannerView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
//    [self addSubview:self.shadowImage];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.leftView];
    [self.containerView addSubview:self.rightView];
    [self.leftView addSubview:self.leftIcon];
    [self.leftView addSubview:self.leftLabel];
    [self.rightView addSubview:self.rightLabel];
    
    self.leftView.userInteractionEnabled = NO;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToJump)];
    [self.leftView addGestureRecognizer:singleTap];

//    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.mas_equalTo(self);
//        make.bottom.mas_equalTo(self);
//        make.height.mas_equalTo(self);
//    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(self).mas_offset(15);
        make.right.mas_equalTo(self).mas_offset(-15);
//        make.height.mas_equalTo(40);
    }];
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(0);
        if ([UIDevice btd_deviceWidthType] == BTDDeviceWidthMode320) {
            make.width.mas_equalTo(98);
        } else {
            make.width.mas_equalTo(114);
        }
    }];
    [self.leftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.leftView);
        if ([UIDevice btd_deviceWidthType] == BTDDeviceWidthMode320) {
            make.left.mas_equalTo(10);
            make.width.height.mas_equalTo(18);
        } else {
            make.left.mas_equalTo(11);
            make.width.height.mas_equalTo(24);
        }
    }];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIcon.mas_right).mas_equalTo(5);
        make.centerY.mas_equalTo(self.leftView);
    }];
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(self.leftView.mas_right);
    }];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([UIDevice btd_deviceWidthType] == BTDDeviceWidthMode320) {
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
        } else {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
        }
        make.centerY.mas_equalTo(self.rightView);
    }];
}

- (void)updateWithTitle:(NSString *)title content:(NSString *)content isCanClick:(BOOL)isCanClick clickUrl:(nonnull NSString *)clickUrl
{
//    switch (self.housetype) {
//        case FHHouseTypeSecondHandHouse:
//            [self.leftIcon mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(11);
//                make.width.height.mas_equalTo(24);
//            }];
//            break;
//        default:
//            [self.leftIcon mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(12);
//                make.width.height.mas_equalTo(18);
//            }];
//            break;
//    }
    self.leftLabel.text = title;
    self.rightLabel.text = content;
    
    self.leftView.userInteractionEnabled = isCanClick;
    self.clickUrl = clickUrl;
    
    if (!_maskLayer) {
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30, 40);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//        maskLayer.frame = self.containerView.bounds;
        maskLayer.frame = rect;
        maskLayer.path = maskPath.CGPath;
        self.containerView.layer.mask = maskLayer;
        _maskLayer = maskLayer;
    }
    
    if (!_gradientLayer) {
        
        UIColor *leftColor = [UIColor colorWithHexString:@"#ff8e00"];
        UIColor *rightColor = [UIColor themeOrange1];
        NSArray *gradientColors = [NSArray arrayWithObjects:(id)(leftColor.CGColor), (id)(rightColor.CGColor), nil];
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.colors = gradientColors;
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        
        gradientLayer.frame = CGRectMake(0, 0, 114, 40);
//        gradientlayer.cornerRadius = 4.0;
        [self.leftView.layer insertSublayer:gradientLayer atIndex:0];
        _gradientLayer = gradientLayer;
    }
    
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        _shadowImage = [[UIImageView alloc]init];
        _shadowImage.image = [[UIImage imageNamed:@"left_top_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(30,25,0,25) resizingMode:UIImageResizingModeStretch];
    }
    return  _shadowImage;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
//        _containerView.layer.cornerRadius = 10;
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}

- (UIView *)leftView
{
    if (!_leftView) {
        _leftView = [[UIView alloc]init];
        _leftView.backgroundColor = [UIColor colorWithHexString:@"#fe6200"];
    }
    return _leftView;
}

- (UIImageView *)leftIcon
{
    if (!_leftIcon) {
        _leftIcon = [[UIImageView alloc]init];
        _leftIcon.image = [UIImage imageNamed:@"detail_header_top_icon"];
    }
    return _leftIcon;
}

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc]init];
        _leftLabel.textColor = [UIColor whiteColor];
        _leftLabel.font = [UIDevice btd_deviceWidthType] == BTDDeviceWidthMode320 ? [UIFont themeFontSemibold:14] : [UIFont themeFontSemibold:16];
        _leftLabel.numberOfLines = 1;
    }
    return _leftLabel;
}

- (UIView *)rightView
{
    if (!_rightView) {
        _rightView = [[UIView alloc]init];
        _rightView.backgroundColor = [UIColor colorWithHexString:@"#fbe5d5"];
    }
    return _rightView;
}

- (UILabel *)rightLabel
{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc]init];
        _rightLabel.textColor = [UIColor colorWithHexString:@"#b53d00"];
        _rightLabel.font = [UIDevice btd_deviceWidthType] == BTDDeviceWidthMode320 ? [UIFont themeFontRegular:12] : [UIFont themeFontRegular:14];
//        _rightLabel.minimumScaleFactor = 0.5;
//        _rightLabel.adjustsFontSizeToFitWidth = YES;
        _rightLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _rightLabel.numberOfLines = 1;
    }
    return _rightLabel;
}

- (void)goToJump {
    if(self.clickUrl.length > 0){
        NSURL *openUrl = [NSURL URLWithString:self.clickUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

@end
