//
//  FHPostDetailViewController
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHPostDetailViewController.h"
#import "FHFeedUGCCellModel.h"
#import "FHPostDetailViewModel.h"
#import "FHDetailCommentAllFooter.h"
#import "TTReachability.h"
#import "Article.h"

@interface FHPostDetailViewController ()

@property (nonatomic, assign) int64_t tid; //帖子ID
@property (nonatomic, assign) int64_t fid; //话题ID
@property (nonatomic, copy) NSString *cid; //关心ID

@property (nonatomic, strong)   FHFeedUGCCellModel       *detailData;
@property (nonatomic, strong)   FHDetailCommentAllFooter       *commentAllFooter;
@property (nonatomic, weak)     FHPostDetailViewModel       *weakViewModel;

@end

@implementation FHPostDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 帖子
        self.postType = FHUGCPostTypePost;
        NSDictionary *params = paramObj.allParams;
        int64_t tid = [[paramObj.allParams objectForKey:@"tid"] longLongValue];
        int64_t fid = [[paramObj.allParams objectForKey:@"fid"] longLongValue];
        
//        TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:[NSString stringWithFormat:@"%lld", self.uniqueID] itemID:self.itemID impressionID:nil aggrType:[self.aggrType integerValue]];
        
        self.tid = tid;
        self.fid = fid;
        self.detailData = params[@"data"];// 列表页数据
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // ViewModel
    self.weakViewModel = self.viewModel;
    self.weakViewModel.threadID = self.tid;
    self.weakViewModel.forumID = self.fid;
    self.weakViewModel.category = @"test";// add by zyk
    // 全部评论
    NSString *commentStr = @"全部评论";
    if ([self.detailData.commentCount integerValue] > 0) {
        commentStr = [NSString stringWithFormat:@"全部评论(%@)",self.detailData.commentCount];
    } else {
        commentStr = [NSString stringWithFormat:@"全部评论(0)"];
    }
    self.commentAllFooter = [[FHDetailCommentAllFooter alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 52)];
    self.commentAllFooter.allCommentLabel.text = commentStr;
    self.tableView.tableFooterView = self.commentAllFooter;
    // 列表页数据
    if (self.detailData) {
        [self.viewModel.items addObject:self.detailData];
        // 刷新数据
        [self.viewModel reloadData];
    }
    [self addDefaultEmptyViewFullScreen];
    // 请求 详情页数据
    [self startLoadData];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [self startLoading];
        self.isLoadingData = YES;
        [self.viewModel startLoadData];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

// 重新加载
- (void)retryLoadData {
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}
/*
 
 
 data = "<FHFeedUGCCellModel: 0x2816942d0>";
 fid = 6564242300;
 "gd_ext_json" = "{\"category_id\":\"weitoutiao\",\"enter_from\":\"click_weitoutiao\",\"group_type\":\"forum_post\",\"log_pb\":\"{\\\"from_gid\\\":0,\\\"impr_id\\\":\\\"2019061215225301000806301252119F6\\\",\\\"post_gid\\\":1636117814370308,\\\"recommend_type\\\":\\\"\\\",\\\"repost_gid\\\":0,\\\"with_quote\\\":0}\",\"refer\":\"1\"}";
 tid = 1636117814370308;
 }
 
 */
@end
