//
// Created by zhulijun on 2019-06-12.
//

#import <TTBaseLib/UIButton+TTAdditions.h>
#import "FHCommunityDetailViewModel.h"
#import "FHCommunityDetailViewController.h"
#import "FHCommunityFeedListController.h"
#import "FHCommunityDetailHeaderView.h"
#import "TTBaseMacro.h"
#import "FHHouseUGCAPI.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "UIImageView+BDWebImage.h"
#import "UILabel+House.h"
#import "FHUGCFollowButton.h"
#import "FHUGCFollowHelper.h"
#import "FHUGCGuideView.h"
#import "FHUGCGuideHelper.h"
#import "FHUGCScialGroupModel.h"
#import "FHUGCConfig.h"
#import "TTAccountManager.h"
#import "FHUserTracker.h"
#import "FHCommunityDetailMJRefreshHeader.h"
#import "MJRefresh.h"
#import "FHCommonDefines.h"
#import "TTUIResponderHelper.h"
#import <TTUGCEmojiParser.h>
#import "TTAccount.h"
#import "TTAccount+Multicast.h"
#import "TTAccountManager.h"
#import "TTHorizontalPagingView.h"
#import "IMManager.h"
#import <TTThemedAlertController.h>
#import "FHFeedUGCCellModel.h"
#import <TTUGCDefine.h>

#define kSegmentViewHeight 52

@interface FHCommunityDetailViewModel () <FHUGCFollowObserver, TTHorizontalPagingViewDelegate>

@property (nonatomic, weak) FHCommunityDetailViewController *viewController;
@property (nonatomic, strong) FHCommunityFeedListController *feedListController; //当前显示的feedVC
@property (nonatomic, strong) FHUGCScialGroupDataModel *data;
@property (nonatomic, strong) FHUGCScialGroupModel *socialGroupModel;
@property (nonatomic, assign) BOOL isViewAppear;
@property (nonatomic, assign) BOOL isLoginSatusChangeFromGroupChat;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) TTHorizontalPagingView *pagingView;
@property (nonatomic, strong) NSMutableArray *subVCs;
@property (nonatomic, strong) NSMutableArray *segmentTitles;
@property (nonatomic, copy) NSString *currentSegmentType;
@property (nonatomic, copy) NSString *defaultType;
@property (nonatomic, assign) NSInteger selectedIndex;
//精华tab的index，默认是-1
@property (nonatomic, assign) NSInteger essenceIndex;
@property (nonatomic, assign) BOOL isFirstEnter;

@property (nonatomic, strong) FHUGCGuideView *guideView;
@property (nonatomic) BOOL shouldShowUGcGuide;
@end

@implementation FHCommunityDetailViewModel

- (instancetype)initWithController:(FHCommunityDetailViewController *)viewController tracerDict:(NSDictionary*)tracerDict {
    self = [super init];
    if (self) {
        self.tracerDict = tracerDict;
        self.viewController = viewController;
        [self initView];
        self.shouldShowUGcGuide = YES;
        self.isViewAppear = YES;
        self.isLogin = TTAccountManager.isLogin;
        self.isFirstEnter = YES;
        self.viewController.segmentView.delegate = self;
        self.essenceIndex = -1;
        
        // 分享埋点
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
        params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
        params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
        params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
        params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
        self.shareTracerDict = [params copy];
        
        self.subVCs = [NSMutableArray array];
    }
    return self;
}

- (void)initView {
    MJWeakSelf;
    self.viewController.headerView.refreshHeader.refreshingBlock = ^{
        [weakSelf requestData:YES refreshFeed:YES showEmptyIfFailed:NO showToast:YES];
        weakSelf.pagingView.userInteractionEnabled = NO;
    };
    
    self.viewController.headerView.refreshHeader.endRefreshingCompletionBlock = ^{
        [weakSelf.pagingView reloadHeaderShowHeight];
        weakSelf.pagingView.userInteractionEnabled = YES;
    };

    [TTAccount addMulticastDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGlobalFollowListLoad:) name:kFHUGCLoadFollowDataFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSuccess:) name:kTTForumPostThreadSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delPostThreadSuccess:) name:kFHUGCDelPostNotification object:nil];
    // 加精或取消加精成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postGoodSuccess:) name:kFHUGCGoodPostNotification object:nil];
}

- (void)postGoodSuccess:(NSNotification *)noti {
    if (noti && noti.userInfo) {
        NSDictionary *userInfo = noti.userInfo;
        NSString *social_group_ids = userInfo[@"social_group_ids"] ? userInfo[@"social_group_ids"] : userInfo[@"social_group_id"];
        
        if(social_group_ids.length > 0 && [social_group_ids containsString:self.viewController.communityId]){
            //多于1个tab的时候
            if(self.socialGroupModel.data.tabInfo && self.socialGroupModel.data.tabInfo.count > 1 && self.essenceIndex > -1 && self.essenceIndex < self.subVCs.count){
                FHCommunityFeedListController *feedVC = self.subVCs[self.essenceIndex];
                feedVC.needReloadData = YES;
            }
        }
    }
}
// 发帖成功通知
- (void)postThreadSuccess:(NSNotification *)noti {
    if (noti) {
        NSString *groupId = noti.userInfo[@"social_group_id"];
        if (groupId.length > 0 && self.viewController.communityId.length > 0 && [groupId containsString:self.viewController.communityId]) {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                FHUGCScialGroupDataModel *groupData = [[FHUGCConfig sharedInstance] socialGroupData:weakSelf.data.socialGroupId];
                if (groupData) {
                    weakSelf.data.contentCount = groupData.contentCount;
                    weakSelf.data.countText = groupData.countText;
                    weakSelf.data.hasFollow = groupData.hasFollow;
                    weakSelf.data.followerCount = groupData.followerCount;
                }
                [weakSelf updateUIWithData:weakSelf.data];
            });
        }
    }
}

