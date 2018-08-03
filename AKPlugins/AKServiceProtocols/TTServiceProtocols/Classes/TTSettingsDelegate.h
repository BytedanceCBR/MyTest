//
//  TTSettingsDelegate.h
//  Pods
//
//  Created by fengyadong on 2017/3/7.
//
//

#import <Foundation/Foundation.h>

@protocol TTSettingsDelegate <NSObject>

@optional

/**
 拉取到服务端配置

 @param success 是否成功的拉取
 */
- (void)didFetchSettingsWithSuccess:(BOOL)success;

/**
 解析默认配置项，一般是app全局的一些设置

 @param settings 原始数据 字典格式
 */
- (void)willDealDefaultSettingsResult:(NSDictionary *)settings;

/**
 解析其他配置项，一般与业务相关

 @param settings 原始数据 字典格式
 */
- (void)willDealAppSettingsResult:(NSDictionary *)settings;

@end
