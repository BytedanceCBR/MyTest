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

@interface FHCommentDetailViewController ()

@property (nonatomic, strong)   UITableView       *tableView;
@property (nonatomic, strong)   FHExploreDetailToolbarView       *toolbarView; // 临时toolbar
@property (nonatomic, strong)   FHCommentDetailViewModel      *viewModel;
@property (nonatomic, copy)     NSString       *comment_id;

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
}

- (void)setupUI {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"详情";
    self.comment_id = @"6714431339993235463";
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

- (void)toolBarButtonClicked:(id)sender
{
    if (sender == self.toolbarView.writeButton) {
//        if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
//            [self tt_commentViewController:self.commentViewController didSelectWithInfo:({
//                NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
//                [baseCondition setValue:self.groupModel forKey:@"groupModel"];
//                [baseCondition setValue:@(1) forKey:@"from"];
//                [baseCondition setValue:@(YES) forKey:@"writeComment"];
//                [baseCondition setValue:self.commentViewController.tt_defaultReplyCommentModel forKey:@"commentModel"];
//                [baseCondition setValue:@(ArticleMomentSourceTypeArticleDetail) forKey:@"sourceType"];
//                baseCondition;
//            })];
//            if ([self.commentViewController respondsToSelector:@selector(tt_clearDefaultReplyCommentModel)]) {
//                [self.commentViewController tt_clearDefaultReplyCommentModel];
//            }
//            [self.toolbarView.writeButton setTitle:@"说点什么..." forState:UIControlStateNormal];
//            return;
//        }
//        [self clickCommentFieldTracer];
        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
    }
    else if (sender == _toolbarView.digButton) {
        // 点赞
        [self gotoDigg];
    }
}

- (void)p_willOpenWriteCommentViewWithReservedText:(NSString *)reservedText switchToEmojiInput:(BOOL)switchToEmojiInput  {
    
//    NSMutableDictionary *condition = [NSMutableDictionary dictionaryWithCapacity:10];
//    [condition setValue:self.groupModel forKey:kQuickInputViewConditionGroupModel];
//    [condition setValue:reservedText forKey:kQuickInputViewConditionInputViewText];
//    [condition setValue:@(NO) forKey:kQuickInputViewConditionHasImageKey];
//
//    NSString *fwID = self.groupModel.groupID;
//
//    TTArticleReadQualityModel *qualityModel = [[TTArticleReadQualityModel alloc] init];
//    double readPct = (self.mainScrollView.contentOffset.y + self.mainScrollView.frame.size.height) / self.mainScrollView.contentSize.height;
//    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
//    qualityModel.readPct = @(percent);
//    //    qualityModel.stayTimeMs = @([self.detailModel.sharedDetailManager currentStayDuration]);
//
//    __weak typeof(self) wSelf = self;
//
//    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:condition commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
//        *willRepostFwID = fwID;
//        [wSelf clickSubmitComment];
//    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:qualityModel];
//    commentManager.enterFrom = @"feed_detail";
//    commentManager.enter_type = @"submit_comment";
//
//    self.commentWriteView = [[FHPostDetailCommentWriteView alloc] initWithCommentManager:commentManager];
//
//    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;
//
//    [self.commentWriteView showInView:self.view animated:YES];
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
    
    [FHCommonApi requestCommonDigg:self.comment_id groupType:FHDetailDiggTypeTHREAD action:self.viewModel.user_digg tracerParam:dict  completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
    }];
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

@end
