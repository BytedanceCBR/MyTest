//
//  ArticleMomentListViewBase.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-27.
//
//

#import "SSViewBase.h"
#import "ArticleTitleImageView.h"
#import "ArticleMomentManager.h"
#import "ExploreMomentListCellBase.h"
#import "SSImpressionProtocol.h"
#import "SSNavigationBar.h"
#import "ArticleDetailHeader.h"
#import "ArticleMomentRefreshTitleView.h"
#import "SSTipModel.h"

@class ArticleMomentListViewBase;
@protocol ArticleMomentListViewDelegate <NSObject>

@optional
- (void)momentListViewDidFinishPullRefresh:(ArticleMomentListViewBase *)momentListView error:(NSError*)error tip:(NSString*)tip;

- (BOOL)momentListView:(ArticleMomentListViewBase *)momentListView
  shouldDisplayMessage:(NSString *)message
              tipModel:(SSTipModel *)tipModel;

@end


@interface ArticleMomentListViewBase : SSViewBase<UITableViewDataSource, UITableViewDelegate, SSImpressionProtocol, ArticleMomentRefreshTitleViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame navigationBarHidden:(BOOL)navigationBarHidden refreshViewHidden:(BOOL)refreshViewHidden;

@property(nonatomic, retain)SSThemedTableView * listView;
@property (nonatomic, retain) SSNavigationBar * navigationBar;
@property(nonatomic, retain)SSViewBase * headerView;

@property(nonatomic, weak) id <ArticleMomentListViewDelegate> delegate;

@property(nonatomic, retain)ArticleMomentRefreshTitleView * refreshTitleView;

@property(nonatomic, assign) BOOL showTipBar;

- (void)removeRegistFromImpression;
- (void)pullAndRefresh;
- (void)reloadData;
//- (void)openLoginViewController;
- (void)showBottomSendMomentButtonIfNeed;
- (void)openPostMomentViewController;
- (void)scrollToTopCellAnimation:(BOOL)animation;
#pragma mark -- protected
- (NSString *)impressionKeyName;

- (void)refreshListUI;
- (NewsGoDetailFromSource)fromSource;
- (void)accountChanged:(NSNotification *)notification;
- (void)refreshHeaderView;
- (ArticleMomentManager *)currentManager;
- (ArticleMomentSourceType)sourceType;
- (NSString *)currentUserID;
- (NSString *)currentTalkID;
- (void)clearTalkID;

- (void)reloadDataDone:(NSError *)error;//刷新成功后会调用该方法
- (void)loadMoreDataDone;//刷新成功后会调用该方法
- (BOOL)notifyBarCouldShow;
//自身的umeng 事件
- (NSString *)currentUmentEventName;
@end
