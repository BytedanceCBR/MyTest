//
//  FHIMHouseShareView.m
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import "FHIMHouseShareView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
@implementation FHIMHouseShareView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.houseImage = [[UIImageView alloc] init];
    _houseImage.layer.masksToBounds = YES;
    _houseImage.layer.cornerRadius = 4;
    _houseImage.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_houseImage];
    [_houseImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(60);
        make.top.mas_equalTo(17);
        make.bottom.mas_equalTo(-20);
    }];

    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontMedium:15];
    _titleLabel.textColor = [UIColor themeGray1];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(16);
        make.height.mas_equalTo(21);
        make.left.mas_equalTo(self.houseImage.mas_right).mas_offset(12);
        make.right.mas_equalTo(-20);
    }];


    self.subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.font = [UIFont themeFontRegular:12];
    _subTitleLabel.textColor = RGBA(0x99, 0x99, 0x99, 1);
    [self addSubview:_subTitleLabel];
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(17);
        make.left.mas_equalTo(self.houseImage.mas_right).mas_offset(12);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(2);
    }];

    self.totalPriceLabel = [[UILabel alloc] init];
    self.pricePerSqmLabel = [[UILabel alloc] init];
    [self addSubview:_totalPriceLabel];
    [self addSubview:_pricePerSqmLabel];

    _totalPriceLabel.font = [UIFont themeFontMedium:14];
    _totalPriceLabel.textColor = RGBA(0xff, 0x58, 0x69, 1);
    [_totalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).mas_offset(4);
        make.left.mas_equalTo(self.houseImage.mas_right).mas_offset(12);
        make.height.mas_equalTo(20);
    }];

    _pricePerSqmLabel.font = [UIFont themeFontRegular:12];
    _pricePerSqmLabel.textColor = RGBA(0x99, 0x99, 0x99, 1);
    [_pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.totalPriceLabel.mas_right).mas_offset(12);
        make.centerY.mas_equalTo(self.totalPriceLabel);
        make.right.lessThanOrEqualTo(self).mas_offset(-20);
        make.height.mas_equalTo(17);
    }];
}

@end
