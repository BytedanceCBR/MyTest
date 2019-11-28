//
//  TTUGCSearchHashtagViewController.m
//  Article
//
//  Created by Jiyee Sheng on 25/09/2017.
//
//

#import "TTUGCSearchHashtagViewController.h"
#import <TTUIWidget/UIViewController+Refresh_ErrorHandler.h>
#import "SSThemed.h"
#import "SSNavigationBar.h"
#import "TTUGCSearchHashtagTableViewCell.h"
#import "TTUGCRequestManager.h"
#import <TTUIWidget/TTSearchBarView.h>
#import "UIScrollView+Refresh.h"
#import "FRApiModel.h"
#import "TTDeviceHelper.h"
#import "TTTrackerWrapper.h"
#import "UIViewAdditions.h"
#import "UIViewController+NavigationBarStyle.h"
#import <TTUIWidget/TTIndicatorView.h>

typedef NS_ENUM(NSUInteger, TTUGCSearchHashtagViewControllerState) {
    TTUGCSearchState,
    TTUGCSearchingState,
    TTUGCSearchResultState,
};


@interface TTUGCSearchHashtagViewController () <UITableViewDataSource, UITableViewDelegate, UIViewControllerErrorHandler, TTSearchBarViewDelegate>

@property (nonatomic, strong) TTSearchBarView *searchBar;
@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) SSThemedTableView *searchResultTableView;
@property (nonatomic, strong) SSThemedView *maskView;

@property (nonatomic, assign) BOOL hasMore; // 请求是否hasMore
@property (nonatomic, strong) NSNumber *offset;
@property (nonatomic, strong) NSArray <TTUGCHashtagModel *> *recentHashtags;
@property (nonatomic, strong) NSArray <TTUGCHashtagModel *> *hotHashtags;

@property (nonatomic, assign) TTUGCSearchHashtagViewControllerState state; // 是否处于搜索请求结果

@property (nonatomic, assign) BOOL hasMoreSearchResult; // 请求是否hasMore
@property (nonatomic, strong) NSNumber *searchResultOffset;
@property (nonatomic, strong) NSArray <TTUGCHashtagModel *> *searchResultSuggestHashtags;
@property (nonatomic, copy) NSString *searchingWord;

@property (nonatomic, strong) NSError *searchError;
@property (nonatomic, strong) NSError *searchResultError;

@end

@implementation TTUGCSearchHashtagViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.ttNeedHideBottomLine = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);

     [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:@"选择话题"];
    TTNavigationBarItemContainerView *dismissItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft
                                                                                                                             withTitle:@"取消"
                                                                                                                                target:self
                                                                                                                                action:@selector(dismissAction:)];
    dismissItem.button.titleColorThemeKey = kColorText1;
    dismissItem.button.highlightedTitleColorThemeKey = kColorText1Highlighted;
    dismissItem.button.titleLabel.font = [UIFont systemFontOfSize:16];

    if ([TTDeviceHelper is736Screen]) {
        [dismissItem.button setTitleEdgeInsets:UIEdgeInsetsMake(0, -4.3f, 0, 4.3f)];
    }

    UIBarButtonItem *leftPaddingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                     target:nil
                                                                                     action:nil];
    leftPaddingItem.width = 17.f;
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:dismissItem], leftPaddingItem];
    self.navigationItem.rightBarButtonItem = nil;

    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];

    // 保证 searchBar 全区域点击可响应
    [self.searchBar.inputBackgroundView addTarget:self action:@selector(searchBarTapAction:) forControlEvents:UIControlEventTouchUpInside];

    //允许上拉刷新
    WeakSelf;
    [self.tableView tt_addPullUpLoadMoreWithNoMoreText:@"没有更多内容" withHandler:^{
        StrongSelf;
        [self triggerLoadMore];
    }];

    self.tableView.pullUpView.enabled = NO;

    // 搜索结果允许上拉刷新
    [self.searchResultTableView tt_addPullUpLoadMoreWithNoMoreText:@"没有更多内容" withHandler:^{
        StrongSelf;
        [self triggerLoadMoreSearchResult];
    }];

    self.searchResultTableView.pullUpView.enabled = NO;

    [self loadRequest];
}

