//
//  FHHouseRentFacilityItemView.m
//  FHHouseRent
//
//  Created by leo on 2018/11/20.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FHHouseRentFacilityItemView.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "BDWebImage.h"
@implementation FHHouseRentFacilityItemView

- (instancetype)initWithStrickoutLabel:(UILabel*)label
{
    self = [super init];
    if (self) {
        self.strickoutLabel = label;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_iconView];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.height.width.mas_equalTo(30);
        make.top.mas_equalTo(10);
    }];

    self.label = [[UILabel alloc] init];
    _label.font = [UIFont themeFontRegular:14];
    _label.textColor = [UIColor themeGray2];
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconView.mas_bottom).offset(6);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-10);
    }];

    if (_strickoutLabel != nil) {
        [_strickoutLabel setHidden:YES];
        [self addSubview:_strickoutLabel];
        [_strickoutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconView.mas_bottom).offset(6);
            make.centerX.mas_equalTo(self);
            make.height.mas_equalTo(20);
            make.bottom.mas_equalTo(-10);
        }];
    }
}

@end
