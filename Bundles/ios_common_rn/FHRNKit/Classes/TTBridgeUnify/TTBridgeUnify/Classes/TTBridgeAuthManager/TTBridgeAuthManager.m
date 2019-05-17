//
//  TTBridgeAuthManager.m
//  BridgeUnifyDemo
//
//  Created by renpeng on 2018/10/9.
//  Copyright © 2018年 tt. All rights reserved.
//

#import "TTBridgeAuthManager.h"
#import "TTBridgeForwarding.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTBridgeRegister.h"

static NSString *kRemoteInnerDomainsKey = @"kRemoteInnerDomainsKey";

@interface TTBridgeAuthInfo : NSObject

@property(nonatomic, copy) NSArray *methodList;
@property(nonatomic, copy) NSArray *metaList;

@end

@implementation TTBridgeAuthInfo

@end

@interface TTBridgeAuthManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString*, TTBridgeAuthInfo*> *friendDomainMethods;
@property (nonatomic, copy) NSArray<NSString*> *remoteInnerDomains;
@property (nonatomic, copy) NSArray<NSString*> *innerDomains;

@end

@implementation TTBridgeAuthManager

static TTBridgeAuthManager *s = nil;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[super allocWithZone:NULL] init];
    });
    return s;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _authEnabled = YES;
        _friendDomainMethods = [NSMutableDictionary dictionary];
        _remoteInnerDomains = [[NSUserDefaults standardUserDefaults] arrayForKey:kRemoteInnerDomainsKey];
        _innerDomains = @[@"toutiao.com",      // 头条
                          @"toutiaopage.com",  // 头条
                          @"snssdk.com",       // 头条
                          @"neihanshequ.com",  // 内涵
                          @"youdianyisi.com",  // 内涵
                          @"huoshanzhibo.com", // 火山
                          @"huoshan.com",      //火山
                          @"wukong.com",        //悟空
                          @"zjurl.cn"];
    }
    return self;
}

#pragma mark - TTBridgeAuthorization

