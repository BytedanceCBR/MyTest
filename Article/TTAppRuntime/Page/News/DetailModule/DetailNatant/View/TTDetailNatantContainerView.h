//
//  TTDetailNatantContainerView.h
//  Article
//
//  Created by Ray on 16/4/5.
//
//

#import "SSThemed.h"
#import "ArticleInfoManager.h"
#import "TTDetailNatantViewBase.h"
#import "ExploreDetailNatantHeaderItemBase.h"
#import "Article.h"
#import "TTAdDetailViewDefine.h"

typedef NS_ENUM(NSUInteger, TTDetailNatantContainerViewSourceType) {
    TTDetailNatantContainerViewSourceType_ArtileDetail,
    TTDetailNatantContainerViewSourceType_VideoDetail,
    TTDetailNatantContainerViewSourceType_ThreadDetail,
};

@protocol TTDetailNatantContainerDatasource <NSObject>

- (nullable Article *)getCurrentArticle;
- (nullable NSString *)getCatagoryID;
- (nullable NSDictionary *)getLogPb;

@end

@interface TTDetailNatantContainerView : SSThemedView <TTAdDetailContainerViewDelegate>

@property(nonatomic, strong, nullable) NSMutableArray<TTDetailNatantViewBase *> *items;
@property(nonatomic, assign) CGFloat contentOffsetWhenLeave;
@property(nonatomic, assign) CGFloat referHeight;
@property(nonatomic, weak) id<TTDetailNatantContainerDatasource> _Nullable datasource;
@property(nonatomic, assign)TTDetailNatantContainerViewSourceType sourceType;
/**
 *
 *
 *  @param natantContentoffsetY
 *  @param isScrollUp           滑动方向（上or下）
 */
- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY isScrollUp:(BOOL)isScrollUp;

- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY scrollView:(nullable UIScrollView*)scrollView isScrollUp:(BOOL)isScrollUp;

- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY isScrollUp:(BOOL)isScrollUp shouldSendShowTrack:(BOOL)shouldSend;

- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY isScrollUp:(BOOL)isScrollUp shouldSendShowTrack:(BOOL)shouldSend style:(NSString * _Nonnull)style;

- (void)checkVisibleAtContentOffset:(CGFloat)contentOffset referViewHeight:(CGFloat)referHeight;

// 向浮层传递scrollViewDidEndDragging事件
- (void)scrollViewDidEndDraggingAtContentOffset:(CGFloat)contentOffset referViewHeight:(CGFloat)referHeight;

- (void)reloadData:(nullable id)object;

- (void)removeObject:(nonnull id)obj;

- (void)insertObject:(nonnull id)obj atIndex:(NSUInteger)index;

- (void)resetAllRelatedItemsWhenNatantDisappear;

- (void)forceReloadUI;
@end
