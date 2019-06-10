//
//  TTAddFriendsViewController.m
//  Article
//
//  Created by Jiyee Sheng on 6/9/17.
//
//

#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTUIWidget/UIView+CustomTimingFunction.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import "SSAvatarView.h"
#import "TTVerifyIconHelper.h"
#import "SSAvatarView+VerifyIcon.h"
#import "TTFollowNotifyServer.h"
#import "TTColorAsFollowButton.h"
#import "TTContactsAddFriendsViewController.h"
#import "TTContactsUserDefaults.h"
#import "TTFollowThemeButton.h"
#import "NetworkUtilities.h"
#import "TTIndicatorView.h"
#import "TTFollowManager.h"
#import "FriendDataManager.h"
#import "TTContactsGuideManager.h"


@interface TTContactsAddFriendModel : NSObject

@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *screen_name;
@property (strong, nonatomic) NSString *avatar_url;
@property (strong, nonatomic) NSString *user_auth_info;
@property (strong, nonatomic) NSString *recommend_reason;
@property (strong, nonatomic) NSNumber *is_following;

- (instancetype)initWithFRUserRelationContactFriendsUserStructModel:(FRUserRelationContactFriendsUserStructModel *)model;

@end

@implementation TTContactsAddFriendModel

- (instancetype)initWithFRUserRelationContactFriendsUserStructModel:(FRUserRelationContactFriendsUserStructModel *)model {
    self = [super init];
    if (self) {
        self.user_id = model.user_id;
        self.screen_name = model.screen_name;
        self.avatar_url = model.avatar_url;
        self.user_auth_info = model.user_auth_info;
        self.recommend_reason = model.recommend_reason;
        self.is_following = model.is_following;
    }
    
    return self;
}

@end

@class TTContactsAddFriendsTableViewCell;

@protocol TTContactsAddFriendsTableViewCellDelegate <NSObject>

- (void)didChangeFollowingOfCell:(TTContactsAddFriendsTableViewCell *)cell;

@end

@interface TTContactsAddFriendsTableViewCell : SSThemedTableViewCell

@property (nonatomic, weak) id <TTContactsAddFriendsTableViewCellDelegate> delegate;

@property (nonatomic, strong) SSAvatarView *avatarView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) TTFollowThemeButton *followButton;
@property (nonatomic, strong) SSThemedView *bottomLineView;

- (void)configWithFriendModel:(TTContactsAddFriendModel *)friendModel;

@end

@implementation TTContactsAddFriendsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.followButton];
        [self addSubview:self.bottomLineView];
        
        self.avatarView.left = 15.f;
        self.avatarView.top = 15.f;
        
        [self.nameLabel sizeToFit];
        self.nameLabel.left = self.avatarView.right + 10.f;
        self.nameLabel.top = 15.f;
        self.nameLabel.height = 24.f;
        
        [self.descLabel sizeToFit];
        self.descLabel.left = self.nameLabel.left;
        self.descLabel.bottom = self.avatarView.bottom + 1;
        
        self.followButton.right = self.width - 15;
        self.followButton.centerY = self.avatarView.centerY;
        
        self.bottomLineView.width = self.width;
        self.bottomLineView.height = [TTDeviceHelper ssOnePixel];
        self.bottomLineView.bottom = self.height - 1;
        
        [self themeChanged:nil];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.nameLabel sizeToFit];
    [self.descLabel sizeToFit];
    
    CGFloat maxWidth = self.width - 15 - 44 - 10 - 58 - 30;
    
    self.nameLabel.top = 15.f;
    self.nameLabel.width = MIN(self.nameLabel.width, maxWidth);
    
    self.descLabel.width = MIN(self.descLabel.width, maxWidth);
    self.descLabel.bottom = self.avatarView.bottom + 1;
    
    self.followButton.right = self.width - 15;
    
    self.bottomLineView.width = self.width;
    self.bottomLineView.bottom = self.height - 1;
}

- (void)followAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeFollowingOfCell:)]) {
        [self.delegate didChangeFollowingOfCell:self];
    }
}

- (void)configWithFriendModel:(TTContactsAddFriendModel *)friendModel {
    [self.avatarView showAvatarByURL:friendModel.avatar_url];
    NSString *userAuthInfo = friendModel.user_auth_info;
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];

    self.nameLabel.text = friendModel.screen_name;
    self.descLabel.text = friendModel.recommend_reason;
    
    self.followButton.followed = friendModel.is_following.boolValue;
}

