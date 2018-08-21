//
//  TTWebviewAntiHijackServerConfig.m
//  Article
//
//  Created by gaohaidong on 8/22/16.
//
//

#import "TTWebviewAntiHijackServerConfig.h"
#import "Singleton.h"
#import "TTPersistence.h"
#import "TTNetworkManager.h"
#import "NetworkUtilities.h"

#import "TTWebviewAntiHijackManager.h"

static NSString *const kTTWebviewAntiHijackServerConfigCacheName = @"com.newsArticle.TTWebviewAntiHijackServerConfig";

static NSString *const kTTWebviewAntiHijackLastGetBlackListTimeKey = @"kTTWebviewAntiHijackLastGetBlackListTimeKey";

static NSString *const kTTWebviewAntiHijackBlackListDicKey = @"kTTWebviewAntiHijackBlackListDicKey";

static NSString *const kTTWebviewAntiHijackServerConfigRefreshIntervalKey = @"hijack_intercept_refresh_interval";
static NSString *const kTTWebviewAntiHijackServerConfigEnabledKey = @"hijack_intercept_enable";

static const NSTimeInterval kTTWebviewAntiHijackServerConfigRefreshIntervalDefault = 60.f * 60 * 12; // 12 hours

static NSString *const kTTWebviewAntiHijackBlackListURL = @"https://dm.toutiao.com/get_blacklist/";

static NSString *const kTTWebviewAntiHijackLastSendFeedbackLogTimeKey = @"kTTWebviewAntiHijackLastSendFeedbackLogTimeKey";

@interface TTWebviewAntiHijackServerConfig ()

@property (atomic, readwrite) BOOL isEnabled;
@property (atomic, assign) NSUInteger refreshInterval;
@property (atomic, strong) NSDate *lastGetBlackListTime;

@property (atomic, assign) BOOL isProcessing;
@property (atomic, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *blackListDic;

@property (nonatomic, strong) NSDate *lastSendFeedbackLogTime; // except the init, accessed in on thread

@end

@implementation TTWebviewAntiHijackServerConfig

#pragma mark - life cycle

SINGLETON_GCD(TTWebviewAntiHijackServerConfig);

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.isEnabled = [[[self.class cache_] valueForKey:kTTWebviewAntiHijackServerConfigEnabledKey] boolValue];
        
        self.refreshInterval = [[[self.class cache_] valueForKey:kTTWebviewAntiHijackServerConfigRefreshIntervalKey] unsignedIntegerValue];
        if (self.refreshInterval == 0) {
            self.refreshInterval = kTTWebviewAntiHijackServerConfigRefreshIntervalDefault;
        }
        
        self.lastGetBlackListTime = [[self.class cache_] valueForKey:kTTWebviewAntiHijackLastGetBlackListTimeKey];
        if (! [self.lastGetBlackListTime isKindOfClass:NSDate.class]) {
            self.lastGetBlackListTime = nil;
        }
        
        self.lastSendFeedbackLogTime = [[self.class cache_] valueForKey:kTTWebviewAntiHijackLastSendFeedbackLogTimeKey];
        if (! [self.lastSendFeedbackLogTime isKindOfClass:NSDate.class]) {
            self.lastSendFeedbackLogTime = nil;
        }
        
        self.blackListDic = [[self.class cache_] valueForKey:kTTWebviewAntiHijackBlackListDicKey];
        if (! [self.blackListDic isKindOfClass:NSDictionary.class]) {
            self.blackListDic = nil;
        }
        
        // test url
//        self.blackListDic[@"a3.pstatp.com"] = [[NSArray alloc] init];
        
        if (self.isEnabled) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
                
                [self tryGetBlackListAsync_];
                
                [TTWebviewAntiHijackManager startWebviewAntiHijack];
            });
        }
        
    }
    return self;
}

- (void)dealloc {
    [self removeObservers_];
}

#pragma mark - public APIs

- (void)updateServerConfig:(NSDictionary *)serverData {
    ENTER;
    
    BOOL isEnabled = [serverData tt_boolValueForKey:kTTWebviewAntiHijackServerConfigEnabledKey];

    LOGI(@"hijack_intercept_enable = %d", isEnabled);
    
    BOOL needSave = NO;
    
    if (self.isEnabled != isEnabled) {
        self.isEnabled = isEnabled;
        
        [[self.class cache_] setValue:@(self.isEnabled) forKey:kTTWebviewAntiHijackServerConfigEnabledKey];
        needSave = YES;
        
        if (self.isEnabled) {

            [self addObservers_];
        } else {
            [TTWebviewAntiHijackManager stopWebviewAntiHijack];
        }
    }
    
    NSUInteger refreshInterval = [serverData tt_unsignedIntegerValueForKey:kTTWebviewAntiHijackServerConfigRefreshIntervalKey];
    if (refreshInterval > 0 && self.refreshInterval != refreshInterval) {
        self.refreshInterval = refreshInterval;
        
        [[self.class cache_] setValue:@(self.refreshInterval) forKey:kTTWebviewAntiHijackServerConfigRefreshIntervalKey];
        needSave = YES;
    }
    
    if (needSave) {
        [[self.class cache_] save];
    }
}

