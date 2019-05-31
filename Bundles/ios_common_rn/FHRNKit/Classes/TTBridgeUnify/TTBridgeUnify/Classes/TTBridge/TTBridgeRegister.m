//
//  TTBridgeRegister.m
//  DoubleConversion
//
//  Created by 李琢鹏 on 2018/10/24.
//

#import "TTBridgeRegister.h"
#import "TTBridgeForwarding.h"
#import "TTBridgeCommand.h"
#import "BDAssert.h"

void TTRegisterBridge(TTBridgeRegisterEngineType engineType,
                      NSString *nativeName,
                      TTBridgeName bridgeName,
                      TTBridgeAuthType authType,
                      NSArray<NSString *> *domains) {
    [[TTBridgeForwarding sharedInstance] registerAlias:nativeName for:bridgeName];
    [[TTBridgeRegister sharedRegister] registerMethod:bridgeName
                                           engineType:engineType
                                             authType:authType
                                              domains:domains];
    
}

void TTRegisterWebViewBridge(NSString *nativeName, TTBridgeName bridgeName) {
    TTRegisterBridge(TTBridgeRegisterWebView, nativeName, bridgeName, TTBridgeAuthProtected, nil);
}

void TTRegisterRNBridge(NSString *nativeName, TTBridgeName bridgeName) {
    TTRegisterBridge(TTBridgeRegisterRN, nativeName, bridgeName, TTBridgeAuthProtected, nil);
}

void TTRegisterAllBridge(NSString *nativeName, TTBridgeName bridgeName) {
    TTRegisterBridge(TTBridgeRegisterAll, nativeName, bridgeName, TTBridgeAuthProtected, nil);
}

static NSString *kRemoteInnerDomainsKey = @"kRemoteInnerDomainsKey";

@interface TTBridgeMethodInfo()
{
    NSMutableDictionary<NSNumber*, NSNumber*> *_authTypeMDic;
}

- (instancetype)initWithEngineType:(TTBridgeRegisterEngineType)engineType
                          authType:(TTBridgeAuthType)authType;

- (void)registerWithEngineType:(TTBridgeRegisterEngineType)engineType
                      authType:(TTBridgeAuthType)authType;

@end

@implementation TTBridgeMethodInfo

- (instancetype)initWithEngineType:(TTBridgeRegisterEngineType)engineType
                          authType:(TTBridgeAuthType)authType {
    if (self = [super init]) {
        _authTypeMDic = [NSMutableDictionary dictionary];
        [self registerWithEngineType:engineType authType:authType];
    }
    return self;
}

- (void)registerWithEngineType:(TTBridgeRegisterEngineType)engineType
                      authType:(TTBridgeAuthType)authType {
    
    void(^registerBlock)(TTBridgeRegisterEngineType) = ^(TTBridgeRegisterEngineType engineType) {
        NSNumber *key = @(engineType);
        if (self->_authTypeMDic[key]) {
            BDAssert(NO, @"重复注册 Brigde");
            return;
        }
        self->_authTypeMDic[key] = @(authType);
    };
    if (engineType & TTBridgeRegisterRN) {
        registerBlock(TTBridgeRegisterRN);
    }
    if (engineType & TTBridgeRegisterWebView) {
        registerBlock(TTBridgeRegisterWebView);
    }
}

- (NSDictionary<NSNumber *,NSNumber *> *)authTypes {
    return [_authTypeMDic copy];
}

@end

@interface TTBridgeRegister ()
{
    NSMutableDictionary<NSString*, TTBridgeMethodInfo*> *_methodDic;  //保存所有注册的方法权限信息 method -> authInfo
    NSMutableDictionary<NSString*, NSMutableArray*> *_domain2PrivateMethods;   //private 方法的列表 domain -> methods
}

@end

@implementation TTBridgeRegister

+ (instancetype)sharedRegister {
    static TTBridgeRegister *s = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[TTBridgeRegister alloc] init];
    });
    return s;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _methodDic = [NSMutableDictionary dictionary];
        _domain2PrivateMethods = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerMethod:(NSString *)bridgeName
            engineType:(TTBridgeRegisterEngineType)engineType
              authType:(TTBridgeAuthType)authType
               domains:(NSArray<NSString *> *)domains {
    
    if (bridgeName.length) {
        BDAssert((domains.count > 0 && TTBridgeAuthPrivate == authType)
                 || 0 == domains.count , @"限定域名的方法必须为private");
        @synchronized (_methodDic) {
            TTBridgeMethodInfo *methodInfo = [_methodDic valueForKey:bridgeName];
            if (methodInfo) {
                [methodInfo registerWithEngineType:engineType authType:authType];
            } else {
                methodInfo = [[TTBridgeMethodInfo alloc] initWithEngineType:engineType authType:authType];
                [_methodDic setValue:methodInfo forKey:bridgeName];
            }
        }
        
        @synchronized (_domain2PrivateMethods) {
            for (NSString *domain in domains) {
                NSMutableArray *methodsUnderDomain = [_domain2PrivateMethods valueForKey:domain];
                if (!methodsUnderDomain) {
                    methodsUnderDomain = [NSMutableArray array];
                    [_domain2PrivateMethods setValue:methodsUnderDomain forKey:domain];
                }
                [methodsUnderDomain addObject:bridgeName];
            }
        }
    }
}

- (NSDictionary<NSString *,TTBridgeMethodInfo *> *)registedMethods {
    NSDictionary *methodDic;
    @synchronized (_methodDic) {
        methodDic = [_methodDic copy];
    }
    return methodDic;
}

- (NSDictionary<NSString *,NSMutableArray *> *)domain2PrivateMethods {
    NSDictionary<NSString*, NSMutableArray*> *domain2PrivateMethods;
    @synchronized (_domain2PrivateMethods) {
        domain2PrivateMethods = [_domain2PrivateMethods copy];
    }
    return domain2PrivateMethods;
}

- (BOOL)bridgeHasRegistered:(TTBridgeName)bridgeName {
    TTBridgeMethodInfo *methodInfo = nil;
    @synchronized (_methodDic) {
        methodInfo = [_methodDic valueForKey:bridgeName];
    }
    return methodInfo != nil;
}

@end
