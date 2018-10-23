//
//  TTFeedCollectionWebListCell.m
//  Article
//
//  Created by Chen Hong on 2017/4/9.
//
//

#import "TTFeedCollectionWebListCell.h"
#import "ExploreMixedListView.h"
#import "NewsListLogicManager.h"
#import "UIScrollView+Refresh.h"
#import "TTDeviceHelper.h"
#import "ArticleWebListView.h"

@interface TTFeedCollectionWebListCell () <ArticleBaseListViewDelegate>
@property(nonatomic, strong) ArticleWebListView *listView;
@property (nonatomic, strong) TTCategory *category;
@end

@implementation TTFeedCollectionWebListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat topPadding = 0;
        CGFloat bottomPadding = 44;
        
        if ([TTDeviceHelper isPadDevice]) {
            bottomPadding = 0;
        }
        
        self.listView = [[ArticleWebListView alloc] initWithFrame:self.bounds topInset:topPadding bottomInset:bottomPadding];
        self.listView.delegate = self;
        self.listView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.listView];
    }
    return self;
}

- (void)willAppear
{
    [self.listView willAppear];
    self.listView.isVisible = YES;
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
    self.listView.isVisible = NO;
    [self.listView scrollToTopEnable:NO];
}

- (BOOL)shouldHideRefreshView
{
    return YES;
}

- (void)setupCellModel:(id)model isDisplay:(BOOL)isDisplay
{
    if ([model isKindOfClass:[TTCategory class]]) {
        self.category = model;
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
    //[self refreshIfNeeded];
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
