//
//  TTBridgeAuthorization.h
//  TTBridgeUnify
//
//  Modified from TTRexxar of muhuai.
//  Created by 李琢鹏 on 2018/10/30.
//

#import <Foundation/Foundation.h>
#import "TTBridgeDefines.h"
#import "TTBridgeCommand.h"
#import "TTBridgeEngine.h"

@protocol TTBridgeAuthorization <NSObject>


/**
 验证是否有权限执行这个bridge

 @param engine 上下文engine
 @param command Command
 @param domain 所在页面
 @return 是否有权限
 */
- (BOOL)engine:(id<TTBridgeEngine>)engine isAuthorizedBridge:(TTBridgeCommand *)command domain:(NSString *)domain;

- (void)engine:(id<TTBridgeEngine>)engine isAuthorizedBridge:(TTBridgeCommand *)command domain:(NSString *)domain completion:(void (^)(BOOL success))completion;

- (BOOL)engine:(id<TTBridgeEngine>)engine isAuthorizedMeta:(NSString *)meta domain:(NSString *)domain;

@end
