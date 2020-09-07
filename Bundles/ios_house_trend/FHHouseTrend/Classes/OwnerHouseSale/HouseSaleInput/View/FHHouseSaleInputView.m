//
//  FHHouseSaleInputView.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import "FHHouseSaleInputView.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "FHUtils.h"
#import "FHHouseSaleFlowView.h"
#import "FHHouseSaleServiceView.h"
#import <TTRoute.h>
#import "FHURLSettings.h"

@interface FHHouseSaleInputView()

@property(nonatomic, strong) UIImageView *headerImageView;
@property(nonatomic, strong) UIImageView *beforeHeaderView;
@property(nonatomic, strong) UILabel *locationLabel;
@property(nonatomic, strong) UIView *inputViewOne;
@property(nonatomic, strong) UIView *inputViewTwo;
//@property(nonatomic, strong) UIButton *evaluateBtn;
@property(nonatomic, assign) CGFloat naviBarHeight;
@property(nonatomic, strong) YYLabel *agreementLabel;
//@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) FHHouseSaleFlowView *flowView;
@property(nonatomic, strong) FHHouseSaleServiceView *serviceView;
@property(nonatomic, strong) UIView *bottomView;
@property(nonatomic, strong) UIButton *bottomBtn;

@end

@implementation FHHouseSaleInputView

- (instancetype)initWithFrame:(CGRect)frame naviBarHeight:(CGFloat)naviBarHeight {
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [UIColor themeGray7];
        self.naviBarHeight = naviBarHeight;
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    __weak typeof(self) wself = self;
    
    self.scrollView = [[FHHouseSaleScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor themeGray7];
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self addSubview:_scrollView];

    self.headerImageView = [[UIImageView alloc] init];
    _headerImageView.image = [UIImage imageNamed:@"house_sale_header_image"];
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:_headerImageView];
    
    self.beforeHeaderView = [[UIImageView alloc] init];
    _beforeHeaderView.image = [self ct_imageFromImage:_headerImageView.image inRect:CGRectMake(0,0, _headerImageView.image.size.width, 1)];
    [self.scrollView addSubview:_beforeHeaderView];

    self.inputViewOne = [[UIView alloc] init];
    _inputViewOne.layer.cornerRadius = 10;
    _inputViewOne.layer.masksToBounds = YES;
    [self.scrollView addSubview:_inputViewOne];
    
    self.locationLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    _locationLabel.backgroundColor = [UIColor whiteColor];
    _locationLabel.text = @"当前定位城市：北京";
    _locationLabel.textAlignment = NSTextAlignmentCenter;
    [self.inputViewOne addSubview:_locationLabel];

    self.neiborhoodItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeNormal];
    _neiborhoodItemView.titleLabel.text = @"所在小区";
    _neiborhoodItemView.titleWidth = 74;
    _neiborhoodItemView.placeholder = @"请输入";
    _neiborhoodItemView.tapBlock = ^{
        [wself goToNeighborhoodSearch];
    };
    [self.inputViewOne addSubview:_neiborhoodItemView];
    
    self.floorItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeNormal];
    _floorItemView.titleLabel.text = @"房源户型";
    _floorItemView.titleWidth = 74;
    _floorItemView.placeholder = @"请选择";
    _floorItemView.tapBlock = ^{
        [wself chooseFloor];
    };
    [self.inputViewOne addSubview:_floorItemView];

    self.areaItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeTextField];
    _areaItemView.bottomLine.hidden = YES;
    _areaItemView.titleLabel.text = @"面积";
    _areaItemView.placeholder = @"请输入";
    _areaItemView.textField.keyboardType = UIKeyboardTypeDecimalPad;
    _areaItemView.rightText = @"m²";
    [self.inputViewOne addSubview:_areaItemView];
    
    self.inputViewTwo = [[UIView alloc] init];
    _inputViewTwo.layer.cornerRadius = 10;
    _inputViewTwo.layer.masksToBounds = YES;
    [self.scrollView addSubview:_inputViewTwo];
    
    self.nameItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeTextField];
    _nameItemView.rightImage.hidden = YES;
    _nameItemView.titleLabel.text = @"称呼";
    _nameItemView.placeholder = @"请输入";
    [self.inputViewTwo addSubview:_nameItemView];
    
    self.phoneItemView = [[FHPriceValuationItemView alloc] initWithFrame:CGRectZero type:FHPriceValuationItemViewTypeTextField];
    _phoneItemView.bottomLine.hidden = YES;
    _phoneItemView.rightImage.hidden = YES;
    _phoneItemView.titleLabel.text = @"手机号";
    _phoneItemView.placeholder = @"填写手机号获得专业顾问服务";
    _phoneItemView.textField.keyboardType = UIKeyboardTypeDecimalPad;
    [self.inputViewTwo addSubview:_phoneItemView];
    
    self.flowView = [[FHHouseSaleFlowView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30, 116)];
    _flowView.layer.cornerRadius = 10;
    _flowView.layer.masksToBounds = YES;
    [self.scrollView addSubview:_flowView];
    
    CGFloat height = [FHHouseSaleServiceView viewHeight:[UIScreen mainScreen].bounds.size.width - 30];
    self.serviceView = [[FHHouseSaleServiceView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30, height)];
    _serviceView.layer.cornerRadius = 10;
    _serviceView.layer.masksToBounds = YES;
    [self.scrollView addSubview:_serviceView];

