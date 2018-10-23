//
//  TTFeedCollectionHTSListCell.m
//  Article
//
//  Created by 王双华 on 2017/6/8.
//
//

#import "TTFeedCollectionHTSListCell.h"
#import "NewsListLogicManager.h"
#import "UIScrollView+Refresh.h"
#import "TTDeviceHelper.h"
#import "TTCategoryStayTrackManager.h"
#import "TTHTSWaterfallCollectionView.h"
#import "TSVTabTipManager.h"
#import "TSVCategory.h"
#import "TSVListAutoRefreshRecorder.h"

@interface TTFeedCollectionHTSListCell () <ArticleBaseListViewDelegate>
@property(nonatomic, strong) TTHTSWaterfallCollectionView *listView;
@property(nonatomic, strong) TTCategory *category;
@property(nonatomic, copy) NSString *listEntracne;

@end

@implementation TTFeedCollectionHTSListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat topPadding = 0;
        CGFloat bottomPadding = 44 + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
        
        if ([TTDeviceHelper isPadDevice]) {
            bottomPadding = 0;
        }
        
        self.listView = [[TTHTSWaterfallCollectionView alloc] initWithFrame:self.bounds topInset:topPadding bottomInset:bottomPadding];
        self.listView.delegate = self;
        self.listView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.listView];
    }
    return self;
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
}

- (void)didDisappear
{
    [self.listView didDisappear];
    [self.listView scrollToTopEnable:NO];
}

- (void)cellWillEnterForground
{
    [self.listView listViewWillEnterForground];
}

- (void)cellWillEnterBackground
{
    [self.listView listViewWillEnterBackground];
}

- (void)setupCellModel:(id)category isDisplay:(BOOL)isDisplay
{
    if ([category isKindOfClass:[TTCategory class]]) {
        if (_category != category) {
            _category = category;
        }

        if ([category isMemberOfClass:[TSVCategory class]]) {
            self.listEntracne = @"main_tab";
        } else {
            self.listEntracne = nil;
        }
        
        [self.listView refreshListViewForCategory:self.category isDisplayView:isDisplay fromLocal:YES fromRemote:NO reloadFromType:ListDataOperationReloadFromTypeNone listEntrance:self.listEntracne];
    }
}

- (id<TTFeedCategory>)categoryModel
{
    return self.category;
}

- (void)refreshIfNeeded
{
    if (self.category) {
        BOOL shouldAutoRefreshWhenDisplayingRedDot = [[TSVTabTipManager sharedManager] shouldAutoReloadFromRemoteForCategory:self.category.categoryID listEntrance:self.listEntracne];
        BOOL shouldAutoRefreshWhenEnteringOverTime = [TSVListAutoRefreshRecorder shouldAutoRefreshForCategory:self.category];
        ListDataOperationReloadFromType type;
        if (shouldAutoRefreshWhenDisplayingRedDot) {
            type = ListDataOperationReloadFromTypeTip;
        } else if (shouldAutoRefreshWhenEnteringOverTime) {
            type = ListDataOperationReloadFromTypeAuto;
        } else {
            type = ListDataOperationReloadFromTypeNone;
        }
        if (shouldAutoRefreshWhenDisplayingRedDot || shouldAutoRefreshWhenEnteringOverTime) {
            [self.listView refreshListViewForCategory:self.category isDisplayView:YES fromLocal:NO fromRemote:YES reloadFromType:type listEntrance:self.listEntracne];
        } else {
            if (![self.listView tt_hasValidateData]) {
                [self.listView refreshListViewForCategory:self.category isDisplayView:YES fromLocal:YES fromRemote:NO reloadFromType:type listEntrance:self.listEntracne];
            } else {
                [self.listView refreshDisplayView:YES];
            }
        }
    }
}

- (void)triggerPullRefresh
{
    [self.listView pullAndRefresh];
}

- (void)refreshDataWithType:(ListDataOperationReloadFromType)refreshType
{
    [self.listView setRefreshFromType:refreshType];
    [self triggerPullRefresh];
}

#pragma mark - ArticleBaseListViewDelegate

- (void)listViewStartLoading:(ArticleBaseListView*)listView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttFeedCollectionCellStartLoading:)]) {
        [self.delegate ttFeedCollectionCellStartLoading:self];
    }
}

- (void)listViewStopLoading:(ArticleBaseListView*)listView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttFeedCollectionCellStopLoading:isPullDownRefresh:)]) {
        [self.delegate ttFeedCollectionCellStopLoading:self isPullDownRefresh:NO];
    }
}

@end