- (void)loadRequest {
    FRUgcPublishPostV1HotForumRequestModel *requestModel = [[FRUgcPublishPostV1HotForumRequestModel alloc] init];
    requestModel.offset = self.offset;
    requestModel.forum_flag = @(self.hashtagSuggestOption);

    self.ttTargetView = self.tableView;

    if (self.offset.integerValue == 0) { // 首次请求
        [self tt_startUpdate];
    }

    WeakSelf;
    [TTUGCRequestManager requestModel:requestModel callBackWithMonitor:^(NSError *error, id<TTResponseModelProtocol> responseModel, TTUGCRequestMonitorModel *monitorModel) {
        StrongSelf;
        self.searchBar.searchField.placeholder = @"输入关键字搜索话题";

        FRUgcPublishPostV1HotForumResponseModel *model = (FRUgcPublishPostV1HotForumResponseModel *) responseModel;

        if (error || model.err_no.integerValue > 0) {
            if (self.offset.integerValue == 0) { // 首次请求
                if ([error.domain isEqualToString:@"kCommonErrorDomain"] && error.code == 1001) {
                    self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
                } else {
                    if ([error.domain isEqualToString:@"kCommonErrorDomain"]) {
                        self.ttViewType = TTFullScreenErrorViewTypeEmpty;
                    } else {
                        self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
                    }
                }

                self.searchError = error;

                [self tt_endUpdataData:NO error:error];
            } else { // loadMore
                self.searchError = nil;

                [self.tableView finishPullUpWithSuccess:NO];
            };

            return;
        }

        if (!isEmptyString(model.data.suggest_tips) && self.showCanBeCreatedHashtag) {
            self.searchBar.searchField.placeholder = model.data.suggest_tips;
        }

        self.searchError = nil;
        self.offset = model.data.offset;
        self.hasMore = model.data.has_more;

        // recent
        if (!self.recentHashtags) {
            self.recentHashtags = [TTUGCHashtagModel hashtagModelsWithSearchHashtagModels:model.data.recently];
        }

        // insert recent header
        if (self.recentHashtags && self.recentHashtags.count > 0) {
            TTUGCHashtagHeaderModel *recentHeaderModel = [[TTUGCHashtagHeaderModel alloc] init];
            recentHeaderModel.cellHeight = 34.f;
            recentHeaderModel.text = @"最近使用";
            NSMutableArray *recentHashtags = [NSMutableArray arrayWithArray:self.recentHashtags];
            [recentHashtags insertObject:recentHeaderModel atIndex:0];
            self.recentHashtags = [recentHashtags copy];
        }

        // hot
        if (!self.hotHashtags) {
            self.hotHashtags = [NSArray array];
        }
        NSMutableArray *hotHashtags = [self.hotHashtags mutableCopy];
        if (model.data.hot) {
            [hotHashtags addObjectsFromArray:[TTUGCHashtagModel hashtagModelsWithSearchHashtagModels:model.data.hot]];
        }

        // insert hot header
        if (hotHashtags.count > 0) {
            TTUGCHashtagHeaderModel *hotHeaderModel = [[TTUGCHashtagHeaderModel alloc] init];
            hotHeaderModel.text = @"热门话题";
            if (self.recentHashtags && self.recentHashtags.count > 0) {
                hotHeaderModel.showTopSeparator = YES;
                hotHeaderModel.cellHeight = 40.f;
            } else {
                hotHeaderModel.showTopSeparator = NO;
                hotHeaderModel.cellHeight = 34.f;
            }

            [hotHashtags insertObject:hotHeaderModel atIndex:0];
        }
        self.hotHashtags = [hotHashtags copy];

        self.tableView.hasMore = model.data.has_more;
        self.tableView.pullUpView.enabled = YES;
        [self reloadDataAndConfigScrollable:self.tableView];

        [self tt_endUpdataData:NO error:error];

        // 检索完成之后的检查不用判断只用判断数据
//        if (!self.tt_hasValidateData) {
//            self.searchBar.searchField.placeholder = @"搜索话题";
//        } else {
//            self.searchBar.searchField.placeholder = @"搜索";
//        }
    }];
}

- (void)triggerLoadMore {
    if (self.hasMore) {
        [self loadRequest];
    } else {
        [self.tableView finishPullUpWithSuccess:YES];
    }
}

