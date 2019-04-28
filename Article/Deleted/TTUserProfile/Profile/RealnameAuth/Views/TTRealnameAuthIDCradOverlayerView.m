//
//  TTIDCradOverlayerView.m
//  CameraDemo
//
//  Created by muhuai on 2018/1/12.
//  Copyright © 2018年 muhuai. All rights reserved.
//

#import "TTRealnameAuthIDCradOverlayerView.h"

#define TOPBAR_HEIGHT [self topBarHeight]
#define BOTTOMBAR_HEIGHT [self bottomBarHeight]
#define OUTLINE_SCALE [self outlineScale]
@interface TTRealnameAuthIDCradOverlayerView()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *idCardOutline;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation TTRealnameAuthIDCradOverlayerView

- (instancetype)initWithFrame:(CGRect)frame isBack:(BOOL)back {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews:back];
    }
    return self;
}

- (void)setupViews:(BOOL)back {
    self.userInteractionEnabled = NO;
    self.maskView = [[UIView alloc] initWithFrame:self.bounds];
    self.maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    self.idCardOutline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:back? @"id_card_outline_back": @"id_card_outline"]];
    self.idCardOutline.frame = CGRectApplyAffineTransform(self.idCardOutline.frame, CGAffineTransformMakeScale(OUTLINE_SCALE, OUTLINE_SCALE));
    self.idCardOutline.center = CGPointMake(self.frame.size.width / 2, (self.frame.size.height - BOTTOMBAR_HEIGHT - TOPBAR_HEIGHT) / 2 + TOPBAR_HEIGHT);
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.font = [UIFont systemFontOfSize:14.f];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.textLabel.text = back? @"请拍摄身份证国徽面 并尝试对齐边缘": @"请拍摄身份证人像面 并尝试对齐边缘";
    [self.textLabel sizeToFit];
    
    self.textLabel.center = CGPointMake(CGRectGetMaxX(self.idCardOutline.frame) + ((self.frame.size.width - CGRectGetMaxX(self.idCardOutline.frame)) / 2), self.idCardOutline.center.y);
    
    [self addSubview:self.maskView];
    [self addSubview:self.idCardOutline];
    [self addSubview:self.textLabel];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    CGRect outlineRect = CGRectInset(self.idCardOutline.frame, 1, 1);
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:outlineRect cornerRadius:16] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = maskPath.CGPath;
    self.maskView.layer.mask = shapeLayer;
}

- (CGFloat)topBarHeight {
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height == 667 || height == 736) {
        return 44.f;
    }
    
    if (height == 568 || height == 480) {
        return 40.f;
    }
    
    return 44.f;
}

- (CGFloat)bottomBarHeight {
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height == 667) {
        return 123.f;
    }
    
    if (height == 568) {
        return 101.5f;
    }
    
    if (height == 480) {
        return 74.5f;
    }
    if (height == 736) {
        return 140.f;
    }
    return 123.f;
}

- (CGFloat)outlineScale {
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height == 667) {
        return 1.f;
    }
    
    if (height == 568) {
        return 0.9f;
    }
    
    if (height == 480) {
        return 0.8f;
    }
    
    return 1.f;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
