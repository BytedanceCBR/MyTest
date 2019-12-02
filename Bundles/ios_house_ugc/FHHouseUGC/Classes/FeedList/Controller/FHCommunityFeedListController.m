//
//  FHCommunityFeedListController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHCommunityFeedListController.h"
#import "UIColor+Theme.h"
#import "FHCommunityFeedListBaseViewModel.h"
#import "FHCommunityFeedListNearbyViewModel.h"
#import "FHCommunityFeedListMyJoinViewModel.h"
#import "FHCommunityFeedListPostDetailViewModel.h"
#import "TTReachability.h"
#import <UIViewAdditions.h>
#import "TTDeviceHelper.h"
#import <TTRoute.h>
#import "TTAccountManager.h"
#import "TTAccount+Multicast.h"
#import "FHEnvContext.h"
#import "FHUserTracker.h"
#import <UIScrollView+Refresh.h>
#import "FHFeedOperationView.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHUGCConfig.h"
#import "ToastManager.h"
#import "FHUGCPostMenuView.h"
#import "FHCommonDefines.h"

@interface FHCommunityFeedListController ()<SSImpressionProtocol, FHUGCPostMenuViewDelegate>

@property(nonatomic, strong) FHCommunityFeedListBaseViewModel *viewModel;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);
@property(nonatomic, assign) NSInteger currentCityId;
@property(nonatomic, strong) FHUGCPostMenuView *publishMenuView;

@end

@implementation FHCommunityFeedListController

-(instancetype)init{
    self = [super init];
    if(self){
        _tableViewNeedPullDown = YES;
        _showErrorView = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    [self initConstraints];
    [self initViewModel];
    
    [[SSImpressionManager shareInstance] addRegist:self];
    [TTAccount addMulticastDelegate:self];
}

- (void)dealloc
{
    [[SSImpressionManager shareInstance] removeRegist:self];
    [TTAccount removeMulticastDelegate:self];
}

- (void)viewWillAppear {
    [self.viewModel viewWillAppear];
    
    if(self.viewModel.dataList.count > 0 || self.notLoadDateWhenEmpty){
        if (self.needReloadData) {
            self.needReloadData = NO;
            [self scrollToTopAndRefreshAllData];
        }
    }else{
        self.needReloadData = NO;
        [self scrollToTopAndRefreshAllData];
    }
}

- (void)viewWillDisappear {
    [self.viewModel viewWillDisappear];
    [FHFeedOperationView dismissIfVisible];
}

- (void)initView {
    [self initTableView];
    [self initNotifyBarView];
    if(self.showErrorView){
        [self addDefaultEmptyViewFullScreen];
        if(self.errorViewTopOffset != 0){
            [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(self.view);
                make.top.mas_equalTo(self.view).offset(self.errorViewTopOffset);
            }];
        }
    }
    [self initPublishBtn];
}

- (void)initTableView {
    if(!_tableView){
        self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor themeGray7];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIView *headerView = self.tableHeaderView ? self.tableHeaderView : [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
        _tableView.tableHeaderView = headerView;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
        _tableView.tableFooterView = footerView;
        
        _tableView.sectionFooterHeight = 0.0;
        
        _tableView.estimatedRowHeight = 0;
        
        if (@available(iOS 11.0 , *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        if ([TTDeviceHelper isIPhoneXDevice]) {
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        
        [self.view addSubview:_tableView];
    }
}

- (void)setTableHeaderView:(UIView *)tableHeaderView {
    _tableHeaderView = tableHeaderView;
    if(self.tableView){
        self.tableView.tableHeaderView = tableHeaderView;
    }
}

- (void)setErrorViewTopOffset:(CGFloat)errorViewTopOffset {
    _errorViewTopOffset = errorViewTopOffset;
    
    [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(errorViewTopOffset);
    }];
}

- (void)initNotifyBarView {
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBarView];
}

//- (void)initGroupChatBtn {
//    self.groupChatBtn = [[UIButton alloc] init];
//    [_groupChatBtn setImage:[UIImage imageNamed:@"fh_ugc_group_chat_tip"] forState:UIControlStateNormal];
//    [_groupChatBtn addTarget:self action:@selector(gotoGroupChat) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_groupChatBtn];
//    [_groupChatBtn setHidden:YES];
//}
//
//- (void)initBageView {
//    self.bageView = [[TTBadgeNumberView alloc] init];
//    _bageView.badgeNumber = [[NSNumber numberWithInt:0] integerValue];
//    [self.view addSubview:_bageView];
//}


- (void)initPublishBtn {
    self.publishBtn = [[UIButton alloc] init];
    [_publishBtn setImage:[UIImage imageNamed:@"fh_ugc_publish"] forState:UIControlStateNormal];
    [_publishBtn addTarget:self action:@selector(goToPublish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publishBtn];
    _publishBtn.hidden = self.hidePublishBtn;
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.tableView);
        make.height.mas_equalTo(32);
    }];
    
    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-self.publishBtnBottomHeight);
        make.right.mas_equalTo(self.view).offset(-12);
        make.width.height.mas_equalTo(64);
    }];
    
