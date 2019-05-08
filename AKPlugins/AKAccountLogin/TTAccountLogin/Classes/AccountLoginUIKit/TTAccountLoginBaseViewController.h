//
//  TTAccountLoginBaseViewController.h
//  TTAccountLogin
//
//  Created by huic on 16/3/8.
//
//

#import "TTAccountLoginPCHHeader.h"
#import "TTAccountLoginDefine.h"
#import "TTAccountLoginInputView.h"
#import "TTAccountLoginPlatformLoginView.h"



#define kTTAccountLoginUpInfoHeight  (93)
#define kTTAccountLoginUpInfoWidth   (110)

#define kTTAccountLoginUpInfoHeightRatioInView (1 / 7.8)
#define kTTAccountLoginInputFieldHeightRatioWithUpInfo (0.5)
#define kTTAccountLoginInputFieldLeftMargin  (30)
#define kTTAccountLoginInputFieldRightMargin (30)
#define kTTAccountLoginInputFieldVerticalMargin (20)
#define kTTAccountLoginInputFieldHeight (60)

#define kTTAccountLoginPaddingFindPasswordTipLabelToLoginButton (30.f)
#define kTTAccountLoginLoginLabelVerticalMargin (30)
#define kTTAccountLoginCenterActionViewItemPadding (16.f)

#define kTTAccountLoginCheckLoginStyleToPrivacyPadding (30.f)


#define kTTAccountLoginPlatformBottomMargin  (32)
#define kTTAccountLoginPlatformButtonHeight  (40)
#define kTTAccountLoginPlatformHorizonMargin (16)

#define kTTAccountLoginAgreeBottomMargin  (20)
#define kTTAccountLoginAgreeHorizonMargin (10)

#define kTTAccountLoginAnimationInterval  (0.4)



/**
 *  登录状态
 */
typedef NS_ENUM(NSInteger, TTAccountLoginState) {
    /**
     *  尚未完成登录
     */
    TTAccountLoginStateNotLogin = 0,
    /**
     *  已经完成登录
     */
    TTAccountLoginStateLogin    = 1,
    /**
     *  取消登录
     */
    TTAccountLoginStateCancelled = 2,
};


typedef NS_ENUM(NSUInteger, TTAccountLoginErrorCode) {
    TTAccountLoginErrorCodeRegistered         = 1001, //账号已注册
    TTAccountLoginErrorCodeNotExist           = 1008, //账号不存在
    TTAccountLoginErrorCodePasswordWrong      = 1009, //密码错误
    TTAccountLoginErrorCodePasswordDigitError = 1012, //密码位数错误
    TTAccountLoginErrorCodeAlertFindPassword  = 1033, //弹出找回密码弹窗
    TTAccountLoginErrorCodeNeedCaptcha        = 1101, //需要图片验证码
    TTAccountLoginErrorCodeCaptchaWrong       = 1102, //图片验证码错误
    TTAccountLoginErrorCodeCaptchaInvalid     = 1103, //图片验证码失效
    TTAccountLoginErrorCodeNeedPassword       = 1037, //退出时需要补全密码
    TTAccountLoginErrorCodeAuthCodeError      = 1202, //验证码错误
    TTAccountLoginErrorCodeAuthCodeExpired    = 1203, //验证码过期
};


typedef void (^TTAccountLoginCompletionBlock)(TTAccountLoginState state);


@interface TTAccountLoginBaseViewController : SSViewControllerBase
<
UITextFieldDelegate,
TTAccountLoginPlatformLoginViewDelegate
>
@property (nonatomic,   copy) NSString *source;
@property (nonatomic, strong) NSArray<NSString *> *excludedPlatformNames; // 标记不显示的第三方平台名称
@property (nonatomic, strong) SSNavigationBar *navigationBar;
@property (nonatomic, strong) SSThemedView *backgroundView;
@property (nonatomic, strong) SSThemedView *upInfoContainerView; //上方头像或上方文案;
@property (nonatomic, strong) TTAccountLoginPlatformLoginView *platformLoginView; //第三方登录控件
@property (nonatomic, assign) TTAccountLoginPlatformType types; // 支持的登陆类型

@property (nonatomic, strong) TTAccountLoginInputView *mobileInput;  // 第一个input，封装自UITextField
@property (nonatomic, strong) TTAccountLoginInputView *captchaInput; // 第一个input，封装自UITextField

@property (nonatomic, strong) SSThemedButton  *registerButton; // 登录按钮

@property (nonatomic, assign) BOOL hideLeftItem;

@property (nonatomic, strong) UIBarButtonItem *leftItem;

@property (nonatomic, strong) UIBarButtonItem *closeItem;

@property (nonatomic, assign) NSInteger countdown;  // 重发倒计时
@property (nonatomic, strong) NSTimer *timer; // 重发计时器

@property (nonatomic, assign, readonly) BOOL registerButtonEnabled; // 登录按钮是否灰色（产品设计，灰色时仍可点击）
@property (nonatomic, assign) BOOL resendButtonEnabled; // 重发按钮可否点击

@property (nonatomic,   copy) NSString *captchaString;  // 用户输入的图片验证码字符串

@property (nonatomic, assign) TTAccountLoginState loginState; // 登录状态
@property (nonatomic, assign) TTAccountLoginState subscribeState; // 订阅是否登录成功

@property (nonatomic,   copy) TTAccountLoginCompletionBlock loginCompletionHandler; // 登录之后回调

@property (nonatomic,   copy) TTAccountLoginCompletionBlock subscribeCompletionHandler; // 订阅登录之后的回调


#pragma mark - Indicator
/**
 *  显示waitingIndicator
 */
- (void)showWaitingIndicator;

/**
 *  移除indicator并根据需要显示提示语
 */
- (void)dismissWaitingIndicator;
- (void)dismissWaitingIndicatorWithError:(NSError *)error;
- (void)dismissWaitingIndicatorWithText:(NSString *)message;

- (void)showAutoDismissIndicatorWithError:(NSError *)error;
- (void)showAutoDismissIndicatorWithText:(NSString *)text;

/**
 *  registerButtonEnabled刷新登录按钮颜色
 */
- (void)refreshRegisterButton;

- (void)refreshSubviews;

/**
 *  布局登录页基础框架
 */
- (void)layoutSubviews;

/**
 *  重新布局重发按钮
 */
- (void)fitResendView;

/**
 *  开始重发倒计时
 */
- (void)startTimer;
- (void)clearTimer;

- (void)leftItemClicked;
- (void)rightItemClicked;

/**
 *  判断手机号是否合法
 *
 *  @param mobileNumber 手机号
 *
 *  @return 是否是手机号
 */
- (BOOL)validateMobileNumber:(NSString *)mobileNumber;

/**
 *  Subclass should override this method
 */
- (BOOL)isContentValid;

/**
 *  第三方平台授权登录完成回调，需子类重写实现具体逻辑
 *
 *  @param error        错误描述
 *  @param platformName 平台名称
 */
- (void)respondsToAccountAuthLoginWithError:(NSError *)error forPlatform:(NSString *)platformName;

/**
 *  Instance
 */
- (instancetype)initWithTitle:(NSString *)title source:(NSString *)source;

@end
