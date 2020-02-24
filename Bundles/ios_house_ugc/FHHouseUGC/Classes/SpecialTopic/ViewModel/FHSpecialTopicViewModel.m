//
//  FHSpecialTopicViewModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/20.
//

#import <TTBaseLib/UIButton+TTAdditions.h>
#import "FHSpecialTopicViewModel.h"
#import "FHSpecialTopicViewController.h"
#import "FHCommunityFeedListController.h"
#import "FHSpecialTopicHeaderView.h"
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
#import "TTUGCEmojiParser.h"
#import "TTAccount.h"
#import "TTAccount+Multicast.h"
#import "TTAccountManager.h"
#import "TTHorizontalPagingView.h"
#import "IMManager.h"
#import "TTThemedAlertController.h"
#import "FHFeedUGCCellModel.h"
#import "TTUGCDefine.h"
#import <FHUGCCategoryHelper.h>
#import "UIImage+FIconFont.h"
#import "FHSpecialTopicHeaderModel.h"
#import "FHSpecialTopicContentModel.h"
#import "UIImageView+BDWebImage.h"

#define kSegmentViewHeight 52

@interface FHSpecialTopicViewModel () <FHUGCFollowObserver, TTHorizontalPagingViewDelegate,TTHorizontalPagingSegmentViewDelegate>

@property (nonatomic, weak) FHSpecialTopicViewController *viewController;
@property (nonatomic, strong) FHCommunityFeedListController *feedListController; //当前显示的feedVC
//@property (nonatomic, strong) FHUGCScialGroupDataModel *data;
@property (nonatomic, strong) FHSpecialTopicHeaderModel *specialTopicHeaderModel;
@property (nonatomic, strong) NSArray *tabContent;
@property (nonatomic, assign) BOOL isViewAppear;
@property (nonatomic, assign) BOOL isLoginSatusChangeFromPost;
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

@end

@implementation FHSpecialTopicViewModel

