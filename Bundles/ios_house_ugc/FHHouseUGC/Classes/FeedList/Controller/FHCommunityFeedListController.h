//
//  FHCommunityFeedListController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHBaseViewController.h"
#import "FHHouseUGCHeader.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityFeedListController : FHBaseViewController

@property(nonatomic, assign) FHCommunityFeedListType listType;
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
//小区详情页进入需要传这个参数，小区圈子id
@property(nonatomic, strong) NSString *forumId;

@property(nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;
- (void)showNotify:(NSString *)message;
//下拉刷新数据
- (void)startLoadData;

- (void)viewWillAppear;

@end

NS_ASSUME_NONNULL_END
