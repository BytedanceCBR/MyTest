//
//  TTBackgroundModeTask.m
//  Article
//
//  Created by fengyadong on 17/1/23.
//
//

#import "TTBackgroundModeTask.h"
#import "NetworkUtilities.h"
#import "SSBatchItemActionManager.h"
#import "TTUserSettingsReporter.h"
#import "SSSimpleCache.h"
#import "TTInstallIDManager.h"
#import "TTNetworkManager.h"
#import "TTHandleAPNSTask.h"
#import <TTNetworkManager/TTDefaultHTTPRequestSerializer.h>
#import "TouTiaoPushSDK.h"



@interface TTBackgroundModeTask ()

@end

static NSUInteger reportTryCount = 0;

@implementation TTBackgroundModeTask

- (NSString *)taskIdentifier {
    return @"BackgroundModeTask";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (!TTNetworkConnected()) return;
    
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier taskId;
    taskId = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:taskId];
    }];
    
    if (taskId == UIBackgroundTaskInvalid) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SSBatchItemActionManager shareManager] excuteSynchronizedBatch];
        [[TTUserSettingsReporter sharedInstance] startReportUserConfiguration];
        
        reportTryCount = 0;
        [self reportAppEnterBackground];
        [[self class] cleanNSUrlCacheIfNeeded];
        
        if (!isShareToPlatformEnterBackground){
            [[SSSimpleCache sharedCache] enterBackgroundClear];
        }
        
        [app endBackgroundTask:taskId];
    });
    TLS_LOG(@"applicationDidEnterBackground");
#ifdef DEBUG
    LOGD(@"document path = %@", NSHomeDirectory());
#endif
}

+ (void)reportDeviceTokenByAppLogout {
    if (reportTryCount > 1) {
        reportTryCount = 0;
        return;
    }
    reportTryCount++;
    if(![SSCommonLogic pushSDKEnable]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        if(!isEmptyString([[TTInstallIDManager sharedInstance] installID]))
        {
            [params setValue:[[TTInstallIDManager sharedInstance] installID] forKey:@"iid"];
        }
        
        if(!isEmptyString([[TTInstallIDManager sharedInstance] deviceID]))
        {
            [params setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
        }
        
        if (!isEmptyString([TTSandBoxHelper appName])) {
            [params setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
        }
        
        if (!isEmptyString([TTSandBoxHelper ssAppID])) {
            [params setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
        }
        
        if (!isEmptyString([TTDeviceHelper platformName])) {
            [params setValue:[TTDeviceHelper platformName] forKey:@"platform"];
        }
        
        if (!isEmptyString([TTSandBoxHelper getCurrentChannel])) {
            [params setValue:[TTSandBoxHelper getCurrentChannel] forKey:@"channel"];
        }
        
        NSString *deviceToken = [TTHandleAPNSTask deviceTokenString];
        if (!isEmptyString(deviceToken)) {
            [params setValue:deviceToken forKey:@"token"];
        }
        
        if (!isEmptyString([TTDeviceHelper openUDID])) {
            [params setValue:[TTDeviceHelper openUDID] forKey:@"openudid"];
        }
        
        __weak typeof(self) wself = self;
        [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting appLogoutURLString] params:params method:@"POST" needCommonParams:NO requestSerializer:[TTDefaultHTTPRequestSerializer class] responseSerializer:nil autoResume:YES callback:^(NSError *error, id result) {
            
            if ([result isKindOfClass:[NSDictionary class]] && [[result objectForKey:@"message"] isKindOfClass:[NSString class]] && [[result objectForKey:@"message"] isEqualToString:@"success"]) {
                reportTryCount = 0;
            } else {
                [wself.class reportDeviceTokenByAppLogout];
            }
        }];
    } else {
        TTUploadTokenRequestParam *param = [TTUploadTokenRequestParam requestParam];
        param.token = [TTHandleAPNSTask deviceTokenString];
        [TouTiaoPushSDK sendRequestWithParam:param completionHandler:^(TTBaseResponse *response) {
            if(!response.error && [[response.jsonObj valueForKey:@"message"] isEqualToString:@"success"]) {
                reportTryCount = 0;
            } else {
                [self.class reportDeviceTokenByAppLogout];
            }
        }];
    }
}

- (void)reportAppEnterBackground {
    [self.class reportDeviceTokenByAppLogout];
}

+ (void)cleanNSUrlCacheIfNeeded{
    NSUInteger value = [[NSURLCache sharedURLCache] currentDiskUsage];
    if (value/1024/1024 > [SSCommonLogic maxNSUrlCache]) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
}

@end
