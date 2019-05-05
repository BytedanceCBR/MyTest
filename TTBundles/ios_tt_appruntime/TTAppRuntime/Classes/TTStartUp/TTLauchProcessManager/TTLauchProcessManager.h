//
//  TTLauchProcessManager.h
//  Article
//
//  Created by xuzichao on 16/6/22.
//
//

#import <Foundation/Foundation.h>

typedef BOOL (^TTLauchProcessBoolCompletionBlock)(void);
typedef void (^TTLauchProcessReportBlock)(NSString *key, NSDictionary *info);
typedef void (^TTLauchProcessHandlerBlock)(NSInteger type, NSString *msg);

extern NSString * const TTLauchProcessLaunchCrash;
extern NSString * const TTLauchProcessServerCloseCrash;
extern NSString * const TTLauchProcessDeleteFile;
extern NSString * const TTLauchProcessError;
extern NSString * const TTLauchProcessUpdateFile;

@interface TTLauchProcessManager : NSObject

/**
 *  使用单例
 */

+ (instancetype)shareInstance;

/**
 *  APPDelegate 启动中，检测过程
 *  APPDelegate 上报和预处理逻辑 ReportBlock，key是crash的类型名，info是伴随的信息
 *  APPDelegate 正常启动逻辑 boolCompletionBlock
 *  APPDelegate 启动后，请求补丁
 */

- (BOOL)launchContinuousCrashProcess;
- (void)setReportBlock:(TTLauchProcessReportBlock)reportBlock;
- (void)setBoolCompletionBlock:(TTLauchProcessBoolCompletionBlock)completionBlock;
- (void)makePatchRequestAfterLaunch;

- (NSInteger)currentCrashCount;

@end
