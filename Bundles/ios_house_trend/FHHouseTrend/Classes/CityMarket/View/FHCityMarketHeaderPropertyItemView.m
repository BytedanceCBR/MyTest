//
//  FHCityMarketHeaderPropertyItemView.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import "FHCityMarketHeaderPropertyItemView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
@interface FHCityMarketHeaderPropertyItemView ()
{

}
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* valueLabel;
@end

@implementation FHCityMarketHeaderPropertyItemView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI {
    self.nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont themeFontRegular:11];
    _nameLabel.textColor = [UIColor colorWithHexString:@"999999"];
    _nameLabel.text = @"降价趋势(比上月)";
    [self addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(-5);
        make.height.mas_equalTo(16);
    }];
    self.valueLabel = [[UILabel alloc] init];
    _valueLabel.font = [UIFont themeFontSemibold:18];
    _valueLabel.textColor = [UIColor blackColor];
    _valueLabel.text = @"value";
    [self addSubview:_valueLabel];
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self->_nameLabel.mas_left);
        make.top.mas_equalTo(self->_nameLabel.mas_bottom).mas_offset(3);
        make.right.mas_equalTo(-5);
        make.height.mas_equalTo(21);
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
