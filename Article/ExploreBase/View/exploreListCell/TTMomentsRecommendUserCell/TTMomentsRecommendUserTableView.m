//
//  TTMomentsRecommendUserTableView.m
//  Article
//
//  Created by Jiyee Sheng on 15/08/2017.
//
//

#import "TTMomentsRecommendUserTableView.h"
#import <TTAvatar/SSAvatarView+VerifyIcon.h>
#import <TTAvatar/ExploreAvatarView+VerifyIcon.h>
#import "TTColorAsFollowButton.h"
#import "TTFollowThemeButton.h"


#define kLeftPadding 15
#define kRightPadding 15

#define kTitleLabelHeight ([TTDeviceUIUtils tt_newPadding:24])
#define kTitleLabelFontSize ([TTDeviceUIUtils tt_fontSize:17])
#define kTableViewCellHeight ([TTDeviceUIUtils tt_newPadding:97])
#define kAvatarViewSize ([TTDeviceUIUtils tt_newPadding:66])

@class TTMomentsRecommendUserTableViewCell;

@protocol TTMomentsRecommendUserTableViewCellDelegate <NSObject>

- (void)didChangeFollowingOfCell:(TTMomentsRecommendUserTableViewCell *)cell;

- (void)didClickAvatarViewOfCell:(TTMomentsRecommendUserTableViewCell *)cell;

@end

@interface TTMomentsRecommendUserTableViewCell : SSThemedTableViewCell

@property (nonatomic, weak) id <TTMomentsRecommendUserTableViewCellDelegate> delegate;

@property (nonatomic, strong) ExploreAvatarView *avatarView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) SSThemedLabel *fansLabel;
@property (nonatomic, strong) TTFollowThemeButton *followButton;
@property (nonatomic, strong) SSThemedView *topLineView;

- (void)configWithUserModel:(FRMomentsRecommendUserStructModel *)userModel;

@end

@implementation TTMomentsRecommendUserTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self addSubview:self.topLineView];
        [self addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.fansLabel];
        [self addSubview:self.followButton];

        self.topLineView.width = self.width;
        self.topLineView.height = [TTDeviceHelper ssOnePixel];
        self.topLineView.top = 0;

        self.avatarView.left = kLeftPadding;
        self.avatarView.top = 15.f;

        self.nameLabel.left = self.avatarView.right + 10.f;
        self.nameLabel.top = 16.f;
        self.nameLabel.height = 24.f;

        self.fansLabel.left = self.nameLabel.left;
        self.fansLabel.bottom = self.avatarView.bottom - 2;

        self.descLabel.left = self.nameLabel.left;
        self.descLabel.top = self.nameLabel.bottom + (self.fansLabel.top - self.nameLabel.bottom - self.descLabel.height) / 2;

        self.followButton.right = self.width - kRightPadding;
        self.followButton.centerY = self.avatarView.centerY;

        // 保证能触发动画效果
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];

        [self themeChanged:nil];
    }

    return self;
}

- (void)themeChanged:(NSNotification *)notification {
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.nameLabel sizeToFit];
    [self.descLabel sizeToFit];
    [self.fansLabel sizeToFit];

    CGFloat maxWidth = self.width - kLeftPadding - kAvatarViewSize - 10 - kRightPadding - self.followButton.width - kRightPadding;

    self.nameLabel.top = 15.f;
    self.nameLabel.width = MIN(self.nameLabel.width, maxWidth);

    self.fansLabel.width = MIN(self.fansLabel.width, maxWidth);
    self.fansLabel.bottom = self.avatarView.bottom - 2;

    self.descLabel.width = MIN(self.descLabel.width, maxWidth);
    self.descLabel.top = self.nameLabel.bottom + (self.fansLabel.top - self.nameLabel.bottom - self.descLabel.height) / 2;

    self.followButton.right = self.width - kRightPadding;

    self.topLineView.width = self.width;
    self.topLineView.top = 0;
}

- (void)followAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeFollowingOfCell:)]) {
        [self.delegate didChangeFollowingOfCell:self];
    }
}

- (void)avatarAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAvatarViewOfCell:)]) {
        [self.delegate didClickAvatarViewOfCell:self];
    }
}

- (void)configWithUserModel:(FRMomentsRecommendUserStructModel *)userModel {
    [self.avatarView setImageWithURLString:userModel.user.info.avatar_url];
    NSString *userAuthInfo = userModel.user.info.user_auth_info;
    [self.avatarView setupVerifyViewForLength:50.f adaptationSizeBlock:^CGSize(CGSize standardSize) {
        return CGSizeMake(14.f, 14.f);
    }];
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];


    NSString *userName = userModel.user.info.name;
    if (isEmptyString(userName)) {
        if (!isEmptyString(userModel.real_name)) {
            userName = [NSString stringWithFormat:@"%@", userModel.real_name];
        }
    } else {
        if (!isEmptyString(userModel.real_name)) {
            userName = [userName stringByAppendingFormat:@" (%@)", userModel.real_name];
        }
    }

    self.nameLabel.text = [self stringWithUserName:userName];
    self.descLabel.text = userModel.intro;
    self.fansLabel.text = [NSString stringWithFormat:@"%@粉丝", [TTBusinessManager formatCommentCount:userModel.fans.longLongValue]];

    self.followButton.followed = [userModel.user.relation.is_following boolValue];
}

