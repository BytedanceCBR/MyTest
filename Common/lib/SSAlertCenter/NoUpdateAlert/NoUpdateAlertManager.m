//
//  AppAlert.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-7.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "NoUpdateAlertManager.h"
#import "NoUpdateAlertModel.h"
#import "NetworkUtilities.h"
#import "UIDevice+TTAdditions.h"
#import "SSActionManager.h"
#import "InstallIDManager.h"
#import "CommonURLSetting.h"
#import "TTDeviceHelper.h"

@interface NoUpdateAlertManager ()
@property (nonatomic, weak) UIViewController *topViewController;
//@property (nonatomic, retain) NSMutableArray *preparedAlertModels;
@property (nonatomic, strong) NoUpdateAlertModel *currentAlert;
@property (nonatomic, weak) SSActionManager * tipManager;
@end

@implementation NoUpdateAlertManager

- (id)init
{
    self = [super init];
    if (self) {
        self.tipManager = [SSActionManager sharedManager];
//        [self loadAlertModelsFromLocal];
    }
    return self;
}

//- (void)loadAlertModelsFromLocal
//{
//    NSDictionary *result = noUpdateAlertResult();
//    NSArray *data = [result objectForKey:@"data"];
//    NSMutableArray *alertModels = [[[NSMutableArray alloc] initWithCapacity:[data count]] autorelease];
//    
//    for (int i=0; i < [data count]; i++) {
//        NoUpdateAlertModel *noUpdateAlertModel = [[[NoUpdateAlertModel alloc] initWithDictionary:[data objectAtIndex:i]] autorelease];
//        [alertModels addObject:noUpdateAlertModel];
//    }
//    self.preparedAlertModels = alertModels;
//}

#pragma mark - public

- (NoUpdateAlertModel *)startLocalAlertNotifyInViewController:(UIViewController *)topViewController remoteResult:(NSDictionary *)aDict
{
    self.isConcurrency = YES;
    [self handleAlert:aDict];
    
    self.topViewController = topViewController;
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        _tipManager.topViewController = (UINavigationController *)topViewController;
    }
    else {
        _tipManager.topViewController = topViewController.navigationController;
    }
    return _currentAlert;
}

- (void)currentAlertNotifyClicked:(id)sender
{
    [_currentAlert.tip sendTrackEventWithLabel:@"tips_click"];
    
    if ([_topViewController isKindOfClass:[UINavigationController class]]) {
        _tipManager.topViewController = (UINavigationController *)_topViewController;
    }
    else {
        _tipManager.topViewController = _topViewController.navigationController;
    }
    
    SSTipModelActionType actionType = [SSTipModel actionTypeForTipModel:_currentAlert.tip];
    if (actionType == SSTipModelActionTypeOpenApp) {
        [_tipManager openAppURL:_currentAlert.tip.appURL tabURL:_currentAlert.tip.tabURL adID:[NSString stringWithFormat:@"%lld",_currentAlert.tip.adID.longLongValue] logExtra:_currentAlert.tip.logExtra];
    }
    else if (actionType == SSTipModelActionTypeDownload || actionType == SSTipModelActionTypeAlertWebOrDownload) {
        [self startAlertAfterDelay:0 concurrency:NO];
    }
    else if (actionType == SSTipModelActionTypeWebView) {
        [_tipManager openWebURL:_currentAlert.tip.webURL appName:_currentAlert.tip.appName adID:[NSString stringWithFormat:@"%lld",_currentAlert.tip.adID.longLongValue] logExtra:_currentAlert.tip.logExtra];
    }
}

#pragma mark - extend methods

