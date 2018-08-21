//
//  NewsFetchArticleDetailManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-10-27.
//
//

#import "NewsFetchArticleDetailManager.h"
#import "ArticleURLSetting.h"

//#import "NetworkUtilities.h"
//#import "NewsDetailLogicManager.h"
#import "WDSettingHelper.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTDeviceHelper.h"
#import "TTMonitor.h"
#import "TTVideoArticleService.h"
#import "TTVVideoArticle+Extension.h"


@implementation TTVFetchEntity



@end

#define maxReRequestCount 5   //最多重新请求次数

#define kArticleFullURLHostKey @"kArticleFullURLHostKey"        //请求完整信息
#define kArticleContentURLHostKey @"kArticleContentURLHostKey"  //请求详情页信息（content，image）

@interface NewsFetchArticleDetailManager()
@property(nonatomic, retain)NSMutableArray<TTHttpTask *> *operations;
//@property(nonatomic, retain)SSOperationStack *operationStack;

@end

static NewsFetchArticleDetailManager * sharedManager;

@implementation NewsFetchArticleDetailManager

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

+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[NewsFetchArticleDetailManager alloc] init];
    });
    return sharedManager;
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

- (void)fetchDetailForArticle:(Article *)article
        withOperationPriority:(NSOperationQueuePriority)priority
 notifyCompleteBeforRealFetch:(BOOL)notifyComplete
                  notifyError:(BOOL)notifyError
                       isFull:(BOOL) full
              forceLoadNative:(BOOL)forceLoadNative
                      isWenda:(BOOL)isWenda
{
    if(!article.managedObjectContext)
    {
        SSLog(@"%s, invalid article:%@", __PRETTY_FUNCTION__, article);
        return;
    }
    
    if (notifyComplete && [article isContentFetchedWithForceLoadNative:forceLoadNative] && ![article.articleDeleted boolValue]) {
        [self notifyFinish:@{@"data" : article}];
    }
    
    [self tryFetchDetailForArticle:article withOperationPriority:priority notifyError:notifyError atIndex:0 processedError:nil isFull:full isWenda:isWenda];
}

- (void)fetchDetailForArticle:(Article *)article withOperationPriority:(NSOperationQueuePriority)priority notifyCompleteBeforRealFetch:(BOOL)notifyComplete notifyError:(BOOL)notifyError forceLoadNative:(BOOL)forceLoadNative
{
    [self fetchDetailForArticle:article
          withOperationPriority:priority
   notifyCompleteBeforRealFetch:notifyComplete
                    notifyError:notifyError
                forceLoadNative:forceLoadNative
                        isWenda:NO];
}

- (void)fetchDetailForArticle:(Article *)article
        withOperationPriority:(NSOperationQueuePriority)priority
 notifyCompleteBeforRealFetch:(BOOL)notifyComplete
                  notifyError:(BOOL)notifyError
              forceLoadNative:(BOOL)forceLoadNative
                      isWenda:(BOOL)isWenda
{
    [self fetchDetailForArticle:article withOperationPriority:priority notifyCompleteBeforRealFetch:notifyComplete notifyError:notifyError isFull:[NewsFetchArticleDetailManager needUseFullAPI:article] forceLoadNative:forceLoadNative isWenda:isWenda];
}

- (void)fetchDetailForArticle:(Article *)article withOperationPriority:(NSOperationQueuePriority)priority notifyError:(BOOL)notifyError
{
    [self fetchDetailForArticle:article withOperationPriority:priority notifyCompleteBeforRealFetch:NO notifyError:notifyError forceLoadNative:NO];
}

//新方法
- (void)fetchDetailForArticle:(Article *)article withPriority:(NSOperationQueuePriority)priority forceLoadNative:(BOOL)force completion:(NewsFetchArticleDetailCompletion)completion; {
    if ([article isContentFetchedWithForceLoadNative:force] && ![article.articleDeleted boolValue]) {
        if (completion) {
            completion(article, nil);
        }
    }
    
    [self tryFetchDetailForArticle:article withOperationPriority:priority atIndex:0 processedError:nil isFull:[NewsFetchArticleDetailManager needUseFullAPI:article] isWenda:NO completion:completion];
}

