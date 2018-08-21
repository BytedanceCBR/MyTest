//
//  NewsFetchArticleDetailManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-10-27.
//

#import <Foundation/Foundation.h>
#import "Article.h"

#define kNewsFetchArticleDetailFinishedNotification @"kNewsFetchArticleDetailFinishedNotification"


@interface TTVFetchEntity : NSObject
@property (nonatomic, assign) BOOL full;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL notifyError;
@property (nonatomic, assign) NSOperationQueuePriority priority;
@property(nonatomic, copy) NSString *itemID;
@property(nonatomic, copy) NSString *uniqueID;
@property(nonatomic, assign) NSInteger aggrType;

@end
typedef void (^NewsFetchArticleDetailCompletion)(Article *article, NSError *error);

@protocol NewsFetchArticleDetailManagerDelegate ;

@class TTVVideoArticle;
@interface NewsFetchArticleDetailManager : NSObject
@property(nonatomic, assign)double threadPriority;//default is 0.5
@property(nonatomic, weak)id<NewsFetchArticleDetailManagerDelegate> delegate;

+ (id)sharedManager;

//notifyComplete 如果Article本身是完整的，在真正请求获取前，发送kNewsFetchArticleDetailFinishedNotification和回调通知
- (void)fetchDetailForArticle:(Article *)article withOperationPriority:(NSOperationQueuePriority)priority notifyCompleteBeforRealFetch:(BOOL)notifyComplete notifyError:(BOOL)notifyError forceLoadNative:(BOOL)forceLoadNative;
- (void)fetchDetailForArticle:(Article *)article withOperationPriority:(NSOperationQueuePriority)priority notifyCompleteBeforRealFetch:(BOOL)notifyComplete notifyError:(BOOL)notifyError forceLoadNative:(BOOL)forceLoadNative isWenda:(BOOL)isWenda;

- (void)fetchDetailForArticle:(Article *)article withOperationPriority:(NSOperationQueuePriority)priority notifyError:(BOOL)notifyError;

- (void)fetchDetailForArticle:(Article *)article withPriority:(NSOperationQueuePriority)priority forceLoadNative:(BOOL)force completion:(NewsFetchArticleDetailCompletion)completion;

- (void)cancelAllRequests;
- (void)suspendAllRequests;
- (void)resumeAllRequests;

+ (void)saveArticleDetailURLHosts:(NSArray *)array isFull:(BOOL)full;
+ (NSArray *)articleDetailURLHostsIsFull:(BOOL)full;

// /article/full/<version>/<platform>/<group_id>/<item_id>/<aggr_type>/<command_id>
// /article/content/<version>/<platform>/<group_id>/<item_id>/<aggr_type>/
+ (NSString *)articleCDNPathWithPrefix:(NSString *)prefix
                               groupID:(NSString *)groupID
                                itemID:(NSString *)itemID
                              aggrType:(NSInteger)groupType
                             commandID:(NSString *)commandID;

- (void)fetchVideoDetailForVideoArticle:(TTVVideoArticle *)videoArticle withRequestEntity:(TTVFetchEntity *)entity;
@end

@protocol NewsFetchArticleDetailManagerDelegate <NSObject>

@optional
- (void)fetchDetailManager:(NewsFetchArticleDetailManager *)manager finishWithResult:(NSDictionary *)result;

@end
