//
//  TTRFlowStatistics.m
//  Article
//
//  Created by wangdi on 2017/7/3.
//
//

#import "TTRFlowStatistics.h"
#import "TTFlowStatisticsManager.h"

@implementation TTRFlowStatistics

- (void)flowStatisticsWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller
{
    [[TTFlowStatisticsManager sharedInstance] setFlowData:param];
    TTR_CALLBACK_SUCCESS
}

@end
