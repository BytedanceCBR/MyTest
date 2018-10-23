//
//  TTSettingsProvider.h
//  Pods
//
//  Created by fengyadong on 2017/3/7.
//
//

#import <Foundation/Foundation.h>

#define SETTING(key) [[[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTSettingsProvider)] getAppSettingsValueForKey:key]

@protocol TTSettingsProvider <NSObject>

@required

/**
 根据服务端原始字段名获取对应应用默认配置的原始数据

 @param key 服务端原始字段名
 @return 应用默认配置的原始数据
 */
- (id)getDefaultSettingsValueForKey:(NSString *)key;

/**
 根据服务端原始字段名获取对应应用内业务相关配置的原始数据

 @param key 服务端原始字段名
 @return 应用默认配置的原始数据
 */
- (id)getAppSettingsValueForKey:(NSString *)key;

@end
