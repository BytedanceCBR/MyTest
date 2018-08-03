//
//  TTVisitorViewController.m
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import "TTVisitorViewController.h"
#import "TTVisitorModel.h"
#import <TTAccountBusiness.h>
#import "TTVisitorCell.h"
#import "TTVisitorDateCell.h"
#import "ArticleProfileFollowConst.h"

#import "TTNetworkManager.h"
#import "TTVisitorRequestModel.h"
#import "TTVisitorModel.h"
#import "TTFriendModel.h"
#import "TTVisitorHeaderView.h"
#import "TTRelationFooterView.h"



@interface TTVisitorViewController ()
@property (nonatomic, strong) TTVisitorModel *visitorModel;
@property (nonatomic, strong) TTVisitorFormattedModel *formattedModel;
@end

@implementation TTVisitorViewController
- (instancetype)init {
    if ((self = [super init])) {
        self.visitorModel = nil;
        self.relationType = FriendDataListTypeVisitor;
    }
    return self;
}

- (void)dealloc {
    _formattedModel = nil;
    _visitorModel = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    wrapperTrackEvent(@"mine_visitor", @"visitor_pull_refresh");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)rebuildIndexes {
    _formattedModel = [_visitorModel toFormattedModel];
}

- (void)loadRequest {
    [super loadRequest];
    
    TTVisitorRequestModel *requestModel = [TTVisitorRequestModel new];
    if ([self.cursor boolValue]) requestModel.cursor = self.cursor;
    requestModel.count = @(50);
    requestModel.user_id = self.currentFriend.userID ? : [TTAccountManager userID];
    
    __weak typeof(self) wself = self;
    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        __strong typeof(wself) sself = wself;
        
        if ([sself isRefreshing] || !sself.visitorModel) {
            sself.visitorModel = (TTVisitorModel *)responseModel;
        } else {
            [sself.visitorModel appendVisitorModel:(TTVisitorModel *)responseModel];
        }
        
        if(error) {
            if(error.code == TTNetworkErrorCodeNetworkError || error.code == TTNetworkErrorCodeNetworkError){
                sself.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
            } else {
                sself.ttViewType = TTFullScreenErrorViewTypeEmpty;
            }
        } else {
            if (!sself.visitorModel || [sself.visitorModel isHistoryEmpty]) {
                sself.ttViewType = TTFullScreenErrorViewTypeNoVisitor;
            } else if([sself.visitorModel isRecentEmpty]) {
                sself.ttViewType = TTFullScreenErrorViewTypeNoVisitor;
            }
        }
        
        [sself reloadWithError:error];
    }];
}

- (void)finishNetworkResponseWithError:(NSError *)error {
    [super finishNetworkResponseWithError:error];
    if (!error && ![self.visitorModel isHistoryEmpty] && [self.visitorModel isRecentEmpty]) {
        self.ttErrorView.errorMsg.text = NSLocalizedString(@"最近7天还没有人访问过你", nil);
    }
}

- (BOOL)hasMoreData {
    return (_formattedModel.has_more && [_formattedModel.users count] > 0);
}

#pragma mark - UIViewControllerErrorHandler delegate

- (BOOL)tt_hasValidateData {
    return [_formattedModel.users count] > 0;
}

#pragma mark - UITableView helper

- (TTVisitorCell *)reusedCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_formattedModel.users count]) return nil;
    
    TTVisitorFormattedModelItem *aModel = _formattedModel.users[indexPath.row];
    NSString *identifier = @"kTTVisitorDefaultCellIdentifier";
    if (aModel.isFirstVisitorOfDay) {
        identifier = @"kTTVisitorFirstCellIdentifier";
    }
    
    TTVisitorCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell) {
        if (aModel.isFirstVisitorOfDay) {
            cell = [[TTVisitorDateCell alloc] initWithReuseIdentifier:identifier];
        } else {
            cell = [[TTVisitorCell alloc] initWithReuseIdentifier:identifier];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_formattedModel.users count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_formattedModel.users count]) {
        return 0;
    }
    
    if (_formattedModel.users[indexPath.row].isFirstVisitorOfDay) {
        return [TTVisitorDateCell cellHeight];
    }
    return [TTVisitorCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.visitorModel && ![self.visitorModel isHistoryEmpty]) {
        return [TTVisitorHeaderView height];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 && self.visitorModel && ![self.visitorModel isRecentAnonymousEmpty] && !self.hasMoreData) {
        return [TTRelationFooterView height];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_formattedModel.users count]) return [UITableViewCell new];
    
    TTVisitorCell *cell = [self reusedCellInTableView:tableView atIndexPath:indexPath];
    [cell reloadWithVisitorModel:_formattedModel.users[indexPath.row]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.visitorModel && ![self.visitorModel isHistoryEmpty]) {
        TTVisitorHeaderView *aView = (TTVisitorHeaderView *)[tableView headerViewForSection:section];
        if (!aView) {
            aView = [TTVisitorHeaderView new];
        }
        [aView reloadWithAllViews:_formattedModel.visit_count_total latestViews:_formattedModel.visit_count_recent];
        return aView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0 && self.visitorModel && ![self.visitorModel isRecentAnonymousEmpty] && !self.hasMoreData) {
        TTRelationFooterView *footerView = (TTRelationFooterView *)[tableView headerViewForSection:section];
        if (!footerView) {
            footerView = [TTRelationFooterView new];
        }
        
        unsigned long days = 7;
        unsigned long latestViews = _formattedModel.visit_device_count;
        
        if (_formattedModel.visit_count_recent == _formattedModel.visit_device_count) {
            [footerView reloadLabelText:[NSString stringWithFormat:@"最近%ld天有%ld位游客访问过你", (unsigned long)days, (unsigned long)latestViews]];
        } else {
            [footerView reloadLabelText:[NSString stringWithFormat:@"最近%ld天还有%ld位游客也访问过你", (unsigned long)days, (unsigned long)latestViews]];
        }
        
        return footerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= [_formattedModel.users count]) return;
    
    BOOL isFromMe = ([TTAccountManager isLogin] && [self.currentFriend isAccountUser]);
    NSString *fromString = isFromMe ? kFromMyVisitors : kFromOtherVisitors;
    NSString *umengEventlabelPrefix = @"visitors";
    if ([umengEventlabelPrefix length] > 0) {
        wrapperTrackEvent(self.umengEventName, [NSString stringWithFormat:@"%@_profile", umengEventlabelPrefix]);
    }
    
    wrapperTrackEvent(@"mine_visitor", @"enter_visitors_profile");
}

#pragma mark - TTTableRefreshEventPageProtocol

- (NSString *)eventPageKey {
    return @"mine_visitor";
}

#pragma mark - fast to access

- (NSNumber *)cursor {
    return [self isRefreshing] ? @(0) : [_formattedModel cursor]; // 刷新重新加载
}
@end
