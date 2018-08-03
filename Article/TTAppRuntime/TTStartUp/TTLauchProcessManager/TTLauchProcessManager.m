//
//  TTLauchProcessManager.m
//  Article
//
//  Created by xuzichao on 16/6/22.
//
//

#import <UIKit/UIKit.h>
#import "TTLauchProcessManager.h"

#define kCrashOnLaunchTimeIntervalHold          3.0 //修改为3秒
#define kContinueCrashMAXCount                  3
#define kContinueCrashReportCount               2
#define kLauchProcessRequestTimeOut                  10.0

#define kContinueCrashOnLaunchCounterKey        @"launchCrashCount"
#define kLauchProcessCrashHappenKey                  @"patchCrashHappen" //仅仅服务端可控

#define kLauchProcessLaunchFilePath                  @"/LauchProcess/launchPatch.js"
#define kLauchProcessActiveFilePath                  @"/LauchProcess/activePatch.js"
#define kLauchProcessDocumentPath                    @"/LauchProcess"
#define kLauchProcessServerUrl                       @"https://i.snssdk.com/2/misc/sparkrescue/"

static TTLauchProcessManager *JSMangager;
static BOOL _hasSwitchLauchProcessOn;

//端监控定义
NSString * const TTLauchProcessLaunchCrash           = @"TTLauchProcessLaunchCrash";
NSString * const TTLauchProcessServerCloseCrash      = @"TTLauchProcessServerCloseCrash";
NSString * const TTLauchProcessDeleteFile            = @"TTLauchProcessDeleteFile";
NSString * const TTLauchProcessError                 = @"TTLauchProcessError";
NSString * const TTLauchProcessUpdateFile            = @"TTLauchProcessUpdateFile";

@interface TTLauchProcessManager ()

@property (nonatomic, strong) NSURLSessionTask *netWorkTask;
@property (nonatomic, strong) NSURL *launchFileUrl;
@property (nonatomic, strong) NSURL *activeFileUrl;
@property (nonatomic, copy)   NSString *testPatchJs;

@end

@implementation TTLauchProcessManager
{
    TTLauchProcessReportBlock _reportBlock;
    TTLauchProcessBoolCompletionBlock _boolCompletionBlock;
    TTLauchProcessHandlerBlock _jsCrashHandlerBlock;
    BOOL _downloadPatchError;
    BOOL _simulationOn;
    BOOL _testPatchOn;
}

#pragma mark -- 初始化

+ (void)load
{
    //启动阶段的描述字段用于发送统计
    NSString * abNormalDesc = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"abnormal_task_identifier"];
    if (abNormalDesc && ![abNormalDesc isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] setValue:abNormalDesc forKey:@"abnormal_task_identifier_TEMP"];
    }
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JSMangager = [[self alloc] init];
    });
    return JSMangager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _simulationOn = NO;
        _testPatchOn = NO;
        _hasSwitchLauchProcessOn = NO;
        _downloadPatchError = NO;
        
        [self initLauchProcessFileGroup];
        [self deletePatchFileIfNeed];
        
        //监听激活状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminateNotification:) name:UIApplicationWillTerminateNotification  object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  APPDelegate 上报逻辑
 *  APPDelegate 正常启动逻辑
 *  APPDelegate 发生运行错误
 */

- (void)setReportBlock:(TTLauchProcessReportBlock)reportBlock
{
    _reportBlock = reportBlock;
}

- (void)setBoolCompletionBlock:(TTLauchProcessBoolCompletionBlock)completionBlock
{
    _boolCompletionBlock = completionBlock;
}

- (void)setJSCrashHanlder:(TTLauchProcessHandlerBlock)handlerBlock
{
    _jsCrashHandlerBlock = handlerBlock;
}

#pragma mark --- 启动中，崩溃修复

/**
 * LauchProcess 启动的检测过程
 */