+ (BOOL)hasAuthForCommand:(TTBridgeCommand *)command
                   engine:(id<TTBridgeEngine>)engine
                   domain:(NSString *)domain {
    //如果是RN，判断资源渠道
    if (engine.engineType == TTBridgeRegisterRN) {
        __auto_type paths = [engine.sourceURL pathComponents];
        __auto_type channel = @"";
        if (paths.count >= 2) {
            channel = paths[paths.count - 2];
        }
        return [channel rangeOfString:@"external_"].location != 0;
    }
    NSString *aliasName = [[TTBridgeForwarding sharedInstance] aliasForOrig:command.origName];
    TTBridgeMethodInfo *methodInfo = [[TTBridgeRegister sharedRegister].registedMethods objectForKey:command.origName] ?:
    [[TTBridgeRegister sharedRegister].registedMethods objectForKey:aliasName];
    NSInteger authType = [[methodInfo.authTypes objectForKey:@([engine engineType])] integerValue];
    if (TTBridgeAuthPublic == authType) {//方法的权限为公共，则所有域名都可以使用
        return YES;
    }
    NSDictionary<NSString*, TTBridgeAuthInfo*> *friendDomainMethods;
    @synchronized ([TTBridgeAuthManager sharedManager].friendDomainMethods) {
        friendDomainMethods = [[TTBridgeAuthManager sharedManager].friendDomainMethods copy];
    }
    if (domain.length) {
        if (TTBridgeAuthPrivate == authType) { //私有方法仅供特定域名使用
            NSMutableArray *methodsUnderDomain = [TTBridgeRegister sharedRegister].domain2PrivateMethods[domain];
            return [methodsUnderDomain containsObject:command.origName]
            || [methodsUnderDomain containsObject:aliasName];
        } else if ([self isInnerDomain:domain]//若不为公共方法，白名单的域名也可以使用protected方法
                   || ([[friendDomainMethods valueForKey:domain].methodList containsObject:command.origName]
                       || [[friendDomainMethods valueForKey:domain].methodList containsObject:aliasName]) //合作方可以使用该方法
                   ) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)engine:(id<TTBridgeEngine>)engine isAuthorizedBridge:(TTBridgeCommand *)command domain:(NSString *)domain {
    return self.authEnabled ? [[self class] hasAuthForCommand:command engine:engine domain:domain] : YES;
}

- (void)engine:(id<TTBridgeEngine>)engine isAuthorizedBridge:(TTBridgeCommand *)command domain:(NSString *)domain completion:(void (^)(BOOL success))completion {
    if (completion) {
        completion(self.authEnabled ? [[self class] hasAuthForCommand:command engine:engine domain:domain] : YES);
    }
}

- (BOOL)engine:(id<TTBridgeEngine>)engine isAuthorizedMeta:(NSString *)meta domain:(NSString *)domain {
    if (!self.authEnabled) {
        return YES;
    }
    
    if (engine.engineType == TTBridgeRegisterRN) {
        __auto_type paths = [engine.sourceURL pathComponents];
        __auto_type channel = @"";
        if (paths.count >= 2) {
            channel = paths[paths.count - 2];
        }
        return [channel rangeOfString:@"external_"].location != 0;
    }
    
    if ([self.class isInnerDomain:domain]) {
        return YES;
    }
    
    TTBridgeAuthInfo *authInfoModel;
    @synchronized (self.friendDomainMethods) {
       authInfoModel = [self.friendDomainMethods objectForKey:domain];
    }
    
    if (!authInfoModel) {
        return NO;
    }
    
    if ([authInfoModel.metaList containsObject:meta]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)authEnabled {
    return _authEnabled;
}

#pragma mark - Auth Update
- (void)startGetAuthConfigWithPartnerClientKey:(NSString*)clientKey
                                 partnerDomain:(NSString*)domain
                                     secretKey:(NSString*)secretKey
                                   finishBlock:(void(^)(BOOL success))finishBlock
{
    void(^finish)(BOOL) = ^(BOOL success) {
        if (finishBlock) {
            finishBlock(success);
        }
    };
    if (!domain.length) {
        return finish(NO);
    }
    
    NSDictionary<NSString*, TTBridgeAuthInfo*> *friendDomainMethods;
    @synchronized ([TTBridgeAuthManager sharedManager].friendDomainMethods) {
        friendDomainMethods = [[TTBridgeAuthManager sharedManager].friendDomainMethods copy];
    }
    if ([friendDomainMethods objectForKey:domain]) {
        return finish(YES);
    }
    NSMutableDictionary * getParam = [NSMutableDictionary dictionary];
    [getParam setValue:clientKey forKey:@"client_id"];
    [getParam setValue:domain forKey:@"partner_domain"];
    
    static NSString *hostDomain = @"ib.snssdk.com";
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[hostDomain stringByAppendingString:@"/client_auth/js_sdk/config/v1/"] params:getParam method:@"GET" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
        if (error) {
            return finish(NO);
        }
        
        NSDictionary *data = jsonObj[@"data"];
            
        TTBridgeAuthInfo *infoModel = [[TTBridgeAuthInfo alloc] init];
        NSMutableArray *methodList = [NSMutableArray array];
        if ([data[@"call"] isKindOfClass:[NSArray class]]) {
            [methodList addObjectsFromArray:data[@"call"]];
        }
        if ([data[@"event"] isKindOfClass:[NSArray class]]) {
            [methodList addObjectsFromArray:data[@"event"]];
        }
        infoModel.methodList = methodList;
        infoModel.metaList = data[@"info"];
        @synchronized (self.friendDomainMethods) {
            [self.friendDomainMethods setValue:infoModel forKey:domain];
        }
        return finish(YES);
    }];
}
     
+ (BOOL)isInnerDomain:(NSString *)host {
    
    for(NSString *innerDomain in [TTBridgeAuthManager sharedManager].innerDomains) {
        if([host rangeOfString:[innerDomain lowercaseString]].location != NSNotFound) {
            return YES;
        }
    }

    NSArray<NSString*> *remoteInnerDomains;
    @synchronized (self) {
        remoteInnerDomains = [TTBridgeAuthManager sharedManager].remoteInnerDomains;
    }
    for(NSString *innerDomain in remoteInnerDomains) {
        if([host rangeOfString:[innerDomain lowercaseString]].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
 }
 
 - (void)updateInnerDomainsFromRemote:(NSArray<NSString *> *)domains {
     if (![domains isKindOfClass:[NSArray class]]) {
         return;
     }
     @synchronized (self) {
         _remoteInnerDomains = domains;
         [[NSUserDefaults standardUserDefaults] setValue:_remoteInnerDomains forKey:kRemoteInnerDomainsKey];
     }
 }

 
 @end