- (NSString *)stringWithUserName:(NSString *)userName {
    if (isEmptyString(userName)) {
        return nil;
    }

    NSString *ellipsis = @"...";
    NSString *anchorString = @" (";

    // 按加粗字体简化计算
    NSDictionary *attributes = @{
        NSFontAttributeName: self.nameLabel.font
    };
    NSMutableString *truncatedString = [userName mutableCopy];
    CGFloat constraintsWidth = self.width - kLeftPadding - kAvatarViewSize - 10 - kRightPadding - self.followButton.width - kRightPadding;

    NSRange range = [truncatedString rangeOfString:anchorString options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return userName;
    }

    // 执行截断操作
    if ([truncatedString sizeWithAttributes:attributes].width > constraintsWidth) {
        // 扣除 ellipsis 宽度，这部分之后会加回来
        constraintsWidth -= [ellipsis sizeWithAttributes:attributes].width;

        // 单字符方式从后往前删除
        range.length = 1;

        while ([truncatedString sizeWithAttributes:attributes].width > constraintsWidth && range.location > 0) {
            range.location -= 1;
            [truncatedString deleteCharactersInRange:range];
        }

        // 添加 ellipsis
        range.length = 0;
        [truncatedString replaceCharactersInRange:range withString:ellipsis];
    }

    return truncatedString;
}

- (ExploreAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake(0, 0, kAvatarViewSize, kAvatarViewSize)];
        _avatarView.enableRoundedCorner = YES;
        UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAvatarViewSize, kAvatarViewSize)];
        coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        coverView.layer.cornerRadius = kAvatarViewSize / 2;
        coverView.layer.masksToBounds = YES;
        coverView.userInteractionEnabled = NO;
        coverView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
        [_avatarView addSubview:coverView];
        _avatarView.imageView.layer.borderWidth = 0;
        _avatarView.imageView.borderColorThemeKey = kColorLine1;
        _avatarView.placeholder = @"default_sdk_login";
        [_avatarView addTouchTarget:self action:@selector(avatarAction:)];
    }

    return _avatarView;
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [SSThemedLabel new];
        _nameLabel.numberOfLines = 1;
        _nameLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:15.f]];
        _nameLabel.textColorThemeKey = kColorText1;
    }

    return _nameLabel;
}

- (SSThemedLabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [SSThemedLabel new];
        _descLabel.numberOfLines = 1;
        _descLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15.f]];
        _descLabel.textColorThemeKey = kColorText1;
    }

    return _descLabel;
}

- (SSThemedLabel *)fansLabel {
    if (!_fansLabel) {
        _fansLabel = [SSThemedLabel new];
        _fansLabel.numberOfLines = 1;
        _fansLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14.f]];
        _fansLabel.textColorThemeKey = kColorText1;
    }

    return _fansLabel;
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

- (SSThemedView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[SSThemedView alloc] init];
        _topLineView.backgroundColorThemeKey = kColorLine1;
    }

    return _topLineView;
}

@end

#define kHeaderViewHeight ([TTDeviceUIUtils tt_newPadding:56])
#define kHeaderAvatarViewSize ([TTDeviceUIUtils tt_newPadding:36])
#define kFooterViewHeight ([TTDeviceUIUtils tt_newPadding:66])
#define kDislikeButtonWidth 60

@interface TTMomentsRecommendUserTableView () <UITableViewDataSource, UITableViewDelegate, TTMomentsRecommendUserTableViewCellDelegate>

@property (nonatomic, strong) ExploreAvatarView *avatarView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedTableView *tableView;

@property (nonatomic, assign) BOOL isDisplay;
@property (nonatomic, strong) NSMutableArray<FRMomentsRecommendUserStructModel *> *userCardModels;
@property (nonatomic, strong) FRCommonUserStructModel *friendUserModel;

@end

@implementation TTMomentsRecommendUserTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.tableView];
    }

    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat fixedWidth = [self.titleLabel.text sizeWithAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:kTitleLabelFontSize]
    }].width;

    CGFloat nameWidth = [self.nameLabel.text sizeWithAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:kTitleLabelFontSize]
    }].width;

    self.avatarView.frame = CGRectMake(kLeftPadding, (kHeaderViewHeight - kHeaderAvatarViewSize) / 2, kHeaderAvatarViewSize, kHeaderAvatarViewSize);
    self.nameLabel.frame = CGRectMake(self.avatarView.right + 10.f, (kHeaderViewHeight - kTitleLabelHeight) / 2, MIN(nameWidth, (self.width -  kLeftPadding - kHeaderAvatarViewSize - 10 - kDislikeButtonWidth - fixedWidth)), kTitleLabelHeight);
    self.titleLabel.frame = CGRectMake(self.nameLabel.right, (kHeaderViewHeight - kTitleLabelHeight) / 2, fixedWidth, kTitleLabelHeight);
    self.tableView.frame = CGRectMake(0, kHeaderViewHeight, self.width, kTableViewCellHeight * self.userCardModels.count);
}