- (BOOL)launchContinuousCrashProcess
{
    NSAssert(_boolCompletionBlock, @"LauchProcess_CompletionBlock 禁止为空!");
    
    NSInteger launchCrash = [self currentCrashCount];
    
    //上报条件：连续崩溃发生，第2次崩溃
    if (launchCrash >= kContinueCrashReportCount) {
        
        if (launchCrash == kContinueCrashReportCount) {
            [self deleteLaunchingPatchFile];
        }
        
        [self makeMonitorReportKey:TTLauchProcessLaunchCrash info:@{@"crashCount":@(launchCrash)}];
    }
    
    //增加一次崩溃计数
    [self addOnceCrashCount];
    
    //正常启动12秒后，则崩溃计数清零
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kCrashOnLaunchTimeIntervalHold * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self clearCrashCount];
    });
    
    //连续crash3次后，直接忽略本地缓存,同步请求更新, 保证正常启动
    //本地有缓存则直接执行，异步请求更高版本的更新
    
    if (launchCrash >= kContinueCrashMAXCount) {
        
//        //同步
//        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
//        dispatch_async(queue, ^(void) {
//
//            TTLauchProcessHandlerBlock semaphoreBlock = ^(NSInteger type,NSString *msg){
//                dispatch_semaphore_signal(semaphore);
//            };
//
//            [self getLaunchRequestBlock:semaphoreBlock];
//        });
//
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        
        //执行启动补丁
        return [self executeLaunch];
    }
    else {
        //只要有缓存就先执行,错误的JS不会被缓存
        if ([self hasLaunchLauchProcess]) {
            
            [self executeLaunch];
            
            //异步更新
//            [self getLaunchRequestBlock:nil];
        }
        
        if ([self hasActiveLauchProcess]) {
            [self executeActiveLauchProcess];
        }
        
        //原本APP的正常流程
        if (_boolCompletionBlock) {
            return _boolCompletionBlock();
        }
    }
    
    return NO;
}

/**
 * 同步请求网络返回JS
 * 更新本地JS
 * 运行修复JS之后，开始启动原本APP的逻辑
 */

//- (void)getLaunchRequestBlock:(TTLauchProcessHandlerBlock)finishBlock
//{
//    //请求参数
//    NSMutableDictionary *params = [self paramDic];
//    [params setValue:@(0) forKey:@"app_launch"];
//    [params setValue:[self getLaunchPatchVersionCode] forKey:@"lastpatch_version"];
//
//    __block NSURL *requestUrl = [self URLWithString:kLauchProcessServerUrl queryItems:params fragment:nil];
//
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kLauchProcessRequestTimeOut];
//    [request setHTTPMethod:@"GET"];
//    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//
//        if (!error && data) {
//
//            NSError *jsonError;
//            NSString *jsonString = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
//
//            if (!jsonError) {
//
//                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
//                NSDictionary *responseData = (NSDictionary *)[json objectForKey:@"data"];
//
//                //服务端的patch 是一个队列 p1 p2 p3... 下发会从p3开始往前找，
//                //patch是ON状态，且用户命中下发就下发
//                //如果全没命中 或者patchOff了，就返回nil 这时候客户端清理掉本地patch
//
//                if (responseData) {
//                    NSNumber *patchCrash = (NSNumber *)[responseData objectForKey:@"js_crash"];
//                    NSNumber *version = (NSNumber *)[responseData objectForKey:@"js_version"];
//                    NSString *base64String = (NSString *)[responseData objectForKey:@"js_value"];
//                    if (![base64String isEqualToString:@""]) {
//                        NSString *jsCodeStr = [self decodeBase64String:base64String];
//                        if (jsCodeStr && ![jsCodeStr isEqualToString:@""]) {
//                            [self updateLaunchLocalJS:jsCodeStr versionCode:version];
//                        }
//                    }
//                    else {
//                        [self deleteLaunchingPatchFile];
//                        [self makeMonitorReportKey:TTLauchProcessDeleteFile info:@{@"action":@"launchingPatchBase64Fail"}];
//                    }
//
//                    //服务端是否关闭JS
//                    [self setLauchProcessForCrash:patchCrash];
//
//                    if ([self hasLauchProcessCrash]) {
//                        [self closeLauchProcessForCrash];
//                        [self makeMonitorReportKey:TTLauchProcessServerCloseCrash info:@{@"action":@"serverCloseCrash"}];
//                    }
//                }
//                else {
//                    [self deleteLaunchingPatchFile];
//                    [self makeMonitorReportKey:TTLauchProcessDeleteFile info:@{@"action":@"launchingPatchNothing"}];
//                }
//            }
//        }
//        else {
//            if (error) {
//                [self makeMonitorReportKey:TTLauchProcessError info:@{@"errorDesc":error.debugDescription,
//                                                                 @"action":@"launchingRequestError"}];
//            }
//        }
//
//        if (finishBlock) {
//            finishBlock(0,@"request_back");
//        }
//    }];
//
//    [task resume];
//
//}

