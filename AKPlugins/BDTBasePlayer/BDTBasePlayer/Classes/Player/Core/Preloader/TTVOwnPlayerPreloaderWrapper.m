//
//  TTVOwnPlayerPreloaderWrapper.m
//  BDTBasePlayer
//
//  Created by peiyun on 2017/12/24.
//

#import "TTVOwnPlayerPreloaderWrapper.h"
#import "TTVVideoURLParser.h"
#import "TTVPlayerLogEvent.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTTrackerProxy.h"

int TTVOwnPlayerPreloaderDefaultResolution = TTAVVideoResolutionFullHD;

@interface TTVOwnPlayerPreloaderWrapper () <TTAVPreloaderDelegate>

@property (nonatomic, strong) TTAVPreloader *preloader;
@property (nonatomic, strong) NSMutableDictionary *preloadGroupDict;
@property (nonatomic, strong) NSMutableSet *observerSet;
@property (nonatomic, strong) NSMutableArray *adPreloaders;

@end

@implementation TTVOwnPlayerPreloaderWrapper

+ (instancetype)sharedPreloader
{
    static TTVOwnPlayerPreloaderWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTVOwnPlayerPreloaderWrapper alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"TTVPlayerPreloaderCache"];
        
        TTAVPreloaderConfig *config = [TTAVPreloaderConfig defaultConfig];
        config.cachePath = cachePath;
        config.maxConcurrentCount = 4;
        NSInteger limitCache = 100;
        if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_disk_cache_optimize" defaultValue:@1 freeze:YES] boolValue]) {
            float fressDisk = [TTDeviceHelper getFreeDiskSpace]/(1024 *1024);
            if (fressDisk < 500) {
                limitCache = 50;
            }
        }
        config.maxCacheSize = limitCache * 1024 * 1024;
        config.autoManageFileEnable = YES;
        
        _preloader = [TTAVPreloader preloaderWithConfig:config];
        _preloader.delegate = self;
        _preloadGroupDict = [NSMutableDictionary dictionary];
        _observerSet = [NSMutableSet set];
        
        [_preloader start];
        
        [_observerSet addObject:[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [[TTVOwnPlayerPreloaderWrapper sharedPreloader].preloader close];
        }]];
        self.adPreloaders = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    for (id observer in self.observerSet) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

- (HandleType)preloadVideoID:(NSString *)videoID
{
    HandleType handler = [self.preloader addTask:videoID resolution:TTVOwnPlayerPreloaderDefaultResolution];
    [self.preloader startTask:handler];
    return handler;
}

- (HandleType)preloadVideoID:(NSString *)videoID group:(NSString *)group
{
    @synchronized (self){
        HandleType handler = [self.preloader addTask:videoID resolution:TTVOwnPlayerPreloaderDefaultResolution];
        [self.preloader startTask:handler];
        
        if (group.length == 0) {
            return 0;
        }
        
        NSMutableArray *array = self.preloadGroupDict[group];
        if (!array) {
            array = [NSMutableArray array];
            self.preloadGroupDict[group] = array;
        }
        [array addObject:@(handler)];
        return handler;
    }
}

- (void)addAdPreloadItem:(TTAdPlayerPreloadModel *)model
{
    if (model) {
        [self.adPreloaders addObject:model];
    }
}

- (void)cancelTaskForVideoID:(NSString *)videoID
{
    HandleType handler = [self.preloader getHandle:videoID resolution:TTVOwnPlayerPreloaderDefaultResolution];
    [self.preloader stopTask:handler];
}

- (void)cancelGroup:(NSString *)group
{
    @synchronized (self){
        NSMutableArray *array = self.preloadGroupDict[group];
        NSArray *enumArray = [array copy];
        for (NSNumber *taskHandler in enumArray) {
            [self.preloader stopTask:[taskHandler longLongValue]];
        }
        [array removeAllObjects];
    }
}

- (void)cancel
{
    [self.preloader stopAllTask];
}

- (void)clear
{
    [self.preloader removeAllTask];
}


#pragma mark - TTAVPreloaderDelegate

- (NSString *)metaInfoApiForVid:(NSString *)vid resolution:(int)resolution
{
    return [TTVVideoURLParser urlWithVideoID:vid categoryID:nil itemId:nil adID:nil sp:TTVPlayerSPToutiao base:nil];
}

- (void)didFinishPreloadTask:(HandleType)handle error:(NSError *)error
{
    [self trackAdPreloadTask:handle];
}

- (void)didRecieveLogEvent:(NSString *)logJson
{
    [[TTVPlayerLogEvent sharedInstance] logPreloaderData:[self.preloader popLogs]];
}

- (void)trackAdPreloadTask:(HandleType)handle
{
    for (TTAdPlayerPreloadModel *model in self.adPreloaders) {
        if (model.hanlder == handle) {
            
            NSMutableDictionary *events = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"umeng", @"category",
                                           @"embeded_ad", @"tag",
                                           @"video_pre_loaded", @"label", nil];
            [events setValue:model.ad_id forKey:@"value"];
            [events setValue:model.log_extra forKey:@"log_extra"];
            TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
            [events setValue:@(connectionType) forKey:@"nt"];
            [events setValue:@"1" forKey:@"is_ad_event"];
            [TTTrackerWrapper eventData:events];
            
            return;
        }
    }
}

@end


@implementation TTAdPlayerPreloadModel

- (instancetype)initWithAdId:(NSString *)ad_id logExtra:(NSString *)logExtra handleType:(HandleType)hanlder
{
    self = [super init];
    if (self) {
        self.ad_id = ad_id;
        self.log_extra = logExtra;
        self.hanlder = hanlder;
    }
    return self;
}

@end
