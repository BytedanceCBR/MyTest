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
#import "TTThemedAlertController.h"
#import "FHUGCGuideView.h"
#import "FHUGCGuideHelper.h"
#import "FHUGCScialGroupModel.h"
#import "FHUGCConfig.h"
#import "TTAccountManager.h"
#import "FHUserTracker.h"
#import "FHCommunityDetailRefreshView.h"
#import "NSTimer+NoRetain.h"


@interface FHCommunityDetailViewModel () <FHUGCFollowObserver>

@property(nonatomic, weak) FHCommunityDetailViewController *viewController;
@property(nonatomic, strong) FHCommunityFeedListController *feedListController;
@property(nonatomic, strong) FHUGCScialGroupDataModel *data;
@property(nonatomic, strong) FHCommunityDetailHeaderView *headerView;
@property(nonatomic, strong) FHUGCFollowButton *rightBtn;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UIView *titleContainer;
@property(nonatomic) BOOL scrollToTop;
@property(nonatomic, strong) NSTimer *requestDataTimer;

@property(nonatomic, strong) FHUGCGuideView *guideView;
@property(nonatomic) BOOL shouldShowUGcGuide;
@end

@implementation FHCommunityDetailViewModel

- (instancetype)initWithController:(FHCommunityDetailViewController *)viewController tracerDict:(NSDictionary*)tracerDict{
    self = [super init];
    if (self) {
        self.tracerDict = tracerDict;
        self.viewController = viewController;
        [self initView];
        self.shouldShowUGcGuide = YES;
    }
    return self;
}

- (void)initView {
    [self initNavBar];

    self.feedListController = [[FHCommunityFeedListController alloc] init];
    CGFloat publishBtnBottomHeight;
    if ([TTDeviceHelper isIPhoneXSeries]) {
        publishBtnBottomHeight = 44;
    }else{
        publishBtnBottomHeight = 10;
    }
    self.feedListController.publishBtnBottomHeight = publishBtnBottomHeight;
    self.feedListController.tableViewNeedPullDown = NO;
    self.feedListController.showErrorView = NO;
    self.feedListController.scrollViewDelegate = self;
    self.feedListController.listType = FHCommunityFeedListTypePostDetail;
    self.feedListController.forumId = self.viewController.communityId;

    self.headerView = [[FHCommunityDetailHeaderView alloc] initWithFrame:CGRectZero];
    self.headerView.followButton.groupId = self.viewController.communityId;
    self.headerView.followButton.tracerDic = [self followButtonTraceDict];

    //随机一张背景图
    NSInteger randomImageIndex = [self.viewController.communityId integerValue] % 4;
    randomImageIndex = randomImageIndex < 0 ? 0 : randomImageIndex;
    NSString *imageName = [NSString stringWithFormat:@"fh_ugc_community_detail_header_back%d", randomImageIndex];
    self.headerView.topBack.image = [UIImage imageNamed:imageName];

    self.feedListController.tableHeaderView = self.headerView;

    [self.viewController addChildViewController:self.feedListController];
    [self.feedListController didMoveToParentViewController:self.viewController];
    [self.viewController.view addSubview:self.feedListController.view];
    WeakSelf;
    self.feedListController.publishBlock = ^() {
        StrongSelf;
        [self gotoPostThreadVC];
    };

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initNavBar {
    FHNavBarView *naveBarView = self.viewController.customNavBarView;
    self.rightBtn = [[FHUGCFollowButton alloc] initWithFrame:CGRectZero];
    self.rightBtn.backgroundColor = [UIColor themeWhite];
    self.rightBtn.groupId = self.viewController.communityId;
    self.rightBtn.hidden = YES;
    self.rightBtn.tracerDic = [self followButtonTraceDict];

    self.titleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor themeGray1];

    self.subTitleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:10];
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.textColor = [UIColor themeGray3];

    self.titleContainer = [[UIView alloc] init];
    [self.titleContainer addSubview:self.titleLabel];
    [self.titleContainer addSubview:self.subTitleLabel];
    [naveBarView addSubview:self.titleContainer];
    [naveBarView addSubview:self.rightBtn];

    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(naveBarView.leftBtn.mas_centerY);
        make.right.mas_equalTo(naveBarView).offset(-18.0f);
        make.width.mas_equalTo(58);
        make.height.mas_equalTo(24);
    }];

    [self.titleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(naveBarView.leftBtn.mas_centerY);
        make.left.mas_equalTo(naveBarView.leftBtn.mas_right).offset(10.0f);
        make.right.mas_equalTo(self.rightBtn.mas_left).offset(-10);
        make.height.mas_equalTo(34);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.titleContainer);
        make.height.mas_equalTo(20);
    }];

    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.titleContainer);
        make.height.mas_equalTo(14);
    }];
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
        CGRect rect = [self.headerView convertRect:self.headerView.followButton.frame toView:self.viewController.view];
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

