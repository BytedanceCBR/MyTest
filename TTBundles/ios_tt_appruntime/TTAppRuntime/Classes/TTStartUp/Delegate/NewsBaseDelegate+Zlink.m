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

@implementation NewsBaseDelegate(Zlink)
-(void)deepLinkOnSchema:(NSString *)schema type:(BDUGDeepLinkType)type {
    // 关闭开屏广告
    [TTAdSplashMediator shareInstance].splashADShowType = TTAdSplashShowTypeHide;
    // 字符串若包含中文，会导致字符串转URL失败，需要进行编码转码
    NSString *schemaString = [schema stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:schemaString];
    [[TTRoute sharedRoute] openURLByPushViewController:url];

}
@end
