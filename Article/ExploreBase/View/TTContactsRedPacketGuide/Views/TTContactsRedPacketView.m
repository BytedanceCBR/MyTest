//
//  TTContactsRedPacketView.m
//  Article
//
//  Created by Jiyee Sheng on 8/2/17.
//
//

#import "TTContactsRedPacketView.h"
#import "TTContactsRecommendUserTableViewCell.h"
#import "TTContactsUserDefaults.h"
#import "TTContactsRedPacketUsersViewController.h"
#import "TTNavigationController.h"
#import <ExploreAvatarView.h>
#import <ExploreAvatarView+VerifyIcon.h>

@implementation TTContactsRedPacketParam

+ (TTContactsRedPacketParam *)paramWithDict:(NSDictionary *)dict {
    if (!dict) {
        return nil;
    }
    
    TTContactsRedPacketParam *param = [TTContactsRedPacketParam new];
    param.redpacketId = [dict tt_stringValueForKey:@"redpack_id"];
    param.redpacketToken = [dict tt_stringValueForKey:@"redpack_token"];
    param.redpacketFirstLine = [dict tt_stringValueForKey:@"redpack_first_line"];
    param.redpacketSecondLine = [dict tt_stringValueForKey:@"redpack_second_line"];
    param.redpacketTitle = [dict tt_stringValueForKey:@"redpack_title"];
    param.redpacketIconUrl = [dict tt_stringValueForKey:@"icon"];
    param.redpacketIconText = [dict tt_stringValueForKey:@"icon_text"];
    return param;
}

@end

/**
 * 通讯录好友为空时的红包样式
 */
@interface TTContactsRedPacketContactUsersEmptyView : SSThemedView

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *subtitleLabel;
@property (nonatomic, strong) TTContactsRedPacketParam *param;

@end

@implementation TTContactsRedPacketContactUsersEmptyView

- (instancetype)initWithFrame:(CGRect)frame param:(TTContactsRedPacketParam *)param {
    self = [super initWithFrame:frame];
    if (self) {
        self.param = param;
        [self addSubview:self.backgroundImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.subtitleLabel];

        self.titleLabel.text = !isEmptyString(param.redpacketFirstLine) ? param.redpacketFirstLine : @"恭喜你";
        self.subtitleLabel.text = !isEmptyString(param.redpacketSecondLine) ? param.redpacketSecondLine : [[TTContactsUserDefaults dictionaryOfContactsRedPacketContents] stringValueForKey:@"get_redpack" defaultValue:@"获得好友红包，金额随机"];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.backgroundImageView.left = 0;
    self.backgroundImageView.top = 0;

    self.titleLabel.centerX = self.width / 2;
    self.titleLabel.top = [TTDeviceUIUtils tt_newPadding:90];

    self.subtitleLabel.centerX = self.width / 2;
    self.subtitleLabel.top = [TTDeviceUIUtils tt_newPadding:150];
}

#pragma mark - getter and setter

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts_red_packet_background"]];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    }

    return _backgroundImageView;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:270], [TTDeviceUIUtils tt_newPadding:42])];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"FFF3BC"];
        _titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:30]];
    }

    return _titleLabel;
}

- (SSThemedLabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:270], [TTDeviceUIUtils tt_newPadding:42])];
        _subtitleLabel.numberOfLines = 1;
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"FFF3BC"];
        _subtitleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:19]];
    }

    return _subtitleLabel;
}

@end

#define kTTAvatarViewSize [TTDeviceUIUtils tt_newPadding:66]

/**
 * 通讯录好友存在时，选择
 */
@interface TTContactsRedPacketContactUsersView : SSThemedView

@property (nonatomic, strong) ExploreAvatarView *avatarView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descriptionLabel;
@property (nonatomic, strong) SSThemedLabel *titleLabel;

@property (nonatomic, strong) NSArray *contactUsers;

@end

@implementation TTContactsRedPacketContactUsersView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.nameLabel];
        [self addSubview:self.descriptionLabel];
        [self addSubview:self.titleLabel];

        self.descriptionLabel.text = [[TTContactsUserDefaults dictionaryOfContactsRedPacketContents] stringValueForKey:@"get_random_redpack" defaultValue:@"发了一个红包，金额随机"];
        self.titleLabel.text = [[TTContactsUserDefaults dictionaryOfContactsRedPacketContents] stringValueForKey:@"open_and_follow" defaultValue:@"开启红包同时关注好友"];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.nameLabel.centerX = self.width / 2;
    self.nameLabel.top = [TTDeviceUIUtils tt_newPadding:83];

    self.descriptionLabel.centerX = self.width / 2;
    self.descriptionLabel.top = self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:11];

    self.titleLabel.centerX = self.width / 2;
    self.titleLabel.top = self.descriptionLabel.bottom + [TTDeviceUIUtils tt_newPadding:10];
}

