//
//  FHUGCCellHeaderView.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellHeaderView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>

@interface FHUGCCellHeaderView ()

@end

@implementation FHUGCCellHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:15] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"我加入的小区";
    [self addSubview:_titleLabel];
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_arrow_right"] forState:UIControlStateNormal];
    [_moreBtn setTitle:@"更多" forState:UIControlStateNormal];
    [_moreBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
    _moreBtn.titleLabel.font = [UIFont themeFontRegular:14];
    //文字的size
    CGSize textSize = [_moreBtn.titleLabel.text sizeWithFont:_moreBtn.titleLabel.font];
    CGSize imageSize = _moreBtn.currentImage.size;
    CGFloat marginGay = 4;//图片跟文字之间的间距
    _moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, textSize.width + marginGay - imageSize.width, 0, - textSize.width - marginGay + imageSize.width);
    _moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width - marginGay, 0, imageSize.width + marginGay);
    //设置按钮内容靠右
    _moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self addSubview:_moreBtn];
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.centerY.mas_equalTo(self);
        make.height.mas_equalTo(21);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-19);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
