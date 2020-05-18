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
#import "FHUserTracker.h"
#import "UIViewController+Track.h"
#import "FHFeedOperationView.h"
#import "FHUGCConfig.h"
#import "TTBusinessManager+StringUtils.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUGCShareManager.h"
#import "UIImage+FIconFont.h"

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
@property (nonatomic, strong)   UIImage       *shareBlackImage;
@property (nonatomic, strong)   UIButton       *shareButton;// 分享
@property (nonatomic, assign)   BOOL       isViewAppearing;
@property (nonatomic, copy)     NSString       *lastPageSocialGroupId;
//标识来源的入口，是发现过来的（house_thread）还是UGC过来的（ugc_thread）
@property(nonatomic, copy) NSString *threadDetailSource;

@end

@implementation FHPostDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 帖子
        self.postType = FHUGCPostTypePost;
        self.fromUGC = YES;
        NSDictionary *params = paramObj.allParams;
        int64_t tid = [[paramObj.allParams objectForKey:@"tid"] longLongValue];
        int64_t fid = [[paramObj.allParams objectForKey:@"fid"] longLongValue];
        self.lastPageSocialGroupId = [params objectForKey:@"social_group_id"];
        // 帖子id
        self.tid = tid;// 1636215424527368  1636223115260939    1636223457031179    1636222717073420
        self.fid = fid;// 6564242300        1621706233835550    6564242300          86578926583
        TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:[NSString stringWithFormat:@"%lld", tid] itemID:[NSString stringWithFormat:@"%lld", tid] impressionID:nil aggrType:1];
        self.groupModel = groupModel;
        // 列表页数据
        self.detailData = params[@"data"];
        if (self.detailData) {
            self.comment_count = [self.detailData.commentCount longLongValue];
            self.user_digg = [self.detailData.userDigg integerValue];
            self.digg_count = [self.detailData.diggCount longLongValue];
            self.detailData.groupId = [NSString stringWithFormat:@"%ld",tid];
        }
        self.threadDetailSource = params[@"thread_detail_source"];
        // 埋点
        self.tracerDict[@"page_type"] = @"feed_detail";
        self.ttTrackStayEnable = YES;
        // 取链接中的埋点数据
        NSString *enter_from = params[@"enter_from"];
        if (enter_from.length > 0) {
            self.tracerDict[@"enter_from"] = enter_from;
        }
        NSString *origin_from = params[@"origin_from"];
        if (origin_from.length > 0) {
            self.tracerDict[@"origin_from"] = origin_from;
        }
        NSString *enter_type = params[@"enter_type"];
        if (enter_type.length > 0) {
            self.tracerDict[@"enter_type"] = enter_type;
        }
        NSString *element_from = params[@"element_from"];
        if (element_from.length > 0) {
            self.tracerDict[@"element_from"] = element_from;
        }
        NSString *log_pb_str = params[@"log_pb"];
        if ([log_pb_str isKindOfClass:[NSString class]] && log_pb_str.length > 0) {
            NSData *jsonData = [log_pb_str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err = nil;
            NSDictionary *dic = nil;
            @try {
                dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                      options:NSJSONReadingMutableContainers
                                                        error:&err];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            if (!err && [dic isKindOfClass:[NSDictionary class]] && dic.count > 0) {
                self.tracerDict[@"log_pb"] = dic;
            }
        } else if ([log_pb_str isKindOfClass:[NSDictionary class]]) {
            self.tracerDict[@"log_pb"] = (NSDictionary *)log_pb_str;
        }
        // report_prarms
        if (self.report_params_dic && self.report_params_dic[@"social_group_id"]) {
            self.lastPageSocialGroupId = [params objectForKey:@"social_group_id"];
        }
        
        // social_group_id 筛入 logpb中
        NSDictionary *temp_log_pb = self.tracerDict[@"log_pb"];
        if (self.lastPageSocialGroupId.length > 0) {
            NSMutableDictionary *mutLogPb = [NSMutableDictionary new];
            if ([temp_log_pb isKindOfClass:[NSDictionary class]]) {
                [mutLogPb addEntriesFromDictionary:temp_log_pb];
            }
            mutLogPb[@"social_group_id"] = self.lastPageSocialGroupId;
            self.tracerDict[@"log_pb"] = mutLogPb;
        }
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
    self.weakViewModel.category = @"thread_detail";
    self.weakViewModel.lastPageSocialGroupId = self.lastPageSocialGroupId;
    self.weakViewModel.threadDetailSource = self.threadDetailSource;
    // 导航栏
    [self setupDetailNaviBar];
    // 全部评论
    [self firstLoadCommentCount];
    // 列表页数据
    if (self.detailData) {
        self.weakViewModel.detailData = self.detailData;
    }
    self.weakViewModel.weakShareButton = self.shareButton;
    [self addDefaultEmptyViewFullScreen];
    // 请求 详情页数据
    [self startLoadData];
    [self addGoDetailLog];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayPageLog];
    //跳页时关闭举报的弹窗
    [FHFeedOperationView dismissIfVisible];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewAppearing = YES;
    // 帖子数同步逻辑
    FHUGCScialGroupDataModel *tempModel = self.weakViewModel.detailHeaderModel.socialGroupModel;
    if (tempModel) {
        NSString *socialGroupId = tempModel.socialGroupId;
        FHUGCScialGroupDataModel *model = [[FHUGCConfig sharedInstance] socialGroupData:socialGroupId];
        if (model && (![model.countText isEqualToString:tempModel.countText] || ![model.hasFollow isEqualToString:tempModel.hasFollow])) {
            self.weakViewModel.detailHeaderModel.socialGroupModel = model;
            [self headerInfoChanged];
            [self.weakViewModel.tableView reloadData];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isViewAppearing = NO;
}

- (void)dealloc
{
    [self addReadPct];
}

- (void)setupDetailNaviBar {
    self.customNavBarView.title.text = @"详情";
    // 分享按钮
    self.shareButton = [[UIButton alloc] init];
    [self.shareButton setBackgroundImage:self.shareBlackImage forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:self.shareBlackImage forState:UIControlStateHighlighted];
    [self.shareButton addTarget:self  action:@selector(shareButtonClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.customNavBarView addSubview:_shareButton];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-10);
    }];
    
    // 关注按钮
    self.followButton = [[FHUGCFollowButton alloc] init];
    self.followButton.followed = YES;
    self.followButton.tracerDic = self.tracerDict.mutableCopy;
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
    self.shareButton.hidden = NO;
    
    UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
    [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
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
        [self remove_comment_vc];
        [self startLoadData];
    }
}

