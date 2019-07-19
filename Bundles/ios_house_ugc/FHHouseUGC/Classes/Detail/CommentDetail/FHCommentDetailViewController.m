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
#import "FHUGCFollowListCell.h"
#import "UIViewController+Track.h"
#import "TTUIResponderHelper.h"
#import "FHExploreDetailToolbarView.h"
#import "FHCommentDetailViewModel.h"
#import "TTAccountManager.h"
#import "TTAccountLoginManager.h"
#import "FHCommonApi.h"
#import "FHUGCReplyCommentWriteView.h"
#import "TTCommentDetailReplyWriteManager.h"

@interface FHCommentDetailViewController ()

@property (nonatomic, strong)   UITableView       *tableView;
@property (nonatomic, strong)   FHExploreDetailToolbarView       *toolbarView; // 临时toolbar
@property (nonatomic, strong)   FHCommentDetailViewModel      *viewModel;
@property (nonatomic, copy)     NSString       *comment_id;
@property (nonatomic, strong)   FHUGCReplyCommentWriteView       *commentWriteView;

@end

@implementation FHCommentDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.comment_id = @"6714466747832877060";//  6712727097456623627  6714431339993235463
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self startLoadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStateChange:) name:@"kFHUGCDiggStateChangeNotification" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"详情";
    self.comment_id = @"6714466747832877060";
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self configTableView];
    [self.view addSubview:_tableView];
    self.viewModel = [[FHCommentDetailViewModel alloc] initWithController:self tableView:_tableView];
    self.viewModel.comment_id = self.comment_id;
    [self setupToolbarView];
//    _tableView.dataSource = self;
//    _tableView.delegate = self;
//    [_tableView registerClass:[FHUGCFollowListCell class] forCellReuseIdentifier:@"FHUGCFollowListCell"];
//    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(height);
        make.bottom.mas_equalTo(self.toolbarView.mas_top);
    }];
    [self addDefaultEmptyViewFullScreen];
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
        self.toolbarView.digCountLabel.textColor = [UIColor themeRed1];
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
        [self p_willOpenWriteCommentViewWithReplyCommentModel:nil];
    }
    else if (sender == _toolbarView.digButton) {
        // 点赞
        [self gotoDigg];
    }
}

// 点击回复 进行评论
- (void)openWriteCommentViewWithReplyCommentModel:(id<TTCommentDetailReplyCommentModelProtocol>)replyCommentModel {
    [self p_willOpenWriteCommentViewWithReplyCommentModel:replyCommentModel];
}

- (void)p_willOpenWriteCommentViewWithReplyCommentModel:(id<TTCommentDetailReplyCommentModelProtocol>)replyCommentModel   {

    WeakSelf;
    // action.replyCommentModel? :[self pageState].defaultRelyModel
    TTCommentDetailReplyWriteManager *replyManager = [[TTCommentDetailReplyWriteManager alloc] initWithCommentDetailModel:self.viewModel.commentDetailModel replyCommentModel:replyCommentModel commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        StrongSelf;
        *willRepostFwID = [wself.viewModel.commentDetailModel.repost_params tt_stringValueForKey:@"fw_id"];

    } publishCallback:^(id<TTCommentDetailReplyCommentModelProtocol>replyModel, NSError *error) {
        StrongSelf;
        if (error) {
            return;
        }
        if (replyModel) {
            [wself.viewModel insertReplyData:replyModel];
        }
    } getReplyCommentModelClassBlock:nil commentRepostWithPreRichSpanText:nil commentSource:nil];
    
    replyManager.enterFrom = @"comment_detail";
//        replyManager.enter_type = @"submit_comment";
    
    self.commentWriteView = [[FHUGCReplyCommentWriteView alloc] initWithCommentManager:replyManager];

    self.commentWriteView.emojiInputViewVisible = NO;

    [self.commentWriteView showInView:self.view animated:YES];
}

// 去点赞
- (void)gotoDigg {
    // 点赞埋点
    if (self.viewModel.user_digg == 1) {
        // 取消点赞
//        [self click_feed_dislike];
    } else {
        // 点赞
//        [self click_feed_like];
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
//    dict[@"enter_from"] = self.tracerDict[@"enter_from"];
//    dict[@"element_from"] = self.tracerDict[@"element_from"];
//    dict[@"page_type"] = self.tracerDict[@"page_type"];
    
    [FHCommonApi requestCommonDigg:self.comment_id groupType:FHDetailDiggTypeCOMMENT action:self.viewModel.user_digg tracerParam:dict  completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
    }];
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

// 点击回复
- (void)clickSubmitComment {
//    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
//    tracerDict[@"click_position"] = @"submit_comment";
//    [FHUserTracker writeEvent:@"click_submit_comment" params:tracerDict];
}

@end
