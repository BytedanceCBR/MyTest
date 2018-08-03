//
//  TTShareApiConfig.h
//  Pods
//
//  Created by 延晋 张 on 16/6/6.
//
//

#import <Foundation/Foundation.h>

@interface TTShareApiConfig : NSObject

//一般在appDelegate中注册
/**
 *  qq分享（好友、空间）需要初始化OAuth,相当于注册appid
 */
+ (void)shareRegisterQQApp:(NSString *)appid;

/**
 *  微信分享分享（好友、空间）需要注册appid，直接调用的WXApi
 */
+ (void)shareRegisterWXApp:(NSString *)appid;
//
///**
// *  支付宝分享
// *
// *  @param appid 需要注册的appid
// */
//+ (void)shareRegisterZhiFuBaoApp:(NSString *)appid;
//
///**
// *  微博分享需要注册appid
// */
//+ (void)shareRegisterWeiboApp:(NSString *)appid;
//
///**
// *  钉钉分享需要注册appid
// */
//+ (void)shareRegisterDingTalk:(NSString *)appid;

@end
