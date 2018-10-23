//
//  HTSNetworkProtocol.h
//  Pods
//
//  Created by 权泉 on 2017/4/19.
//
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager/TTNetworkManager.h>

typedef NS_ENUM(NSUInteger, HTSNetworkServiceMode) {
    HTSNetworkServiceModeProduction,
    HTSNetworkServiceModeSandBox,
};

@protocol HTSNetworkProtocol <NSObject>

/**
 网络环境，Production or Sandbox

 @return current mode
 */
+ (HTSNetworkServiceMode)networkMode;

/**
 处理API请求Session过期
 */
+ (void)handleSessionExpired;

/**
 请求序列化Class，优先级 > TTNetworkManager默认请求序列化Class，可定制处理不同的业务
 
 @return request serializer
 */
+ (Class<TTHTTPRequestSerializerProtocol>)requestSerializerClass;


/**
 请求序列化Class，优先级 > TTNetworkManager默认请求序列化Class，可定制处理不同的业务

 @return response serializer
 */
+ (Class<TTJSONResponseSerializerProtocol>)responseSerializerClass;

@end
