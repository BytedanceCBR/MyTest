//
// Created by zhulijun on 2019-06-12.
//

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
#import "UIViewAdditions.h"


@interface FHCommunityDetailViewModel ()

@property(nonatomic, weak) FHCommunityDetailViewController *viewController;
@property(nonatomic, strong) FHCommunityFeedListController *feedListController;
@property(nonatomic, strong) FHCommunityDetailDataModel *data;
@property(nonatomic, strong) FHCommunityDetailHeaderView *headerView;
@property(nonatomic, strong) UIButton *rightBtn;

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

    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBtn.backgroundColor = [UIColor themeWhite];
    [self.rightBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.rightBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [self.rightBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateHighlighted];
    [self.rightBtn setTitle:@"加入" forState:UIControlStateNormal];
    [self.rightBtn setTitle:@"加入" forState:UIControlStateHighlighted];
    self.rightBtn.layer.borderColor = [UIColor themeRed1].CGColor;
    self.rightBtn.layer.borderWidth = 0.5f;
    self.rightBtn.layer.cornerRadius = 4.0f;
    self.rightBtn.hidden = YES;

    [self.rightBtn addTarget:self action:@selector(joinBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewController.customNavBarView addRightViews:@[self.rightBtn] viewsWidth:@[@58] viewsHeight:@[@24] viewsRightOffset:@[@20]];

    self.feedListController = [[FHCommunityFeedListController alloc] init];
    self.feedListController.customPullRefresh = YES;
    self.feedListController.scrollViewDelegate = self;
    self.feedListController.listType = FHCommunityFeedListTypeMyJoin;
    self.headerView = [[FHCommunityDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.viewController.view.bounds.size.width, 240)];
    self.feedListController.tableHeaderView = self.headerView;

    [self.viewController addChildViewController:self.feedListController];
    [self.feedListController didMoveToParentViewController:self];
    CGFloat topOffset = (@available(iOS 11.0, *)) ? self.viewController.view.tt_safeAreaInsets.top : 0;
    self.feedListController.view.frame = CGRectMake(self.viewController.view.bounds.origin.x, self.viewController.view.bounds.origin.y + topOffset, self.viewController.view.bounds.size.width, self.viewController.view.bounds.size.height - topOffset);
    [self.viewController.view addSubview:self.feedListController.view];
}

- (void)requestData {
    if (![TTReachability isNetworkConnected]) {
        self.feedListController.view.hidden = YES;
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        [[ToastManager manager] showToast:@"网络不给力,请稍后重试"];
        return;
    }

    WeakSelf;
    [self.viewController startLoading];
    [FHHouseUGCAPI requestCommunityDetail:@"1234" class:FHCommunityDetailModel.class completion:^(id <FHBaseModelProtocol> model, NSError *error) {
        [wself.viewController endLoading];
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
}

- (void)refreshContentOffset:(CGPoint)contentOffset hasJoin:(BOOL)hasJoin {
    CGFloat offsetY = contentOffset.y;
    if (offsetY < 0) {
        return;
    }
    CGFloat alpha = offsetY / 88;
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    [self updateNavBarWithAlpha:alpha showJoin:!hasJoin];
}

- (void)updateNavBarWithAlpha:(CGFloat)alpha showJoin:(BOOL)showJoin {
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    if (alpha <= 0.1f) {
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        self.viewController.customNavBarView.title.hidden = YES;
        self.rightBtn.hidden = YES;
    } else if (alpha > 0.1f && alpha < 1.0f) {
        self.viewController.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        self.viewController.customNavBarView.title.hidden = YES;
        self.rightBtn.hidden = YES;
    } else {
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.viewController.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        if (showJoin) {
            self.viewController.customNavBarView.title.hidden = NO;
            self.rightBtn.hidden = NO;
        }
    }
    [self.viewController.customNavBarView refreshAlpha:alpha];
}

- (void)resizeHeader:(CGPoint)contentOffset {
    CGFloat offsetY = contentOffset.y;
    if (offsetY >= 0.0f) {
        return;
    }
    CGRect rect = self.headerView.topBack.frame;
    rect.origin.y = contentOffset.y;
    rect.size.height = 190 - offsetY;
    self.self.headerView.topBack.frame = rect;
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
    [self updateJoinUI:data.hasJoin];
    [self.viewController setTitle:isEmptyString(data.name) ? @"" : data.name];

    [self.headerView resize];
    self.feedListController.tableHeaderView = self.headerView;
}

- (void)updateJoinUI:(BOOL)hasJoin {
    [self.headerView updateWithJoinStatus:hasJoin];
    [self updateNavBarWithAlpha:self.viewController.customNavBarView.alpha showJoin:!hasJoin];
}

#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resizeHeader:scrollView.contentOffset];
    [self refreshContentOffset:scrollView.contentOffset hasJoin:self.data.hasJoin];
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
    [self requestData];
}

@end
