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
    FHErrorHubTypeBuryingPoint = 2 ,//埋点校验
     FHErrorHubTypeConfig = 3, //现场保存
    FHErrorHubTypeShare = 4 ,//分享相关
    FHErrorHubTypeCustom = 5 ,//保存每种类型相应的key用于后续读取所有保存内容
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
- (void)checkRequestResponseWithHost:(NSString *)host requestParams:(NSDictionary *)params responseStatus:(TTHttpResponse *)responseStatus response:(id)response analysisError:(NSError *)analysisError changeModelType:(FHNetworkMonitorType )type errorHubType:(FHErrorHubType)errorHubType;

/// 核心埋点参数
/// @param eventName 事件名称
/// @param params 埋点参数
/// @param errorHubType 类型
- (void)checkBuryingPointWithEvent:(NSString *)eventName Params:(NSDictionary* )eventParams errorHubType:(FHErrorHubType)errorHubType;
- (UIViewController *)jsd_getRootViewController;

/// 获取本地数据
/// @param errorHubType 类型
- (NSArray *)getLocalErrorDataWithType:(FHErrorHubType)errorHubType;

/// 读取数据路径
/// @param errorHubType 类型
- (NSString *)localDataPathWithType:(FHErrorHubType)errorHubType;


/// 添加数据保存
/// @param Data 数据 （必须包含name和error_info）用于展示和复制
/// @param errorHubType 类型
- (void)addLogWithData:(id)Data logType:(FHErrorHubType)errorHubType;

- (void)saveConfigAndSettings;
@end

NS_ASSUME_NONNULL_END
