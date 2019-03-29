//
//  FHCityMarketRecomandHouseCell.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHCityMarketRecomandHouseCell.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
@interface FHCityMarketRecomandHouseCell ()
@end

@implementation FHCityMarketRecomandHouseCell

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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupUI {
    UIView* backgroundView = [[UIView alloc] init];
    [self.contentView addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(14);
        make.bottom.mas_equalTo(-6);
    }];
    backgroundView.layer.borderColor = [UIColor colorWithHexString:@"fa5d12"].CGColor;
    backgroundView.layer.borderWidth = 1;
    backgroundView.layer.cornerRadius = 4;

    self.tagView = [[UIImageView alloc] init];
    [self.contentView addSubview:_tagView];
    _tagView.backgroundColor = [UIColor clearColor];
    [_tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(9);
        make.top.mas_equalTo(self.contentView);
        make.width.mas_equalTo(57);
        make.height.mas_equalTo(50);
    }];

    self.houseIconView = [[UIImageView alloc] init];
    _houseIconView.layer.cornerRadius = 4;
    [backgroundView addSubview:_houseIconView];
    [_houseIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(90);
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(17);
        make.bottom.mas_equalTo(-15);
    }];

    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontRegular:16];
    _titleLabel.textColor = [UIColor colorWithHexString:@"232322"];
    [backgroundView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.mas_equalTo(self.houseIconView.mas_right).mas_offset(15);
        make.top.mas_equalTo(backgroundView).mas_offset(14);
        make.right.mas_equalTo(backgroundView).mas_offset(-15);
    }];

    self.subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.font = [UIFont themeFontRegular:12];
    _subTitleLabel.textColor = [UIColor colorWithHexString:@"7f7f7f"];
    [backgroundView addSubview:_subTitleLabel];
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(4);
        make.left.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(-15);
    }];

    self.priceLabel = [[UILabel alloc] init];
    _priceLabel.font = [UIFont themeFontMedium:16];
    _priceLabel.textColor = [UIColor colorWithHexString:@"ff5b4c"];
    [backgroundView addSubview:_priceLabel];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).mas_offset(4);
        make.left.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(22);
    }];

    self.oldPriceLabel = [[UILabel alloc] init];
    [backgroundView addSubview:_oldPriceLabel];
    [_oldPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.priceLabel);
        make.left.mas_equalTo(self.priceLabel).mas_offset(5);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(backgroundView).mas_offset(-15);
    }];


    self.priceChangeLabel = [[UILabel alloc] init];
    [backgroundView addSubview:_priceChangeLabel];
    [_priceChangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceLabel.mas_bottom).mas_offset(4);
        make.left.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(backgroundView).mas_offset(-15);
    }];
}

@end
