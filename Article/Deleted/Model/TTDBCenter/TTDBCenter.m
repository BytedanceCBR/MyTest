//
//  TTDBCenter.m
//  Article
//
//  Created by Chen Hong on 2017/2/28.
//
//

#import "TTDBCenter.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "TTCategory.h"
#import "TTVideoCategory.h"
#import "TSVCategory.h"
#import "ExploreEntry.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "WenDaBaseData.h"
#import "TTUserData.h"
#import <TTAccountSDK.h>
#import "TTStartupTasksTracker.h"
#import <TTFriendRelationEntity.h>

static NSString *const kTTDBCenterAppVersion = @"kTTDBCenterAppVersion";

@interface TTDBCenter ()
<
TTAccountMulticastProtocol
>
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
@end

@implementation TTDBCenter

+ (instancetype)sharedInstance {
    static TTDBCenter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTDBCenter alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundTaskId = UIBackgroundTaskInvalid;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCacheNotificaiton) name:@"SettingViewClearCachdNotification" object:nil];
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (void)applicationDidEnterBackground {
    [self clearDBAutomatically];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [ExploreOrderedData removeAllEntities];
    [Article removeAllEntities];
    [ExploreEntry removeAllEntities];
    [TTFriendRelationEntity removeAllEntities];
}

- (void)clearCacheNotificaiton {
    //[ExploreOrderedData removeAllEntities];
}

- (void)clearDBAutomatically {
    if ([SSCommonLogic boolForKey:@"db_autoclean_disable"]) {
        return;
    }
    
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        return;
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    WeakSelf;
    self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
        StrongSelf;
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 数据库超过一定大小时，下次启动删除重建
        float oneM = 1024.f * 1024.f;
        float threshold = [SSCommonLogic floatForKey:@"db_clean_size"] / oneM;
        
        if (threshold <= 0) {
            threshold = 50;
        }
        
        float dbSize = [ExploreOrderedData dbSize] / oneM;
        
        if (dbSize > threshold) {
            if (![SSCommonLogic needCleanCoreData]) {
                [SSCommonLogic setNeedCleanCoreData:YES];
                [Answers logCustomEventWithName:@"cleanDBBySize" customAttributes:@{@"threshold":@(threshold), @"dbSize":@(dbSize)}];
            }
        }
        else {
            @try {
                // 清理ExploreOrderedData表，ExploreOrderedData负责清理其关联对象表
                [ExploreOrderedData cleanEntities];
                
                // 清理文章详情
                [ArticleDetail cleanEntities];
            } @catch (NSException *exception) {
                if (![SSCommonLogic needCleanCoreData]) {
                    [SSCommonLogic setNeedCleanCoreData:YES];
                    if (exception) {
                        [Answers logCustomEventWithName:@"cleanDBByException" customAttributes:@{@"exception":exception}];
                    }
                }
            }
        }
        
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    });
}

- (void)deleteDBIfNeeded {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *lastAppVersion = [defaults stringForKey:kTTDBCenterAppVersion];
    
    // app版本升级时
    if (isEmptyString(lastAppVersion) || ![lastAppVersion isEqualToString:appVersion]) {
        [TTDBCenter deleteAllDBFiles];
        [defaults setObject:appVersion forKey:kTTDBCenterAppVersion];
    }
    else {
        [[TTDBCenter dbClassArray] enumerateObjectsUsingBlock:^(Class dbClass, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([dbClass isSubclassOfClass:[TTEntityBase class]]) {
                [dbClass deleteDBFileIfNeeded];
            }
        }];
    }
}

+ (NSArray<Class> *)dbClassArray {
    return @[
             [ExploreOrderedData class],   //首页列表
             [TTCategory class],           //首页tab频道
             [TTVideoCategory class],      //视频tab频道
             [TSVCategory class],          //小视频tab频道
             [ExploreEntry class],         //订阅
             [WenDaBaseData class],        //问答
             [TTUserData class],           //私信用户信息
             ];
}
+ (void)deleteAllDBFiles {
    NSArray<Class> *dbClasses = [self dbClassArray];
    
    [dbClasses enumerateObjectsUsingBlock:^(Class dbClass, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([dbClass isSubclassOfClass:[TTEntityBase class]]) {
            [dbClass deleteDBFile];
        }
    }];
    
    [[TTStartupTasksTracker sharedTracker] cacheInitializeDevLog:@"ClearnAllDB" params:nil];
}

