//
//  TTOpenURLFeedBackLogTask.m
//  Article
//
//  Created by tyh on 2017/9/11.
//
//

#import "TTOpenURLFeedBackLogTask.h"
#import "TTTrackerWrapper.h"
#import "TTSettingsManager.h"

@implementation TTOpenURLFeedBackLogTask

- (NSString *)taskIdentifier {
    return @"OpenURLFeedBackLogURL";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL isNeedUploadLaunchlog = [[[TTSettingsManager sharedManager] settingForKey:@"tt_need_upload_launchlog" defaultValue:@0 freeze:NO] boolValue];
    if (!isNeedUploadLaunchlog) {
        return NO;
    }
    NSDictionary *dic = [self dealUrlToLogParams:url];
    if (!SSIsEmptyDictionary(dic)) {
        [TTTrackerWrapper eventV3:@"launch_log" params:dic];
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {

        NSURL *webpageURL = userActivity.webpageURL;
        NSDictionary *queryDict = [self queryItemsForURL:webpageURL];
        NSString *scheme = [queryDict objectForKey:@"scheme"];
        
        BOOL isNeedUploadLaunchlog = [[[TTSettingsManager sharedManager] settingForKey:@"tt_need_upload_launchlog" defaultValue:@0 freeze:NO] boolValue];
        if (!isNeedUploadLaunchlog) {
            return NO;
        }
        NSDictionary *dic = [self dealUrlToLogParams:[NSURL URLWithString:[scheme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        if (!SSIsEmptyDictionary(dic)) {
            [TTTrackerWrapper eventV3:@"launch_log" params:dic];
        }
    }
    return NO;

}



- (NSDictionary *)dealUrlToLogParams:(NSURL *)url
{
    if (!url) {
        return nil;
    }
    
    
    NSMutableDictionary *dic = [[self queryItemsForURL:url] mutableCopy];
    
    if (!dic) {
        return nil;
    }
    
    //如果不允许log
    if (![[dic valueForKey:@"needlaunchlog"] boolValue]) {
        return nil;
    }
    
    NSString *authority;

    
    if (!isEmptyString(url.scheme)) {
        [dic setValue:url.scheme forKey:@"launchlog_protocol"];
    }
    
    if (!isEmptyString(url.host)) {
        if (url.port) {
            authority = [NSString stringWithFormat:@"%@:%@",url.host,url.port];
        }else{
            authority = url.host;
        }
        [dic setValue:authority forKey:@"aunchlog_authority"];
    }
    if (!isEmptyString(url.path)) {
        [dic setValue:url.path forKey:@"launchlog_path"];
    }
    return [dic copy];
  
}


- (NSDictionary *)queryItemsForURL:(NSURL *)URL
{
    NSString * query = [URL query];
    if ([query length] == 0) {
        return nil;
    }
    
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithCapacity:10];
    NSArray *paramsList = [query componentsSeparatedByString:@"&"];
    [paramsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keyAndValue = [obj componentsSeparatedByString:@"="];
        if ([keyAndValue count] > 1) {
            NSString *paramKey = [keyAndValue objectAtIndex:0];
            NSString *paramValue = [keyAndValue objectAtIndex:1];
            if ([paramValue rangeOfString:@"%"].length > 0) {
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                CFStringRef decodedString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                 
                                                                                                    kCFAllocatorDefault,
                                                                                                    (__bridge CFStringRef)paramValue,
                                                                                                    CFSTR(""),
                                                                                                    kCFStringEncodingUTF8);
#pragma clang diagnostic pop
                paramValue = (__bridge_transfer NSString *)decodedString;
            }
            
            [result setValue:paramValue forKey:paramKey];
        }
    }];
    
    return result;
}


@end