// 删帖成功通知
- (void)delPostThreadSuccess:(NSNotification *)noti {
    NSString *groupId = noti.userInfo[@"social_group_id"];
    
//    if([groupId isEqualToString:self.viewController.communityId]){
//        //多于1个tab的时候
//        if(self.socialGroupModel.data.tabInfo && self.socialGroupModel.data.tabInfo.count > 1 && self.essenceIndex > -1 && self.essenceIndex < self.subVCs.count){
//            FHCommunityFeedListController *feedVC = self.subVCs[self.essenceIndex];
//            feedVC.needReloadData = YES;
//        }
//    }
    
    if (groupId.length > 0 && [groupId isEqualToString:self.viewController.communityId]) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            FHUGCScialGroupDataModel *groupData = [[FHUGCConfig sharedInstance] socialGroupData:weakSelf.data.socialGroupId];
            if (groupData) {
                weakSelf.data.contentCount = groupData.contentCount;
                weakSelf.data.countText = groupData.countText;
                weakSelf.data.hasFollow = groupData.hasFollow;
                weakSelf.data.followerCount = groupData.followerCount;
            }
            [weakSelf updateUIWithData:weakSelf.data];
        });
    }
}

- (void)dealloc {
    [TTAccount removeMulticastDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addUgcGuide {
    if ([FHUGCGuideHelper shouldShowUgcDetailGuide]) {
        [self.guideView show:self.viewController.view dismissDelayTime:0.0f completion:nil];
        [FHUGCGuideHelper hideUgcDetailGuide];
    }
}

- (FHUGCGuideView *)guideView {
    if (!_guideView) {
        WeakSelf;
        _guideView = [[FHUGCGuideView alloc] initWithFrame:self.viewController.view.bounds andType:FHUGCGuideViewTypeDetail];
        [self.viewController.view layoutIfNeeded];
        CGRect rect = [self.viewController.headerView.followButton convertRect:self.viewController.headerView.followButton.bounds toView:self.viewController.view];
        _guideView.focusBtnTopY = rect.origin.y;
        _guideView.clickBlock = ^{
            [wself hideGuideView];
        };
    }
    return _guideView;
}

- (void)hideGuideView {
    [self.guideView hide];
}

- (void)viewWillAppear {
    [self.feedListController viewWillAppear];
}

- (void)viewDidAppear {
    self.isViewAppear = YES;
    [self updateNavBarWithAlpha:self.viewController.customNavBarView.bgView.alpha];
    // 帖子数同步逻辑
    FHUGCScialGroupDataModel *tempModel = self.data;
    if (tempModel) {
        NSString *socialGroupId = tempModel.socialGroupId;
        FHUGCScialGroupDataModel *model = [[FHUGCConfig sharedInstance] socialGroupData:socialGroupId];
        if (model && (![model.countText isEqualToString:tempModel.countText] || ![model.hasFollow isEqualToString:tempModel.hasFollow])) {
            tempModel.countText = model.countText;
            tempModel.contentCount = model.contentCount;
            tempModel.hasFollow = model.hasFollow;
            tempModel.followerCount = model.followerCount;
            [self updateUIWithData:tempModel];
        }
    }
}

- (void)viewWillDisappear {
    [self.feedListController viewWillDisappear];
    self.isViewAppear = NO;
}

- (void)endRefreshing {
    [self.viewController.headerView.refreshHeader endRefreshing];
}

- (void)requestData:(BOOL) userPull refreshFeed:(BOOL) refreshFeed showEmptyIfFailed:(BOOL) showEmptyIfFailed showToast:(BOOL) showToast{
    if(self.isFirstEnter){
        [self.viewController tt_startUpdate];
    }
    
    if (![TTReachability isNetworkConnected]) {
        [self onNetworError:showEmptyIfFailed showToast:showToast];
        if(userPull){
            [self endRefreshing];
        }
        [_viewController tt_endUpdataData];
        return;
    }
    
    if(self.viewController.communityId.length <= 0) {
        [_viewController tt_endUpdataData];
        if(userPull){
            [self endRefreshing];
        }
        return;
    }
    
    // 请求basicInfo信息期间群聊按钮不可点击
    self.viewController.groupChatBtn.enabled = NO;
    
    WeakSelf;
    [FHHouseUGCAPI requestCommunityDetail:self.viewController.communityId class:FHUGCScialGroupModel.class completion:^(id <FHBaseModelProtocol> model, NSError *error) {
        StrongSelf;
        
        [_viewController tt_endUpdataData];

        //basicInfo信息接口回来后群聊按钮才可以点击
        self.viewController.groupChatBtn.enabled = YES;
        
        if(userPull){
            [self endRefreshing];
        }
        
        if(error){
            [self onNetworError:showEmptyIfFailed showToast:showToast];
        }
        
        // 根据basicInfo接口成功失败决定是否显示群聊入口按钮
        self.viewController.groupChatBtn.hidden = (error != nil);
        
        if (model) {
            FHUGCScialGroupModel *responseModel = (FHUGCScialGroupModel *)model;
            self.socialGroupModel = responseModel;
            BOOL isFollowed = [responseModel.data.hasFollow boolValue];
            if(isFollowed == NO) {
                self.viewController.bageView.badgeNumber = TTBadgeNumberHidden;
            }
            [wself updateUIWithData:responseModel.data];
            if (responseModel.data) {
                // 更新圈子数据
                [[FHUGCConfig sharedInstance] updateSocialGroupDataWith:responseModel.data];
                if(self.isFirstEnter){
                    //初始化segment
                    [self initSegment];
                    //初始化vc
                    [self initSubVC];
                }else{
                    [self updateVC];
                }

                if (self.isLoginSatusChangeFromGroupChat) {
                    [self gotoGroupChat];
                    self.isLoginSatusChangeFromGroupChat = NO;
                }

                if (refreshFeed) {
                    [self.feedListController startLoadData:YES];
                }
            }
        }
    }];
}

-(void)onNetworError:(BOOL)showEmpty showToast:(BOOL)showToast{
    if(showEmpty){
        self.feedListController.view.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
    if(showToast){
        [[ToastManager manager] showToast:@"网络异常"];
    }
}
// 发布按钮点击
- (void)gotoPostThreadVC {
    if ([TTAccountManager isLogin]) {
        [self goPostDetail];
    } else {
        [self gotoLogin:FHUGCLoginFrom_POST];
    }
}

- (void)gotoVotePublish {
    if ([TTAccountManager isLogin]) {
        [self gotoVoteVC];
    } else {
        [self gotoLogin:FHUGCLoginFrom_VOTE];
    }
}

- (void)gotoWendaPublish {
    if ([TTAccountManager isLogin]) {
        [self gotoWendaVC];
    } else {
        [self gotoLogin:FHUGCLoginFrom_WENDA];
    }
}

// 跳转到投票发布器
- (void)gotoVoteVC {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"sslocal://ugc_vote_publish"];
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[UT_ENTER_FROM] = self.tracerDict[UT_PAGE_TYPE]?:UT_BE_NULL;
    dict[TRACER_KEY] = tracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
}

- (void)gotoWendaVC {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"sslocal://ugc_wenda_publish"];
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"select_group_id"] = self.socialGroupModel.data.socialGroupId;
    dict[@"select_group_name"] = self.socialGroupModel.data.socialGroupName;
    dict[@"select_group_followed"] = @(self.socialGroupModel.data.hasFollow.boolValue);
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[UT_ENTER_FROM] = self.tracerDict[UT_PAGE_TYPE]?:UT_BE_NULL;
    dict[TRACER_KEY] = tracerDict;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
}

