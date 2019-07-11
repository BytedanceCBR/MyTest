//
//  FHMapSearchFilterHeaderView.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/10.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHMapSearchFilterHeaderView.h"
//#import <FHCommonUI/UIFont+House.h>
//#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>

#import "UIFont+House.h"
#import "UIColor+Theme.h"

@interface FHMapSearchFilterHeaderView ()

@property(nonatomic , strong) UILabel *titleLabel;

@end

@implementation FHMapSearchFilterHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontRegular:12];
        _titleLabel.textColor = [UIColor themeGray1];
        
        [self addSubview:_titleLabel];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.bottom.mas_equalTo(self).offset(-10);
            make.right.mas_lessThanOrEqualTo(-10);
        }];
    }
    return self;
}

-(void)updateTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

-(void)updateAttrTitle:(NSAttributedString *)attrTitle
{
    self.titleLabel.attributedText = attrTitle;
}

@end
