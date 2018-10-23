//
//  NewVersionAlertManager.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-8.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "NewVersionAlertManager.h"
#import "NewVersionAlertModel.h"
#import "InstallIDManager.h"
#import "CommonURLSetting.h"
#import "TTIndicatorView.h"
#import "TTInfoHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTStringHelper.h"

@interface NewVersionAlertManager () {
    BOOL _autoCheck;
}

@end

@implementation NewVersionAlertManager

#pragma mark - public

- (void)startAlertAutoCheck:(BOOL)autoCheck
{
    _autoCheck = autoCheck;
    
    [self startAlertAfterDelay:0 concurrency:YES];
}

- (BOOL)hasNewVersion
{
    return [self checkBundleVersionIsNew:lastVersionName()];
}

#pragma mark - extend methods

static NewVersionAlertManager *_alertManager = nil;
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
    NSString * appIDStr = isEmptyString([TTInfoHelper ssAppID]) ? @"" : [NSString stringWithFormat:@"&aid=%@", [TTInfoHelper ssAppID]];
    NSMutableString *tURL = [NSMutableString stringWithFormat:@"%@?name=%@&user_req=%d&openudid=%@%@", [CommonURLSetting checkVersionURLString], [TTInfoHelper appName], !_autoCheck, [TTInfoHelper openUDID], appIDStr];
    
    if(!isEmptyString([[InstallIDManager sharedManager] deviceID])) {
        [tURL appendFormat:@"&device_id=%@", [[InstallIDManager sharedManager] deviceID]];
    }
    if (!isEmptyString([[InstallIDManager sharedManager] installID])) {
        [tURL appendFormat:@"&iid=%@", [[InstallIDManager sharedManager] installID]];
    }
    
    NSString *url = [[tURL copy] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return url;
}

- (NSDictionary *)parameterDict
{
    return nil;
}

- (void)handleError:(NSError *)error {
    // could be extended
    if (_autoCheck == NO) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"message" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    }
}

