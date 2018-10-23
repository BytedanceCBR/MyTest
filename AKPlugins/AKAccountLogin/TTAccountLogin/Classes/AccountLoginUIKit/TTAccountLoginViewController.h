//
//  TTAccountLoginViewController.h
//  TTAccountLogin
//
//  Created by huic on 16/3/9.
//
//


#import "TTAccountLoginBaseViewController.h"



/**
 * UserInfo: {
 *      Key     : @"animated"
 *      Value   : NSNumber [0: 不执行动画; 1: 执行动画]
 *  }
 */
extern NSString * const TTForceToDismissLoginViewControllerNotification;

/**
 *  登录样式
 */
typedef NS_ENUM(NSInteger, TTAccountLoginStyle) {
    TTAccountLoginStylePassword = 0, // 密码登录
    TTAccountLoginStyleCaptcha  = 1, // 验证码登录
    TTAccountLoginStyleEmail    = 2, // 邮箱登录
};



@interface TTAccountLoginViewController : TTAccountLoginBaseViewController

@property (nonatomic, copy) NSString *loginSource;

/**
 *  指定初始化方法
 *
 *  @param title  标题文案
 *  @param source 来源
 *  @return       本类实例
 */
- (instancetype)initWithTitle:(NSString *)title source:(NSString *)source;

/**
 *  指定初始化方法
 *
 *  @param title              标题文案
 *  @param source             来源
 *  @param passwordLoginStyle 默认是否是账号密码页面
 *
 *  @return 本类实例
 */
- (instancetype)initWithTitle:(NSString *)title source:(NSString *)source isPasswordLogin:(BOOL)passwordLoginStyle;

@end
