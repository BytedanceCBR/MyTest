//
//  FHPriceValuationResultView.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import "FHPriceValuationResultView.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import <PNChart.h>
#import "TTDeviceHelper.h"
#import "UIView+House.h"
#import "FHDetailPriceMarkerView.h"
#import "FHEnvContext.h"

@interface FHPriceValuationResultView()<PNChartDelegate>

@property(nonatomic, assign) CGFloat naviBarHeight;
@property(nonatomic, strong) UIImageView *headerImageView;
@property(nonatomic, strong) UIView *cardView;
@property(nonatomic, strong) UIButton *titleBtn;
@property(nonatomic, strong) UILabel *priceLabel;
@property(nonatomic, strong) UILabel *avgPriceLabel;
@property(nonatomic, strong) UILabel *toLastMonthLabel;
@property(nonatomic, strong) UIView *middleSpLine;
@property(nonatomic, strong) UIButton *moreInfoBtn;
@property(nonatomic, strong) UIView *evaluateView;
@property(nonatomic, strong) UILabel *evaluateLabel;
@property(nonatomic, strong) UIButton *evaluateDownBtn;
@property(nonatomic, strong) UIButton *evaluateJustBtn;
@property(nonatomic, strong) UIButton *evaluateUpBtn;
@property(nonatomic, strong) UIView *chartBgView;
@property(nonatomic, strong) UILabel *chartNameLabel;
@property(nonatomic, strong) UILabel *chartPriceLabel;
@property(nonatomic, strong) UIView *chartTitleView;
@property(nonatomic, strong) PNLineChart *chartView;
@property(nonatomic, strong) UIView *descView;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIView *bottomView;
@property(nonatomic, strong) UIButton *bottomBtn;
@property(nonatomic, strong) UIView *spLineView;
@property(nonatomic, strong) UIButton *cityMarketBtn;

@property(nonatomic, assign) double unitPerSquare;
@property(nonatomic, assign) double maxValue;
@property(nonatomic, assign) double minValue;
@property(nonatomic, strong) NSDateFormatter *monthFormatter;
@property(nonatomic, assign) NSInteger selectIndex;
@property(nonatomic, assign) BOOL hideMarker;
@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel *> *priceTrends;

@end

@implementation FHPriceValuationResultView

- (instancetype)initWithFrame:(CGRect)frame naviBarHeight:(CGFloat)naviBarHeight {
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        self.naviBarHeight = naviBarHeight;
        [self initViews];
        [self initConstraints];
        self.unitPerSquare = 100 * 10000.0;
    }
    return self;
}

