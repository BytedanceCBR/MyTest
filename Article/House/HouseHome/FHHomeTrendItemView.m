//
//  FHHomeTrendItemView.m
//  Article
//
//  Created by 张静 on 2018/11/23.
//

#import "FHHomeTrendItemView.h"
#import "UIColor+Theme.h"

@implementation FHHomeTrendItemView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    
    self.leftPadding = 15;
    self.rightPadding = 15;

    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
    [self addSubview:self.icon];

}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
    self.titleLabel.top = 10;
    self.titleLabel.width = self.width - self.leftPadding - self.rightPadding;
    self.titleLabel.left = self.leftPadding;
    
    [self.subtitleLabel sizeToFit];
    self.subtitleLabel.top = self.titleLabel.bottom + 3;
    self.subtitleLabel.left = self.titleLabel.left;
    if (self.subtitleLabel.width > self.width - 40) {
        
        self.subtitleLabel.width = self.width - 40;
    }
    
    [self.icon sizeToFit];
    self.icon.left = self.subtitleLabel.right + 3;
    self.icon.centerY = self.subtitleLabel.centerY;
    
}

-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
        _titleLabel.textColor = [UIColor themeBlack];
        _titleLabel.numberOfLines = 1;
        
    }
    
    return _titleLabel;
}

-(UILabel *)subtitleLabel {
    
    if (!_subtitleLabel) {
        
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
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

@end
