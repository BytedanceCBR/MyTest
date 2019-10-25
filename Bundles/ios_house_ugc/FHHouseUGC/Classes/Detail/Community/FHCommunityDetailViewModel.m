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

@interface FHCommunityDetailViewModel () <FHUGCFollowObserver, CommunityGroupChatLoginDelegate, FHCommunityFeedListControllerDelegate>

@property(nonatomic, weak) FHCommunityDetailViewController *viewController;
@property(nonatomic, weak) FHCommunityFeedListController *feedListController;
@property(nonatomic, strong) FHUGCScialGroupDataModel *data;
@property(nonatomic, strong) FHCommunityDetailHeaderView *headerView;
@property(nonatomic, strong) FHUGCFollowButton *rightBtn;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UIView *titleContainer;
@property(nonatomic, strong) MJRefreshHeader *refreshHeader;
@property (nonatomic, assign)   BOOL       isViewAppear;
@property(nonatomic, assign) BOOL isLoginSatusChangeFromGroupChat;
@property(nonatomic, assign) BOOL isLogin;

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
        self.isViewAppear = YES;
        self.isLogin = TTAccountManager.isLogin;
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
    self.feedListController.showErrorView = YES;
    self.feedListController.scrollViewDelegate = self;
    self.feedListController.delegate = self;
    self.feedListController.listType = FHCommunityFeedListTypePostDetail;
    self.feedListController.forumId = self.viewController.communityId;
    MJWeakSelf;
    self.refreshHeader = [FHCommunityDetailMJRefreshHeader headerWithRefreshingBlock:^{
        [weakSelf requestData:YES refreshFeed:YES showEmptyIfFailed:NO showToast:YES];
        weakSelf.feedListController.view.userInteractionEnabled = NO;
    }];
    self.refreshHeader.endRefreshingCompletionBlock = ^{
        weakSelf.feedListController.view.userInteractionEnabled = YES;
    };
    self.refreshHeader.mj_h = 14;
    self.refreshHeader.alpha = 0.0f;

    self.headerView = [[FHCommunityDetailHeaderView alloc] initWithFrame:CGRectZero];
    self.headerView.followButton.groupId = self.viewController.communityId;
    self.headerView.followButton.tracerDic = [self followButtonTraceDict];
    WeakSelf;
    self.headerView.followButton.followedSuccess = ^(BOOL isSuccess, BOOL isFollow) {
        StrongSelf;
        if(isSuccess) {
            [self refreshBasicInfo];
        }
    };

    //随机一张背景图
    NSInteger randomImageIndex = [self.viewController.communityId integerValue] % 4;
    randomImageIndex = randomImageIndex < 0 ? 0 : randomImageIndex;
    NSString *imageName = [NSString stringWithFormat:@"fh_ugc_community_detail_header_back%d", randomImageIndex];
    self.headerView.topBack.image = [UIImage imageNamed:imageName];

    [self.viewController addChildViewController:self.feedListController];
    [self.feedListController didMoveToParentViewController:self.viewController];
    [self.viewController.view addSubview:self.feedListController.view];
    self.feedListController.publishBlock = ^() {
        StrongSelf;
        [self gotoPostThreadVC];
    };
    
    self.headerView.gotoSocialFollowUserListBlk = ^{
        StrongSelf;
        [self gotoSocialFollowUserList];
    };

    [TTAccount addMulticastDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGlobalFollowListLoad:) name:kFHUGCLoadFollowDataFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSuccess:) name:kFHUGCPostSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delPostThreadSuccess:) name:kFHUGCDelPostNotification object:nil];
}

