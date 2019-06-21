//
//  FHUGCCellBottomView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellBottomView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"

@interface FHUGCCellBottomView ()

@property(nonatomic ,strong) UIView *positionView;

@end

@implementation FHUGCCellBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    
    self.positionView = [[UIView alloc] init];
    _positionView.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];
    _positionView.layer.masksToBounds= YES;
    _positionView.layer.cornerRadius = 4;
    [self addSubview:_positionView];
    
    self.position = [self LabelWithFont:[UIFont themeFontRegular:13] textColor:[UIColor themeRed3]];
    [_position sizeToFit];
    [_positionView addSubview:_position];
    
    self.likeBtn = [[UIButton alloc] init];
    [_likeBtn setImage:[UIImage imageNamed:@"fh_ugc_like"] forState:UIControlStateNormal];
    [_likeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    _likeBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_likeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    
    [self addSubview:_likeBtn];
    
    self.commentBtn = [[UIButton alloc] init];
    [_commentBtn setImage:[UIImage imageNamed:@"fh_ugc_comment"] forState:UIControlStateNormal];
    [_commentBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    _commentBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    [self addSubview:_commentBtn];
}

- (void)initConstraints {
    [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.position mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionView).offset(6);
        make.right.mas_equalTo(self.positionView).offset(-6);
        make.centerY.mas_equalTo(self.positionView);
        make.height.mas_equalTo(18);
    }];

    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-20);
    }];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.right.mas_equalTo(self.likeBtn.mas_left).offset(-20);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
