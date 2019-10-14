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
#import "IMManager.h"

@interface FHCommunityFeedListController ()<SSImpressionProtocol>

@property(nonatomic, strong) FHCommunityFeedListBaseViewModel *viewModel;
@property(nonatomic, assign) BOOL needReloadData;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);
@property(nonatomic, assign) NSInteger currentCityId;

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
    
    if(self.viewModel.dataList.count > 0){
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
    [self initPublishBtn];
    if (_forumId > 0) {
        [self initGroupChatBtn];
    }
    
    if(self.showErrorView){
        [self addDefaultEmptyViewFullScreen];
    }
}

- (void)initTableView {
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

- (void)setTableHeaderView:(UIView *)tableHeaderView {
    _tableHeaderView = tableHeaderView;
    if(self.tableView){
        self.tableView.tableHeaderView = tableHeaderView;
    }
}

- (void)initNotifyBarView {
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBarView];
}

- (void)initGroupChatBtn {
    self.groupChatBtn = [[UIButton alloc] init];
    [_groupChatBtn setImage:[UIImage imageNamed:@"fh_ugc_publish"] forState:UIControlStateNormal];
    [_groupChatBtn addTarget:self action:@selector(gotoGroupChat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_groupChatBtn];
}


- (void)initPublishBtn {
    self.publishBtn = [[UIButton alloc] init];
    [_publishBtn setImage:[UIImage imageNamed:@"fh_ugc_publish"] forState:UIControlStateNormal];
    [_publishBtn addTarget:self action:@selector(goToPublish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publishBtn];
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
    
    [self.groupChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-self.publishBtnBottomHeight - 64);
        make.right.mas_equalTo(self.view).offset(-12);
        make.width.height.mas_equalTo(64);
    }];
}

- (void)initViewModel {
    FHCommunityFeedListBaseViewModel *viewModel = nil;

    if(self.listType == FHCommunityFeedListTypeNearby){
        viewModel = [[FHCommunityFeedListNearbyViewModel alloc] initWithTableView:_tableView controller:self];
        viewModel.categoryId = @"f_ugc_neighbor";
//        viewModel.categoryId = @"f_shipin";
//        viewModel.categoryId = @"f_hotsoon_video";
    }else if(self.listType == FHCommunityFeedListTypeMyJoin) {
        viewModel = [[FHCommunityFeedListMyJoinViewModel alloc] initWithTableView:_tableView controller:self];
        viewModel.categoryId = @"f_ugc_follow";
    }else if(self.listType == FHCommunityFeedListTypePostDetail) {
        FHCommunityFeedListPostDetailViewModel *postDetailViewModel = [[FHCommunityFeedListPostDetailViewModel alloc] initWithTableView:_tableView controller:self];
        postDetailViewModel.socialGroupId = self.forumId;
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
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)startLoadData:(BOOL)isFirst {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:isFirst];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
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
    if(self.publishBlock){
        self.publishBlock();
        return;
    }
    [self gotoPostThreadVC];
}

//创建新群聊时配置群聊的名称和头像
- (void)initNewGroupChatOptions:(NSString * _Nullable)conversationIdentifier {
    NSString *icon = _scialGroupData.avatar;
    NSString *groupChatName = _scialGroupData.socialGroupName;
    TIMOConversation *sdkConversation = [[IMManager shareInstance].chatService sdkConversationWithIdentifier:conversationIdentifier];
    [sdkConversation setIcon:icon completion:^(id<TIMOConversationOperationResponse>  _Nullable response, NSError * _Nullable error) {
        if (!error && response.status == 0) {
            NSLog(@"FHIM_Group_chat_avatar_succes");
        }
    }];
    [sdkConversation setName:groupChatName completion:^(id<TIMOConversationOperationResponse>  _Nullable response, NSError * _Nullable error) {
        if (!error && response.status == 0) {
           NSLog(@"FHIM_Group_chat_name_succes");
        }
    }];
}

- (void)createNewGroupChat {
    NSMutableDictionary* options = [NSMutableDictionary dictionary];
    [options setValue:_forumId forKey:@"community_id"];
    [options setValue:@"ugc_group" forKey:@"business_type"];
    
    NSMutableSet* set = [NSMutableSet set];
    [set addObject:@"103002277932"];
    [set addObject:@"25505054509"];
    [set addObject:@"2422949347070968"];
    [[IMManager shareInstance].chatService createGroupConversation:options
                                                  withParticipants:set
                                          withIdempotentIdentifier:[_forumId substringToIndex:(_forumId.length-3)]
                                                    withCompletion:^(NSString * _Nullable conversationIdentifier, NSDictionary * _Nullable response, NSError * _Nullable error) {
        if(!error) {
            [self initNewGroupChatOptions:conversationIdentifier];
            [self gotoGroupChatVC:conversationIdentifier isCreate:YES];
        }
    }];
}

- (void)gotoGroupChat {
   if ([TTAccountManager isLogin]) {
       if (isEmptyString(_conversationId)) {
           [self createNewGroupChat];
       } else {
           [self gotoGroupChatVC:_conversationId isCreate:NO];
       }
   } else {
       [self gotoLogin];
   }
}

// 发布按钮点击
- (void)gotoPostThreadVC {
    if ([TTAccountManager isLogin]) {
        [self gotoPostVC];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoLogin {
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
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wSelf gotoPostVC];
                });
            }
        }
    }];
}

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
    tracerDict[@"page_type"] = page_type;// “附近”：’nearby_list‘；“我加入的”：’my_join_list‘；'小区圈子详情页‘：community_group_detail‘
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

- (void)gotoGroupChatVC:(NSString *)convId isCreate:(BOOL)isCreate {
    //跳转到群聊页面
    NSString *title = [@"" stringByAppendingFormat:@"%@(%@)", _scialGroupData.socialGroupName, _scialGroupData.followerCount];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"chat_title"] = title;
    dict[@"conversation_id"] = convId;
    if (isCreate) {
        dict[@"is_create"] = @"1";
    }
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://open_group_chat"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

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
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil willHideBlock:^(ArticleListNotifyBarView *barView, BOOL isImmediately) {
        WeakSelf;
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
