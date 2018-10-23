//
//  TTAccountLoginAlert.m
//  TTAccountLogin
//
//  Created by yuxin on 2/24/16.
//
//

#import "TTAccountLoginAlert.h"
#import <TTKeyboardListener.h>
#import <TTDeviceHelper.h>
#import <TTDeviceUIUtils.h>
#import <UIButton+TTAdditions.h>
#import <TTLabelTextHelper.h>
#import <TTIndicatorView.h>
#import <TTUIResponderHelper.h>
#import <TTThemeManager.h>
#import <UIViewAdditions.h>
#import "TTAccountLoginManager.h"
#import "TTAccountLoginEditProfileViewController.h"
#import "NSTimer+TTNoRetainRef.h"



#define kTTAccountResendDuration (60)

#define kTTAccountResendBtnFontSizeIphone6s  (14)
#define kTTAccountResendBtnFontSizeIphone5s  (12)
#define kTTAccountResendBtnFontSizeIphone4s  (12)


@interface TTAccountLoginAlert ()
<
UITextFieldDelegate
>
/**
 0. centerView
 1. titleLabel
 2. cancelBtn
 3. firstTextField
 4. firstTextField 和 resendBtn 之间的 1 条线 phoneSplitVerifyBtnView
 5. resendBtn
 6. firstTextField下方的 1 条线 phoneSplitVerifyView
 7. secondTextField
 8. secondTextField下方的 1 条线 verifySplitErrorView
 9. errorLabel
 10. tipLabel
 11. doneBtn
 12. tipBtn
 13. moreRegisterBtn
 14. phoneerrorLabel
 */
@property (nonatomic, strong) SSThemedButton *resendBtn;
// 手机号或验证码输入框
@property (nonatomic, strong) SSThemedTextField *firstTextField;
@property (nonatomic, strong) SSThemedTextField *secondTextField;
@property (nonatomic, strong) SSThemedTextField *passwordTextField;

// 在“进入头条”button上的tipLabel，文案也是下发的
@property (nonatomic, strong) SSThemedLabel *tipLabel;
// 在手机号和重发验证码按钮之间的 1 条线
@property (nonatomic, strong) SSThemedView *phoneSplitVerifyBtnView;
// 在手机号和验证码的label之间的 1 条线
@property (nonatomic, strong) SSThemedView *phoneSplitVerifyView;
// 在验证码和error的label之间的 1 条线
@property (nonatomic, strong) SSThemedView *verifySplitErrorView;
// error提示的label
@property (nonatomic, strong) SSThemedLabel *errorLabel;
// phone error 提示的label
@property (nonatomic, strong) SSThemedLabel *phoneErrorLabel;
// 更多登录方式的button
@property (nonatomic, strong) SSThemedButton *moreRegisterBtn;

@property (nonatomic, strong) SSThemedImageView *codeInvalidImageView;

@property (nonatomic, strong) TTAlphaThemedButton *topButton;
@property (nonatomic, strong) TTAlphaThemedButton *midButton;
@property (nonatomic, strong) TTAlphaThemedButton *bottomButton;

@property (nonatomic, assign) BOOL enableSendTrack;

@property (nonatomic, assign) CGFloat centerViewWidth;
@property (nonatomic, assign) CGFloat centerViewHeight;

@property (nonatomic, assign) NSInteger resendSecond;
@property (nonatomic, strong) NSTimer *resendTimer;

@property (nonatomic,   copy) NSString *phoneNumString;
@property (nonatomic,   copy) NSString *verifyCode;

@property (nonatomic,   copy) NSString *captchaString;

@end

@implementation TTAccountLoginAlert

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 判断是哪种类型的设备
- (NSInteger)devieTypeSwitch
{
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return 1;
        case TTDeviceMode736: return 1;
        case TTDeviceMode667: return 1;
        case TTDeviceMode568: return 0;
        case TTDeviceMode480: return -1;
    }
    return 1;
}

- (NSString *)source
{
    if (isEmptyString(_source)) {
        _source = @"other";
    }
    return _source;
}

#pragma mark - keyboard notifications
// 重写 TTAccountAlert 继承自 TTAlertView 的方法，监听键盘事件，设置centerView显示的范围
- (void)keyboardDidShow:(NSNotification *)notification
{
    // 当键盘弹出，用户点击验证码输入框时，如果手机号验证错误，则显示“手机号错误”信息
    if ([self.secondTextField isFirstResponder]) {
        if (![self validateMobileNumber:self.firstTextField.text]) {
            [self.phoneErrorLabel setAttributedText:[self.class attributedStringWithString:@"手机号错误" fontSize:11.0f lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]];
        }
    }
    
    CGFloat keyboardTop = 0.0f;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
            break;
        case TTDeviceMode736: keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
            break;
        case TTDeviceMode667: keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
            break;
        case TTDeviceMode568: keyboardTop = self.frame.size.height + [self statusBarWindow].frame.size.height +  12 -[TTKeyboardListener sharedInstance].keyboardHeight;
            break;
        case TTDeviceMode480: keyboardTop = self.frame.size.height - 3 * [self statusBarWindow].frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
            break;
        default: keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
            break;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    CGPoint center = CGPointMake(self.centerView.center.x,  keyboardTop/2);
    self.centerView.center = center;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    self.centerView.center = self.center;
    [self.centerView endEditing:YES];
    [UIView commitAnimations];
}

- (instancetype)initPhoneNumberInputAlertWithActionType:(TTAccountLoginAlertActionType)type
                                                  title:(NSString *)titleString
                                            placeholder:(NSString *)placeholderString
                                                    tip:(NSString *)tipString
                                         cancelBtnTitle:(NSString *)cancelTitleString
                                        confirmBtnTitle:(NSString *)confirmBtnTitleString
                                               animated:(BOOL)animated
                                                 source:(NSString *)sourceString
                                             completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedHandler
{
    if ((self = [super init])) {
        //快捷登录弹窗
        self.phoneInputCompletedHandler = completedHandler;
        self.alertUIStyle = TTAccountLoginAlertUIStylePhoneNumInput;
        self.actionType = type;
        self.moreButtonRespAction = TTAccountLoginMoreActionRespModeCallback;
        
        self.source = !isEmptyString(sourceString) ? sourceString : @"other";
        
        self.enableSendTrack = YES;
        
        self.centerView.backgroundColors = @[@"FFFFFF", @"252525"];
        
        // 给 centerView 加入点击事件，关闭键盘
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardWillHide:)];
        [self.centerView addGestureRecognizer:tapRecognizer];
        
        self.firstTextField.hidden = YES;
        self.resendBtn.hidden = YES;
        self.phoneSplitVerifyBtnView.hidden = YES;
        self.phoneErrorLabel.hidden = YES;
        self.secondTextField.hidden = YES;
        self.doneBtn.hidden = YES;
        self.verifySplitErrorView.hidden = YES;
        self.errorLabel.hidden = YES;
        self.tipLabel.hidden = YES;
        self.moreRegisterBtn.hidden = YES;
        
        // 相同的视图元素放到开始去定义
        [self.cancelBtn setImageName:@"popup_newclose"];
        self.cancelBtn.layer.borderWidth = 0.0f;
        [self.cancelBtn setTitleColorThemeKey:kColorText3];
        self.cancelBtn.backgroundColors = @[@"00000000", @"00000000"];
        self.cancelBtn.highlightedBackgroundColors = @[@"00000000", @"00000000"];
        self.cancelBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [self.cancelBtn setEnableHighlightAnim:YES];
        
        self.titleLabel.textColorThemeKey = kColorText1;
        self.titleLabel.backgroundColors = @[@"FFFFFF", @"252525"];
        [self.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17.f]]];
        self.tipBtn.titleColorThemeKey = kColorText1;
        [self.tipBtn.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]]];
        [self.tipBtn setEnableHighlightAnim:YES];
        if ([tipString length] <= 0) {
            [self.tipBtn setTitle:@"更多登录方式" forState:UIControlStateNormal];
            
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                [self.tipBtn setImage:[UIImage imageNamed:@"all_card_arrow"] forState:UIControlStateNormal];
            } else {
                [self.tipBtn setImage:[UIImage imageNamed:@"all_card_arrow_night"] forState:UIControlStateNormal];
            }
            [self.tipBtn setImageEdgeInsets:UIEdgeInsetsMake(0.f, self.tipBtn.titleLabel.width + 5.f, 0.f, -self.tipBtn.titleLabel.width - 5.f)];
            [self.tipBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.f, -self.tipBtn.imageView.width, 0.f, 0.f)];
            [self.tipBtn.titleLabel sizeToFit];
        } else {
            [self.tipBtn setTitle:tipString forState:UIControlStateNormal];
            [self.tipBtn.titleLabel sizeToFit];
        }
        
        // 服务端下发平台配置
        NSArray<NSString *> *platformList = [TTAccountLoginConfLogic loginPlatformEntryList];
        if ([platformList count] <= 0) {
            platformList = @[
                             TT_LOGIN_PLATFORM_HUOSHAN,
                             TT_LOGIN_PLATFORM_DOUYIN,
                             TT_LOGIN_PLATFORM_WECHAT,
                             TT_LOGIN_PLATFORM_QZONE,
                             // TT_LOGIN_PLATFORM_SINAWEIBO /** 下掉 */
                             ];
        }
        
        NSInteger maxNumberOfShowPlatforms = 2;
        NSInteger curNumberOfShowPlatforms = 0; // 当前已显示的平台数
        self.midButton.hidden = YES;
        self.bottomButton.hidden = YES;
