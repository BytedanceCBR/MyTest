//
//  TTAccountConfiguration+PlatformAccount.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 03/07/2017.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountConfiguration+PlatformAccount.h"
#import "TTAccountConfiguration_Priv+PlatformAccount.h"
#import "TTAccountPlatformConfiguration.h"
#import "TTAccountAuthLoginManager.h"
#import <objc/runtime.h>



@implementation TTAccountConfiguration (PlatformAccount)

#pragma mark - public methods

- (void)addPlatformConfiguration:(TTAccountPlatformConfiguration *)platformConf
{
    if (!platformConf) return;
    if (-1 == platformConf.platformType) {
        NSAssert(NO, @"TTAccountPlatformConfiguration.platformType must assign to target platform <ref:TTAccountAuthType>");
    }
    
    [self.platformConfigurations setValue:platformConf
                                   forKey:TTAccountEnumString(platformConf.platformType)];
    
    if (!platformConf.bootOptimization) {
        [TTAccountAuthLoginManager registerAppId:platformConf.consumerKey
                                     forPlatform:platformConf.platformType];
    }
}

- (void)addPlatformConfigurations:(NSArray<TTAccountPlatformConfiguration *> *)platformConfs
{
    if (!platformConfs || platformConfs.count == 0) return;
    [platformConfs enumerateObjectsUsingBlock:^(TTAccountPlatformConfiguration * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addPlatformConfiguration:obj];
    }];
}

#pragma mark - Getter/Setter

- (void)setPlatformConfigurations:(NSMutableDictionary<NSString *,TTAccountPlatformConfiguration *> *)confs
{
    objc_setAssociatedObject(self, @selector(platformConfigurations), confs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *,TTAccountPlatformConfiguration *> *)platformConfigurations
{
    NSMutableDictionary *confs = objc_getAssociatedObject(self, _cmd);
    if (!confs || ![confs isKindOfClass:[NSMutableDictionary class]]) {
        confs = [NSMutableDictionary dictionary];
        self.platformConfigurations = confs;
    }
    return confs;
}

- (void)setWapLoginConf:(TTAccountCustomLoginConfiguration *)conf
{
    objc_setAssociatedObject(self, @selector(wapLoginConf), conf, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTAccountCustomLoginConfiguration *)wapLoginConf
{
    TTAccountCustomLoginConfiguration *customWapLoginConf = objc_getAssociatedObject(self, _cmd);
    if (!customWapLoginConf) {
        customWapLoginConf = [TTAccountCustomLoginConfiguration new];
        [self setWapLoginConf:customWapLoginConf];
    }
    return customWapLoginConf;
}

@end