//    self.evaluateBtn = [[UIButton alloc] init];
//    _evaluateBtn.backgroundColor = [UIColor themeOrange4];
//    [_evaluateBtn setTitle:@"立即估价" forState:UIControlStateNormal];
//    [_evaluateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    _evaluateBtn.titleLabel.font = [UIFont themeFontRegular:16];
//    _evaluateBtn.layer.cornerRadius = 22; //4;
//    _evaluateBtn.layer.masksToBounds = YES;
//    [self setEvaluateBtnEnabled:NO];

//    [_evaluateBtn addTarget:self action:@selector(evaluate) forControlEvents:UIControlEventTouchUpInside];
//    [self.scrollView addSubview:_evaluateBtn];
    
    self.agreementLabel = [[YYLabel alloc] init];
    _agreementLabel.numberOfLines = 0;
    _agreementLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _agreementLabel.textColor = [UIColor themeGray3];
    _agreementLabel.font = [UIFont themeFontRegular:12];
    [self.scrollView addSubview:_agreementLabel];
    
    self.bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bottomView];
    
    self.bottomBtn = [[UIButton alloc] init];
    _bottomBtn.backgroundColor = [UIColor themeOrange4];
    [_bottomBtn setTitle:@"提交信息" forState:UIControlStateNormal];
    [_bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _bottomBtn.titleLabel.font = [UIFont themeFontRegular:16];
    _bottomBtn.layer.cornerRadius = 20; //4;
    _bottomBtn.layer.masksToBounds = YES;
    [_bottomBtn addTarget:self action:@selector(houseSale) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:_bottomBtn];
    
//    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:11] textColor:[UIColor themeGray4]];
//    _descLabel.textAlignment = NSTextAlignmentLeft;
//    _descLabel.numberOfLines = 0;
//    _descLabel.text = @"基于幸福里APP海量二手房挂牌和成交大数据，综合市场行情和房屋信息，预估房屋市场价值，仅供参考";
//    [self addSubview:_descLabel];

}

