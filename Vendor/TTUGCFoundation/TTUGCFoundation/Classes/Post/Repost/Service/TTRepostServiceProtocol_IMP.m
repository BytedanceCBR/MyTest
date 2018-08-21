//
//  TTRepostServiceProtocol_IMP.m
//  Article
//
//  Created by jinqiushi on 2018/1/31.
//

#import "TTRepostServiceProtocol_IMP.h"
#import "TTRepostService.h"
#import "TTRepostOriginModels.h"
#import <Article.h>
#import <Thread.h>
#import <TTShortVideoModel.h>
#import <WDAnswerEntity.h>

@implementation TTRepostServiceProtocol_IMP

+ (instancetype)sharedInstance {
    static TTRepostServiceProtocol_IMP *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTRepostServiceProtocol_IMP alloc] init];
    });
    
    return instance;
}

#pragma mark - TTRepostServiceProtocol

- (NSDictionary *)repostParamsWithOriginArticle:(Article *)originArticle {
    TTRepostOriginArticle *repostOriginArticle = [[TTRepostOriginArticle alloc] initWithArticle:originArticle];
    
    return [TTRepostService repostParamsWithRepostType:TTThreadRepostTypeArticle
                              originArticle:repostOriginArticle
                               originThread:nil
               originShortVideoOriginalData:nil
                          originWendaAnswer:nil
                          operationItemType:TTRepostOperationItemTypeArticle
                            operationItemID:originArticle.itemID
                             repostSegments:nil];
}

- (void)showRepostVCWithOriginArticle:(Article *)originArticle {
    NSDictionary *repostParams = [self repostParamsWithOriginArticle:originArticle];
    [self showRepostVCWithRepostParams:repostParams];
}

- (NSDictionary *)repostParamsWithOriginThread:(Thread *)originThread {
    TTRepostOriginThread *repostOriginThread = [[TTRepostOriginThread alloc] initWithThread:originThread];
    
    return [TTRepostService repostParamsWithRepostType:TTThreadRepostTypeThread
                              originArticle:nil
                               originThread:repostOriginThread
               originShortVideoOriginalData:nil
                          originWendaAnswer:nil
                          operationItemType:TTRepostOperationItemTypeThread
                            operationItemID:originThread.threadId
                             repostSegments:nil];
}

- (void)showRepostVCWithOriginThread:(Thread *)originThread {
    NSDictionary *repostParams = [self repostParamsWithOriginThread:originThread];
    [self showRepostVCWithRepostParams:repostParams];
}

- (NSDictionary *)repostParamsWithOriginShortVideo:(TTShortVideoModel *)originShortVideo {
    TTRepostOriginShortVideoOriginalData *repostOriginShortVideo = [[TTRepostOriginShortVideoOriginalData alloc] initWithShortVideoModel:originShortVideo];
    
    return [TTRepostService repostParamsWithRepostType:TTThreadRepostTypeShortVideo
                              originArticle:nil
                               originThread:nil
               originShortVideoOriginalData:repostOriginShortVideo
                          originWendaAnswer:nil
                          operationItemType:TTRepostOperationItemTypeShortVideo
                            operationItemID:originShortVideo.itemID
                             repostSegments:nil];
}

- (void)showRepostVCWithOriginShortVideo:(TTShortVideoModel *)originShortVideo {
    NSDictionary *repostParams = [self repostParamsWithOriginShortVideo:originShortVideo];
    [self showRepostVCWithRepostParams:repostParams];
}

- (NSDictionary *)repostParamsWithOriginAnswer:(WDAnswerEntity *)originAnswer {
    TTRepostOriginTTWendaAnswer *repostOriginWendaAnswer = [[TTRepostOriginTTWendaAnswer alloc] initWithAnswerEntity:originAnswer];
    
    return [TTRepostService repostParamsWithRepostType:TTThreadRepostTypeWendaAnswer
                              originArticle:nil
                               originThread:nil
               originShortVideoOriginalData:nil
                          originWendaAnswer:repostOriginWendaAnswer
                          operationItemType:TTRepostOperationItemTypeWendaAnswer
                            operationItemID:originAnswer.ansid
                             repostSegments:nil];
}

- (void)showRepostVCWithOriginAnswer:(WDAnswerEntity *)originAnswer {
    NSDictionary *repostParams = [self repostParamsWithOriginAnswer:originAnswer];
    [self showRepostVCWithRepostParams:repostParams];
}

- (void)showRepostVCWithRepostParams:(NSDictionary *)repostParams {
    [TTRepostService showRepostVCWithRepostParams:repostParams];
}

- (void)directSendRepostWithRepostParams:(NSDictionary *)repostParams
                      baseViewController:(UIViewController *)baseViewController
                               trackDict:(NSDictionary *)trackDict {
    [TTRepostService directSendRepostWithRepostParams:repostParams
                                   baseViewController:baseViewController
                                            trackDict:trackDict];
}

@end