- (BOOL)isInBlackList:(NSURL *)url {
    
    NSString *host = [url host];
    
    NSArray *paths = self.blackListDic[host];
    if (paths) {
        if (paths.count > 0) {
            for (NSString *path in paths) {
                NSString *fullPath = [NSString stringWithFormat:@"%@%@", host, path];
                
                if ([url.absoluteString.lowercaseString rangeOfString:fullPath.lowercaseString].location != NSNotFound) {
                    
                    [self sendFeedbackLogAsync_:host path:path requestURL:url];
                    return YES;
                }
            }
        } else {
            [self sendFeedbackLogAsync_:host path:nil requestURL:url];
            return YES;
        }
    }
    
    NSString *hostAndPort = [NSString stringWithFormat:@"%@:%@", host, [url port]];
    paths = self.blackListDic[hostAndPort];
    
    if (paths) {
        if (paths.count > 0) {
            for (NSString *path in paths) {
                NSString *fullPath = [NSString stringWithFormat:@"%@%@", hostAndPort, path];
                
                if ([url.absoluteString.lowercaseString rangeOfString:fullPath.lowercaseString].location != NSNotFound) {
                    [self sendFeedbackLogAsync_:host path:path requestURL:url];
                    return YES;
                }
            }
        } else {
            [self sendFeedbackLogAsync_:host path:nil requestURL:url];
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - private functions

+ (TTPersistence *)cache_ {
    return [TTPersistence persistenceWithName:kTTWebviewAntiHijackServerConfigCacheName];
}

- (void)addObservers_ {
    // app state
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onAppDidBecomeActive_:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}

- (void)removeObservers_ {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onAppDidBecomeActive_:(NSNotification *)notification {
    [self tryGetBlackListAsync_];
}

/*
 {
 data =     (
 {
 host = "wap.zjtoolbarc60.10086.cn:808";
 paths =             (
 );
 },
 {
 host = "js.users.51.la";
 paths =             (
 );
 },
 
 {
 host = "49.117.145.146:888";
 paths =             (
 );
 },
 {
 host = "gd.189.cn";
 paths =             (
 "/TS/kd/push/public/pushjs/embed_mobile_V1.js",
 "/TS/kd/push/public/pushjs/embed_mobile_V2.js"
 );
 }
 );
 message = success;
 }
 */

- (void)tryGetBlackListAsync_ {
    
    if (!self.isEnabled) {
        return;
    }
    
    if (!TTNetworkConnected()) {
        LOGW(@"network is down, skip");
        return;
    }
    
    NSDate *now = [NSDate date];
    
    NSTimeInterval interval = [now timeIntervalSinceDate:self.lastGetBlackListTime];
    
    if (interval < self.refreshInterval) {
        return;
    }
    
    if (self.isProcessing) {
        return;
    }
    
    ENTER;
    
    __weak typeof(self) wself = self;
    
    self.isProcessing = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        
        [[TTNetworkManager shareInstance] requestForJSONWithURL:kTTWebviewAntiHijackBlackListURL params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
            if (!error) {
                @try {
                    NSString *success = [jsonObj objectForKey:@"message"];
                    
                    if ([success isEqualToString:@"success"] && [[jsonObj objectForKey:@"data"] isKindOfClass:NSArray.class]) {
                        
                        NSArray *data = [jsonObj objectForKey:@"data"];
                        
                        
                        NSMutableDictionary<NSString *, NSArray<NSString *> *> *blackListDic = [[NSMutableDictionary alloc] init];
                        
                        for (NSDictionary *dict in data) {
                            if ([dict isKindOfClass:NSDictionary.class]) {
                                blackListDic[dict[@"host"]] = dict[@"paths"];
                            }
                        }
                        
                        wself.blackListDic = blackListDic;
                        wself.lastGetBlackListTime = [NSDate date];
                        
                        [[TTWebviewAntiHijackServerConfig cache_] setValue:wself.lastGetBlackListTime forKey:kTTWebviewAntiHijackLastGetBlackListTimeKey];
                        
                        [[TTWebviewAntiHijackServerConfig cache_] setValue:blackListDic forKey:kTTWebviewAntiHijackBlackListDicKey];
                        
                        [[TTWebviewAntiHijackServerConfig cache_] save];
                    } else {
                        LOGW(@"get wrong black list response! repsonse = %@", jsonObj);
                    }
                }
                @catch (NSException *exception) {
                    LOGW(@"exception in parsing json, repsonse = %@, exception = %@", jsonObj, exception);
                }
                @finally {
                    
                }
            } else {
                LOGW(@"fail to get the black list! error = %@", error);
            }
            
            wself.isProcessing = NO;
        }];
         
    });
    
}

#pragma mark feedback log

- (void)sendFeedbackLogAsync_:(NSString *)host path:(NSString *)path requestURL:(NSURL *)requestURL {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setValue:host forKey:@"host"];
        
        if (path) {
            [dict setValue:path forKey:@"path"];
        }
        [dict setValue:requestURL.absoluteString forKey:@"url"];
        
        [[TTMonitor shareManager] trackData:dict logTypeStr:@"ss_hijack_intercept"];
        
        LOGD(@"send feedback log = %@", dict);
        
        NSDate *now = [NSDate date];
        NSTimeInterval interval = [now timeIntervalSinceDate:self.lastSendFeedbackLogTime];
        
        if (interval >= 60 * 60 * 24) {
            [[TTMonitor shareManager] event:@"ss_hijack_intercept" label:@"user_count" count:1 needAggregate:NO];
            
            [[TTWebviewAntiHijackServerConfig cache_] setValue:now forKey:kTTWebviewAntiHijackLastSendFeedbackLogTimeKey];
            
            [[TTWebviewAntiHijackServerConfig cache_] save];
            
            self.lastSendFeedbackLogTime = now;
        }
        
        [[TTMonitor shareManager] event:@"ss_hijack_intercept" label:@"total_count" count:1 needAggregate:NO];
    });
    
}

@end
