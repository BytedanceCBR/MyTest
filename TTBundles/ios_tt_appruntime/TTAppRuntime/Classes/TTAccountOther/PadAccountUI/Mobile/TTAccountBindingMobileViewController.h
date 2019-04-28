//
//  TTAccountBindingMobileViewController.h
//  Article
//
//  Created by zuopengliu on 13/9/2017.
//
//

#import <SSViewControllerBase.h>
#import "TTModalContainerController.h"


#define kAccountBindingMobileNotification  @"kAccountBindingMobileNotification"


/**
 绑定完成回调
 
 @param / dismiss时是否绑定完成
 */
typedef void (^TTAccountBindingCompletionBlock)(BOOL finished/** 是否绑定成功 */, BOOL isDismissed);



/**
 绑定手机号，目前仅用于微博登录后跳出来的页面
 */
@interface TTAccountBindingMobileViewController : SSViewControllerBase
<
TTModalWrapControllerProtocol,
TTModalContainerDelegate
>

@property (nonatomic, copy) TTAccountBindingCompletionBlock bindingCompletionCallback;


/**
 手机号
 */
@property (nonatomic, copy) NSString *mobileString;


/**
统计字段
 */
@property (nonatomic, copy) NSDictionary *trackParams;


/**
 title提示文案
 */
@property (nonatomic, copy) NSString *titleHintString;


/**
 当前已显示绑定手机号次数
 */
+ (NSInteger)showBindingMobileTimes;


/**
 更新已展示绑定手机号次数
 */
+ (void)setShowBindingMobileTimes:(NSInteger)times;


/**
 标记可显示绑定手机号 `第一次登录` 和 点击`我的tab`可显示弹窗
 */
+ (void)setShowBindingMobileEnabled:(BOOL)enabled;


/**
 判断当前是否可显示绑定手机号弹窗
 */
+ (BOOL)showBindingMobileEnabled;

//绑定、退出提示文案
+ (NSString *)tipBindTitle;
+ (void)setTipBindTitle:(NSString *)value;
+ (NSString *)tipBindCancel;
+ (void)setTipBindCancel:(NSString *)value;

@end