- (void)initViews {
    self.scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:_scrollView];
    
    self.headerImageView = [[UIImageView alloc] init];
    _headerImageView.image = [UIImage imageNamed:@"price_valuation_result_header_image"];
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:_headerImageView];
    
    self.evaluateView = [[UIView alloc] init];
    _evaluateView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_evaluateView];
    
    self.chartBgView = [[UIView alloc] init];
    _chartBgView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_chartBgView];
    
    self.cardView = [[UIView alloc] init];
    _cardView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_cardView];
    
    self.titleBtn = [[UIButton alloc] init];
    [_titleBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [_titleBtn setImage:[UIImage imageNamed:@"setting-arrow"] forState:UIControlStateNormal];
    _titleBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [_titleBtn addTarget:self action:@selector(goToNeiborhoodDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:_titleBtn];

    self.priceLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeRed1]];
    [self.cardView addSubview:_priceLabel];
    
    self.middleSpLine = [[UIView alloc] init];
    _middleSpLine.backgroundColor = [UIColor themeGray6];
    [self.cardView addSubview:_middleSpLine];
    
    CGFloat fontSize = CGRectGetWidth([UIScreen mainScreen].bounds) > 320 ? 14 : 11;
    self.avgPriceLabel = [self LabelWithFont:[UIFont themeFontRegular:fontSize] textColor:[UIColor themeGray3]];
    _avgPriceLabel.textAlignment = NSTextAlignmentRight;
    [self.cardView addSubview:_avgPriceLabel];
    
    self.toLastMonthLabel = [self LabelWithFont:[UIFont themeFontRegular:fontSize] textColor:[UIColor themeGray3]];
    _toLastMonthLabel.textAlignment = NSTextAlignmentLeft;
    [self.cardView addSubview:_toLastMonthLabel];
    
    self.moreInfoBtn = [[UIButton alloc] init];
    _moreInfoBtn.backgroundColor = [UIColor themeRed1];
    [_moreInfoBtn setTitle:@"补全信息，结果更精确" forState:UIControlStateNormal];
    [_moreInfoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _moreInfoBtn.titleLabel.font = [UIFont themeFontRegular:16];
    _moreInfoBtn.layer.cornerRadius = 4;
    _moreInfoBtn.layer.masksToBounds = YES;
    [_moreInfoBtn addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:_moreInfoBtn];

    self.evaluateLabel = [self LabelWithFont:[UIFont themeFontMedium:18] textColor:[UIColor themeGray1]];
    _evaluateLabel.text = @"估价结果是否符合您的预期？";
    [self.evaluateView addSubview:_evaluateLabel];
    
    self.evaluateDownBtn = [[UIButton alloc] init];
    _moreInfoBtn.backgroundColor = [UIColor themeRed1];
    [_moreInfoBtn setTitle:@"补全信息，结果更精确" forState:UIControlStateNormal];
    [_moreInfoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _moreInfoBtn.titleLabel.font = [UIFont themeFontRegular:16];
    _moreInfoBtn.layer.cornerRadius = 4;
    _moreInfoBtn.layer.masksToBounds = YES;
    [_moreInfoBtn addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:_moreInfoBtn];
    
    self.evaluateDownBtn = [self buttonWithText:@"比预期低" imageName:@"price_valuation_down" tag:3];
    [self.evaluateView addSubview:_evaluateDownBtn];
    
    self.evaluateJustBtn = [self buttonWithText:@"符合预期" imageName:@"price_valuation_just" tag:2];
    [self.evaluateView addSubview:_evaluateJustBtn];
    
    self.evaluateUpBtn = [self buttonWithText:@"比预期高" imageName:@"price_valuation_up" tag:1];
    [self.evaluateView addSubview:_evaluateUpBtn];
    
    self.spLineView = [[UIView alloc] init];
    _spLineView.backgroundColor = [UIColor themeGray7];
    [self.evaluateView addSubview:_spLineView];
    
    self.chartNameLabel = [self LabelWithFont:[UIFont themeFontMedium:18] textColor:[UIColor themeGray1]];
    _chartNameLabel.text = @"房价走势";
    [self.chartBgView addSubview:_chartNameLabel];
    
    self.cityMarketBtn = [[UIButton alloc] init];
    [_cityMarketBtn setTitleColor:[UIColor themeGray2] forState:UIControlStateNormal];
    [_cityMarketBtn setImage:[UIImage imageNamed:@"setting-arrow"] forState:UIControlStateNormal];
    _cityMarketBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_cityMarketBtn addTarget:self action:@selector(goToCityMarket) forControlEvents:UIControlEventTouchUpInside];
    [_cityMarketBtn setTitle:@"查看全城房价走势" forState:UIControlStateNormal];
    [_cityMarketBtn sizeToFit];
    [_cityMarketBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, - _cityMarketBtn.imageView.image.size.width, 0, _cityMarketBtn.imageView.image.size.width)];
    [_cityMarketBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _cityMarketBtn.titleLabel.bounds.size.width, 0, -_cityMarketBtn.titleLabel.bounds.size.width)];
    [self.chartBgView addSubview:_cityMarketBtn];
    //由config控制这个按钮是否显示
    _cityMarketBtn.hidden = ![FHEnvContext isPriceValuationShowHouseTrend];
    
    self.chartPriceLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    [self.chartBgView addSubview:_chartPriceLabel];
    
    self.chartTitleView = [[UIView alloc] init];
    [self.chartBgView addSubview:_chartTitleView];
    
    self.chartView = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 207.0)];
    _chartView.backgroundColor = [UIColor whiteColor];
    [self.chartBgView addSubview:_chartView];
    
    [self setupChartUI];
    
    self.descView = [[UIView alloc] init];
    _descView.backgroundColor = [UIColor themeGray7];
    [self.scrollView addSubview:_descView];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:11] textColor:[UIColor themeGray4]];
    _descLabel.textAlignment = NSTextAlignmentCenter;
    _descLabel.numberOfLines = 0;
    _descLabel.backgroundColor = [UIColor themeGray7];
    _descLabel.text = @"基于幸福里APP海量二手房挂牌和成交大数据，综合市场行情和房屋信息，预估房屋市场价值，仅供参考";
    [self.descView addSubview:_descLabel];
    
    self.bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bottomView];
    
    self.bottomBtn = [[UIButton alloc] init];
    _bottomBtn.backgroundColor = [UIColor themeRed1];
    [_bottomBtn setTitle:@"我要卖房" forState:UIControlStateNormal];
    [_bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _bottomBtn.titleLabel.font = [UIFont themeFontRegular:16];
    _bottomBtn.layer.cornerRadius = 4;
    _bottomBtn.layer.masksToBounds = YES;
    [_bottomBtn addTarget:self action:@selector(houseSale) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:_bottomBtn];
}

