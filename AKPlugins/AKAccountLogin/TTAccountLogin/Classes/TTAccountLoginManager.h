//
//  TTAccountLoginManager.h
//  TTAccountLogin
//
//  Created by liuzuopeng on 24/05/2017.
//
//

#import <Foundation/Foundation.h>
#import <TTAccountSDK.h>
#import "TTAccountLoginViewController.h"
#import "TTAccountLoginEditProfileViewController.h"
#import "TTAccountLoginQuickRetrieveViewController.h"
#import "TTAccountAlertView.h"
#import "TTAccountLoginAlert.h"
#import "TTAccountLoginConfLogic.h"


typedef NS_ENUM(NSInteger, TTAccountLoginDialogTitleType) {
    TTAccountLoginDialogTitleTypeDefault = 0,//默认文案
    TTAccountLoginDialogTitleTypeRegister,   //注册引导文案
    TTAccountLoginDialogTitleTypeFavor,      //收藏提示
};


/**
 *  登录成功回调
 */
@interface TTAcountFLoginDelegate : NSObject

@property(nonatomic,copy)TTAccountLoginAlertPhoneInputCompletionBlock completeAlert;

@property(nonatomic,copy)TTAccountLoginCompletionBlock completeVC;

- (void)loginSuccessed;

@end


/**
 *  登录面板
 */
@interface TTAccountLoginManager : NSObject

/**
 *  登录Alert是否显示中
 */
+ (BOOL)isLoginAlertShowing;

+ (void)showLoginAlert;

+ (void)hideLoginAlert;

@end



@interface TTAccountLoginManager (TTNonUIPlatformAuthLogin)

#pragma mark - 登录/登出第三方平台

+ (void)requestLoginPlatformByType:(TTAccountAuthType)platformType
                        completion:(void (^)(BOOL success, NSError *error))completedBlock;

+ (void)requestLoginPlatformByType:(TTAccountAuthType)platformType
                   forceUseWebView:(BOOL)useWebView
                        completion:(void (^)(BOOL success, NSError *error))completedBlock;

+ (void)requestLoginPlatformByName:(NSString *)platformName
                        completion:(void (^)(BOOL success, NSError *error))completedBlock;

+ (void)requestLoginPlatformByName:(NSString *)platformName
                   forceUseWebView:(BOOL)useWebView
                        completion:(void (^)(BOOL success, NSError *error))completedBlock;

+ (void)requestLogoutPlatformByType:(TTAccountAuthType)platformType
                         completion:(void (^)(BOOL success, NSError *error))completedBlock;

+ (void)requestLogoutPlatformByName:(NSString *)platformName
                         completion:(void (^)(BOOL success, NSError *error))completedBlock;

@end



@interface TTAccountLoginManager (TTUILoginPanel)

#pragma mark - 登录面板

/**
 *  显示大登录弹窗，exPlatformNames用于标记不显示的第三方登录平台按钮
 
 *  @param vc                  源ViewController
 *  @param titleString         弹窗title显示文案
 *  @param sourceString        触发源，埋点
 *  @param exPlatformNames     不显示的平台类型名称（与服务端下发控制的一致）
 *  @param completedBlock      登录完成回调
 *  @return 返回登录弹窗实例
 */
+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                             title:(NSString *)titleString
                                                            source:(NSString *)sourceString
                                                 excludedPlatforms:(NSArray<NSString *> *)exPlatformNames
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock;

/**
 *  弹窗中title文案由type类型决定，不存在则使用默认文案
 *
 *  @param vc               源ViewController
 *  @param type             title类型
 *  @param source           触发源，埋点
 *  @param completedBlock   登录完成回调
 *  @return 返回登录弹窗实例
 */
+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                              type:(TTAccountLoginDialogTitleType)type
                                                            source:(NSString *)source
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock;

/**
 *  弹窗中文案由调用方传入，不传入则使用默认文案
 *
 *  @param vc               源ViewController
 *  @param titleString      弹窗title显示文案
 *  @param source           触发源，埋点
 *  @param completedBlock   登录完成回调
 *  @return 返回登录弹窗实例
 */
+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                             title:(NSString *)titleString
                                                            source:(NSString *)source
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock;

/**
 *  弹窗中title文案由type类型决定，不存在则使用默认文案
 *
 *  @param vc               源ViewController
 *  @param type             title类型
 *  @param source           触发源，埋点
 *  @param isPasswordStyle  默认是否显示密码登录样式
 *  @param completedBlock   登录完成回调
 *  @return 返回登录弹窗实例
 */
+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                              type:(TTAccountLoginDialogTitleType)type
                                                            source:(NSString *)source
                                                   isPasswordStyle:(BOOL)isPasswordStyle
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock;

/**
 *  弹窗中文案由调用方传入，不传入则使用默认文案
 *
 *  @param vc               源ViewController
 *  @param titleString      弹窗title显示文案
 *  @param source           触发源，埋点
 *  @param isPasswordStyle  默认是否显示密码登录样式
 *  @param completedBlock   登录完成回调
 *  @return 返回登录弹窗实例
 */