- (void)tryFetchDetailForArticle:(Article *)article withOperationPriority:(NSOperationQueuePriority)priority atIndex:(NSUInteger)index processedError:(NSError *)error isFull:(BOOL)full isWenda:(BOOL)isWenda completion:(NewsFetchArticleDetailCompletion)completion {
    NSString * requestURL = nil;
    if (isWenda) {
        requestURL = [self wendaDetailUrlStringAtIndex:index answerID:article.groupModel.groupID];
    } else {
        requestURL = [self articleDetailURLStringAtIndex:index Article:article isFull:full];
    }
    
    if (!requestURL) {
        if (completion) {
            completion(article, error? :[NSError errorWithDomain:kCommonErrorDomain
                                                            code:kInvalidSeverStatusErrorCode
                                                        userInfo:[NSDictionary dictionaryWithObject:kNetworkConnectionErrorTipMessage forKey:kErrorDisplayMessageKey]]);
        }
        return;
    }
    
    __weak typeof(self) wself = self;
    
    __block TTHttpTask *task = [[TTNetworkManager shareInstance] requestForJSONWithURL:requestURL params:nil method:@"GET" needCommonParams:YES requestSerializer:nil responseSerializer:nil autoResume:NO callback:^(NSError *error, id jsonObj) {
        __strong typeof(self) sself = wself;
        if (!sself) {
            return;
        }
        ENTER;
        [sself.operations removeObject:task];
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:article.groupModel.groupID forKey:@"group_id"];
        [extra setValue:article.groupModel.itemID forKey:@"item_id"];
        [extra setValue:@(article.groupModel.aggrType) forKey:@"aggr_type"];
        [extra setValue:[requestURL copy] forKey:@"url"];
        
        if (error) {
            [sself tryFetchDetailForArticle:article withOperationPriority:priority atIndex:(index + 1) processedError:error isFull:[NewsFetchArticleDetailManager needUseFullAPI:article] isWenda:isWenda completion:completion];
            
            //loadDetail错误统计
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:article.groupModel.groupID forKey:@"value"];
            [dict setValue:@0 forKey:@"error_type"];
            [dict setValue:@(error.code) forKey:@"status"];
            [dict setValue:error.localizedDescription forKey:@"error_msg"];
            [sself _sendArticleContentOrFullRequestTrackWithLabel:@"error" dict:dict];
            
            [extra setValue:@(error.code) forKey:@"err_code"];
            [extra setValue:error.localizedDescription forKey:@"err_des"];
            [[TTMonitor shareManager] trackService:@"cdn_finish_load" status:2 extra:extra];
        }
        else {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[jsonObj objectForKey:@"data"]];
            NSString *content = [data objectForKey:@"content"];
            NSArray *gallery = [data tt_arrayValueForKey:@"gallery"];
            if(article && article.managedObjectContext == nil)
            {
                SSLog(@"article no managedObjectContext");
                return;
            }
            
            [sself _checkArticleContentOrFullValidationWithArticle:article dict:data];
            
            if(article && (content || gallery))
            {
                [data removeObjectForKey:@"group_id"];
                if (data[@"item_id"]) {
                    [data setValue:[NSString stringWithFormat:@"%@", data[@"item_id"]] forKey:@"item_id"];
                }
                
                
                //此处需要判断没有删除的情况， 没有返回delete的，都认为没有被删除
                if (![[data allKeys] containsObject:@"delete"]) {
                    [data setObject:@0 forKey:@"delete"];
                }
                
                //loadDetail删除统计
                if ([[data objectForKey:@"delete"] integerValue] == 1) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:article.groupModel.groupID forKey:@"value"];
                    [sself _sendArticleContentOrFullRequestTrackWithLabel:@"delete" dict:dict];
                }
                
                [article updateWithDictionary:data];
                //[[SSModelManager sharedManager] save:nil];
                [article save];
                if (completion) {
                    completion(article, nil);
                }
                
                [[TTMonitor shareManager] trackService:@"cdn_finish_load" status:1 extra:extra];
            }
        }
    }];
    
    [self.operations addObject:task];
    
    // 直接使用NSURLSessionTaskPriorityLow赋值给task.priority在iOS8.x上会EXEC_BAD_ACCESS，NSURLSessionTaskPriorityLow不是一个float
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

