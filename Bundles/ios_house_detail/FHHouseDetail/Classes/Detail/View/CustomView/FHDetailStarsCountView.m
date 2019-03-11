//
//  FHDetailStarsCountView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailStarsCountView.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "Masonry.h"
#import <BDWebImage.h>
#import "UILabel+House.h"

@implementation FHDetailStarsCountView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _starsSize = 18;
    _starsName = [UILabel createLabel:@"3.0" textColor:@"" fontSize:36];
    _starsName.textColor = [UIColor themeGray1];
    _starsName.font = [UIFont themeFontMedium:36];
    _starsName.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_starsName];
    
    _starsCountView = [[UIView alloc] init];
    _starsCountView.backgroundColor = [UIColor clearColor];
    [self addSubview:_starsCountView];
    [self.starsName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(70);
    }];
    [self.starsCountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.top.mas_equalTo(self);
        make.left.mas_equalTo(self.starsName.mas_right);
        make.height.mas_equalTo(50);
    }];
}

- (void)updateStarsCount:(NSInteger)scoreValue {
    NSInteger startCount = scoreValue / 10;
    BOOL isShowHalfStart = scoreValue > startCount * 10;
    CGFloat scoreTotal = scoreValue / 10.0;
    self.starsName.text = [NSString stringWithFormat:@"%.1f",scoreTotal];
    UIView *privousView = nil;
    for (UIView *v in self.starsCountView.subviews) {
        [v removeFromSuperview];
    }
    for (int index = 1; index <= 5; index++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_evaluation_default"]];
        [self.starsCountView addSubview:starImageView];
        [starImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (privousView != nil) {
                make.left.mas_equalTo(privousView.mas_right).offset(5);
            } else {
                make.left.mas_equalTo(self.starsCountView).offset(5);
            }
            make.width.height.mas_equalTo(self.starsSize);
            make.centerY.mas_equalTo(self.starsCountView);
        }];
        if (startCount == 0) {
            if (isShowHalfStart) {
                [self createHalfStarView:starImageView ratio:scoreValue % 10];
            }
            return;
        }
        if (index <= startCount) {
            starImageView.image = [UIImage imageNamed:@"star_evaluation"];
        } else if (index == startCount + 1 && isShowHalfStart) {
            [self createHalfStarView:starImageView ratio:scoreValue % 10];
        }
        privousView = starImageView;
    }
}

- (void)createHalfStarView:(UIView *)superView ratio:(NSInteger)ratio {
    for (UIView *v in superView.subviews) {
        [v removeFromSuperview];
    }
    UIImageView *harfImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_evaluation"]];
    harfImageView.contentMode = UIViewContentModeScaleAspectFit;
    [superView addSubview:harfImageView];
    [harfImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(superView);
        make.width.height.mas_equalTo(self.starsSize);
    }];
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, 26)];
    [path addLineToPoint:CGPointMake(self.starsSize * (ratio / 11.0), 26)];
    [path addLineToPoint:CGPointMake(self.starsSize * (ratio / 11.0), 0)];
    [path addLineToPoint:CGPointMake(0,0)];
    shapeLayer.path = path.CGPath;
    harfImageView.layer.mask = shapeLayer;
}

@end
