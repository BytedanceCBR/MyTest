//
//  TSVCommonURLSetting.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/12/3.
//

#import "TSVCommonURLSetting.h"
#import "TTURLDomainHelper.h"

@implementation TSVCommonURLSetting

+ (NSString *)baseURL
{
    return [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
}

@end
