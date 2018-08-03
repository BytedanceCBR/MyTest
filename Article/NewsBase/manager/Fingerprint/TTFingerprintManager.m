//
//  TTFingerprintManager.m
//  Article
//
//  Created by fengyadong on 2017/10/29.
//

#import "TTFingerprintManager.h"
#import <TTInstallService/TTInstallIDManager.h>
#import <TTInstallService/TTInstallKeychain.h>
#import <TTTracker/TTTrackerUtil.h>
#import <TTInstallService/TTInstallReachability.h>
#import <TTInstallService/TTInstallUtil.h>
#import <TTInstallService/TTInstallNetworkUtilities.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTNetworkManager/TTHTTPResponseSerializerBase.h>
#import "SmAntiFraud.h"
#import "SSCommonLogic.h"
#import "TTFingerprintRequestSerializer.h"
#import "NSDictionary+TTInstallAdditions.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <pthread.h>

static NSString *const kTTFingerprintStoragekey = @"kTTFingerprintStoragekey";
static NSString *const kTTFingerprintLastSuccessTS = @"kTTFingerprintLastSuccessTS";
static NSUInteger kTTFingerprintFetchInterval = 60 * 60 * 24;//24h

@interface TTFingerprintManager () {
    BOOL _hasObserveNetworkChange;
    NSRecursiveLock* _didFetchlock;/*保证是否已获取这个标志线程安全*/
    pthread_mutex_t _blockslock;/*保证回调数组的线程安全*/
    NSMutableArray<TTFingerprintFetchBlock> *_blocksArray;/*回调数组*/
}

@property (nonatomic, copy, readwrite) NSString *fingerprint;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

@end

@implementation TTFingerprintManager

@synthesize fingerprint = _fingerprint;

+ (instancetype)sharedInstance {
    static TTFingerprintManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTFingerprintManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        _hasObserveNetworkChange = NO;
        _bgTask = UIBackgroundTaskInvalid;
        _didFetchlock = [[NSRecursiveLock alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            TTInstallNetworkStartNotifier();
        });
        pthread_mutex_init(&_blockslock, NULL);
        _blocksArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Method

- (void)startFetchFingerprintIfNeeded {
    NSTimeInterval lastFetchTimeStamp = [[NSUserDefaults standardUserDefaults] doubleForKey:kTTFingerprintLastSuccessTS];
    NSDictionary *collectInfo = [[TTSettingsManager sharedManager] settingForKey:@"tt_device_info_collect_controller" defaultValue:@{@"device_info_switch":@(1),@"sensitive":@{@"name":@(1),@"ssid":@(1),@"bssid":@(1)}} freeze:NO];
    BOOL enabeld = [collectInfo tt_boolValueForKey:@"device_info_switch"];
    //24h内接口只发一次
    if (enabeld && [[NSDate date] timeIntervalSince1970] - lastFetchTimeStamp > kTTFingerprintFetchInterval) {
        [self startFetchWithMaxTimes:3];
    }
}

- (void)setDidFetchFingerprintBlock:(TTFingerprintFetchBlock)didFetchBlock {
    [self addFetchFingerprintBlockIfNeeded:didFetchBlock];
}

#pragma mark - Private Method

/**
 回调数组中添加一个代码块
 
 @param didRegisterBlock 回调代码块
 */
- (void)addFetchFingerprintBlockIfNeeded:(TTFingerprintFetchBlock)didFetchBlock {
    if (didFetchBlock) {
        //已经注册则立马返回，否则加入到回调数组中
        if ([self hasFecthed]) {
            didFetchBlock(self.fingerprint);
        } else {
            if (didFetchBlock) {
                pthread_mutex_lock(&_blockslock);
                [_blocksArray addObject:[didFetchBlock copy]];
                pthread_mutex_unlock(&_blockslock);
            }
        }
    }
}

- (void)startFetchIfNeededWithRetryTimes:(NSInteger)retryTimes {
    if (![self hasFecthed]) {
        [self startFetchWithMaxTimes:retryTimes];
    }
}

- (NSDictionary *)generatedPostBody {
    NSMutableDictionary *postBody = [NSMutableDictionary dictionary];
    [postBody setValue:@"ios" forKey:@"platform"];
    [postBody setValue:@([TTInstallIDManager sharedInstance].appID.longLongValue) forKey:@"aid"];
    [postBody setValue:[TTInstallIDManager sharedInstance].deviceID forKey:@"did"];
    [postBody setValue:self.fingerprint ?: @"" forKey:@"fingerprint"];
    
    NSDictionary *collectInfo = [[TTSettingsManager sharedManager] settingForKey:@"tt_device_info_collect_controller" defaultValue:@{@"device_info_switch":@(1),@"sensitive":@{@"name":@(1),@"ssid":@(1),@"bssid":@(1)}} freeze:NO];
    [postBody setValue:[[SmAntiFraud shareInstance] getDeviceInfoWithConfiguration:collectInfo] forKey:@"device_info"];
    
    return [postBody copy];
}

- (void)saveFingerprint:(NSDictionary *)responseDict maxRetryTimes:(NSInteger)retryTimes {
    NSInteger erroNo = [responseDict tt_integerValueForKey:@"errno"];
    if (!TTInstallIsEmptyDictionary(responseDict) && erroNo == 0) {
        // 更新installID
        NSDictionary *data = [responseDict ttInstall_dictionaryValueForKey:@"data"];
        NSString *fingerprint = [data ttInstall_stringValueForKey:@"fingerprint"];
        if(!TTInstallIsEmptyString(fingerprint)) {
            self.fingerprint = fingerprint;
            [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kTTFingerprintLastSuccessTS];
        }
    }
    
    if(![self hasFecthed]) {
        if (!_hasObserveNetworkChange && !TTInstallNetworkConnected()) {
            _hasObserveNetworkChange = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kTTInstallReachabilityChangedNotification object:nil];
        }
        // continue
        if (retryTimes-- <= 0) {
            return;
        }
        if (![self hasFecthed]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startFetchWithMaxTimes:retryTimes];
            });
        }
    } else {
        if (!TTInstallIsEmptyArray(_blocksArray)) {
            [_blocksArray enumerateObjectsUsingBlock:^(TTFingerprintFetchBlock  _Nonnull finshBlock, NSUInteger idx, BOOL * _Nonnull stop) {
                finshBlock(self.fingerprint);
            }];
            
            pthread_mutex_lock(&_blockslock);
            [_blocksArray removeAllObjects];
            pthread_mutex_unlock(&_blockslock);
        }
        [self invalidBgTaskIfNeeded];
    }
}

