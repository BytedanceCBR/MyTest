//
//  FHSpecialTopicSectionHeaderView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/24.
//

#import "FHSpecialTopicSectionHeaderView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "TTDeviceHelper.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHSpecialTopicSectionHeaderView ()

@end

@implementation FHSpecialTopicSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    _titleLabel.backgroundColor = [UIColor whiteColor];
    _titleLabel.layer.masksToBounds = YES;
    [self addSubview:_titleLabel];

    self.postBtn = [self sendPostBtn];
    [self addSubview:_postBtn];
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.hidden = YES;
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:_bottomLine];
}

- (UIButton *)sendPostBtn {
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor whiteColor];
    button.imageView.contentMode = UIViewContentModeCenter;
    [button setTitle:@"发表观点" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"detail_questiom_ask"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont themeFontRegular:14];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    [button addTarget:self action:@selector(gotoPublish) forControlEvents:UIControlEventTouchUpInside];
    button.hidden = YES;
    return button;
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(15);
        make.top.mas_equalTo(self).offset(15);
        make.height.mas_equalTo(22);
    }];
    
    [self.postBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self).offset(-15);
        make.height.mas_equalTo(20);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)gotoPublish {
    if(self.gotoPublishBlock){
        self.gotoPublishBlock();
    }
}

@end
