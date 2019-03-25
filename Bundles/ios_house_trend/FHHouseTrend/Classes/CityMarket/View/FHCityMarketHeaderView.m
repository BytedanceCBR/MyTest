//
//  FHCityMarketHeaderView.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import "FHCityMarketHeaderView.h"
#import <Masonry.h>
#import "TTDeviceHelper.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCityMarketHeaderPropertyBar.h"

@interface FHCityMarketHeaderView () {
    CGFloat _navBarHeight;
}
@property (nonatomic, strong) UIImageView* bgView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* priceLabel;
@property (nonatomic, strong) UILabel* sourceLabel;
@property (nonatomic, strong) UILabel* unitLabel;
@end

@implementation FHCityMarketHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 64 : 84;
        [self initHeaderBgView];
        [self initHeaderInfo];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 64 : 84;
        [self initHeaderBgView];
        [self initHeaderInfo];
    }
    return self;
}

-(void)initHeaderBgView {
    self.bgView = [[UIImageView alloc] init];
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.mas_equalTo(self);
        make.height.mas_equalTo(160 + _navBarHeight);
    }];
    _bgView.image = [UIImage imageNamed:@"city_market_header"];
}

-(void)initHeaderInfo {
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont themeFontRegular:12];
    _titleLabel.text = @"南京·二月房价行情";
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_navBarHeight + 29);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(17);
    }];

    self.priceLabel = [[UILabel alloc] init];
    _priceLabel.textColor = [UIColor whiteColor];
    _priceLabel.font = [UIFont themeFontSemibold:40];
    _priceLabel.text = @"29745";
    [self addSubview:_priceLabel];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLabel.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(47);
    }];

    self.unitLabel = [[UILabel alloc] init];
    _unitLabel.textColor = [UIColor whiteColor];
    _unitLabel.font = [UIFont themeFontSemibold:14];
    _unitLabel.text = @"元/平";
    [self addSubview:_unitLabel];
    [_unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_priceLabel.mas_bottom).mas_offset(-5);
        make.left.mas_equalTo(_priceLabel.mas_right).mas_offset(7);
        make.right.mas_lessThanOrEqualTo(-20);
        make.height.mas_equalTo(20);
    }];

    self.sourceLabel = [[UILabel alloc] init];
    _sourceLabel.textColor = [UIColor whiteColor];
    _sourceLabel.font = [UIFont themeFontRegular:11];
    _sourceLabel.alpha = 0.5;
    _sourceLabel.text = @"数据来源：今日头条房产频道";
    [self addSubview:_sourceLabel];
    [_sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_priceLabel.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(16);
    }];

    self.propertyBar = [[FHCityMarketHeaderPropertyBar alloc] init];
    [self addSubview:_propertyBar];
    [_propertyBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(70);
        make.bottom.mas_equalTo(self.mas_bottom);
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