+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                             title:(NSString *)titleString
                                                            source:(NSString *)source
                                                   isPasswordStyle:(BOOL)isPasswordStyle
                                                        completion:(TTAccountLoginCompletionBlock)completedBlock;

/**
 *  弹窗中title文案由type类型决定，不存在则使用默认文案
 *
 *  @param vc               源ViewController
 *  @param type             title类型
 *  @param source           触发源，埋点
 *  @param isPasswordStyle  默认是否显示密码登录样式
 *  @param subscribeCompletedBlock   订阅完成回调，不知道哪里用，保持老的逻辑
 *  @return 返回登录弹窗实例
 */
+ (TTAccountLoginViewController *)presentLoginViewControllerFromVC:(UIViewController *)vc
                                                              type:(TTAccountLoginDialogTitleType)type
                                                            source:(NSString *)source
                                               subscribeCompletion:(TTAccountLoginCompletionBlock)subscribeCompletedBlock;



//
//  小窗登录样式
//
//  默认点击更多调用回调参数为TTAccountAlertCompletionEventTypeTip
//  当使用参数moreActionRespMode时，点击更多按钮的行为由参数moreActionRespMode决定
//
/**
 *  文案由传入类型决定，不存在则使用默认文案
 *
 *  @param type             title类型
 *  @param source           触发源，埋点
 *  @param completedBlock   点击和登录完成回调
 */
+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;

/**
 *  文案由调用方传入，不传入则使用默认文案
 *
 *  @param titleString      弹窗title文案
 *  @param source           触发源，埋点
 *  @param completedBlock   点击和登录完成回调
 */
+ (TTAccountLoginAlert *)showLoginAlertWithTitle:(NSString *)titleString
                                          source:(NSString *)source
                                      completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;

/**
 *  文案由传入类型决定，不存在则使用默认文案
 *
 *  @param type                 title类型
 *  @param source               触发源，埋点
 *  @param moreActionRespMode   点击更多按钮时是打开大窗还是调用参数为TTAccountAlertCompletionEventTypeTip的回调
 *  @param completedBlock       点击和登录完成回调
 */
+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                 moreActionConf:(TTAccountLoginMoreActionRespMode)moreActionRespMode
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;

/**
 *  文案由传入类型决定，不存在则使用默认文案
 *
 *  @param type             title类型
 *  @param source           触发源，埋点
 *  @param superView        父视图
 *  @param completedBlock   点击和登录完成回调
 */
+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                    inSuperView:(UIView *)superView
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;

/**
 *  文案由调用方传入，不传入则使用默认文案
 *
 *  @param titleString      弹窗title文案
 *  @param source           触发源，埋点
 *  @param superView        父视图
 *  @param completedBlock   点击和登录完成回调
 */
+ (TTAccountLoginAlert *)showLoginAlertWithTitle:(NSString *)titleString
                                          source:(NSString *)source
                                     inSuperView:(UIView *)superView
                                      completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;

/**
 *  文案由传入类型决定，不存在则使用默认文案
 *
 *  @param type                 title类型
 *  @param source               触发源，埋点
 *  @param superView            父视图
 *  @param moreActionRespMode   点击更多按钮时是打开大窗还是调用TTAccountAlertCompletionEventTypeTip回调
 *  @param completedBlock       点击和登录完成回调
 */
+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                    inSuperView:(UIView *)superView
                                 moreActionConf:(TTAccountLoginMoreActionRespMode)moreActionRespMode
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;

/**
 *  文案由调用方传入，不传入则使用默认文案
 *
 *  @param title                弹窗title文案
 *  @param source               触发源，埋点
 *  @param superView            父视图
 *  @param moreActionRespMode   点击更多按钮时是打开大窗还是调用TTAccountAlertCompletionEventTypeTip回调
 *  @param completedBlock       点击和登录完成回调
 */
+ (TTAccountLoginAlert *)showLoginAlertWithTitle:(NSString *)title
                                          source:(NSString *)source
                                     inSuperView:(UIView *)superView
                                  moreActionConf:(TTAccountLoginMoreActionRespMode)moreActionRespMode
                                      completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;


/**
 *  F项目文章登录，统一处理为VC登录
 *
 *  @param complete 完成回调处理
 */

+ (void)showAlertFLoginVCWithParams:(NSDictionary *)params completeBlock:(TTAccountLoginAlertPhoneInputCompletionBlock)complete;

/**
 *  F项目文章登录，统一处理为VC登录
 *
 *  @param complete 完成回调处理
 */

+ (void)showQuickFLoginVCWithParams:(NSDictionary *)params completeBlock:(TTAccountLoginCompletionBlock)complete;

@end



@interface TTAccountLoginManager (TTLoginUIStyleStore)

/** 登录成功后记录登录方式，以便下次打开默认使用 */
+ (void)setDefaultLoginUIStyleFor:(TTAccountLoginStyle)newStyle;

/** 上次登录成功的方式，默认验证码登录，使用第三方登录后也会改成验证码登录 */
+ (TTAccountLoginStyle)loginStyle;

@end

