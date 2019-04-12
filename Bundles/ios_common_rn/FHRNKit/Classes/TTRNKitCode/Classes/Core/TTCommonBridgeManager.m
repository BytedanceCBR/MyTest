//
//  TTCommonBridgeManager.m
//  TTRNKit
//
//  Created by renpeng on 2018/7/17.
//

#import "TTRNkitJSExceptionDelegate.h"
#import "TTCommonBridgeManager.h"
#import "TTRNKitBridgeModule.h"
#import "TTRNKitHelper.h"
#import "TTRNKitMacro.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <React/RCTExceptionsManager.h>
#import <React/RCTBridge+Private.h>
#import <React/RCTBridge.h>
#import <React/RCTUtils.h>
#import <objc/runtime.h>

static NSInteger maxBridgeCacheCount = 5;
static NSURL *_commonBundleUrl;
extern NSString *defaultBundleVersion;
extern NSInteger bundleVersionIndex;
extern NSInteger bundleNeedCombineIndex;
static void *kTTRNKitJSExceptionDelegate = &kTTRNKitJSExceptionDelegate;

@interface TTCommonBridgeInfo ()

@property (nonatomic, copy) dispatch_block_t commonBundleFinishLoading;
@property (nonatomic, strong) NSMutableArray *completionArr;

@end

@implementation TTCommonBridgeInfo

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bundleFinishiLoading:)
                                                     name:RCTJavaScriptDidLoadNotification
                                                   object:self.bridge];
    }
    return self;
}

- (void)bundleFinishiLoading:(NSNotification *)notification {
    if ([notification.userInfo.allValues containsObject:self.bridge.batchedBridge]) {
        if (self.bridge.batchedBridge.isValid) {
            self.jsDidLoad = YES;
            if (self.commonBundleFinishLoading) {
                self.commonBundleFinishLoading();
            }
            for (dispatch_block_t block in self.completionArr) {
                block();
            }
        }
        self.commonBundleFinishLoading = nil;
        [self.completionArr removeAllObjects];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enqueueJSDidLoadCompleiton:(dispatch_block_t)completion {
    if (!_completionArr) {
        _completionArr = [NSMutableArray array];
    }
    [_completionArr addObject:completion];
}

@end

static void setExceptionDelegateForRNBridge(RCTBridge *bridge, TTRNkitJSExceptionDelegate *delegate) {
    objc_setAssociatedObject(bridge, kTTRNKitJSExceptionDelegate, delegate, OBJC_ASSOCIATION_RETAIN);
}

static TTRNkitJSExceptionDelegate *getExceptionDelegateForRNBridge(id bridge) {
    if ([bridge isKindOfClass:[RCTCxxBridge class]]) {
        SEL sel = @selector(parentBridge);
        if ([bridge respondsToSelector:sel]) {
            bridge = [bridge performSelector:sel];
        }
    }
    return objc_getAssociatedObject(bridge, kTTRNKitJSExceptionDelegate);
}

@implementation TTCommonBridgeManager

+ (void)initManagerWithGeckoParams:(NSDictionary *)geckoParams {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _commonBundleUrl = [NSURL URLWithString:[geckoParams tt_stringValueForKey:TTRNKitCommonBundlePath]];
        [TTRNKitHelper initLRUList];
    });
}

+ (TTCommonBridgeInfo *)getBridgeInfoWithManager:(TTRNKit *)manager
                                       bundleUrl:(NSURL *)bundleUrl
                                         channel:(NSString *)channel
                                     preGenerate:(BOOL)generate
                                     geckoParams:(NSDictionary *)geckoParams {
    NSURL *url = bundleUrl ?: _commonBundleUrl;
    void (^generateCommonBridgeInfo)(TTRNKit *manager) = ^(TTRNKit *manager) {
        TTRNKitBridgeModule *rnKitBridgeModule = [[TTRNKitBridgeModule alloc] initWithBundleUrl:url];
        rnKitBridgeModule.geckoParams = geckoParams;
        [manager registerObserver:rnKitBridgeModule];
        RCTBridge *rctBridge = [[RCTBridge alloc] initWithDelegate:rnKitBridgeModule launchOptions:nil];
        RCTExceptionsManager *excepManager = [rctBridge moduleForName:@"ExceptionsManager"];
        TTRNkitJSExceptionDelegate *exceptionDelegate = [[TTRNkitJSExceptionDelegate alloc] initWithChannel:channel
                                                                                           bundleIdentifier:nil];
        [manager registerObserver:exceptionDelegate];
        setExceptionDelegateForRNBridge(rctBridge, exceptionDelegate);
        excepManager.delegate = exceptionDelegate;
        TTCommonBridgeInfo *info = [[TTCommonBridgeInfo alloc] init];
        info.bridge = rctBridge;
        info.bundleUrl = url;
        info.bridgeDelegate = rnKitBridgeModule;
        info.bundleIdentifier = @"";
        [TTRNKitHelper insertURL:url withValue:info useLRU:NO];
    };
    if (![TTRNKitHelper getValueForURL:url updateLRU:NO]) {
        generateCommonBridgeInfo(manager);
    }
    static BOOL generating = NO;
    if (generate && !generating) {
        dispatch_async(dispatch_get_main_queue(), ^{
            generateCommonBridgeInfo(manager);
            generating = NO;
        });
        generating = YES;
    }
    TTCommonBridgeInfo *bridgeInfo = [TTRNKitHelper getValueForURL:url updateLRU:NO];
    [TTRNKitHelper deleteURL:url];
    return bridgeInfo;
}

