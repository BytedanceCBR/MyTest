//
//  TTTestManager.m
//  Article
//
//  Created by carl on 2017/4/9.
//
//

#import "TTTestManager.h"
#import "SSDebugViewController.h"
#import "TTNetworkManager.h"


#import "TTLogServer.h"
#import "TTTestAppModule.h"
#import "TTTestCommonLogicModule.h"

#define SSLogRemoteFailureTimes @"SSLogRemoteFailureTimes"

@interface TTTestManager ()

@end

@implementation TTTestManager

+ (void)load {
#if INHOUSE
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
        [TTTestManager buildUpTest];
        observer = nil; // 避免 observer 和 block 循环引用导致泄漏问题
    }];
#endif
}

+ (void)buildUpTest {
    NSDictionary *config = [self configTestEnv];
    if (config == nil) {
        return;
    }
    NSDictionary *log_config = [config tt_dictionaryValueForKey:@"log_server"];
    [TTLogServer configWith:log_config];
    [TTLogServer startLogger];
    
    NSDictionary *app_config = [config tt_dictionaryValueForKey:@"app"];
    [TTTestAppModule configWith:app_config];
    
    NSDictionary *settings_config = [config tt_dictionaryValueForKey:@"settings"];
    [TTTestCommonLogicModule configWith:settings_config];
}

+ (void)tearDown {
    
}

+ (NSDictionary *)configTestEnv {
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    if (!isEmptyString(configFilePath)) {
        NSError *error;
        NSData *data = [NSData dataWithContentsOfFile:configFilePath];
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            return dict;
        }
    }
    return nil;
}

@end