- (instancetype)initWithController:(FHSpecialTopicViewController *)viewController tracerDict:(NSDictionary*)tracerDict {
    self = [super init];
    if (self) {
        self.tracerDict = tracerDict;
        self.viewController = viewController;
        [self initView];
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
}

- (void)dealloc {
    
}

- (void)viewWillAppear {
    [self.feedListController viewWillAppear];
}

- (void)viewDidAppear {
    self.isViewAppear = YES;
    [self updateNavBarWithAlpha:self.viewController.customNavBarView.bgView.alpha];
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
    WeakSelf;
    [FHHouseUGCAPI requestSpecialTopicHeaderWithTabId:@"" behotTime:0 loadMore:NO listCount:0 extraDic:nil completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        [self.viewController tt_endUpdataData];
        if(userPull){
            [self endRefreshing];
        }
        
        if(error){
            [self onNetworError:showEmptyIfFailed showToast:showToast];
        }
        
        if (model) {
            FHSpecialTopicHeaderModel *responseModel = (FHSpecialTopicHeaderModel *)model;
            self.specialTopicHeaderModel = responseModel;

            [self updateUIWithData:responseModel];
            if (responseModel) {
                if(self.isFirstEnter){
                    //初始化segment
                    [self initSegment];
                    //初始化vc
                    [self initSubVC];
                    
                    [self initPagingView];
                    //放到最下面
                    [self.viewController.view insertSubview:self.pagingView atIndex:0];
                }

                if (refreshFeed) {
                    [self.feedListController startLoadData:self.isFirstEnter];
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

//- (void)gotoVotePublish {
//    if ([TTAccountManager isLogin]) {
//        [self gotoVoteVC];
//    } else {
//        [self gotoLogin:FHUGCLoginFrom_VOTE];
//    }
//}

//- (void)gotoWendaPublish {
//    if ([TTAccountManager isLogin]) {
//        [self gotoWendaVC];
//    } else {
//        [self gotoLogin:FHUGCLoginFrom_WENDA];
//    }
//}

//// 跳转到投票发布器
//- (void)gotoVoteVC {
//    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"sslocal://ugc_vote_publish"];
//    NSMutableDictionary *dict = @{}.mutableCopy;
//    NSMutableDictionary *tracerDict = @{}.mutableCopy;
//    tracerDict[UT_ENTER_FROM] = self.tracerDict[UT_PAGE_TYPE]?:UT_BE_NULL;
//    dict[TRACER_KEY] = tracerDict;
//    dict[@"select_group_id"] = self.socialGroupModel.data.socialGroupId;
//    dict[@"select_group_name"] = self.socialGroupModel.data.socialGroupName;
//    dict[@"select_group_followed"] = @(self.socialGroupModel.data.hasFollow.boolValue);
//    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
//    [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
//}

//- (void)gotoWendaVC {
//    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"sslocal://ugc_wenda_publish"];
//    NSMutableDictionary *dict = @{}.mutableCopy;
//    dict[@"select_group_id"] = self.socialGroupModel.data.socialGroupId;
//    dict[@"select_group_name"] = self.socialGroupModel.data.socialGroupName;
//    dict[@"select_group_followed"] = @(self.socialGroupModel.data.hasFollow.boolValue);
//    NSMutableDictionary *tracerDict = @{}.mutableCopy;
//    tracerDict[UT_ENTER_FROM] = self.tracerDict[UT_PAGE_TYPE]?:UT_BE_NULL;
//    dict[TRACER_KEY] = tracerDict;
//    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
//    [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
//}

- (void)initSegment {
    NSMutableArray *titles = [NSMutableArray array];
    NSInteger selectedIndex = 0;
    if(self.tabContent && self.tabContent.count > 1) {
        for(NSInteger i = 0;i < self.tabContent.count;i++) {
            FHFeedContentModel *item = self.tabContent[i];
            if(!isEmptyString(item.rawData.cardHeader.title)) {
                [titles addObject:item.rawData.cardHeader.title];
            }
        }
        self.viewController.segmentView.hidden = NO;
    }else{
        [titles addObject:@"全部"];
        self.viewController.segmentView.hidden = YES;
    }
    self.selectedIndex = selectedIndex;
    self.viewController.segmentView.selectedIndex = selectedIndex;
    self.viewController.segmentView.titles = titles;
    self.segmentTitles = titles;
}

- (void)initSubVC {
    [self.subVCs removeAllObjects];
    [self createFeedListController:nil];
}

- (void)createFeedListController:(NSString *)tabName {
    FHCommunityFeedListController *feedListController = [[FHCommunityFeedListController alloc] init];
    feedListController.tableViewNeedPullDown = NO;
    feedListController.showErrorView = NO;
    feedListController.scrollViewDelegate = self;
    feedListController.listType = FHCommunityFeedListTypeSpecialTopic;
    feedListController.forumId = self.viewController.communityId;
    feedListController.hidePublishBtn = YES;
    feedListController.tabName = tabName;
    feedListController.isResetStatusBar = NO;
    feedListController.notLoadDataWhenEmpty = YES;
    WeakSelf;
    feedListController.requestSuccess = ^(id<FHBaseModelProtocol>  _Nonnull model) {
        [wself handleFeedRequestSuccess:model];
    };
    
    self.feedListController = feedListController;
    
    [self.subVCs addObject:feedListController];
}

- (void)handleFeedRequestSuccess:(id<FHBaseModelProtocol>  _Nonnull)model {
    FHSpecialTopicContentModel *contentModel = (FHSpecialTopicContentModel *)model;
    self.tabContent = contentModel.dataContent;
    
    _pagingView.delegate = nil;
    self.viewController.segmentView.delegate = nil;
    [_pagingView removeFromSuperview];
    _pagingView = nil;
    
    self.isFirstEnter = YES;
    [self initSegment];
    self.viewController.segmentView.delegate = self;
    [self initPagingView];
    //放到最下面
    [self.viewController.view insertSubview:self.pagingView atIndex:0];
}

- (void)gotoLogin:(FHUGCLoginFrom)from {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"community_group_detail" forKey:@"enter_from"];
    [params setObject:@"feed_like" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    WeakSelf;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        StrongSelf;
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                if(from == FHUGCLoginFrom_GROUPCHAT) {
//                    [self onLoginIn];
                }
                else {
                    if(from == FHUGCLoginFrom_POST){
                        self.isLoginSatusChangeFromPost = YES;
                    }else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            switch(from) {
                                case FHUGCLoginFrom_VOTE:
                                {
//                                    [self gotoVoteVC];
                                }
                                    break;
                                case FHUGCLoginFrom_WENDA:
                                {
//                                    [self gotoWendaVC];
                                }
                                    break;
                                default:
                                    break;
                            }
                        });
                    }
                }
            }
        }
    }];
}

- (void)goPostDetail {
    [self gotoPostVC];
}

