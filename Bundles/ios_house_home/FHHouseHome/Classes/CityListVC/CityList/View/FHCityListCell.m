//
//  FHCityListCell.m
//  FHHouseHome
//
//  Created by 张元科 on 2019/1/6.
//

#import "FHCityListCell.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"

@interface FHCityItemCell()

@end

@implementation FHCityItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    // descLabel
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.textColor = [UIColor colorWithHexString:@"#e1e3e6"];
    self.descLabel.font = [UIFont themeFontRegular:12];
    [self.contentView addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(17);
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-40);
    }];
    // cityNameLabel
    self.cityNameLabel = [[UILabel alloc] init];
    self.cityNameLabel.textColor = [UIColor themeBlue1];
    self.cityNameLabel.font = [UIFont themeFontRegular:15];
    [self.contentView addSubview:self.cityNameLabel];
    [self.cityNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(21);
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.descLabel.mas_left).offset(-10);
    }];
}

@end

// FHCityHotItemCell
@interface FHCityHotItemCell ()

@end

@implementation FHCityHotItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    
}



@end


// FHCityItemHeaderView

@interface FHCityItemHeaderView ()

@end

@implementation FHCityItemHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    self.label = [[UILabel alloc] init];
    self.label.textColor = [UIColor themeGray4];
    self.label.font = [UIFont themeFontRegular:16];
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self).offset(6);
        make.right.mas_equalTo(self).offset(-20);
    }];
}

@end
