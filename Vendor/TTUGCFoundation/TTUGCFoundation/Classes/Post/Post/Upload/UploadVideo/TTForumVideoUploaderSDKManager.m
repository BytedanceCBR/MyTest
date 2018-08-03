//
//  TTForumVideoUploaderManager.m
//  Article
//
//  Created by ranny_90 on 2017/7/21.
//
//

#import "TTForumVideoUploaderSDKManager.h"
#import "NetworkUtilities.h"
#import "TTVideoUploadEventManager.h"
#import "SSLogDataManager.h"
#import "FRForumMonitor.h"
#import "TTBaseMacro.h"
#import "NSDictionary+TTAdditions.h"


#define TTVideoUploadAppKey  @"22b1d0747596877a4c080688af843a58"
#define TTVideoUploadFileHostName  @"tos.snssdk.com"
#define TTVideoUploadVideoHostName  @"vas.snssdk.com"
#define TTVideoUploadCancelErrorCode @"-1414092869"

@interface TTForumVideoUploaderSDKManager()<TTVideoUploadEventManagerProtocol>

@property (nonatomic, strong)NSLock *lock;

@property (nonatomic, strong)NSMutableDictionary *videoUploaderDic;

@end


@implementation TTForumVideoUploaderSDKManager

+ (instancetype)sharedUploader {
    static TTForumVideoUploaderSDKManager *sharedUploader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUploader = [[self alloc] init];
    });
    return sharedUploader;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _videoUploaderDic = [[NSMutableDictionary alloc] init];
        _lock = [[NSLock alloc] init];
        
        [TTVideoUploadEventManager sharedManager].delegate = self;
    }
    return self;
}

- (void)uploadVideoWithTaskID:(NSString *)taskID
                videoFilePath:(NSString *)videoFilePath
          coverImageTimestamp:(NSTimeInterval)coverImageTimestamp
        clientDelegate:(id<TTVideoUploadClientProtocol>)delegate{
    
    if (isEmptyString(taskID)) {
        return;
    }
    
     [_lock lock];
    
    TTVideoUploadClient *client = [self.videoUploaderDic objectForKey:taskID];
    if (!client) {
        client = [[TTVideoUploadClient alloc] initWithFilePath:videoFilePath username:TTVideoUploadAppKey];
        [_videoUploaderDic setValue:client forKey:taskID];
    }
    
    client.delegate = delegate;
    [client setCoverTime:coverImageTimestamp];
    [client setFileHostname:TTVideoUploadFileHostName];
    [client setVideoHostname:TTVideoUploadVideoHostName];
    [client setSliceTimeout:60];
    [client setSliceSize:(512 * 1024)];

    if (TTNetworkWifiConnected()) {
        [client setSliceRetryCount:1];
        [client setFileRetryCount:1];
        [client setSocketNum:1];
    }
    else if (TTNetwork4GConnected()){
        [client setSliceRetryCount:0];
        [client setFileRetryCount:1];
        [client setSocketNum:1];
    }
    else {
        [client setSliceRetryCount:0];
        [client setFileRetryCount:0];
        [client setSocketNum:1];
    }
    
    NSArray *registerDomainCookies = [self getCookies];
    
    if (!SSIsEmptyArray(registerDomainCookies)) {
        [client setCookies:registerDomainCookies];
    }
    
    [_lock unlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (client) {
            [client start];
        }
    });
}

- (TTVideoUploadClient *)fetchTaskWithTaskID:(NSString *)taskID{
    
    if (isEmptyString(taskID)) {
        return nil;
    }
    
    [_lock lock];
    TTVideoUploadClient *client = [self.videoUploaderDic objectForKey:taskID];
    [_lock unlock];
    
    return client;
}

- (void)cacheClient:(TTVideoUploadClient *)client withTaskID:(NSString *)taskID{
    
    if (!client || isEmptyString(taskID)) {
        return;
    }
    
    [_lock lock];
    [_videoUploaderDic setValue:client forKey:taskID];
    [_lock unlock];
    
}