//        if (curNumberOfShowPlatforms < maxNumberOfShowPlatforms &&
//            [self isHuoShanAvailable] && [platformList containsObject:TT_LOGIN_PLATFORM_HUOSHAN]) {
//            [self setHuoShanStyle:self.midButton];
//            self.midButton.tag = 1004; //1004为火山小视频
//            curNumberOfShowPlatforms++;
//
//            // LogV3
//            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
//            [extraDict setValue:self.source forKey:@"source"];
//            [extraDict setValue:@"1" forKey:@"hotsoon_login_show"];
//            [TTTrackerWrapper eventV3:@"login_quick_show" params:extraDict];
//        }
        
//        if (curNumberOfShowPlatforms < maxNumberOfShowPlatforms &&
//            [self isDouYinAvailable] && [platformList containsObject:TT_LOGIN_PLATFORM_DOUYIN]) {
//            if (curNumberOfShowPlatforms == 0) {
//                [self setDouYinStyle:self.midButton];
//                self.midButton.tag = 1005; //1005为抖音
//            } else if (curNumberOfShowPlatforms == 1) {
//                [self setDouYinStyle:self.bottomButton];
//                self.bottomButton.tag = 1005; //1005为抖音
//            }
//            curNumberOfShowPlatforms++;
//
//            // LogV3
//            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
//            [extraDict setValue:self.source forKey:@"source"];
//            [extraDict setValue:@"1" forKey:@"douyin_login_show"];
//            [TTTrackerWrapper eventV3:@"login_quick_show" params:extraDict];
//        }
        
        if (curNumberOfShowPlatforms < maxNumberOfShowPlatforms &&
            [self installedWeixin] && [platformList containsObject:TT_LOGIN_PLATFORM_WECHAT]) {
            if (curNumberOfShowPlatforms == 0) {
                [self setWeChatStyle:self.midButton];
                self.midButton.tag = 1001; //1001为微信登录
            } else if (curNumberOfShowPlatforms == 1) {
                [self setWeChatStyle:self.bottomButton];
                self.bottomButton.tag = 1001; //1001为微信登录
            }
            curNumberOfShowPlatforms++;
        }
        
        if (curNumberOfShowPlatforms < maxNumberOfShowPlatforms && [platformList containsObject:TT_LOGIN_PLATFORM_QZONE]) {
            if (curNumberOfShowPlatforms == 0) {
                [self setQQStyle:self.midButton];
                self.midButton.tag = 1002;//1002为QQ登录
            } else if (curNumberOfShowPlatforms == 1) {
                [self setQQStyle:self.bottomButton];
                self.bottomButton.tag = 1002;//1002为QQ登录
            }
            curNumberOfShowPlatforms++;
        }
        
        if (curNumberOfShowPlatforms < maxNumberOfShowPlatforms && [platformList containsObject:TT_LOGIN_PLATFORM_SINAWEIBO]) {
            if (curNumberOfShowPlatforms == 0) {
                [self setWeiboStyle:self.midButton];
                self.midButton.tag = 1003; //1003为微博登录
            } else if (curNumberOfShowPlatforms == 1) {
                [self setWeiboStyle:self.bottomButton];
                self.bottomButton.tag = 1003; //1003为微博登录
            }
            curNumberOfShowPlatforms++;
        }
        
        self.midButton.hidden = !(curNumberOfShowPlatforms >= 1);
        self.bottomButton.hidden = !(curNumberOfShowPlatforms >= 2);
        
        /** 根据服务端下发控制隐藏的平台数目 */
        NSInteger controlledHidePlatformButtons = maxNumberOfShowPlatforms - curNumberOfShowPlatforms;
        
        // 判断设备，根据设备进行 快捷登录视图的定制
        if ([self devieTypeSwitch] == 1) {
            // ipad，iphone6s plus, iphone 6s 使用一个登录界面效果
            self.centerView.frame = CGRectMake(0.0f, 0.0f, 270.f, 340.0f - controlledHidePlatformButtons * (40 + 12));
            CGFloat centerViewWidth = self.centerView.frame.size.width;
            
            self.titleLabel.frame = CGRectMake(10.f, 55.f, centerViewWidth - 20.f, 17.f);
            self.titleLabel.centerX = centerViewWidth / 2;
            [self.titleLabel setAttributedText:[self.class attributedStringWithString:titleString fontSize:17 lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
            [self.topButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
            [self.midButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
            [self.bottomButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
            [self.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
            [self.tipBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [self.tipBtn.titleLabel sizeToFit];
            [self.tipBtn setImageEdgeInsets:UIEdgeInsetsMake(0.f, self.tipBtn.titleLabel.width + 5.f, 0.f, -self.tipBtn.titleLabel.width - 5.f)];
            [self.tipBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.f, -self.tipBtn.imageView.width, 0.f, 0.f)];
            
            self.cancelBtn.frame = CGRectMake(238.f, 8.f, 24, 24);
            
            self.tipBtn.frame = CGRectMake(10.f, 286.f, centerViewWidth - 20.f, 14);
            self.tipBtn.bottom = (CGRectGetHeight(self.centerView.frame) - 40 /* 340 - (286 + 14) */);
            
            self.topButton.frame = CGRectMake(30.f, 0, 210.f, 40.f);
            self.topButton.top = self.titleLabel.bottom + 40.f;
            [self.topButton setTitle:@"手机登录" forState:UIControlStateNormal];
            [self.topButton.titleLabel sizeToFit];
            [self.topButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, self.topButton.titleLabel.width / 2 - self.topButton.width / 2 + self.topButton.imageView.width / 2 + 10.f, 0.f, -self.topButton.titleLabel.width / 2 + self.topButton.width / 2 - self.topButton.imageView.width / 2 - 10.f)];
            [self.topButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, -self.topButton.imageView.width, 0.f, 0.f)];
            [self.centerView addSubview:self.topButton];
            
            if (!self.midButton.hidden) {
                self.midButton.frame = CGRectMake(30.f, 0, 210.f, 40.f);
                self.midButton.top = self.topButton.bottom + 12.f;
                [self.midButton.titleLabel sizeToFit];
                [self.midButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, self.midButton.titleLabel.width / 2 - self.midButton.width / 2 + self.midButton.imageView.width / 2 + 10.f, 0.f, -self.midButton.titleLabel.width / 2 + self.midButton.width / 2 - self.midButton.imageView.width / 2 - 10.f)];
                [self.midButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, -self.midButton.imageView.width, 0.f, 0.f)];
                [self.centerView addSubview:self.midButton];
            }
            
            if (!self.bottomButton.hidden) {
                self.bottomButton.frame = CGRectMake(30.f, 0, 210.f, 40.f);
                self.bottomButton.top = !self.midButton.hidden ? (self.midButton.bottom + 12.f) : (self.topButton.bottom + 12.f);
                [self.bottomButton.titleLabel sizeToFit];
                [self.bottomButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, self.bottomButton.titleLabel.width / 2 - self.bottomButton.width / 2 + self.bottomButton.imageView.width / 2 + 10.f, 0.f, -self.bottomButton.titleLabel.width / 2 + self.bottomButton.width / 2 - self.bottomButton.imageView.width / 2 - 10.f)];
                [self.bottomButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, -self.bottomButton.imageView.width, 0.f, 0.f)];
                [self.centerView addSubview:self.bottomButton];
            }
        } else {
            // iphone 5s
            self.centerView.frame = CGRectMake(0.0f, 0.0f, [TTDeviceUIUtils tt_newPadding:270.f], [TTDeviceUIUtils tt_newPadding:340.f] - controlledHidePlatformButtons * [TTDeviceUIUtils tt_newPadding:(40 + 12)]);
            CGFloat centerViewWidth = self.centerView.frame.size.width;
            
            self.titleLabel.frame = CGRectMake(10.f, [TTDeviceUIUtils tt_newPadding:55.f], centerViewWidth - 20.f, [TTDeviceUIUtils tt_newPadding:17.f]);
            self.titleLabel.centerX = centerViewWidth / 2;
            [self.titleLabel setAttributedText:[self.class attributedStringWithString:titleString fontSize:[TTDeviceUIUtils tt_newFontSize:17] lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
            
            self.cancelBtn.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:238.f], [TTDeviceUIUtils tt_newPadding:8.f], [TTDeviceUIUtils tt_newPadding:24], [TTDeviceUIUtils tt_newPadding:24]);
            
            self.tipBtn.frame = CGRectMake(10.f, [TTDeviceUIUtils tt_newPadding:286.f], centerViewWidth - 20.f, [TTDeviceUIUtils tt_newPadding:14.f]);
            self.tipBtn.bottom = (CGRectGetHeight(self.centerView.frame) - 40 /* 340 - (286 + 14) */);
            
            self.topButton.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:30.F], 0, [TTDeviceUIUtils tt_newPadding:210.f], [TTDeviceUIUtils tt_newPadding:40.f]);
            self.topButton.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:40.f];
            [self.topButton setTitle:@"手机登录" forState:UIControlStateNormal];
            [self.topButton.titleLabel sizeToFit];
            [self.topButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, self.topButton.titleLabel.width / 2 - self.topButton.width / 2 + self.topButton.imageView.width / 2 + 10.f, 0.f, -self.topButton.titleLabel.width / 2 + self.topButton.width / 2 - self.topButton.imageView.width / 2 - [TTDeviceUIUtils tt_newPadding:10.f])];
            [self.topButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, -self.topButton.imageView.width, 0.f, 0.f)];
            [self.centerView addSubview:self.topButton];
            
            if (!self.midButton.hidden) {
                self.midButton.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:30.f], 0, [TTDeviceUIUtils tt_newPadding:210.f], [TTDeviceUIUtils tt_newPadding:40.f]);
                self.midButton.top = self.topButton.bottom + [TTDeviceUIUtils tt_newPadding:12.f];
                [self.midButton.titleLabel sizeToFit];
                [self.midButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, self.midButton.titleLabel.width / 2 - self.midButton.width / 2 + self.midButton.imageView.width / 2 + 10.f, 0.f, -self.midButton.titleLabel.width / 2 + self.midButton.width / 2 - self.midButton.imageView.width / 2 - 10.f)];
                [self.midButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, -self.midButton.imageView.width, 0.f, 0.f)];
                [self.centerView addSubview:self.midButton];
            }
            
            if (!self.bottomButton.hidden) {
                self.bottomButton.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:30.f], 0, [TTDeviceUIUtils tt_newPadding:210.f], [TTDeviceUIUtils tt_newPadding:40.f]);
                self.bottomButton.top = !self.midButton.hidden ? (self.midButton.bottom + [TTDeviceUIUtils tt_newPadding:12.f]) : (self.topButton.bottom + [TTDeviceUIUtils tt_newPadding:12.f]);
                [self.bottomButton.titleLabel sizeToFit];
                [self.bottomButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, self.bottomButton.titleLabel.width / 2 - self.bottomButton.width / 2 + self.bottomButton.imageView.width / 2 + 10.f, 0.f, -self.bottomButton.titleLabel.width / 2 + self.bottomButton.width / 2 - self.bottomButton.imageView.width / 2 - 10.f)];
                [self.bottomButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, -self.bottomButton.imageView.width, 0.f, 0.f)];
                [self.centerView addSubview:self.bottomButton];
            }
        }
        
        //阻止TTAccountAlert接收大弹窗第三方登录的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableReceiveDismissNotification:) name:@"EnableReceiveDismissNotification" object:nil];
        
        // 快捷登录弹窗PV,记录
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker category:@"umeng" event:@"register_new" label:@"quick_login_show" dict:@{@"source":self.source ? : @"other"}];
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [TTTrackerWrapper eventV3:@"login_quick_show" params:extraDict isDoubleSending:YES];
    }
    return self;
}

