//
//  FHCommentDetailViewController.m
//  Pods
//
//  Created by 张元科 on 2019/7/16.
//

#import "FHCommentDetailViewController.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "FHRefreshCustomFooter.h"
#import "FHUserTracker.h"
#import "FHFakeInputNavbar.h"
#import "FHConditionFilterFactory.h"
#import "SSNavigationBar.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIViewController+NavbarItem.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDeviceHelper.h"
#import "FHUGCConfig.h"
#import "UIViewController+Track.h"
#import "TTUIResponderHelper.h"
#import "FHExploreDetailToolbarView.h"
#import "FHCommentDetailViewModel.h"
#import "TTAccountManager.h"
#import "TTAccountLoginManager.h"
#import "FHCommonApi.h"
#import "FHUGCReplyCommentWriteView.h"
#import "TTCommentDetailReplyWriteManager.h"
#import "FHPostDetailNavHeaderView.h"
#import "FHUGCFollowButton.h"
#import "FHCommonDefines.h"
#import "FHFeedOperationView.h"
#import "FHUtils.h"

@interface FHCommentDetailViewController ()

@property (nonatomic, strong)   UITableView       *tableView;
@property (nonatomic, strong)   FHExploreDetailToolbarView       *toolbarView; // 临时toolbar
@property (nonatomic, strong)   FHCommentDetailViewModel      *viewModel;
@property (nonatomic, copy)     NSString       *comment_id;
@property (nonatomic, strong)   FHUGCReplyCommentWriteView       *commentWriteView;
@property (nonatomic, strong)   FHPostDetailNavHeaderView       *naviHeaderView;
@property (nonatomic, strong)   FHUGCFollowButton       *followButton;// 关注
@property (nonatomic, assign) BOOL beginShowComment;// 点击评论按钮
@property (nonatomic, copy)     NSString       *lastPageSocialGroupId;

@end

@implementation FHCommentDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary * params = paramObj.allParams;
        if ([params isKindOfClass:[NSDictionary class]]) {
            // 6714466747832877060  6712727097456623627  6714431339993235463
            self.comment_id = [params tt_stringValueForKey:@"comment_id"];
            self.lastPageSocialGroupId = [params objectForKey:@"social_group_id"];
            // 埋点
            self.tracerDict[@"page_type"] = @"comment_detail";
            self.ttTrackStayEnable = YES;
            // 点击评论按钮
            self.beginShowComment = NO;
            if(paramObj.allParams[@"begin_show_comment"]) {
                self.beginShowComment = [paramObj.allParams[@"begin_show_comment"] boolValue];
            }
            // 列表页数据
            self.detailData = params[@"data"];
            
            id logPb = self.tracerDict[@"log_pb"];
            NSDictionary *logPbDic = nil;
            if([logPb isKindOfClass:[NSDictionary class]]){
                logPbDic = logPb;
            }else if([logPb isKindOfClass:[NSString class]]){
                logPbDic = [FHUtils dictionaryWithJsonString:logPb];
            }
            
            if(logPbDic[@"group_id"]){
                self.tracerDict[@"group_id"] = logPbDic[@"group_id"];
            }
            
            if(logPbDic[@"impr_id"]){
                self.tracerDict[@"impr_id"] = logPbDic[@"impr_id"];
            }
            
            if(logPbDic[@"group_source"]){
                self.tracerDict[@"group_source"] = logPbDic[@"group_source"];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self startLoadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStateChange:) name:@"kFHUGCDiggStateChangeNotification" object:nil];
    [self addGoDetailLog];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 帖子数同步逻辑
    FHUGCScialGroupDataModel *tempModel = self.viewModel.detailHeaderModel.socialGroupModel;
    if (tempModel) {
        NSString *socialGroupId = tempModel.socialGroupId;
        FHUGCScialGroupDataModel *model = [[FHUGCConfig sharedInstance] socialGroupData:socialGroupId];
        if (model && (![model.countText isEqualToString:tempModel.countText] || ![model.hasFollow isEqualToString:tempModel.hasFollow])) {
            self.viewModel.detailHeaderModel.socialGroupModel = model;
            [self headerInfoChanged];
            [self.tableView reloadData];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayPageLog];
    //跳页时关闭举报的弹窗
    [FHFeedOperationView dismissIfVisible];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    // 导航栏
    [self setupDetailNaviBar];
    self.customNavBarView.title.text = @"详情";
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self configTableView];
    [self.view addSubview:_tableView];
    self.viewModel = [[FHCommentDetailViewModel alloc] initWithController:self tableView:_tableView];
    self.viewModel.comment_id = self.comment_id;
    self.viewModel.beginShowComment = self.beginShowComment;
    self.viewModel.lastPageSocialGroupId = self.lastPageSocialGroupId;
    [self setupToolbarView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(height);
        make.bottom.mas_equalTo(self.toolbarView.mas_top);
    }];
    [self addDefaultEmptyViewFullScreen];
}