- (void)initSegment {
    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *tabArray = [self.socialGroupModel.data.tabInfo mutableCopy];

    NSInteger selectedIndex = 0;
    if(tabArray && tabArray.count > 1) {
        for(NSInteger i = 0;i < tabArray.count;i++) {
            FHUGCScialGroupDataTabInfoModel *item = tabArray[i];
            if(!isEmptyString(item.showName)) {
                [titles addObject:item.showName];
            }
            //这里记录一下精华tab的index,为了后面加精和取消加精时候，可以标记vc刷新
            if([item.tabName isEqualToString:tabEssence]){
                self.essenceIndex = i;
            }
            if(item.isDefault) {
                selectedIndex = i;
                self.currentSegmentType = item.tabName;
                self.defaultType = item.tabName;
            }
        }
    }else{
        [titles addObject:@"全部"];
    }
    self.selectedIndex = selectedIndex;
    self.viewController.segmentView.selectedIndex = selectedIndex;
    self.viewController.segmentView.titles = titles;
    self.segmentTitles = titles;
}

- (void)initSubVC {
    [self.subVCs removeAllObjects];
    NSMutableArray *tabArray = [self.socialGroupModel.data.tabInfo mutableCopy];
    
    if(tabArray && tabArray.count > 1) {
        for(NSInteger i = 0;i < tabArray.count;i++) {
            FHUGCScialGroupDataTabInfoModel *item = tabArray[i];
            if(!isEmptyString(item.showName) && !isEmptyString(item.tabName)) {
                [self createFeedListController:item.tabName];
            }
        }
    }else{
        [self createFeedListController:nil];
    }
    
    self.pagingView.delegate = self;
    //放到最下面
    [self.viewController.view insertSubview:self.pagingView atIndex:0];
}

- (void)createFeedListController:(NSString *)tabName {
    WeakSelf;
    FHCommunityFeedListController *feedListController = [[FHCommunityFeedListController alloc] init];
    feedListController.tableViewNeedPullDown = NO;
    feedListController.showErrorView = NO;
    feedListController.scrollViewDelegate = self;
    feedListController.listType = FHCommunityFeedListTypePostDetail;
    feedListController.forumId = self.viewController.communityId;
    feedListController.hidePublishBtn = YES;
    feedListController.tabName = tabName;
    feedListController.isResetStatusBar = NO;
    //错误页高度
    if(self.socialGroupModel.data.tabInfo && self.socialGroupModel.data.tabInfo.count > 1){
        CGFloat errorViewHeight = [UIScreen mainScreen].bounds.size.height - self.viewController.customNavBarView.height;
        errorViewHeight -= kSegmentViewHeight;
        feedListController.errorViewHeight = errorViewHeight;
    }
    feedListController.notLoadDataWhenEmpty = YES;
    //传入选项信息
    feedListController.operations = self.socialGroupModel.data.permission;
    feedListController.beforeInsertPostBlock = ^{
        //如果是多tab，并且当前不在全部tab，这个时候要先切tab
        if(wself.selectedIndex != 0){
            wself.isFirstEnter = YES;
            wself.viewController.segmentView.selectedIndex = 0;
        }
    };
    
    [self.subVCs addObject:feedListController];
}

- (void)updateVC {
    for (FHCommunityFeedListController *feedListController in self.subVCs) {
        //更新管理员权限
        feedListController.operations = self.socialGroupModel.data.permission;
    }
}