- (instancetype)initPhoneNumberVerifyAlertWithActionType:(TTAccountLoginAlertActionType)type
                                                phoneNum:(NSString *)phoneNumString
                                                   title:(NSString *)titleString
                                             placeholder:(NSString *)placeholderString
                                                     tip:(NSString *)tipString
                                          cancelBtnTitle:(NSString *)cancelTitleString
                                         confirmBtnTitle:(NSString *)confirmBtnTitleString
                                                animated:(BOOL)animated
                                              completion:(TTAccountLoginAlertPhoneVerifyCompletionBlock)completedHandler
{
    if ((self = [super init])) {
        self.alertUIStyle = TTAccountLoginAlertUIStyleVerifyPhoneNum;
        self.actionType   = type;
        self.moreButtonRespAction = TTAccountLoginMoreActionRespModeCallback;
        
        self.phoneNumString = phoneNumString;
        self.phoneVerifyCompletedHandler = completedHandler;
        
        if (self.actionType == TTAccountLoginAlertActionTypePhoneNumSwitch) {
            
            self.centerView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width - 35, self.centerView.frame.size.height + 54);
            
            self.passwordTextField.frame = CGRectMake(kTTAccountAlertLeading, kTTAccountAlertTitleHeight + 54, self.centerView.frame.size.width - kTTAccountAlertLeading * 2, 36);
            self.passwordTextField.placeholder = @"请输入密码";
        }
        
        if (titleString) [self.titleLabel setAttributedText:[self.class attributedStringWithString:titleString fontSize:17.0f lineSpacing:17 * 0.4 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
        if (cancelTitleString) [self.cancelBtn setTitle:cancelTitleString forState:UIControlStateNormal];
        if (confirmBtnTitleString) [self.doneBtn setTitle:confirmBtnTitleString forState:UIControlStateNormal];
        if (tipString) [self.tipBtn setTitle:tipString forState:UIControlStateNormal];
        
        self.titleLabel.frame = CGRectMake(kTTAccountAlertLeading, 0.0f, self.centerView.frame.size.width - kTTAccountAlertLeading * 2, kTTAccountAlertTitleHeight);
        
        if (type != TTAccountLoginAlertActionTypePhoneNumSwitch) {
            self.firstTextField.frame = CGRectMake(kTTAccountAlertLeading, kTTAccountAlertTitleHeight, self.centerView.frame.size.width - kTTAccountAlertLeading * 2, 36);
            self.firstTextField.placeholder = placeholderString;
            self.firstTextField.edgeInsets = UIEdgeInsetsMake(0, 11, 0, 120);
            [self.firstTextField becomeFirstResponder];
        } else {
            self.secondTextField.frame = CGRectMake(kTTAccountAlertLeading, kTTAccountAlertTitleHeight, self.centerView.frame.size.width - kTTAccountAlertLeading * 2, 36);
            self.secondTextField.keyboardType = UIKeyboardTypeNumberPad;
            self.secondTextField.placeholder = placeholderString;
            self.secondTextField.edgeInsets = UIEdgeInsetsMake(0, 11, 0, 120);
            [self.secondTextField becomeFirstResponder];
            self.firstTextField.hidden = YES;
            
            self.errorLabel.top = self.passwordTextField.bottom + 8;
            self.errorLabel.left = self.passwordTextField.left;
        }
        
        _codeInvalidImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(193, 75, 16, 16.0f)];
        _codeInvalidImageView.imageName = @"error_sdk_login";
        _codeInvalidImageView.hidden = YES;
        [self.centerView addSubview:_codeInvalidImageView];
        
        self.resendSecond = kTTAccountResendDuration;
        
        self.resendBtn.frame = CGRectMake(210, 65, 110, 36.0f);
        self.resendBtn.titleColorThemeKey = kColorText3;
        
        if ([self devieTypeSwitch] == 1) {
            self.resendBtn.titleLabel.font = [UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone6s];
        } else if ([self devieTypeSwitch] == 0) {
            self.resendBtn.titleLabel.font = [UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone5s];
        } else if ([self devieTypeSwitch] == -1) {
            self.resendBtn.titleLabel.font = [UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone4s];
        }
        
        [self.resendBtn setTitle:[NSString stringWithFormat:@"重新发送(%@s)", @(self.resendSecond).stringValue] forState:UIControlStateNormal];
        self.resendBtn.enabled = NO;
        [self.resendBtn sizeToFit];
        self.resendBtn.height = MAX(44, CGRectGetHeight(self.resendBtn.bounds));
        self.resendBtn.right = CGRectGetMaxX(self.firstTextField.frame) - 11;
        self.resendBtn.centerY = self.firstTextField.centerY;
        
        self.resendTimer = [TTNoRetainRefNSTimer timerWithTimeInterval:1
                                                                target:self
                                                              selector:@selector(updateTimeDidFireTimer:)
                                                              userInfo:nil
                                                               repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.resendTimer forMode:NSRunLoopCommonModes];
        
        self.doneBtn.titleColorThemeKey = kColorText3;
        
        //发送验证码
        [self resendBtnTouched:nil];
    }
    return self;
}

- (instancetype)initResetPasswordAlertWithActionType:(TTAccountLoginAlertActionType)type
                                               title:(NSString *)titleString
                                         placeholder:(NSString *)placeholderString
                                                 tip:(NSString *)tipString
                                      cancelBtnTitle:(NSString *)cancelTitleString
                                     confirmBtnTitle:(NSString *)confirmBtnTitleString
                                            animated:(BOOL)animated
                                          completion:(TTAccountLoginAlertResetPasswordCompletionBlock)completedHandler
{
    if ((self = [super init])) {
        self.alertUIStyle = TTAccountLoginAlertUIStyleResetPassword;
        self.actionType = type;
        self.moreButtonRespAction = TTAccountLoginMoreActionRespModeCallback;
        
        self.resetPasswordCompletedHandler = completedHandler;
        
        if (titleString) [self.titleLabel setAttributedText:[self.class attributedStringWithString:titleString fontSize:17.0f lineSpacing:17 * 0.4 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
        if (cancelTitleString) [self.cancelBtn setTitle:cancelTitleString forState:UIControlStateNormal];
        if (confirmBtnTitleString) [self.doneBtn setTitle:confirmBtnTitleString forState:UIControlStateNormal];
        if (tipString) [self.tipBtn setTitle:tipString forState:UIControlStateNormal];
        
        self.titleLabel.frame = CGRectMake(kTTAccountAlertLeading, 0.0f, self.centerView.frame.size.width - kTTAccountAlertLeading * 2, kTTAccountAlertTitleHeight);
        self.firstTextField.placeholder = placeholderString;
        [self.firstTextField becomeFirstResponder];
        
        self.doneBtn.titleColorThemeKey = kColorText3;
    }
    return self;
}

- (void)show
{
    [self showInView:nil];
}

- (void)showInView:(UIView *)superView
{
    [TTAccountLoginManager showLoginAlert];
    
    [super showInView:superView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAccountAlert:) name:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil];
}

- (void)hide
{
    [self.resendTimer invalidate];
    
    [super hide];
}

#pragma mark - notifications

- (void)enableReceiveDismissNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    self.enableSendTrack = [userInfo tt_boolValueForKey:@"enable"];
}

