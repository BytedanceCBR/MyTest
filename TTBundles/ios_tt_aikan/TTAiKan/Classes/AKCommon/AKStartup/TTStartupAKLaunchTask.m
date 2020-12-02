//
//  TTStartupAKLaunchTask.m
//  Article
//
//  Created by 冯靖君 on 2018/3/25.
//

#import "TTStartupAKLaunchTask.h"
#import "AKHelper.h"
#import <MetaSecML/MSManager.h>
#import "TTRoute.h"
#import "CommonURLSetting.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import <TTBaseLib/TTSandBoxHelper.h>
#import "TTLaunchDefine.h"
#import <CoreLocation/CoreLocation.h>
#import <ByteDanceKit.h>
#import <BDInstall/BDInstall.h>
#import <TTAccount.h>
#import "FHEnvContext.h"
#import <BDInstall/BDInstallIDFAManager.h>

DEC_TASK("TTStartupAKLaunchTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+17);


@interface TTStartupAKLaunchTask() <TTAccountMulticastProtocol>
@property (nonatomic, strong) MSManagerML* msManager;
@end

@implementation TTStartupAKLaunchTask

- (NSString *)taskIdentifier
{
    return @"ak_common_launch";
}

- (BOOL)isResident
{
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions
{
    [super startWithApplication:application options:launchOptions];
    
    // 初始化安全SDK MetaSecML
    [self registerSafeSDKService];
    
    // 注册路由action
    [self registerRouteActions];
    
}

- (void)registerRouteActions
{
    // 切换tab
    [TTRoute registerAction:^(NSDictionary *params) {
        NSString *tabIdentifier = [params tt_stringValueForKey:@"id"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTArticleTabBarControllerChangeSelectedIndexNotification" object:nil userInfo:({
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:tabIdentifier forKey:@"tag"];
            [userInfo copy];
        })];
    } withIdentifier:@"change_tab"];
}

- (NSString *)safeSDKLicense {
    // 线上License配置平台：https://aqua.bytedance.net/control-panel/69/sec_sdk/list
    NSString *license = @"qD9Z5hYj0MFcxgesfwpBS8dsg5Lcy7OM3cuJpUNuCBQCFsjjO6qEUMz7Z/POHC44VFkD0WXdrZ+m7f2GRLptDg6Kf4kB2n1Q2d1uudJeLe81CupjJincf4p89OXTHnHLIZntUG+JzLsYYea+akU6CvOPYoGtgqpjm75tHb4LiG/aQbVN1u2uRa/Lt3i2tOBFEplalz/eAigysUgjsV/EcIQ3zIvc8QdntlP6X5gRBXtfztGD24Jud/V7DHIQi8yRd/vdShYV4gBq5r5AIbaORa1gG2eWFV8EBdjFcSmCy5QcBgqBK5cUYReQbWj+oZTwjEgy3KJV6QD7RcxXqXyxB+A+jLj7JQMPcVApWMEjq9vHAzho";
    
    
    BOOL isBOE = [TTSandBoxHelper isInHouseApp] && [[NSUserDefaults standardUserDefaults] boolForKey:@"BOE_OPEN_KEY"];
    if(isBOE) {
        // BOELicense配置平台: https://aqua.boe.bytedance.net/control-panel/378/sec_sdk/list
        license = @"5JGEfmyYBtCrS0pIXhVWTiTnz2cwN1cM8+qZRFwrUITV5RtAd3f7y/dDHDJFqJtlBQmDsoGxEPdV9LPXWIN3RO70GTYpgGqNe1VcMIvs0ZeZBSENoej6IP9N/+lcZIQ373IqErLxdXo1UWWGEwa8ZVDG8EL8GbuDC9hXtAqlqY5kiAf2JJfy+GtEGpwPArXfd8ubZU1HhXZmKksWpI7VkXK204ys9YFUv831d06yEDOjSjCELV/dQ1fxTWmOLlSplGphrKC3zfD1ceicpnPRnDLl/jCR/zcUyuZVx+NKbHrcsX4eESF5ke3gT2sG0dYN7gGMSTzd0pzH1BIrsu1NCCWSyKws+x8k8AbxIfvoyzYAdgaK";
    }
    
    return license;
}