- (void)loadRequestSearchResult:(BOOL)loadMore {
    // 重复检索词不重复请求
    if (!loadMore && !self.searchResultError && [self.searchingWord isEqualToString:self.searchBar.text]) {
        return;
    }

    self.searchingWord = self.searchBar.text;

    FRUgcPublishPostV1HashtagRequestModel *requestModel = [[FRUgcPublishPostV1HashtagRequestModel alloc] init];
    requestModel.words = self.searchingWord;
    requestModel.offset = loadMore ? self.searchResultOffset : @0;
    requestModel.forum_flag = @(self.hashtagSuggestOption);

    self.ttTargetView = self.searchResultTableView;

    if (!loadMore && SSIsEmptyArray(self.searchResultSuggestHashtags)) {
        [self tt_startUpdate];
    }

    WeakSelf;
    [TTUGCRequestManager requestModel:requestModel callBackWithMonitor:^(NSError *error, id<TTResponseModelProtocol> responseModel, TTUGCRequestMonitorModel *monitorModel) {
        StrongSelf;

        if (!loadMore) {
            self.searchResultSuggestHashtags = nil;
        }

        FRUgcPublishPostV1HashtagResponseModel *model = (FRUgcPublishPostV1HashtagResponseModel *) responseModel;

        if (error || model.err_no.integerValue > 0) {
            if (!loadMore) { // 首次请求sd
                if ([error.domain isEqualToString:@"kCommonErrorDomain"] && error.code == 1001) {
                    self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
                } else {
                    if ([error.domain isEqualToString:@"kCommonErrorDomain"]) {
                        self.ttViewType = TTFullScreenErrorViewTypeEmpty;
                    } else {
                        self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
                    }
                }

                self.searchResultError = error;

                [self reloadDataAndConfigScrollable:self.searchResultTableView];

                [self tt_endUpdataData:NO error:error];
            } else { // loadMore
                self.searchResultError = nil;
                [self.searchResultTableView finishPullUpWithSuccess:NO];
            };

            return;
        }

        // 检索数据为空时，展现用户数据
        if (!loadMore && model.data.suggest.count == 0 && !model.data.fresh_forum) {
            self.ttViewType = TTFullScreenErrorViewTypeEmpty;
            [self reloadDataAndConfigScrollable:self.searchResultTableView];
            [self tt_endUpdataData:NO error:error];
            return;
        }

        self.searchResultError = nil;
        self.searchResultOffset = model.data.offset;
        self.hasMoreSearchResult = model.data.has_more;

        if (!self.searchResultSuggestHashtags) {
            self.searchResultSuggestHashtags = [NSArray array];
        }

        NSMutableArray *searchResultSuggestHashtags = [self.searchResultSuggestHashtags mutableCopy];
        if (self.showCanBeCreatedHashtag && !loadMore && model.data.fresh_forum) { // 追加可自建的话题到最前面
            [searchResultSuggestHashtags addObject:[TTUGCHashtagModel hashtagModelSelfCreateWithSearchHashtagStructModel:model.data.fresh_forum]];
        }
        if (model.data.suggest) {
            [searchResultSuggestHashtags addObjectsFromArray:[TTUGCHashtagModel hashtagModelsWithSearchHashtagModels:model.data.suggest]];
        }
        self.searchResultSuggestHashtags = [searchResultSuggestHashtags copy];

        self.searchResultTableView.hasMore = model.data.has_more;
        self.searchResultTableView.pullUpView.enabled = YES;
        [self reloadDataAndConfigScrollable:self.searchResultTableView];

        [self tt_endUpdataData:NO error:error];
    }];
}

- (void)triggerLoadMoreSearchResult {
    if (self.hasMoreSearchResult) {
        [self loadRequestSearchResult:YES];
    } else {
        [self.searchResultTableView finishPullUpWithSuccess:YES];
    }
}

- (void)dismissAction:(id)sender {
    [self.searchBar endEditing:YES];

    if (self.delegate && [self.delegate respondsToSelector:@selector(searchHashtagTableViewWillDismiss)]) {
        [self.delegate searchHashtagTableViewWillDismiss];
    }

    WeakSelf;
    [self dismissViewControllerAnimated:YES completion:^{
        StrongSelf;
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchHashtagTableViewDidDismiss)]) {
            [self.delegate searchHashtagTableViewDidDismiss];
        }
    }];

    if (sender) {
        [TTTrackerWrapper eventV3:@"hashtag_choose_cancel" params:nil];
    }
}

- (void)swipeAction:(id)sender {
    [self searchBarCancelButtonClicked:self.searchBar];
}