- (void)dismissAccountAlert:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    //    if (userInfo && [[userInfo tt_stringValueForKey:@"source"] isEqualToString:@"phoneNumber"]) {
    //        if (self.phoneInputCompletedHandler) {
    //            self.phoneInputCompletedHandler(TTAccountAlertCompletionEventTypeDone, @"");
    //        }
    //        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil];
    //        [self hide];
    //        return;
    //    }
    
    if (userInfo && self.enableSendTrack) {
        if ([[userInfo tt_stringValueForKey:@"source"] isEqualToString:TT_LOGIN_PLATFORM_SINAWEIBO]) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                ttTrackEventWithCustomKeys(@"register_new", @"quick_login_success_weibo", nil, self.source, nil);
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"sinaweibo" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_quick_success" params:extraDict isDoubleSending:YES];
            
        } else if ([[userInfo tt_stringValueForKey:@"source"] isEqualToString:TT_LOGIN_PLATFORM_WECHAT]) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                ttTrackEventWithCustomKeys(@"register_new", @"quick_login_success_weixin", nil, self.source, nil);
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"weixin" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_quick_success" params:extraDict isDoubleSending:YES];
            
        } else if ([[userInfo tt_stringValueForKey:@"source"] isEqualToString:TT_LOGIN_PLATFORM_QZONE]) {
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                ttTrackEventWithCustomKeys(@"register_new", @"quick_login_success_qq", nil, self.source, nil);
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"qq" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_quick_success" params:extraDict isDoubleSending:YES];
        }  else if ([[userInfo tt_stringValueForKey:@"source"] isEqualToString:TT_LOGIN_PLATFORM_HUOSHAN]) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"hotsoon" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_quick_success" params:extraDict];
        } else if ([[userInfo tt_stringValueForKey:@"source"] isEqualToString:TT_LOGIN_PLATFORM_DOUYIN]) {
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"douyin" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_quick_success" params:extraDict];
        }
    }
    
    if (self.phoneInputCompletedHandler) {
        self.phoneInputCompletedHandler(TTAccountAlertCompletionEventTypeDone, @"");
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil];
    [self hide];
}

#pragma mark - Third Party Platform Style

- (void)setQQStyle:(TTAlphaThemedButton *)button
{
    [button setTitle:@"QQ登录" forState:UIControlStateNormal];
    [button setTitleColors:@[@"68A5E1", @"43698F"]];
    [button setBorderColors:@[@"68A5E1", @"43698F"]];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        [button setImage:[UIImage imageNamed:@"qq_pop_ups"] forState:UIControlStateNormal];
    } else {
        [button setImage:[UIImage imageNamed:@"qq_pop_ups_night"] forState:UIControlStateNormal];
    }
}

- (void)setWeChatStyle:(TTAlphaThemedButton *)button
{
    [button setTitle:@"微信登录" forState:UIControlStateNormal];
    [button setTitleColors:@[@"3CB033", @"40813B"]];
    [button setBorderColors:@[@"3CB033", @"40813B"]];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        [button setImage:[UIImage imageNamed:@"weixin_pop_ups"] forState:UIControlStateNormal];
    } else {
        [button setImage:[UIImage imageNamed:@"weixin_pop_ups_night"] forState:UIControlStateNormal];
    }
}

- (void)setWeiboStyle:(TTAlphaThemedButton *)button
{
    [button setTitle:@"微博登录" forState:UIControlStateNormal];
    [button setTitleColors:@[@"FFBE00", @"927112"]];
    [button setBorderColors:@[@"FFBE00", @"927112"]];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        [button setImage:[UIImage imageNamed:@"weibo_pop_ups"] forState:UIControlStateNormal];
    } else {
        [button setImage:[UIImage imageNamed:@"weibo_pop_ups_night"] forState:UIControlStateNormal];
    }
}

- (void)setDouYinStyle:(TTAlphaThemedButton *)button
{
    [button setTitle:@"抖音登录" forState:UIControlStateNormal];
    [button setTitleColors:@[@"bfa1d0", @"5f5068"]];
    [button setBorderColors:@[@"bfa1d0", @"5f5068"]];
    [button setTitleColors:@[@"bfa1d0", @"5f5068"]];
    [button setBorderColors:@[@"bfa1d0", @"5f5068"]];
    button.imageName = @"douyin_icon";
}

- (void)setHuoShanStyle:(TTAlphaThemedButton *)button
{
    [button setTitle:@"火山小视频登录" forState:UIControlStateNormal];
    [button setTitleColors:@[@"E7AD70", @"735648"]];
    [button setBorderColors:@[@"E7AD70", @"735648"]];
    button.imageName = @"huoshan_icon";
}

#pragma - Button Actions

- (void)tipBtnTouched:(id)sender
{
    // 快捷登录界面，记录 点击“更多登录方式”的量
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTracker category:@"umeng" event:@"register_new" label:@"quick_login_click_more" dict:@{@"source":self.source}];
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:self.source forKey:@"source"];
    [extraDict setValue:@"more" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_quick_click" params:extraDict isDoubleSending:YES];
    
    if (self.phoneVerifyCompletedHandler) {
        self.phoneVerifyCompletedHandler(TTAccountAlertCompletionEventTypeTip);
    }
    
    if (self.moreButtonRespAction == TTAccountLoginMoreActionRespModeBigLoginPanel) {
        [TTAccountLoginManager presentLoginViewControllerFromVC:self.viewController type:TTAccountLoginDialogTitleTypeDefault source:self.source completion:^(TTAccountLoginState state) {
            
        }];
    } else {
        if (self.phoneInputCompletedHandler) {
            //快捷登录弹窗点其他方式登录
            // [self hide];
            self.phoneInputCompletedHandler(TTAccountAlertCompletionEventTypeTip, @"");
        }
    }
    
    if (self.resetPasswordCompletedHandler) {
        self.resetPasswordCompletedHandler(TTAccountAlertCompletionEventTypeTip, @"");
    }
    [super tipBtnTouched:sender];
}

- (void)cancelBtnTouched:(id)sender
{
    if (!self.source) self.source = @"other";
    
    // 快捷登录界面，记录 点击“关闭小弹窗”的量
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTracker category:@"umeng" event:@"register_new" label:@"quick_login_close" dict:@{@"source":self.source }];
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:self.source forKey:@"source"];
    [TTTrackerWrapper eventV3:@"login_quick_close" params:extraDict isDoubleSending:YES];
    
    if (self.phoneVerifyCompletedHandler) {
        //快捷登录弹窗填验证码阶段返回上一步
        self.phoneVerifyCompletedHandler(TTAccountAlertCompletionEventTypeCancel);
    }
    if (self.phoneInputCompletedHandler) {
        //快捷登录弹窗点跳过
        self.phoneInputCompletedHandler(TTAccountAlertCompletionEventTypeCancel,@"");
    }
    if (self.resetPasswordCompletedHandler) {
        self.resetPasswordCompletedHandler(TTAccountAlertCompletionEventTypeCancel,@"");
    }
    [super cancelBtnTouched:sender];
}