// 发帖成功通知
- (void)postThreadSuccess:(NSNotification *)noti {
    if (noti) {
        NSString *groupId = noti.userInfo[@"social_group_id"];
        if (groupId.length > 0) {
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
    if (groupId.length > 0) {
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

- (void)initNavBar {
    FHNavBarView *naveBarView = self.viewController.customNavBarView;
    self.rightBtn = [[FHUGCFollowButton alloc] initWithFrame:CGRectZero];
    self.rightBtn.backgroundColor = [UIColor themeWhite];
    self.rightBtn.groupId = self.viewController.communityId;
    self.rightBtn.hidden = YES;
    self.rightBtn.tracerDic = [self followButtonTraceDict];
    WeakSelf;
    self.rightBtn.followedSuccess = ^(BOOL isSuccess, BOOL isFollow) {
        StrongSelf;
        if(isSuccess) {
            [self refreshBasicInfo];
        }
    };

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
        CGRect rect = [self.headerView.followButton convertRect:self.headerView.followButton.bounds toView:self.viewController.view];
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
    self.feedListController.tableView.mj_header = self.refreshHeader;
    self.refreshHeader.ignoredScrollViewContentInsetTop = -([TTDeviceHelper isIPhoneXSeries] ? 44 + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top : 64);
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 12.0) {
        self.feedListController.tableView.tableHeaderView = self.headerView;
    }
    [self.feedListController.tableView bringSubviewToFront:self.feedListController.tableView.mj_header];
    if (self.feedListController.tableView) {
        [self scrollViewDidScroll:self.feedListController.tableView];
    }
    // 帖子数同步逻辑
    FHUGCScialGroupDataModel *tempModel = self.data;
    if (tempModel) {
        NSString *socialGroupId = tempModel.socialGroupId;
        FHUGCScialGroupDataModel *model = [[FHUGCConfig sharedInstance] socialGroupData:socialGroupId];
        if (model && (![model.countText isEqualToString:tempModel.countText] || ![model.hasFollow isEqualToString:tempModel.hasFollow])) {
            self.data = model;
            [self updateUIWithData:model];
        }
    }
    // 修复发帖返回状态栏不对问题
    if (self.feedListController.tableView) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf scrollViewDidScroll:weakSelf.feedListController.tableView];
        });
    }
}

- (void)viewWillDisappear {
    [self.feedListController viewWillDisappear];
    self.isViewAppear = NO;
}

