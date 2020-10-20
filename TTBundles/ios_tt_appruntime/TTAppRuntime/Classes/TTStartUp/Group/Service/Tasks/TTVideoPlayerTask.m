//
//  TTIESPlayerTask.m
//  Article
//
//  Created by 邱鑫玥 on 2018/1/7.
//

#import "TTVideoPlayerTask.h"
#import "TTHTSVideoConfiguration.h"
#import "TTLaunchDefine.h"
#import "TTVideoEngine.h"
#import "TTVideoEngine+Preload.h"
#import "NSDictionary+TTAdditions.h"

DEC_TASK("TTVideoPlayerTask",FHTaskTypeService,TASK_PRIORITY_HIGH+14);

@implementation TTVideoPlayerTask

- (NSString *)taskIdentifier
{
    return @"VideoPlayer";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    
    /// 最大的缓存 size
    [TTVideoEngine ls_localServerConfigure].maxCacheSize  = 100 *1024 *1024;
    /// 缓存文件夹 cach
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [TTVideoEngine ls_localServerConfigure].cachDirectory = docsdir;
    /// 预加载任务的并行数量，默认是 2.
    [TTVideoEngine ls_localServerConfigure].preloadParallelNum = 2;
    /// 开启 httpDNS 需要设置为YES,默认是 NO.
    /// 还需要配置 ls_mainDNSParseType:backup: 才能开启 httpDNS 功能
    //[TTVideoEngine ls_localServerConfigure].enableExternDNS = YES;
    /// 设置代理
    [TTVideoEngine ls_setPreloadDelegate:(id<TTVideoEnginePreloadDelegate>)self];
        
    /// 请明确参数已经配置正确，更多参数请看头文件
    [TTVideoEngine ls_start];
//    NSDictionary *s = [self fhSettings];
//    BOOL startupOptimizeClose = ![[self fhSettings] tt_boolValueForKey:@"f_startup_optimize_open"];
//    if(startupOptimizeClose){
//        [TTHTSVideoConfiguration setup];
//    }else{
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [TTHTSVideoConfiguration setup];
//        });
//    }
}

//- (NSDictionary *)fhSettings {
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
//        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
//    } else {
//        return nil;
//    }
//}

/// 数据模块产生错误时，回调信息，目前会在 ls_start 失败时回调，vid 方式预加载时，请求 videoModel 失败回调（对应的 task 也可获取该回调信息，详见 TTVideoEnginePreloaderVidItem）；
- (void)preloaderErrorForVid:(nullable NSString *)vid errorType:(TTVideoEngineDataLoaderErrorType)errorType error:(NSError *)error {
    
    NSLog(@"666");
}
/// 数据模块的日志信息，业务需要上报该日志，上报的方式参照播放器的日志上报。
/// ⚠️ Called in an asynchronous thread.
- (void)localServerLogUpdate:(NSDictionary *)logInfo{
    
    NSLog(@"666");
}
/// 网络测速信息
/// ⚠️ Called in an asynchronous thread.
- (void)localServerTestSpeedInfo:(NSTimeInterval)timeInternalMs size:(NSInteger)sizeByte {
    
    NSLog(@"666");
}
/// 缓存进度信息，目前仅在预加载结束，播放缓存结束时回调，taskType 可以区分预加载和播放任务
/// ⚠️ Called in an asynchronous thread.
- (void)localServerTaskProgress:(TTVideoEngineLocalServerTaskInfo *)taskInfo {
    
    NSLog(@"666");
}

@end
