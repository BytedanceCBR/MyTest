//
//  FHUGCVideoListController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/8/9.
//

#import "FHBaseViewController.h"
#import "FHHouseUGCHeader.h"
#import "SSImpressionManager.h"
#import "ArticleImpressionHelper.h"
#import "FHHouseUGCAPI.h"
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCVideoListController : FHBaseViewController

@property(nonatomic, strong) NSArray *dataList;
//内容分类
@property(nonatomic, strong) NSString *category;
@property(nonatomic, strong) UITableView *tableView;
//是否需要在返回这个页面时候去刷新数据
@property(nonatomic, assign) BOOL needReloadData;
//小区详情页进入需要传这个参数，圈子子id
@property(nonatomic, strong) NSString *forumId;
//tab的名字,调用接口时候会传给服务器
@property(nonatomic, strong) NSString *tabName;
//小区群聊的conversation id
@property(nonatomic, strong) NSString *conversationId;
//传入以后点击三个点以后显示该数组的内容
@property(nonatomic, strong) NSArray *operations;
//网络请求成功回调
@property(nonatomic, copy) void (^requestSuccess)(BOOL hasFeedData);
//是否需要上报enterCategory和stayCategory埋点，默认不报
@property(nonatomic, assign) BOOL needReportEnterCategory;
//埋点上报
//是否是通过点击触发刷新
@property(nonatomic, assign) BOOL isRefreshTypeClicked;
//是否需要强插
@property(nonatomic, assign) BOOL isInsertFeedWhenPublish;
@property(nonatomic, assign) CGFloat headerViewHeight;
//圈子详情页使用
//空态页具体顶部offset
@property (nonatomic, assign) CGFloat errorViewTopOffset;
@property (nonatomic, assign) CGFloat errorViewHeight;
@property (nonatomic, assign) BOOL notLoadDataWhenEmpty;
@property(nonatomic, copy) void(^beforeInsertPostBlock)(void);
@property(nonatomic, strong) FHFeedUGCCellModel *currentVideo;

//下拉刷新数据
- (void)startLoadData;

@end

NS_ASSUME_NONNULL_END