//    [self.groupChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.view).offset(-self.publishBtnBottomHeight - 64);
//        make.right.mas_equalTo(self.view).offset(-12);
//        make.width.height.mas_equalTo(64);
//    }];
//
//    [self.bageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.groupChatBtn).offset(5);
//        make.right.mas_equalTo(self.self.groupChatBtn).offset(-5);
//        make.height.mas_equalTo(15);
//    }];
}

//- (void)updateViews {
//    if (_forumId > 0 && (_scialGroupData.userAuth > UserAuthTypeNormal || [_scialGroupData.chatStatus.conversationId integerValue] > 0)) {
//        [_groupChatBtn setHidden:NO];
//    } else {
//        [_groupChatBtn setHidden:YES];
//    }
//     NSUInteger unreadCount = [[IMManager shareInstance].chatService sdkConversationWithIdentifier:_scialGroupData.chatStatus.conversationId].unreadCount;
//    if (_scialGroupData.chatStatus.conversationStatus == joinConversation) {
//        if ([[IMManager shareInstance].chatService sdkConversationWithIdentifier:_scialGroupData.chatStatus.conversationId].mute && unreadCount > 0) {
//            _bageView.badgeNumber = TTBadgeNumberPoint;
//            [self.bageView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(self.groupChatBtn).offset(7);
//                make.right.mas_equalTo(self.self.groupChatBtn).offset(-7);
//                make.height.mas_equalTo(10);
//                make.width.mas_equalTo(10);
//            }];
//        } else {
//            _bageView.badgeNumber = unreadCount;
//            [self.bageView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(self.groupChatBtn).offset(5);
//                make.right.mas_equalTo(self.self.groupChatBtn).offset(-5);
//                make.height.mas_equalTo(15);
//            }];
//        }
//    }
//}

