//
//  TTMonitorReporter.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/28.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTMonitorConfigurationProtocol.h"
#import "TTMonitorDefine.h"

@class TTMonitorReporterResponse;

/**
 *  上报监控data
 *  调用reportForData:进行上报，方法为同步方法，且内部不切换线程，调用者需要根据自己的需求在相应线程执行
 *  加载失败的情况，会尝试更换host,所有host都尝试完后，返回失败
 *
 */
@interface TTMonitorReporter : NSObject

/**
 *  上报监控data，方法为同步方法，且内部不切换线程，调用者需要根据自己的需求在相应线程执行
 *
 *  @param data 监控data
 *
 *  @return error 为nil标示上报完成，否则上报失败
 */
- (TTMonitorReporterResponse *)reportForData:(NSDictionary *)data reportType:(TTReportDataType)dataType;

- (void)setMonitorConfiguration:(Class<TTMonitorConfigurationProtocol>)configurationClass;

@end
