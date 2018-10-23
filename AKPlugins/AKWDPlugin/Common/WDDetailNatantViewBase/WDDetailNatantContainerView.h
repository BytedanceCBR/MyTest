//
//  WDDetailNatantContainerView.h
//  Article
//
//  Created by Ray on 16/4/5.
//
//

#import "SSThemed.h"
#import "WDAnswerEntity.h"
#import "WDDetailNatantViewBase.h"

#import "TTAdDetailViewDefine.h"

typedef NS_ENUM(NSUInteger, WDDetailNatantContainerViewSourceType) {
    WDDetailNatantContainerViewSourceType_ArtileDetail,
    WDDetailNatantContainerViewSourceType_VideoDetail
};

@protocol WDDetailNatantContainerDatasource <NSObject>

- (nullable WDAnswerEntity *)getCurrentArticle;

@end

@interface WDDetailNatantContainerView : SSThemedView <TTAdDetailContainerViewDelegate>

@property(nonatomic, strong, nullable) NSMutableArray<WDDetailNatantViewBase *> *items;
@property(nonatomic, assign) CGFloat contentOffsetWhenLeave;
@property(nonatomic, assign) CGFloat referHeight;
@property(nonatomic, weak) id<WDDetailNatantContainerDatasource> _Nullable datasource;
@property(nonatomic, assign)WDDetailNatantContainerViewSourceType sourceType;
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

- (void)reloadData:(nullable id)object;

- (void)removeObject:(nonnull id)obj;

- (void)insertObject:(nonnull id)obj atIndex:(NSUInteger)index;

- (void)resetAllRelatedItemsWhenNatantDisappear;
@end
