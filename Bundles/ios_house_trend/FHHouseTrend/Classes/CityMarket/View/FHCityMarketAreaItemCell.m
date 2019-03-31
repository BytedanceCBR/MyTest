//
//  FHCityMarketAreaItemCell.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHCityMarketAreaItemCell.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
@interface FHCityMarketAreaItemCell ()

@end

@implementation FHCityMarketAreaItemCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.numberIconView = [[UIView alloc] init];
    _numberIconView.backgroundColor = [UIColor colorWithHexString:@"ff5200"];
    _numberIconView.layer.cornerRadius = 4;
    [self.contentView addSubview:_numberIconView];
    [_numberIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.width.height.mas_equalTo(19);
        make.top.mas_equalTo(12);
        make.bottom.mas_equalTo(-12);
    }];

    self.numberLabel = [[UILabel alloc] init];
    _numberLabel.font = [UIFont themeFontRegular:14];
    _numberLabel.textColor = [UIColor whiteColor];
    [_numberIconView addSubview:_numberLabel];
    [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.numberIconView);
    }];

    self.countLabel = [[UILabel alloc] init];
    _countLabel.font = [UIFont themeFontRegular:14];
    _countLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_countLabel];
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.left.mas_equalTo(self.contentView.mas_right).mas_offset(-83);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.contentView);
    }];

    self.priceLabel = [[UILabel alloc] init];
    _priceLabel.font = [UIFont themeFontRegular:14];
    _priceLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_priceLabel];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.countLabel.mas_left).mas_offset(-5);
        make.left.mas_equalTo(self.countLabel.mas_left).mas_offset(-106);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.contentView);
    }];

    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontRegular:14];
    _titleLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.numberIconView.mas_right).mas_offset(5);
        make.right.lessThanOrEqualTo(self.priceLabel.mas_left).mas_offset(18);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.contentView);
    }];

    self.arrawView = [[UIImageView alloc] init];
    _arrawView.image = [UIImage imageNamed:@"arrowicon-detail"];
    [self.contentView addSubview:_arrawView];
    [_arrawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right);
        make.centerY.mas_equalTo(self.titleLabel);
        make.width.height.mas_equalTo(14);
    }];

    UIView* seperateLine = [[UIView alloc] init];
    seperateLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:seperateLine];
    [seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
