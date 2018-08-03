//
//  TTRNBundleManager.m
//  Article
//
//  Created by Chen Hong on 16/7/21.
//
//

#import "TTRNBundleManager.h"
#import "NSStringAdditions.h"
#import "TTStringHelper.h"
#import "TTPersistence.h"
#import "TTRNBundleDownloader.h"
#import <React/RCTBundleURLProvider.h>

NSString *const TTRNWidgetBundleName = @"toutiao_widget_rn";
NSString *const TTRNCommonBundleName = @"toutiao_common_rn";


static NSString *const kBundleVersionKey     = @"kRNBundleVersionKey";
static NSString *const kBundleMD5Key         = @"kRNBundleMD5Key";
static NSString *const kBundleConfigFileName = @"TTRNBundleManager.plist";

NSErrorDomain const kTTRNBundleManagerDomain = @"TTRNBundleManagerDomain";

static inline NSArray* whiteDomainsOfBundleUrl() {
    return @[
             @".snssdk.com",
             @".toutiao.com",
             @".pstatp.com",
             @".bytedance.com",
             ];
}

@interface TTRNBundleManager ()
@property (nonatomic) TTPersistence *persistence;
@property (nonatomic, readonly) TTRNBundleDownloader *downloader;
@end

@implementation TTRNBundleManager

RCT_EXPORT_MODULE()

+ (TTRNBundleManager *)sharedManager
{
    static TTRNBundleManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTRNBundleManager alloc] init];
    });
    return manager;
}

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    if (![self.persistence hasObjectForKey:@"Profile"]) {
        [self reset];
        [self migrateDataIfNeeded];
    }
}

- (void)reset
{
    [self updateConfigForModuleName:@"Profile" builder:^(TTRNBundleInfoBuilder * _Nonnull builder) {
        builder.version = @"68";
        builder.bundleNameInApp = @"index.ios";
        builder.dirty = @(NO);
    } synchronize:YES];
}

// FIXME: To be delete
- (void)migrateDataIfNeeded
{
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    NSString *profileModuleName = @"Profile";
    NSString *profileBundlePath = [cachesPath stringByAppendingPathComponent:@"com.bytedance.jsbundles"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:profileBundlePath]) {
        NSString *profileBundleNewPath = [self.downloader cachedDirectoryNameForModuleName:profileModuleName];
        [[NSFileManager defaultManager] moveItemAtPath:profileBundlePath toPath:profileBundleNewPath error:nil];
    }
    [self updateConfigForModuleName:profileModuleName builder:^(TTRNBundleInfoBuilder * _Nonnull builder) {
        builder.version = [[NSUserDefaults standardUserDefaults] objectForKey:kBundleVersionKey];
        builder.md5 = [[NSUserDefaults standardUserDefaults] objectForKey:kBundleMD5Key];
    }];
    
    // TODO: canvas
}

#pragma mark -

- (NSURL *)localBundleURLForModuleName:(NSString *)moduleName
{
#if INHOUSE
    NSString *devHost = self.devHost;
    BOOL devEnable = self.devEnable;
    if (!isEmptyString(devHost)) {
        [RCTBundleURLProvider sharedSettings].jsLocation = devHost;
    }
    if (devEnable) {
        return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
    }
#endif
    
    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        NSLog(@"[WARNING]: only support iOS8+.");
        return nil;
    }
    if ([self.downloader cacheBundleFileExistsForModuleName:moduleName]) {
        return [NSURL URLWithString:[self.downloader cacheBundleFilePathForModuleName:moduleName]];
    } else {
        return [self bundleURLInAppForModuleName:moduleName];
    }
}

