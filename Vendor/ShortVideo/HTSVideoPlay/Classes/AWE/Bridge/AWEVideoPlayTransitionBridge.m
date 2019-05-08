//
//  AWEVideoPlayTransitionBridge.m
//  Pods
//
//  Created by lili.01 on 18/11/2016.
//
//

#import "AWEVideoPlayTransitionBridge.h"
#import "TTURLUtils.h"
#import "TSVShortVideoOriginalData.h"
#import "TTModuleBridge.h"
#import "TTDeviceHelper.h"
#import "TTThemedAlertController.h"
#import "TTUIResponderHelper.h"
#import "BTDMacros.h"
#import "TTRoute.h"
#import "AWEVideoConstants.h"
#import "TTNavigationController.h"
#import "TTStringHelper.h"
#import "TTSettingsManager.h"

@implementation AWEVideoPlayTransitionBridge

+ (void)openProfileViewWithUserId:(NSString *)userId params:(NSDictionary *)params
{
    [self openProfileViewWithUserId:userId params:params userInfo:nil];
}

+ (void)openProfileViewWithUserId:(NSString *)userId params:(NSDictionary *)params userInfo:(NSDictionary *)userInfo
{
    [self openProfileViewWithUserId:userId params:params userInfo:userInfo pushWithTransitioningAnimationEnable:YES];
}

+ (void)openProfileViewWithUserId:(NSString *)userId params:(NSDictionary *)params userInfo:(NSDictionary *)userInfo pushWithTransitioningAnimationEnable:(BOOL)pushWithTransitioningAnimationEnable
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    [dict setValue:userId forKey:@"uid"];
    [dict setValue:@"ies_video" forKey:@"refer"];
    
    // add by zjing 去掉个人主页跳转
    return;
    
    NSString *scheme = @"sslocal://profile";
    NSURL *url = [TTURLUtils URLWithString:scheme queryItems:dict];
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        if (pushWithTransitioningAnimationEnable) {
            //自定义push方式打开火山详情页
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(userInfo) pushHandler:^(UINavigationController *nav, TTRouteObject *routeObj) {
                if ([nav isKindOfClass:[TTNavigationController class]] &&
                    [routeObj.instance isKindOfClass:[UIViewController class]]) {
                    [(TTNavigationController *)nav pushViewControllerByTransitioningAnimation:((UIViewController *)routeObj.instance) animated:YES];
                }
            }];
        } else {
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(userInfo)];
        }
    }
}

+ (BOOL)canOpenAweme
{
    return [AWEVideoPlayTransitionBridge canOpenAwemeWithUrlString:nil];
}

+ (BOOL)canOpenHotsoon
{
    return [AWEVideoPlayTransitionBridge canOpenHotSoonWithUrlString:nil];
}

+ (BOOL)canOpenAwemeWithUrlString:(NSString *)urlString
{
    if (![urlString isKindOfClass:[NSString class]] || BTD_isEmptyString(urlString)) {
        urlString = AwemeSchemaPrefix;
    }
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]];
}

+ (BOOL)canOpenHotSoonWithUrlString:(NSString *)urlString
{
    if (![urlString isKindOfClass:[NSString class]] || BTD_isEmptyString(urlString)) {
        urlString = HotSoonSchemaPrefix;
    }
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]];
}

+ (void)openAweme
{
    NSDictionary *queryParams = @{@"gd_label": @"click_schema_douyin2toutiao"};
    NSURL *url = [TTURLUtils URLWithString:[NSString stringWithFormat:@"%@feed",AwemeSchemaPrefix] queryItems:queryParams];
    [[UIApplication sharedApplication] openURL:url];
}

+ (void)openHotSoon
{
    NSDictionary *queryParams = @{@"gd_label": @"click_schema_huoshan2toutiao"};
    NSURL *url = [TTURLUtils URLWithString:[NSString stringWithFormat:@"%@main",HotSoonSchemaPrefix] queryItems:queryParams];
    [[UIApplication sharedApplication] openURL:url];
}