- (void)configTitle:(NSString *)title friendUserModel:(FRCommonUserStructModel *)friendUserModel {
    [self.avatarView setImageWithURLString:friendUserModel.info.avatar_url];
    NSString *userAuthInfo = friendUserModel.info.user_auth_info;
    [self.avatarView setupVerifyViewForLength:50.f adaptationSizeBlock:^CGSize(CGSize standardSize) {
        return CGSizeMake(14.f, 14.f);
    }];
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];

    CGFloat fixedWidth = [title sizeWithAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:kTitleLabelFontSize]
    }].width;

    CGFloat nameWidth = [friendUserModel.info.name sizeWithAttributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:kTitleLabelFontSize]
    }].width;

    self.nameLabel.text = friendUserModel.info.name;
    self.titleLabel.text = title;

    self.nameLabel.width = MIN(nameWidth, (self.width - kLeftPadding - kDislikeButtonWidth - fixedWidth));
    self.titleLabel.width = fixedWidth;
    self.titleLabel.left = self.nameLabel.right;

    self.friendUserModel = friendUserModel;
}

- (void)configUserModels:(NSArray<FRMomentsRecommendUserStructModel *> *)userModels {
    _userCardModels = [NSMutableArray arrayWithArray:userModels];

    [self.tableView reloadData];
}

- (void)startFollowLoadingAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];

    TTMomentsRecommendUserTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.followButton startLoading];
}

- (void)stopFollowLoadingAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];

    TTMomentsRecommendUserTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.followButton stopLoading:nil];

    FRMomentsRecommendUserStructModel *userModel = self.userCardModels[indexPath.row];

    [cell.followButton setFollowed:userModel.user.relation.is_following.boolValue];
}

- (void)didClickHeaderUserAvatarView:(id)sender {
    FRMomentsRecommendUserStructModel *userModel = [[FRMomentsRecommendUserStructModel alloc] init];
    userModel.user = self.friendUserModel;
    [self.delegate didClickAvatarView:userModel atIndex:-1];
}

#pragma mark - TTMomentsRecommendUserTableViewCellDelegate

- (void)didChangeFollowingOfCell:(TTMomentsRecommendUserTableViewCell *)cell  {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    FRMomentsRecommendUserStructModel *userModel = self.userCardModels[indexPath.row];

    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeFollowing:atIndex:)]) {
        [self.delegate didChangeFollowing:userModel atIndex:indexPath.row];
    }
}

- (void)didClickAvatarViewOfCell:(TTMomentsRecommendUserTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    FRMomentsRecommendUserStructModel *userModel = self.userCardModels[indexPath.row];

    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAvatarView:atIndex:)]) {
        [self.delegate didClickAvatarView:userModel atIndex:indexPath.row];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userCardModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTMomentsRecommendUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTMomentsRecommendUserTableViewCell class]) forIndexPath:indexPath];
    cell.delegate = self;

    FRMomentsRecommendUserStructModel *userModel = self.userCardModels[indexPath.row];
    [cell configWithUserModel:userModel];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - getter and setter

- (ExploreAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake(0, 0, kHeaderAvatarViewSize, kHeaderAvatarViewSize)];
        _avatarView.enableRoundedCorner = YES;
        UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kHeaderAvatarViewSize, kHeaderAvatarViewSize)];
        coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        coverView.layer.cornerRadius = kHeaderAvatarViewSize / 2;
        coverView.layer.masksToBounds = YES;
        coverView.userInteractionEnabled = NO;
        coverView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
        [_avatarView addSubview:coverView];
        _avatarView.imageView.layer.borderWidth = 0;
        _avatarView.imageView.borderColorThemeKey = kColorLine1;
        _avatarView.placeholder = @"default_sdk_login";
        [_avatarView addTouchTarget:self action:@selector(didClickHeaderUserAvatarView:)];
    }

    return _avatarView;
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[SSThemedLabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textColorThemeKey = kColorText5;
        _nameLabel.userInteractionEnabled = YES;

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickHeaderUserAvatarView:)];
        [_nameLabel addGestureRecognizer:tapGestureRecognizer];
    }

    return _nameLabel;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        _titleLabel.numberOfLines = 1;
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
        [_tableView registerClass:[TTMomentsRecommendUserTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTMomentsRecommendUserTableViewCell class])];
    }

    return _tableView;
}

@end
