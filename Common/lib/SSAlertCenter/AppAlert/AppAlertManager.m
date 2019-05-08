//
//  AppAlert.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-7.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "AppAlertManager.h"
#import "AppAlertModel.h"
#import "NetworkUtilities.h"
#import "SSAppStore.h"
#import "TTRoute.h"
#import "TTInstallIDManager.h"
#import "CommonURLSetting.h"
#import <TTImage/TTWebImageManager.h>
#import "SSAlertCenter.h"
#import "TTNetworkHelper.h"
#import "TTSandBoxHelper.h"
#import "TTNetworkManager.h"

#import "TTSingleResponseModel.h"

@interface AppAlertManager ()
@property (nonatomic, strong) NSDictionary *localResult;
@property (nonatomic, weak) UIViewController *topViewController;
@property (nonatomic, strong) TTWebImageManager *imageManager;
@end

@implementation AppAlertManager

- (void)dealloc
{
    [_imageManager cancelAll];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.imageManager = [[TTWebImageManager alloc] initWithShareDownloader:NO];
        
        
        __weak typeof(self) wSelf = self;
        
        self.shouldAlertBlock = ^(id context) {
            AppAlertModel *alertModel = context;
            BOOL ret = YES;
            
            if (!TTNetworkConnected())
            {
                ret = NO;
            }
            else
            {
                if(!isEmptyString(alertModel.imageURLString) && [TTWebImageManager imageForURLString:alertModel.imageURLString] == nil)
                {
                    ret = NO;
                    [wSelf.imageManager downloadImageWithURL:alertModel.imageURLString options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
                        if(image)
                        {
                            // to avoid invoke cycle
                            double delayInSeconds = 1.0;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [[SSAlertCenter defaultCenter] refresh];
                            });
                        }
                    }];
                }
                else
                {
                    switch ([alertModel.mobileAlert intValue])
                    {
                        case MobileAlertTypeAll:
                            ret = YES;
                            break;
                        case MobileAlertTypeNotChinaMobileInNotWifi:
                            if ([[TTNetworkHelper carrierMCC] isEqualToString:@"460"]
                                && ([[TTNetworkHelper carrierMNC] isEqualToString:@"00"]
                                    || [[TTNetworkHelper carrierMNC] isEqualToString:@"02"]
                                    || [[TTNetworkHelper carrierMNC] isEqualToString:@"07"])
                                && !TTNetworkWifiConnected())
                            {
                                ret = NO;
                            }
                            else
                            {
                                ret = YES;
                            }
                            break;
                        default:
                            break;
                    }
                }
            }
            
            return ret;
        };
    }
    return self;
}

#pragma mark - public

- (void)startAlertWithLocalResult:(NSDictionary *)result;
{
    self.topViewController = nil;
    self.localResult = result;
    [self startAlertAfterDelay:0 concurrency:NO];
}

- (void)startAlertWithTopViewController:(UIViewController *)topViewController
{
    self.topViewController = topViewController;
    [self startAlert];
}

#pragma mark - extend methods

static AppAlertManager *_alertManager = nil;
+ (id)alertManager
{
    @synchronized(self) {
        if (_alertManager == nil) {
            _alertManager = [[self alloc] init];
        }
       
        
        return _alertManager;
    }
}

- (NSString *)urlPrefix
{
//#warning debug code ?test=1
//    return [NSString stringWithFormat:@"%@?test=1", [CommonURLSetting appAlertURLString]];
    return [CommonURLSetting appAlertURLString];
}

- (NSDictionary *)parameterDict
{
    NSString *carrierName = [TTNetworkHelper carrierName];
    
    NSMutableDictionary *tDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"zh-Hans", @"lang",
                                  [TTNetworkHelper connectMethodName], @"access",
                                  carrierName ? carrierName : @"", @"carrier",
                                  [NSString stringWithFormat:@"%@%@", [TTNetworkHelper carrierMCC], [TTNetworkHelper carrierMNC]], @"mcc_mnc", nil];
    [tDict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    return [tDict copy];
}

