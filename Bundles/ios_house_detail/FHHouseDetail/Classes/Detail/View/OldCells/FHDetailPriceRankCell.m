//
//  FHDetailPriceRankCell.m
//  Pods
//
//  Created by 张静 on 2019/2/18.
//

#import "FHDetailPriceRankCell.h"
#import "Masonry.h"
#import "YYText.h"

@interface FHDetailPriceRankCell ()

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) UILabel *rankLabel;
@property(nonatomic , strong) UIView *line;
@property(nonatomic , strong) UILabel *subtitleLabel;

@end

@implementation FHDetailPriceRankCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    [self.contentView addSubview:self.bgView];
    self.bgView.layer.cornerRadius = 4;
    self.bgView.layer.masksToBounds = YES;
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(20);
        make.right.bottom.mas_equalTo(-20);
    }];
    
    [self.bgView addSubview:self.tipLabel];
    [self.bgView addSubview:self.rankLabel];
    [self.bgView addSubview:self.line];
    [self.bgView addSubview:self.subtitleLabel];

    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.bgView);
        make.height.mas_equalTo(50);
    }];
    [self.rankLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.bgView);
        make.height.mas_equalTo(self.tipLabel);
    }];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.tipLabel.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.line.mas_bottom).mas_offset(17);
        make.bottom.mas_equalTo(-17);
    }];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"price_rank";
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHDetailPriceRankModel class]]) {
        
        FHDetailOldDataHousePricingRankModel *priceRank = ((FHDetailPriceRankModel *)data).priceRank;
        NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc]init];
        if (priceRank.position.length > 0) {
            NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc]initWithString:priceRank.position];
            attr1.yy_font = [UIFont themeFontRegular:24];
            [attributeText appendAttributedString:attr1];
        }
        if (priceRank.total.length > 0) {
            NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"/%@",priceRank.total]];
            attr1.yy_font = [UIFont themeFontRegular:12];
            [attributeText appendAttributedString:attr1];
        }
        self.rankLabel.attributedText = attributeText;
        if (priceRank.analyseDetail.length > 0) {
            NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc]initWithString:priceRank.analyseDetail];
            attr1.yy_lineSpacing = 6;
            self.subtitleLabel.attributedText = attr1;
        }
    }
}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor themeGray7];
    }
    return _bgView;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont themeFontRegular:16];
        _tipLabel.textColor = [UIColor themeGray1];
        _tipLabel.text = @"同小区同户型挂牌价排名";
    }
    return _tipLabel;
}

- (UILabel *)rankLabel
{
    if (!_rankLabel) {
        _rankLabel = [[UILabel alloc]init];
        _rankLabel.font = [UIFont themeFontRegular:12];
        _rankLabel.textColor = [UIColor themeGray1];
    }
    return _rankLabel;
}

- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = [UIColor themeGray6];
    }
    return _line;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont themeFontRegular:14];
        _subtitleLabel.textColor = [UIColor themeGray2];
        _subtitleLabel.numberOfLines = 0;
    }
    return _subtitleLabel;
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


@implementation FHDetailPriceRankModel


@end
