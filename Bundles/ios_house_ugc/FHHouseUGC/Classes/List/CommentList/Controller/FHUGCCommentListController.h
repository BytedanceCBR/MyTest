//
//  FHUGCCommentListController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import "FHBaseViewController.h"
#import "FHHouseUGCHeader.h"
#import <CoreLocation/CoreLocation.h>
#import "ArticleListNotifyBarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCommentListController : FHBaseViewController

@property(nonatomic, assign) FHCommunityFeedListType listType;
@property(nonatomic, strong) ArticleListNotifyBarView *notifyBarView;
//发布按钮
@property(nonatomic, strong) UIButton *publishBtn;
@property(nonatomic, copy) void(^publishBlock)(void);
//附加在feed上面的自定义view
@property(nonatomic, strong) UIView *tableHeaderView;
@property(nonatomic, strong) UITableView *tableView;
//是否需要下拉刷新，默认为YES
@property(nonatomic, assign) BOOL tableViewNeedPullDown;
//发布按钮距离底部的高度,默认为0
@property(nonatomic, assign) CGFloat publishBtnBottomHeight;
//当前定位的位置
@property(nonatomic, strong) CLLocation *currentLocaton;
//小区详情页进入需要传这个参数，圈子子id
@property(nonatomic, strong) NSString *forumId;
//传入以后点击三个点以后显示该数组的内容
@property(nonatomic, strong) NSArray *operations;
//当接口返回空数据的时候是否显示空态页，默认为YES
@property(nonatomic, assign) BOOL showErrorView;

@property(nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;
- (void)showNotify:(NSString *)message ;
- (void)showNotify:(NSString *)message completion:(void(^)(void))completion;
//下拉刷新数据
- (void)startLoadData;
//下拉刷新数据,不清之前的数据
- (void)startLoadData:(BOOL)isFirst;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)hideImmediately;

@end

NS_ASSUME_NONNULL_END
