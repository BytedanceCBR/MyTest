//
//  AppDelegate.m
//  Video
//
//  Created by Tianhang Yu on 12-7-15.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "VideoBaseDelegate.h"
#import "NSUserDefaultsAdditions.h"
#import "VideoDownloadDataManager.h"
#import "NetworkUtilities.h"
#import "ShareOne.h"
#import "VideoDownloadDataManager.h"
#import "RecomDataManager.h"
#import "SSAlertCenter.h"
#import "APNsManager.h"
#import "AppAlertManager.h"
#import "NewVersionAlertManager.h"
#import "FastSSOAlertManager.h"
#import "FeedbackConstants.h"
#import "FeedbackViewController.h"
#import "SSSimpleCache.h"
#import "CommonURLSetting.h"
#import "CJSONDeserializer.h"
#import "VideoLocalServer.h"
#import "VideoGetUpdatesNumberManager.h"
#import "AccountManager.h"
#import "SSBatchItemActionManager.h"
#import "SSWeixin.h"
#import "SSSinaClient.h"
#import "SSActivityIndicatorView.h"

@interface VideoBaseDelegate ()
{
    NSString * _deviceToken;
}

@end

@implementation VideoBaseDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [_deviceToken release];
    [super dealloc];
}

- (NSString *)appKey
{
    // should be extended
    return nil;
}

- (NSString *)umTrackAppKey
{
    // should be extended
    return nil;
}

- (NSString*)weixinAppID
{
    // should be extended
    return nil;
}

- (NSString *)channelId
{
    return getCurrentUmengChannelId();
}