- (void)updateLaunchLocalJS:(NSString *)launchJS
                versionCode:(NSNumber *)versionCode
{
    __block BOOL needToRequestUpdate = NO;
    
    if ([self getLaunchPatchVersionCode].floatValue < versionCode.floatValue) {
        needToRequestUpdate = YES;
    }
    
    if (![self hasLaunchLauchProcess]) {
        needToRequestUpdate = YES;
    }
    
    if (needToRequestUpdate) {
        
        //删除之前的文件
        [self deleteLaunchingPatchFile];
        
        [self setLaunchPatchVersionCode:versionCode];
        
        //路径写入新数据
        [launchJS writeToURL:self.launchFileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [self makeMonitorReportKey:TTLauchProcessUpdateFile info:@{@"action":@"launchingPatchUpdate"}];
    }
}

- (BOOL)hasLaunchLauchProcess
{
    BOOL hasLaunchFile= NO;
    NSError *error = nil;
    NSString *script = [NSString stringWithContentsOfFile:self.launchFileUrl.path encoding:NSUTF8StringEncoding error:&error];
    if (!error && script && ![script isEqualToString:@""]) {
        hasLaunchFile = YES;
    }
    return hasLaunchFile;
}

- (BOOL)executeLaunch
{
    
    //启动原本的逻辑
    if (_boolCompletionBlock) {
        return  _boolCompletionBlock();
        
    }
    return NO;
}

#pragma mark --- 启动后，崩溃修复

/**
 * 异步请求网络返回JS
 * 更新本地JS,并运行
 */

- (void)makePatchRequestAfterLaunch
{
    //请求参数
    NSMutableDictionary *params = [self paramDic];
    [params setValue:@(1) forKey:@"app_launch"];
    [params setValue:[self getActivePatchVersionCode] forKey:@"lastpatch_version"];

    NSURL *requestUrl = [self URLWithString:kLauchProcessServerUrl queryItems:params fragment:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kLauchProcessRequestTimeOut];
    [request setHTTPMethod:@"GET"];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error && data) {
            
            NSError *jsonError;
            NSString *jsonString = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (!jsonError && [jsonString isKindOfClass:[NSString class]]) {
                
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
                NSDictionary *responseData = (NSDictionary *)[json objectForKey:@"data"];
                
                if (responseData) {
                    NSNumber *patchCrash = (NSNumber *)[responseData objectForKey:@"js_crash"];
                    NSNumber *version = (NSNumber *)[responseData objectForKey:@"js_version"];
                    NSString *base64String = (NSString *)[responseData objectForKey:@"js_value"];
                    if (![base64String isEqualToString:@""]) {
                        NSString *jsCodeStr = [self decodeBase64String:base64String];
                        if (jsCodeStr && ![jsCodeStr isEqualToString:@""]) {
                            [self updateActiveLocalJS:jsCodeStr versionCode:version];
                        }
                    }
                    else {
                        [self deleteActivePatchFile];
                        [self makeMonitorReportKey:TTLauchProcessDeleteFile info:@{@"action":@"activePatchBase64Fail"}];
                    }
                    
                    //服务端是否关闭JS
                    [self setLauchProcessForCrash:patchCrash];
                    
                    if ([self hasLauchProcessCrash]) {
                        [self closeLauchProcessForCrash];
                        [self makeMonitorReportKey:TTLauchProcessServerCloseCrash info:@{@"action":@"serverCloseCrash"}];
                    }
                }
                else {
                    [self deleteActivePatchFile];
                    [self makeMonitorReportKey:TTLauchProcessDeleteFile info:@{@"action":@"activePatchNothing"}];
                }
            }
        }
        else {
            if (error) {
                [self makeMonitorReportKey:TTLauchProcessError info:@{@"errorDesc":error.debugDescription,
                                                                 @"action":@"activeRequestError"}];
            }
        }
        
        [self executeActiveLauchProcess];
    }];
    
    [task resume];

}