- (void)setupDetailNaviBar {
    self.customNavBarView.title.text = @"详情";
    // 关注按钮
    self.followButton = [[FHUGCFollowButton alloc] init];
    self.followButton.followed = YES;
    self.followButton.tracerDic = self.tracerDict.mutableCopy;
    self.followButton.groupId = @"";
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

- (void)headerInfoChanged {
    if (self.viewModel.detailHeaderModel) {
        self.naviHeaderView.titleLabel.text = self.viewModel.detailHeaderModel.socialGroupModel.socialGroupName;
        self.naviHeaderView.descLabel.text = self.viewModel.detailHeaderModel.socialGroupModel.countText;
        // 关注按钮
        self.followButton.followed = [self.viewModel.detailHeaderModel.socialGroupModel.hasFollow boolValue];
        self.followButton.groupId = self.viewModel.detailHeaderModel.socialGroupModel.socialGroupId;
    }
}

// 子类滚动方法
- (void)sub_scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.viewModel.detailHeaderModel) {
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


- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 0;//
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
}

- (void)startLoadData {
    if (self.comment_id.length <= 0) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        return;
    }
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

- (void)setupToolbarView {
    self.toolbarView = [[FHExploreDetailToolbarView alloc] initWithFrame:[self p_frameForToolBarView]];
    
    self.toolbarView.toolbarType = FHExploreDetailToolbarTypeArticleComment;
    
    [self.view addSubview:self.toolbarView];
    
    [self.toolbarView.writeButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.digButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toolbarView.frame = [self p_frameForToolBarView];
    self.toolbarView.hidden = NO;
    [self p_refreshToolbarView];
}

- (void)p_refreshToolbarView
{
    self.toolbarView.digButton.selected = self.viewModel.user_digg == 1;
    self.toolbarView.digCountValue = [NSString stringWithFormat:@"%ld",self.viewModel.digg_count];
    if (self.viewModel.user_digg == 1) {
        // 点赞
        self.toolbarView.digCountLabel.textColor = [UIColor themeOrange4];
    } else {
        // 取消点赞
        self.toolbarView.digCountLabel.textColor = [UIColor themeGray1];
    }
}

- (void)refreshUI {
    [self refreshToolbarView];
}

- (void)refreshToolbarView {
    [self p_refreshToolbarView];
}

- (void)toolBarButtonClicked:(id)sender
{
    if (sender == self.toolbarView.writeButton) {
        // 输入框
        [self clickCommentFieldTracer];
        [self p_willOpenWriteCommentViewWithReplyCommentModel:nil];
    }
    else if (sender == _toolbarView.digButton) {
        // 点赞
        [self gotoDigg];
    }
}

// 点击回复 进行评论
- (void)openWriteCommentViewWithReplyCommentModel:(id<TTCommentDetailReplyCommentModelProtocol>)replyCommentModel {
    [self clickReplyComment:replyCommentModel.commentID];
    [self p_willOpenWriteCommentViewWithReplyCommentModel:replyCommentModel];
}

- (void)p_willOpenWriteCommentViewWithReplyCommentModel:(id<TTCommentDetailReplyCommentModelProtocol>)replyCommentModel   {

    WeakSelf;
    TTCommentDetailReplyWriteManager *replyManager = [[TTCommentDetailReplyWriteManager alloc] initWithCommentDetailModel:self.viewModel.commentDetailModel replyCommentModel:replyCommentModel commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        StrongSelf;
        *willRepostFwID = [wself.viewModel.commentDetailModel.repost_params tt_stringValueForKey:@"fw_id"];
    } publishCallback:^(id<TTCommentDetailReplyCommentModelProtocol>replyModel, NSError *error) {
        StrongSelf;
        // 回复 按钮点击成功之后的埋点上报，点击的时机不好获取
        [wself clickSubmitComment];
        if (error) {
            return;
        }
        if (replyModel) {
            [wself.viewModel insertReplyData:replyModel];
        }
    } getReplyCommentModelClassBlock:nil commentRepostWithPreRichSpanText:nil commentSource:nil];
    
    replyManager.enterFrom = self.tracerDict[@"page_type"];
    replyManager.extraDic = self.tracerDict;
    replyManager.logPb = self.tracerDict[@"log_pb"];
    
    self.commentWriteView = [[FHUGCReplyCommentWriteView alloc] initWithCommentManager:replyManager];

    self.commentWriteView.emojiInputViewVisible = NO;

    [self.commentWriteView showInView:self.view animated:YES];
}

