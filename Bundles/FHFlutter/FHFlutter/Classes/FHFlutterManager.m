//
//  FHFlutterManager.m
//  ABRInterface
//
//  Created by 谢飞 on 2020/8/25.
//


#import "FHFlutterManager.h"
#import "BDPMSManager.h"
#import "FlutterManager.h"
#import "BDFlutterPackageManager.h"
#import "RouteAppPlugin.h"
#import "FHDynamicRouteProtocolImplement.h"
#import "FHRoutePluginProtocolImplement.h"
#import "BDTrackerProtocol.h"
#import "RouteAppPackagePackageInfo.h"
#import "FHFlutterViewController.h"
#import "BDPMSFileManager.h"
#import "GeneratedPluginRegistrant.h"
#import "TTUIResponderHelper.h"
#import "NSURL+BTDAdditions.h"
#import "NSString+BTDAdditions.h"
#import "NSDictionary+BTDAdditions.h"
#import "TTSettingsManager.h"
#import "FlutterManager.h"
#import "FHFlutterTraceIMP.h"

#import <FCFlutterShell/VesselServiceRegistry.h>
#import <FHURLSettings.h>
#import <FCFlutterShell/VesselEnvironment.h>

static NSString *const kFHSettingsKey = @"kFHSettingsKey";
static NSString *const kFModulePacakgeName = @"BFlutterBusiness";

@implementation FHFlutterManager

+(instancetype)sharedInstance
{
    static FHFlutterManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+(void)registerFHFlutterPackageInfo
{
    // SaveU
    BDPMSConfig *config = [[BDPMSConfig alloc] init];
    config.aid = @"1370";
    config.channel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"];;
    config.deviceId = [BDTrackerProtocol deviceID];
    
    //手动赋值版本号
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    if(bundleVersion.length > 0){
       config.bundleVersion = [NSString stringWithFormat:@"%@.%@",shortVersion,[bundleVersion substringFromIndex:bundleVersion.length - 1]];
    }
    
    [[BDPMSManager sharedInstance] setConfig:config];
    [[BDFlutterPackageManager sharedInstance] loadPackagesWithCallback:^(BOOL success) {
        NSLog(@"BDFlutterPackageManager初始化%@", success ? @"成功" : @"失败");
    }];
    
    [VesselEnvironment configBaseUrl:[FHURLSettings baseURL]];
    
    [[FlutterManager sharedManager] setReleaseDartVMEnabled:YES];
    [[FlutterManager sharedManager] setAutoDestroyFlutterContext:YES];
    [RouteAppPlugin registerWithPluginProtocols:@[[FHDynamicRouteProtocolImplement class], [FHRoutePluginProtocolImplement class]]];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
            if([FHFlutterManager isCanFlutterPreload]){
                RouteAppPackagePackageInfo *packageInfo = [[RouteAppPackagePackageInfo alloc] init];
                packageInfo.name = kFModulePacakgeName;
                
                if ([self isCanFlutterDynamicart] && [[BDFlutterPackageManager sharedInstance] validPackageWithName:kFModulePacakgeName]) {
                    packageInfo = [[BDFlutterPackageManager sharedInstance]  validPackageWithName:kFModulePacakgeName];
                }
                 [[FlutterManager sharedManager] preloadFlutterEngineWithPackage:packageInfo];
            }
        }
    });
    
    [VesselServiceRegistry registerProxy:[FHFlutterTraceIMP class] forService:@protocol(HostTrackService)];
   
}

