//
//  WDDetailFullContentManager.m
//  wenda
//
//  Created by xuzichao on 2017/2/20.
//  Copyright © 2017年 延晋 张. All rights reserved.
//

#import "WDDetailFullContentManager.h"
#import "WDQuestionEntity.h"
#import "WDAnswerEntity.h"
#import "WDCommonURLSetting.h"
#import "WDSettingHelper.h"

#import <TTNetworkManager.h>
#import "TTBaseMacro.h"
#import "NSDictionary+TTAdditions.h"

NSString * const kWDFetchAnswerDetailFinishedNotification = @"kWDFetchAnswerDetailFinishedNotification";
NSString * const kWDFullAnswerData = @"answer";
NSString * const kWDFullExtraData = @"wdextra";
NSUInteger detailMaxRetryCount = 3;

static WDDetailFullContentManager * sharedManager;

@interface WDDetailFullContentManager ()

@property(nonatomic, retain) NSMutableArray<TTHttpTask *> *operations;

@end

@implementation WDDetailFullContentManager


+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[WDDetailFullContentManager alloc] init];
    });
    return sharedManager;
}
- (void)dealloc
{
    [self cancelAllRequests];
    self.operations = nil;
    self.delegate = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.operations = [[NSMutableArray alloc] init];
        self.threadPriority = 0.5f;
    }
    return self;
}

- (void)cancelAllRequests
{
    for (TTHttpTask *task in _operations)
    {
        [task cancel];
    }
    [self.operations removeAllObjects];
}

- (void)suspendAllRequests
{
    for (TTHttpTask *task in _operations) {
        if (task.state == TTHttpTaskStateRunning) {
            [task suspend];
            //NSLog(@"suspend %@", task);
        }
    }
}

- (void)resumeAllRequests
{
    for (TTHttpTask *task in _operations) {
        if (task.state == TTHttpTaskStateSuspended) {
            [task resume];
            //NSLog(@"resume %@", task);
        }
    }
}

- (void)fetchDetailForAnswerEntity:(WDAnswerEntity *)entity
                            useCDN:(BOOL)useCDN
{
    [self fetchDetailForAnswerEntity:entity withOperationPriority:NSOperationQueuePriorityVeryHigh atIndex:0 notifyError:YES useCDN:useCDN];
}

- (void)fetchDetailForAnswerEntity:(WDAnswerEntity *)entity
             withOperationPriority:(NSOperationQueuePriority)priority
                           atIndex:(NSUInteger)index
                       notifyError:(BOOL)notifyError
                            useCDN:(BOOL)useCDN
{
    NSString *requestURL = [self detailUrlStringAtIndex:index answerID:entity.ansid useCDN:useCDN];
    if (requestURL == nil) {
        if (notifyError) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            if (entity) {
                [dict setObject:entity forKey:kWDFullAnswerData];
            }
            NSError * e = [NSError errorWithDomain:@"kCommonErrorDomain"
                                              code:1014
                                          userInfo:[NSDictionary dictionaryWithObject:@"网络出现问题，请稍后再试" forKey:@"message"]];
            [dict setObject:e forKey:@"error"];
            [self notifyFinish:dict];
        }
        return;
    }
    
    WeakSelf;
    NSMutableDictionary *param = @{}.mutableCopy;
    if (!useCDN) {
        [param setValue:@"new" forKey:@"type"];
        [param setValue:@([NSDate timeIntervalSinceReferenceDate]) forKey:@"timeStamp"];
    }
    
    __block TTHttpTask *task = [[TTNetworkManager shareInstance] requestForJSONWithURL:requestURL params:[param copy] method:@"GET" needCommonParams:YES requestSerializer:nil responseSerializer:nil autoResume:NO callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        if (!self) {
            return;
        }
        
        [self.operations removeObject:task];
 
        if (error) {
            [self fetchDetailForAnswerEntity:entity withOperationPriority:priority atIndex:(index + 1) notifyError:notifyError useCDN:NO];
        } else {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[jsonObj tt_dictionaryValueForKey:@"data"]];
            NSDictionary *extraDict = [data tt_dictionaryValueForKey:@"wenda_extra"];

            if(data.allKeys.count > 0) {
                [entity updateWithDetailWendaAnswer:data];
                [entity save];
                
                NSMutableDictionary * notifyDict = [NSMutableDictionary dictionaryWithCapacity:2];
                [notifyDict setValue:entity forKey:kWDFullAnswerData];
                [notifyDict setValue:extraDict forKey:kWDFullExtraData];
                
                [self notifyFinish:notifyDict];
            }
        }
    }];
    
    [self.operations addObject:task];
    if ([task respondsToSelector:@selector(setPriority:)]) {
        switch (priority) {
            case NSOperationQueuePriorityVeryLow:
                task.priority = 0.15f;
                break;
                
            case NSOperationQueuePriorityLow:
                task.priority = 0.25f;//NSURLSessionTaskPriorityLow;
                break;
                
            case NSOperationQueuePriorityNormal:
                task.priority = 0.5f;//NSURLSessionTaskPriorityDefault;
                break;
                
            case NSOperationQueuePriorityHigh:
                task.priority = 0.75f;//NSURLSessionTaskPriorityHigh
                break;
                
            case NSOperationQueuePriorityVeryHigh:
                task.priority = 0.85f;
                break;
                
            default:
                task.priority = 0.5f;//NSURLSessionTaskPriorityDefault;
                break;
        }
    }
    
    [task resume];
}

- (void)notifyFinish:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNewsFetchWDDetailFinishedNotification" object:self userInfo:userInfo];
    
    if (_delegate && [_delegate respondsToSelector:@selector(fetchDetailManager:finishWithResult:)]) {
        [_delegate fetchDetailManager:self finishWithResult:userInfo];
    }
}

#pragma mark - Util

- (NSString *)detailUrlStringAtIndex:(NSUInteger)index answerID:(NSString *)answerID useCDN:(BOOL)useCDN
{
    if (index > detailMaxRetryCount) {
        return nil;
    }
    
    if (isEmptyString(answerID) || [answerID rangeOfString:@"null"].length) {
        return nil;
    }
   
    NSString *hostString = useCDN ? [self cdnHostWithIndex:index] : [WDCommonURLSetting baseURL];
    NSArray<NSString *> *hostComponents = [hostString componentsSeparatedByString:@"://"];
    if (hostComponents.count == 1) {
        hostString = [NSString stringWithFormat:@"http://%@", hostString];
    }
    if (!hostString) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/wenda/v1/answer/detail/%@/", hostString, answerID];
}

- (NSString *)cdnHostWithIndex:(NSUInteger)index
{
    NSArray * hosts = [WDSettingHelper wendaDetailURLHosts];
    if (index > [hosts count] || (index == [hosts count] && index > 0)) {
        return nil;
    }
    
    NSString * hostString = nil;
    if (index == 0) {
        if ([hosts count] == 0) {
            hostString = [[WDSettingHelper defaultWendaDetailURLHosts] firstObject];
        } else {
            hostString = [hosts objectAtIndex:0];
        }
    } else {
        hostString = [hosts objectAtIndex:index];
    }
    return hostString;
}

@end