- (void)handleApplicationLaunchOptionRemoteNotification:(NSDictionary *)launchOptions
{
     if ([launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [[APNsManager sharedManager] handleRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
   
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                          UIRemoteNotificationTypeAlert |
                                                                          UIRemoteNotificationTypeSound)];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[AppAlertManager alertManager] startAlert];
    [[NewVersionAlertManager alertManager] startAlertAutoCheck:YES];
    [[FastSSOAlertManager alertManager] startAlertInWindow:self.window];
    
    // first time launch setting
    if ([NSUserDefaults firstTimeRunByType:firstTimeTypeAppDelegate]) {
        setNotWifiAlertOn(YES);
        setVideoDownloadDataManagerBatchStarted(YES);
        setOrientationLock(NO);
    }
    
    // track start
    NSString *appKey = [self umTrackAppKey];
    NSString *deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&udid=%@", appKey, deviceName, udid];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] delegate:nil];
    SSLog(@"umTrack url:%@", urlString);
    
    [self performSelectorInBackground:@selector(reportAppOpenToAdMob) withObject:nil];  // admob
    
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-27818855-1"
                                           dispatchPeriod:-1
                                                 delegate:nil];
    [[GANTracker sharedTracker] dispatch];
    [MobClick setDelegate:self reportPolicy:REALTIME];
    [SSTracker startWithAppKey:[self appKey]];
    
    [SSWeixin registerWithID:[self weixinAppID]];
    [[AccountManager sharedManager] startGetAccountStates:NO];  //更新各平台session状态
    
    // recommend data
    [[RecomDataManager getInstance] startGetMsgThread];
    
    // download when launch
    if (SSNetworkWifiConnected()) {
        [[VideoDownloadDataManager sharedManager] currentDownloadStart];
    }
    else {
        [[VideoDownloadDataManager sharedManager] batchStop];
    }
    
    // feedback
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resultRecived:)
                                                 name:KEY_FEEDBACK_RESULT
                                               object:nil];
    [FeedbackViewController startLoadComments];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[SSSimpleCache sharedCache] startGarbageCollection];
    [[APNsManager sharedManager] sendAppNoticeStatus];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[SSBatchItemActionManager shareManager] excuteSynchronizedBatch];
    });
    
    if (_deviceToken == nil)   return;
    if (!SSNetworkConnected()) return;
    
    UIApplication *app = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier taskId;
    taskId = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:taskId];
    }];
    
    if (taskId == UIBackgroundTaskInvalid) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        int repeatCount = 2;
        while (repeatCount > 0) {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:
                                            [NSURL URLWithString:[CommonURLSetting appLogoutURLString]]];
            [request setHTTPMethod:@"POST"];
            
            NSString *requestString = [NSString stringWithFormat:@"uuid=%@&app_name=%@&platform=%@&channel=%@&token=%@&openudid=%@", [SSCommon getUniqueIdentifier], [SSCommon appName], [SSCommon platformName],getCurrentChannel(), _deviceToken, [SSCommon openUDID]];
            
            
            NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding
                                              allowLossyConversion:YES];
            [request setHTTPBody:requestData];
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            [request release];
            
            CJSONDeserializer *jsonparser = [[CJSONDeserializer alloc] init];
            NSError *error = nil;
            NSDictionary *root = [jsonparser deserialize:data error:&error];
            [jsonparser release];
            
            if ([[root objectForKey:@"message"] isEqualToString:@"success"]) {
                repeatCount = 0;
            }
            else {
                repeatCount --;
            }
        }
        
        [app endBackgroundTask:taskId];
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[AccountManager sharedManager] startGetAccountStates:NO];
    
    [[SSSimpleCache sharedCache] stopGarbageCollection];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[AppAlertManager alertManager] startAlert];
    [[NewVersionAlertManager alertManager] startAlertAutoCheck:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resultRecived:)
                                                 name:KEY_FEEDBACK_RESULT
                                               object:nil];
    [FeedbackViewController startLoadComments];
    
    [[VideoGetUpdatesNumberManager sharedManager] timingGetUpdatesNumber];
    
    // download when launch
    if (SSNetworkWifiConnected()) {
        [[VideoDownloadDataManager sharedManager] currentDownloadStart];
    }
    else {
        [[VideoDownloadDataManager sharedManager] batchStop];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    _deviceToken = [[[[[deviceToken description]
                       stringByReplacingOccurrencesOfString: @"<" withString: @""]
                      stringByReplacingOccurrencesOfString: @">" withString: @""]
                     stringByReplacingOccurrencesOfString: @" " withString: @""] retain];
    
    SSLog(@"device token: %@", _deviceToken);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    SSLog(@"apns failed with error:%@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        // do nothing
    }
    else {
        [[APNsManager sharedManager] handleRemoteNotification:userInfo];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL weixinResult = [SSWeixin handleOpenURL:url];
    BOOL sinaResult = [[SSSinaClient sharedClient] handleOpenURL:url];
    return  weixinResult || sinaResult;
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL weixinResult = [SSWeixin handleOpenURL:url];
    BOOL sinaResult = [[SSSinaClient sharedClient] handleOpenURL:url];
    return  weixinResult || sinaResult;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    SSLog(@"Application will terminate.");
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - FeedBack delegate

- (void)resultRecived:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_FEEDBACK_RESULT object:nil];
    
    NSDictionary * root = notification.userInfo;
    
    if ([STR_SUCCESS isEqualToString:[root objectForKey:STR_MESSAGE]]) {
        NSArray * data = [root objectForKey:STR_DATA];
        
        if ([data count] > 0 && [FeedbackViewController checkItems:data update:NO]) {
            [self performSelectorOnMainThread:@selector(showFeedbackAlert) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)showFeedbackAlert
{
    UIAlertView * feedbackView = [[UIAlertView alloc] initWithTitle:@"发现新的回复"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"查看", nil];
    [feedbackView show];
    [feedbackView release];
}

- (void)showFeedbackViewController
{
    // should be extended
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex ==1) {
        [self showFeedbackViewController];
    }
}

#pragma mark - Admob

// This method requires adding #import <CommonCrypto/CommonDigest.h> to your source file.
- (NSString *)hashedISU
{
    NSString *result = nil;
    NSString *isu = [UIDevice currentDevice].uniqueIdentifier;
    
    if(isu) {
        unsigned char digest[16];
        NSData *data = [isu dataUsingEncoding:NSASCIIStringEncoding];
        CC_MD5([data bytes], [data length], digest);
        
        result = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                  digest[0], digest[1],
                  digest[2], digest[3],
                  digest[4], digest[5],
                  digest[6], digest[7],
                  digest[8], digest[9],
                  digest[10], digest[11],
                  digest[12], digest[13],
                  digest[14], digest[15]];
        result = [result uppercaseString];
    }
    return result;
}

- (void)reportAppOpenToAdMob
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // we're in a new thread here, so we need our own autorelease pool
    // Have we already reported an app open?
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask, YES) objectAtIndex:0];
    NSString *appOpenPath = [documentsDirectory stringByAppendingPathComponent:@"admob_app_open"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:appOpenPath]) {
        // Not yet reported -- report now
        NSString *appOpenEndpoint = [NSString stringWithFormat:@"http://a.admob.com/f0?isu=%@&md5=1&app_id=%@",
                                     [self hashedISU], @"550931978"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:appOpenEndpoint]];
        NSURLResponse *response;
        NSError *error = nil;
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && ([responseData length] > 0)) {
            [fileManager createFileAtPath:appOpenPath contents:nil attributes:nil]; // successful report, mark it as such
            NSLog(@"App download successfully reported.");
        } else {
            NSLog(@"WARNING: App download not successfully reported. %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }
    }
    [pool release];
}
    
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//    return  [WXApi handleOpenURL:url delegate:self];
//}
//
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    return  [WXApi handleOpenURL:url delegate:self];
//}

@end
