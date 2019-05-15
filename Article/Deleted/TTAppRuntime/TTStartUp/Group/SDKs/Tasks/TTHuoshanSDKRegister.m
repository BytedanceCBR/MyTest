//
//  TTHuoshanSDKRegister.m
//  Article
//
//  Created by fengyadong on 17/1/19.
//
//

#import "TTHuoshanSDKRegister.h"
#import "HTSAppDelegate.h"
#import "TTSettingsManager.h"

@implementation TTHuoshanSDKRegister

- (NSString *)taskIdentifier {
    return @"Huoshan";
}

- (BOOL)isConcurrent {
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue];
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    //接管火山直播插件的appDelegate生命周期
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([TTDeviceHelper OSVersionNumber] >= 8.f) {
            if ([[HTSAppDelegate sharedInstance] respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
                [[HTSAppDelegate sharedInstance] performSelector:@selector(application:didFinishLaunchingWithOptions:) withObject:application withObject:launchOptions];
            }
        }
    });
    
#pragma clang diagnostic pop
}

@end
