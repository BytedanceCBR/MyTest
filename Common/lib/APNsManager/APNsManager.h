//
//  APNsManager.h
//  Essay
//
//  Created by Tianhang Yu on 12-5-7.
//  Copyright (c) 2012年 99fang. All rights reserved.
//
//  1. APNsManager 在application状态为active的状态下不会调用，
//  因此不处理badge相关逻辑，badge相关逻辑和track在project的delegate里面处理。
//  2. 应用程序在active的情况下收到apn，只会显示badge，不会做其他操作
//

#import <Foundation/Foundation.h>

// apns new alert
#define USER_DEFAULT_KEY_APNS_NEW_ALERT  @"user_default_key_apns_new_alert"

@interface APNsManager : NSObject

+ (APNsManager *)sharedManager;

- (void)handleRemoteNotification:(NSDictionary *)userInfo;
- (void)sendAppNoticeStatus;
- (void)sendTrackEvent:(NSString *)event lable:(NSString *)label value:(NSString *)valueString;

#pragma mark - extended
- (void)trackWithPageName:(NSString *)pageName params:(NSDictionary *)params;
- (void)dealWithOpenURL:(NSString **)openURL;

// return YES if old logical, this method is for Article project old logical apns
- (BOOL)tryForOldAPNsLogical:(NSDictionary *)userInfo;

@end
