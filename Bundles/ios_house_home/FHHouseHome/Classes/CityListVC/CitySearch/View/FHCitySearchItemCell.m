//
//  FHCitySearchItemCell.m
//  FHHouseHome
//
//  Created by 张元科 on 2019/1/8.
//

#import "FHCitySearchItemCell.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHCommonDefines.h"

@implementation FHCitySearchItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    // cityNameLabel
    self.cityNameLabel = [[UILabel alloc] init];
    self.cityNameLabel.textColor = [UIColor themeGray1];
    self.cityNameLabel.font = [UIFont themeFontRegular:15];
    [self.contentView addSubview:self.cityNameLabel];
    [self.cityNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(21);
        make.top.mas_equalTo(self.contentView).offset(20);
    }];
    // descLabel
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.text = @"未开通";
    self.descLabel.textColor = [UIColor colorWithHexString:@"#e1e3e6"];
    self.descLabel.font = [UIFont themeFontRegular:12];
    [self.contentView addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(21);
        make.centerY.mas_equalTo(self.cityNameLabel);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    self.enabled = NO;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.descLabel.hidden = enabled;
}

@end