static NoUpdateAlertManager *_alertManager = nil;
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
    NSString *url = [NSString stringWithFormat:@"%@?device_platform=%@&channel=%@&version_code=%@&app_name=%@&device_type=%@&os_version=%f&openudid=%@%@",
                      [CommonURLSetting appNoUpdateNotifyURLString],
                      [TTDeviceHelper platformName],
                      [TTInfoHelper getCurrentChannel],
                      [TTInfoHelper versionName],
                      [TTInfoHelper appName],
                      [[UIDevice currentDevice] platformString],
                      [TTInfoHelper OSVersionNumber],
                      [TTInfoHelper openUDID],
                     appIDStr];
    
    if(!isEmptyString([[InstallIDManager sharedManager] deviceID]))
    {
        url = [NSString stringWithFormat:@"%@&device_id=%@", url, [[InstallIDManager sharedManager] deviceID]];
    }
    
    if(!isEmptyString([TTInfoHelper ssAppID]))
    {
        url = [NSString stringWithFormat:@"%@&aid=%@", url, [TTInfoHelper ssAppID]];
    }
    
    return url;
}

- (NSDictionary *)parameterDict
{
    return nil; // get params are in url prefix
}

- (NSArray *)handleAlert:(NSDictionary *)result
{
    if (self.isConcurrency) {
        
//        if (result) {
//            setNoUpdateAlertResult(result);
//            setNoUpdateAlertIndex(0);
//        }
        
        if (result && [result.allKeys containsObject:@"tips"]) {
            
            NSArray *data = @[[result objectForKey:@"tips"]];
            NSMutableArray *alertModels = [[NSMutableArray alloc] initWithCapacity:[data count]];
            
            for (int i=0; i < [data count]; i++) {
                NoUpdateAlertModel *noUpdateAlertModel = [[NoUpdateAlertModel alloc] initWithDictionary:[data objectAtIndex:i]];
                [alertModels addObject:noUpdateAlertModel];
            }
            
            if ([alertModels count] > 0) {
                self.currentAlert = [alertModels objectAtIndex:0];
                [self.alertModels removeAllObjects];
            }
            else {
                self.currentAlert = nil;
            }
        }
        else {
            self.currentAlert = nil;
        }
        
        [_currentAlert.tip sendTrackEventWithLabel:@"tips_show"];
       
        return nil; // return nil to stop alert directly
    }
    else {
        [self.alertModels removeAllObjects];
        return @[_currentAlert];
    }
}

- (void)handleError:(NSError *)error
{
    if (error) {
//        [self loadAlertModelsFromLocal];
    }
}

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex alertModel:(SSBaseAlertModel *)alertModel
{
    NoUpdateAlertModel *noUpdateAlertModel = (NoUpdateAlertModel *)alertModel;
    SSTipModelActionType actionType = [SSTipModel actionTypeForTipModel:noUpdateAlertModel.tip];
    if (actionType == SSTipModelActionTypeDownload) {
        if (buttonIndex == 0) {
            [noUpdateAlertModel.tip sendTrackEventWithLabel:@"tips_alert_install"];
            [_tipManager openDownloadURL:noUpdateAlertModel.tip.downloadURL appleID:noUpdateAlertModel.tip.appleID];
        }
    }
    else if (actionType == SSTipModelActionTypeAlertWebOrDownload) {
        switch (buttonIndex) {
            case 0:
                [noUpdateAlertModel.tip sendTrackEventWithLabel:@"tips_alert_preview"];
                [_tipManager openWebURL:noUpdateAlertModel.tip.webURL appName:noUpdateAlertModel.tip.appName adID:[NSString stringWithFormat:@"%lld", noUpdateAlertModel.tip.adID.longLongValue] logExtra:noUpdateAlertModel.tip.logExtra];
                break;
            case 1:
                [noUpdateAlertModel.tip sendTrackEventWithLabel:@"tips_alert_install"];
                [_tipManager openDownloadURL:noUpdateAlertModel.tip.downloadURL appleID:noUpdateAlertModel.tip.appleID appName:noUpdateAlertModel.tip.appName];
                break;

            default:
                break;
        }
        
    }
    else {
        [noUpdateAlertModel.tip sendTrackEventWithLabel:@"tips_alert_cancel"];
    }
}

@end