- (void)gotoGroupChat {
    if ([TTAccountManager isLogin]) {
        if (self.socialGroupModel.data.chatStatus.currentConversationCount >= self.socialGroupModel.data.chatStatus.maxConversationCount && self.socialGroupModel.data.chatStatus.maxConversationCount > 0) {
            [[ToastManager manager] showToast:@"成员已达上限"];
        } else if ([self.socialGroupModel.data.chatStatus.conversationId integerValue] <= 0) {
            if (self.socialGroupModel.data.userAuth > UserAuthTypeNormal) {
                [self tryCreateNewGroupChat];
            }
        } else if(self.socialGroupModel.data.chatStatus.conversationStatus == joinConversation) {
            [self gotoGroupChatVC:self.socialGroupModel.data.chatStatus.conversationId isCreate:NO autoJoin:NO];
        } else if (self.socialGroupModel.data.chatStatus.conversationStatus == leaveConversation) {
            [self tryJoinConversation];
        } else if(self.socialGroupModel.data.chatStatus.conversationStatus == KickOutConversation) {
            [[ToastManager manager]showToast:@"你已经被移出群聊"];
        } else {
            [self tryJoinConversation];
        }
    } else {
        [self gotoLogin:FHUGCLoginFrom_GROUPCHAT];
    }
}

- (void)tryCreateNewGroupChat {
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"" message:@"确认开启圈子群聊，所有关注用户将默认加入群聊" preferredType:TTThemedAlertControllerTypeAlert];
    
    WeakSelf;
    [alertVC addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
    
    [alertVC addActionWithTitle:@"确认" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        StrongSelf;
        [self gotoGroupChatVC:@"-1" isCreate:YES autoJoin:NO];
    }];
    
    UIViewController *topVC = [TTUIResponderHelper topmostViewController];
    if (topVC) {
        [alertVC showFrom:topVC animated:YES];
    }
}

- (void)tryJoinConversation {
    if ([self.socialGroupModel.data.hasFollow integerValue] == 1) {
        [self gotoGroupChatVC:@"-1" isCreate:NO autoJoin:YES];
    } else {
        TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"" message:@"是否加入群聊并关注圈子？" preferredType:TTThemedAlertControllerTypeAlert];
        
        WeakSelf;
        [alertVC addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        
        [alertVC addActionWithTitle:@"确认" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            StrongSelf;
            if ([TTReachability isNetworkConnected]) {
                [self gotoGroupChatVC:@"-1" isCreate:NO autoJoin:YES];
                [[FHUGCConfig sharedInstance] followUGCBy:self.viewController.communityId isFollow:YES completion:^(BOOL isSuccess) {
                    
                }];
            } else {
                [[ToastManager manager] showToast:@"网络异常"];
            }
        }];
        
        UIViewController *topVC = [TTUIResponderHelper topmostViewController];
        if (topVC) {
            [alertVC showFrom:topVC animated:YES];
        }
    }
}

- (void)gotoGroupChatVC:(NSString *)convId isCreate:(BOOL)isCreate autoJoin:(BOOL)autoJoin {
    //跳转到群聊页面
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"conversation_id"] = convId;
    dict[@"chat_avatar"] = self.socialGroupModel.data.avatar;
    dict[@"chat_name"] = self.socialGroupModel.data.socialGroupName;
    dict[@"community_id"] = self.socialGroupModel.data.socialGroupId;
    NSMutableDictionary *reportDic = [NSMutableDictionary dictionary];
    [reportDic setValue:@"community_group_detail" forKey:@"enter_from"];
    [reportDic setValue:@"ugc_member_talk" forKey:@"element_from"];
    
    if (isCreate) {
        dict[@"is_create"] = @"1";
        NSString *title = [@"" stringByAppendingFormat:@"%@(%@)", self.socialGroupModel.data.socialGroupName, self.socialGroupModel.data.followerCount];
        dict[@"chat_title"] = title;
        dict[@"chat_member_count"] = self.socialGroupModel.data.followerCount;
        dict[@"idempotent_id"] = isEmptyString(self.socialGroupModel.data.chatStatus.idempotentId) ? self.socialGroupModel.data.socialGroupId : self.socialGroupModel.data.chatStatus.idempotentId;
    } else if (autoJoin) {
        dict[@"auto_join"] = @"1";
        dict[@"conversation_id"] = self.socialGroupModel.data.chatStatus.conversationId;
        dict[@"short_conversation_id"] = [[NSNumber numberWithLongLong:self.socialGroupModel.data.chatStatus.conversationShortId] stringValue];
        NSString *title = [@"" stringByAppendingFormat:@"%@(%d)", self.socialGroupModel.data.socialGroupName, self.socialGroupModel.data.chatStatus.currentConversationCount];
        dict[@"chat_title"] = title;
    } else {
        NSInteger count = [[IMManager shareInstance].chatService sdkConversationWithIdentifier:convId].participantsCount;
        NSString *title = [@"" stringByAppendingFormat:@"%@(%d)", self.socialGroupModel.data.socialGroupName, count];
        dict[@"chat_title"] = title;
        dict[@"in_conversation"] = @"1";
        dict[@"conversation_id"] = self.socialGroupModel.data.chatStatus.conversationId;
        dict[@"short_conversation_id"] = [[NSNumber numberWithLongLong:self.socialGroupModel.data.chatStatus.conversationShortId] stringValue];
    }
    dict[@"member_role"] = [NSString stringWithFormat: @"%d", self.socialGroupModel.data.userAuth];
    dict[@"is_admin"] = @(self.socialGroupModel.data.userAuth > UserAuthTypeNormal);
    dict[@"report_params"] = [[reportDic JSONRepresentation] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    WeakSelf;
    dict[@"group_chat_page_exit_block"] = ^(void) {
        StrongSelf;
        [self refreshBasicInfo];
    };
    self.viewController.bageView.badgeNumber = 0;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://open_group_chat"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)gotoLogin:(FHUGCLoginFrom)from {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"community_group_detail" forKey:@"enter_from"];
    [params setObject:@"feed_like" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                if(from == FHUGCLoginFrom_GROUPCHAT) {
                    [self onLoginIn];
                }
                else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        switch(from) {
                            case FHUGCLoginFrom_POST:
                            {
                                [self goPostDetail];
                            }
                                break;
                            case FHUGCLoginFrom_VOTE:
                            {
                                [self gotoVoteVC];
                            }
                                break;
                            case FHUGCLoginFrom_WENDA:
                            {
                                [self gotoWendaVC];
                            }
                                break;
                            default:
                                break;
                        }
                    });
                }
            }
        }
    }];
}

