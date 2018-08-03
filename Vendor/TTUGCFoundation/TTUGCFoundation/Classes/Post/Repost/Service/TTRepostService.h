//
//  TTRepostService.h
//  Article
//
//  Created by ranny_90 on 2017/9/12.
//
//  这个类干两部分事：1.针对输入信息给出转发参数。2.根据repostModel和一些其他参数，完成转发动作。

#import <Foundation/Foundation.h>
#import <TTRepostServiceProtocol.h>
#import "Thread.h"
#import <TTServiceCenter.h>

@class TTRepostOriginArticle;
@class TTRepostOriginThread;
@class TTRepostOriginShortVideoOriginalData;
@class TTRepostOriginTTWendaAnswer;
@class TTRepostContentSegment;
@class TTRepostThreadModel;
@class Article, Thread, TTShortVideoModel, WDAnswerEntity;


@interface TTRepostService : NSObject 

+ (instancetype)sharedInstance;

#pragma mark - 外部调用方法

+ (void)showRepostVCWithRepostParams:(NSDictionary *)repostParams;

+ (void)directSendRepostWithRepostParams:(NSDictionary *)repostParams
                      baseViewController:(UIViewController *)baseViewController
                               trackDict:(NSDictionary *)trackDict;

+ (NSDictionary *)repostParamsWithRepostType:(TTThreadRepostType)repostType
                               originArticle:(TTRepostOriginArticle *)originArticle
                                originThread:(TTRepostOriginThread *)originThread
                originShortVideoOriginalData:(TTRepostOriginShortVideoOriginalData *)originShortVideoOriginalData
                           originWendaAnswer:(TTRepostOriginTTWendaAnswer *)originWendaAnswer
                           operationItemType:(TTRepostOperationItemType)operationItemType
                             operationItemID:(NSString *)operationItemID
                              repostSegments:(NSArray<TTRepostContentSegment *> *)segments;

+ (void)repostAdapterWithRepostType:(TTThreadRepostType)repostType
                      originArticle:(TTRepostOriginArticle *)originArticle
                       originThread:(TTRepostOriginThread *)originThread
       originShortVideoOriginalData:(TTRepostOriginShortVideoOriginalData *)originShortVideoOriginalData
                  originWendaAnswer:(TTRepostOriginTTWendaAnswer *)originWendaAnswer
                  operationItemType:(TTRepostOperationItemType)operationItemType
                    operationItemID:(NSString *)operationItemID
                     repostSegments:(NSArray<TTRepostContentSegment *> *)segments;

+ (NSString *)coverURLWithArticle:(Article *)article;
+ (NSString *)coverURLWithThread:(Thread *)thread;
+ (NSString *)coverURLWithRepostCommonModel:(UGCRepostCommonModel *)repostCommonModel;

+ (TTRichSpanText *)richSpanWithContent:(TTRichSpanText *)richContent user:(FRCommonUserInfoStructModel *)userInfo;

#pragma mark - RepostViewController调用的方法

- (void)sendRepostWithRepostModel:(TTRepostThreadModel *)repostModel
                     richSpanText:(TTRichSpanText *)richSpanText
                  isCommentRepost:(BOOL)isCommentRepost
               baseViewController:(UIViewController *)baseViewController
                        trackDict:(NSDictionary *)trackDict
                      finishBlock:(void (^)(void))finishBlock;

- (void)trackRepostWithEvent:(NSString *)event label:(NSString *)label repostModel:(TTRepostThreadModel *)repostModel extra:(NSDictionary *)extra;

@end
