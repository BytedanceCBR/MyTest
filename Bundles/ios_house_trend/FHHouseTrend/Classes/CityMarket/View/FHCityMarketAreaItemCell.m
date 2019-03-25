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
@property (nonatomic, strong) UIView* numberIconView;
@property (nonatomic, strong) UILabel* numberLabel;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIImageView* arrawView;
@property (nonatomic, strong) UILabel* priceLabel;
@property (nonatomic, strong) UILabel* countLabel;

@end

@implementation FHCityMarketAreaItemCell

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
        make.right.mas_equalTo(20);
        make.left.mas_equalTo(83);
        make.height.mas_equalTo(20);
        make.center.centerY.mas_equalTo(self.contentView);
    }];

    self.priceLabel = [[UILabel alloc] init];
    _priceLabel.font = [UIFont themeFontRegular:14];
    _priceLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_priceLabel];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.countLabel.mas_left).mas_offset(5);
        make.left.mas_equalTo(self.countLabel.mas_left).mas_offset(106);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.contentView);
    }];

    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontRegular:14];
    _titleLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.numberIconView).mas_offset(5);
        make.right.lessThanOrEqualTo(self.priceLabel.mas_left).mas_offset(18);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.contentView);
    }];

    self.arrawView = [[UIImageView alloc] init];
    [self.contentView addSubview:_arrawView];
    [_arrawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right);
        make.centerY.mas_equalTo(self.titleLabel);
        make.width.height.mas_equalTo(14);
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