+ (NSString *)bundleIdentifierForGeckoParams:(NSDictionary *)geckoParams
                                     channel:(NSString *)channel {
    NSURL *bundleUrl = bundleUrlForGeckoParams(geckoParams, channel);
    NSArray *bundleInfo = geckoBundleInfoForGeckoParams(geckoParams, channel);
    NSString *bundleVersion = bundleInfo.count ? bundleInfo[bundleVersionIndex] : @"";
    NSString *bundleIdentifier = bundleIdentifierWithBundlePathAndVersion([bundleUrl absoluteString],
                                                                          bundleVersion);
    return bundleIdentifier;
}

+ (TTCommonBridgeInfo *)generateCombineBridgeForGeckoParams:(NSDictionary *)geckoParams
                                                    manager:(TTRNKit *)manager
                                                    channel:(NSString *)channel {
    NSURL *bundleUrl = bundleUrlForGeckoParams(geckoParams, channel);
    //会保证有默认值
    NSArray *bundleInfo = geckoBundleInfoForGeckoParams(geckoParams, channel);
    NSString *bundleVersion = bundleInfo.count ? bundleInfo[bundleVersionIndex] : @"";
    NSString *bundleIdentifier = bundleIdentifierWithBundlePathAndVersion([bundleUrl absoluteString],
                                                                          bundleVersion);
    TTCommonBridgeInfo *bridgeInfo;
    NSString *commonBundleVersion = commonBundleVersionForGeckoParams(geckoParams);
    if ([[NSFileManager defaultManager] fileExistsAtPath:bundleUrl.absoluteString]
        && ![bundleVersion hasSuffix:defaultBundleVersion] //说明存在manifest文件且有版本信息
        && [bundleVersion isEqualToString:commonBundleVersion]
        && ![bundleInfo[bundleNeedCombineIndex] boolValue]) { //业务包不完整
        NSData *bundleData = [NSData dataWithContentsOfFile:bundleUrl.absoluteString ?: @""];
#ifdef DEBUG
        if (!bundleData ) {
            bundleData = [NSData dataWithContentsOfURL:bundleUrl];
        }
#endif
        bridgeInfo = [self getBridgeInfoWithManager:manager
                                                bundleUrl:_commonBundleUrl
                                            channel:channel
                                              preGenerate:YES
                                              geckoParams:geckoParams];
        SEL sel = NSSelectorFromString(@"executeApplicationScript:url:async:");
        __weak typeof (bridgeInfo) wBridgeInfo = bridgeInfo;
        dispatch_block_t block = ^() {
            if ([wBridgeInfo.bridge.batchedBridge respondsToSelector:sel]) {
                NSMethodSignature *signature = [[wBridgeInfo.bridge.batchedBridge class] instanceMethodSignatureForSelector:sel];
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                [invocation setTarget:wBridgeInfo.bridge.batchedBridge];
                [invocation setSelector:sel];
                [invocation setArgument:(void *)&bundleData atIndex:2];
                [invocation setArgument:(void *)&bundleUrl atIndex:3];
                BOOL async = YES;
                [invocation setArgument:&async atIndex:4];
                [invocation invoke];
            }
        };
        bridgeInfo.commonBundleFinishLoading = block;
        [TTRNKitHelper insertURL:bundleUrl withValue:bridgeInfo useLRU:YES];
    } else {
        //此分支走的是不合包的逻辑
        bridgeInfo = [self getBridgeInfoWithManager:manager
                                          bundleUrl:bundleUrl
                                            channel:channel
                                        preGenerate:NO
                                        geckoParams:geckoParams];
        [TTRNKitHelper insertURL:bundleUrl withValue:bridgeInfo useLRU:YES];
    }
    bridgeInfo.bundleUrl = bundleUrl;
    bridgeInfo.bundleIdentifier = bundleIdentifier;
    bridgeInfo.channel = channel;
    [TTRNKitHelper trimToCount:maxBridgeCacheCount];
    return bridgeInfo;
}

#pragma mark - public API
+ (TTCommonBridgeInfo *)webBridgeInfoWithManager:(TTRNKit *)manager
                                         channel:(NSString *)channel {
    TTCommonBridgeInfo *info = [[TTCommonBridgeInfo alloc] init];
    TTRNKitBridgeModule *module = [[TTRNKitBridgeModule alloc] initWithBundleUrl:nil];
    [manager registerObserver:module];
    info.bridgeDelegate = module;
    info.channel = channel;
    return info;
}

+ (TTCommonBridgeInfo *)bridgeWithGeckoParams:(NSDictionary *)geckoParams
                                      manager:(TTRNKit *)manager
                                      channel:(NSString *)channel {
    [self initManagerWithGeckoParams:geckoParams];
    NSURL *bundleUrl = bundleUrlForGeckoParams(geckoParams, channel);
    if (!bundleUrl.absoluteString.length) { //为了修复web的bridge问题
        return nil;
    }
    TTCommonBridgeInfo *bridgeInfo = [TTRNKitHelper getValueForURL:bundleUrl updateLRU:YES] ?:
    [self generateCombineBridgeForGeckoParams:geckoParams
                                      manager:manager
                                      channel:channel];
    [(TTRNKitBridgeModule*)bridgeInfo.bridgeDelegate setManager:manager];
    return bridgeInfo;
}

+ (TTRNkitJSExceptionDelegate *)getExceptionDelegateForRNBridge:(id)bridge {
    return getExceptionDelegateForRNBridge(bridge);
}

+ (void)removeBridgeForChannel:(NSString *)channel geckoParams:(NSDictionary *)geckoParams {
    NSURL *bundleUrl = bundleUrlForGeckoParams(geckoParams, channel);
    [TTRNKitHelper deleteURL:bundleUrl];
}

@end
