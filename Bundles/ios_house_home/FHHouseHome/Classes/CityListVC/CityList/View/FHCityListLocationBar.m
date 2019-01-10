//
//  FHCityListLocationBar.m
//  FHHouseHome
//
//  Created by 张元科 on 2019/1/4.
//

#import "FHCityListLocationBar.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHSuggestionListNavBar.h"
#import "FHExtendHotAreaButton.h"

@interface FHCityListLocationBar ()

@property (nonatomic, strong)   UIImageView       *locationIcon;

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
    _cityNameBtn = [[FHExtendHotAreaButton alloc] init];
    [_cityNameBtn setTitle:@"" forState:UIControlStateNormal];
    [_cityNameBtn setTitle:@"" forState:UIControlStateHighlighted];
    _cityNameBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [_cityNameBtn setTitleColor:[UIColor themeBlue1] forState:UIControlStateNormal];
    [_cityNameBtn setTitleColor:[UIColor themeBlue1] forState:UIControlStateHighlighted];
    [self addSubview:_cityNameBtn];
    [_cityNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.mas_equalTo(self).offset(20);
        make.centerY.mas_equalTo(self);
    }];
    // searchIcon
    _locationIcon = [[UIImageView alloc] init];
    _locationIcon.image = [UIImage imageNamed:@"location-name"];
    [self addSubview:_locationIcon];
    [_locationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cityNameBtn.mas_right).offset(2);
        make.height.width.mas_equalTo(16);
        make.centerY.mas_equalTo(self);
    }];
    // reLocationBtn
    _reLocationBtn = [[UIButton alloc] init];
    _reLocationBtn.backgroundColor = [UIColor clearColor];
    [_reLocationBtn setTitle:@"重新定位" forState:UIControlStateNormal];
    [_reLocationBtn setTitle:@"重新定位" forState:UIControlStateHighlighted];
    _reLocationBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_reLocationBtn setTitleColor:[UIColor colorWithHexString:@"#299cff"] forState:UIControlStateNormal];
    [_reLocationBtn setTitleColor:[UIColor colorWithHexString:@"#299cff"] forState:UIControlStateHighlighted];
    [self addSubview:_reLocationBtn];
    [_reLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self);
    }];
}

- (void)setCityName:(NSString *)cityName {
    _cityName = cityName;
    [self.cityNameBtn setTitle:cityName forState:UIControlStateNormal];
    [self.cityNameBtn setTitle:cityName forState:UIControlStateHighlighted];
}

- (void)setIsLocationSuccess:(BOOL)isLocationSuccess {
    _isLocationSuccess = isLocationSuccess;
    _cityNameBtn.enabled = isLocationSuccess;
    if (isLocationSuccess) {
        [_cityNameBtn setTitleColor:[UIColor themeBlue1] forState:UIControlStateNormal];
        [_cityNameBtn setTitleColor:[UIColor themeBlue1] forState:UIControlStateHighlighted];
        [self.cityNameBtn setTitle:_cityName forState:UIControlStateNormal];
        [self.cityNameBtn setTitle:_cityName forState:UIControlStateHighlighted];
    } else {
        [_cityNameBtn setTitleColor:[UIColor themeGray4] forState:UIControlStateNormal];
        [_cityNameBtn setTitleColor:[UIColor themeGray4] forState:UIControlStateHighlighted];
        [self.cityNameBtn setTitle:@"定位失败" forState:UIControlStateNormal];
        [self.cityNameBtn setTitle:@"定位失败" forState:UIControlStateHighlighted];
    }
}

@end
