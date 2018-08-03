//
//  TTShareApiConfig.m
//  Pods
//
//  Created by 延晋 张 on 16/6/6.
//
//

#import "TTShareApiConfig.h"
#import "TTQQShare.h"
#import "TTWeChatShare.h"
//#import "TTAliShare.h"
//#import "TTWeiboShare.h"
//#import "TTDingTalkShare.h"

@implementation TTShareApiConfig

+ (void)shareRegisterQQApp:(NSString *)appid
{
    [TTQQShare registerWithID:appid];
}

+ (void)shareRegisterWXApp:(NSString *)appid
{
    [TTWeChatShare registerWithID:appid];
}
//
//+ (void)shareRegisterZhiFuBaoApp:(NSString *)appid
//{
//    [TTAliShare registerWithID:appid];
//}
//
//+ (void)shareRegisterWeiboApp:(NSString *)appid
//{
//    [TTWeiboShare registerWithKey:appid];
//}
//
//+ (void)shareRegisterDingTalk:(NSString *)appid
//{
//    [TTDingTalkShare registerWithID:appid];
//}

@end
