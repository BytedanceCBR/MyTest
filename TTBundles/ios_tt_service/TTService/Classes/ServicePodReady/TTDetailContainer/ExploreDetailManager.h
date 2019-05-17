//
//  ExploreDetailManager.h
//  Article
//
//  Created by Zhang Leonardo on 14-12-26.
//
//

#import <Foundation/Foundation.h>
#import "Article.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTIndicatorView.h"

@protocol ExploreDetailManagerDelegate;

@interface ExploreDetailManager : NSObject
@property(nonatomic, weak, nullable)id<ExploreDetailManagerDelegate> delegate;
@property(nonatomic, retain, readonly, nullable)NSString *eventLabel;
@property(nonatomic, copy,nullable)NSString * adLogExtra;
/** 设置是否是导流页超时从而加载转码页 */
@property(nonatomic, assign)BOOL forceLoadNativeContent;

@property(nonatomic, copy) NSString * _Nullable originalSchema;

- (nullable id)initWithArticle:(nullable Article *)article
          orderedData:(nullable ExploreOrderedData *)orderedData
      umengEventLabel:(nullable NSString *)eventLabel
            adOpenUrl:(nullable NSString *)adOpenUrl
           adLogExtra:(nullable NSString *)adLogExtra
            condition:(nullable NSDictionary *)dict;

- (void)setHasLoadedArticle;
- (void)updateArticleByData:(nullable NSDictionary *)dict;
- (void)extraTrackerDic:(nullable NSDictionary *)dic;
@end

////////////////////////////////////////////////////////////////////////////////////////

@protocol ExploreDetailManagerDelegate <NSObject>
@optional

/**
 *  显示一个提示的tip
 *
 *  @param manager 当前的manager
 *  @param tipMsg  需要提示的字符串
 */
- (void)detailManager:(nullable ExploreDetailManager *)manager showTipMsg:(nullable NSString *)tipMsg;

/**
 *  显示一个提示及icon的tip
 *
 *  @param manager 当前的manager
 *  @param tipMsg  需要提示的字符串
 */
- (void)detailManager:(nullable ExploreDetailManager *)manager showTipMsg:(nullable NSString *)tipMsg icon:(nullable UIImage *)image;

/**
 *  显示一个提示及icon的tip，以及展示完成后的回调
 *
 *  @param manager 当前的manager
 *  @param tipMsg  需要提示的字符串
 *  @param handler 弹窗消失后的block
 */
- (void)detailManager:(nullable ExploreDetailManager *)manager showTipMsg:(nullable NSString *)tipMsg icon:(nullable UIImage *)image dismissHandler:(nullable DismissHandler)handler;

@end

////////////////////////////////////////////////////////////////////////////////////////

@interface ExploreDetailManager(ExploreDetailCurrentStatusCategory)

/**
 * 新增方法，修改收藏状态，吊起强制&非强制登录弹窗
 */
- (void)changeFavoriteButtonClicked:(double)readPct viewController:(UIViewController * _Nullable)viewController;


@end

////////////////////////////////////////////////////////////////////////////////////////

@interface ExploreDetailManager(ExploreDetailStayPageTracker)

- (void)startStayTracker;
- (void)endStayTracker;
- (float)currentStayDuration;

@end

////////////////////////////////////////////////////////////////////////////////////////
#define kEventLabel4ImageRecommendShow    @"related_show"
#define kEventLabel4ImageRecommendClicked @"click_related"