- (void)initViewModel {
    FHCommunityFeedListBaseViewModel *viewModel = nil;

    if(self.listType == FHCommunityFeedListTypeNearby){
        viewModel = [[FHCommunityFeedListNearbyViewModel alloc] initWithTableView:_tableView controller:self];
        viewModel.categoryId = @"f_ugc_neighbor";
    }else if(self.listType == FHCommunityFeedListTypeMyJoin) {
        viewModel = [[FHCommunityFeedListMyJoinViewModel alloc] initWithTableView:_tableView controller:self];
        viewModel.categoryId = @"f_ugc_follow";
    }else if(self.listType == FHCommunityFeedListTypePostDetail) {
        FHCommunityFeedListPostDetailViewModel *postDetailViewModel = [[FHCommunityFeedListPostDetailViewModel alloc] initWithTableView:_tableView controller:self];
        postDetailViewModel.socialGroupId = self.forumId;
        postDetailViewModel.tabName = self.tabName;
        postDetailViewModel.categoryId = @"f_project_social";
        viewModel = postDetailViewModel;
    }
    
    self.viewModel = viewModel;
    self.needReloadData = YES;
    //切换开关
    WeakSelf;
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        StrongSelf;
        NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
        if(self.currentCityId != cityId){
            self.needReloadData = YES;
            self.currentCityId = cityId;
        }
    }];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:YES];
    } else {
        if(!self.hasValidateData){
            if(!self.showErrorView && self.errorViewHeight > 0){
                [self.viewModel showCustomErrorView:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }else{
                [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        }
    }
}

- (void)startLoadData:(BOOL)isFirst {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:isFirst];
    } else {
        if(!self.hasValidateData){
            if(!self.showErrorView && self.errorViewHeight > 0){
                [self.viewModel showCustomErrorView:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }else{
                [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        }
    }
}

- (void)scrollToTopAndRefreshAllData {
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO]; 
    [self startLoadData];
}

- (void)scrollToTopAndRefresh {
    if(self.viewModel.isRefreshingTip || self.isLoadingData){
        return;
    }
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.tableView triggerPullDown];
}

- (void)retryLoadData {
    [self startLoadData];
}

- (void)goToPublish {
    
    [self showPublishMenu];
}

- (FHUGCPostMenuView *)publishMenuView {
    
    if(!_publishMenuView) {
        _publishMenuView = [[FHUGCPostMenuView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _publishMenuView.delegate = self;
    }
    return _publishMenuView;
}

- (void)showPublishMenu {
    [self.publishMenuView showForButton:self.publishBtn];
}

#pragma mark - FHUGCPostMenuViewDelegate

- (void)gotoPostPublish {
    
    if(self.publishBlock){
        self.publishBlock();
        return;
    }
    [self gotoPostThreadVC];
    
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_ELEMENT_TYPE] = @"feed_icon";
    params[UT_PAGE_TYPE] = [self pageType];
    TRACK_EVENT(@"click_options", params);
}

- (void)gotoVotePublish {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[UT_ELEMENT_TYPE] = @"vote_icon";
    params[UT_PAGE_TYPE] = [self pageType];
    TRACK_EVENT(@"click_options", params);
    
    if ([TTAccountManager isLogin]) {
        [self gotoVoteVC];
    } else {
        [self gotoLogin:FHUGCLoginFrom_VOTE];
    }
}

// 发布按钮点击
- (void)gotoPostThreadVC {
    if ([TTAccountManager isLogin]) {
        [self gotoPostVC];
    } else {
        [self gotoLogin:FHUGCLoginFrom_POST];
    }
}

- (NSString *)pageType {
    NSString *page_type = UT_BE_NULL;
    if (self.listType == FHCommunityFeedListTypeMyJoin) {
        page_type = @"my_join_list";
    } else  if (self.listType == FHCommunityFeedListTypeNearby) {
        page_type = @"nearby_list";
    }
    return page_type;
}
- (void)gotoLogin:(FHUGCLoginFrom)from {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *page_type = @"nearby_list";
    if (self.listType == FHCommunityFeedListTypeMyJoin) {
        page_type = @"my_join_list";
    } else  if (self.listType == FHCommunityFeedListTypeNearby) {
        page_type = @"nearby_list";
    }
    [params setObject:page_type forKey:@"enter_from"];
    [params setObject:@"click_publisher" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                if (from == FHUGCLoginFrom_POST) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                       [wSelf gotoPostVC];
                                   });
                
                } else if(from == FHUGCLoginFrom_VOTE) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [wSelf gotoVoteVC];
                    });
                }
            }
        }
    }];
}

// 跳转到投票发布器
- (void)gotoVoteVC {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"sslocal://ugc_vote_publish"];
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[UT_ENTER_FROM] = [self pageType];
    dict[TRACER_KEY] = tracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
}

// 跳转到UGC发布器
- (void)gotoPostVC {

    // 跳转到发布器
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"element_type"] = @"feed_publisher";
    NSString *page_type = @"nearby_list";
    if (self.listType == FHCommunityFeedListTypeMyJoin) {
        page_type = @"my_join_list";
    } else  if (self.listType == FHCommunityFeedListTypeNearby) {
        page_type = @"nearby_list";
    }
    tracerDict[@"page_type"] = page_type;// “附近”：’nearby_list‘；“我加入的”：’my_join_list‘；'圈子子详情页‘：community_group_detail‘
    [FHUserTracker writeEvent:@"click_publisher" params:tracerDict];
    
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    NSMutableDictionary *dict = @{}.mutableCopy;
    traceParam[@"page_type"] = @"feed_publisher";
    traceParam[@"enter_from"] = page_type;
    dict[TRACER_KEY] = traceParam;
    dict[VCTITLE_KEY] = @"发帖";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://ugc_post"];
    [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:userInfo];
}

