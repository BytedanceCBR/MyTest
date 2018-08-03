//
//  TTStartupTask.h
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import <Foundation/Foundation.h>

@interface TTStartupTask : NSObject

- (BOOL)shouldExecuteForApplication:(UIApplication *)application options:(NSDictionary *)launchOptions;//包裹本业务执行的代码，满足条件并且本业务没发生异常就返回YES

- (BOOL)isNormal;//基类方法，子类不要重写 正常的两个条件：1.上次启动没发生过崩溃或者LauchProcess已经生效

- (BOOL)isResident;//该任务是否在启动之后常驻，一般用于监听通知或者接回调

- (NSString *)taskIdentifier;//本业务标识

- (void)startAndTrackWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions;//执行与时间监控

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions;//具体的业务代码

- (void)cleanIfNeeded;//清理缓存尝试修复

- (void)setTaskNormal:(BOOL)isNormal;//设置标志位 本任务是否正常


- (BOOL)isConcurrent;  //是否支持多线程并发

@end
