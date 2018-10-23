//
//  TTStartupSDKsGroup.m
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTStartupSDKsGroup.h"
#import "SSCommonLogic.h"
#import "TTWeixinSDKRegister.h"
//#import "TTDingTalkSDKRegister.h"
#import "TTShareModuleBridgeTask.h"
#import "TTUmengSDKRegister.h"
//#import "TTHuoshanSDKRegister.h"
//#import "TTAliPaySDKRegister.h"
#import "TTQQSDKRegister.h"
//#import "TTBDOAuthSDKRegister.h"
//#import "TTFantasySDKRegister.h"

@implementation TTStartupSDKsGroup

- (BOOL)isConcurrent {
    return NO;
}

+ (TTStartupSDKsGroup *)SDKsRegisterGroup {
    TTStartupSDKsGroup *group = [[TTStartupSDKsGroup alloc] init];
    
    [group.tasks addObject:[[self class] SDKRegisterStartupForType:TTSDKsRegisterStartupTypeWeixin]];
//    [group.tasks addObject:[[self class] SDKRegisterStartupForType:TTSDKsRegisterStartupTypeDingTalk]];
    [group.tasks addObject:[[self class] SDKRegisterStartupForType:TTSDKsRegisterStartupTypeShareModuleBridge]];
    [group.tasks addObject:[[self class] SDKRegisterStartupForType:TTSDKsRegisterStartupTypeUmeng]];
    [group.tasks addObject:[[self class] SDKRegisterStartupForType:TTSDKsRegisterStartupTypeHuoshan]];
//    [group.tasks addObject:[[self class] SDKRegisterStartupForType:TTSDKsRegisterStartupTypeAliPay]];
    [group.tasks addObject:[[self class] SDKRegisterStartupForType:TTSDKsRegisterStartupTypeQQ]];
//    [group.tasks addObject:[[self class] SDKRegisterStartupForType:TTSDKsRegisterStartupTypeBDOAuth]];
//    [group.tasks addObject:[[self class] SDKRegisterStartupForType:TTSDKsRegisterStartupTypeFantasy]];

    return group;
}

+ (TTStartupTask *)SDKRegisterStartupForType:(TTSDKsRegisterStartupType)type {
    switch (type) {
        case TTSDKsRegisterStartupTypeWeixin:
            return [[TTWeixinSDKRegister alloc] init];
            break;
//        case TTSDKsRegisterStartupTypeDingTalk:
//            return [[TTDingTalkSDKRegister alloc] init];
//            break;
        case TTSDKsRegisterStartupTypeShareModuleBridge:
            return [[TTShareModuleBridgeTask alloc] init];
            break;
        case TTSDKsRegisterStartupTypeUmeng:
            return [[TTUmengSDKRegister alloc] init];
            break;
//        case TTSDKsRegisterStartupTypeHuoshan:
//            return [[TTHuoshanSDKRegister alloc] init];
//            break;
//        case TTSDKsRegisterStartupTypeAliPay:
//            return [[TTAliPaySDKRegister alloc] init];
//            break;
        case TTSDKsRegisterStartupTypeQQ:
            return [[TTQQSDKRegister alloc] init];
            break;
//        case TTSDKsRegisterStartupTypeBDOAuth:
//            return [[TTBDOAuthSDKRegister alloc] init];
//            break;
//        case TTSDKsRegisterStartupTypeFantasy:
//            return [[TTFantasySDKRegister alloc] init];
//            break;
        default:
            return [[TTStartupTask alloc] init];
            break;
    }
    
    return [[TTStartupTask alloc] init];
}

@end
