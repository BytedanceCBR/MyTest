//
//  TTStartupSDKsGroup.h
//  Article
//
//  Created by fengyadong on 17/1/16.
//
//

#import "TTStartupGroup.h"
#import "TTStartupTask.h"

typedef NS_ENUM(NSUInteger, TTSDKsRegisterStartupType) {
    TTSDKsRegisterStartupTypeWeixin = 0,        //微信
    TTSDKsRegisterStartupTypeDingTalk,          //钉钉
    TTSDKsRegisterStartupTypeShareModuleBridge, //插件分享Bridge
    TTSDKsRegisterStartupTypeUmeng,             //友盟SDK
    TTSDKsRegisterStartupTypeFabric,            //Fabric
    TTSDKsRegisterStartupTypeHuoshan,           //火山直播
    TTSDKsRegisterStartupTypeAliPay,            //支付宝SDK
    TTSDKsRegisterStartupTypeQQ,                //QQ分享
    TTSDKsRegisterStartupTypeBDOAuth,           //Bytedance OAuth Open and PlatformSDK
    TTSDKsRegisterStartupTypeFantasy,           //Fantasy
};

@interface TTStartupSDKsGroup : TTStartupGroup

+ (TTStartupSDKsGroup *)SDKsRegisterGroup;

@end