- (void)goPostDetail {
    if (!self.viewController.headerView.followButton.followed) {
        WeakSelf;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"先关注该小区才能发布哦"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 // 点击取消按钮，调用此block
                                                                 [wself addPublisherPopupClickLog:NO];
                                                             }];
        [alert addAction:cancelAction];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"关注"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  // 点击按钮，调用此block
                                                                  [wself addPublisherPopupClickLog:YES];
                                                                  [wself followCommunity:wself.data.socialGroupId];
                                                              }];
        [alert addAction:defaultAction];
        [self.viewController presentViewController:alert animated:YES completion:nil];
        
        [self addPublisherPopupShowLog];
        return;
    }
    [self gotoPostVC];
}

- (void)followCommunity:(NSString *)groupId {
    if (groupId) {
        WeakSelf;
        NSString *enter_from = @"community_group_detail";
        [[FHUGCConfig sharedInstance] followUGCBy:groupId isFollow:YES enterFrom:enter_from enterType:@"click" completion:^(BOOL isSuccess) {
            StrongSelf;
            if (isSuccess) {
                [wself gotoPostVC];
            }
        }];
    }
}

- (void)gotoPostVC {
    // 跳转发布器
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"element_type"] = @"feed_publisher";
    tracerDict[@"page_type"] = @"community_group_detail";
    [FHUserTracker writeEvent:@"click_publisher" params:tracerDict];
    
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    NSMutableDictionary *dict = @{}.mutableCopy;
    traceParam[@"page_type"] = @"feed_publisher";
    traceParam[@"enter_from"] = @"community_group_detail";
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"select_group_id"] = self.data.socialGroupId;
    dic[@"select_group_name"] = self.data.socialGroupName;
    dic[TRACER_KEY] = traceParam;
    dic[VCTITLE_KEY] = @"发帖";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dic];
    NSURL *url = [NSURL URLWithString:@"sslocal://ugc_post"];
    [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:userInfo];
}

- (void)refreshContentOffset:(CGFloat)offset {
    CGFloat alpha = offset / (80.0f);
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    [self updateNavBarWithAlpha:alpha];
}

- (void)updateNavBarWithAlpha:(CGFloat)alpha {
    if (!self.isViewAppear) {
        return;
    }
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    if (alpha <= 0.1f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = YES;
        self.viewController.rightBtn.hidden = YES;
        self.shareButton.hidden = NO;
    } else if (alpha > 0.1f && alpha < 0.9f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.viewController.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = YES;
        self.viewController.rightBtn.hidden = YES;
        self.shareButton.hidden = NO;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = NO;
        self.viewController.rightBtn.hidden = NO;
        self.shareButton.hidden = YES;
    }
    [self.viewController.customNavBarView refreshAlpha:alpha];

    NSMutableArray *tabArray = [self.socialGroupModel.data.tabInfo mutableCopy];
    if(tabArray && tabArray.count > 1) {
        self.viewController.customNavBarView.seperatorLine.hidden = YES;
    }
}

// 关注状态改变
- (void)followStateChanged:(NSNotification *)notification {
    if (notification) {
        BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
        NSString *groupId = notification.userInfo[@"social_group_id"];
        NSString *currentGroupId = self.viewController.communityId;
        if (groupId.length > 0 && currentGroupId.length > 0) {
            if ([groupId isEqualToString:currentGroupId]) {
                [self updateFollowStatus:followed];
            }
        }
    }
}

-(void)updateFollowStatus:(BOOL)followed{
    [[FHUGCConfig sharedInstance] updateScialGroupDataModel:self.data byFollowed:followed];
    [self updateUIWithData:self.data];
}

// 未登录状态下进入圈子详情页，点击发帖，这时候跳转登录，如果登录用户已经关注这个圈子，收取通知来更新状态
-(void)onGlobalFollowListLoad:(NSNotification *)notification{
    FHUGCScialGroupDataModel *dataInFollowList = [[FHUGCConfig sharedInstance] socialGroupData:self.data.socialGroupId];
    if(!dataInFollowList){
        return;
    }
    if([dataInFollowList.hasFollow boolValue] != [self.data.hasFollow boolValue]){
        [self updateFollowStatus:[dataInFollowList.hasFollow boolValue]];
    }
}

// 更新运营位
- (void)updateOperationInfo:(FHUGCSocialGroupOperationModel *)model {
    
    BOOL hasOperation = model.hasOperation;
    NSString *linkUrlString = model.linkUrl;
    NSString *imageUrlString = model.imageUrl;
 
    if(linkUrlString.length > 0) {
        WeakSelf;
        self.viewController.headerView.gotoOperationBlock = ^{
            StrongSelf;
            NSURLComponents *urlComponents = [NSURLComponents new];
            urlComponents.scheme = @"fschema";
            urlComponents.host = @"webview";
            urlComponents.queryItems = @[
                                         [[NSURLQueryItem alloc] initWithName:@"url" value: linkUrlString]
                                         ];
            
            NSURL *url = urlComponents.URL;
            [[TTRoute sharedRoute] openURLByViewController:url userInfo:nil];
            
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[UT_PAGE_TYPE] = @"community_group_detail";
            param[UT_ENTER_FROM] = @"community_group_operation";
            param[@"operation_id"] = self.data.logPb[@"operation_id"];
            TRACK_EVENT(@"operation_click", param);
        };
    } else {
        self.viewController.headerView.gotoOperationBlock = nil;
    }
    NSURL *imageUrl = [NSURL URLWithString: imageUrlString];
    [self.viewController.headerView.operationBannerImageView bd_setImageWithURL:imageUrl placeholder:nil options:BDImageRequestDefaultOptions completion:nil];
    CGFloat whRatio = 335.0 / 58;
    if(model.imageHeight > 0 && model.imageWidth > 0) {
        whRatio =  model.imageWidth / model.imageHeight;
    }
    [self.viewController.headerView updateOperationInfo: hasOperation whRatio:whRatio];

    if(hasOperation) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[UT_PAGE_TYPE] = @"community_group_detail";
        param[UT_ELEMENT_TYPE] = @"community_group_operation";
        param[@"operation_id"] = self.data.logPb[@"operation_id"];
        TRACK_EVENT(@"operation_show", param);
    }

}

