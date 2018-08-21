//
//  TTUGCSearchUserViewController.m
//  Article
//
//  Created by Jiyee Sheng on 05/09/2017.
//
//

#import <TTUIWidget/UIViewController+Refresh_ErrorHandler.h>
#import "TTUGCSearchUserViewController.h"
#import "SSThemed.h"
#import "SSNavigationBar.h"
#import "TTUGCSearchUserTableViewCell.h"
#import "TTNetworkManager.h"
#import "TTSeachBarView.h"
#import "UIScrollView+Refresh.h"
#import "TTUGCSearchUserEmptyView.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTTrackerWrapper.h"
#import "TTDeviceUIUtils.h"

typedef NS_ENUM(NSUInteger, TTUGCSearchUserViewControllerState) {
    TTUGCSearchState,
    TTUGCSearchingState,
    TTUGCSearchResultState,
};


@interface TTUGCSearchUserViewController () <UITableViewDataSource, UITableViewDelegate, UIViewControllerErrorHandler, TTSeachBarViewDelegate>

@property (nonatomic, strong) TTSeachBarView *searchBar;
@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) SSThemedTableView *searchResultTableView;
@property (nonatomic, strong) SSThemedView *maskView;
@property (nonatomic, strong) TTUGCSearchUserEmptyView *emptyView;

@property (nonatomic, assign) BOOL hasMore; // 请求是否hasMore
@property (nonatomic, strong) NSNumber *offset;
@property (nonatomic, strong) NSArray <FRPublishPostSearchUserStructModel *> *recentUsers;
@property (nonatomic, strong) NSArray <FRPublishPostSearchUserStructModel *> *followingUsers;

@property (nonatomic, assign) TTUGCSearchUserViewControllerState state; // 是否处于搜索请求结果

@property (nonatomic, assign) BOOL hasMoreSearchResult; // 请求是否hasMore
@property (nonatomic, strong) NSNumber *searchResultOffset;
@property (nonatomic, strong) NSArray <FRPublishPostSearchUserStructModel *> *searchResultFollowingUsers;
@property (nonatomic, strong) NSArray <FRPublishPostSearchUserStructModel *> *searchResultSuggestUsers;
@property (nonatomic, strong) NSArray <FRPublishPostSearchUserStructModel *> *searchResultInputUsers;
@property (nonatomic, copy) NSString *searchingWord;

@property (nonatomic, strong) NSError *searchError;
@property (nonatomic, strong) NSError *searchResultError;

@end

@implementation TTUGCSearchUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    
     [[UIApplication sharedApplication] setStatusBarHidden:NO];

    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:@"联系人"];
    TTNavigationBarItemContainerView *dismissItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft
                                                                                                                             withTitle:@"取消"
                                                                                                                                target:self
                                                                                                                                action:@selector(dismissAction:)];
    dismissItem.button.titleColorThemeKey = kColorText1;
    dismissItem.button.highlightedTitleColorThemeKey = kColorText1Highlighted;
    dismissItem.button.titleLabel.font = [UIFont systemFontOfSize:16];
    
    if ([TTDeviceHelper is736Screen]) {
        [dismissItem.button setTitleEdgeInsets:UIEdgeInsetsMake(0, -4.3, 0, 4.3)];
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
    [self.tableView tt_addDefaultPullUpLoadMoreWithHandler:^{
        StrongSelf;
        [self triggerLoadMore];
    }];

    self.tableView.pullUpView.enabled = NO;

    // 搜索结果允许上拉刷新
    [self.searchResultTableView tt_addDefaultPullUpLoadMoreWithHandler:^{
        StrongSelf;
        [self triggerLoadMoreSearchResult];
    }];

    self.searchResultTableView.pullUpView.enabled = NO;

    [self loadRequest];
}

