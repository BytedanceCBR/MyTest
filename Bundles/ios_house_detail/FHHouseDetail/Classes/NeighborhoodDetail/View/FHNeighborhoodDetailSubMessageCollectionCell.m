//
//  FHNeighborhoodDetailSubMessageCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailSubMessageCollectionCell.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"

@interface FHNeighborhoodDetailSubMessageCollectionCell ()
@property (nonatomic, weak) YYLabel *priceLabel;
@property (nonatomic, strong) UILabel *monthUp;
@property (nonatomic, strong) UILabel *subLabel;
@property (nonatomic, weak) UILabel  *monthUpLabel;
@property (nonatomic, weak) UIImageView *monthUpTrend;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *arrowImageView;
@end

@implementation FHNeighborhoodDetailSubMessageCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailSubMessageModel class]]) {
        CGFloat height = 94;
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailSubMessageModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailSubMessageModel *model = (FHNeighborhoodDetailSubMessageModel *)data;
    if (model) {
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:model.perSquareMetre];
        NSDictionary *commonTextStyle = @{ NSFontAttributeName:[UIFont themeFontMedium:24],NSForegroundColorAttributeName:[UIColor colorWithHexStr:@"#fe5500"]};
        [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
        NSRange tapRange = [attrText.string rangeOfString:@"元/平"];
        [attrText yy_setFont:[UIFont themeFontRegular:14] range:tapRange];
        self.priceLabel.attributedText = attrText;
        
        CGFloat value = [model.monthUp floatValue] * 100;
        if(fabs(value) < 0.0001){
            self.monthUp.text = @"与上月持平";
            self.monthUpTrend.image = [UIImage imageNamed:@"price_plot_even"];
        }else{
            self.monthUpLabel.text = [NSString stringWithFormat:@"%.2f%%",fabs(value)];
            if(value > 0){
                self.monthUp.text = @"比上月涨";
                self.monthUpTrend.image = [UIImage imageNamed:@"price_plot_up"];
            }else{
                self.monthUp.text = @"比上月跌";
                self.monthUpTrend.image = [UIImage imageNamed:@"price_plot_low"];
            }
        }
        self.subLabel.text = model.subTitleText;
    }
}

- (void)bindViewModel:(id)viewModel {
    [self refreshWithData:viewModel];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).offset(12);
            make.top.equalTo(self.containerView).offset(24);
            make.height.mas_equalTo(28);
        }];
        [self.monthUpTrend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.containerView).offset(-12);
            make.top.equalTo(self.containerView).offset(12);
            make.size.mas_equalTo(CGSizeMake(70, 70));
        }];
        [self.monthUpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.monthUp.mas_right).offset(2);
            make.bottom.equalTo(self.priceLabel);
        }];
        [self.monthUp mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.priceLabel.mas_right).offset(8);
            make.bottom.equalTo(self.priceLabel);
        }];
        [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.priceLabel.mas_bottom).offset(2);
            make.left.equalTo(self.priceLabel);
            make.bottom.equalTo(self.containerView).offset(-23);
        }];
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.monthUpLabel);
            make.left.equalTo(self.monthUpLabel.mas_right).offset(4);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
    }
    return self;
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [[UIView alloc]init];
        [self addSubview: containerView];
        _containerView = containerView;
    }
    return _containerView;
}
- (YYLabel *)priceLabel {
    if (!_priceLabel) {
        YYLabel *priceLabel = [[YYLabel alloc] init];
        [self.containerView addSubview:priceLabel];
        _priceLabel = priceLabel;
    }
    return _priceLabel;
}

- (UILabel *)monthUp {
    if (!_monthUp) {
        UILabel *monthUp = [UILabel createLabel:@"比上月涨" textColor:@"" fontSize:14];
        monthUp.textColor = [UIColor themeGray1];
        monthUp.font = [UIFont themeFontRegular:14];
        [self.containerView addSubview:monthUp];
        _monthUp = monthUp;
    }
    return _monthUp;
}

- (UILabel *)monthUpLabel {
    if (!_monthUpLabel) {
        UILabel *monthUpLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        monthUpLabel.textColor = [UIColor themeGray1];
        monthUpLabel.font = [UIFont themeFontMedium:14];
        [self.containerView addSubview:monthUpLabel];
        _monthUpLabel = monthUpLabel;
    }
    return _monthUpLabel;
}

- (UILabel *)subLabel {
    if (!_subLabel) {
        UILabel *subLabel = [UILabel createLabel:@"%" textColor:@"" fontSize:14];
        subLabel.textColor = [UIColor themeGray3];
        subLabel.font = [UIFont themeFontRegular:14];
        [self.containerView addSubview:subLabel];
        _subLabel = subLabel;
    }
    return _subLabel;
}

- (UIImageView *)monthUpTrend {
    if (!_monthUpTrend) {
        UIImageView *monthUpTrend = [[UIImageView alloc]init];
        monthUpTrend.image = [UIImage imageNamed:@"price_plot_up"];
        [self.containerView addSubview:monthUpTrend];
        _monthUpTrend = monthUpTrend;
    }
    return  _monthUpTrend;
}

- (UIImageView *)arrowImageView{
    if(!_arrowImageView){
        UIImageView *iamgeView = [[UIImageView alloc]init];
        iamgeView.image = [UIImage imageNamed:@"arrow_right"];
        _arrowImageView = iamgeView;
        [self.containerView addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

@end


@implementation FHNeighborhoodDetailSubMessageModel

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}


@end