- (void)registerSafeSDKService {
    
    // 接入安全SDK文档： https://bytedance.feishu.cn/docs/doccnCyieen7rxMOUcK4RBzpGKf
    NSString *deviceId = [BDTrackerProtocol deviceID];
    NSString *installId = [BDTrackerProtocol installID];
    NSString *channel = [TTSandBoxHelper getCurrentChannel];
    NSString *sessionId = [[TTAccount sharedAccount] sessionKey];
    MSMLClientType clientType = MS_ML_CLIENT_TYPE_INHOUSE;
    
    NSString *appId = [TTSandBoxHelper ssAppID];
    MSConfigML* msConfig = [[MSConfigML alloc] initWithAppID:appId License: [self safeSDKLicense]];
    msConfig.setClientType(clientType).setChannel(channel);
    
    /// 处理IDFA的配置
    BDInstallAuthorizationStatus idfaStatus = [BDInstallIDFAManager authorizationStatus];
    if(idfaStatus == BDInstallAuthorizationStatusAuthorized) {
        NSString *idfaString = [UIDevice btd_idfaString];
        msConfig.setIDFA(idfaString);
    }
    else {
        // TODO: 待新宇的IDFA需求完成后，监听用户授权IDFA完成的状态后，更新IDFA设置，使用
        // [self updateSafeSDKIDFAWithStatus:status forSence:@"idfa-update-request-user"];
        // status为授权状态
    }
    
    /// MARK: 处理DeviceID和InstallID的配置

    // 用户是否已经同意隐私弹窗协议
    BOOL hasConfirmPermission = [FHEnvContext sharedInstance].hasConfirmPermssionProtocol;
    if(!hasConfirmPermission) { // 用户同意隐私弹窗后才可以设置did和iid
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHasConfirmPermission:) name:PERMISSION_PROTOCOL_CONFIRMED_NOTIFICATION object:nil];
    } else {
        if(deviceId.length > 0) {
            msConfig.setDeviceID(deviceId);
        }
        
        if(installId.length > 0) {
            msConfig.setInstallID(installId);
        }
    }
    // 如果冷启动时候applog还没获取到deviceid,则可以先初始化MetaSec,msConfig中先不设置deviceid，后续did有更新必须通过msManager 设置下deviceID
    self.msManager = [[MSManagerML alloc] initWithConfig:msConfig];
    if(deviceId.length <= 0 || installId.length <= 0) {
        [[BDInstall sharedInstance] observeDeviceDidRegistered:^(NSString * _Nonnull deviceID, NSString * _Nonnull installID) {
            [self updateSafeSDKDid:deviceID installId:installID forScene:@"did-iid-update"];
        }];
    }
    
    /// MARK: 处理登录SessionID的配置
    if(sessionId.length > 0) {
        msConfig.setSessionID(sessionId);
    }
    // 监听用户登录成功事件
    [TTAccount addMulticastDelegate:self];
}

- (void)userHasConfirmPermission:(NSNotification *)notification {
    NSString *deviceId = [BDTrackerProtocol deviceID];
    NSString *installId = [BDTrackerProtocol installID];
    [self updateSafeSDKDid:deviceId installId:installId forScene:@"did-iid-update-user-confirm-permission"];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountLogin {
    [self updateSafeSDKAccountSessionIdForScene:@"sessionId-update-on-login"];
}
#pragma mark - 工具函数

- (void)updateSafeSDKIDFAWithStatus:(BDInstallAuthorizationStatus)idfaStatus forSence:(NSString *)reportScene {
    if(idfaStatus == BDInstallAuthorizationStatusAuthorized) {
        NSString *idfaString = [UIDevice btd_idfaString];
        self.msManager.setIDFA(idfaString);
        [self safeSDKReportForScene:reportScene];
    }
}

- (void)updateSafeSDKDid:(NSString *)deviceId installId:(NSString *)installId forScene:(NSString *)reportScene {
    NSAssert(deviceId.length > 0 && installId.length > 0, @"did 和 iid 须不为空");
    // 用户是否已经同意隐私弹窗协议
    BOOL hasConfirmPermission = [FHEnvContext sharedInstance].hasConfirmPermssionProtocol;
    //必填项:deviceid、did，如果初始化时没有获取到did可以不设置该接口。但是后续did有更新，要求通过 MSManagerML 再次填入，
    //必填项:installid,如果初始化时没有获取到或者installid有更新，后续要求必须通过 MSManagerML 再次填入，并调用 reportForScence接口,上报更改
    if(hasConfirmPermission && deviceId.length > 0 && installId.length > 0) {
        self.msManager.setDeviceID(deviceId);
        self.msManager.setInstallID(installId);
        [self safeSDKReportForScene:reportScene];
    }
}

- (void)updateSafeSDKAccountSessionIdForScene:(NSString *)reportScene {
    NSString *sessionId = [[TTAccount sharedAccount] sessionKey];
    if(sessionId.length > 0) {
        //必填项:用户组件TTAccountSDK 生成的sessionid,非uid,当前uid登录时生成的session,如果初始化时没有获取到可以不设置该接口。但是后续用户有登入登出行为导致sessionid有更新，后续要求必须通过 MSManagerML 再次填入，并调用 reportForScence接口,上报更改
        self.msManager.setSessionID(sessionId);
        [self safeSDKReportForScene:reportScene];
    }
}

- (void)safeSDKReportForScene:(NSString *)reportScene {
    NSAssert(reportScene.length > 0, @"reportScene长度必须不为0，否则会crash");
    if(reportScene.length > 0) {
        [self.msManager reportForScene:reportScene];
    }
}
@end
