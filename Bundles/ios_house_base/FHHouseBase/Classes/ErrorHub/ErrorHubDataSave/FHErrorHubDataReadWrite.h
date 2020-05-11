//
//  FHErrorHubDataReadWrite.h
//  FHHouseBase
//
//  Created by liuyu on 2020/5/9.
//

#import <Foundation/Foundation.h>
#import "FHHouseErrorHub.h"
NS_ASSUME_NONNULL_BEGIN


@interface FHErrorHubDataReadWrite : NSObject

/// 去除dictionary中所有为空的数据
/// @param inputDic 输入dictionary
+ (NSDictionary *)removeNillValue:(NSDictionary *)inputDic;

/// 获取本地数据
/// @param errorHubType 类型
+ (NSArray *)getLocalErrorDataWithType:(FHErrorHubType)errorHubType;

/// 读取数据路径
/// @param errorHubType 类型
+ (NSString *)localDataPathWithType:(FHErrorHubType)errorHubType;


/// 添加数据保存
/// @param Data 数据 （必须包含name和error_info）用于展示和复制
/// @param errorHubType 类型
+ (void)addLogWithData:(id)Data logType:(FHErrorHubType)errorHubType;


@end

NS_ASSUME_NONNULL_END
