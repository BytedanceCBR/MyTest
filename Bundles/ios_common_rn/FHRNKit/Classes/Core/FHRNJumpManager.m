//
//  FHRNJumpManager.m
//  AKShareServicePlugin
//
//  Created by 谢飞 on 2019/7/8.
//

#import "FHRNJumpManager.h"
#import "TTRoute.h"
#import "FHUtils.h"
#import <TTRNKit.h>
#import "FHRNHelper.h"

@implementation FHRNJumpManager

+ (void)jumpToClueDetail:(NSDictionary *)params
{
    NSString *openUrlRnStr = [NSString stringWithFormat:@"sslocal://%@?module_name=FHBClueDetailModule_home&can_multi_preload=0&channelName=f_b_clue_detail&debug=0&bundle_name=f_b_clue_detail.bundle",RNReact];
    
    NSMutableDictionary *info = @{}.mutableCopy;
    info[@"title"] = [@"客户详情" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    info[@"delegate"] = self;
    if (params) {
        params = [self processDictionaryToJsonStr:params];
        [info addEntriesFromDictionary:params];
    }
    
    for (NSString * valueKey in info.allKeys) {
        openUrlRnStr = [openUrlRnStr stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",valueKey,info[valueKey]]];
    }
    
    NSURL *openUrlRn = [NSURL URLWithString:openUrlRnStr];

    [[TTRoute sharedRoute] openURLByViewController:openUrlRn userInfo:nil];
}

+ (NSDictionary *)processDictionaryToJsonStr:(NSDictionary *)originDict
{
    NSMutableDictionary *reasultDict = nil;
    if ([originDict isKindOfClass:[NSDictionary class]]) {
        reasultDict = [[NSMutableDictionary alloc] initWithDictionary:originDict];
        for (NSString *key in originDict.allKeys) {
            if ([originDict[key] isKindOfClass:[NSDictionary class]]) {
                [reasultDict setValue:[FHUtils getJsonStrFrom:originDict[key]] forKey:key];
            }
        }
    }
    return reasultDict;
}

+ (BOOL)isClueDetailCanUseRN
{
    if([[FHRNHelper fhRNEnableChannels] containsObject:@"f_b_clue_detail"])
    {
        return YES;
    }else
    {
        return NO;
    }
}

@end
