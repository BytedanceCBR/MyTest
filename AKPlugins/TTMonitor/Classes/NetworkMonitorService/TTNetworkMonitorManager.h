//
//  TTNetworkMonitorManager.h
//  Article
//
//  Created by ZhangLeonardo on 16/3/23.
//
//

#import <Foundation/Foundation.h>
#import "TTExtensions.h"

/**
 *  给监控的回调，有请求的时候会发送通知
 */
//extern NSString * const kTTNetworkManagerMonitorStartNotification;
///**
// *  给监控的回调，当请求完成时候会通知，包括成功和失败
// */
//extern NSString * const kTTNetworkManagerMonitorFinishNotification;//contain fail and done
//
//extern const NSString *  const kTTNetworkManagerMonitorRequestKey;
//extern const NSString *  const kTTNetworkManagerMonitorResponseKey;
//extern const NSString *  const kTTNetworkManagerMonitorErrorKey;
//extern const NSString *  const kTTNetworkManagerMonitorResponseDataKey;
//extern const NSString *  const kTTNetworkManagerMonitorRequestTriedTimesKey;



@interface TTNetworkMonitorManager : NSObject


+ (instancetype)defaultMonitorManager;

- (void)enableMonitor;

@end
