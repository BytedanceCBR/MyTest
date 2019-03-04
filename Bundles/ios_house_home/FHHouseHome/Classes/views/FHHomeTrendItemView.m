//
//  FHHomeTrendItemView.m
//  Article
//
//  Created by 张静 on 2018/11/23.
//

#import "FHHomeTrendItemView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"

@implementation FHHomeTrendItemView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    
    if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {

        self.leftPadding = 0;
        self.rightPadding = 0;
    }else {
        self.leftPadding = 0;
        self.rightPadding = 5;
    }

    [self addSubview:self.titleLabel];
    
    [self addSubview:self.btn];
    [self addSubview:self.subtitleLabel];
    [self addSubview:self.icon];

    [self.btn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.btn.hidden = YES;
}

-(void)btnDidClick:(UIButton *)btn {

    if (self.clickedCallback) {
        self.clickedCallback(btn);
    }
}
-(void)layoutSubviews {
    
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
    self.titleLabel.top = 10;
    self.titleLabel.width = self.width - self.leftPadding - self.rightPadding;
    self.titleLabel.left = self.leftPadding;
    
    CGFloat leftPadding = 0;
    if (!self.btn.hidden) {
        
        leftPadding = 4;
    }
    [self.subtitleLabel sizeToFit];
    self.subtitleLabel.top = self.titleLabel.bottom + 3;
    self.subtitleLabel.left = self.titleLabel.left + leftPadding;
    if (self.subtitleLabel.width > self.width - self.leftPadding - self.rightPadding) {
        
        self.subtitleLabel.width = self.width - self.leftPadding - self.rightPadding;
    }
    [self.subtitleLabel sizeToFit];

    [self.icon sizeToFit];
    self.icon.left = self.subtitleLabel.right + 3;
    self.icon.centerY = self.subtitleLabel.centerY;

    self.btn.left = self.subtitleLabel.left - leftPadding;
    if (self.icon.width > 0) {
        
        self.btn.width = self.icon.right - self.subtitleLabel.left + 2 * leftPadding;
    } else {
        self.btn.width = self.subtitleLabel.right - self.subtitleLabel.left + 2 * leftPadding;
    }
    self.btn.top = self.subtitleLabel.top - 1;
    self.btn.height = self.subtitleLabel.bottom - self.subtitleLabel.top + 2;
    
}

-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontRegular:18];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.numberOfLines = 1;
        
    }
    
    return _titleLabel;
}

-(UILabel *)subtitleLabel {
    
    if (!_subtitleLabel) {
        
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont themeFontRegular:10];
        _subtitleLabel.textColor = [UIColor themeGray3];
        _subtitleLabel.numberOfLines = 1;
        
    }
    
    return _subtitleLabel;
}

-(UIImageView *)icon {
    
    if (!_icon) {
        _icon = [[UIImageView alloc]init];
    }
    return _icon;
}

-(UIButton *)btn {
    
    if (!_btn) {
        
        _btn = [[UIButton alloc]init];
        _btn.layer.borderWidth = 0.5;
        _btn.layer.borderColor = [UIColor themeGray6].CGColor;
        _btn.layer.cornerRadius = 2;
        _btn.layer.masksToBounds = YES;
        _btn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    }
    return _btn;
}

@end
