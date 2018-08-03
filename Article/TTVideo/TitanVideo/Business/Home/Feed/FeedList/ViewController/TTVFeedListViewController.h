//
//  TTVFeedListViewController.h
//  Article
//
//  Created by panxiang on 2017/3/27.
//
//

#import <Foundation/Foundation.h>
#import "SSViewControllerBase.h"
#import "TTVideoFeedListParameter.h"

@class TTCategory;
@class TTVPlayVideo;
@protocol TTVFeedListViewControllerDelegate <NSObject>
@optional
/**
 *  开始加载
 */
- (void)feedDidStartLoad;
/**
 *  加载完成
 *  @param finish   是否已经完全结束(存在先回掉本地加载finish，在回掉远端加载的情况)
 */
- (void)feedDidFinishLoadIsFinish:(BOOL)finish isUserPull:(BOOL)userPull;
/**
 *  取消加载
 */
- (void)feedRequestDidCancelRequest;
/**
 *  点击status bar时候，系统触发列表回到顶部
 */
- (void)feedViewDidWillScrollToTop;

@end

@interface TTVFeedListViewController : SSViewControllerBase
@property(nonatomic, weak)id<TTVFeedListViewControllerDelegate>delegate;
@property(nonatomic, strong ,readonly) UITableView *tableView;
@property(nonatomic, assign)BOOL refreshShouldLastReadUpate;
@property(nonatomic, assign ,readonly)NSUInteger refer;
//本次stream刷新方式
@property(nonatomic, assign)TTReloadType reloadFromType;
@property (nonatomic, assign) BOOL isVideoTabCategory;   //是否是videoTab的子频道, defaults to YES;
@property (nonatomic, strong) NSString * enterType;

- (void)prepareForReuse;
- (void)pullAndRefresh;
- (void)scrollToTopEnable:(BOOL)enable;
- (void)scrollToTopAnimated:(BOOL)animated;
- (void)clearListContent;
- (void)willAppear;
- (void)didAppear;
- (void)willDisappear;
- (void)didDisappear;
- (void)clickVideoTabbarWithCategory:(TTCategory *)category hasTip:(BOOL)hasTip;
- (void)clickCategorySelectorViewWithCategory:(TTCategory *)category hasTip:(BOOL)hasTip;
//在父类dealloc中调用,ugly code ， 不掉用有内存问题，之后修复
- (void)removeDelegates;
- (void)refreshFeedListForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(TTReloadType)fromType getRemoteWhenLocalEmpty:(BOOL)getRemoteWhenLocalEmpty;

#pragma protected
@property(nonatomic, retain)NSString * categoryID;  // 频道ID

@property(nonatomic, assign)BOOL isDisplayView;//预加载为NO 正常请求为YES

- (void)fetchFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote getMore:(BOOL)getMore;
- (void)listViewWillEnterForground;
- (void)listViewWillEnterBackground;
- (void)tryFetchTipIfNeed;

- (void)setListTopInset:(CGFloat)topInset BottomInset:(CGFloat)bottomInset;

- (void)removeExpireADs;

- (void)reloadListViewWithVideoPlaying;

- (BOOL)tt_hasValidateData;
- (NSString *)localCacheKey;

- (void)attachVideoIfNeededForCellWithUniqueID:(NSString *)uniqueID playingVideo:(TTVPlayVideo *)playingVideo;

@end



