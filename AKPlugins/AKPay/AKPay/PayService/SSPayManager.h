//
//  SSPayManager.h
//  Article
//
//  Created by SunJiangting on 14-8-29.
//
//

#import <Foundation/Foundation.h>

#import "WXApiObject.h"

/**
 支付平台

 - SSPayPlatformWXPay: 微信支付
 - SSPayPlatformAliPay: 支付宝
 */
typedef NS_ENUM(NSInteger, SSPayPlatform) {
    SSPayPlatformWXPay  = 1,
    SSPayPlatformAliPay = 2
};

@class SSPayManager;

typedef void (^SSPayHandler) (NSDictionary * trade, NSInteger errorCode);

@interface SSPayManager : NSObject


/**
 注册微信支付

 @param appID 在微信支付平台上申请的appID，标识当前app
 */
+ (void)registerWxAppID:(NSString *)appID;


/**
 单例

 @return SSPayManager
 */
+ (instancetype) sharedPayManager;


/**
 校验支付交易，调用payForTrade方法前调用

 @param trade 描述此次支付信息的字典
 @return 校验结果
 */
- (BOOL) canPayForTrade:(NSDictionary *) trade;


/**
 交易支付

 @param trade 描述此次支付信息的字典
 @param handler 回调block
 */
- (void) payForTrade:(NSDictionary *) trade finishHandler:(SSPayHandler) handler;


/**
 微信支付结果回调

 @param payResponse 微信支付结果
 */
- (void) handleWXPayResponse:(PayResp *) payResponse;


/**
 支付宝处理支付的结果

 @param URL 支付处理后返回给应用的URL
 @return 能否正常处理
 */
- (BOOL) canHandleOpenURL:(NSURL *) URL;

@end