- (void)initConstraints {
    CGFloat headerImageViewTop = self.naviBarHeight - 64;
    CGFloat headerViewHeight = ceil([UIScreen mainScreen].bounds.size.width * 260/375);
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(headerImageViewTop);
        make.left.mas_equalTo(self.scrollView);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(headerViewHeight);
    }];
    
    [self.beforeHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.headerImageView.mas_top);
        make.left.mas_equalTo(self.scrollView);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(500);
    }];
    
    [self.inputViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerImageView.mas_bottom).offset(-50);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self).offset(-15);
        make.bottom.mas_equalTo(self.areaItemView);
    }];

    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.inputViewOne);
        make.height.mas_equalTo(50);
    }];

    [self.neiborhoodItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.locationLabel.mas_bottom);
        make.left.right.mas_equalTo(self.inputViewOne);
        make.height.mas_equalTo(50);
    }];
    
    [self.floorItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.neiborhoodItemView.mas_bottom);
        make.left.right.mas_equalTo(self.inputViewOne);
        make.height.mas_equalTo(50);
    }];

    [self.areaItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.floorItemView.mas_bottom);
        make.left.right.mas_equalTo(self.inputViewOne);
        make.height.mas_equalTo(50);
    }];
    
    [self.inputViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.inputViewOne.mas_bottom).offset(20);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self).offset(-15);
        make.bottom.mas_equalTo(self.phoneItemView);
    }];
    
    [self.nameItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.inputViewTwo);
        make.height.mas_equalTo(50);
    }];

    [self.phoneItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameItemView.mas_bottom);
        make.left.right.mas_equalTo(self.inputViewTwo);
        make.height.mas_equalTo(50);
    }];
    
    [self.flowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.inputViewTwo.mas_bottom).offset(20);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self).offset(-15);
        make.height.mas_equalTo(116);
    }];
    
    CGFloat height = [FHHouseSaleServiceView viewHeight:[UIScreen mainScreen].bounds.size.width - 30];
    [self.serviceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.flowView.mas_bottom).offset(20);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self).offset(-15);
        make.height.mas_equalTo(height);
    }];

//    [self.evaluateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.inputView.mas_bottom).offset(40);
//        make.left.right.mas_equalTo(self.inputViewOne);
//        make.height.mas_equalTo(44);
//    }];
    
    [self setAgreementContent];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];

//    CGFloat bottom = 10;
//    if (@available(iOS 11.0 , *)) {
//        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
//    }
    
    CGFloat bottom = 64;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(bottom);
    }];
    
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView).offset(12);
        make.left.mas_equalTo(self).offset(15);
        make.right.mas_equalTo(self).offset(-15);
        make.height.mas_equalTo(40);
    }];

//    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self).offset(15);
//        make.right.mas_equalTo(self).offset(-15);
//        make.bottom.mas_equalTo(-bottom);
//    }];

    [self layoutIfNeeded];
//    [FHUtils addShadowToView:self.inputViewOne withOpacity:0.1 shadowColor:[UIColor blackColor] shadowOffset:CGSizeMake(2, 6) shadowRadius:8 andCornerRadius:4];
}

- (void)setAgreementContent {
    __weak typeof(self) weakSelf = self;
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:@"点击提交即视为同意《个人信息保护声明》"];
    [attrText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(10, 8)];
    [attrText addAttributes:[self commonTextStyle] range:NSMakeRange(0, attrText.length)];
    [attrText yy_setTextHighlightRange:NSMakeRange(10, 8) color:[UIColor themeGray3] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [weakSelf goToUserProtocol];
    }];

    self.agreementLabel.attributedText = attrText;

    [self.agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self).offset(-15);
        make.top.mas_equalTo(self.serviceView.mas_bottom).offset(20);
        make.height.mas_equalTo(17);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).offset(-10);
    }];
}

//- (void)setEvaluateBtnEnabled:(BOOL)enabled {
//    if(self.evaluateBtn.enabled != enabled){
//        self.evaluateBtn.enabled = enabled;
//        if(enabled){
//            self.evaluateBtn.alpha = 1.0;
//        }else{
//            self.evaluateBtn.alpha = 0.3;
//        }
//    }
//}

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

- (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect{
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return newImage;
}

- (void)goToNeighborhoodSearch {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToNeighborhoodSearch)]){
        [self.delegate goToNeighborhoodSearch];
    }
}

- (void)houseSale {
    if(self.delegate && [self.delegate respondsToSelector:@selector(evaluate)]){
        [self.delegate evaluate];
    }
}

- (void)goToUserProtocol {
    [self endEditing:YES];
    NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
//    NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    stringByAddingPercentEncodingWithAllowedCharacters
    NSString *urlStr = [privateUrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

//    NSString *urlStr = [privateUrlStr stringByAddingPercentEncodingWithAllowedCharacters:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
    [[TTRoute sharedRoute]openURLByPushViewController:url];
}

- (void)chooseFloor {
    if(self.delegate && [self.delegate respondsToSelector:@selector(chooseFloor)]){
        [self.delegate chooseFloor];
    }
}

@end