+(void)jumpToCustomerDetail:(NSDictionary *)params{
    NSString *rootPath = [[BDPMSFileManager sharedInstance] rootPath];
    
    NSLog(@"NSHomeDirectory = %@",NSHomeDirectory());
    
    NSMutableDictionary *flutterParams = [NSMutableDictionary new];
    
    [flutterParams setValue:[params btd_stringValueForKey:@"customer_id"] forKey:@"customer_id"];
    [flutterParams setValue:[params btd_stringValueForKey:@"lead_id"] forKey:@"lead_id"];
    [flutterParams setValue:[params btd_stringValueForKey:@"associate_id"] forKey:@"associate_id"];
    [flutterParams setValue:[params btd_stringValueForKey:@"assignment_id"] forKey:@"assignment_id"];
    [flutterParams setValue:[params btd_stringValueForKey:@"pool_item_id"] forKey:@"pool_item_id"];

    
    NSDictionary *reportPrarams = [params btd_dictionaryValueForKey:@"report_params"];
    if ([reportPrarams isKindOfClass:[NSDictionary class]]) {
       [flutterParams setValue:[[reportPrarams btd_jsonStringEncoded] btd_stringByURLEncode] forKey:@"report_params"];
//        [flutterParams setValue:reportPrarams forKey:@"report_params"];
    }
    
//    [flutterParams setValue:[params btd_stringValueForKey:@"customer_id" forKey:@"customer_id"]];

    
    NSString *routeStr = @"/customer_detail";

    NSMutableString *schemaStr =[NSMutableString stringWithString:@"sslocal://flutter?plugin_name=CustomerDetail&view_token=CustomerDetail&has_aot=1"];
    
    if (routeStr) {
        [schemaStr appendFormat:@"&route=%@",[routeStr btd_stringByURLEncode]];
    }
    
    if (params) {
        [schemaStr appendFormat:@"&params=%@",[[flutterParams btd_jsonStringEncoded] btd_stringByURLEncode]];
    }
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:nil];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:schemaStr] userInfo:userInfo];
        
}

+ (void)loadLocalPackage:(UIViewController *)vc {
    NSString *localPcakgePath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"dynamic.zip"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:localPcakgePath]) {
        [FHFlutterManager alertWithMessage:@"没有预置包"];
        return;
    }
    
    RouteAppPackagePackageInfo *packageInfo = [[RouteAppPackagePackageInfo alloc] init];
    packageInfo.name = @"dynamicz";
    packageInfo.zipPackagePath = localPcakgePath;
    NSString *url = @"local-flutter://dynamic/";
    
    FlutterViewWrapperController *flutterWrapperVC = [[FlutterViewWrapperController alloc] initWithRouteParams:@{@"url":url, @"packageInfo": packageInfo}];
    [vc.navigationController pushViewController:flutterWrapperVC animated:YES];

}

+ (void)alertWithMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

+ (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kFHSettingsKey]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kFHSettingsKey];
    } else {
        return nil;
    }
}

+(BOOL)isCanJumpFlutterForCustomerDetail{
    NSDictionary *f_flutter_config = [[TTSettingsManager sharedManager] settingForKey:@"f_flutter_config" defaultValue:@{} freeze:NO];
    BOOL isFlutterEnable = [f_flutter_config btd_boolValueForKey:@"is_flutter_enable" default:YES];
    BOOL isFlutterEnableCustomerDetail = [f_flutter_config btd_boolValueForKey:@"is_enable_customer_detail" default:YES];
    return isFlutterEnable && isFlutterEnableCustomerDetail;
}

+(BOOL)isCanFlutterDynamicart{
    NSDictionary *f_flutter_config = [[TTSettingsManager sharedManager] settingForKey:@"f_flutter_config" defaultValue:@{} freeze:NO];
    BOOL isFlutterEnable = [f_flutter_config btd_boolValueForKey:@"is_flutter_enable" default:YES];
    BOOL isCanFlutterDynamicart = [f_flutter_config btd_boolValueForKey:@"is_enable_dynamicart" default:YES];
    return isCanFlutterDynamicart && isFlutterEnable;
}

+(BOOL)isCanFlutterPreload{
    NSDictionary *f_flutter_config = [[TTSettingsManager sharedManager] settingForKey:@"f_flutter_config" defaultValue:@{} freeze:NO];
    BOOL isFlutterEnable = [f_flutter_config btd_boolValueForKey:@"is_flutter_enable" default:YES];
    BOOL isCanFlutterPreload = [f_flutter_config btd_boolValueForKey:@"is_pre_create_flutter" default:NO];
    return isCanFlutterPreload && isFlutterEnable;
}


+(BOOL)checkPackageIsAvailad{
   NSArray *validPackages = [[BDFlutterPackageManager sharedInstance] allValidPackages];
    
    
    return YES;
}

@end
