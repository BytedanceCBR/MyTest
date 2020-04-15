//
//  FHHouseErrorHubManager.h
//  FHHouseBase
//
//  Created by liuyu on 2020/4/8.
//

#import <Foundation/Foundation.h>
#import "FHMainApi.h"
#import "TTNetworkManager.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger , FHErrorHubType) {
    FHErrorHubTypeRequest = 1, //请求校验
    FHErrorHubTypeBuryingPoint = 2 //埋点校验
};
@interface FHHouseErrorHubManager : NSObject

+(instancetype)sharedInstance;

/// 校验核心接口请求
/// @param host requestApi
/// @param params 请求参数
/// @param responseStatus 包括httpStatus(200或者!200)和请求header
/// @param response 请求返回数据
/// @param analysisError 解析失败错误信息
/// @param type 请求成功或者其他错误
- (void)checkRequestResponseWithHost:(NSString *)host requestParams:(id)params responseStatus:(TTHttpResponse *)responseStatus response:(id)response analysisError:(NSError *)analysisError changeModelType:(FHNetworkMonitorType )type errorHubType:(FHErrorHubType)errorHubType;

/// 核心埋点参数
/// @param eventName 事件名称
/// @param params 埋点参数
/// @param errorHubType 类型
- (void)checkBuryingPointWithEvent:(NSString *)eventName Params:(NSDictionary* )eventParams errorHubType:(FHErrorHubType)errorHubType;
- (UIViewController *)jsd_getRootViewController;
@end

NS_ASSUME_NONNULL_END
