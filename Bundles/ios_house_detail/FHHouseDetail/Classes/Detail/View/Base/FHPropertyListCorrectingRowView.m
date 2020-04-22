//
//  FHPropertyListCorrectingRowView.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/10.
//

#import "FHPropertyListCorrectingRowView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UILabel+House.h>
#import <FHCommonUI/UIColor+Theme.h>


@implementation FHPropertyListCorrectingRowView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _keyLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _keyLabel.textColor = [UIColor colorWithHexString:@"aeadad"];
    [self addSubview:_keyLabel];
    [_keyLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_keyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    _valueLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _valueLabel.textColor = [UIColor themeGray1];
    [self addSubview:_valueLabel];
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    
    // 布局
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.keyLabel.mas_right).offset(10);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self.keyLabel);
    }];
}


@end
