//
//  FHUGCFeedGuideView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/20.
//

#import "FHUGCFeedGuideView.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <Masonry.h>

@interface FHUGCFeedGuideView ()

@property(nonatomic ,strong) UIImageView *arror;
@property(nonatomic ,strong) UIView *contentView;
@property(nonatomic ,strong) UILabel *contentLabel;

@end

@implementation FHUGCFeedGuideView

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
    
    self.arror = [[UIImageView alloc] init];
    _arror.image = [UIImage imageNamed:@"fh_ugc_feed_guide_arror_up"];
    [self addSubview:_arror];
    
    self.contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor themeGray7];
    [self addSubview:_contentView];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray2]];
    _contentLabel.numberOfLines = 2;
    [_contentLabel sizeToFit];
    _contentLabel.text = @"点击✌️进入小区圈，查看更多新鲜事";
    [_contentLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.contentView addSubview:_contentLabel];
    
    self.closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[UIImage imageNamed:@"fh_ugc_feed_guide_close"] forState:UIControlStateNormal];
//    [_closeBtn addTarget:self action:@selector(deleteCell) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_closeBtn];
}

- (void)initConstraints {
    [self.arror mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(40);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(6);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.arror.mas_bottom);
        make.left.right.bottom.mas_equalTo(self);
    }];

    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentLabel);
        make.right.mas_equalTo(self.contentView).offset(-6);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(9);
        make.bottom.mas_equalTo(self.contentView).offset(-9);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.closeBtn.mas_left).offset(-20);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)deleteCell {

}

@end
