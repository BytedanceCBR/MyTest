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
#import <TTBaseLib/TTSandBoxHelper.h>
#import "TTLaunchDefine.h"
#import <TTKitchen/TTKitchen.h>
#import <objc/runtime.h>

DEC_TASK("TTUmengSDKRegister",FHTaskTypeSDKs,TASK_PRIORITY_HIGH+1);
static NSString *const kUmengCrashFix = @"f_settings.umeng_crash_fix";

/** 交换类方法 */
static void exchangeClassMethod(Class originalClass, SEL originSel, Class replacedClass, SEL replacedSel) {
    Method originMethod = class_getClassMethod(originalClass, originSel);
    Method replacedMethod = class_getClassMethod(replacedClass, replacedSel);
    IMP replacedMethodIMP = method_getImplementation(replacedMethod);
    BOOL didAddMethod = class_addMethod(object_getClass(objc_getMetaClass([NSStringFromClass(originalClass) UTF8String])), replacedSel, replacedMethodIMP, method_getTypeEncoding(replacedMethod));
    if (didAddMethod) {
        Method newMethod = class_getClassMethod(originalClass, replacedSel);
        method_exchangeImplementations(originMethod, newMethod);
    } else {
        method_exchangeImplementations(originMethod, replacedMethod);
    }
}

@implementation TTUmengSDKRegister

- (NSString *)taskIdentifier {
    return @"UmengSDKRegister";
}

+ (void)registerKitchen
{
    TTRegisterKitchenMethod(TTKitchenRegisterBlock(^{
        TTKConfigBOOL(kUmengCrashFix, @"Umeng调起剪切板修复开关", YES);
    }));
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    
    if ([TTKitchen getBOOL:kUmengCrashFix]) {
        [self hookUmengSDK];
    }
    [[self class] registerUmengSDK];
    [[self class] displayDebugUmengIndicator];
}

#pragma mark - UMeng OpenUDID hook
/** hook UMeng openUDID函数 */
- (void)hookUmengSDK {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        exchangeClassMethod(NSClassFromString(@"UMANProtocolData"), NSSelectorFromString(@"openUDIDString"), [self class], @selector(hook_openUDIDString));
    });
}
/** Umeng 调起剪切板处理 */
+ (NSString *)hook_openUDIDString {
    NSString *udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUMengOpenUDID"];
    if (udid) {
        return udid;
    } else {
        NSString *openUDID = [self hook_openUDIDString]; // 走 UMeng 自己的逻辑
        if (openUDID) {
            [[NSUserDefaults standardUserDefaults] setObject:openUDID forKey:@"kUMengOpenUDID"];
        }
        return openUDID;
    }
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
#else
//#elif INHOUSE
    if ([TTSandBoxHelper isInHouseApp]) {
        if([DebugUmengIndicator displayUmengISOn])
        {
            [[DebugUmengIndicator sharedIndicator] startDisplay];
        }
        else
        {
            [[DebugUmengIndicator sharedIndicator] stopDisplay];
        }
    }
#endif
    
}

@end
