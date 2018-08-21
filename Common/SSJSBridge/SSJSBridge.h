//
//  SSJSBridge.h
//  Article
//
//  Created by Dianwei on 14-10-11.
//
//

#import <Foundation/Foundation.h>
#import "YSWebView.h"

typedef NS_ENUM(NSUInteger, SSJSBridgeAuthType){
    SSJSBridgeAuthPublic, // 所有均可调用
    SSJSBridgeAuthProtected, //内部domain，及外部授权可调用
    SSJSBridgeAuthPrivate // 仅内部domain，appinfo不可见
};

typedef void(^JSCallbackHandler)(NSDictionary *result);
typedef NSDictionary*(^JSCallHandler)(NSString * callbackId, NSDictionary* result, NSString *JSSDKVersion, BOOL * executeCallback);

@interface SSJSBridge : NSObject
@property(nonatomic, weak)YSWebView *webView;
+ (instancetype)JSBridgeWithWebView:(YSWebView*)webView;
- (void)registerHandlerBlock:(JSCallHandler)handler forJSMethod:(NSString*)method authType:(SSJSBridgeAuthType)authType;
- (void)unregisterAllHandlerBlocks;
- (void)invokeJSWithCallbackID:(NSString*)callback parameters:(NSDictionary*)tParameters;
- (void)invokeJSWithEventID:(NSString*)eventID parameters:(NSDictionary*)tParameters finishBlock:(JSCallbackHandler)finishBlock;

- (void)flushMessages;
- (BOOL)isInnerDomain;
- (BOOL)isAuthorizedForEvent:(NSString*)event;
- (BOOL)isAuthorizedForCall:(NSString*)functionName;
- (BOOL)isAuthroizedForInfo:(NSString*)infoKey;
+ (NSString*)currentJSSDKVersion;
@property(nonatomic, strong, readonly)NSMutableSet *publicCallSet;
@property(nonatomic, strong, readonly)NSMutableSet *protectedSet;
@property(nonatomic, strong, readonly)NSMutableSet *privateSet;
@end