- (void)initConstraints {
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(self.naviBarHeight - 64 - 224);
        make.left.mas_equalTo(self.scrollView);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(448);
    }];
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(30 + self.naviBarHeight);
        make.left.mas_equalTo(self.scrollView).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(187);
    }];
    
    [self.titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cardView).offset(22);
        make.centerX.mas_equalTo(self.cardView);
        make.width.mas_lessThanOrEqualTo([UIScreen mainScreen].bounds.size.width - 70);
        make.height.mas_equalTo(22);
    }];

    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleBtn.mas_bottom).offset(11);
        make.centerX.mas_equalTo(self.cardView);
        make.width.mas_lessThanOrEqualTo([UIScreen mainScreen].bounds.size.width - 70);
        make.height.mas_equalTo(30);
    }];
    
    [self.middleSpLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(17);
        make.centerX.mas_equalTo(self.cardView);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(16);
    }];

    [self.avgPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.middleSpLine);
        make.left.mas_equalTo(self.cardView).offset(15);
        make.right.mas_equalTo(self.middleSpLine).offset(-15);
        make.height.mas_equalTo(30);
    }];

    [self.toLastMonthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.middleSpLine);
        make.left.mas_equalTo(self.middleSpLine).offset(15);
        make.right.mas_equalTo(self.cardView).offset(-15);
        make.height.mas_equalTo(30);
    }];

    [self.moreInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avgPriceLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.cardView).offset(15);
        make.right.mas_equalTo(self.cardView).offset(-15);
        make.height.mas_equalTo(44);
    }];
    
    [self.evaluateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cardView.mas_bottom);
        make.left.mas_equalTo(self.scrollView);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(128);
    }];

    [self.evaluateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.evaluateView).offset(20);
        make.left.mas_equalTo(self.evaluateView).offset(20);
        make.right.mas_equalTo(self.evaluateView).offset(-20);
        make.height.mas_equalTo(25);
    }];

    CGFloat btnWidth = ([UIScreen mainScreen].bounds.size.width - 60)/3;
    
    [self.evaluateJustBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.evaluateLabel.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(36);
    }];
    
    [self.evaluateDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.evaluateJustBtn);
        make.right.mas_equalTo(self.evaluateJustBtn.mas_left).offset(-10);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(36);
    }];
    
    [self.evaluateUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.evaluateJustBtn);
        make.left.mas_equalTo(self.evaluateJustBtn.mas_right).offset(10);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(36);
    }];
    
    [self.spLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.evaluateView);
        make.height.mas_equalTo(10);
    }];
    
    [self.chartBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.spLineView.mas_bottom);
        make.left.mas_equalTo(self.scrollView);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(322);
    }];
    
    [self.chartNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.chartBgView).offset(22);
        make.left.mas_equalTo(self.chartBgView).offset(20);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(25);
    }];
    
    [self.cityMarketBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.chartNameLabel);
        make.right.mas_equalTo(self.chartBgView).offset(-20);
        make.height.mas_equalTo(20);
    }];
    
    [self.chartPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.chartNameLabel.mas_bottom).offset(21);
        make.left.mas_equalTo(self.chartBgView).offset(20);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    [self.chartTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.chartBgView).offset(70);
        make.centerY.mas_equalTo(self.chartPriceLabel);
        make.height.mas_equalTo(20);
    }];
    
    [self.chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.chartPriceLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.chartBgView);
        make.right.mas_equalTo(self.chartBgView);
        make.height.mas_equalTo(207);
    }];
    
    [self.descView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.chartBgView.mas_bottom);
        make.left.mas_equalTo(self.scrollView);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(52);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.descView);
        make.left.mas_equalTo(self.scrollView).offset(20);
        make.right.mas_equalTo(self).offset(-20);
    }];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];

    CGFloat bottom = 64;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(bottom);
    }];
    
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView).offset(10);
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(44);
    }];

    [self layoutIfNeeded];
    [self addShadowToView:self.cardView withOpacity:0.1 shadowRadius:8 andCornerRadius:4];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (UIButton *)buttonWithText:(NSString *)text imageName:(NSString *)imageName tag:(NSInteger)tag {
    UIButton *btn = [[UIButton alloc] init];
    btn.tag = tag;
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor themeRed3] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont themeFontRegular:14];
    btn.layer.cornerRadius = 4;
    btn.layer.masksToBounds = YES;
    btn.layer.borderColor = [[UIColor themeRed3] CGColor];
    btn.layer.borderWidth = 1;
    [btn addTarget:self action:@selector(evaluate:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

/*
 周边加阴影，并且同时圆角，注意这个方法必须在view已经布局完成能够获得frame的情况下使用
 */
- (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius {
    //////// shadow /////////
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.frame = view.layer.frame;
    
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    shadowLayer.shadowOffset = CGSizeMake(2, 6);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    shadowLayer.shadowOpacity = shadowOpacity;//0.8;//阴影透明度，默认0
    shadowLayer.shadowRadius = shadowRadius;//8;//阴影半径，默认3
    
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float width = shadowLayer.bounds.size.width;
    float height = shadowLayer.bounds.size.height;
    float x = shadowLayer.bounds.origin.x;
    float y = shadowLayer.bounds.origin.y;
    
    CGPoint topLeft      = shadowLayer.bounds.origin;
    CGPoint topRight     = CGPointMake(x + width, y);
    CGPoint bottomRight  = CGPointMake(x + width, y + height);
    CGPoint bottomLeft   = CGPointMake(x, y + height);
    
    CGFloat offset = -1.f;
    [path moveToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    [path addArcWithCenter:CGPointMake(topLeft.x + cornerRadius, topLeft.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(topRight.x - cornerRadius, topRight.y - offset)];
    [path addArcWithCenter:CGPointMake(topRight.x - cornerRadius, topRight.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 * 3 endAngle:M_PI * 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomRight.x + offset, bottomRight.y - cornerRadius)];
    [path addArcWithCenter:CGPointMake(bottomRight.x - cornerRadius, bottomRight.y - cornerRadius) radius:(cornerRadius + offset) startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y + offset)];
    [path addArcWithCenter:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y - cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    
    //设置阴影路径
    shadowLayer.shadowPath = path.CGPath;
    
    //////// cornerRadius /////////
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [view.superview.layer insertSublayer:shadowLayer below:view.layer];
}

- (void)updateView:(FHPriceValuationEvaluateModel *)model infoModel:(FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *)infoModel {
    if(model){
        NSString *priceStr = [NSString stringWithFormat:@"%.0f",round([model.data.estimatePrice doubleValue]/self.unitPerSquare)];
        self.priceLabel.attributedText = [self getPriceStr:priceStr];
        self.avgPriceLabel.attributedText = [self getAtributeStr:@"房屋均价 " content:model.data.estimatePricingPersqmStr];
        self.toLastMonthLabel.attributedText = [self getAtributeStr:@"环比上月 " content:model.data.estimatePriceRateStr];
    }
    if(infoModel){
        [_titleBtn setTitle:infoModel.neighborhoodName forState:UIControlStateNormal];
        [_titleBtn sizeToFit];
        [_titleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, - _titleBtn.imageView.image.size.width, 0, _titleBtn.imageView.image.size.width)];
        [_titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _titleBtn.titleLabel.bounds.size.width, 0, -_titleBtn.titleLabel.bounds.size.width)];
    }
}

- (void)updateChart:(FHDetailNeighborhoodModel *)detailModel {
    self.priceTrends = detailModel.data.priceTrend;
}

- (void)hideEvaluateView {
    self.evaluateView.hidden = YES;
    [self.evaluateView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    [self layoutIfNeeded];
    //当内容高度不足时，让描述文字贴近底部按钮
    CGFloat height = self.scrollView.contentSize.height;
    CGFloat scrollViewHeight = self.scrollView.frame.size.height;
    if(scrollViewHeight > height){
        CGFloat diff = scrollViewHeight - height;
        [self.descView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.chartBgView.mas_bottom).offset(diff);
        }];
    }
}

- (NSAttributedString *)getAtributeStr:(NSString *)title content:(NSString *)content {
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:title];
    if(content){
        NSAttributedString *contentAstr = [[NSAttributedString alloc] initWithString:content attributes:@{NSForegroundColorAttributeName:[UIColor themeGray1]}];
        [aStr appendAttributedString:contentAstr];
    }
    return aStr;
}

- (NSAttributedString *)getPriceStr:(NSString *)price {
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] init];
    if(price){
        NSAttributedString *priceAstr = [[NSAttributedString alloc] initWithString:price attributes:@{NSFontAttributeName:[UIFont themeFontDINAlternateBold:26]}];
        [aStr appendAttributedString:priceAstr];
        NSAttributedString *unitAstr = [[NSAttributedString alloc] initWithString:@"万" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:14]}];
        [aStr appendAttributedString:unitAstr];
    }
    return aStr;
}

