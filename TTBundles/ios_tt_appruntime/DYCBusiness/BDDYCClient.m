//
//  BDDYCClient.m
//  BDDynamically
//
//  Created by zuopengliu on 21/5/2018.
//

#import "BDDYCClient.h"

#if __has_include(<TTBaseLib/TTSandBoxHelper.h>)
#import <TTBaseLib/TTSandBoxHelper.h>
#define BDDYC_HAS_BASELIB 1
#endif

#if __has_include(<TTInstallIDManager.h>)
#import <TTInstallIDManager.h>
#define BDDYC_HAS_INSTALL 1
#endif

#if __has_include(<TTSettings/TTSettingsManager.h>)
#import <TTSettings/TTSettingsManager.h>
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
    dycConfs = [[TTSettingsManager sharedManager] settingForKey:@"better_settings"
                                                   defaultValue:@{@"on_off": @(1)}
                                                         freeze:NO];
#endif
    
    NSNumber *onNumber = [dycConfs isKindOfClass:[NSDictionary class]] ? dycConfs[@"on_off"] : nil;
    if (onNumber && [onNumber respondsToSelector:@selector(boolValue)] && [onNumber boolValue]) {
        BDDYCConfiguration *conf = [BDDYCConfiguration new];
        
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
        [BDDYCMain startWithConfiguration:conf delegate:nil];
        
        BDDYCLogConfiguration *logConf = [BDDYCLogConfiguration new];
        logConf.enableModInitLog = YES;
        logConf.enablePrintLog   = YES;
        logConf.enableInstExecLog = YES;
        logConf.enableInstCallFrameLog = YES;
        [BDDYCMain sharedMain].logConf = logConf;
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

    BDDYCConfiguration *conf = [BDDYCConfiguration new];
    conf.commonNetworkParamsBlock = ^NSDictionary *{
        return @{};
    };
    conf.getDeviceIdBlock = ^NSString *{
        return @"38986334076";
    };
    conf.aid = @"99998";
    conf.channel = @"local_test";
    //conf.distArea = kBDDYCDeployAreaVA; // kBDDYCDeployAreaVA | kBDDYCDeployAreaCN | kBDDYCDeployAreaSG
    conf.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]; 
    conf.appBuildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [BDDYCMain startWithConfiguration:conf delegate:nil];
    
    
    BDDYCLogConfiguration *logConf = [BDDYCLogConfiguration new];
    logConf.enableModInitLog = YES;
    logConf.enablePrintLog   = YES;
    logConf.enableInstExecLog = YES;
    logConf.enableInstCallFrameLog = YES;
    [BDDYCMain sharedMain].logConf = logConf;
    
#endif
#endif
}

+ (void)loadAtPath:(NSString *)path;
{
#ifdef BDDYC_ENABLED
    
    [BDDYCMain loadFileAtPath:path];
    
#endif
}

+ (void)loadZipAtPath:(NSString *)zipPath
{
#ifdef BDDYC_ENABLED
    
    [BDDYCMain loadZipFileAtPath:zipPath];
    
#endif
}

@end



@implementation BDDYCClient (SchemeLaunch)

@end
