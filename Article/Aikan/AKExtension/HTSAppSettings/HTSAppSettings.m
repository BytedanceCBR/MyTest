//
//  HTSAppSettings.m
//  LiveStreaming
//
//  Created by Quan Quan on 16/11/6.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "HTSAppSettings.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TTNetworkManager.h>
#import "HTSAppSettingsModel.h"
#import "HTSNetworkDefaultIMP.h"
#import "HTSBaseHTTPRequestSerializer.h"
#import "HTSBaseJSONResponseSerializer.h"

static HTSAppSettingsModel *appSettingsModel;
static NSString * const HTSAppSettingsPersistKey = @"HTSAppSettingsPersistKey";

static NSString * const BASE_URL_PRODUCTION = @"https://hotsoon.snssdk.com/hotsoon";
static NSString * const BASE_URL_SANDBOX    = @"https://hotsoon.snssdk.com/sandbox";


@implementation HTSAppSettings

+ (void)load
{
    @autoreleasepool {
        __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                                                object:nil
                                                                                 queue:[NSOperationQueue mainQueue]
                                                                            usingBlock:^(NSNotification * _Nonnull note) {
                                                                                [self fetchAppSetting];
                                                                                [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                                observer = nil;
                                                                            }];
    }
}

+ (void)fetchAppSetting
{
    return;
    
    HTSNetworkServiceMode mode = [HTSNetworkDefaultIMP networkMode];
    NSString *urlString = @"/settings/";
    if (mode == HTSNetworkServiceModeSandBox) {
        urlString = [NSString stringWithFormat:@"%@%@", BASE_URL_SANDBOX, urlString];
    } else {
        urlString = [NSString stringWithFormat:@"%@%@", BASE_URL_PRODUCTION, urlString];
    }
    
    Class <MTLModel> modelClass = [HTSAppSettingsModel class];
    void (^completion)(NSError *, id<MTLModel>) = ^(NSError *error, HTSAppSettingsModel *model) {
        if (error || !model) {
            return;
        }
        [self persist:model];
    };
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlString
                                                     params:({
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        result[@"live_sdk_version"] = @"2.4.0";
        [result copy];
    })
                                                     method:@"POST"
                                           needCommonParams:YES
                                          requestSerializer:[HTSBaseHTTPRequestSerializer class]
                                         responseSerializer:[HTSBaseJSONResponseSerializer class]
                                                 autoResume:YES
                                                   callback:^(NSError *error, id jsonObj) {
                                                       if (!modelClass) {
                                                           !completion ? : completion(error, jsonObj);
                                                           return;
                                                       }
                                                       
                                                       if (error) {
                                                           !completion ? : completion(error, nil);
                                                           return;
                                                       }
                                                       
                                                       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                           NSError *mappingError = nil;
                                                           MTLModel *model = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:jsonObj error:&mappingError];
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               !completion ? : completion(mappingError, model);
                                                           });
                                                       });
                                                   }];
}

+ (void)persist:(HTSAppSettingsModel *)model
{
    if (!model) {
        return;
    }
    
    appSettingsModel = model;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:HTSAppSettingsPersistKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (HTSAppSettingsModel *)modelForApp
{
    if (!appSettingsModel) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:HTSAppSettingsPersistKey];
        appSettingsModel = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    }
    return appSettingsModel;
}

@end
