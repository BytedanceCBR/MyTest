//
//  BDDYCClient.m
//  BDDynamically
//
//  Created by zuopengliu on 21/5/2018.
//

#import "BDDYCClient.h"
#import <FHHouseBase/FHURLSettings.h>

#if __has_include(<TTBaseLib/TTSandBoxHelper.h>)
#import <TTBaseLib/TTSandBoxHelper.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#define BDDYC_HAS_BASELIB 1
#endif

#if __has_include(<TTInstallIDManager.h>)
#import "TTInstallIDManager.h"
#define BDDYC_HAS_INSTALL 1
#endif

#if __has_include(<TTSettingsManager/TTSettingsManager.h>)
#import <TTSettingsManager/TTSettingsManager.h>
#define BDDYC_HAS_SETTINGS 1
#endif

#if __has_include(<TTNetBusiness/TTNetworkUtilities.h>)
#import <TTNetBusiness/TTNetworkUtilities.h>
#define BDDYC_HAS_NETWORK 1
#endif



@implementation BDDYCClient

+ (void)load
{
#if BDDYC_HAS_SETTINGS
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relaunchDidReceiveSettingsNotification:) name:TTSettingsManagerDidUpdateNotification object:nil];
    });
#endif
}

+ (void)start
{
#ifdef BDDYC_ENABLED
    
    NSDictionary *dycConfs = @{@"on_off": @(1)};
    
#if BDDYC_HAS_SETTINGS
    NSDictionary *archSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    dycConfs = [archSettings dictionaryValueForKey:@"better_settings" defalutValue:@{@"on_off": @(1)}];
    
//    dycConfs = [[TTSettingsManager sharedManager] settingForKey:@"better_settings"
//                                                   defaultValue:@{@"on_off": @(1)}
//                                                         freeze:NO];
#endif
    
    NSNumber *onNumber = [dycConfs isKindOfClass:[NSDictionary class]] ? dycConfs[@"on_off"] : nil;
    if (onNumber && [onNumber respondsToSelector:@selector(boolValue)] && [onNumber boolValue]) {
        BDBDConfiguration *conf = [BDBDConfiguration new];
        
#if BDDYC_HAS_NETWORK
        conf.commonNetworkParamsBlock = ^NSDictionary * {
            return [TTNetworkUtilities commonURLParameters];
        };
#endif
        
#if BDDYC_HAS_INSTALL
        conf.getDeviceIdBlock = ^NSString * {
            return [[TTInstallIDManager sharedInstance] deviceID];
        };
#endif
        
//        conf.distArea = kBDDYCDeployAreaCN;
#if BDDYC_HAS_BASELIB
        conf.aid = [TTSandBoxHelper ssAppID];
        conf.channel = [TTSandBoxHelper getCurrentChannel];
        conf.appVersion = [TTSandBoxHelper versionName];
#endif
        conf.appBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        BDBDLogConfiguration *logConf = [BDBDLogConfiguration new];
        logConf.enableModInitLog = YES;
        logConf.enablePrintLog   = YES;
        logConf.enableInstExecLog = YES;
        logConf.enableInstCallFrameLog = YES;
        [BDBDMain sharedMain].logConf = logConf;
        [BDBDMain startWithConfiguration:conf delegate:nil];

    }
    
#endif
}

+ (void)close
{
    
}

+ (void)unloadWithName:(NSString *)path
{
    
}

#if BDDYC_HAS_SETTINGS

+ (void)relaunchDidReceiveSettingsNotification:(NSNotification *)note
{
    [self start];
}

#endif

@end



@implementation BDDYCClient (OnlyForDebug)

+ (void)startAsDebug
{
#if DEBUG
#ifdef BDDYC_ENABLED

    BDBDConfiguration *conf = [BDBDConfiguration new];
#if BDDYC_HAS_NETWORK
    conf.commonNetworkParamsBlock = ^NSDictionary * {
        return [TTNetworkUtilities commonURLParameters];
    };
#endif
    
#if BDDYC_HAS_INSTALL
    conf.getDeviceIdBlock = ^NSString * {
        return [[TTInstallIDManager sharedInstance] deviceID];
    };
#endif
    
    //conf.distArea = kBDDYCDeployAreaCN;
#if BDDYC_HAS_BASELIB
    conf.aid = [TTSandBoxHelper ssAppID];
    conf.channel = [TTSandBoxHelper getCurrentChannel];
    conf.appVersion = [TTSandBoxHelper versionName];
#endif
    
    conf.appBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    BDBDLogConfiguration *logConf = [BDBDLogConfiguration new];
    logConf.enableModInitLog = YES;
    logConf.enablePrintLog   = YES;
    logConf.enableInstExecLog = YES;
    logConf.enableInstCallFrameLog = YES;
    [BDBDMain sharedMain].logConf = logConf;
    [BDBDMain startWithConfiguration:conf delegate:nil];

#endif
#endif
}

+ (void)loadAtPath:(NSString *)path;
{
#ifdef BDDYC_ENABLED
    // todo zjing
//    [BDBDQuaterback loadFileAtPath:path];
#endif
}

+ (void)loadZipAtPath:(NSString *)zipPath
{
#ifdef BDDYC_ENABLED
    
//    [BDBDQuaterback loadZipFileAtPath:zipPath];
    
#endif
}

@end



@implementation BDDYCClient (SchemeLaunch)

@end
