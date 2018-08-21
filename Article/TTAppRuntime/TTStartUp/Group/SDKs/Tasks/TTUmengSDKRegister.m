//
//  TTUmengSDKRegister.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTUmengSDKRegister.h"
#import "NewsBaseDelegate.h"
#import "DebugUmengIndicator.h"
#import <UMMobClick/MobClick.h>

@implementation TTUmengSDKRegister

- (NSString *)taskIdentifier {
    return @"UmengSDKRegister";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [[self class] registerUmengSDK];
    [[self class] displayDebugUmengIndicator];
}

+ (void)registerUmengSDK {
    // 注册友盟
    UMConfigInstance.appKey = [SharedAppDelegate appKey];
    UMConfigInstance.channelId = [TTSandBoxHelper getCurrentChannel];
    UMConfigInstance.bCrashReportEnabled = NO;
    [MobClick setCrashReportEnabled:NO];//坑爹Umeng 换什么handler
    [MobClick startWithConfigure:UMConfigInstance];
}

+ (void)displayDebugUmengIndicator {
#ifdef DEBUG
    if([DebugUmengIndicator displayUmengISOn])
    {
        [[DebugUmengIndicator sharedIndicator] startDisplay];
    }
    else
    {
        [[DebugUmengIndicator sharedIndicator] stopDisplay];
    }
#elif INHOUSE
    if([DebugUmengIndicator displayUmengISOn])
    {
        [[DebugUmengIndicator sharedIndicator] startDisplay];
    }
    else
    {
        [[DebugUmengIndicator sharedIndicator] stopDisplay];
    }
#endif
}

@end
