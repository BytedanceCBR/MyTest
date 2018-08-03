//
//  WeixinUserAccount.m
//  Article
//
//  Created by Yu Tianhang on 12-11-7.
//
//

#import "WeixinUserAccount.h"



@implementation WeixinUserAccount

+ (NSString *)platformName
{
    return TTA_NONNULL_PLATFORM_NAME(TTAccountAuthTypeWeChat);
}

+ (NSString *)platformDisplayName
{
    return NSLocalizedString(@"微信", nil);
}

- (NSString *)keyName
{
    return TTA_NONNULL_PLATFORM_NAME(TTAccountAuthTypeWeChat);
}

- (NSString *)displayName
{
    return NSLocalizedString(@"微信", nil);
}

- (NSString *)iconImageName
{
    return @"weixinicon_setup";
}

@end