- (NSURL *)bundleURLInAppForModuleName:(NSString *)moduleName
{
    NSDictionary *moduleInfo = [self.persistence objectForKey:moduleName];
    if (!moduleInfo || ![moduleInfo isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSString *bundleNameInApp = moduleInfo[TTRNBundleNameInApp];
    if (!isEmptyString(bundleNameInApp)) {
        return [[NSBundle mainBundle] URLForResource:bundleNameInApp withExtension:@"bundle"];
    }
    
    return nil;
}

- (NSDictionary *)localBundleInfoForModuleName:(NSString *)moduleName
{
    NSDictionary *moduleInfo = [self.persistence objectForKey:moduleName];
    if (!moduleInfo || ![moduleInfo isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    return moduleInfo;
}

- (NSInteger)localBundleVersionForModuleName:(NSString *)moduleName
{
    NSDictionary *moduleInfo = [self.persistence objectForKey:moduleName];
    if (!moduleInfo || ![moduleInfo isKindOfClass:[NSDictionary class]]) {
        return NSNotFound;
    }
    
    return [moduleInfo[TTRNBundleVersion] integerValue];
}

- (void)updateBundleForModuleName:(NSString *)moduleName
                       bundleInfo:(void(^)(TTRNBundleInfoBuilder *builder))newBlock
                     updatePolicy:(TTRNBundleUpdatePolicy)policy
                       completion:(nullable TTRNBundleUpdateCompletionBlock)completion
{
    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        NSError *error = [NSError errorWithDomain:kTTRNBundleManagerDomain
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"only support iOS8+."}];
        if (completion) {
            completion(nil, NO, error);
        }
        return;
    }
    
    if (!newBlock) {
        NSError *error = [NSError errorWithDomain:kTTRNBundleManagerDomain
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"no bundle info."}];
        if (completion) {
            completion(nil, NO, error);
        }
        return;
    }
    
    TTRNBundleInfoBuilder *info = [TTRNBundleInfoBuilder new];
    newBlock(info);
    
    BOOL isPatch = NO;
    if (info.patchUrl) {
        isPatch = YES;
    }
    NSString *urlStr = isPatch? info.patchUrl : info.bundleUrl;
    NSURL *url = [NSURL URLWithString:urlStr];
    if (!url) {
        NSError *error = [NSError errorWithDomain:kTTRNBundleManagerDomain
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"url is nil."}];
        if (completion) {
            completion(nil, NO, error);
        }
        return;
    }
    
    BOOL isUrlValid = NO;
    NSArray *whiteDomains = whiteDomainsOfBundleUrl();
    for(NSString *domain in whiteDomains) {
        if([[url.host lowercaseString] rangeOfString:[domain lowercaseString]].location != NSNotFound) {
            isUrlValid = YES;
            break;
        }
    }
    
    if (!isUrlValid) {
        NSError *error = [NSError errorWithDomain:kTTRNBundleManagerDomain
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"url is not trusted."}];
        if (completion) {
            completion(nil, NO, error);
        }
        return;
    }
    
    if (![self supportRNVersion:info.rnMinVersion]) {
        NSError *error = [NSError errorWithDomain:kTTRNBundleManagerDomain
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"current react native version is %@, not support version %@", [self RNVersion], info.rnMinVersion]}];
        if (completion) {
            completion(nil, NO, error);
        }
        return;
    }
    
    NSInteger version = [info.version integerValue];
    NSInteger localVersion = [self localBundleVersionForModuleName:moduleName];
    
    if (localVersion != NSNotFound && version < localVersion && policy == TTRNBundleUseBundleInAppIfVersionLow) {
        [self deleteCachedBundleForModuleName:moduleName];
        if (completion) {
            completion([self bundleURLInAppForModuleName:moduleName], YES, nil);
        }
        return;
    }
    
    NSURL *bundleDownloadURL = nil;
    if (version > localVersion || localVersion == NSNotFound) {
        bundleDownloadURL = url;
    } else {
        NSURL *localBundleURL = [self localBundleURLForModuleName:moduleName];
        if (localBundleURL) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(localBundleURL, NO, nil);
                });
            }
            return;
        }
        if (isPatch) {
            bundleDownloadURL = url;
        }else{
            bundleDownloadURL = [self localConfigBundleDownloadURLForModuleName:moduleName];
        }
    }
    
    NSString *md5 = isPatch? info.patchMD5 : info.md5;
    
    WeakSelf;
    [self.downloader downloadBundleForModuleName:moduleName url:bundleDownloadURL isPatch:isPatch bundleMD5:md5 completion:^(NSString * _Nullable cacheBundlePath, NSError * _Nullable error) {
        StrongSelf;
        if (error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, NO, error);
                });
            }
            return;
        }
        
        [self setLocalBundleDirty:NO forModuleName:moduleName];
        [self updateConfigForModuleName:moduleName builder:newBlock];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([NSURL URLWithString:cacheBundlePath], YES, nil);
            });
        }
        
    }];
}

- (void)deleteCachedBundleForModuleName:(NSString *)moduleName
{
    NSString *bundleDirectory = [self.downloader cachedDirectoryNameForModuleName:moduleName];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] removeItemAtPath:bundleDirectory error:&error]) {
        [self resetConfigForModuleName:moduleName];
    }
}

- (void)deleteAllBundles
{
    NSString *bundleRootPath    = [self.downloader bundleRootDirectory];
    if ([[NSFileManager defaultManager] removeItemAtPath:bundleRootPath error:nil]) {
        [self.persistence removeAll];
        [self reset];
        [self.persistence save];
    }
}

