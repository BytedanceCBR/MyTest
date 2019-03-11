//
//  SSLogDataManager.m
//  Article
//
//  Created by Zhang Leonardo on 15-3-22.
//
//

#import "SSLogDataManager.h"
#import "TTTrackerProxy.h"
#import "TTLogServer.h"
#import <pthread.h>

#define kSSLogDataSaveKey @"kSSLogDataSaveKey"
@interface SSLogDataManager(){
    BOOL _isSending;//是否正在网络发送中
    pthread_mutex_t _logDataLock;
    pthread_mutex_t _appendDataLock;
}

@property(nonatomic, strong)NSMutableArray *logDatas;
@property(nonatomic, strong)NSMutableArray *appendingDatas;

@end

@implementation SSLogDataManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

static SSLogDataManager * sManager;

+ (SSLogDataManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sManager = [[SSLogDataManager alloc] init];
    });
    return sManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _logDatas = [NSMutableArray arrayWithCapacity:200];
        _appendingDatas = [NSMutableArray arrayWithCapacity:10];
        
        pthread_mutexattr_t attr;
        pthread_mutexattr_init (&attr);
        pthread_mutex_init (&_logDataLock, &attr);
        pthread_mutexattr_destroy (&attr);
        
        pthread_mutexattr_t appending_attr;
        pthread_mutexattr_init (&appending_attr);
        pthread_mutex_init (&_appendDataLock, &appending_attr);
        pthread_mutexattr_destroy (&appending_attr);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackerWillSendNotification:) name:kTrackerCleanerWillStartCleanNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackerSentSuccessNotification:)
                                                     name:kTrackerSentSuccessNotification
                                                   object:nil];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackerSentFailNotification:)
                                                     name:kTrackerSentFailNotification
                                                   object:nil];

    }
    return self;
}

- (void)appendLogData:(NSDictionary *)dict
{
    if ([dict isKindOfClass:[NSDictionary class]] && [dict count] > 0) {
        NSMutableDictionary * tmpDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        long long uniqueKey = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
        [tmpDict setValue:@(uniqueKey) forKey:@"log_id"];
        NSDictionary * sendDict = [NSDictionary dictionaryWithDictionary:tmpDict];
        if (_isSending) {
            pthread_mutex_lock(&_appendDataLock);
            [self.appendingDatas addObject:sendDict];
            pthread_mutex_unlock(&_appendDataLock);
        } else {
            pthread_mutex_lock(&_logDataLock);
            [self.logDatas addObject:sendDict];
            pthread_mutex_unlock(&_logDataLock);
        }
        
        [TTLogServer sendValueToLogServer:sendDict];
    }
}

- (NSArray *)needSendLogDatas
{
    pthread_mutex_lock(&_logDataLock);
    NSArray *logDatas = [self.logDatas copy];
    pthread_mutex_unlock(&_logDataLock);
    return logDatas;
}


#pragma mark --  notification

- (void)trackerWillSendNotification:(NSNotification *)notification {
    _isSending = YES;
}

- (void)trackerSentSuccessNotification:(NSNotification *)notification
{
    if (_isSending) {
        pthread_mutex_lock(&_logDataLock);
        [self.logDatas removeAllObjects];
        [self.logDatas addObjectsFromArray:[self.appendingDatas copy]];
        pthread_mutex_unlock(&_logDataLock);
        
        pthread_mutex_lock(&_appendDataLock);
        [self.appendingDatas removeAllObjects];
        pthread_mutex_unlock(&_appendDataLock);

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSSLogDataSaveKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        _isSending = NO;
    }
}

- (void)trackerSentFailNotification:(NSNotification *)notification
{
    if (_isSending) {
        pthread_mutex_lock(&_appendDataLock);
        NSArray *appendings = [self.appendingDatas copy];
        pthread_mutex_unlock(&_appendDataLock);

        pthread_mutex_lock(&_logDataLock);
        [self.logDatas addObjectsFromArray:appendings];
        pthread_mutex_unlock(&_logDataLock);
       
        pthread_mutex_lock(&_appendDataLock);
        [self.appendingDatas removeAllObjects];
        pthread_mutex_unlock(&_appendDataLock);

        _isSending = NO;
    }
}

@end
