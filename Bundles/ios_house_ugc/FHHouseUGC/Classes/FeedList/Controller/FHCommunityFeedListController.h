//
//  FHCommunityFeedListController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHBaseViewController.h"
#import "FHHouseUGCHeader.h"
#import <CoreLocation/CoreLocation.h>
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import "SSImpressionManager.h"
#import "ArticleImpressionHelper.h"
//#import "FHUGCScialGroupModel.h"
//#import "TTBadgeNumberView.h"

NS_ASSUME_NONNULL_BEGIN

//@protocol CommunityGroupChatLoginDelegate <NSObject>
//
//-(void)onLoginIn;
//
//@end
//
//@protocol FHCommunityFeedListControllerDelegate <NSObject>
//
//- (void)refreshBasicInfo;
//
//@end

@interface FHCommunityFeedListController : FHBaseViewController

@property(nonatomic, assign) FHCommunityFeedListType listType;
@property(nonatomic, strong) ArticleListNotifyBarView *notifyBarView;
@property(nonatomic, strong) NSArray *dataList;
//发布按钮
@property(nonatomic, strong) UIButton *publishBtn;
////群聊按钮
//@property(nonatomic, strong) UIButton *groupChatBtn;
////群聊红泡提示按钮
//@property(nonatomic, strong) TTBadgeNumberView *bageView;

@property(nonatomic, copy) void(^publishBlock)(void);
//附加在feed上面的自定义view
@property(nonatomic, strong) UIView *tableHeaderView;
@property(nonatomic, strong) UITableView *tableView;
//是否需要下拉刷新，默认为YES
@property(nonatomic, assign) BOOL tableViewNeedPullDown;
//发布按钮距离底部的高度,默认为0
@property(nonatomic, assign) CGFloat publishBtnBottomHeight;
//发布按钮隐藏
@property(nonatomic, assign) BOOL hidePublishBtn;
//是否需要在返回这个页面时候去刷新数据
@property(nonatomic, assign) BOOL needReloadData;
//当前定位的位置
@property(nonatomic, strong) CLLocation *currentLocaton;
//小区详情页进入需要传这个参数，圈子子id
@property(nonatomic, strong) NSString *forumId;
//tab的名字,调用接口时候会传给服务器
@property(nonatomic, strong) NSString *tabName;
//小区群聊的conversation id
@property(nonatomic, strong) NSString *conversationId;
//传入以后点击三个点以后显示该数组的内容
@property(nonatomic, strong) NSArray *operations;
//当接口返回空数据的时候是否显示空态页，默认为YES
@property(nonatomic, assign) BOOL showErrorView;
//空态页具体顶部offset

//圈子详情页使用
@property (nonatomic, assign) CGFloat errorViewTopOffset;
@property (nonatomic, assign) CGFloat errorViewHeight;
@property (nonatomic, assign) BOOL notLoadDateWhenEmpty;
@property (nonatomic, assign) BOOL segmentViewHeight;
@property(nonatomic, copy) void(^beforeInsertPostBlock)(void);
//圈子信息
//@property(nonatomic, strong) FHUGCScialGroupDataModel *scialGroupData;

//@property(nonatomic, weak) id<CommunityGroupChatLoginDelegate> loginDelegate;

@property(nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;
//@property(nonatomic, weak) id<FHCommunityFeedListControllerDelegate> delegate;

- (void)showNotify:(NSString *)message ;
- (void)showNotify:(NSString *)message completion:(void(^)())completion;
//下拉刷新数据
- (void)startLoadData;
//下拉刷新数据,不清之前的数据
- (void)startLoadData:(BOOL)isFirst;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)scrollToTopAndRefresh;

- (void)scrollToTopAndRefreshAllData;

- (void)hideImmediately;

//- (void)gotoGroupChat;
//- (void)gotoGroupChatVC:(NSString *)convId isCreate:(BOOL)isCreate autoJoin:(BOOL)autoJoin;
//- (void)updateViews;
//- (void)initTableView;
@end

NS_ASSUME_NONNULL_END
