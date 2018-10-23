//
//  TTRepostViewController.h
//  Article
//
//  Created by 王霖 on 2017/5/18.
//
//

#import "SSViewControllerBase.h"
#import "Thread.h"
#import "TTRepostContentSegment.h"
#import "WDAnswerEntity.h"

@class Article;
@class UGCVideo;
@class TTRepostOriginArticle,TTRepostOriginThread,TTRepostOriginShortVideoOriginalData,TTRepostOriginTTWendaAnswer;

@interface TTRepostViewController : SSViewControllerBase

+ (TTRepostViewController *)presentRepostToWeitoutiaoViewControllerWithRepostType:(TTThreadRepostType)repostType
                                                                originWendaAnswer:(TTRepostOriginTTWendaAnswer *)originWendaAnswer
                                                                  operationItemID:(NSString *)operationItemID
                                                                   repostSegments:(NSArray<TTRepostContentSegment *> *)segments;

+ (TTRepostViewController *)presentRepostToWeitoutiaoViewControllerWithRepostType:(TTThreadRepostType)repostType
                                                                    originArticle:(TTRepostOriginArticle *)originArticle
                                                                     originThread:(TTRepostOriginThread *)originThread
                                                                   originShortVideoOriginalData:(TTRepostOriginShortVideoOriginalData *)originShortVideoOriginalData
                                                                operationItemType:(TTRepostOperationItemType)operationItemType
                                                                  operationItemID:(NSString *)operationItemID
                                                                   repostSegments:(NSArray<TTRepostContentSegment *> *)segments;

+ (TTRepostViewController *)presentRepostToWeitoutiaoViewControllerWithRepostType:(TTThreadRepostType)repostType
                                                                    originArticle:(TTRepostOriginArticle *)originArticle
                                                                     originThread:(TTRepostOriginThread *)originThread
                                                                   originShortVideoOriginalData:(TTRepostOriginShortVideoOriginalData *)originShortVideoOriginalData
                                                                originWendaAnswer:(TTRepostOriginTTWendaAnswer *)originWendaAnswer
                                                                operationItemType:(TTRepostOperationItemType)operationItemType
                                                                  operationItemID:(NSString *)operationItemID
                                                                   repostSegments:(NSArray<TTRepostContentSegment *> *)segments;

@end