//- (void)gotoGroupChatVC:(NSString *)convId isCreate:(BOOL)isCreate autoJoin:(BOOL)autoJoin {
//    //跳转到群聊页面
//    NSMutableDictionary *dict = @{}.mutableCopy;
//    dict[@"conversation_id"] = convId;
//    dict[@"chat_avatar"] = _scialGroupData.avatar;
//    dict[@"chat_name"] = _scialGroupData.socialGroupName;
//    dict[@"community_id"] = _scialGroupData.socialGroupId;
//    NSMutableDictionary *reportDic = [NSMutableDictionary dictionary];
//    [reportDic setValue:@"community_group_detail" forKey:@"enter_from"];
//    [reportDic setValue:@"ugc_member_talk" forKey:@"element_from"];
// 
//    if (isCreate) {
//        dict[@"is_create"] = @"1";
//        NSString *title = [@"" stringByAppendingFormat:@"%@(%@)", _scialGroupData.socialGroupName, _scialGroupData.followerCount];
//        dict[@"chat_title"] = title;
//        dict[@"chat_member_count"] = _scialGroupData.followerCount;
//        dict[@"idempotent_id"] = isEmptyString(_scialGroupData.chatStatus.idempotentId) ? _scialGroupData.socialGroupId : _scialGroupData.chatStatus.idempotentId;
//    } else if (autoJoin) {
//        dict[@"auto_join"] = @"1";
//        dict[@"conversation_id"] = _scialGroupData.chatStatus.conversationId;
//        dict[@"short_conversation_id"] = [[NSNumber numberWithLongLong:_scialGroupData.chatStatus.conversationShortId] stringValue];
//        NSString *title = [@"" stringByAppendingFormat:@"%@(%d)", _scialGroupData.socialGroupName, _scialGroupData.chatStatus.currentConversationCount];
//        dict[@"chat_title"] = title;
//    } else {
//        NSInteger count = [[IMManager shareInstance].chatService sdkConversationWithIdentifier:convId].participantsCount;
//        NSString *title = [@"" stringByAppendingFormat:@"%@(%d)", _scialGroupData.socialGroupName, count];
//        dict[@"chat_title"] = title;
//        dict[@"in_conversation"] = @"1";
//        dict[@"conversation_id"] = _scialGroupData.chatStatus.conversationId;
//        dict[@"short_conversation_id"] = [[NSNumber numberWithLongLong:_scialGroupData.chatStatus.conversationShortId] stringValue];
//    }
//    dict[@"member_role"] = [NSString stringWithFormat: @"%d", _scialGroupData.userAuth];
//    dict[@"is_admin"] = @(_scialGroupData.userAuth > UserAuthTypeNormal);
//    dict[@"report_params"] = [[reportDic JSONRepresentation] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    @weakify(self);
//    dict[@"group_chat_page_exit_block"] = ^(void) {
//        @strongify(self);
//        if([self.delegate respondsToSelector:@selector(refreshBasicInfo)]) {
//            [self.delegate refreshBasicInfo];
//        }
//    };
//    _bageView.badgeNumber = 0;
//    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
//    
//    NSURL* url = [NSURL URLWithString:@"sslocal://open_group_chat"];
//    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
//}

#pragma mark - show notify

- (void)showNotify:(NSString *)message
{
    [self showNotify:message completion:nil];
}

- (void)showNotify:(NSString *)message completion:(void(^)())completion{
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = self.notifyBarView.height;
    self.tableView.contentInset = inset;
    self.tableView.contentOffset = CGPointMake(0, -inset.top);
    self.notifyCompletionBlock = completion;
    WeakSelf;
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil willHideBlock:^(ArticleListNotifyBarView *barView, BOOL isImmediately) {
        if(!isImmediately) {
            [wself hideIfNeeds];
        } else {
            if(wself.notifyCompletionBlock) {
                wself.notifyCompletionBlock();
            }
        }
    }];
}

- (void)hideIfNeeds {
    [UIView animateWithDuration:0.3 animations:^{
        
        if ([TTDeviceHelper isIPhoneXDevice]) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }else{
            self.tableView.contentInset = UIEdgeInsetsZero;
        }
        self.tableView.originContentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
    }completion:^(BOOL finished) {
        if (self.notifyCompletionBlock) {
            self.notifyCompletionBlock();
        }
    }];
}

- (void)hideImmediately {
    [self.notifyBarView hideImmediately];
}

- (NSArray *)dataList {
    return self.viewModel.dataList;
}

#pragma mark - TTAccountMulticaastProtocol

// 帐号切换
- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName {
    if(self.listType != FHCommunityFeedListTypePostDetail) {
        self.needReloadData = YES;
    }
}

#pragma mark -- SSImpressionProtocol

- (void)needRerecordImpressions {
    if (self.viewModel.dataList.count == 0) {
        return;
    }

    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.refer = self.viewModel.refer;

    for (FHUGCBaseCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[FHUGCBaseCell class]]) {
            id data = cell.currentData;
            if ([data isKindOfClass:[FHFeedUGCCellModel class]]) {
                FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
                if (self.viewModel.isShowing) {
                    [self.viewModel recordGroupWithCellModel:cellModel status:SSImpressionStatusRecording];
                }
                else {
                    [self.viewModel recordGroupWithCellModel:cellModel status:SSImpressionStatusSuspend];
                }
            }
        }
    }
}


@end