- (void)setContactUsers:(NSArray *)contactUsers {
    // PM 策略，如果有 friendName 则预先显示 friendName
    NSString *friendName = [[TTContactsUserDefaults dictionaryOfContactsRedPacketContents] tt_stringValueForKey:@"friend_name"];
    if (!isEmptyString(friendName)) {
        self.nameLabel.text = friendName;
        return;
    }

    NSString *userName;
    NSString *firstUserName;
    NSString *secondUserName;

    NSMutableArray *selectedUsers = [NSMutableArray arrayWithCapacity:contactUsers.count];
    for (TTRecommendUserModel *contactUser in contactUsers) {
        if (contactUser.selected) {
            [selectedUsers addObject:contactUser];
        }
    }

    for (TTRecommendUserModel *userModel in selectedUsers) {
        if (!isEmptyString(userModel.mobile_name)) {
            if (isEmptyString(firstUserName)) {
                firstUserName = userModel.mobile_name;
            } else if (isEmptyString(secondUserName)) {
                secondUserName = userModel.mobile_name;
                break;
            }
        }
    }

    if (!isEmptyString(firstUserName)) {
        if (selectedUsers.count == 1) {
            if (firstUserName.length > 9) {
                firstUserName = [[firstUserName substringToIndex:8] stringByAppendingString:@"..."];
            }

            userName = firstUserName;
        } else {
            if (firstUserName.length > 4) {
                firstUserName = [[firstUserName substringToIndex:3] stringByAppendingString:@"..."];
            }

            if (secondUserName.length > 4) {
                secondUserName = [[secondUserName substringToIndex:3] stringByAppendingString:@"..."];
            }

            userName = [NSString stringWithFormat:@"%@、%@ 等%ld人", firstUserName, secondUserName, selectedUsers.count];
        }

        self.nameLabel.text = userName;
    } else {
        self.nameLabel.text = nil;
    }
}

- (ExploreAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake((self.width - kTTAvatarViewSize) / 2, [TTDeviceUIUtils tt_newPadding:30], kTTAvatarViewSize, kTTAvatarViewSize)];
        _avatarView.enableRoundedCorner = YES;
        _avatarView.highlightedMaskView = nil;
        _avatarView.imageView.layer.borderWidth = 0;
        _avatarView.placeholder = @"default_avatar";
        _avatarView.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _avatarView.disableNightMode = YES;
        _avatarView.verifyView.disableNightMode = YES;

        UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kTTAvatarViewSize, kTTAvatarViewSize)];
        coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        coverView.layer.cornerRadius = kTTAvatarViewSize / 2;
        coverView.layer.masksToBounds = YES;
        coverView.userInteractionEnabled = NO;
        coverView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
        [_avatarView addSubview:coverView];
    }

    return _avatarView;
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:20], [TTDeviceUIUtils tt_newPadding:83], self.width - [TTDeviceUIUtils tt_newPadding:40], [TTDeviceUIUtils tt_newPadding:28])];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#FFF3BC"];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:20]];
    }

    return _nameLabel;
}

- (SSThemedLabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:40], self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:11], self.width - [TTDeviceUIUtils tt_newPadding:80], [TTDeviceUIUtils tt_newPadding:40])];
        _descriptionLabel.textColor = [UIColor colorWithHexString:@"#FFF3BC"];
        _descriptionLabel.numberOfLines = 2;
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        _descriptionLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    }

    return _descriptionLabel;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:40], self.descriptionLabel.bottom + [TTDeviceUIUtils tt_newPadding:10], self.width - [TTDeviceUIUtils tt_newPadding:80], [TTDeviceUIUtils tt_newPadding:48])];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#FFF3BC"];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17]];
    }

    return _titleLabel;
}

@end


@interface TTContactsRedPacketView () <TTContactsRedPacketUsersDelegate>

@property (nonatomic, strong) TTContactsRedPacketContactUsersView *contactUsersView;
@property (nonatomic, strong) SSThemedButton *contactUsersButton;
@property (nonatomic, strong) TTContactsRedPacketContactUsersEmptyView *emptyView;
@property (nonatomic, strong) TTContactsRedPacketParam *param;
@property (nonatomic, assign) TTContactsRedPacketViewControllerType type;
@end

@implementation TTContactsRedPacketView