// 去点赞
- (void)gotoDigg {
    // 点赞埋点
    if (self.viewModel.user_digg == 1) {
        // 取消点赞
        [self click_feed_dislike];
    } else {
        // 点赞
        [self click_feed_like];
    }
    if ([TTAccountManager isLogin]) {
        [self p_digg];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"feed_detail" forKey:@"enter_from"];
    [params setObject:@"feed_like" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                [wSelf p_digg];
            }
        }
    }];
}

- (void)p_digg {
    self.viewModel.user_digg = (self.viewModel.user_digg == 1) ? 0 : 1;
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"enter_from"] = self.tracerDict[@"enter_from"];
    dict[@"element_from"] = self.tracerDict[@"element_from"];
    dict[@"page_type"] = self.tracerDict[@"page_type"];
    
    [FHCommonApi requestCommonDigg:self.comment_id groupType:FHDetailDiggTypeCOMMENT action:self.viewModel.user_digg tracerParam:dict  completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
    }];
}

// 点击回复
- (void)clickSubmitComment {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"click_position"] = @"submit_comment";
    [FHUserTracker writeEvent:@"click_submit_comment" params:tracerDict];
}

// 点击回复他人的评论中的“回复”按钮
- (void)clickReplyComment:(NSString *)comment_id {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"click_position"] = @"reply_comment";
    tracerDict[@"comment_id"] = comment_id ?: @"be_null";
    [FHUserTracker writeEvent:@"click_reply_comment" params:tracerDict];
}

// 点击评论
- (void)clickCommentFieldTracer {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"click_position"] = @"comment_field";
    [FHUserTracker writeEvent:@"click_comment_field" params:tracerDict];
}

// 详情 点赞
- (void)click_feed_like {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"click_position"] = @"feed_detail";
    [FHUserTracker writeEvent:@"click_like" params:tracerDict];
}

// 详情页 取消点赞
- (void)click_feed_dislike {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"click_position"] = @"feed_detail";
    [FHUserTracker writeEvent:@"click_dislike" params:tracerDict];
}

- (void)likeStateChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if(userInfo){
        NSInteger user_digg = [userInfo[@"action"] integerValue];
        NSInteger diggCount = self.viewModel.digg_count;
        NSInteger groupType = [userInfo[@"group_type"] integerValue];
        NSString *groupId = userInfo[@"group_id"];
        
        if(groupType == FHDetailDiggTypeCOMMENT && [groupId isEqualToString:self.comment_id]){
            // 刷新UI
            if(user_digg == 0) {
                //取消点赞
                self.viewModel.user_digg = 0;
                if(diggCount > 0){
                    diggCount = diggCount - 1;
                }
            }else{
                //点赞
                self.viewModel.user_digg = 1;
                diggCount = diggCount + 1;
            }
            
            self.viewModel.digg_count = diggCount;
        }
        [self p_refreshToolbarView];
    }
}

- (CGRect)p_frameForToolBarView
{
    self.toolbarView.height = FHExploreDetailGetToolbarHeight() + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    return CGRectMake(0, self.view.height - self.toolbarView.height, self.view.width, self.toolbarView.height);
}

- (void)dismissSelf
{
    if (self.navigationController.viewControllers.count>1) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers && viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
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
    [tracerDict setValue:@"89249" forKey:@"event_tracking_id"];
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
//    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
//    tracerDict[@"page_count"] = @"1";
//    tracerDict[@"percent"] = @"100";
//    tracerDict[@"item_id"] = self.comment_id ?: @"be_null";
//    [FHUserTracker writeEvent:@"read_pct" params:tracerDict];
}

@end