- (void)doneBtnTouched:(id)sender
{
    // 快捷登录弹窗，记录 点击“进入头条”的量
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTracker category:@"umeng" event:@"register_new" label:@"quick_login_click_confirm" dict:@{@"source":self.source}];
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:self.source forKey:@"source"];
    [extraDict setValue:@"confirm" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_quick_click" params:extraDict isDoubleSending:YES];
    
    __weak typeof(self) wself = self;
    switch (self.alertUIStyle) {
        case TTAccountLoginAlertUIStylePlain: {
            
            if (self.tapCompletedHandler) {
                self.tapCompletedHandler(TTAccountAlertCompletionEventTypeDone);
            }
            break;
        }
        case TTAccountLoginAlertUIStylePhoneNumInput: {
            
            switch (self.actionType) {
                    
                case TTAccountLoginAlertActionTypeLogin: {
                    
                    // 主要是快捷登录的弹窗
                    if (self.firstTextField.text.length == 0 && self.secondTextField.text.length == 0) {
                        // 如果没有任何输入时，点击doneBtn会在phoneErrorLabel上显示“手机号错误”
                        [self.phoneErrorLabel setAttributedText:[self.class attributedStringWithString:@"手机号错误" fontSize:11.0f lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]];
                    }
                    
                    if ([self validateMobileNumber:self.firstTextField.text]) {
                        self.phoneErrorLabel.text = @"";
                    }
                    
                    if ([self validateMobileNumber:self.firstTextField.text] && self.secondTextField.text.length == 0) {
                        // 如果此时 firstTextField的手机号有效，而 secondTextField 没有输入内容，则phoneErrorLabel显示“验证码错误”
                        [self.errorLabel setAttributedText:[self.class attributedStringWithString:@"验证码错误" fontSize:11.0f lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]];
                    }
                    
                    if ([self validateMobileNumber:self.firstTextField.text] && self.secondTextField.text.length > 0) {
                        //快捷登录弹窗手机号正确点下一步
                        [self quickLogin];
                    } else {
                        // 显示手机号错误
                        [self.phoneErrorLabel setAttributedText:[self.class attributedStringWithString:@"手机号错误" fontSize:11.0f lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]];
                        
                        if ([self validateMobileNumber:self.firstTextField.text]) {
                            self.phoneErrorLabel.text = @"";
                        }
                        
                        [self codeInvalide];
                    }
                }
                    break;
                case TTAccountLoginAlertActionTypeBind: {
                    
                    if ([self validateMobileNumber:self.firstTextField.text]) {
                        [self phoneBind];
                    } else {
                        [self codeInvalide];
                        [self.tipBtn setTitle:@"手机号错误" forState:UIControlStateNormal];
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case TTAccountLoginAlertUIStyleVerifyPhoneNum: {
            
            switch (self.actionType) {
                    
                case TTAccountLoginAlertActionTypePlain: {
                    break;
                }
                case TTAccountLoginAlertActionTypeLogin: {
                    
                    if (self.firstTextField.text.length == 0) {
                        [self.tipBtn setTitle:@"请输入验证码" forState:UIControlStateNormal];
                    } else {
                        [self quickLogin];
                    }
                    break;
                }
                case TTAccountLoginAlertActionTypeBind: {
                    
                    if (self.firstTextField.text.length == 0) {
                        [self.tipBtn setTitle:@"请输入验证码" forState:UIControlStateNormal];
                    } else if (self.passwordTextField.text.length == 0) {
                        [self.tipBtn setTitle:@"请输入密码" forState:UIControlStateNormal];
                    } else {
                        //绑定手机号时提示已绑定其他账号， 确认放弃原账号
                        ttTrackEvent(@"login", @"binding_mobile_abandon_confirm");
                        [self phoneNumSwitch];
                    }
                    break;
                }
                case TTAccountLoginAlertActionTypePhoneNumSwitch: {
                    
                    if (self.secondTextField.text.length == 0) {
                        [self.tipBtn setTitle:@"请输入验证码" forState:UIControlStateNormal];
                    } else if (self.passwordTextField.text.length == 0) {
                        [self.tipBtn setTitle:@"请输入密码" forState:UIControlStateNormal];
                    } else {
                        //绑定手机号时提示已绑定其他账号， 确认放弃原账号
                        ttTrackEvent(@"login", @"binding_mobile_abandon_confirm");
                        [self phoneNumSwitch];
                    }
                    
                    break;
                }
                case TTAccountLoginAlertActionTypeResetPassword: {
                    
                    if (self.firstTextField.text.length == 0) {
                        [self.tipBtn setTitle:@"请输入验证码" forState:UIControlStateNormal];
                    }
                    else {
                        __block TTAccountLoginAlert *alert = [[TTAccountLoginAlert alloc] initResetPasswordAlertWithActionType:TTAccountLoginAlertActionTypeResetPassword title:@"输入密码" placeholder:@"密码是xxx" tip:@"请输入密码" cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString *password) {
                            
                            if (type == TTAccountAlertCompletionEventTypeCancel) {
                                wself.phoneVerifyCompletedHandler(TTAccountAlertCompletionEventTypeCancel);
                            } else if (type == TTAccountAlertCompletionEventTypeDone) {
                                [wself hide];
                                if (wself.phoneVerifyCompletedHandler) {
                                    wself.phoneVerifyCompletedHandler(TTAccountAlertCompletionEventTypeDone);
                                }
                            }
                        }];
                        alert.verifyCode = self.firstTextField.text;
                        [alert show];
                    }
                }
                    break;
            }
        }
            break;
        case TTAccountLoginAlertUIStyleResetPassword: {
            
            if (self.firstTextField.text.length == 0) {
                [self.tipBtn setTitle:@"请输入密码" forState:UIControlStateNormal];
            } else {
                [self resetPassword];
            }
            break;
        }
        default: {
            break;
        }
    }
}

- (UIView *)statusBarWindow
{
    UIView *statusBar = nil;
    NSData *data = [NSData dataWithBytes:(unsigned char[]) { 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72 } length:9];
    NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    id object = [UIApplication sharedApplication];
    if ([object respondsToSelector:NSSelectorFromString(key)]) {
        statusBar = [object valueForKey:key];
    }
    return statusBar;
}

#pragma mark - 业务逻辑

- (void)phoneBind
{
    __weak typeof(self) wself = self;
    [TTAccount sendSMSCodeWithPhone:self.firstTextField.text captcha:self.captchaString SMSCodeType:TTASMSCodeScenarioBindPhone unbindExist:NO completion:^(NSNumber * _Nullable retryTime, UIImage * _Nullable captchaImage, NSError * _Nullable error) {
        
        if (!error && !captchaImage) {
            __block TTAccountLoginAlert *alert = [[TTAccountLoginAlert alloc] initPhoneNumberVerifyAlertWithActionType:TTAccountLoginAlertActionTypeLogin phoneNum:self.firstTextField.text title:@"验证手机号" placeholder:@"验证码" tip:[NSString stringWithFormat:@"已向%@发送验证码", self.firstTextField.text] cancelBtnTitle:@"上一步" confirmBtnTitle:@"确定" animated:NO completion:^(TTAccountAlertCompletionEventType type) {
                
                if (type == TTAccountAlertCompletionEventTypeCancel) {
                    
                    if (wself.phoneInputCompletedHandler) {
                        wself.phoneInputCompletedHandler(TTAccountAlertCompletionEventTypeCancel, @"hhh");
                    }
                    
                } else if (type == TTAccountAlertCompletionEventTypeDone) {
                    
                    [wself hide];
                    if (wself.phoneInputCompletedHandler) {
                        wself.phoneInputCompletedHandler(TTAccountAlertCompletionEventTypeDone, @"hhh");
                    }
                }
            }];
            alert.phoneNumString = wself.firstTextField.text;
            [alert show];
        } else {
            if (captchaImage) {
                TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString *captchaStr) {
                    
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        wself.captchaString = captchaStr;
                        [wself phoneBind];
                    }
                }];
                [cAlert show];
            } else {
                [wself.errorLabel setAttributedText:[wself.class attributedStringWithString:error.userInfo[@"description"] fontSize:11.0f lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]];
            }
        }
    }];
}

// 快速登录
- (void)quickLogin
{
    __weak typeof(self) wself = self;
    [TTAccount quickLoginWithPhone:self.phoneNumString SMSCode:self.secondTextField.text captcha:self.captchaString completion:^(UIImage * _Nullable captchaImage, NSError * _Nullable error) {
        
        BOOL isNewUser = [[TTAccount sharedAccount] user].newUser;
        
        if (!error) {
            [wself hide];
            if (wself.phoneInputCompletedHandler) {
                //快捷登录弹窗成功登录
                wself.phoneInputCompletedHandler(TTAccountAlertCompletionEventTypeDone, wself.phoneNumString);
            }
            
            // 小弹窗登录成功埋点
            if (!self.source) self.source = @"other";
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                [TTTracker category:@"umeng" event:@"register_new" label:@"quick_login_success" dict:@{@"source":self.source}];
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"quick" forKey:@"type"];
            [TTTrackerWrapper eventV3:@"login_quick_click" params:extraDict isDoubleSending:YES];
            
            if (isNewUser) {
                TTAccountLoginEditProfileViewController *editUserInfoVC = [[TTAccountLoginEditProfileViewController alloc] initWithSource:wself.source];
                // 设置新用户信息
                [wself.navigationController pushViewController:editUserInfoVC animated:YES];
            }
            
        } else {
            // 快捷登录弹窗验证码错误点验证
            if (captchaImage) {
                TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString *captchaStr) {
                    
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        wself.captchaString = captchaStr;
                        [wself quickLogin];
                    }
                }];
                [cAlert show];
                
            } else {
                
                if (wself.alertUIStyle == TTAccountLoginAlertActionTypeLogin) {
                    [wself.errorLabel setAttributedText:[wself.class attributedStringWithString:@"验证码错误" fontSize:11.0f lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]];
                    // 将doneBtn设置为0.5f灰度透明
                    wself.doneBtn.alpha = 0.5f;
                } else {
                    [wself.phoneErrorLabel setAttributedText:[wself.class attributedStringWithString:error.userInfo[@"description"] fontSize:11.0f lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]];
                }
            }
        }
    }];
}

- (void)phoneNumSwitch
{
    __weak typeof(self) wself = self;
    [TTAccount bindPhoneWithPhone:self.phoneNumString SMSCode:self.secondTextField.text password:self.passwordTextField.text captcha:self.captchaString unbind:YES completion:^(UIImage * _Nullable captchaImage, NSError * _Nullable error) {
        
        if (!error) {
            [wself hide];
            if (wself.phoneVerifyCompletedHandler) {
                wself.phoneVerifyCompletedHandler(TTAccountAlertCompletionEventTypeDone);
            }
        } else {
            if (captchaImage) {
                TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString *captchaStr) {
                    
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        wself.captchaString = captchaStr;
                        [wself phoneNumSwitch];
                    }
                }];
                [cAlert show];
                
            } else {
                [wself.tipBtn setTitle:[error.userInfo tt_stringValueForKey:@"description"] forState:UIControlStateNormal];
            }
        }
    }];
}

- (void)resetPassword
{
    __weak typeof(self) wself = self;
    [TTAccount modifyPasswordWithNewPassword:self.firstTextField.text SMSCode:self.verifyCode captcha:self.captchaString completion:^(UIImage *captchaImage, NSError *error) {
        
        if (!error) {
            [wself hide];
            if (wself.resetPasswordCompletedHandler) {
                wself.resetPasswordCompletedHandler(TTAccountAlertCompletionEventTypeDone,wself.firstTextField.text);
            }
        } else {
            
            if (captchaImage) {
                TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString *captchaStr) {
                    
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        wself.captchaString = captchaStr;
                        [wself resetPassword];
                    }
                }];
                [cAlert show];
                
            } else {
                [wself.phoneErrorLabel setAttributedText:[self.class attributedStringWithString:error.userInfo[@"description"] fontSize:11.0f lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]];
            }
        }
    }];
}

