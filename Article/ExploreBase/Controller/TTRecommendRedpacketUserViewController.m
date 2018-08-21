//
//  TTRecommendRedpacketUserViewController.m
//  Article
//
//  Created by lipeilun on 2017/10/26.
//

#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTAccountLogin/TTAccountLoginManager.h>
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTNetworkManager/TTNetworkUtil.h>
#import <TTImpression/SSImpressionManager.h>
#import "TTRecommendRedpacketUserViewController.h"
#import "TTContactsRecommendUserTableViewCell.h"
#import "SSNavigationBar.h"
#import "TTRecommendRedpacketAction.h"
#import "RecommendRedpacketData.h"
#import "TTContactsRedPacketManager.h"
#import "ExploreOrderedData+TTBusiness.h"


@interface TTRecommendRedpacketUserViewController () <UITableViewDelegate, UITableViewDataSource, TTContactsRecommendUserTableViewCellDelegate, SSImpressionProtocol>

@property (nonatomic, strong) SSThemedView *navigationBar;
@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *buttonFormat;
@property (nonatomic, strong) SSThemedButton *followButton;
@property (nonatomic, strong) SSThemedView *followBackView;
@property (nonatomic, assign) BOOL hasOpenedRedPacket;

@end

@implementation TTRecommendRedpacketUserViewController

- (instancetype)initWithRelatedUsers:(NSArray *)userArray title:(NSString *)title buttonFormat:(NSString *)buttonFormat {
    if (self = [super init]) {
        self.dataSource = userArray;
        self.titleText = !isEmptyString(title) ? title : @"在爱看的好友";
        self.buttonFormat = !isEmptyString(buttonFormat) ? buttonFormat : @"关注%ld人并领取红包";
    }
    return self;
}

- (void)viewDidLoad {  
    [super viewDidLoad];
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:self.titleText];

    TTAlphaThemedButton *closeButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(12, 0, 56, 44)];
    closeButton.backgroundColor = [UIColor clearColor];
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    closeButton.imageName = @"titlebar_close";
    [closeButton sizeToFit];
    [closeButton setHitTestEdgeInsets:UIEdgeInsetsMake(-12, -20, -12, -20)];
    [closeButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.followButton];
    
    self.followBackView = [SSThemedView new];
    self.followBackView.backgroundColorThemeKey = kColorBackground4;
    self.followBackView.frame = self.followButton.frame;
    [self.view insertSubview:self.followBackView belowSubview:self.followButton];
    
//    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.tableView.frame = self.view.bounds;
    [self refreshFollowButtonUI];
    [self.tableView reloadData];

    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - self.view.tt_safeAreaInsets.bottom);
    self.followButton.frame = CGRectMake(0, self.view.height - self.view.tt_safeAreaInsets.bottom - 44, self.view.width, 44);
    self.followBackView.frame = CGRectMake(0, self.view.height - self.view.tt_safeAreaInsets.bottom - 44, self.view.width, 44 + self.view.tt_safeAreaInsets.bottom);

    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.followButton.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
        self.followButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        self.followButton.layer.cornerRadius = 4.f;
        self.followButton.frame = CGRectMake(15, self.view.height - self.view.tt_safeAreaInsets.bottom - 44, self.view.width - 30, 44);
        self.followBackView.frame = CGRectMake(0, self.view.height - self.view.tt_safeAreaInsets.bottom - 44 - 10, self.view.width, 44 + self.view.tt_safeAreaInsets.bottom + 10);
    }

    [[SSImpressionManager shareInstance] addRegist:self];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];

    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - self.view.tt_safeAreaInsets.bottom);
    self.followButton.frame = CGRectMake(0, self.view.height - self.view.tt_safeAreaInsets.bottom - 44, self.view.width, 44);
    self.followBackView.frame = CGRectMake(0, self.view.height - self.view.tt_safeAreaInsets.bottom - 44, self.view.width, 44 + self.view.tt_safeAreaInsets.bottom);

    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.followButton.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
        self.followButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        self.followButton.layer.cornerRadius = 4.f;
        self.followButton.frame = CGRectMake(15, self.view.height - self.view.tt_safeAreaInsets.bottom - 44, self.view.width - 30, 44);
        self.followBackView.frame = CGRectMake(0, self.view.height - self.view.tt_safeAreaInsets.bottom - 44 - 10, self.view.width, 44 + self.view.tt_safeAreaInsets.bottom + 10);
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SSImpressionManager shareInstance] removeRegist:self];
}

