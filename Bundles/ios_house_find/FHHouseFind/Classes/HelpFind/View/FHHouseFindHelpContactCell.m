//
//  FHHouseFindHelpContactCell.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/27.
//

#import "FHHouseFindHelpContactCell.h"
#import "TTRoute.h"
#import "FHURLSettings.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "Masonry.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <FHHouseBase/FHUserInfoManager.h>
#import <FHHouseBase/NSObject+FHOptimize.h>
#import "SSCommonLogic.h"
#import <TTAccountSDK/TTAccount.h>

@interface FHHouseFindHelpContactCell()

@property(nonatomic, strong, readwrite) UITextField *phoneInput;
@property(nonatomic, strong, readwrite) UITextField *varifyCodeInput;
@property(nonatomic, strong) UIView *singleLine;
@property(nonatomic, strong) UIView *singleLine2;
@property(nonatomic, strong) UILabel *tipLabel;
@property(nonatomic, strong) UILabel *announceLabel;

@end

@implementation FHHouseFindHelpContactCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self.contentView addSubview:self.phoneInput];
    [self.contentView addSubview:self.singleLine];
    
    [self.contentView addSubview:self.varifyCodeInput];
    [self.contentView addSubview:self.sendVerifyCodeBtn];
    [self.contentView addSubview:self.singleLine2];
    [self.sendVerifyCodeBtn addTarget:self action:@selector(sendVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    self.sendVerifyCodeBtn.enabled = NO;
    
    [self.contentView addSubview:self.tipLabel];
    [self.contentView addSubview:self.announceLabel];
    [self.phoneInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(30);
    }];
    
    [self.singleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneInput.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(self.phoneInput);
        make.right.mas_equalTo(self.phoneInput);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    if ([SSCommonLogic isEnableVerifyFormAssociate]) {
        if (![TTAccount sharedAccount].isLogin) {
            [self.varifyCodeInput mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.phoneInput.mas_bottom).offset(30);
                make.left.mas_equalTo(self.phoneInput);
                make.right.mas_equalTo(self.phoneInput);
                make.height.mas_equalTo(30);
            }];
            
            [self.singleLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.varifyCodeInput.mas_bottom);
                make.left.mas_equalTo(self.phoneInput);
                make.right.mas_equalTo(self.phoneInput);
                make.height.mas_equalTo(1.0/UIScreen.mainScreen.scale);
            }];
            
            [self.sendVerifyCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.phoneInput);
                make.right.mas_equalTo(self.phoneInput);
                make.height.mas_equalTo(30);
            }];
            
            [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(self.phoneInput);
                make.top.mas_equalTo(self.singleLine2.mas_bottom).mas_offset(20);
        //        make.bottom.mas_equalTo(-20);
            }];
        } else {
            self.phoneInput.userInteractionEnabled = NO;
            
            [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(self.phoneInput);
                make.top.mas_equalTo(self.singleLine.mas_bottom).mas_offset(20);
        //        make.bottom.mas_equalTo(-20);
            }];
        }
    } else {
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.phoneInput);
            make.top.mas_equalTo(self.singleLine.mas_bottom).mas_offset(20);
    //        make.bottom.mas_equalTo(-20);
        }];
    }
    [self.announceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.tipLabel);
        make.top.mas_equalTo(self.tipLabel.mas_bottom);
        make.height.mas_equalTo(14);
    }];
}

-(void)legalAnnouncementClick{
    NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
    NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
    [[TTRoute sharedRoute]openURLByPushViewController:url];
}

- (void)sendVerifyCode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyCode)]) {
        [self.delegate sendVerifyCode];
    }
}

- (void)enableSendVerifyCodeBtn:(BOOL)enabled
{
    self.sendVerifyCodeBtn.enabled = enabled;
}

- (void)showFullPhoneNum:(BOOL)isShow {
    if(isShow){
        __weak typeof(self) weakSelf = self;
        [self executeOnce:^{
            weakSelf.phoneInput.text = @"";
        } token:FHExecuteOnceUniqueTokenForCurrentContext];
    }else{
        self.phoneInput.text = [FHUserInfoManager formatMaskPhoneNumber:self.phoneNum];
    }
}

- (UITextField *)phoneInput
{
    if (!_phoneInput) {
        _phoneInput = [[UITextField alloc] init];
        _phoneInput.font = [UIFont themeFontRegular:14];
        _phoneInput.placeholder = @"请输入手机号";
        _phoneInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入手机号" attributes:@{NSForegroundColorAttributeName: [UIColor themeGray3]}];
        _phoneInput.keyboardType = UIKeyboardTypePhonePad;
        _phoneInput.returnKeyType = UIReturnKeyDone;
        _phoneInput.userInteractionEnabled = YES;
    }
    return _phoneInput;
}

- (UITextField *)varifyCodeInput
{
    if (!_varifyCodeInput) {
        _varifyCodeInput = [[UITextField alloc] init];
        _varifyCodeInput.font = [UIFont themeFontRegular:14];
        _varifyCodeInput.placeholder = @"请输入验证码";
        _varifyCodeInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:@{NSForegroundColorAttributeName: [UIColor themeGray3]}];
        _varifyCodeInput.keyboardType = UIKeyboardTypePhonePad;
        _varifyCodeInput.returnKeyType = UIReturnKeyGo;
    }
    return _varifyCodeInput;
}

- (UIButton *)sendVerifyCodeBtn
{
    if (!_sendVerifyCodeBtn) {
        _sendVerifyCodeBtn = [[UIButton alloc] init];
        _sendVerifyCodeBtn.titleLabel.font = [UIFont themeFontRegular:14];
        [_sendVerifyCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_sendVerifyCodeBtn setTitle:@"获取验证码" forState:UIControlStateHighlighted];
        [_sendVerifyCodeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [_sendVerifyCodeBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateHighlighted];
        [_sendVerifyCodeBtn setTitleColor:[UIColor themeGray3] forState:UIControlStateDisabled];
    }
    return _sendVerifyCodeBtn;
}

- (UIView *)singleLine
{
    if (!_singleLine) {
        _singleLine = [[UIView alloc] init];
        _singleLine.backgroundColor = [UIColor themeGray6];
    }
    return _singleLine;
}

- (UIView *)singleLine2
{
    if (!_singleLine2) {
        _singleLine2 = [[UIView alloc] init];
        _singleLine2.backgroundColor = [UIColor themeGray6];
    }
    return _singleLine2;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"温馨提示：\n提交购房需求后将由幸福里及其授权的优质服务商为您提供专业服务";
        _tipLabel.numberOfLines = 0;
        _tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _tipLabel.textColor = [UIColor themeGray3];
        _tipLabel.font = [UIFont themeFontRegular:10];
    }
    return _tipLabel;
}

- (UILabel *)announceLabel {
    if (!_announceLabel) {
        _announceLabel = [[UILabel alloc] init];
        NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:@"点击提交即视为同意《个人信息保护声明》"];
        [attrText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(10, @"个人信息保护声明".length)];
        _announceLabel.attributedText= attrText;
        _announceLabel.numberOfLines = 0;
        _announceLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _announceLabel.textColor = [UIColor themeGray3];
        _announceLabel.font = [UIFont themeFontRegular:10];
        UITapGestureRecognizer *tipTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(legalAnnouncementClick)];
        _announceLabel.userInteractionEnabled = YES;
        [_announceLabel addGestureRecognizer:tipTap];
    }
    return _announceLabel;
}

@end
