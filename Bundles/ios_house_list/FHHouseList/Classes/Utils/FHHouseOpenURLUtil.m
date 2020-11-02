//
//  FHHouseOpenURLUtil.m
//  FHHouseList
//
//  Created by 春晖 on 2019/8/23.
//

#import "FHHouseOpenURLUtil.h"
#import "FHCommuteManager.h"
#import "TTRoute.h"
#import "NSString+BTDAdditions.h"
#import "NSURL+BTDAdditions.h"
#import "NSDictionary+BTDAdditions.h"

@implementation FHHouseOpenURLUtil

+(BOOL)isSameURL:(NSString *)url1 and:(NSString *)url2
{
    if (url1 == url2) {
        return YES;
    }
    
    if ([url1 isEqualToString:url2]) {
        return YES;
    }
    
    NSDictionary *dict1 = [self queryDict:url1];
    NSDictionary *dict2 = [self queryDict:url2];
    
    if ([dict1 isEqualToDictionary:dict2]) {
        return YES;
    }
    
    
    return NO;
}

+(NSDictionary *)queryDict:(NSString *)url
{
    NSURLComponents *componets = [NSURLComponents componentsWithString:url];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for (NSURLQueryItem *item in componets.queryItems) {
        dict[item.name] = item.value;
    }
    
    return dict;
    
}

+ (void)openUrl:(NSString *)openUrl logParams:(NSDictionary *)logParams {
    if (!openUrl || !openUrl.length || ![openUrl isKindOfClass:[NSString class]]) return;
    NSURL *url = [NSURL URLWithString:openUrl];
    NSString *host = url.host;
    if ([host isEqualToString:@"webview"]) {
        NSDictionary *params = [openUrl btd_queryParamDict];
        NSString *urlValue = [params btd_stringValueForKey:@"url"];
        if (urlValue) {
            NSString *finalUrlValue = [[[urlValue btd_stringByURLDecode] btd_urlStringByAddingParameters:logParams] btd_stringByURLEncode];
            if (finalUrlValue) {
                openUrl = [openUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"url=%@", urlValue] withString:[NSString stringWithFormat:@"url=%@", finalUrlValue]];
                url = [NSURL URLWithString:openUrl];
            }
        }
    }
    
    if ([openUrl containsString:@"://commute_list"]){
        //通勤找房
        [[FHCommuteManager sharedInstance] tryEnterCommutePage:openUrl logParam:logParams];
    } else {
        NSDictionary *userInfoDict = @{@"tracer":logParams};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

@end
