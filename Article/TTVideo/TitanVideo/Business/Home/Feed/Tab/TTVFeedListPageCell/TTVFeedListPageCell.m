//
//  TTVFeedListPageCell.m
//  Article
//
//  Created by 刘廷勇 on 16/1/15.
//
//

#import "TTVFeedListPageCell.h"
#import "NewsListLogicManager.h"
#import "UIScrollView+Refresh.h"
#import "TTDeviceHelper.h"
#import "TTCategoryStayTrackManager.h"
#import "TTVFeedListViewController.h"
#import "TTCategory.h"
#import "ExploreCellHelper.h"
#import "TTTopBar.h"

extern BOOL ttvs_threeTopBarEnable(void);

@interface TTVFeedListPageCell() <TTVFeedListViewControllerDelegate>

@property (nonatomic, weak) TTCollectionPageViewController *pageVC;

@end

@implementation TTVFeedListPageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setHeaderView:(UIView *)headerView
{
    self.feedListViewController.tableView.customTopOffset = headerView.frame.size.height;
    self.feedListViewController.tableView.tableHeaderView = headerView;
}

- (void)configFeedListVC
{
    if (self.feedListViewController) {
        [self.feedListViewController prepareForReuse];
        return;
    }
    CGFloat topPadding = 0;
    CGFloat bottomPadding = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom + 44;
    
    if ([TTDeviceHelper isPadDevice]) {
        topPadding = 64 + 44;
    }
    self.feedListViewController = [[TTVFeedListViewController alloc] init];
    self.feedListViewController.delegate = self;
    UIViewController *viewController = self.sourceViewController;
    [viewController addChildViewController:self.feedListViewController];
    [self.contentView addSubview:self.feedListViewController.view];
    [self.feedListViewController didMoveToParentViewController:viewController];
    [self.feedListViewController setListTopInset:topPadding BottomInset:bottomPadding];
    if (![TTDeviceHelper isPadDevice]) {
        CGFloat statusBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
        CGFloat topOffset = statusBarHeight + kTopSearchButtonHeight;
        if (ttvs_threeTopBarEnable()){
            topOffset = statusBarHeight + kTopSearchButtonHeight + kSelectorViewHeight;
        }
        [self.feedListViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(topOffset);
            make.left.right.bottom.equalTo(@0);
        }];
    }
    else {
        [self.feedListViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(@0);
        }];
    }
}

- (void)refreshIfNeeded
{
    if (self.category) {
        BOOL shouldAutoReload = [[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:self.feedListViewController.localCacheKey];
        TTReloadType type = shouldAutoReload ? TTReloadTypeAuto : TTReloadTypeNone;
        BOOL hasSetCategory = NO;
        if (self.feedListViewController.categoryID != nil) {
            hasSetCategory = YES;
        }
        [self.feedListViewController refreshFeedListForCategory:self.category isDisplayView:YES fromLocal:YES fromRemote:shouldAutoReload reloadFromType:type getRemoteWhenLocalEmpty:YES];
        if (!hasSetCategory) {
            [self.feedListViewController willAppear];
        }
    }
}

- (void)triggerPullRefresh
{
    [self.feedListViewController pullAndRefresh];
}

#pragma mark ExploreMixedListBaseViewDelegate Methods

- (void)feedDidStartLoad
{
    if ([self.delegate respondsToSelector:@selector(listViewOfTTCollectionPageCellStartLoading:)]) {
        [self.delegate listViewOfTTCollectionPageCellStartLoading:self];
    }
}

- (void)feedDidFinishLoadIsFinish:(BOOL)finish isUserPull:(BOOL)userPull
{
    if ([self.delegate respondsToSelector:@selector(listViewOfTTCollectionPageCellEndLoading:)]) {
        [self.delegate listViewOfTTCollectionPageCellEndLoading:self];
    }
}

- (void)feedRequestDidCancelRequest
{
    if ([self.delegate respondsToSelector:@selector(listViewOfTTCollectionPageCellEndLoading:)]) {
        [self.delegate listViewOfTTCollectionPageCellEndLoading:self];
    }
}

#pragma mark -
#pragma mark TTCollectionCell protocal

// 频道驻留统计
- (void)enterCategory {
    /**
     *  视频tab中推荐频道的驻留时长埋点，由 tag:stay_category label:video 改为 tag:stay_category label:subv_recommend
     */
    NSString *categoryID = self.category.categoryID;
    if ([categoryID isEqualToString:kTTVideoCategoryID]) {
        categoryID = @"subv_recommend";
    }
    
    [[TTCategoryStayTrackManager shareManager] startTrackForCategoryID:categoryID concernID:self.category.concernID enterType:self.feedListViewController.enterType];
}

- (void)leaveCategory {
    NSString *categoryID = self.category.categoryID;
    if ([categoryID isEqualToString:kTTVideoCategoryID]) {
        categoryID = @"subv_recommend";
    }
    [[TTCategoryStayTrackManager shareManager] endTrackCategory:categoryID];
}

- (void)willAppear
{
    [self.feedListViewController willAppear];
}

- (void)didAppear
{
    [self.feedListViewController didAppear];
}

- (void)willDisappear
{
    [self.feedListViewController willDisappear];
}

- (void)didDisappear
{
    [self.feedListViewController didDisappear];
}

- (void)setupCellModel:(id)model isDisplay:(BOOL)isDisplay
{
    if (self.pageVC) {
        if ([self.pageVC.delegate conformsToProtocol:@protocol(TTVFeedListPageCellDelegate)]) {
            self.delegate = (id<TTVFeedListPageCellDelegate>)self.pageVC.delegate;
        }
    }
    // Configure the cell
    if ([model isKindOfClass:[TTCategory class]]) {
        if (_category != model) {
            _category = (TTCategory *)model;
            [self configFeedListVC];
        }
        [self.feedListViewController refreshFeedListForCategory:self.category isDisplayView:isDisplay fromLocal:YES fromRemote:NO reloadFromType:TTReloadTypeNone getRemoteWhenLocalEmpty:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(headerViewForCell:)]) {
        [self setHeaderView:[self.delegate headerViewForCell:self]];
    }
}

- (void)refreshData
{
    [self triggerPullRefresh];
}

- (void)setSourceViewController:(TTCollectionPageViewController *)sourceViewController
{
    self.pageVC = (TTCollectionPageViewController *)sourceViewController;
}

- (TTCollectionPageViewController *)sourceViewController
{
    return self.pageVC;
}

@end
