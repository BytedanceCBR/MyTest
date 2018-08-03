//
//  TTVWhiteBoard.h
//  Article
//
//  Created by pei yun on 2017/5/8.
//
//

#import <Foundation/Foundation.h>

@class RACSignal;
@interface TTVWhiteBoard : NSObject

/**
 *  订阅制定key的变化通知，支持初始值获取；强烈建议使用keypath宏声称键值字符串
 *
 *  @param key 不允许空值， 强烈建议使用keypath宏声称键值字符串
 *
 *  @return signal
 */
- (nonnull RACSignal *)signalForKey:(nonnull NSString *)key;
/**
 *  更新白板内容，强烈建议使用keypath宏生成键值字符串
 *
 *  @param value 更新值，允许为空，为空则移除原值；强烈建议使用keypath宏声称键值字符串
 *  @param key   不允许为空
 */
- (void)setValue:(nullable id)value forKey:(nonnull NSString *)key;

/**
 *  同步获取特定值；强烈建议使用keypath宏声称键值字符串
 *
 *  @param key 强烈建议使用keypath宏声称键值字符串
 *
 *  @return
 */
- (nullable id)valueForKey:(nonnull NSString *)key;

/**
 *  subscripting same with valueForKey:
 *
 *  @param key
 *
 *  @return
 */
- (nullable id)objectForKeyedSubscript:(nonnull NSString *)key;
/**
 *  subscripting same with setValue:forKey:
 *
 *  @param object
 *  @param key
 */
- (void)setObject:(nullable id)object forKeyedSubscript:(nonnull NSString *)key;

/**
 *  发送消息，返回结果数组
 *
 *  @param message   字符串类型，建议静态化
 *  @param parameter 任意参数对象
 *
 *  @return 多返回值数组
 */
- (nonnull NSArray *)queryMessage:(nonnull NSString *)message withParameters:(nullable id)parameter;

/**
 *  注册消息处理器，message为方法名
 *
 *  @param handler
 *  @param messageSelector 处理器对应的selector，即使没有返回值也必须返回nil
 */
- (void)registMessageHandler:(nonnull id)handler forMessageSelector:(nonnull SEL)messageSelector;

/**
 *  注册消息处理器
 *
 *  @param message         字符串类型，建议静态化
 *  @param handler
 *  @param messageSelector 处理器对应的selector，即使没有返回值也必须返回nil
 */
- (void)registMessage:(nonnull NSString *)message forMessageHandler:(nonnull id)handler forMessageSelector:(nonnull SEL)messageSelector;

/**
 *  解除注册
 *
 *  @param handler
 */
- (void)removeHandler:(nonnull id)handler;

@end