- (NSDateFormatter *)monthFormatter {
    if (!_monthFormatter) {
        _monthFormatter = [[NSDateFormatter alloc]init];
        _monthFormatter.dateFormat = @"M月";
    }
    return _monthFormatter;
}

- (void)setupChartUI {
    self.chartView.yLabelNum = 4; // 4 lines
    self.chartView.chartMarginLeft = 20;
    self.chartView.chartMarginRight = 20;
    self.chartView.backgroundColor = [UIColor whiteColor];
    self.chartView.yGridLinesColor = [UIColor themeGray6];
    self.chartView.showYGridLines = YES; // 横着的虚线
    [self.chartView.chartData enumerateObjectsUsingBlock:^(PNLineChartData *obj, NSUInteger idx, BOOL *stop) {
        obj.pointLabelColor = [UIColor blackColor];
    }];
    self.chartView.showCoordinateAxis = YES;// 坐标轴的线
    self.chartView.yLabelColor = [UIColor themeGray3];
    self.chartView.yLabelFormat = @"%.2f";
    self.chartView.yLabelFont = [UIFont themeFontRegular:12];
    self.chartView.yLabelHeight = 17;
    self.chartView.showGenYLabels = YES; // 竖轴的label值
    self.chartView.xLabelColor = [UIColor themeGray3];
    self.chartView.xLabelFont = [UIFont themeFontRegular:12];
    self.chartView.yHighlightedColor = [UIColor themeRed1];
    self.chartView.axisColor = [UIColor themeGray6]; // x轴和y轴
    [self.chartView setXLabels:@[@"", @"", @"", @"", @"", @""]];
    
    self.chartView.delegate = self;
}

