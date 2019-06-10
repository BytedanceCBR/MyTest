//
//  TTBridgePlugin.h
//  TTBridgeUnify
//
//  Modified from TTRexxar of muhuai.
//  Created by 李琢鹏 on 2018/10/30.
//

#import <Foundation/Foundation.h>
#import "TTBridgeDefines.h"
#import "TTBridgeEngine.h"

/**
 这个宏用来保证注册时的native方法存在
 
 例：
 TTBridgeSEL(TTAppBridge, appInfo) 等价于 @selector(appInfoWithParam:callback:engine:controller:)
 
 当方法不存在时编译器会提示错误
 */
#define TTBridgeSEL(CLASS, METHOD) \
((void)(NO && ((void)[((CLASS *)(nil)) METHOD##WithParam:nil callback:nil engine:nil controller:nil], NO)), @selector(METHOD##WithParam:callback:engine:controller:))



//推荐使用动态的方式
/**
 使用方法:
 1.继承TTBridgePlugin
 2.在.h中使用宏 TTR_EXPORT_HANDLER(abc)声明需要暴露的方法
 3.在.m中实现此方法, 输入-(void)abc 即可获得ide补全提示
 4.通过传入的callback来回调执行结果. 注意.无论成功与否都必须执行这个callback
 */
@interface TTBridgePlugin : NSObject

/**
 plugin执行时所处的engine
 */
@property (nonatomic, weak) id<TTBridgeEngine> engine;


/**
 TTBridgeInstanceTypeGlobal时 需要实现此方法, 没有特殊需要 不推荐使用

 @return 单例plugin
 */
+ (instancetype)sharedPlugin;

+ (TTBridgeInstanceType)instanceType;

/**
 注册外部实现的bridge调用，当有外部实现时，同名bridge在plugin内的实现不会再被调用

 @param handler bridge的外部实现block
 @param engine 对应的engine实例
 @param selector 注册bridge时的实现方法,可以通过TTBridgeSEL宏来避免硬编码
 */
+ (void)registerHandlerBlock:(TTBridgePluginHandler)handler forEngine:(id<TTBridgeEngine>)engine selector:(SEL)selector;

+ (void)performCallbackForEngine:(id<TTBridgeEngine>)engine selector:(SEL)selector msg:(TTBridgeMsg)msg params:(NSDictionary *)params __deprecated_msg("Use -[TTBridgeEngine callbackBridge:msg:params:");

/**
 native主动回调plugin实现的某个birdge
 
 @param engine 对应的engine实例
 @param selector 注册bridge时的实现方法,可以通过TTBridgeSEL宏来避免硬编码
 @param msg 回传msg
 @param params 参数
 @resultBlock resultBlock 异步获取返回值
 */
+ (void)performCallbackForEngine:(id<TTBridgeEngine>)engine selector:(SEL)selector msg:(TTBridgeMsg)msg params:(NSDictionary *)params resultBlock:(void (^)(NSString *result))resultBlock __deprecated_msg("Use -[TTBridgeEngine callbackBridge:msg:params:resultBlock:");

/**
 如果返回 YES 则不会执行 forwarding 逻辑,而是直接调用外部注册的 block 实现
 */
- (BOOL)hasExternalHandleForMethod:(NSString *)method params:(NSDictionary *)params callback:(TTBridgeCallback)callback;

/**
 保存当前的callback供后续调用，一般用于回调on开头的bridge

 @param callback 回调block
 @param selector 以注册bridge的selector为key
 */
- (void)setCallback:(TTBridgeCallback)callback forSelector:(SEL)selector;
- (void)removeCallback:(TTBridgeCallback)callback forSelector:(SEL)selector;

@end
