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
    [self addSubview:_valueLabel];
    [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self->_nameLabel.mas_left);
        make.top.mas_equalTo(self->_nameLabel.mas_bottom).mas_offset(3);
        make.right.mas_equalTo(-5);
        make.height.mas_equalTo(21);
    }];

    self.arrawView = [[UIImageView alloc] init];
    [_arrawView setHidden:YES];
    [self addSubview:_arrawView];
    [_arrawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.valueLabel.mas_right);
        make.centerY.mas_equalTo(self.valueLabel);
        make.height.with.mas_equalTo(13);
    }];
}

-(void)setArraw:(NSInteger)flag {
    switch (flag) {
        case 1:
            _arrawView.image = [UIImage imageNamed:@"arraw-up"];
            [_arrawView setHidden:NO];
            break;
        case -1:
            _arrawView.image = [UIImage imageNamed:@"arrow-down"];
            [_arrawView setHidden:NO];
            break;
        default:
            [_arrawView setHidden:YES];
            break;
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