- (void)resendBtnTouched:(id)sender
{
    // 快捷登录窗口，发送短信验证码的量
    // LogV1
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTracker category:@"umeng" event:@"register_new" label:@"quick_login_send_auth" dict:@{@"source":self.source}];
    }
    // LogV3
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:self.source forKey:@"source"];
    [extraDict setValue:@"send_auth" forKey:@"action_type"];
    [TTTrackerWrapper eventV3:@"login_quick_click" params:extraDict isDoubleSending:YES];
    
    // 在任何情况下，只要点击了resendBtn，errorLabel不会再显示“验证码错误”，没有显示内容
    self.errorLabel.text = @"";
    self.secondTextField.text = @"";
    
    if ((self.actionType == TTAccountLoginAlertActionTypeLogin || self.actionType == TTAccountLoginAlertActionTypeBind) && ![self validateMobileNumber:self.firstTextField.text]) {
        // 点击“发送验证码”按钮，如果验证码无效，判断手机号为错误
        [self.phoneErrorLabel setAttributedText:[self.class attributedStringWithString:@"手机号错误" fontSize:11.0f lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]];
        [self codeInvalide];
    } else {
        // 如果有效，是正确的手机号，phoneErrorLabel没有显示内容, 此时 secondTextField成为第一响应者
        self.phoneErrorLabel.text = @"";
        [self.secondTextField becomeFirstResponder];
        
        TTASMSCodeScenarioType smsCodeType = TTASMSCodeScenarioBindPhoneRetry;
        if (self.actionType == TTAccountLoginAlertActionTypeLogin) {
            //快捷登录弹窗重发验证码
            smsCodeType = TTASMSCodeScenarioQuickLoginRetry;
        } else if (self.actionType == TTAccountLoginAlertActionTypePhoneNumSwitch) {
            smsCodeType = TTASMSCodeScenarioBindPhoneRetry;
        } else if (self.actionType == TTAccountLoginAlertActionTypeResetPassword) {
            smsCodeType = TTASMSCodeScenarioChangePasswordRetry;
        }
        
        if (self.actionType == TTAccountLoginAlertActionTypeLogin || self.actionType == TTAccountLoginAlertActionTypeBind) {
            self.phoneNumString = self.firstTextField.text;
        }
        __weak typeof(self) wself = self;
        [TTAccount sendSMSCodeWithPhone:self.phoneNumString captcha:self.captchaString SMSCodeType:smsCodeType unbindExist:(self.actionType == TTAccountLoginAlertActionTypePhoneNumSwitch ? YES : NO) completion:^(NSNumber *retryTime, UIImage *captchaImage, NSError *error) {
            
            if (!error) {
                [wself.resendTimer invalidate];
                wself.resendTimer = nil;
                wself.resendSecond = kTTAccountResendDuration;
                
                if ([wself devieTypeSwitch] == 1) {
                    wself.resendBtn.titleLabel.font = [UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone6s];
                } else if ([wself devieTypeSwitch] == 0) {
                    wself.resendBtn.titleLabel.font = [UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone5s];
                } else if ([wself devieTypeSwitch] == -1) {
                    wself.resendBtn.titleLabel.font = [UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone4s];
                }
                
                [wself.resendBtn setTitle:[NSString stringWithFormat:@"重新发送(%@s)",@(wself.resendSecond).stringValue] forState:UIControlStateNormal];
                wself.resendBtn.titleColorThemeKey = kColorText3;
                [wself.resendBtn sizeToFit];
                wself.resendBtn.height = MAX(44, CGRectGetHeight(self.resendBtn.bounds));
                wself.resendBtn.right = CGRectGetMaxX(self.firstTextField.frame) - 11;
                wself.resendBtn.centerY = self.firstTextField.centerY;
                
                wself.resendTimer = [TTNoRetainRefNSTimer timerWithTimeInterval:1
                                                                         target:wself
                                                                       selector:@selector(updateTimeDidFireTimer:)
                                                                       userInfo:nil
                                                                        repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:wself.resendTimer forMode:NSRunLoopCommonModes];
                
            } else {
                [wself.resendTimer invalidate];
                wself.resendTimer = nil;
                wself.resendSecond = 0;
                [wself updateTimeDidFireTimer:nil];
                
                if (captchaImage) {
                    TTAccountCaptchaAlert *cAlert = [[TTAccountCaptchaAlert alloc] initWithTitle:@"请输入图片中的字符" captchaImage:captchaImage placeholder:nil cancelBtnTitle:@"取消" confirmBtnTitle:@"确定" animated:YES completion:^(TTAccountAlertCompletionEventType type, NSString *captchaStr) {
                        
                        if (type == TTAccountAlertCompletionEventTypeDone) {
                            wself.captchaString = captchaStr;
                            [wself resendBtnTouched:nil];
                        }
                    }];
                    [cAlert show];
                } else {
                    [wself.errorLabel setAttributedText:[wself.class attributedStringWithString:error.userInfo[@"description"] fontSize:11.0f lineSpacing:0 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft]];
                }
            }
        }];
    }
}

- (void)updateTimeDidFireTimer:(NSTimer *)timer
{
    self.resendSecond--;
    if (self.resendSecond <= 0) {
        self.resendSecond = 0;
        // 判断设备
        if ([self devieTypeSwitch] == 1) {
            [self.resendBtn.titleLabel setFont:[UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone6s]];
        } else if ([self devieTypeSwitch] == 0) {
            [self.resendBtn.titleLabel setFont:[UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone5s]];
        } else if ([self devieTypeSwitch] == -1) {
            [self.resendBtn.titleLabel setFont:[UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone4s]];
        }
        [self.resendBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        [self.resendTimer invalidate];
        self.resendTimer = nil;
        
        self.resendBtn.enabled = YES;
        self.resendBtn.titleColorThemeKey = kColorText1;
        
    } else {
        if ([self devieTypeSwitch] == 1) {
            self.resendBtn.titleLabel.font = [UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone6s];
        } else if ([self devieTypeSwitch] == 0) {
            self.resendBtn.titleLabel.font = [UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone5s];
        } else if ([self devieTypeSwitch] == -1) {
            self.resendBtn.titleLabel.font = [UIFont systemFontOfSize:kTTAccountResendBtnFontSizeIphone4s];
        }
        
        self.resendBtn.enabled = NO;
        [self.resendBtn setTitle:[NSString stringWithFormat:@"重新发送(%@s)", @(self.resendSecond).stringValue] forState:UIControlStateNormal];
    }
    [self.resendBtn sizeToFit];
    self.resendBtn.height = MAX(44, CGRectGetHeight(self.resendBtn.bounds));
    self.resendBtn.right = CGRectGetMaxX(self.firstTextField.frame) - 11;
    self.resendBtn.centerY = self.firstTextField.centerY;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        // 修复7.0上不及时刷新BUG
        [self.resendBtn layoutIfNeeded];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldDidChange:(NSNotification *)notification
{
    // 一旦 firstTextField 或者 secondTextField 接收了输入，phoneErrorLabel此时就没有显示内容
    if (self.firstTextField.text.length > 0 || self.secondTextField.text.length > 0) {
        self.phoneErrorLabel.text = @"";
    }
    
    // 如果 secondTextField接收了输入，内容发生了改变，errorLabel就不会有显示内容
    if (self.secondTextField.text.length > 0) {
        self.errorLabel.text = @"";
    }
    
    if ((self.secondTextField.text.length < 4 || self.secondTextField.text.length > 4) &&
        self.actionType != TTAccountLoginAlertActionTypePhoneNumSwitch) {
        self.doneBtn.alpha = 0.5f;
    }
    
    if (self.firstTextField.text.length > 0 || self.secondTextField.text.length == 4) {
        
        if (_passwordTextField) {
            if (_passwordTextField.text.length >0 ) {
                self.doneBtn.titleColorThemeKey = kColorText6;
            } else {
                self.doneBtn.titleColorThemeKey = kColorText3;
                
            }
            self.doneBtn.alpha = 1.f;
        } else {
            if (self.alertUIStyle == TTAccountLoginAlertActionTypeLogin) {
                self.doneBtn.titleColorThemeKey = kColorText8;
            } else {
                self.doneBtn.titleColorThemeKey = kColorText6;
            }
        }
    } else {
        self.doneBtn.titleColorThemeKey = kColorText3;
    }
    
    // 如果 手机号输入的label验证为有效手机号，验证码输入的label的长度为4，说明是正常的输入，改变doneBtn的显示
    if ([self validateMobileNumber:self.firstTextField.text] && self.secondTextField.text.length == 4) {
        self.doneBtn.alpha = 1.0f;
    }
    
    return YES;
}

#pragma mark - Utils

- (void)codeInvalide
{
    _codeInvalidImageView.hidden = YES;
}

- (BOOL)validateMobileNumber:(NSString *)mobileNumber
{
    NSString *regex = @"^1\\d{10}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:mobileNumber]) {
        return YES;
    }
    return NO;
}

- (BOOL)installedWeixin
{
    return [TTAccountAuthWeChat isAppInstalled];
}

//- (BOOL)isHuoShanAvailable
//{
//    return [TTAccountAuthHuoShan isAppAvailable];
//}
//
//- (BOOL)isDouYinAvailable
//{
//    return [TTAccountAuthDouYin isAppAvailable];;
//}

#pragma mark - button Actions

- (void)actionDidTapButton:(TTAlphaThemedButton *)button
{
    if (!button) return;
    if (button.tag == 1001) {//微信登录
        if ([self installedWeixin]) {
            [TTAccountLoginManager requestLoginPlatformByType:TTAccountAuthTypeWeChat completion:^(BOOL success, NSError *error) {
                if (success && !error) {
                    NSString *platformName = [TTAccount platformNameForAccountAuthType:TTAccountAuthTypeWeChat];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": platformName ? : @""}];
                    
                    [TTAccountLoginManager setDefaultLoginUIStyleFor:TTAccountLoginStyleCaptcha];
                }
            }];
            
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                ttTrackEventWithCustomKeys(@"register_new", @"quick_login_weixin", nil, self.source, nil);
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"weixin" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_quick_click" params:extraDict isDoubleSending:YES];
        }
        else {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"登录失败 未检测到微信" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
    }
    else if (button.tag == 1002) {//QQ登录
        [TTAccountLoginManager requestLoginPlatformByType:TTAccountAuthTypeTencentQQ completion:^(BOOL success, NSError *error) {
            if (success && !error) {
                NSString *platformName = [TTAccount platformNameForAccountAuthType:TTAccountAuthTypeTencentQQ];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": platformName ? : @""}];
                
                [TTAccountLoginManager setDefaultLoginUIStyleFor:TTAccountLoginStyleCaptcha];
            }
        }];
        
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            ttTrackEventWithCustomKeys(@"register_new", @"quick_login_qq", nil, self.source, nil);
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"qq" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_quick_click" params:extraDict isDoubleSending:YES];
    }
    else if (button.tag == 1003) {//新浪微博
        [TTAccountLoginManager requestLoginPlatformByType:TTAccountAuthTypeSinaWeibo completion:^(BOOL success, NSError *error) {
            if (success && !error) {
                NSString *platformName = [TTAccount platformNameForAccountAuthType:TTAccountAuthTypeSinaWeibo];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": platformName ? : @""}];
                
                [TTAccountLoginManager setDefaultLoginUIStyleFor:TTAccountLoginStyleCaptcha];
            }
        }];
        
        // LogV1
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            ttTrackEventWithCustomKeys(@"register_new", @"quick_login_weibo", nil, self.source, nil);
        }
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"weibo" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_quick_click" params:extraDict isDoubleSending:YES];
    }
    else if (button.tag == 1004) {//火山小视频
        [TTAccountLoginManager requestLoginPlatformByType:TTAccountAuthTypeHuoshan completion:^(BOOL success, NSError *error) {
            if (success && !error) {
                NSString *platformName = [TTAccount platformNameForAccountAuthType:TTAccountAuthTypeHuoshan];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": platformName ? : @""}];
                
                [TTAccountLoginManager setDefaultLoginUIStyleFor:TTAccountLoginStyleCaptcha];
            }
        }];
        
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"hotsoon" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_quick_click" params:extraDict];
    }
    else if (button.tag == 1005) {//抖音登录
        [TTAccountLoginManager requestLoginPlatformByType:TTAccountAuthTypeDouyin completion:^(BOOL success, NSError *error) {
            if (success && !error) {
                NSString *platformName = [TTAccount platformNameForAccountAuthType:TTAccountAuthTypeDouyin];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_MASK_AFTER_LOGIN_SUCCESS" object:nil userInfo:@{@"source": platformName ? : @""}];
                
                [TTAccountLoginManager setDefaultLoginUIStyleFor:TTAccountLoginStyleCaptcha];
            }
        }];
        
        // LogV3
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:self.source forKey:@"source"];
        [extraDict setValue:@"douyin" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"login_quick_click" params:extraDict];
    }
}