- (void)dismissSelf {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"close" forKey:@"action_type"];
    [dict setValue:self.recommendType forKey:@"recommend_type"];
    [dict setValue:self.categoryName forKey:@"category_name"];
    [dict setValue:@"all_follow_card" forKey:@"card_type"];
    [dict setValue:@(self.recommendRedpacketData.numberOfAvatars) forKey:@"head_image_num"];
    [dict setValue:@(self.recommendRedpacketData.hasRedPacket) forKey:@"is_redpacket"];
    [dict setValue:self.recommendRedpacketData.relationTypeValue forKey:@"relation_type"];
    [TTTrackerWrapper eventV3:@"vert_follow_card" params:dict];
    
    [super dismissSelf];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[SSImpressionManager shareInstance] enterMessageNotificationList];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[SSImpressionManager shareInstance] leaveMessageNotificationList];

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.dismissBlock) {
        NSMutableSet *mset = [NSMutableSet set];
        for (TTRecommendUserModel *model in self.dataSource) {
            if (![mset containsObject:model.user_id] && model.selected) {
                [mset addObject:model.user_id];
            }
        }
        
        if (!self.hasOpenedRedPacket) {
            self.dismissBlock(mset.copy);
        }
    }
    self.hasOpenedRedPacket = NO;
}

- (void)needRerecordImpressions {
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.row < self.dataSource.count) {
            TTRecommendUserModel *userModel = self.dataSource[indexPath.row];
            if (!isEmptyString(userModel.user_id)) {
                NSMutableDictionary *extra = @{}.mutableCopy;
                [extra setValue:@"all_follow_card_list" forKey:@"source"];
                [extra setValue:@{@"select_status" : userModel.selected ? @1 : @0, @"default_select_status" : indexPath.row < self.recommendRedpacketData.numberOfUsersSelected ? @1 : @0} forKey:@"modelExtra"];
                [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:userModel.user_id
                                                                                categoryName:self.categoryName
                                                                                      cellId:[NSString stringWithFormat:@"list_%@", @(self.recommendRedpacketData.uniqueID).stringValue]
                                                                                      status:SSImpressionStatusRecording
                                                                                       extra:extra.copy];
            }
        }
    }
}

- (void)refreshFollowButtonUI {
    NSInteger followCount = 0;
    for (TTRecommendUserModel *userModel in self.dataSource) {
        if (userModel.selected && !isEmptyString(userModel.user_id)) {
            followCount++;
        }
    }
    
    BOOL enabled = followCount > 0;
    BOOL dayMode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    if (enabled) {
        if (dayMode) {
            self.followButton.backgroundColor = [UIColor colorWithHexString:@"F85959"];
        } else {
            self.followButton.backgroundColor = [UIColor colorWithHexString:@"935656"];
        }
    } else {
        //待修改
        if (dayMode) {
            self.followButton.backgroundColor = [[UIColor colorWithHexString:@"F85959"] colorWithAlphaComponent:0.5];
        } else {
            self.followButton.backgroundColor = [[UIColor colorWithHexString:@"935656"] colorWithAlphaComponent:0.5];
        }
    }
    [self.followButton setTitle:[NSString stringWithFormat:self.buttonFormat, followCount] forState:UIControlStateNormal];
}

- (void)onClickFollowButton:(id)sender {
    NSMutableArray *userIds = [[NSMutableArray alloc] init];

    NSMutableArray *selectedUsers = [NSMutableArray array];
    for (TTRecommendUserModel *model in self.dataSource) {
        if (model.selected) {
            [selectedUsers addObject:model];
            [userIds addObject:model.user_id];
        }
    }
    
    if (selectedUsers.count == 0) {
        return;
    }

    self.hasOpenedRedPacket = YES;

    NSMutableDictionary *extraParams = [NSMutableDictionary dictionary];
    [extraParams setValue:@(self.recommendRedpacketData.numberOfAvatars) forKey:@"head_image_num"];
    [extraParams setValue:@(self.recommendRedpacketData.hasRedPacket) forKey:@"is_redpacket"];
    [extraParams setValue:@(self.recommendRedpacketData.relationType) forKey:@"rel_type"];
    [extraParams setValue:self.recommendRedpacketData.relationTypeValue forKey:@"relation_type"];
    [extraParams setValue:self.recommendRedpacketData.userDataList.count > 0 ? [[self.recommendRedpacketData.userDataList[0] recommend_type] stringValue] : @"0" forKey:@"recommend_type"];
    if (self.recommendRedpacketData.redpacketInfo) {
        [extraParams addEntriesFromDictionary:self.recommendRedpacketData.redpacketInfo];

        if (self.recommendRedpacketData.isAuth || [TTAccountManager isLogin]) {
            [extraParams setValue:self.action.orderedData.categoryID forKey:@"category_name"];
            [extraParams setValue:![self.action.orderedData.categoryID isEqualToString:kMainCategoryAPINameKey] ? @"click_category" : @"click_headline" forKey:@"enter_from"];
            [extraParams setValue:self.action.orderedData.logPb forKey:@"log_pb"];

            [self.action multiFollowSelectedUsers:selectedUsers
                                      extraParams:extraParams
                               fromViewController:self
                                  completionBlock:^(BOOL completed, TTRedPacketDetailBaseViewModel *viewModel, NSArray <TTRecommendUserModel *> *contactUsers) {
                                      [[TTContactsRedPacketManager sharedManager] presentInViewController:[TTUIResponderHelper topmostViewController]
                                                                                             contactUsers:contactUsers
                                                                                                     type:TTContactsRedPacketViewControllerTypeRecommendRedpacket
                                                                                                viewModel:viewModel
                                                                                              extraParams:[extraParams copy]
                                                                                                 needPush:NO];
                                  }];

        } else {
            [[TTContactsRedPacketManager sharedManager] presentInViewController:self
                                                                   contactUsers:selectedUsers
                                                                           type:TTContactsRedPacketViewControllerTypeRecommendRedpacketNoLogin
                                                                      viewModel:nil
                                                                    extraParams:[extraParams copy]
                                                                       needPush:YES];
}
    } else {
        [self.action multiFollowSelectedUsers:selectedUsers extraParams:extraParams fromViewController:self completionBlock:nil];
    }
}