//+ (void)deleteOldDB {
//    //删除4.3开始新增的订阅数据库
//    [self deleteDataBaseForFileName:@"explore_entry.sqlite" fileInDocumentDirectory:YES];
//    
//    //删除文章数据库, 尝试删除3.6版本的文章数据库
//    [self deleteDataBaseForFileName:@"news36.sqlite" fileInDocumentDirectory:YES];
//    
//    //删除document中数据库
//    [self deleteDataBaseForFileName:@"other.sqlite" fileInDocumentDirectory:YES];
//    
//    //删除cache中数据库
//    [self deleteDataBaseForFileName:@"other.sqlite" fileInDocumentDirectory:NO];
//    
//    //删除3.6遗留的数据库
//    [self deleteDataBaseForFileName:@"other36.sqlite" fileInDocumentDirectory:YES];
//    
//    //删除coreData数据库
//    [self deleteDataBaseForFileName:@"news.sqlite" fileInDocumentDirectory:NO];
//}

+ (void)deleteDBFile:(NSString *)dbName {
    NSString *fileName = [NSString stringWithFormat:@"%@.db", dbName];
    [self deleteDataBaseForFileName:fileName fileInDocumentDirectory:YES];
}

#pragma mark -- util

/**
 *  删除指定的数据库文件
 *
 *  @param fileName         数据库名
 *  @param fileInDocument   YES表示文件在NSDocumentDirectory目录，NO表示文件在NSCachesDirectory目录
 *
 *  @return 返回YES，表示数据库文件存在，并且删除了。 NO表示文件不存在.
 */
+ (BOOL)deleteDataBaseForFileName:(NSString *)fileName fileInDocumentDirectory:(BOOL)fileInDocument
{
    BOOL exist = NO;
    NSSearchPathDirectory dictionary = fileInDocument ? NSDocumentDirectory : NSCachesDirectory;
    NSString *pathString = [[NSSearchPathForDirectoriesInDomains(dictionary, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
        exist = YES;
        [[NSFileManager defaultManager] removeItemAtPath:pathString error:nil];
    }
    return exist;
}

/**
 *  判断指定文件名的数据库是否存在
 *
 *  @param fileName       数据库的名字
 *  @param fileInDocument YES表示文件在NSDocumentDirectory目录，NO表示文件在NSCachesDirectory目录
 *
 *  @return YES:数据库存在，NO:数据库不存在
 */
+ (BOOL)dataBaseFileExistForFileName:(NSString *)fileName fileInDocumentDirectory:(BOOL)fileInDocument
{
    BOOL exist = NO;
    NSSearchPathDirectory dictionary = fileInDocument ? NSDocumentDirectory : NSCachesDirectory;
    NSString *pathString = [[NSSearchPathForDirectoriesInDomains(dictionary, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
        exist = YES;
    }
    return exist;
}

/**
 *  获取指定名字数据库对应的文件的路径
 *
 *  @param fileName       数据库的名字
 *  @param fileInDocument YES表示文件在NSDocumentDirectory目录，NO表示文件在NSCachesDirectory目录
 *
 *  @return 返回nil，表示指定的文件不存在。否则表示指定的文件存在。
 */
+ (NSString *)pathForDataBaseFileName:(NSString *)fileName fileInDocumentDirectory:(BOOL)fileInDocument
{
    NSSearchPathDirectory dictionary = fileInDocument ? NSDocumentDirectory : NSCachesDirectory;
    NSString *pathString = [[NSSearchPathForDirectoriesInDomains(dictionary, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:pathString];
    return exist ? pathString : nil;
}


@end