- (void)loadRequest {
    FRUgcPublishPostV1ContactRequestModel *requestModel = [[FRUgcPublishPostV1ContactRequestModel alloc] init];
    requestModel.offset = self.offset;

    self.ttTargetView = self.tableView;

    if (self.offset.integerValue == 0) { // 首次请求
        [self tt_startUpdate];
    }

    WeakSelf;
    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        StrongSelf;

        FRUgcPublishPostV1ContactResponseModel *model = (FRUgcPublishPostV1ContactResponseModel *) responseModel;

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

        if (!self.recentUsers) {
            self.recentUsers = model.data.recently;
        }

        if (!self.followingUsers) {
            self.followingUsers = [NSArray array];
        }

        NSMutableArray *followingUsers = [self.followingUsers mutableCopy];
        if (model.data.following) {
            [followingUsers addObjectsFromArray:model.data.following];
        }
        self.followingUsers = [followingUsers copy];

        self.tableView.hasMore = model.data.has_more;
        self.tableView.pullUpView.enabled = YES;
        [self.tableView reloadData];

        [self tt_endUpdataData:NO error:error];

        // 检索完成之后的检查不用判断只用判断数据
        if (!self.tt_hasValidateData) {
            self.searchBar.searchField.placeholder = @"搜索你想@的人";

            // 因为 tableView 流程终止了，通过直接手动添加的方式
            // 由于涉及 ttErrorView 变量的共用，为了避免更多问题，这里不采用 ttErrorView 方式添加
            [self.tableView addSubview:self.emptyView];
        } else {
            self.searchBar.searchField.placeholder = @"搜索";
        }
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

    FRUgcPublishPostV1SuggestRequestModel *requestModel = [[FRUgcPublishPostV1SuggestRequestModel alloc] init];
    requestModel.words = self.searchingWord;
    requestModel.offset = loadMore ? self.searchResultOffset : @0;

    self.ttTargetView = self.searchResultTableView;

    if (!loadMore && (!self.searchResultFollowingUsers && !self.searchResultSuggestUsers && !self.searchResultInputUsers)) {
        [self tt_startUpdate];
    }

    WeakSelf;
    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        StrongSelf;

        if (!loadMore) {
            self.searchResultFollowingUsers = nil;
            self.searchResultSuggestUsers = nil;
            self.searchResultInputUsers = nil;
        }

        FRUgcPublishPostV1SuggestResponseModel *model = (FRUgcPublishPostV1SuggestResponseModel *) responseModel;

        if (error || model.err_no.integerValue > 0) {
            if (!loadMore) { // 首次请求
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
        if (!loadMore && model.data.following.count == 0 && model.data.suggest.count == 0) {
            self.searchResultTableView.hasMore = NO;
            self.searchResultTableView.pullUpView.enabled = NO;

            FRPublishPostSearchUserStructModel *inputUserModel = [[FRPublishPostSearchUserStructModel alloc] init];
            FRPublishPostUserStructModel *userModel = [[FRPublishPostUserStructModel alloc] init];
            FRPublishPostUserInfoStructModel *userInfoModel = [[FRPublishPostUserInfoStructModel alloc] init];
            userInfoModel.name = self.searchBar.text;
            userModel.info = userInfoModel;
            inputUserModel.user = userModel;

            self.searchResultFollowingUsers = nil;
            self.searchResultSuggestUsers = nil;
            self.searchResultInputUsers = @[inputUserModel];
            [self.searchResultTableView reloadData];

            [self tt_endUpdataData:NO error:error];

            return;
        }

        self.searchResultError = nil;
        self.searchResultOffset = model.data.offset;
        self.hasMoreSearchResult = model.data.has_more;

        if (!self.searchResultFollowingUsers) {
            self.searchResultFollowingUsers = model.data.following;
        }

        if (!self.searchResultSuggestUsers) {
            self.searchResultSuggestUsers = [NSArray array];
        }

        NSMutableArray *searchResultSuggestUsers = [self.searchResultSuggestUsers mutableCopy];
        if (model.data.suggest) {
            [searchResultSuggestUsers addObjectsFromArray:model.data.suggest];
        }
        self.searchResultSuggestUsers = [searchResultSuggestUsers copy];

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

    if (self.delegate && [self.delegate respondsToSelector:@selector(searchUserTableViewWillDismiss)]) {
        [self.delegate searchUserTableViewWillDismiss];
    }

    WeakSelf;
    [self dismissViewControllerAnimated:YES completion:^{
        StrongSelf;
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchUserTableViewDidDismiss)]) {
            [self.delegate searchUserTableViewDidDismiss];
        }
    }];
}

