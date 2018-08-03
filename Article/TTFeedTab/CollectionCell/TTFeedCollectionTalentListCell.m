//
//  TTFeedCollectionTalentListCell.m
//  Article
//
//  Created by Chen Hong on 2017/4/9.
//
//

#import "TTFeedCollectionTalentListCell.h"
#import "NewsListLogicManager.h"
#import "UIScrollView+Refresh.h"
#import "TTDeviceHelper.h"
#import "TTCategoryStayTrackManager.h"
#import "TTWaterfallCollectionView.h"

@interface TTFeedCollectionTalentListCell () <ArticleBaseListViewDelegate>
@property(nonatomic, strong) TTWaterfallCollectionView *listView;
@property(nonatomic, strong) TTCategory *category;
@end

@implementation TTFeedCollectionTalentListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat topPadding = 0;
        CGFloat bottomPadding = 44;
        
        if ([TTDeviceHelper isPadDevice]) {
            bottomPadding = 0;
        }
        
        self.listView = [[TTWaterfallCollectionView alloc] initWithFrame:self.bounds topInset:topPadding bottomInset:bottomPadding];
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

- (void)setupCellModel:(id)category isDisplay:(BOOL)isDisplay
{
    if ([category isKindOfClass:[TTCategory class]]) {
        if (_category != category) {
            _category = category;
        }
        //    [self refreshIfNeeded];
        [self.listView refreshListViewForCategory:self.category isDisplayView:isDisplay fromLocal:YES fromRemote:NO reloadFromType:ListDataOperationReloadFromTypeNone];
    }
}

- (id<TTFeedCategory>)categoryModel
{
    return self.category;
}

- (void)refreshData
{
    [self triggerPullRefresh];
}

- (void)setCategory:(TTCategory *)category
{
    if (_category != category) {
        _category = category;
    }
//    [self refreshIfNeeded];
    [self.listView refreshListViewForCategory:self.category isDisplayView:YES fromLocal:YES fromRemote:NO reloadFromType:ListDataOperationReloadFromTypeNone];
}

- (void)refreshIfNeeded
{
    if (self.category) {
        BOOL shouldAutoReload = [[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:self.category.categoryID];
        ListDataOperationReloadFromType type = shouldAutoReload ? ListDataOperationReloadFromTypeAuto : ListDataOperationReloadFromTypeNone;
        if (shouldAutoReload) {
            [self.listView refreshListViewForCategory:self.category isDisplayView:YES fromLocal:NO fromRemote:shouldAutoReload reloadFromType:type];
        } else {
            [self.listView refreshDisplayView:YES];
        }
    }
}

- (void)triggerPullRefresh
{
    [self.listView pullAndRefresh];
}

- (void)refreshDataWithType:(ListDataOperationReloadFromType)refreshType
{
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
