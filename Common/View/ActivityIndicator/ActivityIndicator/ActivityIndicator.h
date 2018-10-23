/**
 * @file ActivityIndicator
 * @author David<gaotianpo@songshulin.net>
 *
 * @brief 创建一个ActivityIndicator用于显示一些信息
 * 
 * @details 创建一个一次性的ActivityIndicator显示信息，去掉了以前使用的rest方法
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * @brief 创建一个ActivityIndicator用于显示一些信息
 * @details 创建一个一次性的ActivityIndicator显示信息，去掉了以前使用的rest方法
 */
@interface SSActivityIndicator : UIView
{
	UILabel *_centerMessageLabel;
	UILabel *_subMessageLabel;
	
	UIActivityIndicatorView *_activityIndicator;
}

@property (nonatomic, retain) UILabel *centerMessageLabel;
@property (nonatomic, retain) UILabel *subMessageLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

/**
 *@brief 创建一个自动释放的ActivityIndicator 
 */
+ (SSActivityIndicator *)currentIndicator;

// @brief 将当前的ActivityIndicator 持久化，所谓持久化就是保持它显示
- (void)persist;
- (void)show;
/**
 *@brief 滞后0.6秒销毁
 */
- (void)hideAfterDelay;
- (void)hideImmediately;
/**
 *@brief 滞后指定秒数销毁
 *@param 指定的秒数，尽量不要过大，只做了负检查，没有做上限检查
 */
- (void)hideAfterSecond:(NSTimeInterval)second;
/**
 *@brief 显示一个带有进度的消息，进度会使用中心的位置
 *@param 中心下方的消息，尽量不要太长，这个消息会被控件reatain的
 */
- (void)displayActivity:(NSString *)message;
/**
 *@brief 显示完成消息，中心显示为完成，传入的消息会显示在完成下方
 *@param 中心下方的消息，尽量不要太长，这个消息会被控件reatain的
 */
- (void)displayCompleted:(NSString *)message;
/**
 *@brief 设置中心消息
 *@param 中心消息，尽量不要太长，这个消息会被控件reatain的
 */
- (void)setCenterMessage:(NSString *)message;
/**
 *@brief 设置中心下方的消息
 *@param 中心下方的消息，尽量不要太长，这个消息会被控件reatain的
 */
- (void)setSubMessage:(NSString *)message;
/**
 *@brief 只显示一个进度不显示消息内容
 */
- (void)showActivityIndicator;
/**
 *@brief 设置当前水平位置的函数，非动画
 */
- (void)setProperRotation;
/**
 
 *@brief 设置当前水平位置的函数，指定进行动画或非动画
 */
- (void)setProperRotation:(BOOL)animated;
/**
 *@brief 设置消息字体大小
 */
//- (void)setFontSize:(NSInteger *)fontSize;

+ (void)showMsg:(NSString *)msg afterDelay:(float)second;
+ (void)showCenterMsg:(NSString *)msg subMsg:(NSString *)subMsg afterDelay:(float)second;
+ (void)showCenterAutoMutableLineMessage:(NSString *)message msgFontSize:(NSUInteger)fontSize afterDelay:(float)second;

@end