- (NSArray *)handleAlert:(NSDictionary *)result
{
    // 处理服务器返回的版本信息数据
    NSDictionary *cVersionDict = [result objectForKey:@"data"];
    
    NewVersionAlertModel *newVersionAlertModel = [[NewVersionAlertModel alloc] init];

    newVersionAlertModel.delayTime = [[cVersionDict objectForKey:@"latency_seconds"] doubleValue];
    newVersionAlertModel.title = [cVersionDict objectForKey:@"title"];
    newVersionAlertModel.forceUpdate = [[cVersionDict objectForKey:@"force_update"] doubleValue];
    /*
     如果是用户手动触发的检查版本，使用实际最大的版本号
     如果是系统自动发出的检查版本，使用允许看到的版本号
     */
    NSString * lastVersionName = [NSString stringWithFormat:@"%@", [cVersionDict objectForKey:@"last_version_name"]];

    // 只有自动显示，才需要显示小红点等其它提示，因此用户触发而获取最大版本号的代码，要在 setLastVersionName() 之后执行
    setLastVersionName(lastVersionName);
    [[NSNotificationCenter defaultCenter] postNotificationName:CheckNewVersionFinishedNotification object:self];

    // 接口就位后，这里的 NSLocalizedString(@"10", 应当被改为 [cVersionDict objectForKey:@", nil)xx"]; xx为最大版本号的字段名
    if (!_autoCheck) {
        NSString * realLastVersionName = [NSString stringWithFormat:@"%@", [cVersionDict objectForKey:@"real_last_version_name"]];
        if (realLastVersionName && [realLastVersionName isKindOfClass:[NSString class]]) {
            lastVersionName = realLastVersionName;
        }
    }
    
    if ([self checkBundleVersionIsNew:lastVersionName]) {
        /*
         如果是强制升级，则每次都弹
         发现有要弹框提示给用户的新版本:
         1、用户手动触发
         2、自动触发，距离上次提醒间隔特定时间段之后
        */
        if (!_autoCheck || newVersionAlertModel.forceUpdate || [self checkNeedAlertNewVersion:lastVersionName]) {
            NSString *downloadUrl = [cVersionDict objectForKey:@"market_url"];
            NSString *whatsNew = [cVersionDict objectForKey:@"whats_new"];
            
            newVersionAlertModel.title   = NSLocalizedString(@"发现新版本", nil);
            newVersionAlertModel.message = whatsNew;
            newVersionAlertModel.buttons = NSLocalizedString(@"立即升级,稍后再说", nil);
            newVersionAlertModel.actions = [NSString stringWithFormat:@"%@,", downloadUrl];
            newVersionAlertModel.versionNameNew = lastVersionName;
            
            newVersionAlertModel.delayTime = [[cVersionDict objectForKey:@"latency"] doubleValue];
            newVersionAlertModel.hasNewVersion = YES;
            
            return [NSArray arrayWithObject:newVersionAlertModel];
        }
        else {
            return nil;
        }
    }
    else {
        newVersionAlertModel.title   = NSLocalizedString(@"当前是最新版本", nil);
        newVersionAlertModel.buttons = NSLocalizedString(@"确定", nil);
        newVersionAlertModel.hasNewVersion = NO;
        
        if (!_autoCheck) {
            return [NSArray arrayWithObject:newVersionAlertModel];
        }
        else {
            return nil;
        }
    }
}

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex alertModel:(SSBaseAlertModel *)alertModel
{
    NewVersionAlertModel *newVersionAlertModel = (NewVersionAlertModel *)alertModel;
    if(newVersionAlertModel)
    {
        NSString *actionStr = newVersionAlertModel.actions;
        NSArray *actionArray = [actionStr componentsSeparatedByString:@","];
        if (buttonIndex >= [actionArray count]) return;
        
        updateNewVersionLastDelayDaysAndCheckRecordLastTime(newVersionAlertModel.versionNameNew);
        
        NSString *url = [[actionArray objectAtIndex:buttonIndex] stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([url length] > 0)
        {
            NSUInteger count = [[newVersionAlertModel.buttons componentsSeparatedByString:@","] count];
            NSString *eventString = [NSString stringWithFormat:@"appalert_%lu_%li", (unsigned long)count, (long)(buttonIndex + 1)];
            ssTrackEvent(eventString, newVersionAlertModel.actions);
            
            [[UIApplication sharedApplication] openURL:[TTStringHelper URLWithURLString:url]];
        }
    }
}

#pragma mark - private

- (BOOL)checkBundleVersionIsNew:(NSString *)lastVersionStr
{
    BOOL hasNewVersion = NO;
    
    if ([lastVersionStr length] == 0) return NO;
    
    NSString *currentVersion = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ];
    NSArray *currentVersionArray = [currentVersion componentsSeparatedByString:@"."];
    NSArray *lastVersionArray = [lastVersionStr componentsSeparatedByString:@"."];
    
    int currentPosition = 0;
    while (!hasNewVersion && (currentPosition < [currentVersionArray count] || currentPosition < [lastVersionArray count])) {

        int currentPositionValue = currentPosition < [currentVersionArray count] ?
                                    [[currentVersionArray objectAtIndex:currentPosition] intValue] : 
                                    0;
        int lastPositionValue = currentPosition < [lastVersionArray count] ? 
                                    [[lastVersionArray objectAtIndex:currentPosition] intValue] :
                                    0;
        
        hasNewVersion = lastPositionValue > currentPositionValue;
        
        if (lastPositionValue < currentPositionValue) {
            break;
        }
        
        currentPosition ++;
    }
    
    return hasNewVersion;
}

- (BOOL)checkNeedAlertNewVersion:(NSString *)lastVersionStr
{
    NSString *key = checkRecordKey(lastVersionStr);
    NSDictionary *recordDict = newVersionCheckRecordDict();
    
    BOOL ret = YES;
    if (recordDict) {
        NSDictionary *versionDict = [recordDict objectForKey:key];
        
        if (versionDict) {
            NSNumber *lastTime = [versionDict objectForKey:kNewVersionCheckRecordLastTimeKey];
            NSNumber *days = [versionDict objectForKey:kNewVersionLastDelayDaysKey];
            
            if (lastTime && days) {
                double timeInterval = [[NSDate date] timeIntervalSince1970] - [lastTime doubleValue];
                
                if (timeInterval < [days intValue]*24*60*60) {
                    ret = NO;
                }
            }
        }
    }
    return ret;
}

@end