- (void)cancelVideoUploadWithTaskID:(NSString *)taskID{
    
    if (isEmptyString(taskID)) {
        return;
    }
    
    [_lock lock];
    TTVideoUploadClient *client = [self.videoUploaderDic objectForKey:taskID];
    [_lock unlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (client) {
             [client stop];
        }
       
    });
}

- (void)cancelAndRemoveUploadWithTaskID:(NSString *)taskID{
    if (isEmptyString(taskID)) {
        return;
    }
    
    [_lock lock];
    
    TTVideoUploadClient *client = [self.videoUploaderDic objectForKey:taskID];
    if (client) {
        [self.videoUploaderDic removeObjectForKey:taskID];
    }
    [_lock unlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (client) {
            [client stop];
        }
    });
}

- (void)removeClientWithTaskId:(NSString *)taskID{
    
    if (isEmptyString(taskID)) {
        return;
    }
    [_lock lock];
    TTVideoUploadClient *client = [self.videoUploaderDic objectForKey:taskID];
    if (client) {
        [self.videoUploaderDic removeObjectForKey:taskID];
    }
    [_lock unlock];
}

- (NSArray<NSHTTPCookie *> *)getCookies
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSArray *cookiesHttp = [storage cookiesForURL:[NSURL URLWithString:@"http://i.snssdk.com/"]];
    NSArray *cookieHttps = [storage cookiesForURL:[NSURL URLWithString:@"https://i.snssdk.com/"]];
    
    NSMutableArray *cookies = [[NSMutableArray alloc] init];
    if (!SSIsEmptyArray(cookiesHttp)) {
        [cookies addObjectsFromArray:cookiesHttp];
    }
    
    if (!SSIsEmptyArray(cookieHttps)) {
        [cookies addObjectsFromArray:cookieHttps];
    }
    
    return cookies;
}

#pragma mark -- TTVideoUploadEventManagerProtocol

- (void)eventManagerDidUpdate:(TTVideoUploadEventManager *)eventManager {
    NSArray<NSDictionary *> *events = [eventManager popAllEvents];
    
    for (NSDictionary *event in events) {
        
        if (event && [event isKindOfClass:[NSDictionary class]]) {
            
            [[SSLogDataManager shareManager] appendLogData:event];
            
            NSMutableDictionary *monitorDict = [[NSMutableDictionary alloc] init];
            [monitorDict addEntriesFromDictionary:event];
            
            NSString *errorCode = [event tt_stringValueForKey:@"errc"];
            NSString *error_stage = [event tt_stringValueForKey:@"errs"];
            NSDictionary *ex = [event tt_dictionaryValueForKey:@"ex"];
            
            //errs存在 且 不为0，则判断为 失败
            if (!isEmptyString(error_stage) && ![error_stage isEqualToString:@"0"]) {
                
                NSString *ex_errcode = nil;
                
                if (!SSIsEmptyDictionary(ex)) {
                    ex_errcode = [ex tt_stringValueForKey:@"errcode"];
                }
                
                //errc == "-1414092869" 或 ex中的errcode字段存在 "-1414092869"，则为 用户取消
                if ((errorCode && [errorCode isEqualToString:TTVideoUploadCancelErrorCode]) || (ex_errcode && [ex_errcode isEqualToString:TTVideoUploadCancelErrorCode])) {
                    [FRForumMonitor ugcVideoSDKPostMonitorUploadVideoPerformanceWithStatus:TTSDKPostVideoStatusMonitorCancelled extra:[monitorDict copy]];
                }
                //其他 为 接口错误
                else {
                    [FRForumMonitor ugcVideoSDKPostMonitorUploadVideoPerformanceWithStatus:TTSDKPostVideoStatusMonitorFailed extra:[monitorDict copy]];
                }
                
            }
            
            //其他判断为 成功
            else {
               [FRForumMonitor ugcVideoSDKPostMonitorUploadVideoPerformanceWithStatus:TTSDKPostVideoStatusMonitorSucceed extra:[monitorDict copy]];
            }
            
        }
    }
    
}

@end