- (void)showSearchResultTableView {
    self.state = TTUGCSearchResultState;

    self.searchResultSuggestHashtags = nil;

    [self reloadDataAndConfigScrollable:self.searchResultTableView];

    [self.view addSubview:self.searchResultTableView];
}

- (void)hideSearchResultTableView {
    self.state = TTUGCSearchingState;

    self.searchingWord = nil;
    self.searchResultSuggestHashtags = nil;

    [self reloadDataAndConfigScrollable:self.searchResultTableView];

    [self.searchResultTableView removeFromSuperview];

    if (self.searchError) {
        self.ttTargetView = self.tableView;
        [self tt_endUpdataData:NO error:self.searchError];
    }
}

- (void)reloadDataAndConfigScrollable:(UITableView *)tableView {
    [tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        tableView.pullUpView.hidden = tableView.contentSize.height + 74.f * 2 < tableView.height;
    });
}

#pragma mark - UIView+ErrorHandler

- (BOOL)tt_hasValidateData {
    return [self dataSourceInSection:0 forState:self.state].count > 0 ||
        [self dataSourceInSection:1 forState:self.state].count > 0 ||
        [self dataSourceInSection:2 forState:self.state].count > 0;
}

- (void)refreshData {
    if (self.state == TTUGCSearchState) {
        [self loadRequest];
    } else if (self.state == TTUGCSearchResultState) {
        [self loadRequestSearchResult:NO];
    }
}

#pragma mark - TTSearchBarViewDelegate

- (void)searchBarTapAction:(id)sender {
    [self.searchBar becomeFirstResponder];

    [self searchBarBecomeActive];
}

- (void)searchBarBecomeActive {
    if (self.state == TTUGCSearchState) {
        self.state = TTUGCSearchingState;

        [self.navigationController setNavigationBarHidden:YES animated:YES];

        CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;

        self.maskView.top = topInset + 44.f;

        [self.view addSubview:self.maskView];

        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            self.searchBar.top = [UIApplication sharedApplication].statusBarFrame.size.height;
            self.tableView.top = self.searchBar.bottom;
            self.tableView.height = self.view.height - self.searchBar.bottom;
            self.searchBar.showsCancelButton = YES;
            self.searchBar.contentView.width -= self.searchBar.cancelButton.width;
            self.searchBar.cancelButton.left -= self.searchBar.cancelButton.width;
            self.searchBar.backgroundColorThemeKey = kColorBackground4;
            self.searchBar.inputBackgroundView.backgroundColorThemeKey = kColorBackground3;
            self.maskView.top = topInset;
            self.maskView.alpha = 0.3f;
        } completion:^(BOOL finished) {
            self.tableView.scrollEnabled = NO;
        }];
    }
}

- (BOOL)searchBarShouldBeginEditing:(TTSearchBarView *)searchBar {
    [TTTrackerWrapper eventV3:@"search_bar_click" params:nil];

    [self searchBarBecomeActive];

    return YES;
}

- (void)searchBar:(TTSearchBarView *)searchBar textDidChange:(NSString *)searchText {
    if (isEmptyString(searchText)) {
        [self hideSearchResultTableView];

        return;
    }

    if (self.state == TTUGCSearchingState) {
        [self showSearchResultTableView];
    }

    [self loadRequestSearchResult:NO];
}

- (void)searchBarSearchButtonClicked:(TTSearchBarView *)searchBar {
    [self.searchBar resignFirstResponder];

    if (isEmptyString(searchBar.text)) {
        [self hideSearchResultTableView];

        return;
    }

    if (self.state == TTUGCSearchingState) {
        [self showSearchResultTableView];
    }

    [self loadRequestSearchResult:NO];
}

- (void)searchBarCancelButtonClicked:(TTSearchBarView *)searchBar {
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }

    CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height - 4.f;

    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.searchBar.top = topInset;
        self.tableView.top = self.searchBar.bottom;
        self.tableView.height = self.view.height - self.searchBar.bottom;
        self.searchBar.showsCancelButton = NO;
        self.searchBar.contentView.width += self.searchBar.cancelButton.width;
        self.searchBar.cancelButton.left += self.searchBar.cancelButton.width;
        self.searchBar.backgroundColorThemeKey = kColorBackground4;
        self.searchBar.inputBackgroundView.backgroundColorThemeKey = kColorBackground3;
        self.maskView.top = topInset + 44.f;
        self.maskView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self hideSearchResultTableView];
        [self.maskView removeFromSuperview];
        self.tableView.scrollEnabled = YES;
        self.state = TTUGCSearchState;
        self.searchBar.text = nil;

        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }];
}

