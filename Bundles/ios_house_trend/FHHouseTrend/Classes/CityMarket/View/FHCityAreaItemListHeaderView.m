//
//  FHCityAreaItemListHeaderView.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/27.
//

#import "FHCityAreaItemListHeaderView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "ReactiveObjC.h"
@implementation FHCityAreaItemListHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    self.headerNameLabel = [[UILabel alloc] init];
    _headerNameLabel.font = [UIFont themeFontRegular:14];
    _headerNameLabel.textColor = [UIColor themeGray3];
    _headerNameLabel.text = @"小区名称";
    [self addSubview:_headerNameLabel];
    [_headerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-3);
    }];

    self.headerPriceLabel = [[UILabel alloc] init];
    _headerPriceLabel.font = [UIFont themeFontRegular:14];
    _headerPriceLabel.textColor = [UIColor themeGray3];
    _headerPriceLabel.text = @"均价";
    [self addSubview:_headerPriceLabel];
    [_headerPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_right).mas_offset(-187);
        make.top.mas_equalTo(15);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-3);
    }];

    self.headerCountLabel = [[UILabel alloc] init];
    _headerCountLabel.font = [UIFont themeFontRegular:14];
    _headerCountLabel.textColor = [UIColor themeGray3];
    _headerCountLabel.text = @"在售套数";
    [self addSubview:_headerCountLabel];
    [_headerCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-27);
        make.top.mas_equalTo(15);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-3);
    }];

    UIView* lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor themeGray6];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self);
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