- (void)setUnitPerSquare:(double)unitPerSquare {
    _unitPerSquare = unitPerSquare;
    if (unitPerSquare >= 100 * 10000) {
        self.chartPriceLabel.text = @"万元/平";
        self.chartView.yLabelFormat = @"%.2f";
    }else {
        self.chartPriceLabel.text = @"元/平";
        self.chartView.yLabelFormat = @"%1.f";
    }
}

- (void)setPriceTrends:(NSArray<FHDetailPriceTrendModel *> *)priceTrends {
    _priceTrends = priceTrends;
    if (priceTrends.count < 1) {
        return;
    }
    CGFloat trailing = [UIScreen mainScreen].bounds.size.width - 20 - 70;
    CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 14 : 12;
    for (UIView *subview in self.chartTitleView.subviews) {
        [subview removeFromSuperview];
    }
    FHDetailPriceTrendModel *maxPriceTrend = priceTrends.firstObject;
    FHDetailPriceTrendValuesModel *value = maxPriceTrend.values.firstObject;
    double maxValue = value.price.length > 0 ? value.price.doubleValue : 0;
    double minValue = maxValue;
    
    for (NSInteger index = priceTrends.count - 1; index >= 0; index--) {
        FHDetailPriceTrendModel *priceTrend = priceTrends[index];
        if (priceTrend.values.count > maxPriceTrend.values.count) {
            maxPriceTrend = priceTrend;
        }
        NSString *trendName = priceTrend.name;
        if (trendName.length > 7) {
            trendName = [NSString stringWithFormat:@"%@...",[trendName substringToIndex:7]];
        }
        UIView *icon = [[UIView alloc]init];
        icon.width = 8;
        icon.height = 8;
        icon.layer.cornerRadius = 4;
        icon.layer.masksToBounds = YES;
        icon.backgroundColor = [self lineColorByIndex:index];
        [self.chartTitleView addSubview:icon];
        
        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont themeFontRegular:fontSize];
        label.textColor = [UIColor themeGray1];
        label.text = trendName;
        [self.chartTitleView addSubview:label];
        
        [label sizeToFit];
        label.left = trailing - label.width;
        label.height = 20;
        label.top = 0;
        trailing = label.left - 10;
        
        icon.left = trailing - icon.width;
        icon.centerY = label.centerY;
        trailing = icon.left - 20;
        
        for (FHDetailPriceTrendValuesModel *value in priceTrend.values) {
            if (value.price.doubleValue > maxValue) {
                maxValue = value.price.doubleValue;
            }
            if (value.price.doubleValue < minValue) {
                minValue = value.price.doubleValue;
            }
        }
        
    }
    // 处理最大最小值
    self.maxValue = maxValue;
    self.minValue = minValue;
    if (self.maxValue >= 100 * 10000.0) {
        self.unitPerSquare = 100.0 * 10000.0;
    }else {
        self.unitPerSquare = 100.0;
    }
    NSMutableArray *mutable = @[].mutableCopy;
    
    for (NSInteger index = priceTrends.count - 1; index >= 0; index--) {
        FHDetailPriceTrendModel *priceTrend = priceTrends[index];
        NSArray *data01Array = priceTrend.values;
        PNLineChartData *data01 = [PNLineChartData new];
        data01.color = [self lineColorByIndex:index];
        data01.highlightedImg = [self highlightImgNameByIndex:index];
        data01.alpha = 1;
        data01.showPointLabel = NO; // 是否显示坐标点的值
        data01.itemCount = data01Array.count;
        data01.inflexionPointColor = [self lineColorByIndex:index];
        data01.inflexionPointStyle = PNLineChartPointStyleCircle;
        data01.lineWidth = 1;
        data01.inflexionPointWidth = 4; // inflexionPoint 圆圈圈
        data01.pointLabelFormat = @"%.2f";
        __weak typeof(self)wself = self;
        data01.getData = ^(NSUInteger index) {
            if (index < data01Array.count) {
                FHDetailPriceTrendValuesModel *trendValue = data01Array[index];
                CGFloat yValue = trendValue.price.floatValue / wself.unitPerSquare;
                return [PNLineChartDataItem dataItemWithY:yValue andRawY:yValue];
            }
            return [PNLineChartDataItem dataItemWithY:0];
        };
        [mutable addObject:data01];
    }
    
    CGFloat padding = (self.maxValue - self.minValue) / self.unitPerSquare / 16;
    self.chartView.yFixedValueMax = self.maxValue / self.unitPerSquare - padding;
    self.chartView.yFixedValueMin = self.minValue / self.unitPerSquare - padding;
    self.chartView.chartData = mutable;
    [self.chartView strokeChart];
    
    NSMutableArray *Xlabels = @[].mutableCopy;
    for (FHDetailPriceTrendValuesModel *trendValue in maxPriceTrend.values) {
        NSString *monthStr = [self.monthFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:trendValue.timestamp.doubleValue]];
        [Xlabels addObject:monthStr];
    }
    [self.chartView setXLabels:Xlabels];
}

