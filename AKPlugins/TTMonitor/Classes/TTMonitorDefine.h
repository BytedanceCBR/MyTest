//
//  TTMonitorDefine.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/2/28.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef TTMonitor_Define
#define TTMonitor_Define

#define kTTMonitorErrorDomain @"kTTMonitorErrorDomain"

typedef NS_ENUM(NSInteger, kTTMonitorErrorCode) {
    kTTMonitorErrorCodeUnknown     = -1,
    kTTMonitorErrorCodeReportError = 0,
    kTTMonitorErrorCodeServerException = 1,
};

typedef NS_ENUM(NSInteger, TTReportDataType){
    TTReportDataTypeCommon = 0,
    TTReportDataTypeWatchDog = (1<<0)
};

/**
 *  客户端内置的上报URL的默认值
 */
#define kDefaultTTMonitorURL @"http://mon.snssdk.com/monitor/collect/"

typedef NS_ENUM(NSInteger, TTMonitorTrackerType)
{
    TTMonitorTrackerTypeUnknow = 0,
    TTMonitorTrackerTypeAPIError = 1,
    TTMonitorTrackerTypeAPISample = 2,
    TTMonitorTrackerTypeDNSReport = 3,
    TTMonitorTrackerTypeDebug = 4,//线上实时处理， 注意量不要太大
    TTMonitorTrackerTypeAPIAll = 5,//针对人群采样
    TTMonitorTrackerTypeHTTPHiJack = 6,//针对人群采样
    TTMonitorTrackerTypeLocalLog = 8, // 定向上报本地日志
};


#endif

