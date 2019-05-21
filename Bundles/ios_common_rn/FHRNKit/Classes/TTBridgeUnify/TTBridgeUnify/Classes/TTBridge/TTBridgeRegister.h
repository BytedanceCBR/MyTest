//
//  BridgeRegister.h
//  Pods
//
//  Created by renpeng on 2018/10/9.
//

#import <Foundation/Foundation.h>
#import "TTBridgeDefines.h"
#import "TTBridgePlugin.h"


/**
 注册 bridge

 @param engineType bridge 支持的平台，目前支持 RN/webview
 @param nativeName 对应的 native 名
 @param bridgeName bridge 名
 @param authType 权限
 @param domains 如果权限为 private, 需传入其支持的域名
 */
extern void TTRegisterBridge(TTBridgeRegisterEngineType engineType,
                             NSString *nativeName,
                             TTBridgeName bridgeName,
                             TTBridgeAuthType authType,
                             NSArray<NSString *> *domains);

extern void TTRegisterWebViewBridge(NSString *nativeName, TTBridgeName bridgeName);

extern void TTRegisterRNBridge(NSString *nativeName, TTBridgeName bridgeName);

extern void TTRegisterAllBridge(NSString *nativeName, TTBridgeName bridgeName);

@interface TTBridgeMethodInfo : NSObject

@property (nonatomic, copy, readonly) NSDictionary<NSNumber*, NSNumber*> *authTypes;

@end

@interface TTBridgeRegister : NSObject

+ (instancetype)sharedRegister;

- (void)registerMethod:(TTBridgeName)bridgeName
            engineType:(TTBridgeRegisterEngineType)engineType
              authType:(TTBridgeAuthType)authType
               domains:(NSArray<NSString *> *)domains;

- (BOOL)bridgeHasRegistered:(TTBridgeName)bridgeName;

@property (nonatomic, copy, readonly) NSDictionary<NSString*, TTBridgeMethodInfo*> *registedMethods;
@property (nonatomic, copy, readonly) NSDictionary<NSString*, NSMutableArray*> *domain2PrivateMethods;

@end


