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
#import "FHCommunityDetailModel.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "UIImageView+BDWebImage.h"
#import "UILabel+House.h"
#import "FHUGCFollowButton.h"
#import "FHUGCFollowHelper.h"
#import "TTThemedAlertController.h"


@interface FHCommunityDetailViewModel () <FHUGCFollowObserver>

@property(nonatomic, weak) FHCommunityDetailViewController *viewController;
@property(nonatomic, strong) FHCommunityFeedListController *feedListController;
@property(nonatomic, strong) FHCommunityDetailDataModel *data;
@property(nonatomic, strong) FHCommunityDetailHeaderView *headerView;
@property(nonatomic, strong) FHUGCFollowButton *rightBtn;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UIView *titleContainer;

@end

@implementation FHCommunityDetailViewModel

- (instancetype)initWithController:(FHCommunityDetailViewController *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
        [self initView];
    }
    return self;
}

- (void)initView {
    [self initNavBar];
    [self.rightBtn addTarget:self action:@selector(followClicked) forControlEvents:UIControlEventTouchUpInside];

    self.feedListController = [[FHCommunityFeedListController alloc] init];
    self.feedListController.publishBtnBottomHeight = 10;
    self.feedListController.tableViewNeedPullDown = NO;
    self.feedListController.scrollViewDelegate = self;
    self.feedListController.listType = FHCommunityFeedListTypeMyJoin;
    self.headerView = [[FHCommunityDetailHeaderView alloc] initWithFrame:CGRectZero];
    self.feedListController.tableHeaderView = self.headerView;

    [self.viewController addChildViewController:self.feedListController];
    [self.feedListController didMoveToParentViewController:self.viewController];
    [self.viewController.view addSubview:self.feedListController.view];
    WeakSelf;
    self.feedListController.publishBlock = ^() {
        StrongSelf;
        [self goPosDetail];
    };
}

- (void)initNavBar {
    FHNavBarView *naveBarView = self.viewController.customNavBarView;
    self.rightBtn = [[FHUGCFollowButton alloc] initWithFrame:CGRectZero];
    self.rightBtn.backgroundColor = [UIColor themeWhite];
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

- (void)requestData:(BOOL)refreshFeed {
    if (![TTReachability isNetworkConnected]) {
        self.feedListController.view.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        return;
    }

    WeakSelf;
    [FHHouseUGCAPI requestCommunityDetail:@"1234" class:FHCommunityDetailModel.class completion:^(id <FHBaseModelProtocol> model, NSError *error) {
        StrongSelf;
        if (model && (error == nil)) {
            FHCommunityDetailModel *responseModel = model;
            [wself updateUIWithData:responseModel.data];
        } else {
            wself.feedListController.view.hidden = YES;
            [wself.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
            [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
            return;
        }
    }];
    if(refreshFeed){
        [self.feedListController startLoadData];
    }
}

- (void)followClicked {
    if (self.data.followed) {
        WeakSelf;
        TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"确定退出？" message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alertController addActionWithTitle:NSLocalizedString(@"取消", comment:nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alertController addActionWithTitle:NSLocalizedString(@"退出", comment:nil) actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
            StrongSelf;
            [FHUGCFollowHelper followCommunity:wself.data.id userInfo:nil followBlock:nil];
        }];
        [alertController showFrom:self.viewController animated:YES];
    }
}

- (void)goPosDetail {
    if (!self.data.followed) {
        WeakSelf;
        TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"先关注该小区才能发布哦" message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alertController addActionWithTitle:NSLocalizedString(@"取消", comment:nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alertController addActionWithTitle:NSLocalizedString(@"关注", comment:nil) actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
            StrongSelf;
            [FHUGCFollowHelper followCommunity:wself.data.id userInfo:nil followBlock:^(){
                //跳转发布器
                NSURL *url = [NSURL URLWithString:@"sslocal://ugc_post"];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
            }];
        }];
        [alertController showFrom:self.viewController animated:YES];
        return;
    }
    //跳转发布器
    NSURL *url = [NSURL URLWithString:@"sslocal://ugc_post"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
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
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        self.titleContainer.hidden = YES;
        self.rightBtn.hidden = YES;
    } else if (alpha > 0.1f && alpha < 0.9f) {
        self.viewController.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        self.titleContainer.hidden = YES;
        self.rightBtn.hidden = YES;
    } else {
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

- (void)updateUIWithData:(FHCommunityDetailDataModel *)data {
    if (!data) {
        self.feedListController.view.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }
    self.data = data;
    self.feedListController.view.hidden = NO;
    self.viewController.emptyView.hidden = YES;
    [self.headerView.avatar bd_setImageWithURL:[NSURL URLWithString:isEmptyString(data.avatar) ? @"" : data.avatar]];
    self.headerView.nameLabel.text = isEmptyString(data.name) ? @"" : data.name;
    self.headerView.subtitleLabel.text = isEmptyString(data.subtitle) ? @"" : data.subtitle;
    if (isEmptyString(data.publications)) {
        self.headerView.publicationsContainer.hidden = YES;
    } else {
        self.headerView.publicationsContentLabel.text = data.publications;
    }
    [self updateJoinUI:data.followed];
    self.titleLabel.text = isEmptyString(data.name) ? @"" : data.name;
    self.subTitleLabel.text = isEmptyString(data.subtitle) ? @"" : data.subtitle;

    [self.headerView resize];
    self.feedListController.tableHeaderView = self.headerView;
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
    if (offsetY > -60.0f) {
        return;
    }
    [self requestData:YES];
}

@end
