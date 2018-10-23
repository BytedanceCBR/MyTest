//
//  ExploreMixedListBaseView.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-14.
//
//

#import "SSViewBase.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreFetchListManager.h"
#import "ListDataHeader.h"
#import "ExploreFetchListDefines.h"
#import <Lottie/Lottie.h>

@interface LOTAnimationView (Refresh)
- (void)startLoadingAnimation;
@end

@protocol ExploreMixedListBaseViewDelegate;

//extern const NSUInteger ExploreMixedListBaseViewSectionUploadingCells;
//extern const NSUInteger ExploreMixedListBaseViewSectionFunctionAreaCells;
extern const NSUInteger ExploreMixedListBaseViewSectionExploreCells;

extern void tt_listView_preloadWebRes(Article *article, NSDictionary *rawAdData);

@interface ExploreMixedListBaseView : SSViewBase
#pragma public
@property(nonatomic, retain)UITableView * listView;
@property(nonatomic, retain, readonly)ExploreFetchListManager * fetchListManager;
@property(nonatomic, weak)id<ExploreMixedListBaseViewDelegate>delegate;
@property(nonatomic, retain)NSString * umengEventName;
@property(nonatomic, assign)BOOL refreshShouldLastReadUpate;
@property(nonatomic, assign) BOOL isInVideoTab;
//@property(nonatomic, assign) BOOL isEditButtonHighlighted;/*5.8.4版本做统计用，仅收藏模块需要，后续版本随时可能删掉*/
//本次stream刷新方式
@property(nonatomic, assign)ListDataOperationReloadFromType refreshFromType;

@property(nonatomic, assign)BOOL shouldShowRefreshButton;   //当前出现的lastRead是否显示刷新按钮

- (id)initWithFrame:(CGRect)frame listType:(ExploreOrderedDataListType)listType listLocation:(ExploreOrderedDataListLocation)listLocation;

- (void)pullAndRefresh;
- (void)scrollToTopEnable:(BOOL)enable;
- (void)cancelAllOperation;
- (void)scrollToTopAnimated:(BOOL)animated;
- (void)clearListContent;

//在父类dealloc中调用,ugly code ， 不掉用有内存问题，之后修复
- (void)removeDelegates;

#pragma protected
@property(nonatomic, assign)ExploreOrderedDataListType listType;
@property(nonatomic, assign)ExploreOrderedDataListLocation listLocation;
@property(nonatomic, retain)NSString * categoryID;  // 频道ID
@property(nonatomic, retain)NSString * concernID;   // 关心ID
@property(nonatomic, strong)NSString * concernName;   // 关心ID

//混排列表api类型
@property(nonatomic, assign)ExploreFetchListApiType apiType;

@property(nonatomic, strong) LOTAnimationView *animationView;

//1:入口是频道主页 2:入口是关心主页
@property(nonatomic, assign)NSUInteger refer;

@property(nonatomic, retain)NSString * movieCommentVideoID; //影评的视频Tab使用的ID
@property(nonatomic, retain)NSString * movieCommentEntireID;// 影评的全部Tab使用的ID

@property(nonatomic, assign)BOOL isDisplayView;
@property(nonatomic, assign)BOOL specialConcernPage;//特殊关心主页
- (void)setExternalCondtion:(NSDictionary *)externalRequestCondtion;
- (void)fetchFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote getMore:(BOOL)getMore;
- (void)listViewWillEnterForground;
- (void)listViewWillEnterBackground;
- (void)tryFetchTipIfNeedWithForce:(BOOL)force;
//清除tab架构第一个tab 的badge，调用仅对tab架构有效
//- (void)clearFirstTabBarTipIfNeed;

//#pragma mark - trackEvent
//
//- (void)trackEventForLabel:(NSString *)label;

- (void)scrollToBottomAndLoadmore;

- (void)setListTopInset:(CGFloat)topInset BottomInset:(CGFloat)bottomInset;

- (void)removeExpireADs;

- (void)reloadListViewWithVideoPlaying;

- (BOOL)tt_hasValidateData;

@end

@protocol ExploreMixedListBaseViewDelegate <NSObject>
@optional
- (void)mixListView:(ExploreMixedListBaseView *)listView didSelectRowAtIndex:(NSIndexPath *)path;
//- (void)mixListView:(ExploreMixedListBaseView *)listView didFinishWithFetchedItems:(NSArray *)fetchedItems operationContext:(id)operationContext error:(NSError *)error;
/**
 *  开始加载
 */
- (void)mixListViewDidStartLoad:(ExploreMixedListBaseView *)listView;
/**
 *  加载完成
 *
 *  @param listView 列表
 *  @param finish   是否已经完全结束(存在先回掉本地加载finish，在回掉远端加载的情况)
 */
- (void)mixListViewFinishLoad:(ExploreMixedListBaseView *)listView isFinish:(BOOL)finish isUserPull:(BOOL)userPull;
/**
 *  取消加载
 *
 *  @param listView 列表
 */
- (void)mixListViewCancelRequest:(ExploreMixedListBaseView *)listView;

/**
 *  点击status bar时候，系统触发列表回到顶部
 */
- (void)mixListViewWillScrollToTop:(ExploreMixedListBaseView *)listView;

/**
 *  点击"刚刚看到这里 点击刷新"，将要刷新
 */
- (void)mixListViewDidSelectLastReadCellWillBeginRefresh:(ExploreMixedListBaseView *)listView;

/**
 *  点击"刚刚看到这里 点击刷新"，开始刷新
 */
- (void)mixListViewDidSelectLastReadCellDidBeginRefresh:(ExploreMixedListBaseView *)listView;
@end

