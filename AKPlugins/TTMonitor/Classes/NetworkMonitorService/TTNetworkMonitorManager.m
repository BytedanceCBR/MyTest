//
//  TTNetworkMonitorManager.m
//  Article
//
//  Created by ZhangLeonardo on 16/3/23.
//
//

#import "TTNetworkMonitorManager.h"
#import "TTNetworkMonitorRecorder.h"
#import "TTNetworkManager.h"
#import "TTMonitorConfiguration.h"
#import <objc/runtime.h>
#import "TTExtensions.h"

@interface TTNetworkMonitorManagerInternalRequestState : NSObject

@property (nonatomic, copy) TTHttpRequest *request;
@property (nonatomic, strong) NSMutableData *dataAccumulator;


@end

@implementation TTNetworkMonitorManagerInternalRequestState

@end

@interface TTNetworkMonitorManager()
@property (nonatomic, strong) NSMutableDictionary *requestStatesForRequestIDs;
@property (nonatomic, strong) dispatch_queue_t queue;
@property(nonatomic, assign)BOOL enable;

@end

@implementation TTNetworkMonitorManager

+ (instancetype)defaultMonitorManager
{
    static TTNetworkMonitorManager *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [[[self class] alloc] init];
    });
    return defaultRecorder;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.requestStatesForRequestIDs = [[NSMutableDictionary alloc] init];
        self.queue = dispatch_queue_create("com.bytedance.TTNetworkMonitorManagerQueue", DISPATCH_QUEUE_SERIAL);

    }
    return self;
}


- (void)enableMonitor
{
    self.enable = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self registNotification];
    });
}

- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNetworkStartNotification:) name:@"kTTNetworkManagerMonitorStartNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNetworkFinishNotification:) name:@"kTTNetworkManagerMonitorFinishNotification" object:nil];
}


#pragma mark - Private Methods

- (void)performBlock:(dispatch_block_t)block
{
    if (self.enable) {
        dispatch_async(_queue, block);
    }
}

- (TTNetworkMonitorManagerInternalRequestState *)requestStateForRequestID:(NSString *)requestID
{
    TTNetworkMonitorManagerInternalRequestState *requestState = [self.requestStatesForRequestIDs objectForKey:requestID];
    if (!requestState) {
        requestState = [[TTNetworkMonitorManagerInternalRequestState alloc] init];
        [self.requestStatesForRequestIDs setValue:requestState forKey:requestID];
    }
    return requestState;
}

- (void)removeRequestStateForRequestID:(NSString *)requestID
{
    [self.requestStatesForRequestIDs removeObjectForKey:requestID];
}




#pragma mark -- notification

- (void)receiveNetworkStartNotification:(NSNotification *)notification
{
    if (!_enable) {
        return;
    }
    NSDate * startDate = [NSDate date];
    __weak typeof(self) weakSelf = self;
    [self performBlock:^{
        TTHttpRequest * request = [[notification userInfo] objectForKey:@"kTTNetworkManagerMonitorRequestKey"];
        NSInteger hasTriedTimes = [[[notification userInfo] objectForKey:@"kTTNetworkManagerMonitorRequestTriedTimesKey"] integerValue];
        [weakSelf dealStartRequest:request
                         startDate:startDate
                     hasTriedTimes:hasTriedTimes];
    }];
}

- (void)receiveNetworkFinishNotification:(NSNotification *)notification
{
    if (!_enable) {
        return;
    }
    NSDate * finishedDate = [NSDate date];
    __weak typeof(self) weakSelf = self;
    [self performBlock:^{
        TTHttpRequest * request = [[notification userInfo] objectForKey:@"kTTNetworkManagerMonitorRequestKey"];
        TTHttpResponse * response = [[notification userInfo] objectForKey:@"kTTNetworkManagerMonitorResponseKey"];
        NSError * error = [[notification userInfo] objectForKey:@"kTTNetworkManagerMonitorErrorKey"];
        id responseObj = [[notification userInfo] objectForKey:@"kTTNetworkManagerMonitorResponseDataKey"];
        [weakSelf dealFinishResponse:response
                             request:request
                               error:error
                         responseObj:responseObj
                        finishedDate:finishedDate];
    }];
}

#pragma mark -- deal
- (void)dealStartRequest:(TTHttpRequest *)request
               startDate:(NSDate *)startDate
           hasTriedTimes:(NSInteger)hasTriedTimes
{
    NSString *requestID = [[self class] requestIDForURLRequest:request];
    [[TTNetworkMonitorRecorder defaultRecorder]
     recordRequestWillBeSentWithRequestID:requestID
     request:request
     startDate:startDate
     hasTriedTimes:hasTriedTimes];
}

- (void)dealFinishResponse:(TTHttpResponse *)response
                   request:(TTHttpRequest *)request
                     error:(NSError *)error
               responseObj:(id)responseObj
              finishedDate:(NSDate *)finishedDate;
{
    NSString *requestID = [[self class] requestIDForURLRequest:request];
    if (error) {
        [[TTNetworkMonitorRecorder defaultRecorder]
         recordLoadingFailedWithRequestID:requestID
         error:error
         response:response
         responseBody:responseObj
         finishedDate:finishedDate];
    }
    else {
        [[TTNetworkMonitorRecorder defaultRecorder]
         recordLoadingFinishedWithRequestID:requestID
         responseBody:responseObj
         response:response
         finishedDate:finishedDate];
    }
}

#pragma mark -- util

+ (NSString *)nextRequestID
{
    return [[NSUUID UUID] UUIDString];
}

static char const * const kTTNetworkMonitorRequestIDKey = "kTTNetworkMonitorRequestIDKey";

+ (NSString *)requestIDForURLRequest:(TTHttpRequest *)request
{
    if (!request) {
        return nil;
    }
    
    NSString *requestID = objc_getAssociatedObject(request, @"kTTNetworkMonitorRequestIDKey");
    if (!requestID) {
        requestID = [self nextRequestID];
        [self setRequestID:requestID forURLRequest:request];
    }
    return requestID;

}

+ (void)setRequestID:(NSString *)requestID forURLRequest:(TTHttpRequest *)request
{
    if (!request) {
        return;
    }
    objc_setAssociatedObject(request, @"kTTNetworkMonitorRequestIDKey", requestID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
