//
//  FHHouseErrorHubManager.h
//  FHHouseBase
//
//  Created by liuyu on 2020/4/8.
//

#import <Foundation/Foundation.h>
#import "FHMainApi.h"
#import "TTNetworkManager.h"
#import "FHErrorHubDataReadWrite.h"
#import "FHHouseErrorHub.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseErrorHubManager : NSObject
+(instancetype)sharedInstance;

/// 校验核心接口请求
/// @param host requestApi
/// @param params 请求参数
/// @param responseStatus 包括httpStatus(200或者!200)和请求header
/// @param response 请求返回数据
/// @param analysisError 解析失败错误信息
/// @param type 请求成功或者其他错误
/// @param senceDic 关联现场
- (void)checkRequestResponseWithHost:(NSString *)host requestParams:(NSDictionary *)params responseStatus:(TTHttpResponse *)responseStatus response:(id)response analysisError:(NSError *)analysisError changeModelType:(FHNetworkMonitorType )type errorHubType:(FHErrorHubType)errorHubType;

/// 核心埋点参数
/// @param eventName 事件名称
/// @param params 埋点参数
/// @param errorHubType 类型
/// @param senceDic 关联现场
- (void)checkBuryingPointWithEvent:(NSString *)eventName Params:(NSDictionary* )eventParams errorHubType:(FHErrorHubType)errorHubType;
- (UIViewController *)jsd_getRootViewController;

- (void)saveConfigAndSettings;


/// 注册需要上报自己信息的类也就是现场
/// @param cls 类
- (void)registerFHErrorHubProcotolClass:(Class)cls;

/// 保存自定义错误
/// @param errorHub 错误信息对象
- (void)saveCustomErrorHubSence:(FHHouseErrorHub *)errorHub;

/// 返回问题现场名数组
- (NSArray *)returnSenceArr;

@end

NS_ASSUME_NONNULL_END
