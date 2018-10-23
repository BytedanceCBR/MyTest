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
#import "TTNetworkManager.h"
#import "TTSeachBarView.h"
#import "UIScrollView+Refresh.h"
#import "FRApiModel.h"
#import "TTDeviceHelper.h"
#import "TTTrackerWrapper.h"
#import "UIViewAdditions.h"
#import "UIViewController+NavigationBarStyle.h"

typedef NS_ENUM(NSUInteger, TTUGCSearchHashtagViewControllerState) {
    TTUGCSearchState,
    TTUGCSearchingState,
    TTUGCSearchResultState,
};


@interface TTUGCSearchHashtagViewController () <UITableViewDataSource, UITableViewDelegate, UIViewControllerErrorHandler, TTSeachBarViewDelegate>

@property (nonatomic, strong) TTSeachBarView *searchBar;
@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) SSThemedTableView *searchResultTableView;
@property (nonatomic, strong) SSThemedView *maskView;

@property (nonatomic, assign) BOOL hasMore; // 请求是否hasMore
@property (nonatomic, strong) NSNumber *offset;
@property (nonatomic, strong) NSArray <FRPublishPostSearchHashtagStructModel *> *recentHashtags;
@property (nonatomic, strong) NSArray <FRPublishPostSearchHashtagStructModel *> *hotHashtags;

@property (nonatomic, assign) TTUGCSearchHashtagViewControllerState state; // 是否处于搜索请求结果

@property (nonatomic, assign) BOOL hasMoreSearchResult; // 请求是否hasMore
@property (nonatomic, strong) NSNumber *searchResultOffset;
@property (nonatomic, strong) NSArray <FRPublishPostSearchHashtagStructModel *> *searchResultSuggestHashtags;
@property (nonatomic, copy) NSString *searchingWord;

@property (nonatomic, strong) NSError *searchError;
@property (nonatomic, strong) NSError *searchResultError;

@end

@implementation TTUGCSearchHashtagViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        StrongSelf;

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

        self.searchError = nil;
        self.offset = model.data.offset;
        self.hasMore = model.data.has_more;

        if (!self.recentHashtags) {
            self.recentHashtags = model.data.recently;
        }

        if (!self.hotHashtags) {
            self.hotHashtags = [NSArray array];
        }

        NSMutableArray *hotHashtags = [self.hotHashtags mutableCopy];
        if (model.data.hot) {
            [hotHashtags addObjectsFromArray:model.data.hot];
        }
        self.hotHashtags = [hotHashtags copy];

        self.tableView.hasMore = model.data.has_more;
        self.tableView.pullUpView.enabled = YES;
        [self.tableView reloadData];

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

    // 去掉搜索结果页的 loading 效果，避免无结果情况下闪烁问题
//    if (!loadMore && (!self.searchResultSuggestHashtags)) {
//        [self tt_startUpdate];
//    }

    WeakSelf;
    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
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

                [self.searchResultTableView reloadData];

                [self tt_endUpdataData:NO error:error];
            } else { // loadMore
                self.searchResultError = nil;
                [self.searchResultTableView finishPullUpWithSuccess:NO];
            };

            return;
        }

        // 检索数据为空时，展现用户数据
        if (!loadMore && model.data.suggest.count == 0) {
            self.ttViewType = TTFullScreenErrorViewTypeEmpty;
            [self.searchResultTableView reloadData];
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
        if (model.data.suggest) {
            [searchResultSuggestHashtags addObjectsFromArray:model.data.suggest];
        }
        self.searchResultSuggestHashtags = [searchResultSuggestHashtags copy];

        self.searchResultTableView.hasMore = model.data.has_more;
        self.searchResultTableView.pullUpView.enabled = YES;
        [self.searchResultTableView reloadData];

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

    [self.searchResultTableView reloadData];

    [self.view addSubview:self.searchResultTableView];
}