- (NSArray *)handleAlert:(NSDictionary *)result
{
    if (self.isConcurrency) {
        NSArray *dataList = [result objectForKey:@"datalist"];
        NSMutableArray *alertModels = [[NSMutableArray alloc] initWithCapacity:[dataList count]];
        
        for (int i=0; i < [dataList count]; i++) {
            
            NSDictionary *alertDict = [dataList objectAtIndex:i];
            NSError *error;
            AppAlertModel *appAlertModel = [[AppAlertModel alloc] initWithDictionary:alertDict error:&error];
            if (!appAlertModel){
                continue;
            }
            NSMutableString *buttons = [[NSMutableString alloc] init];
            NSMutableString *actions = [[NSMutableString alloc] init];
            NSMutableString *appleIDs = [[NSMutableString alloc] init];
            
            int counter = 0;
            NSArray *buttonList = [alertDict objectForKey:@"button_list"];
            for (NSDictionary *dict in buttonList) {
                
                [buttons appendString:[dict objectForKey:@"text"]];
                [actions appendString:[dict objectForKey:@"action_url"]];
                
                if ([dict.allKeys containsObject:@"appleid"]) {
                    [appleIDs appendString:[dict objectForKey:@"appleid"]];
                }
                else {
                    [appleIDs appendString:@""];
                }
                
                if (counter < [buttonList count] - 1) {
                    [buttons appendString:@","];
                    [actions appendString:@","];
                    [appleIDs appendString:@","];
                }
                counter ++;
            }
            
            appAlertModel.buttons = buttons;
            appAlertModel.actions = actions;
            appAlertModel.appleIDs = appleIDs;
            
//            [self.alertModels addObject:appAlertModel];
//            [appAlertModel release];
            
            [self tryDownloadImageForAlertModel:appAlertModel];
            if (appAlertModel) {
                [alertModels addObject:appAlertModel];
            }
        }
        return alertModels;
    }
    else {
        if (_localResult) {
            AppAlertModel *alertModel = [[AppAlertModel alloc] init];
            
            alertModel.title = nil;
            alertModel.message = [[_localResult objectForKey:@"aps"] objectForKey:@"alert"];
            alertModel.buttons = NSLocalizedString(@"确定,取消", nil);
            alertModel.actions = [_localResult objectForKey:@"action"];
            alertModel.rule_id = [_localResult objectForKey:@"rule_id"];
            alertModel.mobileAlert = [NSNumber numberWithInt:1];
            alertModel.delayTime = @0.f;
            
            [self tryDownloadImageForAlertModel:alertModel];
            self.localResult = nil;
            
            return [NSArray arrayWithObject:alertModel];
        }
        else {
            return nil;
        }
    }
}

- (void)tryDownloadImageForAlertModel:(AppAlertModel*)alertModel
{
    if(!isEmptyString(alertModel.imageURLString) && TTNetworkWifiConnected())
    {
        [_imageManager downloadImageWithURL:alertModel.imageURLString options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
            if(image)
            {
                // to avoid invoke cycle
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[SSAlertCenter defaultCenter] refresh];
                });
            }
        }];
    }
}

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex alertModel:(SSBaseAlertModel *)alertModel;
{
    self.isConcurrency = YES;
    self.localResult = nil;
    
    @autoreleasepool {
        
        AppAlertModel *appAlertModel = (AppAlertModel *)alertModel;
        if(appAlertModel)
        {
            NSString *actionStr = appAlertModel.actions;
            NSArray *actionArray = [actionStr componentsSeparatedByString:@","];
            if ((buttonIndex >= 0) && buttonIndex >= [actionArray count]) {
                return;
            }
            
            if(buttonIndex >= 0)
            {
                NSString *openURL = [[actionArray objectAtIndex:buttonIndex] stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([openURL length] > 0) {
                    NSInteger count = [[appAlertModel.buttons componentsSeparatedByString:@","] count];
                    NSString * eventString = [NSString stringWithFormat:@"appalert_%@_%@", @(count), @(buttonIndex + 1)];
                    wrapperTrackerEvent([TTSandBoxHelper appName], eventString, appAlertModel.actions);
                    
                    if ([openURL hasPrefix:@"snssdk1370"]) {
                        NSURL *tURL = [NSURL URLWithString:openURL];
                        if ([[TTRoute sharedRoute] canOpenURL:tURL]) {
                            [[TTRoute sharedRoute] openURLByPushViewController:tURL];
                        }
                        else {
                            if ([[UIApplication sharedApplication] canOpenURL:tURL]) {
                                [[UIApplication sharedApplication] openURL:tURL];
                            }
                        }
                    }
                    else {
                        NSString *appleIDStr = appAlertModel.appleIDs;
                        NSArray *appleIDArray = nil;
                        if (appleIDStr && !isEmptyString(appleIDStr)) {
                            appleIDArray = [appleIDStr componentsSeparatedByString:@","];
                        }
                        
                        NSString *appleID = nil;
                        if (appleIDArray && [appleIDArray count] > buttonIndex) {
                            appleID = [[appleIDArray objectAtIndex:buttonIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        }
                        
                        if (appleID && !isEmptyString(appleID)) {
                            
                            UIViewController *tViewController = _topViewController;
                            if (!tViewController) {
                                tViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                            }
                            
                            if (tViewController) {
                                [[SSAppStore shareInstance] openAppStoreByActionURL:actionStr itunesID:appleID presentController:tViewController];
                            }
                        }
                        else {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openURL]];
                        }
                    }
                }
            }
            
            NSString *urlPrefix = [CommonURLSetting appAlertActionURLString];
            
            NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                           @"lang" : @"zh-Hans",
                                                                                           @"os" : [TTSandBoxHelper versionName],
                                                                                           @"rule_id" : appAlertModel.rule_id,
                                                                                           @"action" : @(buttonIndex)
                                                                                           }];
            [params setValue:[TTDeviceHelper idfaString] forKey:@"idfa"];
            
            [[TTNetworkManager shareInstance] requestForJSONWithURL:urlPrefix params: params method:@"GET" needCommonParams:YES callback:NULL];
            
            NSArray *buttonArray = [appAlertModel.buttons componentsSeparatedByString:@","];
            NSString *eventString = [NSString stringWithFormat:@"appalert_%@_%@", @(buttonArray.count), @(buttonIndex + 1)];
            
            if(buttonIndex >= 0)
            {
                wrapperTrackerEvent([TTSandBoxHelper appName], eventString, [actionArray objectAtIndex:buttonIndex]);
            }
        }
    }
}

@end