- (void)followCommunity:(NSString *)groupId {
    if (groupId) {
        WeakSelf;
        NSString *enter_from = @"community_group_detail";
        [[FHUGCConfig sharedInstance] followUGCBy:groupId isFollow:YES enterFrom:enter_from enterType:@"click" completion:^(BOOL isSuccess) {
            StrongSelf;
            if (isSuccess) {
                [self gotoPostVC];
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
//    dic[@"select_group_id"] = self.data.socialGroupId;
//    dic[@"select_group_name"] = self.data.socialGroupName;
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
        UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]);
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = YES;
        self.viewController.rightBtn.hidden = YES;
        self.shareButton.hidden = NO;
    } else if (alpha > 0.1f && alpha < 0.9f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.viewController.customNavBarView.title.textColor = [UIColor themeGray1];
        UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = YES;
        self.viewController.rightBtn.hidden = YES;
        self.shareButton.hidden = NO;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
        self.viewController.titleContainer.hidden = NO;
        self.viewController.rightBtn.hidden = NO;
        self.shareButton.hidden = YES;
    }
    [self.viewController.customNavBarView refreshAlpha:alpha];

//    NSMutableArray *tabArray = [self.socialGroupModel.data.tabInfo mutableCopy];
//    if(tabArray && tabArray.count > 1) {
//        self.viewController.customNavBarView.seperatorLine.hidden = YES;
//    }
}

- (void)updateUIWithData:(FHSpecialTopicHeaderModel *)headerModel {
    if (!headerModel) {
        self.pagingView.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }

    // 第一次服务端返回数据
    if (headerModel.shareInfo && self.shareInfo == nil) {
        FHUGCShareInfoModel *shareInfo = [[FHUGCShareInfoModel alloc] init];
        shareInfo.title = headerModel.shareInfo.shareTitle;
        shareInfo.isVideo = @"0";
        shareInfo.desc = headerModel.shareInfo.shareDesc;
        shareInfo.shareUrl = headerModel.shareInfo.shareUrl;
        shareInfo.coverImage = headerModel.shareInfo.shareCover;
        self.shareInfo = shareInfo;
    }
    self.pagingView.hidden = NO;
    self.viewController.emptyView.hidden = YES;
    
    if(headerModel.forum.bannerUrl.length > 0){
        NSURL *url = [NSURL URLWithString:headerModel.forum.bannerUrl];
        [self.viewController.headerView.topBack bd_setImageWithURL:url placeholder:nil];
    }
    
    self.viewController.headerView.nameLabel.text = isEmptyString(headerModel.forum.forumName) ? @"" : headerModel.forum.forumName;
    NSString *subtitle = headerModel.forum.desc;
    self.viewController.headerView.subtitleLabel.text = isEmptyString(subtitle) ? @"" : subtitle;
    
    self.viewController.titleLabel.text = isEmptyString(headerModel.forum.forumName) ? @"" : headerModel.forum.forumName;
    self.viewController.subTitleLabel.text = isEmptyString(subtitle) ? @"" : subtitle;
    
    [self.pagingView reloadHeaderViewHeight:self.viewController.headerView.height];
}

- (void)updateJoinUI:(BOOL)followed {
    self.viewController.rightBtn.followed = followed;
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

// MARK: FHCommunityFeedListControllerDelegate
-(void)refreshBasicInfo {
    [self requestData:NO refreshFeed:NO showEmptyIfFailed:NO showToast:NO];
}

#pragma mark - lazy load

//- (TTHorizontalPagingView *)pagingView {
//    if(!_pagingView) {
//        _pagingView = [[TTHorizontalPagingView alloc] init];
//        _pagingView.delegate = self;
//        _pagingView.frame = self.viewController.view.bounds;
//        _pagingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        _pagingView.segmentTopSpace = CGRectGetMaxY(self.viewController.customNavBarView.frame);
//        _pagingView.horizontalCollectionView.scrollEnabled = NO;
//        _pagingView.clipsToBounds = YES;
//    }
//    return _pagingView;
//}

- (void)initPagingView {
    if(!_pagingView) {
        _pagingView = [[TTHorizontalPagingView alloc] init];
        _pagingView.delegate = self;
        _pagingView.frame = self.viewController.view.bounds;
        _pagingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _pagingView.segmentTopSpace = CGRectGetMaxY(self.viewController.customNavBarView.frame);
        _pagingView.horizontalCollectionView.scrollEnabled = NO;
        _pagingView.clipsToBounds = YES;
    }
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
    if(self.tabContent && self.tabContent.count > 1) {
        return kSegmentViewHeight;
    }else{
        return 0;
    }
}

- (void)pagingView:(TTHorizontalPagingView *)pagingView scrollTopOffset:(CGFloat)offset {
    CGFloat delta = self.pagingView.currentContentViewTopInset + offset;
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
    }

    if(self.isFirstEnter) {
        [self.pagingView scrollToIndex:toIndex withAnimation:NO];
        self.isFirstEnter = NO;
    } else {
        //上报埋点
        NSString *position = @"be_null";
//        if(toIndex < self.socialGroupModel.data.tabInfo.count){
//            FHUGCScialGroupDataTabInfoModel *tabModel = self.socialGroupModel.data.tabInfo[toIndex];
//            if(tabModel.tabName){
//                position = [NSString stringWithFormat:@"%@_list",tabModel.tabName];
//            }
//        }
//        [self addClickOptionsLog:position];
//        [self.pagingView scrollToIndex:toIndex withAnimation:NO];
    }
}

@end
