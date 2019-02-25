//
//  FHHouseHeaderView.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHHouseHeaderView.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"

@implementation FHHouseHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [UIColor themeGrayPale];
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.dateView = [[UIView alloc] init];
    _dateView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    _dateView.layer.cornerRadius = 4;
    _dateView.layer.masksToBounds = YES;
    [self addSubview:_dateView];
    
    self.dateLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor whiteColor]];
    [_dateView addSubview:_dateLabel];
    
    self.contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeBlack]];
    _contentLabel.numberOfLines = 2;
    _contentLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    [_contentView addSubview:_contentLabel];
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [_contentView addSubview:_bottomLine];
}

- (void)initConstraints {
    [self.dateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(self);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dateView.mas_left).offset(10);
        make.right.mas_equalTo(self.dateView.mas_right).offset(-10);
        make.center.mas_equalTo(self.dateView);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(self.dateView.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.top.mas_equalTo(self.contentView).offset(10);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)setContentViewMargin:(UIEdgeInsets)edgeInsets {
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(edgeInsets.left);
        make.right.mas_equalTo(self).offset(edgeInsets.right);
        make.top.mas_equalTo(self.dateView.mas_bottom).offset(edgeInsets.top + 14);
        make.bottom.mas_equalTo(self).offset(edgeInsets.bottom);
    }];
    
    [self layoutIfNeeded];
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    shape.frame = self.contentView.bounds;
    shape.path = rounded.CGPath;
    self.contentView.layer.mask = shape;
}


@end
