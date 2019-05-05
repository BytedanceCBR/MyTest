//
//  TTFeedCollectionFollowListCell.m
//  Article
//
//  Created by 王霖 on 2017/6/12.
//
//

#import "TTFeedCollectionFollowListCell.h"
#import "NewsListLogicManager.h"
#import "UIScrollView+Refresh.h"
#import "TTDeviceHelper.h"
#import "TTCategory.h"
#import "ExploreMixedListBaseView.h"
#import "TTFollowCategoryMixedListView.h"

@interface TTFeedCollectionFollowListCell ()<ExploreMixedListBaseViewDelegate>

@property (nonatomic, strong) TTFollowCategoryMixedListView * listView;
@property (nonatomic, strong) TTCategory * category;

@end

@implementation TTFeedCollectionFollowListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat topPadding = 0;
        CGFloat bottomPadding = 44.f;
        if ([TTDeviceHelper isPadDevice]) {
            bottomPadding = 0;
        }
        self.listView = [[TTFollowCategoryMixedListView alloc] initWithFrame:self.bounds
                                                                    topInset:topPadding
                                                                 bottomInset:bottomPadding
                                                                    listType:ExploreOrderedDataListTypeCategory
                                                                listLocation:ExploreOrderedDataListLocationCategory
                                                   mixedListBaseViewDelegate:self];
        self.listView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.listView];
    }
    return self;
}

- (void)willAppear {
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView willAppear];
    [self.listView scrollToTopEnable:YES];
}

- (void)didAppear {
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView didAppear];
}

- (void)willDisappear {
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView willDisappear];
}

- (void)didDisappear {
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView didDisappear];
    [self.listView scrollToTopEnable:NO];
}

- (void)cellWillEnterForground {
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView listViewWillEnterForground];
}

- (void)cellWillEnterBackground {
    LOGD(@"~~~~~~%@ %@", self.category.categoryID, NSStringFromSelector(_cmd));
    [self.listView listViewWillEnterBackground];
}

- (BOOL)shouldAnimateRefreshView {
    BOOL isLoadingMore = self.listView.mixedListBaseView.listView.pullUpView.state == PULL_REFRESH_STATE_LOADING;
    return !isLoadingMore;
}

- (void)setupCellModel:(id<TTFeedCategory>)model isDisplay:(BOOL)isDisplay {
    if ([model isKindOfClass:[TTCategory class]]) {
        if (_category != model) {
            _category = (TTCategory *)model;
        }
        [self.listView refreshListViewForCategory:self.category
                                    isDisplayView:isDisplay
                                        fromLocal:YES
                                       fromRemote:NO
                                   reloadFromType:ListDataOperationReloadFromTypeNone];
    }
}

- (id<TTFeedCategory>)categoryModel {
    return self.category;
}

- (void)refreshDataWithType:(ListDataOperationReloadFromType)refreshType {
    TTFollowCategoryMixedListView * mixedListView = self.listView;
    mixedListView.mixedListBaseView.refreshFromType = refreshType;
    
    [self triggerPullRefresh];
}

- (void)setCategory:(TTCategory *)category {
    if (_category != category) {
        _category = category;
    }
    
    [self.listView refreshListViewForCategory:self.category
                                isDisplayView:YES
                                    fromLocal:YES
                                   fromRemote:NO
                               reloadFromType:ListDataOperationReloadFromTypeNone];
}

- (void)refreshIfNeeded {
    if (self.category) {
        BOOL shouldAutoReload = [[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:self.category.categoryID];
        ListDataOperationReloadFromType type = shouldAutoReload ? ListDataOperationReloadFromTypeAuto : ListDataOperationReloadFromTypeNone;
        if (shouldAutoReload) {
            [self.listView refreshListViewForCategory:self.category
                                        isDisplayView:YES
                                            fromLocal:NO
                                           fromRemote:shouldAutoReload
                                       reloadFromType:type];
        } else {
            if (![self.listView.mixedListBaseView tt_hasValidateData]) {
                [self.listView refreshListViewForCategory:self.category isDisplayView:YES fromLocal:YES fromRemote:shouldAutoReload reloadFromType:type];
            } else {
                [self.listView refreshDisplayView:YES];
            }
        }
    }
}

- (void)triggerPullRefresh {
    [self.listView pullAndRefresh];
}

#pragma mark -- ExploreMixedListBaseViewDelegate

- (void)mixListViewDidStartLoad:(ExploreMixedListBaseView *)listView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttFeedCollectionCellStartLoading:)]) {
        [self.delegate ttFeedCollectionCellStartLoading:self];
    }
}


- (void)mixListViewFinishLoad:(ExploreMixedListBaseView *)listView
                     isFinish:(BOOL)finish
                   isUserPull:(BOOL)userPull {
    if (finish && self.delegate && [self.delegate respondsToSelector:@selector(ttFeedCollectionCellStopLoading:isPullDownRefresh:)]) {
        [self.delegate ttFeedCollectionCellStopLoading:self isPullDownRefresh:userPull];
    }
    
}

- (void)mixListViewCancelRequest:(ExploreMixedListBaseView *)listView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttFeedCollectionCellStopLoading:isPullDownRefresh:)]) {
        [self.delegate ttFeedCollectionCellStopLoading:self isPullDownRefresh:NO];
    }
}


@end
