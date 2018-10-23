//
//  TTVFeedCollectionVideoCell.m
//  Article
//
//  Created by pei yun on 2017/7/13.
//
//

#import "TTVFeedCollectionVideoCell.h"
#import "TTVFeedListViewController.h"
#import "TTCategory.h"
#import "NewsListLogicManager.h"
#import "UIScrollView+Refresh.h"

@interface TTVFeedCollectionVideoCell () <TTVFeedListViewControllerDelegate>

@property (nonatomic, strong) TTVFeedListViewController     *feedListViewController;
@property (nonatomic, strong) TTCategory *category;

@end

@implementation TTVFeedCollectionVideoCell

@synthesize sourceViewController = _sourceViewController;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
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
        bottomPadding = 0;
    }
    self.feedListViewController = [[TTVFeedListViewController alloc] init];
    self.feedListViewController.isVideoTabCategory = NO;
    self.feedListViewController.delegate = self;
    UIViewController *viewController = self.sourceViewController;
    [viewController addChildViewController:self.feedListViewController];
    [self.contentView addSubview:self.feedListViewController.view];
    [self.feedListViewController didMoveToParentViewController:viewController];
    [self.feedListViewController setListTopInset:topPadding BottomInset:bottomPadding];
    [self.feedListViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(@0);
    }];
}

#pragma mark -- TTFeedCollectionCell protocol

- (void)didAppear
{
    [self.feedListViewController didAppear];
}

- (void)willAppear
{
    [self.feedListViewController willAppear];
}

- (void)willDisappear
{
    [self.feedListViewController willDisappear];
}

- (void)didDisappear
{
    [self.feedListViewController didDisappear];
}

- (void)cellWillEnterForground
{
    [self.feedListViewController listViewWillEnterForground];
}

- (void)cellWillEnterBackground
{
    [self.feedListViewController listViewWillEnterBackground];
}

- (BOOL)shouldAnimateRefreshView
{
    BOOL isLoadingMore = self.feedListViewController.tableView.pullUpView.state == PULL_REFRESH_STATE_LOADING;
    return !isLoadingMore;
}

- (void)setupCellModel:(id<TTFeedCategory>)model isDisplay:(BOOL)isDisplay
{
    if ([model isKindOfClass:[TTCategory class]]) {
        if (_category != model) {
            _category = (TTCategory *)model;
            [self configFeedListVC];
        }
        [self.feedListViewController refreshFeedListForCategory:self.category isDisplayView:isDisplay fromLocal:YES fromRemote:NO reloadFromType:TTReloadTypeNone getRemoteWhenLocalEmpty:NO];
    }
}

- (id<TTFeedCategory>)categoryModel
{
    return self.category;
}

- (void)refreshDataWithType:(ListDataOperationReloadFromType)refreshType
{
    self.feedListViewController.reloadFromType = (TTReloadType)refreshType;
    
    [self triggerPullRefresh];
}

- (void)refreshIfNeeded
{
    if (self.category) {
        BOOL shouldAutoReload = [[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:self.feedListViewController.localCacheKey];
        TTReloadType type = shouldAutoReload ? TTReloadTypeAuto : TTReloadTypeNone;
        if (shouldAutoReload) {
            [self.feedListViewController refreshFeedListForCategory:self.category isDisplayView:YES fromLocal:NO fromRemote:shouldAutoReload reloadFromType:type getRemoteWhenLocalEmpty:YES];
        } else {
            if (![self.feedListViewController tt_hasValidateData]) {
                [self.feedListViewController refreshFeedListForCategory:self.category isDisplayView:YES fromLocal:YES fromRemote:shouldAutoReload reloadFromType:type getRemoteWhenLocalEmpty:YES];
            } else {
                self.feedListViewController.isDisplayView = YES;
            }
        }
    }
}

- (void)triggerPullRefresh
{
    [self.feedListViewController pullAndRefresh];
}

#pragma mark - TTVFeedListViewControllerDelegate

- (void)feedDidStartLoad
{
    if ([self.delegate respondsToSelector:@selector(ttFeedCollectionCellStartLoading:)]) {
        [self.delegate ttFeedCollectionCellStartLoading:self];
    }
}

- (void)feedDidFinishLoadIsFinish:(BOOL)finish isUserPull:(BOOL)userPull
{
    if (finish && self.delegate && [self.delegate respondsToSelector:@selector(ttFeedCollectionCellStopLoading:isPullDownRefresh:)]) {
        [self.delegate ttFeedCollectionCellStopLoading:self isPullDownRefresh:userPull];
    }
}

- (void)feedRequestDidCancelRequest
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttFeedCollectionCellStopLoading:isPullDownRefresh:)]) {
        [self.delegate ttFeedCollectionCellStopLoading:self isPullDownRefresh:NO];
    }
}

@end