- (void)hideSearchResultTableView {
    self.state = TTUGCSearchingState;

    self.searchingWord = nil;
    self.searchResultSuggestHashtags = nil;

    [self.searchResultTableView reloadData];

    [self.searchResultTableView removeFromSuperview];

    if (self.searchError) {
        self.ttTargetView = self.tableView;
        [self tt_endUpdataData:NO error:self.searchError];
    }
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

- (BOOL)searchBarShouldBeginEditing:(TTSeachBarView *)searchBar {
    [TTTrackerWrapper eventV3:@"search_bar_click" params:nil];

    [self searchBarBecomeActive];

    return YES;
}

- (void)searchBar:(TTSeachBarView *)searchBar textDidChange:(NSString *)searchText {
    if (isEmptyString(searchText)) {
        [self hideSearchResultTableView];

        return;
    }

    if (self.state == TTUGCSearchingState) {
        [self showSearchResultTableView];
    }

    [self loadRequestSearchResult:NO];
}

- (void)searchBarSearchButtonClicked:(TTSeachBarView *)searchBar {
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

- (void)searchBarCancelButtonClicked:(TTSeachBarView *)searchBar {
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }

    CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;

    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.searchBar.top = topInset;
        self.tableView.top = self.searchBar.bottom;
        self.tableView.height = self.view.height - self.searchBar.bottom;
        self.searchBar.showsCancelButton = NO;
        self.searchBar.contentView.width += self.searchBar.cancelButton.width;
        self.searchBar.cancelButton.left += self.searchBar.cancelButton.width;
        self.searchBar.backgroundColorThemeKey = kColorBackground3;
        self.searchBar.inputBackgroundView.backgroundColorThemeKey = kColorBackground4;
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

- (NSString *)titleForHeaderInSection:(NSInteger)section forState:(TTUGCSearchHashtagViewControllerState)state {
    if (state == TTUGCSearchResultState) {
        if (section == 0) {
            return nil;
        }
    } else if (state == TTUGCSearchState || state == TTUGCSearchingState) {
        if (section == 0) {
            return @"最近使用";
        } else if (section == 1) {
            return @"热门话题";
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.state == TTUGCSearchResultState) {
        return 1;
    } else if (self.state == TTUGCSearchState || self.state == TTUGCSearchingState) {
        return 2;
    }

    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.state == TTUGCSearchResultState) {
        return 0;
    }

    NSArray *dataSource = [self dataSourceInSection:section forState:self.state];

    return dataSource.count > 0 ? 28.f : 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SSThemedView *headerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 28)];
    headerView.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);

    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(15, 0, self.tableView.width - 15, 28)];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    titleLabel.text = [self titleForHeaderInSection:section forState:self.state];

    [headerView addSubview:titleLabel];

    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *dataSource = [self dataSourceInSection:section forState:self.state];

    return dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FRPublishPostSearchHashtagStructModel *hashtagModel;
    NSArray *dataSource = [self dataSourceInSection:indexPath.section forState:self.state];
    if (indexPath.row < dataSource.count) {
        hashtagModel = dataSource[indexPath.row];
    }

    TTUGCSearchHashtagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTUGCSearchHashtagTableViewCell class]) forIndexPath:indexPath];

    NSInteger row = self.state == TTUGCSearchState && indexPath.section == 1 ? indexPath.row + 1 : 0;
    [cell configWithHashtagModel:hashtagModel row:row];

    if (indexPath.section == 0 && indexPath.row == dataSource.count - 1) {
        cell.bottomLineView.hidden = YES;
    } else {
        cell.bottomLineView.hidden = NO;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FRPublishPostSearchHashtagStructModel *hashtagModel;
    NSArray *dataSource = [self dataSourceInSection:indexPath.section forState:self.state];
    if (indexPath.row < dataSource.count) {
        hashtagModel = dataSource[indexPath.row];
    }

    if (hashtagModel) {
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

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - getter and setter

- (TTSeachBarView *)searchBar {
    CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;

    if (!_searchBar) {
        _searchBar = [[TTSeachBarView alloc] initWithFrame:CGRectMake(0, topInset, self.view.width, 44.f)];
        _searchBar.backgroundColorThemeKey = kColorBackground3;
        _searchBar.inputBackgroundView.backgroundColorThemeKey = kColorBackground4;
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.searchField.placeholder = @"搜索话题";
        _searchBar.searchField.placeholderColorThemeKey = kColorText3;
        _searchBar.cancelButton.titleColorThemeKey = kColorText1;
        _searchBar.cancelButton.highlightedTitleColorThemeKey = kColorText1Highlighted;
        _searchBar.delegate = self;
    }

    return _searchBar;
}

- (SSThemedTableView *)tableView {
    CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;

    if (!_tableView) {
        _tableView = [[SSThemedTableView alloc] initWithFrame:CGRectMake(0, topInset + 44, self.view.width, self.view.height - topInset - 44)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColorThemeKey = kColorBackground4;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];
        [_tableView registerClass:[TTUGCSearchHashtagTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTUGCSearchHashtagTableViewCell class])];
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
        [_searchResultTableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];
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
