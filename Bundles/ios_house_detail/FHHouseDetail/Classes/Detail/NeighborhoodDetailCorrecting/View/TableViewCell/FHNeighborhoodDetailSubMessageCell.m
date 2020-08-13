//
//  FHNeighborhoodDetailSubMessageCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/2/5.
//

#import "FHNeighborhoodDetailSubMessageCell.h"
#import "UILabel+House.h"
@interface FHNeighborhoodDetailSubMessageCell()
@property (nonatomic, weak) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *monthUp;
@property (nonatomic, weak) UILabel  *monthUpLabel;
@property (nonatomic, weak) UILabel  *per;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) UIImageView *monthUpTrend;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation FHNeighborhoodDetailSubMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodSubMessageModel class]]) {
        return;
    }
     self.currentData = data;
    
    FHDetailNeighborhoodSubMessageModel *model = (FHDetailNeighborhoodSubMessageModel *)data;
    self.shadowImage.image = model.shadowImage;
    if (model) {
        self.priceLabel.text = model.neighborhoodInfo.pricingPerSqm;
        if (model.neighborhoodInfo.monthUp.length > 0) {
            CGFloat value = [model.neighborhoodInfo.monthUp floatValue] * 100;
            if (fabs(value) < 0.0001) {
                self.monthUpLabel.text = @"持平";
                self.per.hidden = YES;
                self.monthUpTrend.hidden = YES;
                [self.monthUpLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.containerView).offset(-16);
                    make.centerY.equalTo(self.priceLabel);
                }];
            } else {
                self.monthUpLabel.text = [NSString stringWithFormat:@"%.2f",fabs(value)];
                self.monthUpTrend.hidden = NO;
                if (value > 0) {
                    self.monthUpTrend.image = [UIImage imageNamed:@"plot_red_arrow"];
                } else {
                    self.monthUpTrend.image = [UIImage imageNamed:@"plot_green_arrow"];
                }
            }
        }
    }
}

- (void)createUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadowImage).offset(12);
        make.bottom.equalTo(self.shadowImage).offset(-12);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(16);
        make.top.equalTo(self.containerView).offset(16);
        make.bottom.equalTo(self.containerView).offset(-5);
    }];
    [self.monthUpTrend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView).offset(-16);
        make.centerY.equalTo(self.priceLabel);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [self.per mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.monthUpTrend.mas_left).offset(-2);
        make.centerY.equalTo(self.priceLabel);
    }];
    [self.monthUpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.per.mas_left).offset(-2);
        make.centerY.equalTo(self.priceLabel);
    }];
    [self.monthUp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.monthUpLabel.mas_left).offset(-4);
        make.centerY.equalTo(self.priceLabel);
    }];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        shadowImage.image = [[UIImage imageNamed:@""] resizableImageWithCapInsets:UIEdgeInsetsMake(20,0,20,0) resizingMode:UIImageResizingModeStretch];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [[UIView alloc]init];
        [self.contentView addSubview: containerView];
        _containerView = containerView;
    }
    return _containerView;
}
- (UILabel *)priceLabel {
    if (!_priceLabel) {
        UILabel *priceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:20];
        priceLabel.textColor = [UIColor themeGray1];
        priceLabel.font = [UIFont themeFontSemibold:20];
        [self.containerView addSubview:priceLabel];
        _priceLabel = priceLabel;
    }
    return _priceLabel;
}

- (UILabel *)monthUp {
    if (!_monthUp) {
        UILabel *monthUp = [UILabel createLabel:@"环比上月" textColor:@"" fontSize:14];
        monthUp.textColor = [UIColor themeGray3];
        monthUp.font = [UIFont themeFontMedium:14];
        [self.containerView addSubview:monthUp];
        _monthUp = monthUp;
    }
    return _monthUp;
}

- (UILabel *)monthUpLabel {
    if (!_monthUpLabel) {
        UILabel *monthUpLabel = [UILabel createLabel:@"" textColor:@"" fontSize:18];
        monthUpLabel.textColor = [UIColor themeGray1];
        monthUpLabel.font = [UIFont themeFontDINAlternateBold:18];
        [self.containerView addSubview:monthUpLabel];
        _monthUpLabel = monthUpLabel;
    }
    return _monthUpLabel;
}

- (UILabel *)per {
    if (!_per) {
        UILabel *per = [UILabel createLabel:@"%" textColor:@"" fontSize:18];
        per.textColor = [UIColor themeGray1];
        per.font = [UIFont themeFontMedium:18];
        [self.containerView addSubview:per];
        _per = per;
    }
    return _per;
}

- (UIImageView *)monthUpTrend {
    if (!_monthUpTrend) {
        UIImageView *monthUpTrend = [[UIImageView alloc]init];
        monthUpTrend.image = [UIImage imageNamed:@"plot-green-arrow"];
        [self.containerView addSubview:monthUpTrend];
        _monthUpTrend = monthUpTrend;
    }
    return  _monthUpTrend;
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

@implementation FHDetailNeighborhoodSubMessageModel

@end