#pragma mark - TTContactsRecommendUserTableViewCellDelegate

- (void)addFriendsTableViewCell:(TTContactsRecommendUserTableViewCell *)cell didSelectedUser:(BOOL)selected {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TTRecommendUserModel *userModel = self.dataSource[indexPath.row];
    userModel.selected = selected;

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:selected ? @"select" : @"unselect" forKey:@"action_type"];
    [dict setValue:@(indexPath.row + 1) forKey:@"order"];
    [dict setValue:userModel.user_id forKey:@"to_user_id"];
    [dict setValue:self.categoryName forKey:@"category_name"];
    [dict setValue:self.recommendType forKey:@"recommend_type"];
    [dict setValue:@"all_follow_card" forKey:@"card_type"];
    [dict setValue:@(self.recommendRedpacketData.numberOfAvatars) forKey:@"head_image_num"];
    [dict setValue:@(self.recommendRedpacketData.hasRedPacket) forKey:@"is_redpacket"];
    [dict setValue:self.recommendRedpacketData.relationTypeValue forKey:@"relation_type"];
    [TTTrackerWrapper eventV3:@"vert_follow_card" params:dict];
    
    [self refreshFollowButtonUI];
}

- (void)addFriendsTableViewCell:(TTContactsRecommendUserTableViewCell *)cell didUserProfile:(NSString *)userID {
    if (!isEmptyString(userID)) {
        NSString *schema = [NSString stringWithFormat:@"sslocal://profile?uid=%@", userID];
        [[TTRoute sharedRoute] openURLByPushViewController:[TTNetworkUtil URLWithURLString:schema]];
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTContactsRecommendUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTContactsRecommendUserTableViewCell class]) forIndexPath:indexPath];

    cell.delegate = self;

    TTRecommendUserModel *userModel = self.dataSource[indexPath.row];
    userModel.selectable = YES;
    userModel.userProfileEnabled = YES;
    [cell configWithUserModel:userModel];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TTContactsRecommendUserTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell onChange:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.count) {
        TTRecommendUserModel *userModel = self.dataSource[indexPath.row];
        if (!isEmptyString(userModel.user_id)) {
            NSMutableDictionary *extra = @{}.mutableCopy;
            [extra setValue:@"all_follow_card_list" forKey:@"source"];
            [extra setValue:@{@"select_status" : userModel.selected ? @1 : @0, @"default_select_status" : indexPath.row < self.recommendRedpacketData.numberOfUsersSelected ? @1 : @0} forKey:@"modelExtra"];
            [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:userModel.user_id
                                                                            categoryName:self.categoryName
                                                                                  cellId:[NSString stringWithFormat:@"list_%@", @(self.recommendRedpacketData.uniqueID).stringValue]
                                                                                  status:SSImpressionStatusRecording
                                                                                   extra:extra.copy];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.count) {
        TTRecommendUserModel *userModel = self.dataSource[indexPath.row];
        if (!isEmptyString(userModel.user_id)) {
            NSMutableDictionary *extra = @{}.mutableCopy;
            [extra setValue:@"all_follow_card_list" forKey:@"source"];
            [extra setValue:@{@"select_status" : userModel.selected ? @1 : @0, @"default_select_status" : indexPath.row < self.recommendRedpacketData.numberOfUsersSelected ? @1 : @0} forKey:@"modelExtra"];
            [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:userModel.user_id
                                                                            categoryName:self.categoryName
                                                                                  cellId:[NSString stringWithFormat:@"list_%@", @(self.recommendRedpacketData.uniqueID).stringValue]
                                                                                  status:SSImpressionStatusEnd
                                                                                   extra:extra.copy];
        }
    }
}

#pragma mark - getter and setter

- (SSThemedTableView *)tableView {
    if (!_tableView) {
        _tableView = [[SSThemedTableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColorThemeKey = kColorBackground4;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_tableView registerClass:[TTContactsRecommendUserTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTContactsRecommendUserTableViewCell class])];
    }
    
    return _tableView;
}

- (SSThemedButton *)followButton {
    if (!_followButton) {
        _followButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, self.view.height - 44, SSScreenWidth, 44)];
        _followButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _followButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        [_followButton addTarget:self action:@selector(onClickFollowButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followButton;
}

@end
