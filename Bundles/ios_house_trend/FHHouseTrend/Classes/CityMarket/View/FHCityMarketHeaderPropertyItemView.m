//
//  FHCityMarketHeaderPropertyItemView.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import "FHCityMarketHeaderPropertyItemView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <FHHouseBase/UIImage+FIconFont.h>

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
        make.right.lessThanOrEqualTo(self.mas_right).mas_offset(-5);
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
    NSString *text = nil;
    UIColor *textColor = nil;
    switch (flag) {
        case 1:
            text = @"\U0000e67f"; //arraw-up
            textColor = [UIColor themeRed];
            [_arrawView setHidden:NO];
            break;
        case -1:
            text = @"\U0000e677"; // arraw-down
            textColor = [UIColor themeGreen1];
            [_arrawView setHidden:NO];
            break;
        default:
            [_arrawView setHidden:YES];
            break;
    }
    if(text){
        _arrawView.image  =  ICON_FONT_IMG(12, text, textColor);
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
