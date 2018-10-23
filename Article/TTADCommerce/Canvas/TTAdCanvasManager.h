//
//  TTAdCanvasManager.h
//  Article
//
//  Created by yin on 2016/12/13.
//
//

#import "ExploreOrderedData+TTBusiness.h"
#import "TTAdCanvasLayoutModel.h"
#import "TTAdCanvasModel.h"
#import "TTAdSingletonManager.h"
#import "TTRNView.h"
#import <Foundation/Foundation.h>
#import <TTShareManager.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TTAdAnimationCell;

@interface TTAdCanvasManager : NSObject<TTAdSingletonProtocol, TTShareManagerDelegate>

Singleton_Interface(TTAdCanvasManager)

@property (nonatomic, strong, nullable) TTRNView *rnView;

- (TTRNView *)createRNView;

- (void)destroyRNView;

/**
 下发bundle成功,预加载沉浸式页面
 */
- (void)preCreateCanvasView;

/**
 沉浸式cell进入feed可视窗口,预加载沉浸式页面
 */
- (void)preCreateCanvasView:(ExploreOrderedData*)orderData;


- (void)requestCanvasData;


/**
 获取缓存的所有广告计划

 @return 缓存的canvas广告model Array
 */
+ (NSDictionary *)getCacheCanvasDict;

/**
 获取上次接口返回model

 @return 接口返回model
 */
+ (TTAdCanvasModel *)getCanvasModel;

/**
 获取当前广告projectModel

 @param ad_id 广告id
 @return 当前广告model
 */
+ (TTAdCanvasProjectModel *)getMatchProjctModel:(NSString *)ad_id;

+ (BOOL)filterCanvas:(ExploreOrderedData *)orderData;

- (void)clearModelCache;

- (BOOL)canOpenCanvasOrderData:(ExploreOrderedData*)orderData model:(TTAdCanvasProjectModel *)projectModel error:(NSError **)error;
- (BOOL)showCanvasView:(ExploreOrderedData*)orderData cell:(UITableViewCell*)cell;

- (void)canvasShare;

+ (void)mergeProjects:(NSArray<TTAdCanvasProjectModel *> *) projectModels;
+ (void)mergeProject:(TTAdCanvasProjectModel *)projectModel;

- (void)setRNFatalHandler:(TTRNFatalHandler)handler;

- (void)canvasCall;

- (void)trackCanvasTag:(NSString *)tag label:(NSString*)label dict:(NSDictionary * _Nullable)dict;

- (void)trackCanvasRN:(NSDictionary *)dict;

- (TTAdCanvasJsonLayoutModel *)parseJsonLayout:(NSDictionary *)layoutInfo;

+ (NSDictionary *)parseJsonDict:(TTAdCanvasProjectModel*)projectModel;

@end

NS_ASSUME_NONNULL_END
