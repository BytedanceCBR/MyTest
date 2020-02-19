//
//  SpringLoginView.m
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/12/16.
//

#import "SpringLoginView.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "ToastManager.h"
#import "FHNavBarView.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <lottie-ios/Lottie/LOTAnimationView.h>

@implementation SpringLoginAcceptButton : UIButton
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    UIEdgeInsets insets = self.hotAreaInsets;
    CGFloat widthDelta = insets.left + insets.right;
    CGFloat heightDelta = insets.bottom + insets.top;
    CGRect hotAreaBounds = CGRectMake(bounds.origin.x - insets.left, bounds.origin.y - insets.top, bounds.size.width + widthDelta, bounds.size.height + heightDelta);
    if (!CGRectContainsPoint(hotAreaBounds, point)) {
        insets = self.hotAreaInsets2;
        widthDelta = insets.left + insets.right;
        heightDelta = insets.bottom + insets.top;
        hotAreaBounds = CGRectMake(bounds.origin.x - insets.left, bounds.origin.y - insets.top, bounds.size.width + widthDelta, bounds.size.height + heightDelta);
        return CGRectContainsPoint(hotAreaBounds, point);
    }
    return YES;
}

@end

@implementation SpringLoginScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if(!self.dragging) {
        [[self nextResponder] touchesBegan:touches withEvent:event];
    }
}

@end

@interface SpringLoginView ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *serviceLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UIView *rightView;
@property(nonatomic, strong) UIView *singleLine;
@property(nonatomic, strong) UIView *singleLine2;
@property(nonatomic, strong) UIButton *confirmBtn;
@property(nonatomic, strong) UIButton *otherLoginBtn;
@property(nonatomic, strong) YYLabel *agreementLabel;

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *springBgView;
@property(nonatomic, strong) UIButton *closeBtn;
@property(nonatomic, strong) UIView *phoneBgView;
@property(nonatomic, strong) UIView *varifyCodeBgView;

@property(nonatomic , strong) LOTAnimationView *animationView;
@property(nonatomic , strong) UIImageView *tipView;

@end

@implementation SpringLoginView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.scrollView = [[SpringLoginScrollView alloc] init];
    [self addSubview:_scrollView];
    
    self.containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:_containerView];
    
    self.springBgView = [[UIView alloc] init];
    _springBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fh_spring_login_bg"]];
    [self.containerView addSubview:_springBgView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"firework" ofType:@"json"];
    self.animationView = [LOTAnimationView animationWithFilePath:path];
    _animationView.contentMode = UIViewContentModeScaleToFill;
    _animationView.loopAnimation = YES;
    [self.containerView addSubview:_animationView];
    [_animationView play];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"fh_spring_login_close"] forState:UIControlStateNormal];
    _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:_closeBtn];
    
    self.phoneBgView = [[UIView alloc] init];
    _phoneBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fh_spring_input_bg"]];
    [self.springBgView addSubview:_phoneBgView];

    self.phoneInput = [[UITextField alloc] init];
    _phoneInput.font = [UIFont themeFontRegular:14];
    _phoneInput.textColor = [UIColor colorWithHexString:@"a05700"];
    _phoneInput.placeholder = @"请输入手机号";
    _phoneInput.tintColor = [UIColor colorWithHexString:@"a05700"];
    _phoneInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入手机号"attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"e1b067"]}];
    _phoneInput.keyboardType = UIKeyboardTypePhonePad;
    _phoneInput.returnKeyType = UIReturnKeyDone;
    [self.phoneBgView addSubview:_phoneInput];

    self.varifyCodeBgView = [[UIView alloc] init];
    _varifyCodeBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fh_spring_input_bg"]];
    [self.springBgView addSubview:_varifyCodeBgView];

    self.varifyCodeInput = [[UITextField alloc] init];
    _varifyCodeInput.font = [UIFont themeFontRegular:14];
    _varifyCodeInput.textColor = [UIColor colorWithHexString:@"a05700"];
    _varifyCodeInput.placeholder = @"请输入验证码";
    _varifyCodeInput.tintColor = [UIColor colorWithHexString:@"a05700"];
    _varifyCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"e1b067"]}];
    _varifyCodeInput.keyboardType = UIKeyboardTypePhonePad;
    _varifyCodeInput.returnKeyType = UIReturnKeyGo;
    [self.varifyCodeBgView addSubview:_varifyCodeInput];

    self.sendVerifyCodeBtn = [[UIButton alloc] init];
    [self setButtonContent:@"发送验证码" font:[UIFont themeFontRegular:14] color:[UIColor colorWithHexString:@"a05700"] state:UIControlStateNormal btn:_sendVerifyCodeBtn];
    [self setButtonContent:@"发送验证码" font:[UIFont themeFontRegular:14] color:[UIColor colorWithHexString:@"e1b067"] state:UIControlStateDisabled btn:_sendVerifyCodeBtn];
    _sendVerifyCodeBtn.enabled = NO;
    [_sendVerifyCodeBtn addTarget:self action:@selector(sendVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    [self.varifyCodeBgView addSubview:_sendVerifyCodeBtn];

    self.agreementLabel = [[YYLabel alloc] init];
    _agreementLabel.numberOfLines = 0;
    _agreementLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _agreementLabel.textColor = [UIColor colorWithHexString:@"a90c05"];
    _agreementLabel.font = [UIFont themeFontRegular:10];
    [self.scrollView addSubview:_agreementLabel];

//    self.acceptCheckBox = [[SpringLoginAcceptButton alloc] init];
//    self.acceptCheckBox.hotAreaInsets = UIEdgeInsetsMake(20, 15, 0, 30);
//    self.acceptCheckBox.hotAreaInsets2 = UIEdgeInsetsMake(20, 15, 20, 0);
//    [_acceptCheckBox setImage:[UIImage imageNamed:@"fh_spring_login_checked"] forState:UIControlStateSelected];
//    [_acceptCheckBox setImage:[UIImage imageNamed:@"fh_spring_login_check"] forState:UIControlStateNormal];
//    [_acceptCheckBox addTarget:self action:@selector(acceptCheckBoxChange) forControlEvents:UIControlEventTouchUpInside];
//    [self.scrollView addSubview:_acceptCheckBox];
    
    self.confirmBtn = [[UIButton alloc] init];
    [_confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [_confirmBtn setImage:[UIImage imageNamed:@"fh_spring_login_button_disable"] forState:UIControlStateNormal];
    [self.springBgView addSubview:_confirmBtn];

    self.tipView = [[UIImageView alloc] init];
    _tipView.image = [UIImage imageNamed:@"fh_spring_no_check_tip"];
    _tipView.hidden = YES;
    [self.springBgView addSubview:_tipView];
}

- (void)initConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(self);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.scrollView);
        make.width.mas_equalTo(312);
        make.height.mas_equalTo(553);
    }];
    
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(160);
    }];
    
    [self.springBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(447);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.springBgView.mas_bottom).offset(40);
        make.centerX.mas_equalTo(self.containerView);
        make.width.height.mas_equalTo(24);
    }];
    
    [self.phoneBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.springBgView).offset(221);
        make.left.mas_equalTo(self.springBgView).offset(43);
        make.width.mas_equalTo(230);
        make.height.mas_equalTo(45);
    }];
    
    [self.phoneInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.phoneBgView);
        make.left.mas_equalTo(self.phoneBgView).offset(10);
        make.right.mas_equalTo(self.phoneBgView).offset(-10);
        make.top.bottom.mas_equalTo(self.phoneBgView);
    }];
    
    [self.varifyCodeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneBgView.mas_bottom).offset(12);
        make.left.mas_equalTo(self.phoneBgView);
        make.width.mas_equalTo(self.phoneBgView);
        make.height.mas_equalTo(self.phoneBgView);
    }];
    
    [self.sendVerifyCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.varifyCodeBgView);
        make.top.bottom.mas_equalTo(self.varifyCodeBgView);
        make.right.mas_equalTo(self.varifyCodeBgView).offset(-10);
    }];

    [self.varifyCodeInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.varifyCodeBgView);
        make.left.mas_equalTo(self.varifyCodeBgView).offset(10);
        make.right.mas_equalTo(self.varifyCodeBgView).offset(-10);
        make.top.bottom.mas_equalTo(self.varifyCodeBgView);
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.springBgView).offset(-15);
        make.left.mas_equalTo(self.springBgView).offset(85);
        make.width.mas_equalTo(147);
        make.height.mas_equalTo(63);
    }];
    
