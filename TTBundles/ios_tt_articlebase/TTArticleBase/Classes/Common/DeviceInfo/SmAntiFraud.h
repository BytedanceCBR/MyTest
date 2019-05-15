//
//  Copyright © 2017年 shumei. All rights reserved.
//  Pingshun Wei<weipingshun@ishumei.com>
//

#ifndef SM_ANTI_FRAUD_H
#define SM_ANTI_FRAUD_H

#import <Foundation/Foundation.h>

// 错误码
#define SM_AF_SUCCESS                  0
#define SM_AF_ERROR_OPTION_NULL        1
#define SM_AF_ERROR_ORIGNATION_BLANK   2
#define SM_AF_ERROR_ID_COLLECTOR       3
#define SM_AF_ERROR_SEQ_COLLECTOR      4
#define SM_AF_ERROR_BASE_COLLECTOR     5
#define SM_AF_ERROR_FINANCE_COLLECTOR  6
#define SM_AF_ERROR_TRACKER            7
#define SM_AF_ERROR_UNINIT             8
#define SM_AF_ERROR_SPEC_COLLECTOR     9
#define SM_AF_ERROR_CORE_COLLECTOR    10


// 处理模式
#define SM_AF_SYN_MODE  0     // 同步模式
#define SM_AF_ASYN_MODE 1    // 异步模式


// 数美反欺诈SDK主类
@interface SmAntiFraud : NSObject


/**
 * 单例模式
 * 优点: 
 * 1. 只需要初始化一次，任意任意调用。
 * 2. 不用传递SmAntiFraud对象。
 */
+(instancetype) shareInstance;

/**
 同步返回收集到的设备信息
 头条需求

 @return 设备信息
 */
- (NSDictionary *)getDeviceInfoWithConfiguration:(NSDictionary *)configuration;

@end
#endif
