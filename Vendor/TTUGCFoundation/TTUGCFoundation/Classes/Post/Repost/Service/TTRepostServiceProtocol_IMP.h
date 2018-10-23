//
//  TTRepostServiceProtocol_IMP.h
//  Article
//
//  Created by jinqiushi on 2018/1/31.
//  TTRepostServiceProtocol的实现类，实现给出repostParams和展示面板、直接转发等功能。

#import <Foundation/Foundation.h>
#import <TTRepostServiceProtocol.h>
#import <TTServiceCenter.h>

@class Article, Thread, TTShortVideoModel, WDAnswerEntity;


@interface TTRepostServiceProtocol_IMP : NSObject <TTRepostServiceProtocol,TTService>

+ (instancetype)sharedInstance;

#pragma mark - TTRepostServiceProtocol

- (NSDictionary *)repostParamsWithOriginArticle:(Article *)originArticle;

- (void)showRepostVCWithOriginArticle:(Article *)originArticle;

- (NSDictionary *)repostParamsWithOriginThread:(Thread *)originThread;

- (void)showRepostVCWithOriginThread:(Thread *)originThread;

- (NSDictionary *)repostParamsWithOriginShortVideo:(TTShortVideoModel *)originShortVideo;

- (void)showRepostVCWithOriginShortVideo:(TTShortVideoModel *)originShortVideo;

- (NSDictionary *)repostParamsWithOriginAnswer:(WDAnswerEntity *)originAnswer;

- (void)showRepostVCWithOriginAnswer:(WDAnswerEntity *)originAnswer;

- (void)showRepostVCWithRepostParams:(NSDictionary *)repostParams;

- (void)directSendRepostWithRepostParams:(NSDictionary *)repostParams
                      baseViewController:(UIViewController *)baseViewController
                               trackDict:(NSDictionary *)trackDict;

@end
