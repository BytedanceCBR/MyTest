//
//  MonitorHook.m
//  Article
//
//  Created by leo on 2019/4/10.
//

#import "MonitorHook.h"
#import "RSSwizzle.h"
#import "HeimdallrConfig.h"
#import "HMDUploadURLSetting.h"
@implementation MonitorHook

+(void)load {
    RSSwizzleClassMethod(HeimdallrConfig,
                         @selector(isNeedEncrypt),
                         RSSWReturnType(BOOL),
                         RSSWArguments(),
                         RSSWReplacement(
                                         {
                                             return NO;
                                         }));

    RSSwizzleClassMethod(HMDUploadURLSetting,
                         @selector(monitorCollectUploadURL),
                         RSSWReturnType(NSString*),
                         RSSWArguments(),
                         RSSWReplacement(
                                         {
                                             return @"http://10.1.11.42:8081/monitor/collect/";
//                                             return @"https://mon.haoduofangs.com/monitor/collect/";
                                         }));
}

@end