- (void)updateActiveLocalJS:(NSString *)activeJS
                versionCode:(NSNumber *)versionCode
{
    __block BOOL needToRequestUpdate = NO;
    
    if ([self getActivePatchVersionCode].floatValue < versionCode.floatValue) {
        needToRequestUpdate = YES;
    }
    
    if (![self hasActiveLauchProcess]) {
        needToRequestUpdate = YES;
    }
    
    if (needToRequestUpdate) {
        
        //删除之前的文件
        [self deleteActivePatchFile];
        
        [self setActivePatchVersionCode:versionCode];
        
        //路径写入新数据
        [activeJS writeToURL:self.activeFileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [self makeMonitorReportKey:TTLauchProcessUpdateFile info:@{@"action":@"activePatchUpdate"}];
    }
}

- (BOOL)hasActiveLauchProcess
{
    BOOL hasActiveFile =  NO;
    NSError *error = nil;
    NSString *script = [NSString stringWithContentsOfFile:self.activeFileUrl.path encoding:NSUTF8StringEncoding error:&error];
    if (!error && script && ![script isEqualToString:@""]) {
        hasActiveFile = YES;
    }
    return hasActiveFile;
}

- (void)executeActiveLauchProcess
{

}


/**
 * closeCrash 是服务端下发的开关标识,服务端关闭，客户端不执行关闭
 * hanlder 是客户端发现运行错误时候的处理
 */
- (void)setLauchProcessForCrash:(NSNumber *)crash
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:crash.boolValue forKey:kLauchProcessCrashHappenKey];
    [defaults synchronize];
}

- (BOOL)hasLauchProcessCrash
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL crash = [defaults boolForKey:kLauchProcessCrashHappenKey];
    if (!crash) {
        crash = NO;
    }
    return crash;
}

- (void)closeLauchProcessForCrash
{
    [self setLauchProcessForCrash:@(1)];
    [self deleteActivePatchFile];
    [self deleteLaunchingPatchFile];
}

#pragma mark --- App活动通知
- (void)appDidBecomeActiveNotification:(NSNotification *)notice
{
    [self makePatchRequestAfterLaunch];
}

- (void)appDidEnterBackground:(NSNotification *)notice
{
    [self clearCrashCount];
}

- (void)appWillTerminateNotification:(NSNotification *)notice
{
    [self clearCrashCount];
}

#pragma mark --- 辅助函数

/**
 *  文件处理
 *  文件夹初始化和文件删除
 */

- (void)initLauchProcessFileGroup
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [dirs objectAtIndex:0];
    NSString *fileDocumentPath = [NSString stringWithFormat:@"%@%@",documentsPath,kLauchProcessDocumentPath];
    self.launchFileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",documentsPath,kLauchProcessLaunchFilePath]];
    self.activeFileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",documentsPath,kLauchProcessActiveFilePath]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileDocumentPath]) {
        return;
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:fileDocumentPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    
}

- (void)deletePatchFileIfNeed
{
    NSString *currentBundleStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *patchBundleStr = [defaults objectForKey:@"patchBundleStr"];
    
    if (![patchBundleStr isEqualToString:currentBundleStr]) {
        [self deleteActivePatchFile];
        [self deleteLaunchingPatchFile];
        [defaults setObject:currentBundleStr forKey:@"patchBundleStr"];
        
        [self makeMonitorReportKey:TTLauchProcessDeleteFile info:@{@"action":@"bundleUpdate"}];
    }
}

- (void)deleteLaunchingPatchFile
{
    [self setLaunchPatchVersionCode:@(0)];
    [[NSFileManager defaultManager] removeItemAtPath:self.launchFileUrl.path error:nil];
}

- (void)deleteActivePatchFile
{
    [self setActivePatchVersionCode:@(0)];
    [[NSFileManager defaultManager] removeItemAtPath:self.activeFileUrl.path error:nil];
}

/**
 *  启动时候已发生的崩溃次数
 *  增加一次崩溃
 *  清除崩溃计数
 */

- (NSInteger)currentCrashCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger count = [defaults integerForKey:kContinueCrashOnLaunchCounterKey];
    if (!count) {
        count = 0;
    }
    return count;
}

- (void)addOnceCrashCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger count = [defaults integerForKey:kContinueCrashOnLaunchCounterKey];
    if (!count) {
        count = 0;
    }
    [defaults setInteger:count + 1 forKey:kContinueCrashOnLaunchCounterKey];
    [defaults synchronize];
}

