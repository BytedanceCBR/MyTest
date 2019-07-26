//
//  NewsBaseDelegate+Zlink.m
//  TTAppRuntime
//
//  Created by wangzhizhou on 2019/7/17.
//

#import "NewsBaseDelegate+Zlink.h"
#import "BDUGDeepLinkManager.h"
#import <TTRoute/TTRoute.h>
#import "TTAdSplashMediator.h"
#import "FHUtils.h"
#import "FHEnvContext.h"

@implementation NewsBaseDelegate(Zlink)
-(void)deepLinkOnSchema:(NSString *)schema type:(BDUGDeepLinkType)type {
    // 关闭开屏广告
    [TTAdSplashMediator shareInstance].splashADShowType = TTAdSplashShowTypeHide;
    // 字符串若包含中文，会导致字符串转URL失败，需要进行编码转码
    NSString *schemaString = [schema stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (schemaString.length > 0) {
        BOOL hasSelectedCity = [(id)[FHUtils contentForKey:kUserHasSelectedCityKey] boolValue];
        if (!hasSelectedCity) {
            // no select city
            [[NSUserDefaults standardUserDefaults] setValue:schemaString forKey:@"kFHDeepLinkFirstLaunchKey"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            NSURL *url = [NSURL URLWithString:schemaString];
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
    }

}
@end