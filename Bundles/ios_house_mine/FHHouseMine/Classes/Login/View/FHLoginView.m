//
//  FHLoginView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/14.
//

#import "FHLoginView.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"

@interface FHLoginView()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UIView *rightView;
@property(nonatomic, strong) UIView *singleLine;
@property(nonatomic, strong) UIView *singleLine2;
@property(nonatomic, strong) UIButton *confirmBtn;
@property(nonatomic, strong) YYLabel *agreementLabel;

@end

@implementation FHLoginView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.scrollView = [[UIScrollView alloc] init];
//    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self addSubview:_scrollView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:30] textColor:[UIColor themeGray1]];
    _titleLabel.text = @"手机快捷登录";
    [self.scrollView addSubview:_titleLabel];
    
    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    _subTitleLabel.text = @"未注册手机验证后自动注册";
    [self.scrollView addSubview:_subTitleLabel];
    
    self.rightView = [[UIView alloc] init];
    [self.scrollView addSubview:_rightView];
    
    self.phoneInput = [[UITextField alloc] init];
    _phoneInput.font = [UIFont themeFontRegular:14];
    _phoneInput.placeholder = @"请输入手机号";
    [_phoneInput setValue:[UIColor themeGray3] forKeyPath:@"_placeholderLabel.textColor"];
    _phoneInput.keyboardType = UIKeyboardTypePhonePad;
    _phoneInput.returnKeyType = UIReturnKeyDone;
    [self.scrollView addSubview:_phoneInput];
    
    self.singleLine = [[UIView alloc] init];
    _singleLine.backgroundColor = [UIColor themeGray6];
    [self.scrollView addSubview:_singleLine];
    
    self.varifyCodeInput = [[UITextField alloc] init];
    _varifyCodeInput.font = [UIFont themeFontRegular:14];
    _varifyCodeInput.placeholder = @"请输入验证码";
    [_varifyCodeInput setValue:[UIColor themeGray3] forKeyPath:@"_placeholderLabel.textColor"];
    _varifyCodeInput.keyboardType = UIKeyboardTypePhonePad;
    _varifyCodeInput.returnKeyType = UIReturnKeyGo;
    [self.scrollView addSubview:_varifyCodeInput];
    
    self.singleLine2 = [[UIView alloc] init];
    _singleLine2.backgroundColor = [UIColor themeGray6];
    [self.scrollView addSubview:_singleLine2];
    
    self.sendVerifyCodeBtn = [[UIButton alloc] init];
    [self setButtonContent:@"获取验证码" font:[UIFont themeFontRegular:14] color:[UIColor themeGray1] state:UIControlStateNormal btn:_sendVerifyCodeBtn];
    [self setButtonContent:@"获取验证码" font:[UIFont themeFontRegular:14] color:[UIColor themeGray3] state:UIControlStateDisabled btn:_sendVerifyCodeBtn];
    _sendVerifyCodeBtn.enabled = NO;
    [_sendVerifyCodeBtn addTarget:self action:@selector(sendVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_sendVerifyCodeBtn];
    
    self.confirmBtn = [[UIButton alloc] init];
    _confirmBtn.backgroundColor = [UIColor themeRed1];
    _confirmBtn.alpha = 0.6;
    _confirmBtn.layer.cornerRadius = 23;
    _confirmBtn.enabled = NO;
    [_confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonContent:@"登录" font:[UIFont themeFontRegular:16] color:[UIColor whiteColor] state:UIControlStateNormal btn:_confirmBtn];
    [self.scrollView addSubview:_confirmBtn];
    
    self.acceptCheckBox = [[UIButton alloc] init];
    [_acceptCheckBox setImage:[UIImage imageNamed:@"checkbox-checked"] forState:UIControlStateSelected];
    [_acceptCheckBox setImage:[UIImage imageNamed:@"ic-filter-normal"] forState:UIControlStateNormal];
    [_acceptCheckBox addTarget:self action:@selector(acceptCheckBoxChange) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_acceptCheckBox];
    
    self.agreementLabel = [[YYLabel alloc] init];
    _agreementLabel.numberOfLines = 0;
    _agreementLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _agreementLabel.textColor = [UIColor themeGray1];
    _agreementLabel.font = [UIFont themeFontRegular:13];
    [self addSubview:_agreementLabel];
}

