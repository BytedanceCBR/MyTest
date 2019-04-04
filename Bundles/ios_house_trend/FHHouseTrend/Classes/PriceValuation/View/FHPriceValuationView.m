//
//  FHPriceValuationView.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/19.
//

#import "FHPriceValuationView.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "FHUtils.h"

@interface FHPriceValuationView()

@property(nonatomic, strong) UIImageView *headerImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UIView *inputView;
@property(nonatomic, strong) UIButton *evaluateBtn;
@property(nonatomic, assign) CGFloat naviBarHeight;
@property(nonatomic, strong) YYLabel *agreementLabel;
@property(nonatomic, strong) UILabel *descLabel;

@end

@implementation FHPriceValuationView

- (instancetype)initWithFrame:(CGRect)frame naviBarHeight:(CGFloat)naviBarHeight {
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        self.naviBarHeight = naviBarHeight;
        [self initViews];
        [self initConstraints];
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
    _headerImageView.image = [UIImage imageNamed:@"price_valuation_header_image"];
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:_headerImageView];

    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:28] textColor:[UIColor whiteColor]];
    _titleLabel.text = @"我的房子值多少钱";
    [self.scrollView addSubview:_titleLabel];

    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor whiteColor]];
    _subTitleLabel.text = @"添加房屋信息，马上预估价格";
    [self.scrollView addSubview:_subTitleLabel];

    self.inputView = [[UIView alloc] init];
    [self.scrollView addSubview:_inputView];

    self.neiborhoodItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeNormal];
    _neiborhoodItemView.titleLabel.text = @"小区";
    _neiborhoodItemView.tapBlock = ^{
        [self goToNeighborhoodSearch];
    };
    [self.inputView addSubview:_neiborhoodItemView];

    self.areaItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeTextField];
    _areaItemView.titleLabel.text = @"面积";
    _areaItemView.textField.placeholder = @"请输入";
    _areaItemView.textField.keyboardType = UIKeyboardTypeDecimalPad;
    _areaItemView.rightText = @"m²";
    [self.inputView addSubview:_areaItemView];

    self.floorItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeNormal];
    _floorItemView.titleLabel.text = @"户型";
    _floorItemView.bottomLine.hidden = YES;
    _floorItemView.tapBlock = ^{
        [self chooseFloor];
    };
    [self.inputView addSubview:_floorItemView];

    self.evaluateBtn = [[UIButton alloc] init];
    _evaluateBtn.backgroundColor = [UIColor themeRed1];
    [_evaluateBtn setTitle:@"立即估价" forState:UIControlStateNormal];
    [_evaluateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _evaluateBtn.titleLabel.font = [UIFont themeFontRegular:16];
    _evaluateBtn.layer.cornerRadius = 4;
    _evaluateBtn.layer.masksToBounds = YES;
    [self setEvaluateBtnEnabled:NO];

    [_evaluateBtn addTarget:self action:@selector(evaluate) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_evaluateBtn];
    
    self.agreementLabel = [[YYLabel alloc] init];
    _agreementLabel.numberOfLines = 0;
    _agreementLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _agreementLabel.textColor = [UIColor themeGray3];
    _agreementLabel.font = [UIFont themeFontRegular:12];
    [self.scrollView addSubview:_agreementLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:11] textColor:[UIColor themeGray4]];
    _descLabel.textAlignment = NSTextAlignmentCenter;
    _descLabel.numberOfLines = 0;
    _descLabel.text = @"基于幸福里APP海量二手房挂牌和成交大数据，综合市场行情和房屋信息，预估房屋市场价值，仅供参考";
    [self addSubview:_descLabel];

}

- (void)initConstraints {
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self.scrollView);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(176 + self.naviBarHeight);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(30 + self.naviBarHeight);
        make.left.mas_equalTo(self.scrollView).offset(20);
        make.height.mas_equalTo(40);
    }];

    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
        make.left.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(20);
    }];

    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(40);
        make.left.mas_equalTo(self.scrollView).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.bottom.mas_equalTo(self.floorItemView);
    }];

    [self.neiborhoodItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.inputView);
        make.height.mas_equalTo(50);
    }];

    [self.areaItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.neiborhoodItemView.mas_bottom);
        make.left.right.mas_equalTo(self.neiborhoodItemView);
        make.height.mas_equalTo(50);
    }];

    [self.floorItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.areaItemView.mas_bottom);
        make.left.right.mas_equalTo(self.areaItemView);
        make.height.mas_equalTo(50);
    }];

    [self.evaluateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.inputView.mas_bottom).offset(40);
        make.left.right.mas_equalTo(self.inputView);
        make.height.mas_equalTo(44);
    }];
    
    [self setAgreementContent];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.descLabel.mas_top);
    }];

    CGFloat bottom = 10;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.bottom.mas_equalTo(-bottom);
    }];

    [self layoutIfNeeded];
    [FHUtils addShadowToView:self.inputView withOpacity:0.1 shadowColor:[UIColor blackColor] shadowOffset:CGSizeMake(2, 6) shadowRadius:8 andCornerRadius:4];
}

- (void)setAgreementContent {
    __weak typeof(self) weakSelf = self;
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:@"提交即视为同意《个人信息保护声明》"];
    [attrText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(7, 10)];
    [attrText addAttributes:[self commonTextStyle] range:NSMakeRange(0, attrText.length)];
    [attrText yy_setTextHighlightRange:NSMakeRange(7, 10) color:[UIColor themeGray3] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [weakSelf goToUserProtocol];
    }];

    self.agreementLabel.attributedText = attrText;
    
    [self.agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.evaluateBtn.mas_bottom).offset(6);
        make.height.mas_equalTo(17);
    }];
}

- (void)setEvaluateBtnEnabled:(BOOL)enabled {
    if(self.evaluateBtn.enabled != enabled){
        self.evaluateBtn.enabled = enabled;
        if(enabled){
            self.evaluateBtn.alpha = 1.0;
        }else{
            self.evaluateBtn.alpha = 0.6;
        }
    }
}

- (NSDictionary *)commonTextStyle {
    return @{
             NSFontAttributeName : [UIFont themeFontRegular:13],
             NSForegroundColorAttributeName : [UIColor themeGray3],
             };
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)goToNeighborhoodSearch {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToNeighborhoodSearch)]){
        [self.delegate goToNeighborhoodSearch];
    }
}

- (void)evaluate {
    if(self.delegate && [self.delegate respondsToSelector:@selector(evaluate)]){
        [self.delegate evaluate];
    }
}

- (void)goToUserProtocol {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToUserProtocol)]){
        [self.delegate goToUserProtocol];
    }
}

- (void)chooseFloor {
    if(self.delegate && [self.delegate respondsToSelector:@selector(chooseFloor)]){
        [self.delegate chooseFloor];
    }
}

@end