#pragma mark - Getters

- (SSThemedTextField *)firstTextField
{
    if (!_firstTextField) {
        _firstTextField = [[SSThemedTextField alloc] initWithFrame:CGRectMake(20.0f, 60.0f, self.centerView.frame.size.width-40, 44.0f)];
        // _firstTextField.layer.borderWidth = 0.5f;
        // _firstTextField.borderColorThemeKey = kColorLine9;
        _firstTextField.edgeInsets = UIEdgeInsetsMake(0, 11, 0, 11);
        _firstTextField.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_padding:16]];
        _firstTextField.delegate = self;
        _firstTextField.tintColor = [UIColor blueColor];
        // _firstTextField.textColorThemeKey = kColorText9;
        // _firstTextField.edgeInsets = UIEdgeInsetsMake(0, 11, 0, 11);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_firstTextField];
        
        [self.centerView addSubview:_firstTextField];
    }
    return _firstTextField;
}

- (SSThemedView *)phoneSplitVerifyBtnView
{
    if (!_phoneSplitVerifyBtnView) {
        _phoneSplitVerifyBtnView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        [self.centerView addSubview:_phoneSplitVerifyBtnView];
    }
    return _phoneSplitVerifyBtnView;
}

- (SSThemedButton *)resendBtn
{
    if (!_resendBtn) {
        _resendBtn = [[SSThemedButton alloc] initWithFrame:CGRectMake(self.phoneSplitVerifyBtnView.frame.origin.x + [TTDeviceUIUtils tt_padding:15], self.phoneSplitVerifyBtnView.frame.origin.y + 1, [TTDeviceUIUtils tt_padding:70], [TTDeviceUIUtils tt_padding:14])];
        _resendBtn.titleColorThemeKey = kColorText1;
        [_resendBtn addTarget:self action:@selector(resendBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.centerView addSubview:_resendBtn];
    }
    return _resendBtn;
}

- (SSThemedView *)phoneSplitVerifyView
{
    if (!_phoneSplitVerifyView) {
        _phoneSplitVerifyView = [[SSThemedView alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_padding:30.0f], self.firstTextField.frame.origin.y + [TTDeviceUIUtils tt_padding:5] + [TTDeviceUIUtils tt_padding:16], [TTDeviceUIUtils tt_padding:210],1)];
        
        [self.centerView addSubview:_phoneSplitVerifyView];
    }
    return _phoneSplitVerifyView;
}

- (SSThemedTextField *)secondTextField
{
    if (!_secondTextField) {
        _secondTextField = [[SSThemedTextField alloc] initWithFrame:CGRectMake(20.0f, 60.0f, self.centerView.frame.size.width - 40, 44.0f)];
        _secondTextField.layer.borderWidth = 0.5f;
        _secondTextField.borderColorThemeKey = kColorLine9;
        _secondTextField.edgeInsets = UIEdgeInsetsMake(0, 11, 0, 11);
        _secondTextField.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        _secondTextField.delegate = self;
        _secondTextField.tintColor = [UIColor blueColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_secondTextField];
        
        [self.centerView addSubview:_secondTextField];
    }
    return _secondTextField;
}

- (SSThemedView *)verifySplitErrorView
{
    if (!_verifySplitErrorView) {
        _verifySplitErrorView = [[SSThemedView alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_padding:30.0f], self.secondTextField.frame.origin.y+self.secondTextField.frame.size.height+[TTDeviceUIUtils tt_padding:5],[TTDeviceUIUtils tt_padding:210], 1)];
        
        [self.centerView addSubview:_verifySplitErrorView];
    }
    return _verifySplitErrorView;
}

- (SSThemedLabel *)errorLabel
{
    if (!_errorLabel) {
        _errorLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_padding:30.0f], self.verifySplitErrorView.frame.origin.y+1+[TTDeviceUIUtils tt_padding:5], [TTDeviceUIUtils tt_padding:200], [TTDeviceUIUtils tt_padding:11])];
        _errorLabel.textAlignment = NSTextAlignmentLeft;
        // _errorLabel.textColorThemeKey = kColorText4;
        _errorLabel.numberOfLines = 0;
        
        [self.centerView addSubview:_errorLabel];
    }
    return _errorLabel;
}

- (SSThemedLabel *)phoneErrorLabel
{
    if (!_phoneErrorLabel) {
        _phoneErrorLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _phoneErrorLabel.textAlignment = NSTextAlignmentLeft;
        _phoneErrorLabel.numberOfLines = 0;
        
        [self.centerView addSubview:_phoneErrorLabel];
    }
    return _phoneErrorLabel;
}

- (SSThemedLabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_padding:68], self.errorLabel.frame.origin.y + [TTDeviceUIUtils tt_padding:11 + 15], self.centerView.frame.size.width - [TTDeviceUIUtils tt_padding:68] * 2, [TTDeviceUIUtils tt_padding:11])];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColorThemeKey = kColorText3;
        _tipLabel.numberOfLines = 0;
        
        [self.centerView addSubview:_tipLabel];
    }
    return _tipLabel;
}

- (SSThemedButton *)moreRegisterBtn
{
    if (!_moreRegisterBtn) {
        _moreRegisterBtn = [[SSThemedButton alloc] initWithFrame:CGRectMake(self.tipBtn.frame.origin.x+self.tipBtn.frame.size.width+[TTDeviceUIUtils tt_padding:3], self.tipBtn.frame.origin.y+[TTDeviceUIUtils tt_padding:3], 14, 14)];
        [_moreRegisterBtn addTarget:self action:@selector(tipBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.centerView addSubview:_moreRegisterBtn];
    }
    return _moreRegisterBtn;
}

- (SSThemedTextField *)passwordTextField
{
    if (!_passwordTextField) {
        _passwordTextField = [[SSThemedTextField alloc] initWithFrame:CGRectMake(20.0f, 114.0f, self.centerView.frame.size.width-40, 44.0f)];
        _passwordTextField.layer.borderWidth = 0.5f;
        _passwordTextField.borderColorThemeKey = kColorLine9;
        _passwordTextField.edgeInsets = UIEdgeInsetsMake(0, 11, 0, 11);
        _passwordTextField.font = [UIFont systemFontOfSize:16];
        _passwordTextField.delegate = self;
        _passwordTextField.tintColor = [UIColor blueColor];
        _passwordTextField.secureTextEntry = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_passwordTextField];
        
        [self.centerView addSubview:_passwordTextField];
    }
    return _passwordTextField;
}

