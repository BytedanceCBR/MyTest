//
//  TTRepostServiceProtocol.h
//  Pods
//
//  Created by jinqiushi on 2018/1/30.
//

#import <Foundation/Foundation.h>

@class Article,Thread,TTShortVideoModel,WDAnswerEntity;
@protocol TTRepostServiceProtocol <NSObject>

- (void)directSendRepostWithRepostParams:(NSDictionary *)repostParams baseViewController:(UIViewController *)baseViewController trackDict:(NSDictionary *)trackDict;

- (void)showRepostVCWithRepostParams:(NSDictionary *)repostParams;

- (NSDictionary *)repostParamsWithOriginArticle:(Article *)originArticle;

- (void)showRepostVCWithOriginArticle:(Article *)originArticle;

- (NSDictionary *)repostParamsWithOriginThread:(Thread *)originThread;

- (void)showRepostVCWithOriginThread:(Thread *)originThread;

- (NSDictionary *)repostParamsWithOriginShortVideo:(TTShortVideoModel *)originShortVideo;

- (void)showRepostVCWithOriginShortVideo:(TTShortVideoModel *)originShortVideo;

- (NSDictionary *)repostParamsWithOriginAnswer:(WDAnswerEntity *)originAnswer;

- (void)showRepostVCWithOriginAnswer:(WDAnswerEntity *)originAnswer;

@end