- (NSAttributedString *)announcementAttributeString:(NSString *) announcement {
    announcement = [announcement stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
       if(!isEmptyString(announcement)) {
           UIFont *titleFont = [UIFont themeFontSemibold:12];
           NSDictionary *announcementTitleAttributes = @{
                                                         NSFontAttributeName: titleFont,
                                                         NSForegroundColorAttributeName: [UIColor themeGray1]
                                                         };
           NSAttributedString *announcementTitle = [[NSAttributedString alloc] initWithString:@"[公告] " attributes: announcementTitleAttributes];
           
           NSAttributedString *emojiSupportAnnouncement = [[TTUGCEmojiParser parseInTextKitContext:announcement fontSize:12] mutableCopy];
           NSAttributedString *announcementContent = [[NSAttributedString alloc] initWithAttributedString:emojiSupportAnnouncement];
           
           [attributedText appendAttributedString:announcementTitle];
           [attributedText appendAttributedString:announcementContent];
           
           NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
           CGFloat lineHeight = PublicationsContentLabel_lineHeight;
           paragraphStyle.minimumLineHeight = lineHeight;
           paragraphStyle.maximumLineHeight = lineHeight;
           paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
           
           [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedText.length)];
       }
    return attributedText;
}

// 更新公告信息
- (void)updatePublicationsWith:(FHUGCScialGroupDataModel *)data {
    WeakSelf;
    BOOL isAdmin = (self.data.userAuth != UserAuthTypeNormal);
    // 是否显示公告区
    BOOL isShowPublications = !isEmptyString(data.announcement);
    self.viewController.headerView.gotoPublicationsDetailBlock = nil;
    BOOL hasDetailBtn = YES;

    // 管理员
    if(isAdmin) {
        isShowPublications = YES;
        self.viewController.headerView.publicationsDetailViewTitleLabel.text = @"编辑公告";
        NSString *defaultAnnouncement = [NSString stringWithFormat:@"与%@有关的话题都可以在这里分享讨论哦", data.socialGroupName];
        self.viewController.headerView.publicationsContentLabel.attributedText = [self announcementAttributeString:(data.announcement.length > 0)?data.announcement: defaultAnnouncement];

        self.viewController.headerView.gotoPublicationsDetailBlock = ^{
            StrongSelf;
            // 跳转公告编辑页
            NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
            urlComponents.scheme = @"sslocal";
            urlComponents.host = @"ugc_notice_edit";
            
            NSMutableDictionary *infoDict = @{}.mutableCopy;
            infoDict[@"socialGroupId"] = self.data.socialGroupId;
            infoDict[@"content"] = data.announcement;
            infoDict[@"isReadOnly"] = @(NO);
            infoDict[@"callback"] = ^(NSString *newContent){
                data.announcement = newContent;
                [self updateUIWithData:data];
            };
            
            NSMutableDictionary *tracer = self.tracerDict.mutableCopy;
            tracer[UT_ENTER_FROM] = @"community_group_detail";
            infoDict[@"tracer"] = tracer;
            
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
            [[TTRoute sharedRoute] openURLByViewController:urlComponents.URL userInfo:userInfo];
            
            // 点击编辑公告按钮埋点
            NSMutableDictionary *param = @{}.mutableCopy;
            param[UT_ELEMENT_TYPE] = @"community_group_notice";
            param[UT_PAGE_TYPE] = @"community_group_detail";
            param[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM];
            param[@"click_position"] = @"community_notice_edit";
            TRACK_EVENT(@"click_community_notice_edit", param);
        };
    }
    // 非管理员
    else {
        self.viewController.headerView.publicationsContentLabel.attributedText = [self announcementAttributeString:data.announcement];
        self.viewController.headerView.publicationsDetailViewTitleLabel.text = @"点击查看";
        self.viewController.headerView.gotoPublicationsDetailBlock = ^{
            StrongSelf;
            // 跳转只读模式的公告详情页
            NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
            urlComponents.scheme = @"sslocal";
            urlComponents.host = @"ugc_notice_edit";
            
            NSMutableDictionary *infoDict = @{}.mutableCopy;
            infoDict[@"socialGroupId"] = self.data.socialGroupId;
            infoDict[@"content"] = data.announcement;
            infoDict[@"isReadOnly"] = @(YES);
            
            NSMutableDictionary *tracer = self.tracerDict.mutableCopy;
            tracer[UT_ENTER_FROM] = @"community_group_detail";
            infoDict[@"tracer"] = tracer;
            
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
            [[TTRoute sharedRoute] openURLByViewController:urlComponents.URL userInfo:userInfo];
            
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[UT_ELEMENT_TYPE] = @"community_group_notice";
            param[UT_PAGE_TYPE] = @"community_group_detail";
            param[@"click_position"] = @"community_notice_more";
            param[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM];
            TRACK_EVENT(@"click_community_notice_more", param);
        };
        hasDetailBtn = [self.viewController.headerView isPublicationsContentLabelLargerThanTwoLineWithoutDetailButtonShow];
    }
    
    [self.viewController.headerView updatePublicationsInfo: isShowPublications
                               hasDetailBtn: hasDetailBtn];
}