- (UIColor *)lineColorByIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return [UIColor themeRed1];
            break;
        case 1:
            return [UIColor colorWithHexString:@"#bebebe"];
            break;
        case 2:
            return [UIColor themeGray5];
            break;
        default:
            return [UIColor themeGray5];
            break;
    }
}

- (NSString *)highlightImgNameByIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"detail_circle_red";
            break;
        case 1:
            return @"detail_circle_dark";
            break;
        case 2:
            return @"detail_circle_gray";
            break;
        default:
            return @"detail_circle_gray";
            break;
    }
}

#pragma mark delegate
- (void)addClickPriceTrendLog {
//    NSMutableDictionary *params = @{}.mutableCopy;
//    NSDictionary *traceDict = [self.baseViewModel detailTracerDic];
//    params[@"page_type"] = traceDict[@"page_type"] ? : @"be_null";
//    params[@"rank"] = traceDict[@"rank"] ? : @"be_null";
//    params[@"origin_from"] = traceDict[@"origin_from"] ? : @"be_null";
//    params[@"origin_search_id"] = traceDict[@"origin_search_id"] ? : @"be_null";
//    params[@"log_pb"] = traceDict[@"log_pb"] ? : @"be_null";
//    [FHUserTracker writeEvent:@"click_price_trend" params:params];
}

