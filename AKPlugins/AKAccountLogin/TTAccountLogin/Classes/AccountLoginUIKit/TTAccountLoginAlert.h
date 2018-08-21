//
//  TTAccountLoginAlert.h
//  TTAccountLogin
//
//  Created by yuxin on 2/24/16.
//
//


#import <SSThemed.h>
#import "TTAccountAlertView.h"



NS_ASSUME_NONNULL_BEGIN

typedef
NS_ENUM(NSUInteger, TTAccountLoginAlertUIStyle) {
    TTAccountLoginAlertUIStylePhoneNumInput,    //输入手机号
    TTAccountLoginAlertUIStyleVerifyPhoneNum,   //输入验证码
    TTAccountLoginAlertUIStyleResetPassword,    //添加密码
    TTAccountLoginAlertUIStylePlain,            //普通弹框
};

typedef
NS_ENUM(NSUInteger, TTAccountLoginAlertActionType) {
    TTAccountLoginAlertActionTypeLogin,         //登录
    TTAccountLoginAlertActionTypeBind,          //第三方登录后提示绑定手机号
    TTAccountLoginAlertActionTypeResetPassword, //添加密码
    TTAccountLoginAlertActionTypePhoneNumSwitch,//将当期手机号绑定到另一个账户上
    TTAccountLoginAlertActionTypePlain,         //普通弹框
};

typedef
NS_ENUM(NSUInteger, TTAccountLoginAlertTitleType) {
    TTAccountLoginAlertTitleTypeDefault = 0, //默认
    TTAccountLoginAlertTitleTypePost,        //发表评论
    TTAccountLoginAlertTitleTypeFavor,       //收藏
    TTAccountLoginAlertTitleTypeSocial,      //好友动态
    TTAccountLoginAlertTitleTypePGCLike,     //title_pgc_like
    TTAccountLoginAlertTitleTypeMyFavor,     //我的收藏
    TTAccountLoginAlertTitleTypePushHistory, //推送历史
    TTAccountLoginAlertTitleTypeDislike,     //不喜欢
    TTAccountLoginAlertTitleTypeBoot,        //启动
};

typedef
NS_ENUM(NSInteger, TTAccountLoginMoreActionRespMode) {
    TTAccountLoginMoreActionRespModeCallback,
    TTAccountLoginMoreActionRespModeBigLoginPanel,
};

typedef
void (^TTAccountLoginAlertPhoneInputCompletionBlock)(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum);
typedef
void (^TTAccountLoginAlertPhoneVerifyCompletionBlock)(TTAccountAlertCompletionEventType type);
typedef
void (^TTAccountLoginAlertResetPasswordCompletionBlock)(TTAccountAlertCompletionEventType type, NSString * _Nullable password);


@interface TTAccountLoginAlert : TTAccountAlertView

// 埋点源
@property (nonatomic,   copy) NSString *source;

@property (nonatomic, assign) TTAccountLoginAlertActionType actionType;

@property (nonatomic, assign) TTAccountLoginAlertUIStyle alertUIStyle;

// 当使用initPhoneNumberInputAlertWithActionType:title:placeholder:tip:cancelBtnTitle:confirmBtnTitle:animated:source:completion初始化时，点击更多按钮行为，YES打开登录大窗，NO调用TTAccountAlertCompletionEventTypeTip回调（默认为NO）
@property (nonatomic, assign) TTAccountLoginMoreActionRespMode moreButtonRespAction;

// Blocks
@property (nonatomic, copy) TTAccountLoginAlertPhoneInputCompletionBlock    phoneInputCompletedHandler;
@property (nonatomic, copy) TTAccountLoginAlertPhoneVerifyCompletionBlock   phoneVerifyCompletedHandler;
@property (nonatomic, copy) TTAccountLoginAlertResetPasswordCompletionBlock resetPasswordCompletedHandler;

- (instancetype)initPhoneNumberInputAlertWithActionType:(TTAccountLoginAlertActionType)type
                                                  title:(NSString * _Nullable)titleString
                                            placeholder:(NSString * _Nullable)placeholderString
                                                    tip:(NSString * _Nullable)tipString
                                         cancelBtnTitle:(NSString * _Nonnull)cancelTitleString
                                        confirmBtnTitle:(NSString * _Nonnull)confirmBtnTitleString
                                               animated:(BOOL)animated
                                                 source:(NSString * _Nullable)sourceString
                                             completion:(TTAccountLoginAlertPhoneInputCompletionBlock _Nullable)completedHandler;

- (instancetype)initPhoneNumberVerifyAlertWithActionType:(TTAccountLoginAlertActionType)type
                                                phoneNum:(NSString * _Nonnull)phoneNumString
                                                   title:(NSString * _Nullable)titleString
                                             placeholder:(NSString * _Nullable)placeholderString
                                                     tip:(NSString * _Nullable)tipString
                                          cancelBtnTitle:(NSString * _Nonnull)cancelTitleString
                                         confirmBtnTitle:(NSString * _Nonnull)confirmBtnTitleString
                                                animated:(BOOL)animated
                                              completion:(TTAccountLoginAlertPhoneVerifyCompletionBlock _Nullable)completedHandler;

- (instancetype)initResetPasswordAlertWithActionType:(TTAccountLoginAlertActionType)type
                                               title:(NSString * _Nullable)titleString
                                         placeholder:(NSString * _Nullable)placeholderString
                                                 tip:(NSString * _Nullable)tipString
                                      cancelBtnTitle:(NSString * _Nonnull)cancelTitleString
                                     confirmBtnTitle:(NSString * _Nonnull)confirmBtnTitleString
                                            animated:(BOOL)animated
                                          completion:(TTAccountLoginAlertResetPasswordCompletionBlock _Nullable)completedHandler;
@end



#pragma mark - TTAccountCaptchaAlert

typedef
void(^TTAccountAlertCaptchaCompletionBlock)(TTAccountAlertCompletionEventType type, NSString * _Nullable captchaStr);

@interface TTAccountCaptchaAlert : TTAccountAlertView

@property (nonatomic, copy, nullable) TTAccountAlertCaptchaCompletionBlock captchaCompletedHandler;

- (instancetype)initWithTitle:(NSString * _Nullable)titleString
                 captchaImage:(UIImage  * _Nonnull)image
                  placeholder:(NSString * _Nullable)placeholderString
               cancelBtnTitle:(NSString * _Nullable)cancelTitleString
              confirmBtnTitle:(NSString * _Nullable)confirmBtnTitleString
                     animated:(BOOL)animated
                   completion:(TTAccountAlertCaptchaCompletionBlock _Nullable)completedHandler;

@end

NS_ASSUME_NONNULL_END
