//
//  TTProjectLogicManager.h
//  Article
//
//  Created by zhaoqin on 8/10/16.
//
//  读取配置文件
//

#import <Foundation/Foundation.h>
#import "NSObject+TTAdditions.h"


@protocol TTProjectLogicManagerResultMapper <NSObject>
@required
/**
 *  Mapper的唯一标识，必须实现
 *
 *  @return 唯一标识
 */
- (NSString *)key;

@optional
/**
 *  对TTProjectLogicManager查询字符串结果进行映射
 *
 *  @param target 映射目标
 *
 *  @return 如果查询到返回映射结果，否则返回nil
 */
- (NSString *)mapString:(NSString *)target;

@end

@interface TTProjectLogicManager : NSObject <Singleton>

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
 *  获取配置文件中的float类型值
 *
 *  @param key   关键字
 *  @param value 默认值
 *
 *  @return 返回找到的value，否则返回默认值
 */
- (float)logicFloatForKey:(NSString *)key defaultValue:(float)value;

/**
 *  获取配置文件中的int类型值
 *
 *  @param key   关键字
 *  @param value 默认值
 *
 *  @return 返回找到的value，否则返回默认值
 */
- (int)logicIntForKey:(NSString *)key defaultValue:(int)value;

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
 *  获取配置文件中的float类型值
 *
 *  @param key 关键字
 *
 *  @return 返回找到的value，否则返回0.0f
 */
- (float)logicFloatForKey:(NSString *)key;

/**
 *  获取配置文件中的int类型值
 *
 *  @param key 关键字
 *
 *  @return 返回找到的value,否则返回0
 */
- (int)logicIntForKey:(NSString *)key;

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

/**
 *  向容器中添加映射
 *
 *  @param mapper 需要添加的映射
 */
- (void)registerMapper:(id<TTProjectLogicManagerResultMapper>)mapper;

#define TTLogicString(key, default) \
[[TTProjectLogicManager sharedInstance_tt] logicStringForKey:(key) defaultValue:(default)]

#define TTLogicFloat(key, default) \
[[TTProjectLogicManager sharedInstance_tt] logicFloatForKey:(key) defaultValue:(default)]

#define TTLogicInt(key, default) \
[[TTProjectLogicManager sharedInstance_tt] logicIntForKey:(key) defaultValue:(default)]

#define TTLogicDictionary(key, default) \
[[TTProjectLogicManager sharedInstance_tt] logicDictionaryForKey:(key) defaultValue:(default)]

#define TTLogicArray(key, default) \
[[TTProjectLogicManager sharedInstance_tt] logicArrayForKey:(key) defaultValue:(default)]

#define TTLogicBool(key, default) \
[[TTProjectLogicManager sharedInstance_tt] logicBoolForKey:(key) defaultValue:(default)]

#define TTLogicStringNODefault(key) \
[[TTProjectLogicManager sharedInstance_tt] logicStringForKey:(key)]

#define TTLogicFloatNODefault(key) \
[[TTProjectLogicManager sharedInstance_tt] logicFloatForKey:(key)]

#define TTLogicIntNODefault(key) \
[[TTProjectLogicManager sharedInstance_tt] logicIntForKey:(key)]

#define TTLogicDictionaryNODefault(key) \
[[TTProjectLogicManager sharedInstance_tt] logicDictionaryForKey:(key)]

#define TTLogicArrayNODefault(key) \
[[TTProjectLogicManager sharedInstance_tt] logicArrayForKey:(key)]

#define TTLogicBoolNODefault(key) \
[[TTProjectLogicManager sharedInstance_tt] logicBoolForKey:(key)]

@end