- (NSArray *)dataSourceInSection:(NSInteger)section forState:(TTUGCSearchHashtagViewControllerState)state {
    if (state == TTUGCSearchResultState) {
        if (section == 0) {
            return self.searchResultSuggestHashtags;
        }
    } else if (state == TTUGCSearchState || state == TTUGCSearchingState) {
        if (section == 0) {
            return self.recentHashtags;
        } else if (section == 1) {
            return self.hotHashtags;
        }
    }

    return nil;
}

- (NSString *)trackEventProfileTypeInSection:(NSInteger)section forState:(TTUGCSearchHashtagViewControllerState)state {
    if (state == TTUGCSearchResultState) {
        if (section == 0) {
            return @"suggest";
        }
    } else if (state == TTUGCSearchState || state == TTUGCSearchingState) {
        if (section == 0) {
            return @"recently";
        } else if (section == 1) {
            return @"hot_tag";
        }
    }

    return nil;
}

- (NSString *)trackEventPageTypeInSection:(NSInteger)section forState:(TTUGCSearchHashtagViewControllerState)state {
    if (state == TTUGCSearchResultState) {
        return @"search";
    } else if (state == TTUGCSearchState || state == TTUGCSearchingState) {
        return @"default";
    }

    return nil;

}

- (BOOL)showLastLongSeparatorLineInIndexPath:(NSIndexPath *)indexPath dataSource:(NSArray *)dataSource forState:(TTUGCSearchHashtagViewControllerState)state {
    if (state == TTUGCSearchResultState) {
        if (indexPath.section == 0 && indexPath.row == dataSource.count - 1) {
            return YES;
        }
    } else if (state == TTUGCSearchState || state == TTUGCSearchingState) {
        if ((indexPath.section == 0 || indexPath.section == 1) && indexPath.row == dataSource.count - 1) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.state == TTUGCSearchResultState) {
        return 1;
    } else if (self.state == TTUGCSearchState || self.state == TTUGCSearchingState) {
        return 2;
    }

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *dataSource = [self dataSourceInSection:section forState:self.state];

    return dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *dataSource = [self dataSourceInSection:indexPath.section forState:self.state];
    if (dataSource && dataSource.count > indexPath.row) {
        id model = [dataSource objectAtIndex:indexPath.row];
        if ([model isKindOfClass:[TTUGCHashtagHeaderModel class]]) {
            return ((TTUGCHashtagHeaderModel *) model).cellHeight;
        }
    }

    return 74.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id hashtagModel;
    NSArray *dataSource = [self dataSourceInSection:indexPath.section forState:self.state];
    if (indexPath.row < dataSource.count) {
        hashtagModel = dataSource[indexPath.row];
    }

    UITableViewCell *cell = nil;

    if ([hashtagModel isKindOfClass:[TTUGCHashtagHeaderModel class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTUGCSearchHashtagTableHeaderViewCell class]) forIndexPath:indexPath];
        [(TTUGCSearchHashtagTableHeaderViewCell *)cell configWithHashtagHeaderModel:hashtagModel];
    } else if ([hashtagModel isKindOfClass:[TTUGCHashtagModel class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTUGCSearchHashtagTableViewCell class]) forIndexPath:indexPath];

        NSInteger row = self.state == TTUGCSearchState && indexPath.section == 1 ? indexPath.row : 0;
        [(TTUGCSearchHashtagTableViewCell *)cell configWithHashtagModel:hashtagModel row:row longSeparatorLine:[self showLastLongSeparatorLineInIndexPath:indexPath dataSource:dataSource forState:self.state]];

        // ui 第一个section最后一个cell分割线不显示
        if ((self.state == TTUGCSearchState || self.state == TTUGCSearchingState) && indexPath.section == 0 && self.hotHashtags.count > 0 && self.recentHashtags.count > 0 && indexPath.row == dataSource.count - 1) {
            ((TTUGCSearchHashtagTableViewCell *)cell).bottomLineView.hidden = YES;
        } else {
            ((TTUGCSearchHashtagTableViewCell *)cell).bottomLineView.hidden = NO;
        }
    }

    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id selectedModel = nil;
    NSArray *dataSource = [self dataSourceInSection:indexPath.section forState:self.state];
    if (indexPath.row < dataSource.count) {
        selectedModel = dataSource[indexPath.row];
    }

    if (selectedModel && [selectedModel isKindOfClass:[TTUGCHashtagModel class]]) {
        TTUGCHashtagModel *hashtagModel = (TTUGCHashtagModel *)selectedModel;
        if (hashtagModel.canBeCreated && hashtagModel.forum.status.intValue == 0) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:@"您的话题被话题君带走了~"
                                     indicatorImage:nil
                                        autoDismiss:YES
                                     dismissHandler:nil];
        } else {
            if (hashtagModel.canBeCreated) {
                NSString *forumName = hashtagModel.forum.forum_name;
                if ([forumName containsString:@"#"] || [forumName containsString:@"@"]) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                              indicatorText:@"不支持特殊符号的话题创建"
                                             indicatorImage:nil
                                                autoDismiss:YES
                                             dismissHandler:nil];
                    forumName = [forumName stringByReplacingOccurrencesOfString:@"#" withString:@""];
                    forumName = [forumName stringByReplacingOccurrencesOfString:@"@" withString:@""];
                }

                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
                NSString *trimmedString = [regex stringByReplacingMatchesInString:forumName options:0 range:NSMakeRange(0, [forumName length]) withTemplate:@" "];
                forumName = [trimmedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                hashtagModel.forum.forum_name = forumName;
            }

            if (self.delegate && [self.delegate respondsToSelector:@selector(searchHashtagTableViewDidSelectedHashtag:)]) {
                [self.delegate searchHashtagTableViewDidSelectedHashtag:hashtagModel];
            }

            [self dismissAction:nil];
        }

        NSString *trackEventProfileType = [self trackEventProfileTypeInSection:indexPath.section forState:self.state];
        NSString *trackEventPageType = [self trackEventPageTypeInSection:indexPath.section forState:self.state];

        [TTTrackerWrapper eventV3:@"hashtag_choose_click" params:@{
            @"page_type" : trackEventPageType ?: @"",
            @"profile_type" : trackEventProfileType ?: @"",
        }];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - getter and setter

