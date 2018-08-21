//
//  TTCrashRepotTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTCrashRepotTask.h"

@implementation TTCrashRepotTask

#if TARGET_IPHONE_SIMULATOR
static void handleRootException(NSException* exception) {
    __unused NSString* name = [ exception name ];
    __unused NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ];
    for ( NSString* item in symbols )
    {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    LOGD(@"Exception: %@, %@, \r\n%@", name, reason, strSymbols);
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *crashString = [NSString stringWithFormat:@",- %@ ->[Uncaught Exception]\r\nName:%@,Reason:%@\r\n[Fe Symbols Start]\r\n%@[Fe Symbols End]\r\n\r\n",
                             dateStr,name,reason,strSymbols];
    [TTDebugRealMonitorManager handleException:crashString];
    assert(0);
}
#endif


static void newHandleRootException(NSException* exception) {
    __unused NSString* name = [ exception name ];
    __unused NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ];
    for ( NSString* item in symbols )
    {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *crashString = [NSString stringWithFormat:@",- %@ ->[Uncaught Exception]\r\nName:%@,Reason:%@\r\n[Fe Symbols Start]\r\n%@[Fe Symbols End]\r\n\r\n",
                             dateStr,name,reason,strSymbols];
    [TTDebugRealMonitorManager handleException:crashString];
}

- (NSString *)taskIdentifier {
    return @"CrashReport";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    if ([SSCommonLogic enableCrashMonitor]) {
        NSSetUncaughtExceptionHandler(newHandleRootException);
    }else{
#if TARGET_IPHONE_SIMULATOR
        NSSetUncaughtExceptionHandler(handleRootException);
#endif
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([SSCommonLogic toutiaoCrashReportEnable]) {
            //[SSTracker startSendException];
        }
    });
}

@end