- (void)startFetchWithMaxTimes:(NSInteger)maxTimes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *postParams = [self generatedPostBody];
        
        NSString *URLString = [[self class] getDeviceInfoURL];
        
        BOOL needEcrypt = [[self class] needEncrypt];
        
        if (needEcrypt) {
            if ([URLString rangeOfString:@"?"].location != NSNotFound) {
                URLString = [NSString stringWithFormat:@"%@&tt_data=a", URLString];
            } else {
                URLString = [NSString stringWithFormat:@"%@?tt_data=a", URLString];
            }
        }
        
        URLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [[TTNetworkManager shareInstance] requestForJSONWithURL:URLString params:postParams method:@"POST" needCommonParams:YES requestSerializer:[TTFingerprintRequestSerializer class] responseSerializer:[TTHTTPJSONResponseSerializerBase class] autoResume:YES callback:^(NSError *error, id JSONObj) {
            NSDictionary* responseDict;
            if ([JSONObj isKindOfClass:[NSDictionary class]]) {
                responseDict = JSONObj;
                [self saveFingerprint:responseDict maxRetryTimes:maxTimes];
            }
        }];
        
    });
}

- (void)invalidBgTaskIfNeeded {
    ttinstall_dispatch_main_sync_safe(^{
        if (self.bgTask != UIBackgroundTaskInvalid) {
            UIApplication *app = [UIApplication sharedApplication];
            [app endBackgroundTask:self.bgTask];
            self.bgTask = UIBackgroundTaskInvalid;
        }
    });
}

#pragma mark - Notification

- (void)didEnterBackground:(NSNotification *)notification {
    UIApplication *app = [UIApplication sharedApplication];
    if (self.bgTask == UIBackgroundTaskInvalid) {
        __weak __typeof__ (self) wself = self;
        self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof (wself) sself = wself;
            if (sself) {
                [app endBackgroundTask:sself.bgTask];
                sself.bgTask = UIBackgroundTaskInvalid;
            }
        }];
    }
    [self startFetchIfNeededWithRetryTimes:3];
}

- (void)connectionChanged:(NSNotification *)notification {
    if ([self hasFecthed]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kTTInstallReachabilityChangedNotification object:nil];
    } else {
        if (TTInstallNetworkConnected()) {
            [self startFetchIfNeededWithRetryTimes:1];
        }
    }
}

#pragma mark - Getters & Setters

- (NSString *)fingerprint {
    if(TTInstallIsEmptyString(_fingerprint)) {
        _fingerprint = [[NSUserDefaults standardUserDefaults] objectForKey:kTTFingerprintStoragekey];
        if (TTInstallIsEmptyString(_fingerprint)) {
                NSString *keychainFingerprint = [TTInstallKeychain loadValueForKey:kTTFingerprintStoragekey];
                if (!TTInstallIsEmptyString(keychainFingerprint)) {
                    [self setFingerprint:keychainFingerprint];
                }
        }
    }
    
    return _fingerprint;
}

- (void)setFingerprint:(NSString *)fingerprint {
    [_didFetchlock lock];
    if(TTInstallIsEmptyString(_fingerprint) || ![_fingerprint isEqualToString:fingerprint]) {
        _fingerprint = fingerprint;
        [[NSUserDefaults standardUserDefaults] setObject:_fingerprint forKey:kTTFingerprintStoragekey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [TTInstallKeychain saveValue:_fingerprint forKey:kTTFingerprintStoragekey];
    }
    [_didFetchlock unlock];
}

#pragma mark - Helper

+ (NSString *)getDeviceInfoURL {
    return @"https://ib.snssdk.com/rc/device_info/v1/collection/";
}

+ (BOOL)needEncrypt {
    BOOL needEcrypt = YES;
    
    return needEcrypt;
}

- (BOOL)hasFecthed {
    [_didFetchlock lock];
    BOOL hasFecthed = !TTInstallIsEmptyString(self.fingerprint);
    [_didFetchlock unlock];
    
    return hasFecthed;
}

@end
