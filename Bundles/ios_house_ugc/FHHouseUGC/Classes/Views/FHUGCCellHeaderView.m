//
//  FHUGCCellHeaderView.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellHeaderView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "TTDeviceHelper.h"
#import <FHHouseBase/UIImage+FIconFont.h>

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
    _titleLabel.backgroundColor = [UIColor whiteColor];
    _titleLabel.layer.masksToBounds = YES;
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
    
    self.refreshBtn = [[UIButton alloc] init];
    _refreshBtn.hidden = YES;
    _refreshBtn.layer.masksToBounds = YES;
    _refreshBtn.layer.cornerRadius = 4;
    _refreshBtn.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];
    [_refreshBtn setImage:[UIImage imageNamed:@"fh_ugc_refresh"] forState:UIControlStateNormal];
    [_refreshBtn setTitle:@"换一批" forState:UIControlStateNormal];
    [_refreshBtn setTitleColor:[UIColor themeRed3] forState:UIControlStateNormal];
    _refreshBtn.titleLabel.font = [UIFont themeFontRegular:12];
    _refreshBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -marginGay/2, 0, marginGay/2);
    _refreshBtn.titleEdgeInsets = UIEdgeInsetsMake(0, marginGay/2, 0, -marginGay/2);
    [self addSubview:_refreshBtn];
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.hidden = YES;
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:_bottomLine];
    
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
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(20);
    }];
    
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.moreBtn.mas_left).offset(-8);
        make.width.mas_equalTo(60);
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

@end