//    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.acceptCheckBox.mas_top).offset(-4);
//        make.right.mas_equalTo(self.springBgView).offset(-33);
//        make.width.mas_equalTo(80);
//        make.height.mas_equalTo(28);
//    }];
}

- (void)setAgreementContent:(NSAttributedString *)attrText showAcceptBox:(BOOL)showAcceptBox {
    self.agreementLabel.attributedText = attrText;
    CGFloat boxWidth = 12;
    CGFloat width = 230;
    CGSize size = [self.agreementLabel sizeThatFits:CGSizeMake(width, 1000)];
//    self.acceptCheckBox.hidden = YES; //!showAcceptBox;
    
    [self.agreementLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.varifyCodeBgView);
        make.top.mas_equalTo(self.varifyCodeBgView.mas_bottom).offset(11);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(size.height);
    }];
    
//    [self.acceptCheckBox mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.varifyCodeBgView);
//        make.top.mas_equalTo(self.agreementLabel).offset(2);
//        make.width.height.mas_equalTo(boxWidth);
//    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)setButtonContent:(NSString *)content font:(UIFont *)font color:(UIColor *)color state:(UIControlState)state btn:(UIButton *)btn {
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: color,
                                 NSUnderlineColorAttributeName: [UIColor clearColor]
                                 };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    [btn setAttributedTitle:attrStr forState:state];
}

- (void)close {
    if (self.delegate && [self.delegate respondsToSelector:@selector(close)]) {
        [self.delegate close];
    }
}

- (void)confirm {
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirm)]) {
        [self.delegate confirm];
    }
}

//- (void)acceptCheckBoxChange {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(acceptCheckBoxChange:)]) {
//        [self.delegate acceptCheckBoxChange:self.acceptCheckBox.selected];
//    }
//}

- (void)sendVerifyCode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCode)]) {
        [self.delegate sendVerifyCode];
    }
}

- (void)enableConfirmBtn:(BOOL)enabled {
    if(enabled){
        [_confirmBtn setImage:[UIImage imageNamed:@"fh_spring_login_button"] forState:UIControlStateNormal];
    }else{
        [_confirmBtn setImage:[UIImage imageNamed:@"fh_spring_login_button_disable"] forState:UIControlStateNormal];
    }
}

- (void)enableSendVerifyCodeBtn:(BOOL)enabled {
    self.sendVerifyCodeBtn.enabled = enabled;
}

- (void)showTipView:(BOOL)isShow {
    self.tipView.hidden = !isShow;
}

- (void)startAnimation {
    [_animationView play];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

@end
