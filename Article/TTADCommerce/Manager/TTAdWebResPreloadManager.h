//
//  TTAdWebResPreloadManager.h
//  Article
//
//  Created by yin on 2017/1/13.
//
//

#import <Foundation/Foundation.h>
#import "TTAdResPreloadModel.h"
#import "ArticleHeader.h"
#import "ExploreOrderedData+TTBusiness.h"


@interface TTAdWebResPreloadManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, assign) BOOL isWebTargetPreload;

- (NSInteger)preloadTotalAdID:(NSString*)adid;

- (NSInteger)preloadNumInWebView;

- (NSInteger)matchNumInWebView;


/**
 Feed Cell 进入预加载流程
 @param orderData 原始广告数据
 @param article 原始广告数据
 */
- (void)preloadResource:(ExploreOrderedData*)orderData;
- (BOOL)hasPreloadResource:(NSString *)ad_id;
- (void)synchronizeReourceModel:(TTAdResPreloadDataModel*)dataModel;

- (NSDictionary*)getResourceModelDict;

- (BOOL)isFirstEnterPageAdid:(NSString*)adid;

- (void)startCaptureAdWebResRequest;

- (void)stopCaptureAdWebResRequest;

- (void)finishCaptureThePage;

- (void)clearCache;

@end

@interface TTAdWebResURLProtocol : NSURLProtocol



@end