- (void)swipeAction:(id)sender {
    [self searchBarCancelButtonClicked:self.searchBar];
}

- (void)showSearchResultTableView {
    self.state = TTUGCSearchResultState;

    self.searchResultFollowingUsers = nil;
    self.searchResultSuggestUsers = nil;
    self.searchResultInputUsers = nil;

    [self.searchResultTableView reloadData];

    [self.view addSubview:self.searchResultTableView];
}

- (void)hideSearchResultTableView {
    self.state = TTUGCSearchingState;

    self.searchingWord = nil;
    self.searchResultFollowingUsers = nil;
    self.searchResultSuggestUsers = nil;
    self.searchResultInputUsers = nil;

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

- (NSArray *)dataSourceInSection:(NSInteger)section forState:(TTUGCSearchUserViewControllerState)state {
    if (state == TTUGCSearchResultState) {
        if (section == 0) {
            return self.searchResultFollowingUsers;
        } else if (section == 1) {
            return self.searchResultSuggestUsers;
        } else if (section == 2) {
            return self.searchResultInputUsers;
        }
    } else if (state == TTUGCSearchState || state == TTUGCSearchingState) {
        if (section == 0) {
            return self.recentUsers;
        } else if (section == 1) {
            return self.followingUsers;
        }
    }

    return nil;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section forState:(TTUGCSearchUserViewControllerState)state {
    if (state == TTUGCSearchResultState) {
        if (section == 0) {
            return @"我的关注";
        } else if (section == 1) {
            return @"网络搜索结果";
        } else if (section == 2) {
            return nil;
        }
    } else if (state == TTUGCSearchState || state == TTUGCSearchingState) {
        if (section == 0) {
            return @"最近联系人";
        } else if (section == 1) {
            return @"我的关注";
        }
    }

    return nil;
}

- (NSString *)trackEventProfileTypeInSection:(NSInteger)section forState:(TTUGCSearchUserViewControllerState)state {
    if (state == TTUGCSearchResultState) {
        if (section == 0) {
            return @"following";
        } else if (section == 1) {
            return @"suggest";
        } else if (section == 2) {
            return @"suggest_none";
        }
    } else if (state == TTUGCSearchState || state == TTUGCSearchingState) {
        if (section == 0) {
            return @"recently";
        } else if (section == 1) {
            return @"following";
        }
    }

    return nil;
}

- (NSString *)trackEventPageTypeInSection:(NSInteger)section forState:(TTUGCSearchUserViewControllerState)state {
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
        return 3;
    } else if (self.state == TTUGCSearchState || self.state == TTUGCSearchingState) {
        return 2;
    }

    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.state == TTUGCSearchResultState && section == 2) {
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
    if (self.state == TTUGCSearchResultState && indexPath.section == 2) {
        return 46;
    }

    return 74.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FRPublishPostSearchUserStructModel *userModel;
    NSArray *dataSource = [self dataSourceInSection:indexPath.section forState:self.state];
    if (indexPath.row < dataSource.count) {
        userModel = dataSource[indexPath.row];
    }

    if (self.state == TTUGCSearchResultState && indexPath.section == 2) {
        SSThemedTableViewCell *cell = [[SSThemedTableViewCell alloc] init];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.text = [NSString stringWithFormat:@"@%@ ", userModel.user.info.name];
        cell.textLabel.textColor = SSGetThemedColorWithKey(kColorText1);

        SSThemedImageView *arrowView = [[SSThemedImageView alloc] init];
        arrowView.imageName = @"setting_arrow";
        [cell.contentView addSubview:arrowView];

        SSThemedView *bottomLineView = [[SSThemedView alloc] init];
        bottomLineView.backgroundColorThemeKey = kColorLine1;
        [cell.contentView addSubview:bottomLineView];

        arrowView.width = [TTDeviceUIUtils tt_newPadding:9];
        arrowView.height = [TTDeviceUIUtils tt_newPadding:14];
        arrowView.left = tableView.width - arrowView.width - [TTDeviceUIUtils tt_newPadding:15];
        arrowView.top = (cell.height - arrowView.height) / 2;

        bottomLineView.left = 15.f;
        bottomLineView.width = tableView.width - 15.f;
        bottomLineView.height = [TTDeviceHelper ssOnePixel];
        bottomLineView.bottom = 45.f;

        return cell;
    }

    TTUGCSearchUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTUGCSearchUserTableViewCell class]) forIndexPath:indexPath];
    [cell configWithUserModel:userModel];

    if (indexPath.section == 0 && indexPath.row == dataSource.count - 1) {
        cell.bottomLineView.hidden = YES;
    } else {
        cell.bottomLineView.hidden = NO;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FRPublishPostSearchUserStructModel *userModel;
    NSArray *dataSource = [self dataSourceInSection:indexPath.section forState:self.state];
    if (indexPath.row < dataSource.count) {
        userModel = dataSource[indexPath.row];
    }

    if (userModel) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchUserTableViewDidSelectedUser:)]) {
            [self.delegate searchUserTableViewDidSelectedUser:userModel];
        }

        [self dismissAction:nil];
    }

    NSString *trackEventProfileType = [self trackEventProfileTypeInSection:indexPath.section forState:self.state];
    NSString *trackEventPageType = [self trackEventPageTypeInSection:indexPath.section forState:self.state];

    [TTTrackerWrapper eventV3:@"choose_at_profile" params:@{
        @"page_type" : trackEventPageType ?: @"",
        @"profile_type" : trackEventProfileType ?: @"",
    }];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - getter and setter