- (void)tryFetchDetailForArticle:(Article *)article withOperationPriority:(NSOperationQueuePriority)priority notifyError:(BOOL)notifyError atIndex:(NSUInteger)index processedError:(NSError *)error isFull:(BOOL)full isWenda:(BOOL)isWenda{
    NSString * requestURL = nil;
    if (isWenda) {
        requestURL = [self wendaDetailUrlStringAtIndex:index answerID:article.groupModel.groupID];
    } else {
        requestURL = [self articleDetailURLStringAtIndex:index Article:article isFull:full];
    }
    if (requestURL == nil) {
        
        if (notifyError) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            if (article) {
                [dict setObject:article forKey:@"data"];
            }
            
            if (error) {
                [dict setObject:error forKey:@"error"];
            }
            else {
                NSError * e = [NSError errorWithDomain:kCommonErrorDomain
                                                  code:kInvalidSeverStatusErrorCode
                                              userInfo:[NSDictionary dictionaryWithObject:kNetworkConnectionErrorTipMessage forKey:kErrorDisplayMessageKey]];
                [dict setObject:e forKey:@"error"];
            }
            [self notifyFinish:dict];
        }
        return;
    }
    
    __weak typeof(self) wself = self;
    
    __block TTHttpTask *task = [[TTNetworkManager shareInstance] requestForJSONWithURL:requestURL params:nil method:@"GET" needCommonParams:YES requestSerializer:nil responseSerializer:nil autoResume:NO callback:^(NSError *error, id jsonObj) {
        __strong typeof(self) sself = wself;
        if (!sself) {
            return;
        }
        ENTER;
        [sself.operations removeObject:task];
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:article.groupModel.groupID forKey:@"group_id"];
        [extra setValue:article.groupModel.itemID forKey:@"item_id"];
        [extra setValue:@(article.groupModel.aggrType) forKey:@"aggr_type"];
        [extra setValue:[requestURL copy] forKey:@"url"];

        if (error) {
            [sself tryFetchDetailForArticle:article withOperationPriority:priority notifyError:notifyError atIndex:(index + 1) processedError:error isFull:[NewsFetchArticleDetailManager needUseFullAPI:article] isWenda:isWenda];
            
            //loadDetail错误统计
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:article.groupModel.groupID forKey:@"value"];
            [dict setValue:@0 forKey:@"error_type"];
            [dict setValue:@(error.code) forKey:@"status"];
            [dict setValue:error.localizedDescription forKey:@"error_msg"];
            [sself _sendArticleContentOrFullRequestTrackWithLabel:@"error" dict:dict];
            
            [extra setValue:@(error.code) forKey:@"err_code"];
            [extra setValue:error.localizedDescription forKey:@"err_des"];
            [[TTMonitor shareManager] trackService:@"cdn_finish_load" status:2 extra:extra];
        }
        else {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[(NSDictionary *)jsonObj objectForKey:@"data"]];
            NSString *content = [data objectForKey:@"content"];
            NSArray *gallery = [data tt_arrayValueForKey:@"gallery"];
            if(article && article.managedObjectContext == nil)
            {
                SSLog(@"article no managedObjectContext");
                return;
            }
            
            [sself _checkArticleContentOrFullValidationWithArticle:article dict:data];
            
            if(article && (content || gallery))
            {
                [data removeObjectForKey:@"group_id"];
                if (data[@"item_id"]) {
                    [data setValue:[NSString stringWithFormat:@"%@", data[@"item_id"]] forKey:@"item_id"];
                }
                
                
                //此处需要判断没有删除的情况， 没有返回delete的，都认为没有被删除
                if (![[data allKeys] containsObject:@"delete"]) {
                    [data setObject:@0 forKey:@"delete"];
                }
                
                //loadDetail删除统计
                if ([[data objectForKey:@"delete"] integerValue] == 1) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:article.groupModel.groupID forKey:@"value"];
                    [sself _sendArticleContentOrFullRequestTrackWithLabel:@"delete" dict:dict];
                }
                
                [article updateWithDictionary:data];
                //[[SSModelManager sharedManager] save:nil];
                [article save];
                NSMutableDictionary * notifyDict = [NSMutableDictionary dictionaryWithCapacity:2];
                [notifyDict setObject:article forKey:@"data"];
            
                [sself notifyFinish:notifyDict];
                
                [[TTMonitor shareManager] trackService:@"cdn_finish_load" status:1 extra:extra];
            }
        }
    }];

    [self.operations addObject:task];

    // 直接使用NSURLSessionTaskPriorityLow赋值给task.priority在iOS8.x上会EXEC_BAD_ACCESS，NSURLSessionTaskPriorityLow不是一个float
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewsFetchArticleDetailFinishedNotification object:self userInfo:userInfo];
    
    if (_delegate && [_delegate respondsToSelector:@selector(fetchDetailManager:finishWithResult:)]) {
        [_delegate fetchDetailManager:self finishWithResult:userInfo];
    }
 
}