- (void)updateUIWithData:(FHUGCScialGroupDataModel *)data {
    if (!data) {
        self.pagingView.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }
    self.data = data;
    // 第一次服务端返回数据
    if (data.shareInfo && self.shareInfo == nil) {
        self.shareInfo = data.shareInfo;
    }
    self.pagingView.hidden = NO;
    self.viewController.emptyView.hidden = YES;
    [self.viewController.headerView.avatar bd_setImageWithURL:[NSURL URLWithString:isEmptyString(data.avatar) ? @"" : data.avatar]];
    self.viewController.headerView.nameLabel.text = isEmptyString(data.socialGroupName) ? @"" : data.socialGroupName;
    NSString *subtitle = data.countText;
    self.viewController.headerView.subtitleLabel.text = isEmptyString(subtitle) ? @"" : subtitle;
    NSInteger followerCount = [data.followerCount integerValue];
    if (followerCount <= 0) {
       self.viewController.headerView.userCountShowen = NO;
    } else {
        self.viewController.headerView.userCountShowen = YES;
        self.viewController.headerView.userCountLabel.text = [NSString stringWithFormat:@"%ld个成员",followerCount];
    }
    
    // 配置公告
    [self updatePublicationsWith:data];
    // 配置运营位
    [self updateOperationInfo:data.operation];
    
    [self updateJoinUI:[data.hasFollow boolValue]];
    if (followerCount > 0) {
        if (subtitle.length > 0) {
            subtitle = [NSString stringWithFormat:@"%@ | %@",subtitle, [NSString stringWithFormat:@"%ld个成员",followerCount]];
        } else {
            subtitle = [NSString stringWithFormat:@"%ld个成员",followerCount];
        }
    }
    self.viewController.titleLabel.text = isEmptyString(data.socialGroupName) ? @"" : data.socialGroupName;
    self.viewController.subTitleLabel.text = isEmptyString(subtitle) ? @"" : subtitle;
    
    [self.viewController.headerView setNeedsLayout];
    [self.viewController.headerView layoutIfNeeded];
    
    //更新群聊入口
    if (self.viewController.communityId && (self.socialGroupModel.data.userAuth > UserAuthTypeNormal || [self.socialGroupModel.data.chatStatus.conversationId integerValue] > 0)) {
        [self.viewController.groupChatBtn setHidden:NO];
    } else {
        [self.viewController.groupChatBtn setHidden:YES];
    }
    NSUInteger unreadCount = [[IMManager shareInstance].chatService sdkConversationWithIdentifier:self.socialGroupModel.data.chatStatus.conversationId].unreadCount;
    if (self.socialGroupModel.data.chatStatus.conversationStatus == joinConversation) {
        if ([[IMManager shareInstance].chatService sdkConversationWithIdentifier:self.socialGroupModel.data.chatStatus.conversationId].mute && unreadCount > 0) {
            self.viewController.bageView.badgeNumber = TTBadgeNumberPoint;
            [self.viewController.bageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.viewController.groupChatBtn).offset(7);
                make.right.mas_equalTo(self.viewController.groupChatBtn).offset(-7);
                make.height.mas_equalTo(10);
                make.width.mas_equalTo(10);
            }];
        } else {
            self.viewController.bageView.badgeNumber = unreadCount;
            [self.viewController.bageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.viewController.groupChatBtn).offset(5);
                make.right.mas_equalTo(self.viewController.groupChatBtn).offset(-5);
                make.height.mas_equalTo(15);
            }];
        }
    }
    
//    CGFloat hei = self.viewController.headerView.frame.size.height;
//    self.feedListController.errorViewTopOffset = hei;

    //仅仅在未关注时显示引导页
    if (![data.hasFollow boolValue] && self.shouldShowUGcGuide) {
        [self addUgcGuide];
    }
    self.shouldShowUGcGuide = NO;
    [self.pagingView reloadHeaderViewHeight:self.viewController.headerView.height];
}

- (void)updateJoinUI:(BOOL)followed {
    self.viewController.headerView.followButton.followed = followed;
    self.viewController.rightBtn.followed = followed;
//    [self updateNavBarWithAlpha:self.viewController.customNavBarView.bgView.alpha];
}

- (void)gotoSocialFollowUserList {
    FHUGCScialGroupDataModel *item = self.data;
    if (!item && [item isKindOfClass:[FHUGCScialGroupDataModel class]]) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"element_type"] = @"community_group_join_member";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    params[@"click_position"] = @"community_group_join_member";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    [FHUserTracker writeEvent:@"click_options" params:params];
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    NSMutableDictionary *tracer = @{}.mutableCopy;
    tracer[@"enter_type"] = @"click";
    tracer[@"enter_from"] = self.tracerDict[@"page_type"] ?: @"be_null";
    //tracer[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    tracer[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    // 埋点
    [infoDict setValue:tracer forKey:@"tracer"];
    // NSString *name = [NSString stringWithFormat:@"%@圈子",item.socialGroupName];
    infoDict[@"title"] = item.socialGroupName;
    infoDict[@"social_group_id"] = item.socialGroupId;
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://ugc_follow_user_list"] userInfo:info];
}

#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self refreshContentOffset:scrollView.contentOffset];
//    [self.viewController.headerView updateWhenScrolledWithContentOffset:scrollView.contentOffset isScrollTop:NO];
//    if(scrollView.contentOffset.y < 0){
//        CGFloat alpha = self.refreshHeader.mj_h <= 0 ? 0.0f : fminf(1.0f,fabsf(scrollView.contentOffset.y / self.refreshHeader.mj_h));
//        self.refreshHeader.alpha = alpha;
//    }else{
//        self.refreshHeader.alpha = 0;
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(decelerate){
        CGFloat delta = self.pagingView.currentContentViewTopInset + scrollView.contentOffset.y;
        if(delta <= -50){
            [self.viewController.headerView.refreshHeader beginRefreshing];
        }
    }
}