- (instancetype)initWithFrame:(CGRect)frame type:(TTContactsRedPacketViewControllerType)type param:(TTContactsRedPacketParam *)param {
    self = [super initWithFrame:frame];
    if (self) {
        self.param = param;
        self.type = type;
        [self.headerView addSubview:self.emptyView];
        [self.headerView addSubview:self.contactUsersView];
        [self.footerView addSubview:self.contactUsersButton];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.contactUsersView.frame = self.headerView.frame;
    self.emptyView.frame = self.headerView.frame;

    self.contactUsersButton.bottom = self.footerView.height;
    self.contactUsersButton.centerX = self.footerView.width / 2 - [TTDeviceUIUtils tt_newPadding:6];
}

- (void)startTransitionAnimation {
    [self stopLoadingAnimation];

    self.footerView.hidden = YES;
    self.headerView.hidden = NO;
//    self.contactUsersView.avatarView.hidden = NO;

    self.contactUsersView.nameLabel.hidden = YES;
    self.contactUsersView.descriptionLabel.hidden = YES;
    self.contactUsersView.titleLabel.hidden = YES;

    self.emptyView.titleLabel.hidden = YES;
    self.emptyView.subtitleLabel.hidden = YES;

    [super startTransitionAnimation];

    // 执行头像平移动画
    if (!self.contactUsersView.hidden) {
        [UIView animateWithDuration:0.4f
                         animations:^{
//                             self.contactUsersView.avatarView.top = 20 + 44 + [TTDeviceUIUtils tt_newPadding:46] - self.containerView.top;
                         } completion:^(BOOL finished) {
                             self.headerView.hidden = YES;
                             self.footerView.hidden = YES;
                         }];
    }
}

- (void)setContactUsers:(NSArray *)contactUsers {
    _contactUsers = contactUsers;

    NSMutableArray *selectedUsers = [NSMutableArray arrayWithCapacity:contactUsers.count];
    for (TTRecommendUserModel *contactUser in contactUsers) {
        if (contactUser.selected) {
            [selectedUsers addObject:contactUser];
        }
    }

    if (selectedUsers.count == 0 ||
        self.type == TTContactsRedPacketViewControllerTypeRecommendRedpacket ||
        self.type == TTContactsRedPacketViewControllerTypeRecommendRedpacketNoLogin) {
        self.emptyView.hidden = NO;
        self.contactUsersView.hidden = YES;
        self.contactUsersButton.hidden = YES;
    } else {
        self.emptyView.hidden = YES;
        self.contactUsersView.hidden = NO;
        self.contactUsersButton.hidden = NO;
        self.contactUsersView.contactUsers = selectedUsers;
    }
}

- (void)contactUsersAction:(id)sender {
    [TTTrackerWrapper eventV3:@"upload_contact_redpacket" params:@{@"action_type": @"click_friends_list"}];

    TTContactsRedPacketUsersViewController *viewController = [[TTContactsRedPacketUsersViewController alloc] initWithContactUsers:self.contactUsers];
    viewController.delegate = self;
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:viewController];
    navigationController.ttNavBarStyle = @"White";
    navigationController.ttHideNavigationBar = NO;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)didUpdateContactUsers:(NSArray *)contactUsers {
    self.contactUsers = contactUsers;
}

#pragma mark - getter and setter

- (TTContactsRedPacketContactUsersView *)contactUsersView {
    if (!_contactUsersView) {
        _contactUsersView = [[TTContactsRedPacketContactUsersView alloc] initWithFrame:self.headerView.frame];
    }

    return _contactUsersView;
}

- (SSThemedButton *)contactUsersButton {
    if (!_contactUsersButton) {
        _contactUsersButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:200], [TTDeviceUIUtils tt_newPadding:37])];
        _contactUsersButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        [_contactUsersButton setTitle:@"查看好友列表" forState:UIControlStateNormal];
        [_contactUsersButton setTitleColor:[UIColor colorWithHexString:@"FFF3BC"] forState:UIControlStateNormal];
        [_contactUsersButton setImage:[UIImage imageNamed:@"ask_arrow_right"] forState:UIControlStateNormal];
        [_contactUsersButton setImage:[UIImage imageNamed:@"ask_arrow_right"] forState:UIControlStateHighlighted];
        [_contactUsersButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, [TTDeviceUIUtils tt_newPadding:-170])];
        [_contactUsersButton addTarget:self action:@selector(contactUsersAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _contactUsersButton;
}

- (TTContactsRedPacketContactUsersEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[TTContactsRedPacketContactUsersEmptyView alloc] initWithFrame:self.headerView.frame param:self.param];
        _emptyView.hidden = YES;
    }

    return _emptyView;
}

@end
