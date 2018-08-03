//
//  TFFetchInfoManager.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-26.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TFFetchInfoManager.h"
#import "SSHttpOperation.h"
#import "SSOperationManager.h"
#import "TFManager.h"
#import "UIDevice-Hardware.h"
#import "TFAppInfosModel.h"
#import "NetworkUtilities.h"

#define IPAListURL @"http://admin.bytedance.com/apptest/ipa_list/"

static TFFetchInfoManager * shareManager;

@interface TFFetchInfoManager()

@property(nonatomic, retain)SSHttpOperation * fetchInfoOperation;

@end

@implementation TFFetchInfoManager

+ (TFFetchInfoManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[TFFetchInfoManager alloc] init];
    });
    return shareManager;
}

- (void)dealloc
{
    [_fetchInfoOperation cancelAndClearDelegate];
    self.fetchInfoOperation = nil;
    [super dealloc];
}

- (void)startFetchInfos:(NSString *)email identity:(NSString *)identity isRegister:(BOOL)regist
{
    if (isEmptyString(email) || isEmptyString(identity)) {
        return;
    }
    
    [TFManager saveTestFlightAccountEmail:email];
    [TFManager saveTestFlightAccountIdentifier:identity];
    
    NSMutableDictionary * getParameter = [NSMutableDictionary dictionaryWithCapacity:10];
    [getParameter setValue:email forKey:@"email"];
    [getParameter setValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"];
    [getParameter setValue:identity forKey:@"identity"];
    [getParameter setValue:[[UIDevice currentDevice] ssPlatformString] forKey:@"device_model"];
    if (regist) {
        [getParameter setObject:[NSNumber numberWithBool:YES] forKey:@"register"];
    }

    self.fetchInfoOperation = [SSHttpOperation httpOperationWithURLString:IPAListURL getParameter:getParameter];
    [_fetchInfoOperation setFinishTarget:self selector:@selector(operation:finishedResult:error:userInfo:)];
    [SSOperationManager addOperation:_fetchInfoOperation];
}


- (void)operation:(SSHttpOperation*)operation finishedResult:(NSDictionary*)result error:(NSError*)error userInfo:(id)userInfo
{
    if (_fetchInfoOperation == operation) {
        NSString * message = [[result objectForKey:@"result"] objectForKey:@"message"];

        if (error || [message isEqualToString:@"error"]) {
            if (error) {
                NSDictionary * failedUserInfo = nil;
                if (SSNetworkConnected()) {
                    failedUserInfo = @{kErrorType : kNoNetConnectError};
                }
                else {
                    failedUserInfo = @{kErrorType : kServerError};
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kFetchInfoFailedNotification object:nil userInfo:failedUserInfo];
                return;
            }
            
            [TFManager saveIsUserAvailable:NO];
            NSString * errorInfo = [[result objectForKey:@"result"] objectForKey:@"error_info"];

            NSDictionary * failedUserInfo = nil;
            
            if ([errorInfo isKindOfClass:[NSString class]] && !isEmptyString(errorInfo)) {
                failedUserInfo = @{kErrorType : errorInfo};
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFetchInfoFailedNotification object:nil userInfo:failedUserInfo];
            
            NSLog(@"errorInfo %@", errorInfo);
        }
        else {
            [TFManager saveIsUserAvailable:YES];
            
            NSArray * data = [[result objectForKey:@"result"] objectForKey:@"data"];
            NSMutableArray * models = [NSMutableArray arrayWithCapacity:50];
            for (NSDictionary * dict in data) {
                TFAppInfosModel * model = [[TFAppInfosModel alloc] init];
                model.uploadTime = [NSNumber numberWithLong:[[dict objectForKey:@"upload_time"] longLongValue]];
                model.releaseID = [NSNumber numberWithInt:[[dict objectForKey:@"release_id"] longLongValue]];
                model.appName = [NSString stringWithFormat:@"%@", [dict objectForKey:@"app_name"]];
                model.iconURL = [NSString stringWithFormat:@"%@", [dict objectForKey:@"icon_url"]];
                model.updateNumber = [NSNumber numberWithLong:[[dict objectForKey:@"update_number"] longLongValue]];
                model.pkgName = [NSString stringWithFormat:@"%@", [dict objectForKey:@"pkg_name"]];
                model.ipaURL = [NSString stringWithFormat:@"%@", [dict objectForKey:@"ipa_url"]];
                model.releaseBuild = [NSString stringWithFormat:@"%@", [dict objectForKey:@"release_build"]];
                model.ipaSize = [NSNumber numberWithLong:[[dict objectForKey:@"ipa_size"] longLongValue]];
                model.versionName = [NSString stringWithFormat:@"%@", [dict objectForKey:@"version_name"]];
                model.ipaHash = [NSString stringWithFormat:@"%@", [dict objectForKey:@"ipa_hash"]];
                model.whatsNew = [NSString stringWithFormat:@"%@", [dict objectForKey:@"whats_new"]];
                [models addObject:model];
                [model release];
            }
            
            [TFManager saveTFAppInfosModels:models];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFetchInfoDoneNotification object:nil];
        }
    }
}

@end
