//
//  FHMapSearchInfoTopBar.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/9.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHMapSearchInfoTopBar.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIImage+IconFont.h"
#import "UIColor+Theme.h"
#import "UIViewAdditions.h"

#define BTN_WIDTH  24

@interface FHMapSearchInfoTopBar ()

@property(nonatomic , strong) UIView *contentView;
@property(nonatomic , strong) UIButton *backButton;
@property(nonatomic , strong) UIButton *filterButton;
@property(nonatomic , strong) UILabel *titleLabel;

@end

@implementation FHMapSearchInfoTopBar

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.layer.cornerRadius = 4;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:_contentView];
        
        CALayer *layer = self.layer;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOffset = CGSizeMake(0, 2);
        layer.shadowRadius = 6;
        layer.shadowOpacity = 0.1;
        
        
        UIImage *img = ICON_FONT_IMG(16,@"\U0000e672",[UIColor themeGray1]);
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:img forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:_backButton];
        
        img = ICON_FONT_IMG(18,@"\U0000e68d",[UIColor themeGray1]);
        _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_filterButton setImage:img forState:UIControlStateNormal];
        [_filterButton addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_filterButton];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [_contentView addSubview:_titleLabel];
        
        [self initConstraints];
    }
    return self;
}

-(void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

-(NSString *)title
{
    return _titleLabel.text;
}

-(void)backAction:(id)sender
{
    if (_backBlock) {
        _backBlock();
    }
}

-(void)filterAction:(id)sender
{
    if (_filterBlock) {
        _filterBlock();
    }
}

-(void)initConstraints
{
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(BTN_WIDTH);
        make.height.mas_equalTo(BTN_WIDTH);
    }];
    
    [_filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(BTN_WIDTH);
        make.height.mas_equalTo(BTN_WIDTH);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backButton.mas_right).offset(10);
        make.right.mas_equalTo(self.filterButton.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.contentView);
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
