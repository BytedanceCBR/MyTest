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


@interface FHCommunityDetailViewModel () <FHUGCFollowObserver>

@property(nonatomic, weak) FHCommunityDetailViewController *viewController;
@property(nonatomic, strong) FHCommunityFeedListController *feedListController;
@property(nonatomic, strong) FHUGCScialGroupDataModel *data;
@property(nonatomic, strong) FHCommunityDetailHeaderView *headerView;
@property(nonatomic, strong) FHUGCFollowButton *rightBtn;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UIView *titleContainer;

@property(nonatomic, strong) FHUGCGuideView *guideView;
@property(nonatomic) BOOL shouldShowUGcGuide;
@end

@implementation FHCommunityDetailViewModel

- (instancetype)initWithController:(FHCommunityDetailViewController *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        [self initView];
        self.shouldShowUGcGuide = YES;
        [self addGoDetailLog];
        [self addPublicationsShowLog];
    }
    return self;
}

- (void)initView {
    [self initNavBar];
    [self.rightBtn addTarget:self action:@selector(followClicked) forControlEvents:UIControlEventTouchUpInside];

    self.feedListController = [[FHCommunityFeedListController alloc] init];
    self.feedListController.publishBtnBottomHeight = 10;
    self.feedListController.tableViewNeedPullDown = NO;
    self.feedListController.showErrorView = NO;
    self.feedListController.scrollViewDelegate = self;
    self.feedListController.listType = FHCommunityFeedListTypePostDetail;
    self.feedListController.forumId = self.viewController.communityId;

    self.headerView = [[FHCommunityDetailHeaderView alloc] initWithFrame:CGRectZero];
    self.headerView.followButton.groupId = self.viewController.communityId;
    //随机一张背景图
    NSUInteger randomImageIndex = [self.viewController.communityId integerValue] % 4;
    NSString *imageNmae = [NSString stringWithFormat:@"fh_ugc_community_detail_header_back%d",randomImageIndex];
    self.headerView.topBack.image = [UIImage imageNamed:imageNmae];
    
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initNavBar {
    FHNavBarView *naveBarView = self.viewController.customNavBarView;
    self.rightBtn = [[FHUGCFollowButton alloc] initWithFrame:CGRectZero];
    self.rightBtn.backgroundColor = [UIColor themeWhite];
    self.rightBtn.groupId = self.viewController.communityId;
    self.rightBtn.hidden = YES;

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
        [self.guideView show:self.viewController.view dismissDelayTime:0.0f];
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
    [FHUGCGuideHelper hideUgcDetailGuide];
}

- (void)viewWillAppear {
    [self.feedListController viewWillAppear];
}

- (void)requestData:(BOOL)refreshFeed {
    if (![TTReachability isNetworkConnected]) {
        self.feedListController.view.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        return;
    }

    WeakSelf;
    [FHHouseUGCAPI requestCommunityDetail:self.viewController.communityId class:FHUGCScialGroupModel.class completion:^(id <FHBaseModelProtocol> model, NSError *error) {
        StrongSelf;
        if (model && (error == nil)) {
            FHUGCScialGroupModel *responseModel = (FHUGCScialGroupModel *)model;
            [wself updateUIWithData:responseModel.data];
        } else {
            wself.feedListController.view.hidden = YES;
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
            return;
        }
    }];
    if (refreshFeed) {
        [self.feedListController startLoadData];
    }
}

- (void)followClicked {
    if ([self.data.hasFollow boolValue]) {
        WeakSelf;
        TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"确定退出？" message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alertController addActionWithTitle:NSLocalizedString(@"取消", comment:
            nil)                 actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alertController addActionWithTitle:NSLocalizedString(@"退出", comment:
            nil)                 actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
            StrongSelf;
            [FHUGCFollowHelper followCommunity:wself.data.socialGroupId userInfo:nil followBlock:nil];
        }];
        [alertController showFrom:self.viewController animated:YES];
    }
}

// 发布按钮点击
- (void)gotoPostThreadVC {
    if ([TTAccountManager isLogin]) {
        [self goPosDetail];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // add by zyk 记得修改埋点
    [params setObject:@"communitydetail" forKey:@"enter_from"];
    [params setObject:@"communitydetail" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wSelf goPosDetail];
                });
            }
        }
    }];
}

- (void)goPosDetail {
    if (!self.headerView.followButton.followed) {
        WeakSelf;
        TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"先关注该小区才能发布哦" message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alertController addActionWithTitle:NSLocalizedString(@"取消", comment:
            nil)                 actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alertController addActionWithTitle:NSLocalizedString(@"关注", comment:
            nil)                 actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
            StrongSelf;
            [wself followCommunity:wself.data.socialGroupId];
        }];
        [alertController showFrom:self.viewController animated:YES];
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
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"select_group_id"] = self.data.socialGroupId;
    dic[@"select_group_name"] = self.data.socialGroupName;
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
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        self.titleContainer.hidden = YES;
        self.rightBtn.hidden = YES;
    } else if (alpha > 0.1f && alpha < 0.9f) {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        self.viewController.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        self.titleContainer.hidden = YES;
        self.rightBtn.hidden = YES;
    } else {
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
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
    CGRect rect = self.headerView.topBack.frame;
    self.headerView.topBack.frame = CGRectMake(0, offsetY, rect.size.width, self.headerView.headerBackHeight - offsetY);
}

// 关注状态改变
- (void)followStateChanged:(NSNotification *)notification {
    if (notification) {
        NSDictionary *userInfo = notification.userInfo;
        BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
        NSString *groupId = notification.userInfo[@"social_group_id"];
        NSString *currentGroupId = self.viewController.communityId;
        if(groupId.length > 0 && currentGroupId.length > 0) {
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

- (NSString *)generateSubTitle:(FHUGCScialGroupDataModel *)data {
    if (data) {
        return [NSString stringWithFormat:@"%@个成员·%@帖子", data.followerCount, data.contentCount];
    }
    return nil;
}

- (void)updateJoinUI:(BOOL)followed {
    self.headerView.followButton.followed = followed;
    self.rightBtn.followed = followed;
    [self updateNavBarWithAlpha:self.viewController.customNavBarView.bgView.alpha];
}

#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resizeHeader:scrollView.contentOffset];
    [self refreshContentOffset:scrollView.contentOffset];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY >= 0.0f) {
        return;
    }
    if (offsetY > -80.0f) {
        return;
    }
    [self requestData:YES];
}

-(void)addGoDetailLog{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ? : @"be_null";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ? : @"be_null";
    params[@"page_type"] = [self pageTypeString];
    [FHUserTracker writeEvent:@"go_detail_community" params:params];
}

-(void)addPublicationsShowLog{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"element_type"] = @"community_group_notice";
    params[@"page_type"] = [self pageTypeString];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    [FHUserTracker writeEvent:@"element_show" params:params];
}

-(void)addPublisherPopupShowLog{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = [self pageTypeString];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    [FHUserTracker writeEvent:@"community_publisher_popup_show" params:params];
}

-(void)addPublisherPopupClickLog:(BOOL) positive{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"] = [self pageTypeString];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    params[@"click_position"] = positive ? @"confirm" : @"cancel";
    [FHUserTracker writeEvent:@"community_publisher_popup_click" params:params];
}

- (NSString *)pageTypeString
{
    return @"community_group_detail";
}

@end