#pragma mark -- Track
- (void)_checkArticleContentOrFullValidationWithArticle:(Article *)article
                                                   dict:(NSDictionary *)dict
{
    NSNumber *articleType;
    if ([dict.allKeys containsObject:@"article_type"]) {
        articleType = dict[@"article_type"];
    }
    else {
        articleType = @(article.articleType);
    }
    NSNumber *groupFlag;
    if ([dict.allKeys containsObject:@"group_flags"]) {
        groupFlag = dict[@"group_flags"];
    }
    else {
        groupFlag = article.groupFlags;
    }
    NSString *articleURL;
    if ([dict.allKeys containsObject:@"article_url"]) {
        articleURL = dict[@"article_url"];
    }
    else {
        articleURL = article.articleURLString;
    }
    NSString *content = [dict objectForKey:@"content"];
    NSArray *gallery = [dict tt_arrayValueForKey:@"gallery"];
    
    //check
    NSString *errorDesc = nil;
    if ([articleType intValue] == ArticleTypeNativeContent) {
        if (!!([groupFlag longLongValue] & kArticleGroupFlagsDetailTypeImageSubject)) {
            if (!gallery) {
                errorDesc = @"nativeGallery with no gallery";
            }
        }
        else {
            if (isEmptyString(content)) {
                errorDesc = @"nativeArticle with no content";
            }
        }
    }
    else {
        if (isEmptyString(articleURL)) {
            errorDesc = @"webContent with no articleURL";
        }
    }
    
    if (!isEmptyString(errorDesc)) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:article.groupModel.groupID forKey:@"value"];
        [dict setValue:@1 forKey:@"error_type"];
        [dict setValue:errorDesc forKey:@"error_msg"];
        [self _sendArticleContentOrFullRequestTrackWithLabel:@"error" dict:dict];
    }
}

- (void)_sendArticleContentOrFullRequestTrackWithLabel:(NSString *)label
                                                  dict:(NSDictionary *)dict
{
    [TTTrackerWrapper category:@"article"
                  event:@"detail_load"
                  label:label
                   dict:dict];
}

#pragma mark -- URL

