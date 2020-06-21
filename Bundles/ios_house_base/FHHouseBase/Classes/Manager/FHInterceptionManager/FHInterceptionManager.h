//
//  FHInterceptionManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/3/20.
//

#import <Foundation/Foundation.h>
#import "TTNetworkManager.h"
#import "FHInterceptionConfig.h"
#import "FHInterception.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHInterceptionManager : NSObject

+ (instancetype)sharedInstance;

/**
添加拦截器方法

@param uniqueId 唯一id不要和其他的拦截器重复，参考命名 “kInterception + 接口名”，如kInterceptionUserFollows。
@param config 设置参数
@param condition 参数判断条件，返回YES或者NO
@param operation 当参数不满足条件时，补救措施
@param complete 拦截完成时回调
@param task 原来的网络请求
@note 目前一个接口支持使用一个拦截器，不要使用多个
 */
- (TTHttpTask *)addInterception:(NSString *)uniqueId
                         config:(FHInterceptionConfig *)config
                      Condition:(Condition)condition
                      operation:(Operation)operation
                       complete:(Complete)complete
                           task:(Task)task;

/**
立即退出拦截器并且中止后续操作

@param uniqueId 唯一id不要和其他的拦截器重复，参考命名 “kInterception + 接口名”，如kInterceptionUserFollows。
 */
- (void)cancelInterception:(NSString *)uniqueId;

/**
立即退出拦截器并且直接调用接口

@param uniqueId 唯一id不要和其他的拦截器重复，参考命名 “kInterception + 接口名”，如kInterceptionUserFollows。
 */
- (void)breakInterception:(NSString *)uniqueId;

@end

NS_ASSUME_NONNULL_END
