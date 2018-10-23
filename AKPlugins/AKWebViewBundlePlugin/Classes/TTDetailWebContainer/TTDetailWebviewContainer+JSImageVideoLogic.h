//
//  TTDetailWebviewContainer+JSImageVideoLogic.h
//  Article
//
//  Created by yuxin on 4/12/16.
//
//

#import "TTDetailWebviewContainer.h"

@interface TTDetailWebviewContainer (JSImageVideoLogic) <NewsDetailImageDownloadManagerDelegate,TTVBaseDemandPlayerDelegate>

- (BOOL)redirectRequestCanOpen:(NSURLRequest *)requestURL;

- (BOOL)redirectLocalRequest:(NSURL*)requestURL;

- (void)p_addWebViewVideoObservers;
- (CGRect)p_frameFromObject:(id)frameID;
- (void)layoutMovieViewsIfNeeded;
/**
 *  注册webView加载正文图片行为
 *
 *  @param largeImageModels 大图数组
 *  @param thumbImageModels 缩略图数组
 *  @param block            取到图片数据后需要调用的js回调
 */
- (void)tt_registerWebImageWithLargeImageModels:(NSArray <TTImageInfosModel *> *)largeImageModels
                               thumbImageModels:(NSArray <TTImageInfosModel *> *)thumbImageModels
                                  loadImageMode:(NSNumber *)imageMode
                     showOriginForThumbIfCached:(BOOL)showOriginForThumbIfCached
                        evaluateJsCallbackBlock:(TTLoadWebImageJsCallbackBlock)jsCallbackBlock;

- (void)tt_registerCarouselBackUpdateWithCallback:(void (^)(NSInteger index, CGRect updatedFrame))jsCallback;

/**
 *  注册webView加载正文视频行为
 *
 *  @param movieViewModel 需要的数据 例如:
 NSMutableDictionary *dic = [NSMutableDictionary dictionary];
 [dic setValue:[NSNumber numberWithBool:YES] forKey:@"isInDetail"];
 [dic setValue:_detailModel.article.groupModel.itemID forKey:@"itemID"];
 [dic setValue:_detailModel.article.groupModel.groupID forKey:@"groupID"];
 [dic setValue:@(_detailModel.article.groupModel.aggrType) forKey:@"aggrType"];
 [dic setValue:aID forKey:@"aID"];
 [dic setValue:_detailModel.categoryID forKey:@"cID"];
 [dic setValue:_detailModel.article.title forKey:@"movieTitle"];
 [dic setValue:_detailModel.adLogExtra forKey:@"logExtra"];
 [dic setValue:_detailModel.clickLabel forKey:@"gdLabel"];
 [dic setValue:[_detailModel.article videoThirdMonitorUrl] forKey:@"videoThirdMonitorUrl"];
 [dic setValue:_detailModel.orderedData.adClickTrackURLs forKey:@"adClickTrackURLs"];
 [dic setValue:_detailModel.orderedData.adPlayOverTrackUrls forKey:@"adPlayOverTrackUrls"];
 [dic setValue:_detailModel.orderedData.adPlayEffectiveTrackUrls forKey:@"adPlayEffectiveTrackUrls"];
 [dic setValue:_detailModel.orderedData.adPlayActiveTrackUrls forKey:@"adPlayActiveTrackUrls"];
 [dic setValue:_detailModel.orderedData.adPlayTrackUrls forKey:@"adPlayTrackUrls"];
 [dic setValue:@(_detailModel.orderedData.effectivePlayTime) forKey:@"effectivePlayTime"];
 */
- (void)tt_registerWebVideoWithMovieViewInfo:(NSDictionary *)movieViewModel;

@end