- (SSAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[SSAvatarView alloc] initWithFrame:CGRectMake(0, 0, 44.f, 44.f)];
        _avatarView.avatarImgPadding = 0;
        _avatarView.avatarButton.userInteractionEnabled = NO;
        _avatarView.avatarStyle = SSAvatarViewStyleRound;
        [_avatarView setupVerifyViewForLength:50.f adaptationSizeBlock:nil];
    }
    
    return _avatarView;
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [SSThemedLabel new];
        _nameLabel.numberOfLines = 1;
        _nameLabel.font = [UIFont boldSystemFontOfSize:15.f];
        _nameLabel.textColorThemeKey = kColorText1;
        _nameLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    }
    
    return _nameLabel;
}

- (SSThemedLabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [SSThemedLabel new];
        _descLabel.numberOfLines = 1;
        _descLabel.font = [UIFont systemFontOfSize:15.f];
        _descLabel.textColorThemeKey = kColorText1;
        _descLabel.contentInset = UIEdgeInsetsMake(1.f, 0, 1.f, 0);
    }
    
    return _descLabel;
}

- (TTFollowThemeButton *)followButton {
    if (!_followButton) {
        _followButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101
                                                               followedType:TTFollowedType101
                                                         followedMutualType:TTFollowedMutualType101];
        [_followButton setHitTestEdgeInsets:UIEdgeInsetsMake(0, -8, 0, -8)];
        [_followButton addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _followButton;
}

- (SSThemedView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }
    
    return _bottomLineView;
}

@end

NSString *const kPresentAddFriendsViewNotification = @"kPresentAddFriendsViewNotification";
NSString *const kDismissAddFriendsViewNotification = @"kDismissAddFriendsViewNotification";
NSString *const kUploadContactsSuccessForInvitePageNotification = @"kUploadContactsSuccessForInvitePageNotification";

@interface TTContactsAddFriendsViewController () <UITableViewDataSource, UITableViewDelegate, TTContactsAddFriendsTableViewCellDelegate>

@property (nonatomic, strong) SSThemedView *rootMaskView;
@property (nonatomic, strong) SSThemedView *topView;
@property (nonatomic, strong) TTAlphaThemedButton *closeButton;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) UIView *topViewBottomLine;
@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) TTColorAsFollowButton *submitButton;
@property (nonatomic, strong) NSArray <TTContactsAddFriendModel *> *friendModels; // 内部 Model 映射
@property (nonatomic, assign) NSUInteger numberOfFollowingUsers; // 自动关注的人数


@end

@implementation TTContactsAddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rootMaskView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    self.rootMaskView.backgroundColorThemeKey = kColorBackground15;
    
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.closeButton];
    [self.topView addSubview:self.titleLabel];
    [self.topView addSubview:self.topViewBottomLine];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.submitButton];
    
    self.topViewBottomLine.bottom = self.topView.height;
    
    self.tableView.top = self.topView.bottom;
    self.tableView.width = self.view.width;
    self.tableView.height = self.view.height - self.topView.top - self.topView.height;
    
    self.titleLabel.text = [NSString stringWithFormat:@"%ld个好友在爱看", self.friendModels.count];
    
    self.submitButton.bottom = self.view.bottom;
    
    [self updateTopViewLayerMask];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

- (void)updateTopViewLayerMask {
    CGRect rect = self.topView.bounds;
    CGSize radio = CGSizeMake(6, 6);
    UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:radio];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = rect;
    maskLayer.path = path.CGPath;
    self.topView.layer.mask = maskLayer;
}

- (void)showInView:(UIView *)view withUsers:(NSArray <FRUserRelationContactFriendsUserStructModel *> *)users {
    [view addSubview:self.rootMaskView];
    [view addSubview:self.view];
    
    self.rootMaskView.frame = view.bounds;
    self.rootMaskView.alpha = 0;
    
    self.isVisible = YES;
    
    self.view.frame = view.bounds;
    self.view.top = view.height;
    self.view.height = view.height;
    
    [UIView animateWithDuration:0.35
           customTimingFunction:CustomTimingFunctionQuadIn
                          delay:0.f
         usingSpringWithDamping:0.92f
          initialSpringVelocity:20
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.top = 0;
                         self.rootMaskView.alpha = 1;
                         
                         if (view.tt_safeAreaInsets.top > 0) {
                             self.view.top = view.tt_safeAreaInsets.top - 20.f;
                             self.view.height -= view.tt_safeAreaInsets.top - 20.f;
                             self.topView.top = 20.f;
                             self.tableView.top = self.topView.bottom;
                             self.tableView.height = self.view.height - self.topView.top - self.topView.height;
                             self.submitButton.height = 44.f + view.tt_safeAreaInsets.bottom;
                             self.submitButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, view.tt_safeAreaInsets.bottom, 0);
                             self.submitButton.bottom = self.view.bottom;                         }
                     } completion:^(BOOL finished) {
                         [self showCompleteHud];
                     }];
    
    [TTTrackerWrapper eventV3:@"upload_concat_list_follow_show" params:@{
                                                                         @"value" : @(users.count),
                                                                         @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
                                                                         }];
    
    [self setUsers:users];
    [self refreshNavigationBarTitle];
    
    [[TTFollowNotifyServer sharedServer] addObserver:self selector:@selector(followActionNotify:)];
}