- (void)viewWillDisappear {
    [self.feedListController viewWillDisappear];
}

- (void)requestData:(BOOL) userPull refreshFeed:(BOOL) refreshFeed showEmptyIfFailed:(BOOL) showEmptyIfFailed showToast:(BOOL) showToast{
    if (![TTReachability isNetworkConnected]) {
        [self onNetworError:showEmptyIfFailed showToast:showToast];
        if(userPull){
            [self endRefresh];
        }
        return;
    }

    WeakSelf;
    [FHHouseUGCAPI requestCommunityDetail:self.viewController.communityId class:FHUGCScialGroupModel.class completion:^(id <FHBaseModelProtocol> model, NSError *error) {
        StrongSelf;
        if(userPull){
            [self endRefresh];
        }
        if (model && (error == nil)) {
            FHUGCScialGroupModel *responseModel = (FHUGCScialGroupModel *)model;
            [wself updateUIWithData:responseModel.data];
            return;
        }
        [self onNetworError:showEmptyIfFailed showToast:showToast];
    }];
    if (refreshFeed) {
        [self.feedListController startLoadData];
    }
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
        [self gotoLogin];
    }
}

- (void)gotoLogin {
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
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wSelf goPostDetail];
                });
            }
        }
    }];
}

- (void)goPostDetail {
    if (!self.headerView.followButton.followed) {
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
        [[FHUGCConfig sharedInstance] followUGCBy:groupId isFollow:YES completion:^(BOOL isSuccess) {
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

- (void)refreshContentOffset:(CGPoint)contentOffset {
    CGFloat offsetY = contentOffset.y;
    CGFloat alpha = offsetY / (80.0f);
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    [self updateNavBarWithAlpha:alpha];
}

- (void)updateNavBarWithAlpha:(CGFloat)alpha {
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    if (alpha <= 0.1f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        self.titleContainer.hidden = YES;
        self.rightBtn.hidden = YES;
    } else if (alpha > 0.1f && alpha < 0.9f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.viewController.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        self.titleContainer.hidden = YES;
        self.rightBtn.hidden = YES;
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        self.titleContainer.hidden = NO;
        self.rightBtn.hidden = NO;
    }
    [self.viewController.customNavBarView refreshAlpha:alpha];
}

- (void)resizeHeader:(CGPoint)contentOffset {
    CGFloat offsetY = contentOffset.y;
    if (offsetY >= 0.0f) {
        return;
    }
    [self.headerView.topBack mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(offsetY);
        make.height.mas_greaterThanOrEqualTo(self.headerView.headerBackHeight - offsetY);
    }];
    self.feedListController.tableView.tableHeaderView = self.headerView;
}

// 关注状态改变
- (void)followStateChanged:(NSNotification *)notification {
    if (notification) {
        BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
        NSString *groupId = notification.userInfo[@"social_group_id"];
        NSString *currentGroupId = self.viewController.communityId;
        if (groupId.length > 0 && currentGroupId.length > 0) {
            if ([groupId isEqualToString:currentGroupId]) {
                if (self.data) {
                    // 替换关注人数 AA关注BB热帖 替换：AA
                    [[FHUGCConfig sharedInstance] updateScialGroupDataModel:self.data byFollowed:followed];
                    [self updateUIWithData:self.data];
                }
            }
        }
    }
}

- (void)updateUIWithData:(FHUGCScialGroupDataModel *)data {
    if (!data) {
        self.feedListController.view.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }
    self.data = data;
    self.feedListController.view.hidden = NO;
    self.viewController.emptyView.hidden = YES;
    [self.headerView.avatar bd_setImageWithURL:[NSURL URLWithString:isEmptyString(data.avatar) ? @"" : data.avatar] placeholder:[UIImage imageNamed:@"default_avatar"]];
    self.headerView.nameLabel.text = isEmptyString(data.socialGroupName) ? @"" : data.socialGroupName;
    NSString *subtitle = data.countText;// [self generateSubTitle:data];
    self.headerView.subtitleLabel.text = isEmptyString(subtitle) ? @"" : subtitle;
    if (isEmptyString(data.announcement)) {
        self.headerView.publicationsContainer.hidden = YES;
    } else {
        self.headerView.publicationsContentLabel.text = data.announcement;
    }
    [self updateJoinUI:[data.hasFollow boolValue]];
    self.titleLabel.text = isEmptyString(data.socialGroupName) ? @"" : data.socialGroupName;
    self.subTitleLabel.text = isEmptyString(subtitle) ? @"" : subtitle;

    self.feedListController.tableView.tableHeaderView = self.headerView;

    //仅仅在未关注时显示引导页
    if (![data.hasFollow boolValue] && self.shouldShowUGcGuide) {
        [self addUgcGuide];
    }
    self.shouldShowUGcGuide = NO;
}

- (void)updateJoinUI:(BOOL)followed {
    self.headerView.followButton.followed = followed;
    self.rightBtn.followed = followed;
    [self updateNavBarWithAlpha:self.viewController.customNavBarView.bgView.alpha];
}

#pragma UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView; {
    self.scrollToTop = NO;
    if (scrollView.contentOffset.y < 0 && -scrollView.contentOffset.y > self.headerView.refreshView.toRefreshMinDistance) {
        [self cancelRequestAfter];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0); {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resizeHeader:scrollView.contentOffset];
    [self refreshContentOffset:scrollView.contentOffset];
    [self.headerView updateWhenScrolledWithContentOffset:scrollView.contentOffset isScrollTop:self.scrollToTop];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < 0 && -scrollView.contentOffset.y > self.headerView.refreshView.toRefreshMinDistance) {
        self.scrollToTop = YES;
        scrollView.contentInset = UIEdgeInsetsMake(self.headerView.refreshView.toRefreshMinDistance, 0, 0, 0);
        [self requestDataAfter];
        [self.headerView startRefresh];
    }
}

- (void)endRefresh {
    WeakSelf;
    [UIView animateWithDuration:0.5 animations:^{
        StrongSelf;
        wself.feedListController.tableView.contentOffset = CGPointMake(0, 0);
        wself.feedListController.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }completion:^(BOOL finished) {
        [wself.headerView stopRefresh];
    }];
}

- (void)requestDataAfter {
    WeakSelf;
    [self cancelRequestAfter];
    self.requestDataTimer = [NSTimer scheduledNoRetainTimerWithTimeInterval:1.0f target:self selector:@selector(requestDataWithRefresh) userInfo:nil repeats:NO];
}

-(void)requestDataWithRefresh{
    [self requestData:YES refreshFeed:YES showEmptyIfFailed:NO showToast:YES];
}

- (void)cancelRequestAfter {
    if (self.requestDataTimer) {
        [self.requestDataTimer invalidate];
        self.requestDataTimer = nil;
    }
}

- (void)addGoDetailLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
    params[@"page_type"] = [self pageTypeString];
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
    params[@"page_type"] = [self pageTypeString];
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_page_community" params:params];
}

- (void)addPublicationsShowLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"element_type"] = @"community_group_notice";
    params[@"page_type"] = [self pageTypeString];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
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

- (NSString *)pageTypeString {
    return @"community_group_detail";
}

- (NSDictionary *)followButtonTraceDict {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"community_id"] = self.viewController.communityId;
    params[@"page_type"] = [self pageTypeString];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"click_position"] = @"join_like";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    return [params copy];
}

@end
