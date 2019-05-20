//
//  TTBridgeForwarding.h
//  TTBridgeUnify
//
//  Modified from TTRexxar of muhuai.
//  Created by 李琢鹏 on 2018/10/30.
//


#import <Foundation/Foundation.h>
#import "TTBridgeCommand.h"
#import "TTBridgeEngine.h"
#import "TTBridgeDefines.h"

@interface TTBridgeForwarding : NSObject

+ (instancetype)sharedInstance;


/**
 转发到对应的插件

 @param command bridge命令
 @param engine Hybrid容器, 可是webview, RNView, weex. 实现此协议即可
 @param completion 完成回调
 */
- (void)forwardWithCommand:(TTBridgeCommand *)command engine:(id<TTBridgeEngine>)engine completion:(TTBridgeCallback)completion;



/// 和上面方法的区别是，block不会持有engine，不需要等js执行完成在去释放engine 暂时小游戏在用
- (void)forwardWithCommand:(TTBridgeCommand *)command weakEngine:(id<TTBridgeEngine>)engine completion:(TTBridgeCallback)completion;


/**
 注册bridge别名
 
 @param alias 新名
 @param orig 原名
 */
- (void)registerAlias:(NSString *)alias for:(NSString *)orig;


/**
 原名 -> 别名

 @param orig 原名
 @return 别名
 */
- (NSString *)aliasForOrig:(NSString *)orig;
@end

