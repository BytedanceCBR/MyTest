//
//  TTUGCDetailNatantContainerViewProtocol.h
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/1/29.
//

#import <Foundation/Foundation.h>
#import "TTUGCDetailNatantViewBaseProtocol.h"
#import <TTAdDetailViewDefine.h>

typedef NS_ENUM(NSUInteger, TTUGCDetailNatantContainerViewSourceType) {
    TTUGCDetailNatantContainerViewSourceType_ArtileDetail,
    TTUGCDetailNatantContainerViewSourceType_VideoDetail,
    TTUGCDetailNatantContainerViewSourceType_ThreadDetail,
};

@protocol TTUGCDetailNatantContainerDatasource <NSObject>

- (nullable Article *)getCurrentArticle;
- (nullable NSString *)getCatagoryID;
- (nullable NSDictionary *)getLogPb;

@end

@protocol TTUGCDetailNatantContainerViewProtocol <TTAdDetailContainerViewDelegate>//主工程里相同的那份代码，这个广告的协议定的真是偷懒。

- (instancetype _Nonnull )initWithFrame:(CGRect)frame;


@property(nonatomic, strong, nullable) NSMutableArray<id<TTUGCDetailNatantViewBaseProtocol>> *items;
@property(nonatomic, assign) CGFloat contentOffsetWhenLeave;
@property(nonatomic, assign) CGFloat referHeight;
@property(nonatomic, weak) id<TTUGCDetailNatantContainerDatasource> _Nullable datasource;
@property(nonatomic, assign)TTUGCDetailNatantContainerViewSourceType sourceType;
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