- (TTAlphaThemedButton *)topButton
{
    if (!_topButton) {
        _topButton = [[TTAlphaThemedButton alloc] init];
        [_topButton setTitleColors:@[@"F85959", @"935656"]];
        [_topButton setBorderColors:@[@"F85959", @"935656"]];
        [_topButton.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17.f]]];
        _topButton.layer.borderWidth = 1.f;
        _topButton.layer.cornerRadius = 6.f;
        [_topButton setTitleColor:[UIColor tt_themedColorForKey:kColorText4] forState:UIControlStateNormal];
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            [_topButton setImage:[UIImage imageNamed:@"phone_pop_ups"] forState:UIControlStateNormal];
        } else {
            [_topButton setImage:[UIImage imageNamed:@"phone_pop_ups_night"] forState:UIControlStateNormal];
        }
        WeakSelf;
        [_topButton addTarget:self withActionBlock:^{
            StrongSelf;
            
            [TTAccountLoginManager presentLoginViewControllerFromVC:self.viewController type:TTAccountLoginDialogTitleTypeDefault source:self.source completion:^(TTAccountLoginState state) {
                
            }];
            
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                ttTrackEventWithCustomKeys(@"register_new", @"quick_login_mobile", nil, self.source, nil);
            }
            // LogV3
            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [extraDict setValue:self.source forKey:@"source"];
            [extraDict setValue:@"mobile" forKey:@"action_type"];
            [TTTrackerWrapper eventV3:@"login_quick_click" params:extraDict isDoubleSending:YES];
            
        } forControlEvent:UIControlEventTouchUpInside];
    }
    return _topButton;
}

- (TTAlphaThemedButton *)midButton
{
    if (!_midButton) {
        _midButton = [[TTAlphaThemedButton alloc] init];
        [_midButton.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17.f]]];
        _midButton.layer.borderWidth = 1.f;
        _midButton.layer.cornerRadius = 6.f;
        WeakSelf;
        [_midButton addTarget:self withActionBlock:^{
            StrongSelf;
            [self actionDidTapButton:self.midButton];
        } forControlEvent:UIControlEventTouchUpInside];
    }
    return _midButton;
}

- (TTAlphaThemedButton *)bottomButton
{
    if (!_bottomButton) {
        _bottomButton = [[TTAlphaThemedButton alloc] init];
        [_bottomButton.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17.f]]];
        _bottomButton.layer.borderWidth = 1.f;
        _bottomButton.layer.cornerRadius = 6.f;
        WeakSelf;
        [_bottomButton addTarget:self withActionBlock:^{
            StrongSelf;
            [self actionDidTapButton:self.bottomButton];
        } forControlEvent:UIControlEventTouchUpInside];
    }
    return _bottomButton;
}

@end



#pragma mark - TTAccountCaptchaAlert

@interface TTAccountCaptchaAlert ()
<
UITextFieldDelegate
>
@property (nonatomic, strong) SSThemedButton *resendBtn;
@property (nonatomic, strong) SSThemedTextField *firstTextField;

@property (nonatomic,   copy) NSString *captchaString;
@end

@implementation TTAccountCaptchaAlert

- (instancetype)initWithTitle:(NSString *)titleString
                 captchaImage:(UIImage *)image
                  placeholder:(NSString *)placeholderString
               cancelBtnTitle:(NSString *)cancelTitleString
              confirmBtnTitle:(NSString *)confirmBtnTitleString
                     animated:(BOOL)animated
                   completion:(TTAccountAlertCaptchaCompletionBlock)completedHandler
{
    if ((self = [super init])) {
        const CGFloat insetLeft = [TTDeviceUIUtils tt_padding:35.f];
        const CGFloat anotherCaptchaButtonWidth = [TTDeviceUIUtils tt_padding:80.f], anotherCaptchaButtonHeight = [TTDeviceUIUtils tt_padding:40.f];
        const CGFloat paddingInAnotherCaptchaButton = [TTDeviceUIUtils tt_padding:10.f];
        const CGFloat actionButtonHeight = [TTDeviceUIUtils tt_padding:44.f];
        CGFloat offsetY = [TTDeviceUIUtils tt_padding:22.f];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            // iPad下用一个 固定宽度
            self.centerView.frame = CGRectMake(0.0f, 0.0f, 380, [TTDeviceUIUtils tt_padding:226.0f]);
        } else {
            self.centerView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width - [TTDeviceUIUtils tt_padding:100], [TTDeviceUIUtils tt_padding:226.0f]);
        }
        
        self.cancelBtn.frame = CGRectMake(0.0f, self.centerView.frame.size.height - actionButtonHeight, self.centerView.frame.size.width/2, actionButtonHeight);
        self.cancelBtn.borderColorThemeKey = kColorLine1;
        [self.cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]]];
        if (cancelTitleString) {
            [self.cancelBtn setTitle:cancelTitleString forState:UIControlStateNormal];
        }
        
        self.doneBtn.frame = CGRectMake(self.centerView.frame.size.width / 2, self.centerView.frame.size.height - actionButtonHeight, self.centerView.frame.size.width / 2, actionButtonHeight);
        self.doneBtn.borderColorThemeKey = kColorLine1;
        [self.doneBtn.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]]];
        if (confirmBtnTitleString) {
            [self.doneBtn setTitle:confirmBtnTitleString forState:UIControlStateNormal];
        }
        
        // Title Label
        CGFloat fontSize = [TTDeviceUIUtils tt_fontSize:16.f];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        if (titleString) [self.titleLabel setAttributedText:[self.class attributedStringWithString:titleString fontSize:fontSize lineSpacing:0*0.4 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
        [self.titleLabel sizeToFit];
        self.titleLabel.frame = CGRectIntegral(CGRectMake(insetLeft, offsetY, self.centerView.frame.size.width - insetLeft * 2, self.titleLabel.height));
        
        // CaptchaImage Button
        if ([titleString length] > 0) {
            offsetY = self.titleLabel.bottom + [TTDeviceUIUtils tt_padding:20.f];
        }
        _resendBtn = [[SSThemedButton alloc] initWithFrame:CGRectMake(insetLeft, offsetY, self.centerView.frame.size.width - insetLeft * 2, [TTDeviceUIUtils tt_padding:50.0f])];
        [_resendBtn setBackgroundImage:image forState:UIControlStateNormal];
        [_resendBtn addTarget:self action:@selector(resendBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _resendBtn.enabled = YES;
        [self.centerView addSubview:_resendBtn];
        
        offsetY = _resendBtn.bottom + [TTDeviceUIUtils tt_padding:15.f];
        self.firstTextField.frame = CGRectMake(insetLeft, offsetY, self.centerView.frame.size.width - insetLeft * 2 - (anotherCaptchaButtonWidth + paddingInAnotherCaptchaButton), anotherCaptchaButtonHeight);
        self.firstTextField.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        self.firstTextField.borderColorThemeKey = kColorLine7;
        self.firstTextField.placeholder = placeholderString;
        self.firstTextField.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        if (![TTDeviceHelper isPadDevice]) {
            [self.firstTextField becomeFirstResponder];
        }
        
        // 换一张Captcha Button
        self.tipBtn.frame = CGRectMake(self.firstTextField.right + paddingInAnotherCaptchaButton, offsetY, anotherCaptchaButtonWidth, anotherCaptchaButtonHeight);
        self.tipBtn.titleColorThemeKey = kColorText1;
        [self.tipBtn.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]]];
        self.tipBtn.layer.borderWidth = 0.5;
        self.tipBtn.borderColorThemeKey = kColorLine7;
        [self.tipBtn setTitle:@"换一张" forState:UIControlStateNormal];
        [self.tipBtn addTarget:self action:@selector(resendBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        self.tipBtn.enabled = YES;
        
        self.captchaCompletedHandler = completedHandler;
    }
    return self;
}

- (void)show
{
    [self showInView:nil];
}

- (void)showInView:(UIView *)superView
{
    [super showInView:superView];
    if ([TTDeviceHelper isPadDevice]) {
        [self.firstTextField becomeFirstResponder];
    }
}

#pragma mark - events

- (void)resendBtnTouched:(id)sender
{
    [TTAccount refreshCaptchaWithCompletion:^(UIImage *captchaImage, NSError *error) {
        if (!error && captchaImage) {
            [_resendBtn setBackgroundImage:captchaImage forState:UIControlStateNormal];
        }
    }];
}

- (BOOL)textFieldDidChange:(NSNotification *)notification
{
    if (self.firstTextField.text.length > 0) {
        self.doneBtn.titleColorThemeKey = kColorText6;
    } else {
        self.doneBtn.titleColorThemeKey = kColorText3;
    }
    return YES;
}

- (void)cancelBtnTouched:(id)sender
{
    if (self.captchaCompletedHandler) {
        self.captchaCompletedHandler(TTAccountAlertCompletionEventTypeCancel, nil);
    }
    [super cancelBtnTouched:sender];
}

- (void)doneBtnTouched:(id)sender
{
    if (self.firstTextField.text.length == 0) {
        [self.tipBtn setTitle:@"请输入验证码" forState:UIControlStateNormal];
    } else {
        if (self.captchaCompletedHandler) {
            self.captchaCompletedHandler(TTAccountAlertCompletionEventTypeDone, self.firstTextField.text);
        }
        [super doneBtnTouched:sender];
    }
}

#pragma mark - Getters

- (SSThemedTextField *)firstTextField
{
    if (!_firstTextField) {
        _firstTextField = [[SSThemedTextField alloc] initWithFrame:CGRectMake(20.0f, 60.0f, self.centerView.frame.size.width - 40, 44.0f)];
        _firstTextField.layer.borderWidth = 0.5f;
        _firstTextField.borderColorThemeKey = kColorLine9;
        _firstTextField.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _firstTextField.font = [UIFont systemFontOfSize:16];
        _firstTextField.delegate = self;
        _firstTextField.tintColor = [UIColor blueColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_firstTextField];
        
        [self.centerView addSubview:_firstTextField];
    }
    return _firstTextField;
}

@end
