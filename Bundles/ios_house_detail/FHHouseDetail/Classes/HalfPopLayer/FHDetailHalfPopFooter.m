//
//  FHDetailHalfPopFooter.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHDetailHalfPopFooter.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>
#import <TTBaseLib/TTDeviceHelper.h>

#define HOR_MARGIN 20

@implementation FHDetailHalfPopFooter

+ (CGFloat)btnWidth
{
    return [TTDeviceHelper isScreenWidthLarge320] ? 50 : 40;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tipLabel = [[UILabel alloc]init];
        UIFont *font = [TTDeviceHelper isScreenWidthLarge320] ? [UIFont themeFontRegular:16] : [UIFont themeFontRegular:15];
        _tipLabel.font = font;
        _tipLabel.textColor = [UIColor themeGray1];
        
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.titleLabel.font = font;
        [_actionButton setTitleColor:[UIColor themeRed3] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _negativeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _negativeButton.titleLabel.font = font;
        [_negativeButton setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
        [_negativeButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_tipLabel];
        [self addSubview:_actionButton];
        [self addSubview:_negativeButton];
        
        self.backgroundColor = [UIColor themeRed2];
        
        [self initConstraints];
        
    }
    return self;
}

-(void)onAction:(id)sender
{
    if (self.actionBlock) {
        NSInteger type = 0;
        if (!self.actionButton.hidden && !self.negativeButton.hidden) {
            if (sender == self.actionButton) {
                type = 1;
            }else{
                type = 2;
            }
        }
        self.actionBlock(type);
    }
}

-(void)showTip:(NSString *)tip type:(FHDetailHalfPopFooterType)type positiveTitle:(NSString *)ptitle negativeTitle:(NSString *)ntitle
{
    _tipLabel.text = tip;

    self.actionButton.enabled = YES;
    [self.actionButton setTitle:ptitle forState:UIControlStateNormal];
    if (type == FHDetailHalfPopFooterTypeConfirm) {
        
        self.negativeButton.hidden = YES;
//        CGSize size = [self.actionButton sizeThatFits:CGSizeMake(200, CGRectGetHeight(self.bounds))];
        [self.actionButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([FHDetailHalfPopFooter btnWidth]);
            make.right.mas_equalTo(-0);
        }];
        
    }else{
        self.negativeButton.enabled = YES;
        [self.negativeButton setTitle:ntitle forState:UIControlStateNormal];
        self.negativeButton.hidden = NO;
        [self.actionButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([FHDetailHalfPopFooter btnWidth]);
            make.right.mas_equalTo(-([FHDetailHalfPopFooter btnWidth] + 8));
        }];                
    }
}

-(void)changeToFeedbacked
{
    [self.actionButton setTitle:@"已提交" forState:UIControlStateNormal];
    self.negativeButton.hidden = YES;
    self.actionButton.enabled = NO;
    
    CGSize size = [self.actionButton sizeThatFits:CGSizeMake(200, CGRectGetHeight(self.bounds))];
    [self.actionButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(ceil(size.width));
        make.right.mas_equalTo(-20);
    }];
    
}

-(void)initConstraints
{
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.centerY.mas_equalTo(self);
        make.right.mas_lessThanOrEqualTo(self.actionButton.mas_left).offset(-5);
    }];
    
    [_negativeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(self);
        make.width.mas_equalTo([FHDetailHalfPopFooter btnWidth]);
    }];
    
    [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.mas_equalTo(self);        
        make.width.mas_equalTo([FHDetailHalfPopFooter btnWidth]);
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
