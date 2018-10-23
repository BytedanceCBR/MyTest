//
//  TTInterestViewController.m
//  Article
//
//  Created by liuzuopeng on 8/10/16.
//
//

#import "TTInterestViewController.h"
#import "TTInterestCell.h"
#import "SSNavigationBar.h"

#import "TTProfileThemeConstants.h"
#import <TTAccountBusiness.h>
#import "TTInterestNetwork.h"
#import "TTInterestCell.h"
#import "FriendDataManager.h"
#import "SSWebViewController.h"
#import "TTRoute.h"


@interface TTInterestViewController ()
<
TTSocialBaseCellDelegate
>
@property (nonatomic, strong) ArticleFriend *visitingUser; //当前正在访问的用户
@property (nonatomic, strong) TTInterestDataModel *interestModel;
@end

@implementation TTInterestViewController
- (instancetype)initWithUID:(NSString *)uid {
    ArticleFriend *aFriend = nil;
    if (uid) {
        aFriend = [ArticleFriend new];
        aFriend.userID = uid;
    }
    return [self initWithArticleFriend:aFriend];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *param = paramObj.allParams;
        if (param && [param isKindOfClass:[NSDictionary class]]) {
            NSString *uid = param[@"uid"];
            ArticleFriend *aFriend = [ArticleFriend new];
            aFriend.userID = uid;
            _visitingUser = aFriend;
        }
    }
    return self;
}

- (instancetype)initWithArticleFriend:(ArticleFriend *)aFriend {
    if ((self = [self init])) {
        _visitingUser = aFriend;
    }
    return self;
}

- (instancetype)init {
    if ((self = [super init])) {
        _visitingUser = nil;
        self.reloadWhenAppear = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = YES;
    // 以防万一（服务端下发错误），保留显示其他人兴趣
    NSString *navTitle = [_visitingUser isAccountUser] || (!_visitingUser && ![TTAccountManager isLogin]) ? @"我的兴趣" : @"TA的兴趣";
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(navTitle, nil)];
}


#pragma mark - load request

- (void)loadRequest {
    [super loadRequest];
    
    NSString *uid    = [self uid];
    NSNumber *offset = [self offset];
    
    __weak typeof(self) wself = self;
    [TTInterestNetwork getInterestListWithUserID:uid Offset:offset completion:^(TTInterestResponseModel *aModel, NSError *error) {
        __weak typeof(wself) sself = wself;
        if ([sself isRefreshing] || !sself.interestModel) {
            sself.interestModel = aModel.data;
        } else {
            [sself.interestModel appendDataModel:aModel.data];
        }
        
        if (error) {
            sself.ttViewType = TTFullScreenErrorViewTypeEmpty;
        } else if ([sself isMe] && [sself.interestModel.count unsignedIntegerValue] <= 0) {
            sself.ttViewType = TTFullScreenErrorViewTypeNoInterests;
        } else if (![sself isMe] && [sself.interestModel.count unsignedIntegerValue] <= 0){
            sself.ttViewType = TTFullScreenErrorViewTypeOtherNoInterests;
        }
        
        [sself reloadWithError:error];
    }];
}

#pragma mark - override methods

- (BOOL)hasMoreData {
    return _interestModel.has_more;
}

- (BOOL)isMe
{
    // 如果未登陆且currentFriend的userID为nil，也为自己（匿名访问我的关注）
    return [self.visitingUser isAccountUser] || (!self.visitingUser.userID && ![TTAccountManager isLogin]);
}

#pragma mark - TTTableRefreshEventPageProtocol

- (NSString *)eventPageKey {
    return @"interest_page";
}

#pragma mark - UIViewControllerErrorHandler delegate

- (BOOL)tt_hasValidateData {
    return [_interestModel.user_concern_list count] > 0;
}

- (void)emptyViewBtnAction {
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://concern_guide"]];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_interestModel.user_concern_list count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TTInterestCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_interestModel.user_concern_list count]) return [UITableViewCell new];
    
    static NSString *interestCellIdentifier = @"kTTInterestCellIdentifier";
    TTInterestCell *cell = [tableView dequeueReusableCellWithIdentifier:interestCellIdentifier];
    if (!cell) cell = [[TTInterestCell alloc] initWithReuseIdentifier:interestCellIdentifier];
    cell.delegate = self;
    [cell reloadWithModel:_interestModel.user_concern_list[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= [_interestModel.user_concern_list count]) return;
    
    TTInterestItemModel *aModel = _interestModel.user_concern_list[indexPath.row];
    NSURL *url = [TTStringHelper URLWithURLString:[aModel urlString]];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
    
    wrapperTrackEventWithCustomKeys(@"interest_page", @"enter", aModel.concern_id, nil, nil);
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - TTSocialBaseCellDelegate

- (void)socialBaseCell:(TTSocialBaseCell *)cell didTapFollowButton:(id)sender {
    if (![cell isKindOfClass:[TTInterestCell class]]) return;
}

#pragma mark - fast access

- (NSString *)uid {
    return _visitingUser.userID ? : [TTAccountManager userID];
}

- (NSNumber *)offset {
    NSNumber *offsetValue = (!_interestModel || !_interestModel.offset) ? @(0) : _interestModel.offset;
    if ([self isRefreshing]) { // 下拉刷新，重置offset为0
        offsetValue = @(0);
    }
    return offsetValue;
}

- (UITableViewCellSeparatorStyle)tableViewSeparatorStyle {
    return UITableViewCellSeparatorStyleSingleLine;
}

+ (CGFloat)insetRightOfSeparator {
    return [TTDeviceUIUtils tt_padding:30.f/2];
}
@end