//  根据请求的Article是否信息完整，来决定是否使用Full的API
//  返回YES， 则用full api请求
+ (BOOL)needUseFullAPI:(Article *)article
{
    if ([article.title length] == 0 || [article.displayURL length] == 0) {
        return YES;
    }
    return NO;
}

- (NSString *)articleDetailURLStringAtIndex:(NSUInteger)index Article:(Article *)article
{
    return [self articleDetailURLStringAtIndex:index Article:article isFull:[NewsFetchArticleDetailManager needUseFullAPI:article]];
}

- (NSString *)articleDetailURLStringAtIndex:(NSUInteger)index Article:(Article *)article isFull:(BOOL)full
{
    if (article.uniqueID == 0) {
        SSLog(@"error: no group ID when fetch article detail");
        return nil;
    }
    NSString * host = [self articleDetailURLHostStringAtIndex:index isFull:full];
    if ([host length] == 0) {
        return nil;
    }
    
    NSString *groupId = [NSString stringWithFormat:@"%lld", article.uniqueID];
    NSString *itemID = article.itemID;
    NSString * path = full ? [ArticleURLSetting detailFullPathString] : [ArticleURLSetting detailContentPathString];
    NSString *prefix = [NSString stringWithFormat:@"%@%@", host, path];
    NSString *commandID = nil;
    if (full) {
        commandID = @"0";
    }
    return [NewsFetchArticleDetailManager articleCDNPathWithPrefix:prefix groupID:groupId itemID:itemID aggrType:article.aggrType.integerValue  commandID:commandID];
}

- (NSString *)articleDetailURLHostStringAtIndex:(NSUInteger)index isFull:(BOOL)full
{
    if (index >= maxReRequestCount) {//最多5次重请求
        return nil;
    }
    NSArray * hosts = [NewsFetchArticleDetailManager articleDetailURLHostsIsFull:full];
    
    if (index > [hosts count] || (index == [hosts count] && index > 0)) {
        return nil;
    }
    
    NSString * hostString = nil;
    
    if (index == 0) {
        if ([hosts count] == 0) {
            hostString = [[CommonURLSetting defaultArticleDetailURLHosts] objectAtIndex:0];
        }
        else {
            hostString = [hosts objectAtIndex:0];
        }
    }
    else {
        hostString = [hosts objectAtIndex:index];
    }
    
    NSArray<NSString *> *hostComponents = [hostString componentsSeparatedByString:@"://"];
    if (hostComponents.count == 1) {
        hostString = [NSString stringWithFormat:@"http://%@", hostString];
    }
    return hostString;
}

- (NSString *)wendaDetailUrlStringAtIndex:(NSUInteger)index answerID:(NSString *)answerID
{
    if (isEmptyString(answerID) || [answerID rangeOfString:@"null"].length) {
        return nil;
    }
    NSArray * hosts = [WDSettingHelper wendaDetailURLHosts];
    
    if (index > [hosts count] || (index == [hosts count] && index > 0)) {
        return nil;
    }
    
    NSString * hostString = nil;
    
    if (index == 0) {
        if ([hosts count] == 0) {
            hostString = [[WDSettingHelper defaultWendaDetailURLHosts] firstObject];
        }
        else {
            hostString = [hosts objectAtIndex:0];
        }
    } else {
        hostString = [hosts objectAtIndex:index];
    }
    NSArray<NSString *> *hostComponents = [hostString componentsSeparatedByString:@"://"];
    if (hostComponents.count == 1) {
        hostString = [NSString stringWithFormat:@"http://%@", hostString];
    }

    return [NSString stringWithFormat:@"%@/wenda/v1/answer/detail/%@/", hostString, answerID];
}