- (void)requestData:(BOOL) userPull refreshFeed:(BOOL) refreshFeed showEmptyIfFailed:(BOOL) showEmptyIfFailed showToast:(BOOL) showToast{
    if (![TTReachability isNetworkConnected]) {
        [self onNetworError:showEmptyIfFailed showToast:showToast];
        if(userPull){
            [self.feedListController.tableView.mj_header endRefreshing];
        }
        [_viewController tt_endUpdataData];
        return;
    }
    
    if(self.viewController.communityId.length <= 0) {
        return;
    }
    
    WeakSelf;
    [FHHouseUGCAPI requestCommunityDetail:self.viewController.communityId class:FHUGCScialGroupModel.class completion:^(id <FHBaseModelProtocol> model, NSError *error) {
        [_viewController tt_endUpdataData];
        StrongSelf;
        if(userPull){
            [wself.feedListController.tableView.mj_header endRefreshing];
        }
        if (model && (error == nil)) {
            FHUGCScialGroupModel *responseModel = (FHUGCScialGroupModel *)model;
            BOOL isFollowed = [responseModel.data.hasFollow boolValue];
            if(isFollowed == NO) {
                self.feedListController.bageView.badgeNumber = TTBadgeNumberHidden;
            }
            [wself updateUIWithData:responseModel.data];
            if (responseModel.data) {
                // 更新圈子数据
                [[FHUGCConfig sharedInstance] updateSocialGroupDataWith:responseModel.data];
                //传入选项信息
                self.feedListController.operations = responseModel.data.permission;
                self.feedListController.scialGroupData = responseModel.data;
                [self.feedListController updateViews];
                self.feedListController.loginDelegate = wself;
                if (_isLoginSatusChangeFromGroupChat) {
                    [self.feedListController gotoGroupChat];
                    _isLoginSatusChangeFromGroupChat = NO;
                }
            }
            return;
        }
        [wself onNetworError:showEmptyIfFailed showToast:showToast];
    }];
    if (refreshFeed) {
        [self.feedListController startLoadData:NO];
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

- (void)refreshContentOffset:(CGPoint)contentOffset {
    CGFloat offsetY = contentOffset.y;
    CGFloat alpha = offsetY / (80.0f);
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
        self.headerView.gotoOperationBlock = ^{
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
        self.headerView.gotoOperationBlock = nil;
    }
    NSURL *imageUrl = [NSURL URLWithString: imageUrlString];
    [self.headerView.operationBannerImageView bd_setImageWithURL:imageUrl placeholder:nil options:BDImageRequestDefaultOptions completion:nil];
    CGFloat whRatio = 335.0 / 58;
    if(model.imageHeight > 0 && model.imageWidth > 0) {
        whRatio =  model.imageWidth / model.imageHeight;
    }
    [self.headerView updateOperationInfo: hasOperation whRatio:whRatio];

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
    self.headerView.gotoPublicationsDetailBlock = nil;
    BOOL hasDetailBtn = YES;

    // 管理员
    if(isAdmin) {
        isShowPublications = YES;
        self.headerView.publicationsDetailViewTitleLabel.text = @"编辑公告";
        NSString *defaultAnnouncement = [NSString stringWithFormat:@"与%@有关的话题都可以在这里分享讨论哦", data.socialGroupName];
        self.headerView.publicationsContentLabel.attributedText = [self announcementAttributeString:(data.announcement.length > 0)?data.announcement: defaultAnnouncement];

        self.headerView.gotoPublicationsDetailBlock = ^{
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
        self.headerView.publicationsContentLabel.attributedText = [self announcementAttributeString:data.announcement];
        self.headerView.publicationsDetailViewTitleLabel.text = @"点击查看";
        self.headerView.gotoPublicationsDetailBlock = ^{
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
        hasDetailBtn = [self.headerView isPublicationsContentLabelLargerThanTwoLineWithoutDetailButtonShow];
    }
    
    [self.headerView updatePublicationsInfo: isShowPublications
                               hasDetailBtn: hasDetailBtn];
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
    [self.headerView.avatar bd_setImageWithURL:[NSURL URLWithString:isEmptyString(data.avatar) ? @"" : data.avatar]];
    self.headerView.nameLabel.text = isEmptyString(data.socialGroupName) ? @"" : data.socialGroupName;
    NSString *subtitle = data.countText;
    self.headerView.subtitleLabel.text = isEmptyString(subtitle) ? @"" : subtitle;
    NSInteger followerCount = [data.followerCount integerValue];
    if (followerCount <= 0) {
       self.headerView.userCountShowen = NO;
    } else {
        self.headerView.userCountShowen = YES;
        self.headerView.userCountLabel.text = [NSString stringWithFormat:@"%ld个成员",followerCount];
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
    self.titleLabel.text = isEmptyString(data.socialGroupName) ? @"" : data.socialGroupName;
    self.subTitleLabel.text = isEmptyString(subtitle) ? @"" : subtitle;
    
    [self.headerView setNeedsLayout];
    [self.headerView layoutIfNeeded];
    
    
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 12.0) {
        self.feedListController.tableView.tableHeaderView = self.headerView;
    } else {
        CGFloat headerHeight = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        if(self.refreshHeader.isRefreshing) {
            headerHeight -= self.refreshHeader.mj_h;
        }
        CGRect headerFrame = CGRectMake(0, 0, SCREEN_WIDTH, headerHeight);
        self.headerView.frame = headerFrame;
        
        UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
        [headerView addSubview:self.headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(headerView);
        }];
        
        self.feedListController.tableView.tableHeaderView = headerView;
        [self.feedListController.tableView bringSubviewToFront:self.feedListController.tableView.mj_header];
    }
    
    CGFloat hei = self.headerView.frame.size.height;
    self.feedListController.errorViewTopOffset = hei;

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
    params[@"page_type"] = [self pageTypeString];
    [FHUserTracker writeEvent:@"click_options" params:params];
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    NSMutableDictionary *tracer = @{}.mutableCopy;
    tracer[@"enter_type"] = @"click";
    tracer[@"enter_from"] = [self pageTypeString];
    //tracer[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    tracer[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    // 埋点
    [infoDict setValue:tracer forKey:@"tracer"];
    // NSString *name = [NSString stringWithFormat:@"%@小区圈",item.socialGroupName];
    infoDict[@"title"] = item.socialGroupName;
    infoDict[@"social_group_id"] = item.socialGroupId;
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://ugc_follow_user_list"] userInfo:info];
}

#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self refreshContentOffset:scrollView.contentOffset];
    [self.headerView updateWhenScrolledWithContentOffset:scrollView.contentOffset isScrollTop:NO];
    if(scrollView.contentOffset.y < 0){
        CGFloat alpha = self.refreshHeader.mj_h <= 0 ? 0.0f : fminf(1.0f,fabsf(scrollView.contentOffset.y / self.refreshHeader.mj_h));
        self.refreshHeader.alpha = alpha;
    }else{
        self.refreshHeader.alpha = 0;
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

// 帐号切换
- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    if (_isLogin != TTAccountManager.isLogin) {
        [_viewController tt_startUpdate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self requestData:YES refreshFeed:YES showEmptyIfFailed:NO showToast:YES];
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
@end
