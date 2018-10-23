//
//  TTTrackerDelegate.h
//  Pods
//
//  Created by fengyadong on 2017/3/3.
//
//

#import <Foundation/Foundation.h>

@protocol TTTrackerDelegate <NSObject>

@optional

/**
 将要请求installID
 */
- (void)willStartGetInstallID;

/**
 debug用，将日志上传到本地服务器

 @param logs 日志原始Log，字典/数组/字符串
 @param dict 其他额外参数
 */
- (void)willSendValueToLogServer:(id)logs parameters:(NSDictionary *)dict;

/**
 友盟上报提醒

 @param mStr 展示字符串
 */
- (void)willShowDebugUmengIndicatorWithDisplayString:(NSString *)mStr;

/**
 将要保存一条日志数据，用于外部监控等需求
 
 @param dict 日志的完整数据，字典格式
 */
- (void)willCacheOneLogItem:(NSDictionary *)dict;

@end
