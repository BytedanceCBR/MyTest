//
//  TTCollectionListPageCell.m
//  Article
//
//  Created by 刘廷勇 on 16/1/15.
//
//

#import "TTCollectionListPageCell.h"
#import "ExploreMixedListView.h"
#import "NewsListLogicManager.h"
#import "UIScrollView+Refresh.h"
#import "TTDeviceHelper.h"
#import "TTCategoryStayTrackManager.h"
#import "TTTopBar.h"

@interface TTCollectionListPageCell() <ExploreMixedListBaseViewDelegate>

@property (nonatomic, assign) TTCategoryModelTopType tabType;
@property (nonatomic, weak) TTCollectionPageViewController *pageVC;

@end

@implementation TTCollectionListPageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat topPadding = 0;
        CGFloat bottomPadding = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom + 44;
        
        if ([TTDeviceHelper isPadDevice]) {
            topPadding = 64 + 44;
        }
        
        self.listView = [[ExploreMixedListView alloc] initWithFrame:CGRectMake(0,64, self.bounds.size.width, self.bounds.size.height-64) topInset:topPadding bottomInset:bottomPadding listType:ExploreOrderedDataListTypeCategory listLocation:ExploreOrderedDataListLocationCategory];
        self.listView.listView.delegate = self;
        self.listView.listView.isInVideoTab = YES;
        [self.contentView addSubview:self.listView];
        
        if (![TTDeviceHelper isPadDevice]) {
            CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
            CGFloat topOffset = statusBarHeight + kTopSearchButtonHeight;
            if ([SSCommonLogic threeTopBarEnable] && self.listView.listView.isInVideoTab){
                topOffset = statusBarHeight + kTopSearchButtonHeight + kSelectorViewHeight;
            }
            [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).offset(topOffset);
                make.left.right.bottom.equalTo(self.contentView);
            }];
        }
        else {
            [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView);
            }];
        }
        [self.listView willAppear];
    }
    return self;
}

- (void)setHeaderView:(UIView *)headerView
{
    self.listView.listView.listView.customTopOffset = headerView.frame.size.height;
    self.listView.listView.listView.tableHeaderView = headerView;
}

- (void)setTabType:(TTCategoryModelTopType)tabType
{
    self.listView.tabType = tabType;
}

- (void)refreshIfNeeded
{
    if (self.category) {
        BOOL shouldAutoReload = [[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:self.category.categoryID];
        ListDataOperationReloadFromType type = shouldAutoReload ? ListDataOperationReloadFromTypeAuto : ListDataOperationReloadFromTypeNone;
        BOOL hasSetCategory=NO;
        if (self.listView.currentCategory!=nil) {
            hasSetCategory = YES;
        }
        [self.listView refreshListViewForCategory:self.category isDisplayView:YES fromLocal:YES fromRemote:shouldAutoReload reloadFromType:type];
        if (!hasSetCategory) {
            [self.listView willAppear];
        }
    }
}

- (void)triggerPullRefresh
{
    [self.listView pullAndRefresh];
}

#pragma mark ExploreMixedListBaseViewDelegate Methods

- (void)mixListViewDidStartLoad:(ExploreMixedListBaseView *)listView
{
    if ([self.delegate respondsToSelector:@selector(listViewOfTTCollectionPageCellStartLoading:)]) {
        [self.delegate listViewOfTTCollectionPageCellStartLoading:self];
    }
}

- (void)mixListViewFinishLoad:(ExploreMixedListBaseView *)listView isFinish:(BOOL)finish isUserPull:(BOOL)userPull
{
    if ([self.delegate respondsToSelector:@selector(listViewOfTTCollectionPageCellEndLoading:)]) {
        [self.delegate listViewOfTTCollectionPageCellEndLoading:self];
    }
}

- (void)mixListViewCancelRequest:(ExploreMixedListBaseView *)listView
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
    
    [[TTCategoryStayTrackManager shareManager] startTrackForCategoryID:categoryID concernID:self.category.concernID enterType:nil];
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
    [self.listView willAppear];
    [self.listView scrollToTopEnable:YES];
}

- (void)didAppear
{
    [self.listView didAppear];
}

- (void)willDisappear
{
    [self.listView willDisappear];
    [self.listView scrollToTopEnable:NO];
}

- (void)didDisappear
{
    [self.listView didDisappear];
}

- (void)setupCellModel:(id)model isDisplay:(BOOL)isDisplay
{
    if (self.pageVC) {
        self.tabType = self.pageVC.tabType;
        if ([self.pageVC.delegate conformsToProtocol:@protocol(TTCollectionListPageCellDelegate)]) {
            self.delegate = (id<TTCollectionListPageCellDelegate>)self.pageVC.delegate;
        }
    }
    // Configure the cell
    if ([model isKindOfClass:[TTCategory class]]) {
        if (_category != model) {
            _category = (TTCategory *)model;
        }
        [self.listView refreshListViewForCategory:self.category isDisplayView:isDisplay fromLocal:YES fromRemote:NO reloadFromType:ListDataOperationReloadFromTypeNone];
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