- (void)setUsers:(NSArray<FRUserRelationContactFriendsUserStructModel *> *)users {
    NSUInteger numberOfFollowingUsers = 0;
    NSMutableArray *friendModels = [[NSMutableArray alloc] initWithCapacity:users.count];
    NSMutableArray *to_user_ids = [[NSMutableArray alloc] initWithCapacity:users.count];
    for (FRUserRelationContactFriendsUserStructModel *friendsUserStructModel in users) {
        TTContactsAddFriendModel *addFriendModel = [[TTContactsAddFriendModel alloc] initWithFRUserRelationContactFriendsUserStructModel:friendsUserStructModel];
        [friendModels addObject:addFriendModel];
        
        // 统计自动关注人数
        if (addFriendModel.is_following.boolValue) {
            numberOfFollowingUsers++;
            [to_user_ids addObject:addFriendModel.user_id];
        }
    }
    
    self.numberOfFollowingUsers = numberOfFollowingUsers;
    
    [TTTrackerWrapper eventV3:@"rt_follow" params:@{
                                                    @"to_user_id_list": [to_user_ids componentsJoinedByString:@","],
                                                    @"follow_num": @(numberOfFollowingUsers),
                                                    @"follow_type": @"auto_follow",
                                                    @"source": @"upload_concat_list_follow",
                                                    @"server_source": @95
                                                    }];
    
    self.friendModels = [friendModels copy];
    
    [self.tableView reloadData];
}

- (void)refreshNavigationBarTitle {
    NSUInteger numberOfFollowingUsers = 0;
    for (FRUserRelationContactFriendsUserStructModel *friendsUserStructModel in self.friendModels) {
        TTContactsAddFriendModel *addFriendModel = [[TTContactsAddFriendModel alloc] initWithFRUserRelationContactFriendsUserStructModel:friendsUserStructModel];
        
        // 统计自动关注人数
        if (addFriendModel.is_following.boolValue) {
            numberOfFollowingUsers++;
        }
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"已关注%lu位好友", numberOfFollowingUsers];
}

- (void)followActionNotify:(TTFollowNotify *)notify {
    [self refreshNavigationBarTitle];
}

- (void)showCompleteHud {
    if (self.numberOfFollowingUsers == 0) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[NSString stringWithFormat:@"同步成功已为你关注%lu个好友", self.numberOfFollowingUsers] indicatorImage:nil autoDismiss:NO dismissHandler:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
            [TTIndicatorView dismissIndicators];
        });
    });
}

- (void)closeIfNeeded {
    if (self.view.superview || self.rootMaskView.superview) {
        [self close];
    }
}

- (void)close {
    [UIView animateWithDuration:0.15 customTimingFunction:CustomTimingFunctionQuadIn animation:^{
        self.view.top = self.view.superview.height;
    } completion:^(BOOL finished) {
        [self setEditing:NO];
        
        [self.rootMaskView removeFromSuperview];
        [self.view removeFromSuperview];
        
        self.isVisible = NO;
    }];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)dismissAction {
    [self closeIfNeeded];
    
    [TTTrackerWrapper eventV3:@"upload_concat_list_follow_click" params:@{
                                                                          @"action_type" : @"cancel",
                                                                          @"value" : @0,
                                                                          @"frequency" : @([[TTContactsGuideManager sharedManager] contactsGuidePresentingTimes])
                                                                          }];
}

#pragma mark - TTAddFriendsTableViewCellDelegate

- (void)didChangeFollowingOfCell:(TTContactsAddFriendsTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    TTContactsAddFriendModel *friendModel = self.friendModels[indexPath.row];
    
    [self didChangeFollowing:friendModel atIndex:indexPath.row];
}

