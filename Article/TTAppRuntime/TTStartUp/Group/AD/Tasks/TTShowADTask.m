//
//  TTShowADTask.m
//  Article
//
//  Created by fengyadong on 17/1/19.
//
//

#import "TTShowADTask.h"
#import "NewsBaseDelegate.h"
//#import "TTADEngine.h"
//#import "SSCommon+UIApplication.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import "TTAdManager.h"
#import "TTAdSplashMediator.h"
#import "FHUtils.h"
#import "FHEnvContext.h"

@implementation TTShowADTask

- (NSString *)taskIdentifier {
    return @"ShowAD";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    //从推动进入或者schema调起进入均不展示广告
    BOOL fromAPNS = [[self class] isFromAPNSWithOptions:launchOptions];
    BOOL fromSchema = [[self class] isFromSchemaWithOptions:launchOptions];
    [[self class] settingSplashADShowType:fromAPNS || fromSchema];
    
    [[self class] showADSplash];
    [TTAdManageInstance applicationDidFinishLaunching];
}

+ (void)showADSplash {
//    if ([adManagerInstance splashADShowType] != SSSplashADShowTypeIgnore) {
//        if (!SharedAppDelegate.window.rootViewController) {
//            UIViewController *blankVC = [[UIViewController alloc] init];
//            UIImageView *bgView = [[UIImageView alloc] initWithFrame:blankVC.view.bounds];
//            [bgView setImage:[self splashImageForPrefix:@"Default" extension:@"png"]];
//            bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//            [blankVC.view addSubview:bgView];
//            SharedAppDelegate.window.rootViewController = blankVC;
//        }
//        if ([TTDeviceHelper isPadDevice] && [TTDeviceHelper OSVersionNumber] < 8) {
//            [adManagerInstance applicationDidBecomeActiveShowOnWindow:SharedAppDelegate.window splashShowType:adManagerInstance.splashADShowType];
//        }
//        else {
//            [adManagerInstance applicationDidBecomeActiveShowOnWindow:SharedAppDelegate.window splashShowType:adManagerInstance.splashADShowType];
//        }
//    }else{
//        LOGD(@"ingore....");
//    }
//    LOGD(@"ingore....");
//    [adManagerInstance setSplashADShowType:SSSplashADShowTypeIgnore];
    
    
    BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];
    if (hasSelectedCity) {
        [[TTAdSplashMediator  shareInstance] displaySplashOnWindow:SharedAppDelegate.window splashShowType:[TTAdSplashMediator shareInstance].splashADShowType];
    }
}

+ (BOOL)isFromAPNSWithOptions:(NSDictionary *)launchOptions {
    return ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil);
}

+ (void)settingSplashADShowType:(BOOL)shouldHide {
//    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
//    if(shouldHide) {
//        adManagerInstance.splashADShowType = SSSplashADShowTypeHide;
//    } else {
//        adManagerInstance.splashADShowType = SSSplashADShowTypeShow;
//    }
//
//    if([TTSandBoxHelper isAPPFirstLaunch])
//    {
//        adManagerInstance.splashADShowType = SSSplashADShowTypeHide;
//    }
    TTAdSplashMediator *mediator = [TTAdSplashMediator shareInstance];
    
    if(shouldHide) {
        mediator.splashADShowType = SSSplashADShowTypeHide;
    } else {
        mediator.splashADShowType = SSSplashADShowTypeShow;
    }
    if([TTSandBoxHelper isAPPFirstLaunch])
    {
        mediator.splashADShowType = SSSplashADShowTypeHide;
    }
}

+ (BOOL)isFromSchemaWithOptions:(NSDictionary *)launchOptions
{
    if ([TTDeviceHelper OSVersionNumber] >= 8.0) {
        return ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] != nil||[launchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey]!=nil);
    }
    
    return  ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] != nil);
}


#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
    //app启动后,只有后台到前台的操作才触发开屏
//    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
//
//    if (adManagerInstance.showByForground == YES) {
//        [adManagerInstance applicationDidBecomeActiveShowOnWindow:SharedAppDelegate.window splashShowType:adManagerInstance.splashADShowType];
//        adManagerInstance.showByForground = NO;
//    }
    TTAdSplashMediator *mediator = [TTAdSplashMediator shareInstance];
    if (mediator.showByForground == YES) {
        [mediator displaySplashOnWindow:SharedAppDelegate.window splashShowType:mediator.splashADShowType];
        mediator.showByForground = NO;
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
//    [adManagerInstance didEnterBackground];
    TTAdSplashMediator *mediator = [TTAdSplashMediator shareInstance];
    [mediator didEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
//    adManagerInstance.showByForground = YES;
//    adManagerInstance.splashADShowType = SSSplashADShowTypeShow;
    
    TTAdSplashMediator *mediator = [TTAdSplashMediator shareInstance];
    mediator.showByForground = YES;
    mediator.splashADShowType = SSSplashADShowTypeShow;
}



@end