- (void)firstLoadCommentCount {
    if (self.commentAllFooter == nil) {
        self.commentAllFooter = [[FHDetailCommentAllFooter alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 52)];
        self.tableView.tableFooterView = self.commentAllFooter;
    }
    // 全部评论
    NSString *commentStr = @"全部评论";
    if (self.comment_count > 0) {
        commentStr = [NSString stringWithFormat:@"全部评论(%@)",[TTBusinessManager formatCommentCount:self.comment_count]];
    } else {
        commentStr = [NSString stringWithFormat:@"全部评论(0)"];
    }
    self.commentAllFooter.allCommentLabel.text = commentStr;
}

- (void)commentCountChanged {
    if (self.commentAllFooter == nil) {
        self.commentAllFooter = [[FHDetailCommentAllFooter alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 52)];
        self.tableView.tableFooterView = self.commentAllFooter;
    }
    // 全部评论
    NSString *commentStr = @"全部评论";
    if (self.comment_count > 0) {
        commentStr = [NSString stringWithFormat:@"全部评论(%@)",[TTBusinessManager formatCommentCount:self.comment_count]];
    } else {
        commentStr = [NSString stringWithFormat:@"全部评论(0)"];
    }
    self.commentAllFooter.allCommentLabel.text = commentStr;
    
    //评论完成后发送通知修改评论数
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    NSString *group_id = [NSString stringWithFormat:@"%ld",self.tid];
    userInfo[@"group_id"] = group_id;
    userInfo[@"comment_conut"] = @(self.comment_count);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPostMessageFinishedNotification"
                                                                   object:nil
                                                                 userInfo:userInfo];
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
            self.shareButton.hidden = YES;
        } else {
            self.naviHeaderView.hidden = YES;
            self.followButton.hidden = YES;
            self.shareButton.hidden = NO;
        }
    }
}


#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayPageLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Tracer

-(void)addGoDetailLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    [FHUserTracker writeEvent:@"go_detail" params:tracerDict];
}

-(void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_page" params:tracerDict];
    [self tt_resetStayTime];
}

- (void)addReadPct {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"page_count"] = @"1";
    tracerDict[@"percent"] = @"100";
    tracerDict[@"item_id"] = self.groupModel.itemID ?: @"be_null";
    [FHUserTracker writeEvent:@"read_pct" params:tracerDict];
}

// 黑色
- (UIImage *)shareBlackImage
{
    if (!_shareBlackImage) {
        _shareBlackImage = ICON_FONT_IMG(24, @"\U0000e692", nil); //detail_share_black
    }
    return _shareBlackImage;
}

// 分享按钮点击
- (void)shareButtonClicked:(UIButton *)btn {
    if (self.viewModel.shareInfo && self.tracerDict) {
        [[FHUGCShareManager sharedManager] shareActionWithInfo:self.viewModel.shareInfo tracerDic:self.tracerDict];
    }
}

@end
