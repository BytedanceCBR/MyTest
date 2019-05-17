//
//  TTContactsRedPacketUsersViewController.m
//  Article
//
//  Created by Jiyee Sheng on 8/8/17.
//
//

#import "TTContactsRedPacketUsersViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "SSThemed.h"
#import "TTContactsRecommendUserTableViewCell.h"
#import "SSNavigationBar.h"


@interface TTContactsRedPacketUsersViewController () <UITableViewDataSource, UITableViewDelegate, TTContactsRecommendUserTableViewCellDelegate>

@property (nonatomic, strong) SSThemedView *navigationBar;
@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) NSArray *contactUsers;
@end

@implementation TTContactsRedPacketUsersViewController

- (instancetype)initWithContactUsers:(NSArray *)contactUsers {
    if (self = [super init]) {
        self.contactUsers = contactUsers;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);

    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:@"好友列表"];
    TTNavigationBarItemContainerView *submitItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight
                                                                                                                            withTitle:@"完成"
                                                                                                                               target:self
                                                                                                                               action:@selector(submitAction:)];
    submitItem.button.titleColorThemeKey = kColorText6;
    submitItem.button.highlightedTitleColorThemeKey = kColorText6Highlighted;
    submitItem.button.titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
    [submitItem.button setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -20, -10, -20)];
    submitItem.button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    submitItem.button.frame = CGRectMake(0, 0, 44.f, 44.f);
    submitItem.frame = CGRectMake(0.f, 0, 44.f, 44.f);
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:submitItem];

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;

    [self.view addSubview:self.tableView];

    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.frame = self.view.bounds;

    [self.tableView reloadData];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];

    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

- (void)submitAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateContactUsers:)]) {
        [self.delegate didUpdateContactUsers:self.contactUsers];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TTContactsRecommendUserTableViewCellDelegate

- (void)addFriendsTableViewCell:(TTContactsRecommendUserTableViewCell *)cell didSelectedUser:(BOOL)selected {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    TTRecommendUserModel *userModel = self.contactUsers[indexPath.row];
    userModel.selected = selected;

    if (!selected) {
        [TTTrackerWrapper eventV3:@"upload_contact_redpacket" params:@{@"action_type": @"unselect_friend"}];
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
    cell.delegate = self;

    TTRecommendUserModel *userModel = self.contactUsers[indexPath.row];
    userModel.selectable = YES;
    [cell configWithUserModel:userModel];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

@end