#pragma mark - Bundle configure

- (nullable NSURL *)localConfigBundleDownloadURLForModuleName:(NSString *)moduleName
{
    NSDictionary *moduleInfo = [self.persistence objectForKey:moduleName];
    if (!moduleInfo || ![moduleInfo isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSURL *bundleDownloadUrl = [NSURL URLWithString:moduleInfo[TTRNBundleUrl]];
    return bundleDownloadUrl;
}

- (void)updateConfigForModuleName:(NSString *)moduleName builder:(void(^)(TTRNBundleInfoBuilder *builder))block
{
    [self updateConfigForModuleName:moduleName builder:block synchronize:YES];
}

- (void)updateConfigForModuleName:(NSString *)moduleName builder:(void(^)(TTRNBundleInfoBuilder *))block synchronize:(BOOL)synchronize
{
    NSCParameterAssert(!isEmptyString(moduleName));
    if (isEmptyString(moduleName)) {
        return;
    }
    
    if (!block) {
        NSLog(@"Nothing changed.");
        return;
    }
    
    NSDictionary *info = [self.persistence objectForKey:moduleName];
    TTRNBundleInfoBuilder *builder = [TTRNBundleInfoBuilder builderWithInfo:info];
    block(builder);
    info = [builder info];
    [self updateCachedBundleInfo:info forModuleName:moduleName];
    if (synchronize) {
        [self.persistence save];
    }
}

- (void)updateCachedBundleInfo:(NSDictionary *)newInfo forModuleName:(NSString *)moduleName
{
    [self.persistence setObject:newInfo forKey:moduleName];
}

- (void)resetConfigForModuleName:(NSString *)moduleName
{
    NSCParameterAssert(!isEmptyString(moduleName));
    if (isEmptyString(moduleName)) {
        return;
    }
    
    [self updateCachedBundleInfo:nil forModuleName:moduleName];
    
    void(^block)(TTRNBundleInfoBuilder * _Nonnull builder) = [self defaultBuilderBlockForModuleName:moduleName];
    if (block) {
        TTRNBundleInfoBuilder *builder = [TTRNBundleInfoBuilder builderWithInfo:nil];
        block(builder);
        NSDictionary *info = [builder info];
        [self updateCachedBundleInfo:info forModuleName:moduleName];
    }
    [self.persistence save];
}

- (void(^)(TTRNBundleInfoBuilder * _Nonnull builder))defaultBuilderBlockForModuleName:(NSString *)moduleName
{
    if ([moduleName isEqualToString:@"Profile"]) {
        return ^(TTRNBundleInfoBuilder * _Nonnull builder) {
            builder.version = @"68";
            builder.bundleNameInApp = @"index.ios";
        };
    }
    
    return NULL;
}

#pragma mark - Custom accessors

- (TTPersistence *)persistence
{
    if (!_persistence) {
        _persistence = [TTPersistence persistenceWithName:kBundleConfigFileName];
    }
    return _persistence;
}

- (TTRNBundleDownloader *)downloader
{
    return [TTRNBundleDownloader sharedDownloader];
}

#pragma mark - RN Version

- (BOOL)supportRNVersion:(NSString *)rnVersion
{
    if (!rnVersion) {
        return YES;
    }
    
    NSCParameterAssert([rnVersion isKindOfClass:[NSString class]]);
    if (![rnVersion isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    NSArray *versionComponents = [rnVersion componentsSeparatedByString:@"."];
    
    int major = 0, minor = 0, patch = 0;
    
    if (versionComponents.count > 0) {
        NSAssert(major >= 0, @"rnVersion's major version is invalid");
        major = [versionComponents[0] intValue];
    }
    
    if (versionComponents.count > 1) {
        NSAssert(minor >= 0, @"rnVersion's minor version is invalid");
        minor = [versionComponents[1] intValue];
    }
    
    if (versionComponents.count > 2) {
        NSAssert(patch >= 0, @"rnVersion's patch version is invalid");
        patch = [versionComponents[2] intValue];
    }
    
    if (major > [self RNMajorVersion]) {
        return NO;
    }
    
    if (minor > [self RNMinorVersion]) {
        return NO;
    }
    
    if (patch > [self RNPatchVersion]) {
        return NO;
    }
    
    return YES;
}

- (NSString *_Nonnull)RNVersion
{
    return @"0.37";
}

- (int)RNMajorVersion
{
    return 0;
}

- (int)RNMinorVersion
{
    return 37;
}

- (int)RNPatchVersion
{
    return 0;
}

#pragma mark - 本地支持bundle对应的bitmask

- (NSString *)bitMaskStringForModuleName:(NSString *)moduleName
{
    NSDictionary *moduleInfo = [self.persistence objectForKey:moduleName];
    if (!moduleInfo || ![moduleInfo isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSString *bitmask = moduleInfo[TTRNBundleBitmask];
    return bitmask;
}

#pragma mark - 本地bundle可用状态

- (void)setLocalBundleDirty:(BOOL)dirty forModuleName:(NSString *)moduleName
{
    [self updateConfigForModuleName:moduleName builder:^(TTRNBundleInfoBuilder * _Nonnull builder) {
        builder.dirty = @(dirty);
    } synchronize:YES];
}

- (BOOL)localBundleDirtyForModuleName:(NSString *)moduleName
{
    NSDictionary *moduleInfo = [self.persistence objectForKey:moduleName];
    if (!moduleInfo || ![moduleInfo isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    
    return [moduleInfo[TTRNBundleDirty] boolValue];
}

#pragma mark - RCTBridgeModule

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (NSDictionary<NSString *, id> *)constantsToExport
{
    return @{
             @"rnVersion": [self RNVersion]
             };
}

RCT_EXPORT_METHOD(updateBundle:(NSDictionary *)bundleInfo callback:(RCTResponseSenderBlock)callback)
{
    if (!bundleInfo || ![bundleInfo isKindOfClass:[NSDictionary class]]) {
        NSError *error = [NSError errorWithDomain:kTTRNBundleManagerDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid parameters."}];
        callback(@[error, @{@"message": @"Invalid parameters."}]);
        return;
    }
    
    NSString *moduleName = bundleInfo[TTRNBundleModuleName];
    if (isEmptyString(moduleName)) {
        NSError *error = [NSError errorWithDomain:kTTRNBundleManagerDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"ModuleName is empty."}];
        callback(@[error, @{@"message": @"Invalid parameters."}]);
        return;
    }
    
    NSString *bundleUrl = bundleInfo[TTRNBundleUrl];
    if (isEmptyString(bundleUrl)) {
        NSError *error = [NSError errorWithDomain:kTTRNBundleManagerDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"BundleUrl is empty."}];
        callback(@[error, @{@"message": @"BundleUrl is empty."}]);
        return;
    }
    
    NSString *version = [NSString stringWithFormat:@"%@", bundleInfo[TTRNBundleVersion]];
    if (isEmptyString(version)) {
        NSError *error = [NSError errorWithDomain:kTTRNBundleManagerDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Version is empty."}];
        callback(@[error, @{@"message": @"Version is empty."}]);
        return;
    }
    
    NSString *md5 = bundleInfo[TTRNBundleMD5];
    NSString *fallbackUrl = bundleInfo[TTRNBundleFallbackUrl];
    NSString *rnMinVersion = bundleInfo[TTRNBundleRNMinVersion];
    
    [self updateBundleForModuleName:moduleName
                         bundleInfo:^(TTRNBundleInfoBuilder * _Nonnull builder) {
                             builder.bundleUrl = bundleUrl;
                             builder.version = version;
                             builder.md5 = md5;
                             builder.fallbackUrl = fallbackUrl;
                             builder.rnMinVersion = rnMinVersion;
                         }
                       updatePolicy:TTRNBundleUpdateDefaultPolicy
                         completion:^(NSURL * _Nullable localBundleURL, BOOL update, NSError * _Nullable error) {
                             if (error) {
                                 callback(@[error, @{@"message": @"Update failed."}]);
                             } else {
                                 if (!update) {
                                     callback(@[[NSNull null], @{@"message": @"Nothing changed."}]);
                                 } else {
                                     callback(@[[NSNull null], @{@"message": @"Update success."}]);
                                 }
                             }
                         }];
    
}

#pragma mark - 调试相关

- (NSString *)devHost
{
    NSString *host = [[NSUserDefaults standardUserDefaults] objectForKey:@"TTRCTDevHost"];
    if ([host length] == 0) {
        host = @"localhost";
    }
    return host;
}

- (void)setDevHost:(NSString *)devHost
{
    [[NSUserDefaults standardUserDefaults] setValue:devHost forKey:@"TTRCTDevHost"];
}

- (BOOL)devEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"TTRCTDevEnable"];
}

- (void)setDevEnable:(BOOL)devEnable
{
    [[NSUserDefaults standardUserDefaults] setBool:devEnable forKey:@"TTRCTDevEnable"];
}

@end
