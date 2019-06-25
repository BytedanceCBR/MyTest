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
#import "FHPostDetailNavHeaderView.h"
#import "FHCommonDefines.h"
#import "FHUGCFollowButton.h"

@interface FHPostDetailViewController ()

@property (nonatomic, assign) int64_t tid; //帖子ID--必须
@property (nonatomic, assign) int64_t fid; //话题ID
@property (nonatomic, copy) NSString *cid; //关心ID
// 列表页数据
@property (nonatomic, strong)   FHFeedUGCCellModel       *detailData;
@property (nonatomic, strong)   FHDetailCommentAllFooter       *commentAllFooter;
@property (nonatomic, weak)     FHPostDetailViewModel       *weakViewModel;

@property (nonatomic, strong)   FHPostDetailNavHeaderView       *naviHeaderView;
@property (nonatomic, strong)   FHUGCFollowButton       *followButton;// 关注
@property (nonatomic, assign)   BOOL       isViewAppearing;

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
        // 帖子id
        self.tid = tid;// 1636215424527368  1636223115260939    1636223457031179    1636222717073420
        self.fid = fid;// 6564242300        1621706233835550    6564242300          86578926583
        TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:[NSString stringWithFormat:@"%lld", tid] itemID:[NSString stringWithFormat:@"%lld", tid] impressionID:nil aggrType:1];
        self.groupModel = groupModel;
        // 评论数 点赞数等
        self.comment_count = [[paramObj.allParams objectForKey:@"comment_count"] integerValue];
        self.digg_count = [[paramObj.allParams objectForKey:@"digg_count"] integerValue];
        self.user_digg = [[paramObj.allParams objectForKey:@"user_digg"] integerValue];
        // 列表页数据
        self.detailData = params[@"data"];
        // add by zyk 注意埋点
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
    // 导航栏
    [self setupDetailNaviBar];
    // 全部评论
    [self commentCountChanged];
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.detailData) {
        // 修改列表页数据
        self.detailData.commentCount = [NSString stringWithFormat:@"%lld",self.comment_count];
        self.detailData.userDigg = [NSString stringWithFormat:@"%ld",self.user_digg];
        self.detailData.diggCount = [NSString stringWithFormat:@"%lld",self.digg_count];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewAppearing = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isViewAppearing = NO;
}

- (void)setupDetailNaviBar {
    self.customNavBarView.title.text = @"详情";
    // 关注按钮
    self.followButton = [[FHUGCFollowButton alloc] init];
    [self.followButton addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.followButton.followed = YES;
    self.followButton.groupId = [NSString stringWithFormat:@"%lld",self.tid];
    [self.customNavBarView addSubview:_followButton];
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(58);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(24);
        make.bottom.mas_equalTo(-10);
    }];
    
    self.naviHeaderView = [[FHPostDetailNavHeaderView alloc] init];
    [self.customNavBarView addSubview:_naviHeaderView];
    [self.naviHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(35);
        make.centerX.mas_equalTo(self.customNavBarView);
        make.bottom.mas_equalTo(self.customNavBarView.mas_bottom).offset(-3.5);
        make.width.mas_equalTo(SCREEN_WIDTH - 78 * 2 - 10);
    }];
    self.naviHeaderView.hidden = YES;
    self.followButton.hidden = YES;
}

- (void)followButtonClick:(UIControl *)control {
    
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

- (void)commentCountChanged {
    if (self.commentAllFooter == nil) {
        self.commentAllFooter = [[FHDetailCommentAllFooter alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 52)];
        self.tableView.tableFooterView = self.commentAllFooter;
    }
    // 全部评论
    NSString *commentStr = @"全部评论";
    if (self.comment_count > 0) {
        commentStr = [NSString stringWithFormat:@"全部评论(%ld)",self.comment_count];
    } else {
        commentStr = [NSString stringWithFormat:@"全部评论(0)"];
    }
    self.commentAllFooter.allCommentLabel.text = commentStr;
}

- (void)headerInfoChanged {
    if (self.weakViewModel.detailHeaderModel) {
        self.naviHeaderView.titleLabel.text = self.weakViewModel.detailHeaderModel.socialGroupModel.socialGroupName;
        self.naviHeaderView.descLabel.text = self.weakViewModel.detailHeaderModel.socialGroupModel.countText;
        // 关注按钮
        self.followButton.followed = [self.weakViewModel.detailHeaderModel.socialGroupModel.hasFollow boolValue];
        self.followButton.groupId = self.weakViewModel.detailHeaderModel.socialGroupModel.socialGroupId;
    }
}

// 子类滚动方法
- (void)sub_scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.weakViewModel.detailHeaderModel) {
        // 有头部数据
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY > 78) {
            self.naviHeaderView.hidden = NO;
            self.followButton.hidden = NO;
        } else {
            self.naviHeaderView.hidden = YES;
            self.followButton.hidden = YES;
        }
    }
}

@end
