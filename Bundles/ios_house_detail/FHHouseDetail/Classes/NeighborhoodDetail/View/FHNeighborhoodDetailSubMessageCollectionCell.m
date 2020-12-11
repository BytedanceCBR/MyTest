//
//  FHNeighborhoodDetailSubMessageCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailSubMessageCollectionCell.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHNeighborhoodDetailSubMessageCollectionCell ()
@property (nonatomic, weak) YYLabel *priceLabel;
@property (nonatomic, strong) UILabel *monthUp;
@property (nonatomic, strong) UILabel *subLabel;
@property (nonatomic, weak) UILabel  *monthUpLabel;
@property (nonatomic, weak) UIImageView *monthUpTrend;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *jumpAveragePrice;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIImageView *bacImageView;


@property (nonatomic, strong) UIView *sepLine;
@property (nonatomic, strong) UIView *midLine;
@property (nonatomic, strong) UIButton *jumpSold;
@property (nonatomic, strong) UIButton *jumpOnSale;
@property (nonatomic, strong) UILabel *soldTitleLab;
@property (nonatomic, strong) UILabel *onSaleTitleLab;
@property (nonatomic, strong) UILabel *soldValue;
@property (nonatomic, strong) UILabel *onSaleValue;
@property (nonatomic, strong) UILabel *soldUnit;
@property (nonatomic, strong) UILabel *onSaleUnit;
@property (nonatomic, strong) UIImageView *arrowOnSaleImageView;
@property (nonatomic, strong) UIImageView *arrowSoldImageView;

@end

@implementation FHNeighborhoodDetailSubMessageCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailSubMessageModel class]]) {
        CGFloat height = 94 + 52;
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
        
        
        self.onSaleTitleLab.text = @"在售房源";
        self.soldTitleLab.text = @"成交房源";
        self.soldUnit.text = @"套";
        self.onSaleUnit.text = @"套";
        if([model.sold isEqualToString:@"暂无数据"]){
            self.soldValue.font =  [UIFont themeFontMedium:14];
            self.soldUnit.hidden = YES;
            self.arrowSoldImageView.hidden = YES;
        }
        if([model.onSale isEqualToString:@"暂无数据"]){
            self.onSaleValue.font =  [UIFont themeFontMedium:14];
            self.onSaleUnit.hidden = YES;
            self.arrowOnSaleImageView.hidden = YES;
        }
        self.soldValue.text = model.sold;
        self.onSaleValue.text = model.onSale;
    }
}

- (void)bindViewModel:(id)viewModel {
    [self refreshWithData:viewModel];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.bacImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(12);
            make.left.bottom.right.mas_equalTo(self.contentView);
        }];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self.contentView);
            make.height.mas_equalTo(94);
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
        }];
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.monthUpLabel);
            make.left.equalTo(self.monthUpLabel.mas_right).offset(4);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        [self.sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView.mas_bottom);
            make.height.mas_equalTo([UIDevice btd_onePixel]);
            make.left.equalTo(self.contentView).offset(12);
            make.right.equalTo(self.contentView).offset(-12);
        }];
        [self.midLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.sepLine).offset(16);
            make.bottom.mas_equalTo(self.contentView).offset(-16);
            make.centerX.mas_equalTo(self.contentView);
            make.width.mas_equalTo([UIDevice btd_onePixel]);
        }];
        
        [self.soldTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(12);
            make.centerY.mas_equalTo(self.midLine);
        }];
        
        [self.soldValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.soldTitleLab.mas_right).offset(8);
            make.centerY.mas_equalTo(self.midLine);
        }];
        
        [self.soldUnit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.soldValue.mas_right).offset(8);
            make.centerY.mas_equalTo(self.midLine);
        }];
        
        [self.onSaleUnit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).offset(-30);
            make.centerY.mas_equalTo(self.midLine);
        }];
        
        [self.onSaleValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.onSaleUnit.mas_left).offset(-8);
            make.centerY.mas_equalTo(self.midLine);
        }];
        
        [self.onSaleTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.onSaleValue.mas_left).offset(-8);
            make.centerY.mas_equalTo(self.midLine);
        }];
        
        [self.arrowOnSaleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.midLine);
            make.right.mas_equalTo(self.contentView).offset(-12);
        }];
        
        [self.arrowSoldImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.midLine);
            make.left.mas_equalTo(self.soldUnit.mas_right).offset(8);
        }];
        
        [self.jumpAveragePrice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.containerView);
        }];
        
        [self.jumpSold mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.sepLine);
            make.bottom.left.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.midLine);
        }];
        
        [self.jumpOnSale mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.sepLine);
            make.bottom.right.mas_equalTo(self.contentView);
            make.left.mas_equalTo(self.midLine);
        }];
    }
    return self;
}

