//
//  TTConfReaderProvider.h
//  Pods
//
//  Created by fengyadong on 2017/4/14.
//
//

#import <Foundation/Foundation.h>
#import "TTConfReaderMapper.h"

@protocol TTConfReaderProvider <NSObject>

@required
/**
 *  向容器中添加映射
 *
 *  @param mapper 需要添加的映射
 */
- (void)registerMapper:(id<TTConfReaderMapper>)mapper;

/**
 将配置文件注册到容器中，方便之后查询
 
 @param bundleName bundle名称，如果传空默认为主bundle
 @param fileName 文件名
 @param type 文件类型，目前只支持strings,plist,json等
 */
- (void)reigisterBundleName:(NSString *)bundleName confFileName:(NSString *)fileName type:(NSString *)type;

/**
 *  获取配置文件中的NSString类型值
 *
 *  @param key   关键字
 *  @param value 默认值
 *
 *  @return 返回找到的value，否则返回默认值
 */
- (NSString *)logicStringForKey:(NSString *)key defaultValue:(NSString *)value;

/**
 *  获取配置文件中的CGFloat类型值
 *
 *  @param key   关键字
 *  @param value 默认值
 *
 *  @return 返回找到的value，否则返回默认值
 */
- (CGFloat)logicFloatForKey:(NSString *)key defaultValue:(CGFloat)value;

/**
 *  获取配置文件中的int类型值
 *
 *  @param key   关键字
 *  @param value 默认值
 *
 *  @return 返回找到的value，否则返回默认值
 */
- (NSInteger)logicIntForKey:(NSString *)key defaultValue:(int)value;

/**
 *  获取配置文件中的NSDictionary类型值
 *
 *  @param key  关键字
 *  @param dict 默认值
 *
 *  @return 返回找到的value，否则返回默认值
 */
- (NSDictionary *)logicDictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)dict;

/**
 *  获取配置文件中的NSArray类型值
 *
 *  @param key   关键字
 *  @param array 默认值
 *
 *  @return 返回找到的value，否则返回默认值
 */
- (NSArray *)logicArrayForKey:(NSString *)key defaultValue:(NSArray *)array;

/**
 *  获取配置文件中的BOOL类型值
 *
 *  @param key   关键字
 *  @param value 默认值
 *
 *  @return 返回找到的value，否则返回默认值
 */
- (BOOL)logicBoolForKey:(NSString *)key defaultValue:(BOOL)value;

/**
 *  获取配置文件中的NSString类型值
 *
 *  @param key 关键字
 *
 *  @return 返回找到的value，否则返回nil
 */
- (NSString *)logicStringForKey:(NSString *)key;

/**
 *  获取配置文件中的CGFloat类型值
 *
 *  @param key 关键字
 *
 *  @return 返回找到的value，否则返回0.0f
 */
- (CGFloat)logicFloatForKey:(NSString *)key;

/**
 *  获取配置文件中的int类型值
 *
 *  @param key 关键字
 *
 *  @return 返回找到的value,否则返回0
 */
- (NSInteger)logicIntForKey:(NSString *)key;

/**
 *  获取配置文件中的NSDictionary类型值
 *
 *  @param key 关键字
 *
 *  @return 返回找到的value,否则返回nil
 */
- (NSDictionary *)logicDictionaryForKey:(NSString *)key;

/**
 *  获取配置文件中的NSArray类型值
 *
 *  @param key 关键字
 *
 *  @return 返回找到的value,否则返回nil
 */
- (NSArray *)logicArrayForKey:(NSString *)key;

/**
 *  获取配置文件中的BOOL类型值
 *
 *  @param key 关键字
 *
 *  @return 返回找到的value,否则返回nil
 */
- (BOOL)logicBoolForKey:(NSString *)key;

@end