+ (NSArray *)articleDetailURLHostsIsFull:(BOOL)full
{
    NSArray * hosts = nil;
    if (full) {
        hosts = [[NSUserDefaults standardUserDefaults] objectForKey:kArticleFullURLHostKey];
    }
    else {
        hosts = [[NSUserDefaults standardUserDefaults] objectForKey:kArticleContentURLHostKey];
    }
    
    // 默认
    if (SSIsEmptyArray(hosts)) {
        hosts = [CommonURLSetting defaultArticleDetailURLHosts];
    }
    return hosts;
}

+ (void)saveArticleDetailURLHosts:(NSArray *)array isFull:(BOOL)full
{
    if (!SSIsEmptyArray(array)) {
        if (full) {
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:kArticleFullURLHostKey];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:kArticleContentURLHostKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


// /article/full/<version>/<platform>/<group_id>/<item_id>/<aggr_type>/<command_id>
// /article/content/<version>/<platform>/<group_id>/<item_id>/<aggr_type>/
+ (NSString *)articleCDNPathWithPrefix:(NSString *)prefix
                               groupID:(NSString *)groupID
                                itemID:(NSString *)itemID
                              aggrType:(NSInteger)groupType
                             commandID:(NSString *)commandID {
    if ([prefix hasSuffix:@"/"]) {
        prefix = [prefix substringToIndex:prefix.length - 1];
    }
    NSString *version = [ArticleURLSetting detailCDNAPIVersionString];
    NSString *platform = [TTDeviceHelper isPadDevice] ? @"4" : @"2";
    NSMutableString *result = [NSMutableString stringWithCapacity:50];
    if (!isEmptyString(prefix)) {
        [result appendString:prefix];
    }
    [result appendFormat:@"/%@/%@", version, platform];
    if (!isEmptyString(groupID)) {
        [result appendFormat:@"/%@", groupID];
    } else {
        [result appendString:@"/0"];
    }
    if (!isEmptyString(itemID)) {
        [result appendFormat:@"/%@", itemID];
    } else {
        [result appendString:@"/0"];
    }
    [result appendFormat:@"/%@/", @(groupType)];
    if (!isEmptyString(commandID)) {
        [result appendString:commandID];
        [result appendString:@"/"];
    }
    
    [result appendFormat:@"%lu/", (unsigned long)[SSCommonLogic detailCDNVersion]];
    return [result copy];
}


//兼容视频重构
- (NSString *)articleDetailURLStringAtIndex:(NSUInteger)index entity:(TTVFetchEntity *)entity isFull:(BOOL)full
{
    if (entity.uniqueID == 0) {
        SSLog(@"error: no group ID when fetch article detail");
        return nil;
    }
    NSString * host = [self articleDetailURLHostStringAtIndex:index isFull:full];
    if ([host length] == 0) {
        return nil;
    }

    NSString *groupId = [NSString stringWithFormat:@"%@", entity.uniqueID];
    NSString *itemID = entity.itemID;
    NSString * path = full ? [ArticleURLSetting detailFullPathString] : [ArticleURLSetting detailContentPathString];
    NSString *prefix = [NSString stringWithFormat:@"%@%@", host, path];
    NSString *commandID = nil;
    if (full) {
        commandID = @"0";
    }
    return [NewsFetchArticleDetailManager articleCDNPathWithPrefix:prefix groupID:groupId itemID:itemID aggrType:entity.aggrType  commandID:commandID];
}


- (void)fetchVideoDetailForVideoArticle:(TTVVideoArticle *)videoArticle withRequestEntity:(TTVFetchEntity *)entity
{
    NSOperationQueuePriority priority = entity.priority;
    BOOL notifyError = entity.notifyError;
    NSInteger index = entity.index;
    NSString *itemID = entity.itemID;
    NSString *uniqueID = entity.uniqueID;
    NSInteger aggrType = entity.aggrType;
    BOOL full = entity.full;

    NSString * requestURL = [self articleDetailURLStringAtIndex:index entity:entity isFull:full];
    if (requestURL == nil) {

        if (notifyError) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            if (entity) {
                [dict setObject:entity forKey:@"data"];
            }

            NSError * e = [NSError errorWithDomain:kCommonErrorDomain
                                              code:kInvalidSeverStatusErrorCode
                                          userInfo:[NSDictionary dictionaryWithObject:kNetworkConnectionErrorTipMessage forKey:kErrorDisplayMessageKey]];
            [dict setObject:e forKey:@"error"];
            [self notifyFinish:dict];
        }
        return;
    }

    __weak typeof(self) wself = self;

    __block TTHttpTask *task = [[TTNetworkManager shareInstance] requestForJSONWithURL:requestURL params:nil method:@"GET" needCommonParams:YES requestSerializer:nil responseSerializer:nil autoResume:NO callback:^(NSError *error, id jsonObj) {
        __strong typeof(self) sself = wself;
        if (!sself) {
            return;
        }
        ENTER;
        [sself.operations removeObject:task];

        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:uniqueID forKey:@"group_id"];
        [extra setValue:itemID forKey:@"item_id"];
        [extra setValue:@(aggrType) forKey:@"aggr_type"];
        [extra setValue:[requestURL copy] forKey:@"url"];

        if (error) {
            entity.index += 1;
            [sself fetchVideoDetailForVideoArticle:videoArticle withRequestEntity:entity];
            //loadDetail错误统计
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:uniqueID forKey:@"value"];
            [dict setValue:@0 forKey:@"error_type"];
            [dict setValue:@(error.code) forKey:@"status"];
            [dict setValue:error.localizedDescription forKey:@"error_msg"];
            [sself _sendArticleContentOrFullRequestTrackWithLabel:@"error" dict:dict];

            [extra setValue:@(error.code) forKey:@"err_code"];
            [extra setValue:error.localizedDescription forKey:@"err_des"];
            [[TTMonitor shareManager] trackService:@"cdn_finish_load" status:2 extra:extra];
        }
        else {
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[(NSDictionary *)jsonObj objectForKey:@"data"]];
            NSString *content = [data objectForKey:@"content"];
            if (isEmptyString(content)) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:uniqueID forKey:@"value"];
                [dict setValue:@1 forKey:@"error_type"];
                [dict setValue:@"nativeArticle with no content" forKey:@"error_msg"];
                [TTTrackerWrapper category:@"article"
                              event:@"detail_load"
                              label:@"error"
                               dict:dict];
            }

            if(!isEmptyString(content))
            {
                [data removeObjectForKey:@"group_id"];
                if (data[@"item_id"]) {
                    [data setValue:[NSString stringWithFormat:@"%@", data[@"item_id"]] forKey:@"item_id"];
                }
                //此处需要判断没有删除的情况， 没有返回delete的，都认为没有被删除
                if (![[data allKeys] containsObject:@"delete"]) {
                    [data setObject:@0 forKey:@"delete"];
                }

                //loadDetail删除统计
                if ([[data objectForKey:@"delete"] integerValue] == 1) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:uniqueID forKey:@"value"];
                    [sself _sendArticleContentOrFullRequestTrackWithLabel:@"delete" dict:dict];
                }
                [videoArticle updateContentWithDictionary:data];
                
//                TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
//                NSArray *array = [service articlesByUniqueId:uniqueID];
//                for (TTVVideoArticle *videoArticle in array) {
//                    [videoArticle updateContentWithDictionary:data];
//                }
//                NSMutableDictionary * notifyDict = [NSMutableDictionary dictionaryWithCapacity:2];
//                [notifyDict setObject:article forKey:@"data"];
//
//                [sself notifyFinish:notifyDict];

                [[TTMonitor shareManager] trackService:@"cdn_finish_load" status:1 extra:extra];
            }
        }
    }];

    [self.operations addObject:task];

    // 直接使用NSURLSessionTaskPriorityLow赋值给task.priority在iOS8.x上会EXEC_BAD_ACCESS，NSURLSessionTaskPriorityLow不是一个float
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

@end
