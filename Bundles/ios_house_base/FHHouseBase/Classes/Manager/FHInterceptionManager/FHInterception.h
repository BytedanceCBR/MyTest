//
//  FHInterception.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/3/24.
//

#import <Foundation/Foundation.h>
#import "TTNetworkManager.h"
#import "FHInterceptionConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^Condition)(void);
typedef void (^Operation)(void);
typedef void (^Complete)(BOOL success, TTHttpTask * _Nullable httpTask);
typedef TTHttpTask * _Nullable (^Task)(void);
typedef void (^Operation)(void);

@interface FHInterception : NSObject
/**
添加拦截器方法

@param condition 参数判断条件，返回YES或者NO
@param operation 当参数不满足条件时，补救措施
@param complete 拦截完成时回调
@param task 原来的网络请求
@note 目前一个接口支持使用一个拦截器，不要使用多个
*/
- (TTHttpTask *)addParamInterceptionWithConfig:(FHInterceptionConfig *)config
                                     Condition:(Condition)condition
                                     operation:(Operation)operation
                                      complete:(Complete)complete
                                          task:(Task)task;
/**
取消拦截并中止下一步
*/
- (void)cancelInterception;
/**
跳出拦截直接进行下一步
*/
- (void)breakInterception;

@end

NS_ASSUME_NONNULL_END