- (void)clearCrashCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:kContinueCrashOnLaunchCounterKey];
    [defaults synchronize];
}

/**
 * 读取和设置当前的补丁版本号
 */
- (void)setLaunchPatchVersionCode:(NSNumber *)code
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:code forKey:@"launchPatchVersionCode"];
    [defaults synchronize];
}

- (void)setActivePatchVersionCode:(NSNumber *)code
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:code forKey:@"activePatchVersionCode"];
    [defaults synchronize];
}

- (NSNumber *)getLaunchPatchVersionCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *code = [defaults objectForKey:@"launchPatchVersionCode"];
    if (!code) {
       code = @(0);
    }
    return code;
}

- (NSNumber *)getActivePatchVersionCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *code = [defaults objectForKey:@"activePatchVersionCode"];
    if (!code) {
        code = @(0);
    }
    return code;
}

/**
 *  base64解码
 */

- (NSString *)decodeBase64String:(NSString *)base64String
{
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *jsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return jsString;
    
}

//端监控报表
- (void)makeMonitorReportKey:(NSString *)key info:(NSDictionary *)dic
{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:dic];
    [info setValue:[self getActivePatchVersionCode] forKey:@"current_active_patch_version"];
    [info setValue:[self getLaunchPatchVersionCode] forKey:@"current_launching_patch_version"];
    
    if (_reportBlock) {
        _reportBlock(key,info);
    }
}

//应用和用户的信息参数
- (NSMutableDictionary *)paramDic
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] forKey:@"app_name"];
    [params setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"app_version"];
    [params setValue:[self getShortBundleIdString] forKey:@"app_id"];
    [params setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"kDeviceIDStorageKey"] forKey:@"device_id"];
    [params setValue:@([[[UIDevice currentDevice] systemVersion] floatValue]) forKey:@"os_version"];
    
    //启动阶段的描述字段用于发送统计
    NSString * abNormalDesc = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"abnormal_task_identifier_TEMP"];
    if (abNormalDesc && ![abNormalDesc isEqualToString:@""]) {
        [params setValue:abNormalDesc forKey:@"abnormal_task_identifier"];
    }
    
    return params;
}

/**
 * 根据参数构造下发补丁的请求url
 */

- (NSURL *)URLWithString:(NSString *)URLString queryItems:(NSDictionary *)queryItems fragment:(NSString *)fragment
{
    NSMutableString * querys = [NSMutableString stringWithCapacity:10];
    if ([queryItems count] > 0) {
        [queryItems enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [querys appendFormat:@"%@=%@", key, queryItems[key]];
            [querys appendString:@"&"];
        }];
        if ([querys hasSuffix:@"&"]) {
            [querys deleteCharactersInRange:NSMakeRange([querys length] - 1, 1)];
        }
    }
    
    NSMutableString * resultURL = [NSMutableString stringWithString:URLString];
    if ([querys length] > 0) {
        if ([resultURL rangeOfString:@"?"].location == NSNotFound) {
            [resultURL appendString:@"?"];
        }
        else if ([resultURL rangeOfString:@"&"].location != NSNotFound) {
            [resultURL appendString:@"&"];
        }
        [resultURL appendString:querys];
    }
    
    if ([fragment isKindOfClass:[NSString class]] && [fragment length] > 0) {
        [resultURL appendFormat:@"#%@", fragment];
    }
    
    resultURL = [NSMutableString stringWithString:[resultURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL * URL = [NSURL URLWithString:resultURL];
    return URL;
}

/**
 * 之前是因为后端定义类型过短，我们取boundId用“.”分隔的，后三个子字符串，作为APP区分的标识
 * 现在我们保留这种做法，按照IOS的规范，不能命名过长，后三个可以区别出来
 */
- (NSString *)getShortBundleIdString
{
    NSString *bundleString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSArray *words = [bundleString componentsSeparatedByString:@"."];
    if (words.count > 0) {
        NSInteger startIndex = words.count >= 3 ? words.count - 3 : 0 ;
        NSArray *shortWords = [words objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, words.count - startIndex)]];
        bundleString = [shortWords componentsJoinedByString:@"."];
    }
    return bundleString;
}


@end
