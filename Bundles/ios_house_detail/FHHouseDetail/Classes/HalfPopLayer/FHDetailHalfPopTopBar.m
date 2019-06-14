//
//  FHDetailHalfPopTopBar.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHDetailHalfPopTopBar.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>


@interface FHDetailHalfPopTopBar ()

@property(nonatomic , strong) UIButton *closeButton;
@property(nonatomic , strong) UIButton *reportButton;

@end

@implementation FHDetailHalfPopTopBar

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage *img = [UIImage imageNamed:@"icon_close"];
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:img forState:UIControlStateNormal];
        [_closeButton setImage:img forState:UIControlStateHighlighted];
        [_closeButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reportButton setTitle:@"举报" forState:UIControlStateNormal];
        [_reportButton setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
        [_reportButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
        _reportButton.titleLabel.font = [UIFont themeFontRegular:16];
        
        [self addSubview:_closeButton];
        [self addSubview:_reportButton];
        
        self.backgroundColor = [UIColor whiteColor];
        
        [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(7);
            make.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(50);
        }];
        
        [_reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self);
            make.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(72);
        }];
    }
    return self;
}

-(void)onAction:(id)sender
{
    if (self.headerActionBlock) {
        self.headerActionBlock(sender == _closeButton);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end