- (void)addClickPriceRankLog {
//    NSMutableDictionary *params = @{}.mutableCopy;
//    NSDictionary *traceDict = [self.baseViewModel detailTracerDic];
//    params[@"page_type"] = traceDict[@"page_type"] ? : @"be_null";
//    params[@"rank"] = traceDict[@"rank"] ? : @"be_null";
//    params[@"origin_from"] = traceDict[@"origin_from"] ? : @"be_null";
//    params[@"origin_search_id"] = traceDict[@"origin_search_id"] ? : @"be_null";
//    params[@"log_pb"] = traceDict[@"log_pb"] ? : @"be_null";
//    [FHUserTracker writeEvent:@"click_price_rank" params:params];
}

- (void)userClickedOnKeyPoint:(CGPoint)point
                    lineIndex:(NSInteger)lineIndex
                   pointIndex:(NSInteger)pointIndex
                  selectPoint:(CGPoint)selectPoint {
    [self addClickPriceTrendLog];
    
//    self.cha
    FHDetailPriceMarkerView *view = [self.chartView viewWithTag:200];
    if (pointIndex == self.selectIndex && self.hideMarker) {
        [view removeFromSuperview];
        view = nil;
        self.hideMarker = NO;
        return;
    }
    self.selectIndex = pointIndex;
    self.hideMarker = YES;
    
    if (!view) {
        view = [[FHDetailPriceMarkerView alloc]init];
        view.tag = 200;
        [self.chartView addSubview:view];
    }
    if (![view isKindOfClass:[FHDetailPriceMarkerView class]]) {
        return;
    }
    FHDetailPriceMarkerData *markData = [[FHDetailPriceMarkerData alloc]init];
    NSArray *priceTrends = self.priceTrends;
    if (priceTrends.count < 1) {
        return;
    }
    NSMutableArray *trendItems = @[].mutableCopy;
    for (FHDetailPriceTrendModel *priceTrend in priceTrends) {
        if (priceTrend.values.count < 1 || pointIndex >= priceTrend.values.count) {
            continue;
        }
        FHDetailPriceTrendValuesModel *priceValue = priceTrend.values[pointIndex];
        FHDetailPriceMarkerItem *item = [[FHDetailPriceMarkerItem alloc]init];
        item.name = priceTrend.name;
        item.priceModel = priceValue;
        [trendItems addObject:item];
    }
    markData.trendItems = trendItems;
    [view refreshContent:markData];
    //calculate markerview position
    CGFloat padding = 10;
    if (selectPoint.x + view.width + padding > self.chartView.width) {
        view.right = selectPoint.x - padding;
    }else{
        view.left = selectPoint.x + padding;
    }
    if (view.left < 0) {
        view.left = 0;
    }
    view.centerY = (self.chartView.height - 40) /2;
}

- (void)goToNeiborhoodDetail {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToNeiborhoodDetail)]){
        [self.delegate goToNeiborhoodDetail];
    }
}

- (void)moreInfo {
    if(self.delegate && [self.delegate respondsToSelector:@selector(moreInfo)]){
        [self.delegate moreInfo];
    }
}

- (void)evaluate:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger type = button.tag;
    if(self.delegate && [self.delegate respondsToSelector:@selector(evaluate:desc:)]){
        [self.delegate evaluate:type desc:button.titleLabel.text];
    }
}

- (void)houseSale {
    if(self.delegate && [self.delegate respondsToSelector:@selector(houseSale)]){
        [self.delegate houseSale];
    }
}

- (void)goToCityMarket {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToCityMarket)]){
        [self.delegate goToCityMarket];
    }
}

@end