- (TTSearchBarView *)searchBar {
    CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height - 4.f;

    if (!_searchBar) {
        _searchBar = [[TTSearchBarView alloc] initWithFrame:CGRectMake(0, topInset, self.view.width, 44.f)];
        _searchBar.backgroundColorThemeKey = kColorBackground4;
        _searchBar.inputBackgroundView.backgroundColorThemeKey = kColorBackground3;
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.searchField.placeholderColorThemeKey = kColorText3;
        _searchBar.delegate = self;
    }

    return _searchBar;
}

- (SSThemedTableView *)tableView {
    if (!_tableView) {
        _tableView = [[SSThemedTableView alloc] initWithFrame:CGRectMake(0, self.searchBar.bottom, self.view.width, self.view.height - self.searchBar.bottom)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColorThemeKey = kColorBackground4;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        [_tableView registerClass:[TTUGCSearchHashtagTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTUGCSearchHashtagTableViewCell class])];
        [_tableView registerClass:[TTUGCSearchHashtagTableHeaderViewCell class] forCellReuseIdentifier:NSStringFromClass([TTUGCSearchHashtagTableHeaderViewCell class])];
    }

    return _tableView;
}

- (SSThemedTableView *)searchResultTableView {
    CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;

    if (!_searchResultTableView) {
        _searchResultTableView = [[SSThemedTableView alloc] initWithFrame:CGRectMake(0, topInset, self.view.width, self.view.height - topInset)];
        _searchResultTableView.delegate = self;
        _searchResultTableView.dataSource = self;
        _searchResultTableView.backgroundColorThemeKey = kColorBackground4;
        _searchResultTableView.backgroundView = nil;
        _searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchResultTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _searchResultTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_searchResultTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        [_searchResultTableView registerClass:[TTUGCSearchHashtagTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTUGCSearchHashtagTableViewCell class])];
    }

    return _searchResultTableView;
}

- (SSThemedView *)maskView {
    CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;

    if (!_maskView) {
        _maskView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, topInset, self.view.width, self.view.height - topInset)];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0;

        UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp;
        [_maskView addGestureRecognizer:swipeGestureRecognizer];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        [_maskView addGestureRecognizer:tapGestureRecognizer];
    }

    return _maskView;
}

@end