- (void)didChangeFollowing:(TTContactsAddFriendModel *)userModel atIndex:(NSInteger)index {
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    [self startFollowLoadingAtIndex:index];
    
    FriendDataManager *dataManager = [FriendDataManager sharedManager];
    FriendActionType actionType;
    NSString *event = nil;
    if (userModel.is_following.boolValue) {
        actionType = FriendActionTypeUnfollow;
        event = @"rt_unfollow";
    } else {
        actionType = FriendActionTypeFollow;
        event = @"rt_follow";
    }
    
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:userModel.user_id forKey:@"to_user_id"];
    [extraDict setValue:@(95) forKey:@"server_source"];
    [extraDict setValue:@"from_others" forKey:@"follow_type"];
    [extraDict setValue:@"upload_concat_list_follow" forKey:@"source"];
    [extraDict setValue:@(index + 1) forKey:@"order"];
    [TTTracker eventV3:event params:extraDict];
    
    WeakSelf;
    [[TTFollowManager sharedManager] startFollowAction:actionType
                                             userID:userModel.user_id
                                           platform:nil
                                               name:nil
                                               from:nil
                                             reason:nil
                                          newReason:@0
                                          newSource:@(95)
                                         completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                                             StrongSelf;
                                             if (!error) {
                                                 NSDictionary *response = [result tt_dictionaryValueForKey:@"result"];
                                                 NSDictionary *data = [response tt_dictionaryValueForKey:@"data"];
                                                 NSDictionary *user = [data tt_dictionaryValueForKey:@"user"];
                                                 BOOL isFollowing = [user tt_boolValueForKey:@"is_following"];
                                                 NSString *followId = [user tt_stringValueForKey:@"user_id"];
                                                 
                                                 userModel.is_following = @(isFollowing);
                                                 
                                                 [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:followId actionType:TTFollowActionTypeFollow itemType:TTFollowItemTypeDefault userInfo:nil];
                                             }
                                             
                                             [self stopFollowLoadingAtIndex:index];
                                         }];
}

- (void)startFollowLoadingAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    TTContactsAddFriendsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.followButton startLoading];
}

- (void)stopFollowLoadingAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    TTContactsAddFriendsTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.followButton stopLoading:nil];
    
    TTContactsAddFriendModel *userModel = self.friendModels[indexPath.row];
    
    [cell.followButton setFollowed:userModel.is_following.boolValue];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTContactsAddFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTContactsAddFriendsTableViewCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    
    TTContactsAddFriendModel *friendModel = self.friendModels[indexPath.row];
    [cell configWithFriendModel:friendModel];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - getter and setter

- (SSThemedView *)topView {
    if (!_topView) {
        _topView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 20, self.view.width, [TTDeviceUIUtils tt_newPadding:49])];
        _topView.backgroundColorThemeKey = kColorBackground4;
    }
    
    return _topView;
}

- (TTAlphaThemedButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:49], [TTDeviceUIUtils tt_newPadding:49])];
        _closeButton.contentMode = UIViewContentModeScaleToFill;
        _closeButton.imageName = @"close_channel";
        [_closeButton addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeButton;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:49], 0, self.view.width - [TTDeviceUIUtils tt_newPadding:49] * 2, [TTDeviceUIUtils tt_newPadding:49])];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:17]];
    }
    
    return _titleLabel;
}

- (UIView *)topViewBottomLine {
    if (!_topViewBottomLine) {
        _topViewBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [TTDeviceHelper ssOnePixel])];
        _topViewBottomLine.backgroundColor = [UIColor tt_themedColorForKey:kColorLine7];
    }
    
    return _topViewBottomLine;
}


- (SSThemedTableView *)tableView {
    if (!_tableView) {
        _tableView = [[SSThemedTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColorThemeKey = kColorBackground4;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _tableView.tableFooterView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        [_tableView registerClass:[TTContactsAddFriendsTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTContactsAddFriendsTableViewCell class])];
    }
    
    return _tableView;
}

- (TTColorAsFollowButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [[TTColorAsFollowButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        [_submitButton setTitle:@"完成" forState:UIControlStateNormal];
        _submitButton.enableNightMask = YES;
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _submitButton.titleColorThemeKey = kColorText12;
        _submitButton.backgroundColorThemeKey = kColorBackground8;
        [_submitButton addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _submitButton;
}

@end

