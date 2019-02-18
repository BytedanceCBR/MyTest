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

@property(nonatomic , strong) UILabel *titleLabel;
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
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.contentView).mas_offset(30);
        make.height.mas_equalTo(25);
    }];
    
    [self.contentView addSubview:self.bgView];
    self.bgView.layer.cornerRadius = 4;
    self.bgView.layer.masksToBounds = YES;
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(20);
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
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#f2f4f5" alpha:0.4];
    }
    return _bgView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeBlack];
        _titleLabel.text = @"价格分析";
    }
    return _titleLabel;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont themeFontRegular:16];
        _tipLabel.textColor = [UIColor themeBlack];
        _tipLabel.text = @"同小区同户型挂牌价排名";
    }
    return _tipLabel;
}

- (UILabel *)rankLabel
{
    if (!_rankLabel) {
        _rankLabel = [[UILabel alloc]init];
        _rankLabel.font = [UIFont themeFontRegular:12];
        _rankLabel.textColor = [UIColor themeBlack];
    }
    return _rankLabel;
}

- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = [UIColor whiteColor];
    }
    return _line;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont themeFontRegular:14];
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"#737a80"];
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
