//
//  TTContactsRedPacketDetailView.m
//  Article
//
//  Created by Jiyee Sheng on 8/3/17.
//
//

#import <TTAvatar/ExploreAvatarView+VerifyIcon.h>
#import "TTContactsRedPacketDetailView.h"
#import "TTContactsRecommendUserTableViewCell.h"

#define kTTTableViewOffsetY           [TTDeviceUIUtils tt_newPadding:365]
#define kTTTableHeaderViewHeight      [TTDeviceUIUtils tt_newPadding:24]

@interface TTContactsRedPacketDetailView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *contactUsers;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedTableView *tableView;

@end

@implementation TTContactsRedPacketDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.scrollView addSubview:self.tableView];

        self.descriptionLabel.hidden = YES;

        [self.avatarView.imageView setImage:[UIImage imageNamed:@"avatar_toutiao"]];
        self.tableView.frame = CGRectMake(0, kTTTableViewOffsetY, self.width, 0);

        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, kTTTableHeaderViewHeight)];
        self.tableView.tableHeaderView.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);
        [self.tableView.tableHeaderView addSubview:self.titleLabel];
    }

    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    self.tableView.tableHeaderView.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);
}

- (void)configWithViewModel:(TTRedPacketDetailBaseViewModel *)viewModel {
    [super configWithViewModel:viewModel];
    if (!isEmptyString(viewModel.listTitle)) {
        self.titleLabel.text = viewModel.listTitle;
    }
}

- (void)setContactUsers:(NSArray<TTRecommendUserModel *> *)users {
    _contactUsers = [users copy];

    self.titleLabel.text = [NSString stringWithFormat:@"已关注%ld位好友", users.count];

    if (users.count == 0) {
        self.tableView.hidden = YES;
        self.tableView.height = 0;
    } else {
        self.tableView.hidden = NO;
        self.tableView.height = kTTTableHeaderViewHeight + 74.f * users.count;
        [self.tableView reloadData];
    }

    self.scrollView.contentSize = CGSizeMake(self.width, kTTTableViewOffsetY + self.tableView.height);
}

- (void)setDefaultAvatar:(NSString *)avatar {
    if (!isEmptyString(avatar)) {
        self.avatarView.placeholder = avatar;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactUsers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTContactsRecommendUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTContactsRecommendUserTableViewCell class]) forIndexPath:indexPath];

    TTRecommendUserModel *userModel = self.contactUsers[indexPath.row];
    [cell configWithUserModel:userModel];

    return cell;
}

#pragma mark - setter and getter

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:15], 0, self.width, kTTTableHeaderViewHeight)];
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:15]];
        _titleLabel.textColorThemeKey = kColorText1;
    }

    return _titleLabel;
}

- (SSThemedTableView *)tableView {
    if (!_tableView) {
        _tableView = [[SSThemedTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColorThemeKey = kColorBackground4;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_tableView registerClass:[TTContactsRecommendUserTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTContactsRecommendUserTableViewCell class])];
    }

    return _tableView;
}

@end
