//
//  TTVVideoURLSettingUtility.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVVideoURLSettingUtility.h"
#import "TTURLDomainHelper.h"

@implementation TTVVideoURLSettingUtility

+ (NSString *)baseURL
{
    return [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
//    return [CommonURLSetting baseURL];
}

+ (NSString *)leTVPlayApi {
    return @"http://api.letvcloud.com/getplayurl.php";
}

+ (NSString *)toutiaoPlayApi {
    NSString *baseURL = [self baseURL];
    NSString *url = [NSString stringWithFormat:@"%@/video/play/%@", baseURL, [self toutiaoPlayApiVersion]];
    url = [self mappedUrl:url];
    return url;
}

+ (NSString *)toutiaoPlayApiVersion {
    return @"1";
}

+ (NSString *)mappedUrl:(NSString *)finalUrl {
    NSArray *mapping = [self urlMapping];
    bool isMapped = NO;
    NSString *mappedOrigin = nil;
    NSString *mappedTarget = nil;
    for (NSDictionary *dic in mapping) {
        NSString *origin = [dic valueForKey:@"origin"];//i.sub
        NSString *target = [dic valueForKey:@"target"];//i.365
        NSString *trimHTTP = [finalUrl lowercaseString];
        
        if ([trimHTTP rangeOfString:@"https://"].location != NSNotFound) {
            trimHTTP = [trimHTTP stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        }
        if ([trimHTTP rangeOfString:@"http://"].location != NSNotFound) {
            trimHTTP = [trimHTTP stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        }
        if ([trimHTTP rangeOfString:origin].location != NSNotFound) {
            isMapped = YES;
            mappedOrigin = origin;
            mappedTarget = target;
            break;
        }
    }
    if (isMapped) {
        return [finalUrl stringByReplacingOccurrencesOfString:mappedOrigin withString:mappedTarget];
    }
    return finalUrl;
}

+ (NSArray *)urlMapping {
    NSArray *mapping = [[NSUserDefaults standardUserDefaults] valueForKey:@"kBaseURLMappingUserDefaultKey"];
    if ([mapping isKindOfClass:[NSArray class]] && mapping.count > 0) {
        return mapping;
    }
    return nil;
}

@end
