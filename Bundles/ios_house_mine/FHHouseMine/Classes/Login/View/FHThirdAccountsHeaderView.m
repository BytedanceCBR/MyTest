//
//  FHThirdAccountsHeaderView.m
//  FHHouseMine
//
//  Created by luowentao on 2020/4/21.
//

#import "FHThirdAccountsHeaderView.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "Masonry.h"

@implementation FHThirdAccountsHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"社交平台账号绑定";
        _titleLabel.font = [UIFont themeFontMedium:14];
        _titleLabel.textColor = [UIColor themeGray3];
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(20);
            make.centerY.mas_equalTo(self);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(112);
        }];
    }
    return self;
}


@end