+ (BOOL)canOpenAppWithGroupSource:(NSString *)groupSource;
{
    if ([groupSource isEqualToString:AwemeGroupSource]) {
        return [self canOpenAweme];
    } else if ([groupSource isEqualToString:HotsoonGroupSource]) {
        return [self canOpenHotsoon];
    }
    return NO;
}

+ (void)openAppWithGroupSource:(NSString *)groupSource
{
    if ([groupSource isEqualToString:AwemeGroupSource]) {
        return [self openAweme];
    } else if ([groupSource isEqualToString:HotsoonGroupSource]) {
        return [self openHotSoon];
    }
}

+ (void)openDownloadViewWithConfigDict:(NSDictionary *)configDict
                         confirmBlock:(void(^)())confirmBlock
                          cancelBlock:(void(^)())cancelBlock
{
    TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:configDict[@"dialog_title"]?:@"下载应用，发现更多有趣内容"
                                                                                      message:nil
                                                                                preferredType:TTThemedAlertControllerTypeAlert];
    [alertController addActionWithTitle:configDict[@"cancel_text"]?:@"取消"
                             actionType:TTThemedAlertActionTypeCancel
                            actionBlock:^{
                                cancelBlock();
                            }];
    [alertController addActionWithTitle:configDict[@"positive_text"]?:@"去下载"
                             actionType:TTThemedAlertActionTypeNormal
                            actionBlock:^{
                                confirmBlock();
                                [[TTModuleBridge sharedInstance_tt] triggerAction:@"TSVDownloadAPP" object:nil withParams:configDict complete:nil];
                            }];
    [alertController showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
}

+ (NSDictionary *)getConfigDictWithGroupSource:(NSString *)groupSource
{
    NSArray *topIconConfigDefaultValue = @[
                                           @{@"group_source": @"16",
                                             @"dialog_title": @"",
                                             @"dialog_content" : @"您当前正在使用移动网络，下载将消耗流量",
                                             @"positive_text": @"",
                                             @"cancel_text": @"取消",
                                             @"should_display":@0,
                                             @"handle_click":@0,
                                             @"new_icon_url":@"http://p3.pstatp.com/origin/50ec00054da6a3895544.webp",
                                             @"old_icon_url":@"http://p3.pstatp.com/origin/55190001c5d31a8512b8.webp",
                                             @"app_appleid":@"1086047750",
                                             @"download_track_url":@"http://d.huoshanzhibo.com/UsSo/"
                                             },
                                           @{@"group_source": @"19",
                                             @"dialog_title": @"",
                                             @"dialog_content": @"您当前正在使用移动网络，下载将消耗流量",
                                             @"positive_text": @"",
                                             @"cancel_text": @"取消",
                                             @"should_display":@0,
                                             @"handle_click":@0,
                                             @"new_icon_url":@"http://p3.pstatp.com/origin/50ed00054c88526e181c.webp",
                                             @"old_icon_url":@"http://p3.pstatp.com/origin/50ec000547d1d00d57c8.webp",
                                             @"app_appleid":@"1142110895",
                                             @"download_track_url":@"https://d.douyin.com/Stvr/"
                                             },
                                           @{@"group_source": @"21",
                                             @"should_display":@0,
                                             },
                                           ];
    
    NSArray *content = [[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_detail_top_icon_config" defaultValue:topIconConfigDefaultValue freeze:YES];
    if (content && [content isKindOfClass:[NSArray class]]) {
        NSArray *result = (NSArray *)content;
        for (NSDictionary *dictionary in result) {
            NSString *currentGroupSource = [NSString stringWithFormat:@"%@", dictionary[@"group_source"]];
            if ([currentGroupSource isEqualToString:groupSource]) {
                return dictionary;
            }
        }
    }
    return [NSDictionary new];
}

@end