- (void)addGoDetailLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    [FHUserTracker writeEvent:@"go_detail_community" params:params];
}

- (void)addStayPageLog:(NSTimeInterval)stayTime {
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_page_community" params:params];
}

- (void)addPublicationsShowLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"element_type"] = @"community_group_notice";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    [FHUserTracker writeEvent:@"element_show" params:params];
}

- (void)addPublisherPopupShowLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = @"community_publisher_popup";
    params[@"enter_from"] = @"community_group_detail";
    [FHUserTracker writeEvent:@"community_publisher_popup_show" params:params];
}

- (void)addPublisherPopupClickLog:(BOOL)positive {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = @"community_publisher_popup";
    params[@"enter_from"] = @"community_group_detail";
    params[@"click_position"] = positive ? @"confirm" : @"cancel";
    [FHUserTracker writeEvent:@"community_publisher_popup_click" params:params];
}

- (void)addClickOptionsLog:(NSString *)position {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"enter_type"] =  @"click";
    params[@"click_position"] = position;
    [FHUserTracker writeEvent:@"click_options" params:params];
}

// 帐号切换
- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName {
    if (_isLogin != TTAccountManager.isLogin) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshBasicInfo];
        });
        _isLogin = TTAccountManager.isLogin;
    }
}

- (void)onLoginIn {
    _isLoginSatusChangeFromGroupChat = YES;
}

// MARK: FHCommunityFeedListControllerDelegate
-(void)refreshBasicInfo {
    [self requestData:NO refreshFeed:NO showEmptyIfFailed:NO showToast:NO];
}

#pragma mark - lazy load

- (TTHorizontalPagingView *)pagingView {
    if(!_pagingView) {
        _pagingView = [[TTHorizontalPagingView alloc] init];
        _pagingView.delegate = self;
        _pagingView.frame = self.viewController.view.bounds;
        _pagingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _pagingView.segmentTopSpace = CGRectGetMaxY(self.viewController.customNavBarView.frame);
        _pagingView.horizontalCollectionView.scrollEnabled = NO;
        _pagingView.clipsToBounds = YES;
    }
    return _pagingView;
}

#pragma mark - pagingView 代理

- (NSInteger)numberOfSectionsInPagingView:(TTHorizontalPagingView *)pagingView {
    return self.subVCs.count;
}

- (UIScrollView *)pagingView:(TTHorizontalPagingView *)pagingView viewAtIndex:(NSInteger)index {
    index = MIN(self.subVCs.count - 1, index);
    FHCommunityFeedListController *feedVC = self.subVCs[index];
    if(!feedVC.tableView){
        [feedVC viewDidLoad];
    }
    return feedVC.tableView;
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView didSwitchIndex:(NSInteger)aIndex to:(NSInteger)toIndex {
    //前面的消失
    if(aIndex < self.subVCs.count && !self.isFirstEnter){
        FHCommunityFeedListController *feedVC = self.subVCs[aIndex];
        [feedVC viewWillDisappear];
    }
    //新的展现
    if(toIndex < self.subVCs.count){
        FHCommunityFeedListController *feedVC = self.subVCs[toIndex];
        [self.viewController addChildViewController:feedVC];
        [feedVC didMoveToParentViewController:self.viewController];
        [feedVC viewWillAppear];
    }
}

- (UIView *)viewForHeaderInPagingView {
    return self.viewController.headerView;
}

- (CGFloat)heightForHeaderInPagingView {
    return self.viewController.headerView.height;
}

- (UIView *)viewForSegmentInPagingView {
    return self.viewController.segmentView;
}

- (CGFloat)heightForSegmentInPagingView {
    NSMutableArray *tabArray = [self.socialGroupModel.data.tabInfo mutableCopy];
    if(tabArray && tabArray.count > 1) {
        return kSegmentViewHeight;
    }else{
        return 0;
    }
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView scrollTopOffset:(CGFloat)offset {
    CGFloat delta = self.pagingView.currentContentViewTopInset + offset;
    UIScrollView *scrollView = pagingView.currentContentView;
    [self refreshContentOffset:delta];
    [self.viewController.headerView updateWhenScrolledWithContentOffset:delta isScrollTop:NO scrollView:pagingView.currentContentView];
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView scrollViewDidEndDraggingOffset:(CGFloat)offset {
    CGFloat delta = self.pagingView.currentContentViewTopInset + offset;
    if(delta <= -50){
        [self.viewController.headerView.refreshHeader beginRefreshing];
    }
}

#pragma mark - segmentView 代理
- (void)segmentView:(TTHorizontalPagingSegmentView *)segmentView didSelectedItemAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex {
    
    //点击同一个不做处理
    if(index == toIndex && !self.isFirstEnter){
        return;
    }
    
    if(toIndex < self.subVCs.count){
        self.selectedIndex = toIndex;
        self.feedListController = self.subVCs[toIndex];
        self.pagingView.headerView = self.viewController.headerView;
        self.pagingView.segmentView = self.viewController.segmentView;
    }
    
    if(self.isFirstEnter) {
        [self.pagingView scrollToIndex:toIndex withAnimation:NO];
        self.isFirstEnter = NO;
    } else {
        //上报埋点
        NSString *position = @"be_null";
        if(toIndex < self.socialGroupModel.data.tabInfo.count){
            FHUGCScialGroupDataTabInfoModel *tabModel = self.socialGroupModel.data.tabInfo[toIndex];
            if(tabModel.tabName){
                position = [NSString stringWithFormat:@"%@_list",tabModel.tabName];
            }
        }
        [self addClickOptionsLog:position];
        [self.pagingView scrollToIndex:toIndex withAnimation:YES];
    }
}

@end