- (void)initConstraints {
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(40);
        make.left.mas_equalTo(self.scrollView).offset(30);
        make.height.mas_equalTo(42);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6);
        make.left.mas_equalTo(self.scrollView).offset(30);
        make.height.mas_equalTo(20);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView);
        make.left.mas_equalTo(self.scrollView).offset(30);
        make.right.mas_equalTo(self).offset(-30);
        make.height.mas_equalTo(1);
    }];
    
    [self.phoneInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(40);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(20);
    }];
    
    [self.singleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneInput.mas_bottom).offset(11);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.varifyCodeInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneInput.mas_bottom).offset(43);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(20);
    }];
    
    [self.singleLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.varifyCodeInput.mas_bottom).offset(11);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.sendVerifyCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.varifyCodeInput);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(30);
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.varifyCodeInput.mas_bottom).offset(40);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(46);
    }];
    
    [self setAgreementContent];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.agreementLabel.mas_top).offset(-20);
    }];

}

- (void)setAgreementContent {
    __weak typeof(self) weakSelf = self;
    self.acceptCheckBox.selected = YES;
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:@"我已阅读并同意 《幸福里用户使用协议》及《隐私协议》"];
    [attrText addAttributes:[self commonTextStyle] range:NSMakeRange(0, attrText.length)];
    [attrText yy_setTextHighlightRange:NSMakeRange(8, 11) color:[UIColor themeRed1] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(goToUserProtocol)]) {
            [self.delegate goToUserProtocol];
        }
    }];
    
    [attrText yy_setTextHighlightRange:NSMakeRange(20, 6) color:[UIColor themeRed1] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(goToSecretProtocol)]) {
            [self.delegate goToSecretProtocol];
        }
    }];
    
    self.agreementLabel.attributedText = attrText;
    
    CGFloat width = UIScreen.mainScreen.bounds.size.width - 45 - 3 - 30;
    CGSize size = [self.agreementLabel sizeThatFits:CGSizeMake(width, 1000)];
    
    CGFloat bottom = 25;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }

    [self.agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.acceptCheckBox.mas_right).offset(3);
        make.right.mas_equalTo(self.rightView);
        make.height.mas_equalTo(size.height);
        make.bottom.mas_equalTo(self).offset(-bottom);
    }];
    
    [self.acceptCheckBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(30);
        make.top.mas_equalTo(self.agreementLabel).offset(1.5);
        make.width.height.mas_equalTo(15);
    }];
}

- (NSDictionary *)commonTextStyle {
    return @{
             NSFontAttributeName : [UIFont themeFontRegular:13],
             NSForegroundColorAttributeName : [UIColor themeGray1],
             };
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)setButtonContent:(NSString *)content font:(UIFont *)font color:(UIColor *)color state:(UIControlState)state btn:(UIButton *)btn {
    NSDictionary *attributes = @{
                                 NSFontAttributeName : font,
                                 NSForegroundColorAttributeName : color,
                                 NSUnderlineColorAttributeName : [UIColor clearColor]
                                 };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    [btn setAttributedTitle:attrStr forState:state];
}

- (void)confirm {
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirm)]) {
        [self.delegate confirm];
    }
}

- (void)acceptCheckBoxChange {
    if (self.delegate && [self.delegate respondsToSelector:@selector(acceptCheckBoxChange:)]) {
        [self.delegate acceptCheckBoxChange:self.acceptCheckBox.selected];
    }
}

- (void)sendVerifyCode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCode)]) {
        [self.delegate sendVerifyCode];
    }
}

- (void)enableConfirmBtn:(BOOL)enabled {
    self.confirmBtn.enabled = enabled;
    if(enabled){
        self.confirmBtn.alpha = 1;
    }else{
        self.confirmBtn.alpha = 0.6;
    }
}

- (void)enableSendVerifyCodeBtn:(BOOL)enabled {
    self.sendVerifyCodeBtn.enabled = enabled;
}

@end
