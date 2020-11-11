//
//  FHCityListLocationBar.m
//  FHHouseHome
//
//  Created by 张元科 on 2019/1/4.
//

#import "FHCityListLocationBar.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHCityListLocationBar ()

@property (nonatomic, strong) UILabel *locationNameLabel;
@property (nonatomic, strong) UIImageView *locationIcon;

@end

@implementation FHCityListLocationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.cityName = @"";
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // cityNameBtn
    self.cityNameBtn = [[UIControl alloc] init];
    [self addSubview:self.cityNameBtn];
    [self.cityNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(-85);
    }];

    
    self.locationNameLabel = [[UILabel alloc] init];
    self.locationNameLabel.font = [UIFont themeFontRegular:16];
    self.locationNameLabel.textColor = [UIColor themeGray1];
    [self.cityNameBtn addSubview:self.locationNameLabel];
    [self.locationNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self.cityNameBtn);
    }];
    
    
    // searchIcon
    self.locationIcon = [[UIImageView alloc] init];
    self.locationIcon.userInteractionEnabled = NO;
    self.locationIcon.image = [UIImage imageNamed:@"location-name"];
    [self.cityNameBtn addSubview:self.locationIcon];
    [self.locationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.locationNameLabel.mas_right).offset(2);
        make.height.width.mas_equalTo(16);
        make.centerY.mas_equalTo(self);
    }];
    
    // reLocationBtn
    _reLocationBtn = [[UIButton alloc] init];
    _reLocationBtn.backgroundColor = [UIColor clearColor];
    [_reLocationBtn setTitle:@"重新定位" forState:UIControlStateNormal];
    [_reLocationBtn setTitle:@"重新定位" forState:UIControlStateHighlighted];
    _reLocationBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_reLocationBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
    [_reLocationBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateHighlighted];
    [self addSubview:_reLocationBtn];
    [_reLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self);
    }];
}

- (void)setCityName:(NSString *)cityName {
    _cityName = cityName;
    self.locationNameLabel.text = cityName;
}

- (void)setIsLocationSuccess:(BOOL)isLocationSuccess {
    _isLocationSuccess = isLocationSuccess;
    _cityNameBtn.enabled = isLocationSuccess;
    if (isLocationSuccess && _cityName) {
        self.locationNameLabel.textColor = [UIColor themeGray1];
        self.locationNameLabel.text = _cityName;
    } else {
        self.locationNameLabel.textColor = [UIColor themeGray4];
        self.locationNameLabel.text = @"定位失败";
    }
}

@end
