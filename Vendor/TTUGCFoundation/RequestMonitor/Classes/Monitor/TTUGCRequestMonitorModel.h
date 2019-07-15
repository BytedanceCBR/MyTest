//
//  TTUGCRequestMonitorModel.h
//  News
//
//  Created by ranny_90 on 2017/10/18.
//

#import <Foundation/Foundation.h>
#import "TTUGCNetworkMonitor.h"

@interface TTUGCRequestMonitorModel : NSObject

@property (nonatomic, assign) BOOL enableMonitor;

@property (nonatomic, copy) NSString *monitorService;

@property (nonatomic, assign) NSInteger monitorStatus; // 对应category中的status

@property (nonatomic, strong) NSDictionary *monitorExtra; // 存于 hive

@property (nonatomic, copy) NSDictionary *category; // 可枚举，只有一级

@property (nonatomic, copy) NSDictionary *metric; // 数值类型，只有一级

@property (nonatomic, assign) NSTimeInterval cost; // 请求耗时

- (NSDictionary *)categoryContainsMonitorStatus; // 将monitorStatus作为status给端监控的category使用

@end