- (void)clickAveragePrice:(UIButton *)btn {
    if(self.clickAveragePriceblock){
        self.clickAveragePriceblock();
    }
}

- (UIButton *)jumpAveragePrice{
    if(!_jumpAveragePrice){
        UIButton *bt = [[UIButton alloc]init];
        [self.contentView addSubview:bt];
        [bt addTarget:self action:@selector(clickAveragePrice:) forControlEvents:UIControlEventTouchUpInside];
        _jumpAveragePrice = bt;
    }
    return _jumpAveragePrice;
}

- (void)clickSold:(UIButton *)btn {
    if(self.clickSoldblock){
        self.clickSoldblock();
    }
}

- (UIButton *)jumpSold{
    if(!_jumpSold){
        UIButton *bt = [[UIButton alloc]init];
        [self.contentView addSubview:bt];
        [bt addTarget:self action:@selector(clickSold:) forControlEvents:UIControlEventTouchUpInside];
        _jumpSold = bt;
    }
    return _jumpSold;
}

- (void)clickOnSale:(UIButton *)btn {
    if(self.clickOnSaleblock){
        self.clickOnSaleblock();
    }
}

- (UIButton *)jumpOnSale{
    if(!_jumpOnSale){
        UIButton *bt = [[UIButton alloc]init];
        [self.contentView addSubview:bt];
        [bt addTarget:self action:@selector(clickOnSale:) forControlEvents:UIControlEventTouchUpInside];
        _jumpOnSale = bt;
    }
    return _jumpOnSale;
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

- (UIImageView *)bacImageView{
    if(!_bacImageView){
        UIImageView *iamgeView = [[UIImageView alloc] init];
        iamgeView.image = [UIImage imageNamed:@"neigborhood_header_backView"];
        [self.contentView addSubview:iamgeView];
        _bacImageView = iamgeView;
    }
    return _bacImageView;
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

- (UIView *)midLine{
    if(!_midLine){
        UIView *midLine = [[UIView alloc] init];
        midLine.backgroundColor = [UIColor themeGray6];
        [self.contentView addSubview:midLine];
        _midLine = midLine;
    }
    return _midLine;
}

- (UIView *)sepLine{
    if(!_sepLine){
        UIView *sepLine = [[UIView alloc] init];
        sepLine.backgroundColor = [UIColor themeGray6];
        [self.contentView addSubview:sepLine];
        _sepLine = sepLine;
    }
    return _sepLine;
}

- (UIImageView *)arrowOnSaleImageView{
    if(!_arrowOnSaleImageView){
        UIImageView *iamgeView = [[UIImageView alloc]init];
        iamgeView.image = [UIImage imageNamed:@"arrow_right"];
        _arrowOnSaleImageView = iamgeView;
        [self.contentView addSubview:_arrowOnSaleImageView];
    }
    return _arrowOnSaleImageView;
}

- (UIImageView *)arrowSoldImageView{
    if(!_arrowSoldImageView){
        UIImageView *iamgeView = [[UIImageView alloc]init];
        iamgeView.image = [UIImage imageNamed:@"arrow_right"];
        _arrowSoldImageView = iamgeView;
        [self.contentView addSubview:_arrowSoldImageView];
    }
    return _arrowSoldImageView;
}

- (UILabel *)onSaleUnit{
    if(!_onSaleUnit){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:soldTitleLab];
        _onSaleUnit = soldTitleLab;
    }
    return _onSaleUnit;
}

- (UILabel *)soldUnit{
    if(!_soldUnit){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:soldTitleLab];
        _soldUnit = soldTitleLab;
    }
    return _soldUnit;
}

- (UILabel *)onSaleValue{
    if(!_onSaleValue){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontMedium:20];
        [self.contentView addSubview:soldTitleLab];
        _onSaleValue = soldTitleLab;
    }
    return _onSaleValue;
}

- (UILabel *)soldValue{
    if(!_soldValue){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontMedium:20];
        [self.contentView addSubview:soldTitleLab];
        _soldValue = soldTitleLab;
    }
    return _soldValue;
}

- (UILabel *)soldTitleLab{
    if(!_soldTitleLab){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:soldTitleLab];
        _soldTitleLab = soldTitleLab;
    }
    return _soldTitleLab;
}

- (UILabel *)onSaleTitleLab{
    if(!_onSaleTitleLab){
        UILabel *soldTitleLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        soldTitleLab.textColor = [UIColor themeGray1];
        soldTitleLab.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:soldTitleLab];
        _onSaleTitleLab = soldTitleLab;
    }
    return _onSaleTitleLab;
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