- (TTSeachBarView *)searchBar {
    if (!_searchBar) {
        CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;

        _searchBar = [[TTSeachBarView alloc] initWithFrame:CGRectMake(0, topInset, self.view.width, 44.f)];
        _searchBar.backgroundColorThemeKey = kColorBackground3;
        _searchBar.inputBackgroundView.backgroundColorThemeKey = kColorBackground4;
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _searchBar.searchField.placeholder = @"搜索";
        _searchBar.searchField.placeholderColorThemeKey = kColorText3;
        _searchBar.cancelButton.titleColorThemeKey = kColorText1;
        _searchBar.cancelButton.highlightedTitleColorThemeKey = kColorText1Highlighted;
        _searchBar.delegate = self;
    }

    return _searchBar;
}

- (SSThemedTableView *)tableView {
    if (!_tableView) {
        CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;

        _tableView = [[SSThemedTableView alloc] initWithFrame:CGRectMake(0, topInset + 44, self.view.width, self.view.height - topInset - 44)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColorThemeKey = kColorBackground4;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];
        [_tableView registerClass:[TTUGCSearchUserTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTUGCSearchUserTableViewCell class])];
    }

    return _tableView;
}

- (SSThemedTableView *)searchResultTableView {
    if (!_searchResultTableView) {
        CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;

        _searchResultTableView = [[SSThemedTableView alloc] initWithFrame:CGRectMake(0, topInset, self.view.width, self.view.height - topInset)];
        _searchResultTableView.delegate = self;
        _searchResultTableView.dataSource = self;
        _searchResultTableView.backgroundColorThemeKey = kColorBackground4;
        _searchResultTableView.backgroundView = nil;
        _searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchResultTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _searchResultTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_searchResultTableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];
        [_searchResultTableView registerClass:[TTUGCSearchUserTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTUGCSearchUserTableViewCell class])];
    }

    return _searchResultTableView;
}

- (SSThemedView *)maskView {
    if (!_maskView) {
        CGFloat topInset = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;

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

- (TTUGCSearchUserEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[TTUGCSearchUserEmptyView alloc] initWithFrame:CGRectMake(0, 44, self.tableView.width, self.tableView.height - 44)];
    }

    return _emptyView;
}


@end
