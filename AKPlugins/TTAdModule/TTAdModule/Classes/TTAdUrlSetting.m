//
//  TTAdUrlSetting.m
//  Article
//
//  Created by yin on 2017/7/12.
//
//

#import "TTAdUrlSetting.h"
#import "TTURLDomainHelper.h"

@implementation TTAdUrlSetting
//分享版广告
+ (NSString*)shareAdURLString
{
    return [NSString stringWithFormat:@"%@/api/ad/share/v1/", [self baseURL]];
}

+ (NSString *)baseURL
{
    return [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
}

@end
