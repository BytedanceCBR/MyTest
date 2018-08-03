//
//  TouTiaoPushSDK.m
//  TouTiaoPushSDKDemo
//
//  Created by wangdi on 2017/7/30.
//  Copyright © 2017年 wangdi. All rights reserved.
//

#import "TouTiaoPushSDK.h"
#import <TTNetworkManager.h>
#import <TTURLDomainHelper.h>

@implementation TTBaseRequestParam

+ (instancetype)requestParam
{
    TTBaseRequestParam *requestParam = [[self alloc] init];
    return requestParam;
}

@end

@implementation TTChannelRequestParam

@end

@implementation TTUploadTokenRequestParam

@end

@implementation TTUploadSwitchRequestParam

@end

@implementation TTBaseResponse

@end

@implementation TouTiaoPushSDK

+ (void)sendRequestWithParam:(TTBaseRequestParam *)requestParam completionHandler:(void (^)(TTBaseResponse *))completionHandler
{
    NSString *url = [self _requestUrlWithRequest:requestParam];
    NSDictionary *param = [self _requestParamWithRequest:requestParam];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:param method:@"GET" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
        TTBaseResponse *response = [[TTBaseResponse alloc] init];
        response.jsonObj = jsonObj;
        response.error = error;
        if(completionHandler) {
            completionHandler(response);
        }
    }];
}

+ (NSString *)_requestUrlWithRequest:(TTBaseRequestParam *)request
{
    if([request isKindOfClass:[TTChannelRequestParam class]]) {
        return [self _getChannelUrlWithRequest:(TTChannelRequestParam *)request];
    } else if([request isKindOfClass:[TTUploadTokenRequestParam class]]) {
        return [self _getUploadTokenUrlWithRequest:(TTUploadTokenRequestParam *)request];
    } else if([request isKindOfClass:[TTUploadSwitchRequestParam class]]) {
        return [self _getUploadSwitchUrlWithRequest:(TTUploadSwitchRequestParam *)request];
    }
    return nil;
}

+ (NSDictionary *)_requestParamWithRequest:(TTBaseRequestParam *)request
{
    if([request isKindOfClass:[TTChannelRequestParam class]]) {
        return [self _getChannelParamWithRequest:(TTChannelRequestParam *)request];
    } else if([request isKindOfClass:[TTUploadTokenRequestParam class]]) {
        return [self _getUploadTokenParamWithRequest:(TTUploadTokenRequestParam *)request];
    } else if([request isKindOfClass:[TTUploadSwitchRequestParam class]]) {
        return [self _getUploadSwitchParamWithRequest:(TTUploadSwitchRequestParam *)request];
    }
    return nil;
}

+ (NSMutableDictionary<NSString *,NSString *> *)_getCommonParamDictWithRequest:(TTBaseRequestParam *)request
{
    NSMutableDictionary<NSString *,NSString *> *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:request.aId forKey:@"aid"];
    [paramDict setValue:request.deviceId forKey:@"device_id"];
    [paramDict setValue:request.appName forKey:@"app_name"];
    [paramDict setValue:request.installId forKey:@"install_id"];
    return paramDict;
}

+ (NSString *)_getSystemPushStatus
{
    NSString *systemPushStatus = nil;
    if([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        systemPushStatus = [[UIApplication sharedApplication] currentUserNotificationSettings].types == 0 ? @"0" : @"1";
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        systemPushStatus = [[UIApplication sharedApplication] enabledRemoteNotificationTypes] == 0 ? @"0" : @"1";
#pragma clang diagnostic pop
    }
    return systemPushStatus;
}

+ (NSString *)_getChannelUrlWithRequest:(TTChannelRequestParam *)request
{
    NSString *domain = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
    NSString *urlStr = [NSString stringWithFormat:@"%@/cloudpush/update_sender/",domain];
    return urlStr;
}

+ (NSString *)_getUploadTokenUrlWithRequest:(TTUploadTokenRequestParam *)request
{
    NSString *domain = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
    NSString *urlStr = [NSString stringWithFormat:@"%@/service/1/update_token/",domain];
    return urlStr;
}

+ (NSString *)_getUploadSwitchUrlWithRequest:(TTUploadSwitchRequestParam *)request
{
    NSString *domain = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
    NSString *urlStr = [NSString stringWithFormat:@"%@/service/1/app_notice_status/",domain];
    return urlStr;
}

+ (NSDictionary *)_getChannelParamWithRequest:(TTChannelRequestParam *)request
{
    NSMutableDictionary<NSString *,NSString *> *paramDict = [self _getCommonParamDictWithRequest:request];
    [paramDict setValue:request.channel forKey:@"channel"];
    [paramDict setValue:request.pushSDK forKey:@"push_sdk"];
    [paramDict setValue:request.versionCode forKey:@"version_code"];
    [paramDict setValue:request.osVersion forKey:@"os_version"];
    [paramDict setValue:request.package forKey:@"package"];
    [paramDict setValue:@"iOS" forKey:@"os"];
    [paramDict setValue:request.notice forKey:@"notice"];
    [paramDict setValue:[self _getSystemPushStatus] forKey:@"system_notify_status"];
    return paramDict;
}

+ (NSDictionary *)_getUploadTokenParamWithRequest:(TTUploadTokenRequestParam *)request
{
    NSMutableDictionary<NSString *,NSString *> *paramDict = [self _getCommonParamDictWithRequest:request];
    [paramDict setValue:request.token forKey:@"token"];
    return paramDict;
}

+ (NSDictionary *)_getUploadSwitchParamWithRequest:(TTUploadSwitchRequestParam *)request
{
    NSMutableDictionary<NSString *,NSString *> *paramDict = [self _getCommonParamDictWithRequest:request];
    [paramDict setValue:request.notice forKey:@"notice"];
    [paramDict setValue:[self _getSystemPushStatus] forKey:@"system_notify_status"];
    return paramDict;
}

@end
