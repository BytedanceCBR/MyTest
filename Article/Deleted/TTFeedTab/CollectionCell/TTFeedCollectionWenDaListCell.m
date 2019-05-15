//
//  TTFeedCollectionWenDaListCell.m
//  Article
//
//  Created by Chen Hong on 2017/5/19.
//
//

#import "TTFeedCollectionWenDaListCell.h"
#import "UIScrollView+Refresh.h"
#import "TTDeviceHelper.h"
#import "TTCategory.h"
#import "WDDefines.h"
#import "WDCategoryMainListView.h"
#import "NewsListLogicManager.h"


@interface TTFeedCollectionWenDaListCell () <WDCategoryMainListViewDelegate>
@property (nonatomic, strong) WDCategoryMainListView *listView;
@property (nonatomic, strong) TTCategory *category;
@end

@implementation TTFeedCollectionWenDaListCell

- (instancetype)initWithFrame:(CGRect)frame {
    frame.origin.y = 0;
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat bottomPadding = 44;
        if ([TTDeviceHelper isPadDevice]) {
            bottomPadding = 0;
        }
        WDNativeListModel *model = [[WDNativeListModel alloc] initWithPageType:WDNativeListBaseListAtWDCategory];
        self.listView = [[WDCategoryMainListView alloc] initWithFrame:self.bounds widthModel:model];
        self.listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.listView.delegate = self;
        [self.contentView addSubview:self.listView];
    }
    return self;
}

- (void)willAppear
{
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView willAppear];
    [self.listView scrollToTopEnable:YES];
}

- (void)didAppear
{
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView didAppear];
}

- (void)willDisappear
{
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView willDisappear];
}

- (void)didDisappear
{
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView didDisappear];
    [self.listView scrollToTopEnable:NO];
}

- (void)cellWillEnterForground
{
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView listViewWillEnterForground];
}

- (void)cellWillEnterBackground
{
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView listViewWillEnterBackground];
}

- (void)setupCellModel:(id)category isDisplay:(BOOL)isDisplay
{
    if ([category isKindOfClass:[TTCategory class]]) {
        if (_category != category) {
            _category = category;
        }
        [self.listView refreshListViewForCategory:self.category isDisplayView:isDisplay fromLocal:YES fromRemote:NO];
    }
}

- (id<TTFeedCategory>)categoryModel
{
    return self.category;
}

- (void)refreshDataWithType:(ListDataOperationReloadFromType)refreshType
{
    [self triggerPullRefresh];
}

- (void)setCategory:(TTCategory *)category
{
    if (_category != category) {
        _category = category;
    }
//    [self refreshIfNeeded];
    [self.listView refreshListViewForCategory:self.category isDisplayView:YES fromLocal:YES fromRemote:NO];
}

- (void)refreshIfNeeded
{
    if (self.category) {
        BOOL shouldAutoReload = [[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:self.category.categoryID];
//        ListDataOperationReloadFromType type = shouldAutoReload ? ListDataOperationReloadFromTypeAuto : ListDataOperationReloadFromTypeNone;
        [self.listView refreshListViewForCategory:self.category isDisplayView:YES fromLocal:NO fromRemote:shouldAutoReload];
    }
}

- (void)triggerPullRefresh
{
    [self.listView pullAndRefresh];
}

#pragma mark -- ArticleBaseListViewDelegate

- (void)listViewStartLoading:(WDCategoryMainListView*)listView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttFeedCollectionCellStartLoading:)]) {
        [self.delegate ttFeedCollectionCellStartLoading:self];
    }
}

- (void)listViewStopLoading:(WDCategoryMainListView*)listView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttFeedCollectionCellStopLoading:isPullDownRefresh:)]) {
        [self.delegate ttFeedCollectionCellStopLoading:self isPullDownRefresh:NO];
    }
}

@end
