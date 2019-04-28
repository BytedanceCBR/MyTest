//
//  TTBridgeDefines.h
//  TTBridgeUnify
//
//  Modified from TTRexxar of muhuai.
//  Created by 李琢鹏 on 2018/10/30.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(NSInteger, TTBridgeRegisterEngineType) {
    TTBridgeRegisterRN = 1 << 0,
    TTBridgeRegisterWebView = 1 << 1,
    TTBridgeRegisterAll = TTBridgeRegisterRN | TTBridgeRegisterWebView
};

#define TT_BRIDGE_EXPORT_HANDLER(NAME) - (void)NAME##WithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback engine:(id<TTBridgeEngine>)engine controller:(UIViewController *)controller;

/**
 这个宏用来保证注册时的native方法存在
 
 例：
 TTRegisterAllBridge(TTClassBridgeMethod(TTAppBridge, appInfo), @"app.getAppInfo");
 等价于
 TTRegisterAllBridge(@"TTAppBridge.appInfo", @"app.getAppInfo");
 
 当方法不存在时编译器会提示错误
 */
#define TTClassBridgeMethod(CLASS, METHOD) \
((void)(NO && ((void)[((CLASS *)(nil)) METHOD##WithParam:nil callback:nil engine:nil controller:nil], NO)), [NSString stringWithFormat:@"%@.%@", @(#CLASS), @(#METHOD)])


#define TTBRIDGE_CALLBACK_SUCCESS \
if (callback) {\
callback(TTBridgeMsgSuccess, @{});\
}\

#define TTBRIDGE_CALLBACK_FAILED \
if (callback) {\
callback(TTBridgeMsgFailed, @{});\
}\

#define TTBRIDGE_CALLBACK_FAILED_MSG(msg) \
if (callback) {\
callback(TTBridgeMsgFailed, @{@"msg": [NSString stringWithFormat:msg]? :@""});\
}\

#define TTBRIDGE_CALLBACK_WITH_MSG(status, msg) \
if (callback) {\
callback(status, @{@"msg": [NSString stringWithFormat:msg]? [NSString stringWithFormat:msg] :@""});\
}\

#ifndef isEmptyString
#define isEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif

typedef NS_ENUM(NSUInteger, TTBridgeInstanceType) {
    TTBridgeInstanceTypeNormal, //每次调用都是不同实例(默认, 推荐)
    TTBridgeInstanceTypeGlobal, //全局单例, 需要实现 +(instance)sharedPlugin;
    TTBridgeInstanceTypeAssociated, //对同一个source object复用一个实例
};

typedef NS_ENUM(NSUInteger, TTBridgeAuthType){
    TTBridgeAuthPublic, // 所有均可调用(默认)
    TTBridgeAuthProtected, //内部domain，及外部授权可调用
    TTBridgeAuthPrivate // 仅内部domain，appinfo不可见
};

typedef enum : NSInteger {
    TTBridgeMsgSuccess = 1,
    TTBridgeMsgFailed = 0,
    TTBridgeMsgParamError = -3,
    TTBridgeMsgNoHandler = -2,
    TTBridgeMsgNoPermission = -1
} TTBridgeMsg;

typedef void(^TTBridgeCallback)(TTBridgeMsg, NSDictionary *);

typedef NSString * TTBridgeName;
