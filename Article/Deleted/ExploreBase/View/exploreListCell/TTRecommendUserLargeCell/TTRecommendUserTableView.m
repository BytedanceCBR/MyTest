//
//  TTRecommendUserTableView.m
//  Article
//  推人列表卡片
//
//  Created by Jiyee Sheng on 7/13/17.
//
//

#import <TTImpression/SSImpressionProtocol.h>
#import <TTAvatar/SSAvatarView+VerifyIcon.h>
#import <TTAvatar/ExploreAvatarView+VerifyIcon.h>
#import "TTRecommendUserTableView.h"
#import "TTColorAsFollowButton.h"
#import "ExploreAvatarView.h"
#import "TTRoute.h"
#import "TTIndicatorView.h"


#define kLeftPadding 15
#define kRightPadding 15

#define kTitleLabelHeight ([TTDeviceUIUtils tt_newPadding:24])
#define kTitleLabelFontSize ([TTDeviceUIUtils tt_fontSize:17])
#define kTableViewCellHeight ([TTDeviceUIUtils tt_newPadding:75])
#define kAvatarViewSize ([TTDeviceUIUtils tt_newPadding:44])

@class TTRecommendUserLargeCardCell;

@protocol TTRecommendUserLargeCardCellDelegate <NSObject>

- (BOOL)shouldRespondsToChangeAction;

- (void)didChangeSelected:(BOOL)selected ofCell:(TTRecommendUserLargeCardCell *)cell;

- (void)didClickAvatarViewOfCell:(TTRecommendUserLargeCardCell *)cell;

@end

@interface TTRecommendUserLargeCardCell : SSThemedTableViewCell

@property (nonatomic, weak) id <TTRecommendUserLargeCardCellDelegate> delegate;

@property (nonatomic, strong) ExploreAvatarView *avatarView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) TTAlphaThemedButton *selectButton;
@property (nonatomic, strong) SSThemedView *bottomLineView;

- (void)configWithUserModel:(FRRecommendUserLargeCardStructModel *)userModel;

@end

@implementation TTRecommendUserLargeCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.selectButton];
        [self addSubview:self.bottomLineView];

        self.avatarView.left = kLeftPadding;
        self.avatarView.top = 15.f;

        [self.nameLabel sizeToFit];
        self.nameLabel.left = self.avatarView.right + 10.f;
        self.nameLabel.top = 15.f;
        self.nameLabel.height = 24.f;

        [self.descLabel sizeToFit];
        self.descLabel.left = self.nameLabel.left;
        self.descLabel.bottom = self.avatarView.bottom - 2;

        self.selectButton.right = self.width - kRightPadding;
        self.selectButton.centerY = self.avatarView.centerY;

        self.bottomLineView.width = self.width;
        self.bottomLineView.height = [TTDeviceHelper ssOnePixel];
        self.bottomLineView.bottom = self.height - 1;

        // 保证能触发动画效果
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];

        [self themeChanged:nil];
    }

    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    [self.selectButton setImage:[UIImage themedImageNamed:[SSCommonLogic followSelectedImageName]] forState:UIControlStateSelected];
    [self.selectButton setImage:[UIImage themedImageNamed:[SSCommonLogic followUnSelectedImageName]] forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.nameLabel sizeToFit];
    [self.descLabel sizeToFit];

    CGFloat maxWidth = self.width - kLeftPadding - kAvatarViewSize - 10 - kRightPadding - 22 - kRightPadding;

    self.nameLabel.top = 15.f;
    self.nameLabel.width = MIN(self.nameLabel.width, maxWidth);

    self.descLabel.width = MIN(self.descLabel.width, maxWidth);
    self.descLabel.bottom = self.avatarView.bottom - 2;

    self.selectButton.right = self.width - kRightPadding;
    self.bottomLineView.width = self.width;
    self.bottomLineView.bottom = self.height - 1;
}

- (void)changeAction:(id)sender {
    // loading 状态不响应选择动作
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldRespondsToChangeAction)]) {
        if (![self.delegate shouldRespondsToChangeAction]) {
            return;
        }
    }

    BOOL selected = self.selectButton.selected;
    if (!selected) {
        UIImageView *rotateImg = [[UIImageView alloc] initWithFrame:self.selectButton.bounds];
        rotateImg.image = [UIImage themedImageNamed:[SSCommonLogic followSelectedImageName]];
        rotateImg.transform = CGAffineTransformMakeScale(0.2, 0.2);
        rotateImg.transform = CGAffineTransformRotate(rotateImg.transform, -M_PI/4);
        [self.selectButton addSubview:rotateImg];

        [UIView animateWithDuration:0.1 animations:^{
            rotateImg.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [rotateImg removeFromSuperview];

            self.selectButton.selected = !selected;
        }];
    } else {
        self.selectButton.selected = !selected;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeSelected:ofCell:)]) {
        [self.delegate didChangeSelected:!selected ofCell:self];
    }
}

- (void)avatarAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAvatarViewOfCell:)]) {
        [self.delegate didClickAvatarViewOfCell:self];
    }
}

- (void)configWithUserModel:(FRRecommendUserLargeCardStructModel *)userModel {
    [self.avatarView setImageWithURLString:userModel.user.info.avatar_url];
    NSString *userAuthInfo = userModel.user.info.user_auth_info;
    [self.avatarView setupVerifyViewForLength:12 adaptationSizeBlock:nil];
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];

    self.nameLabel.text = userModel.user.info.name;
    self.descLabel.text = userModel.recommend_reason;

    self.selectButton.selected = [userModel.selected boolValue];
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
//        _descLabel.contentInset = UIEdgeInsetsMake(1.f, 0, 1.f, 0);
    }

    return _descLabel;
}

- (TTAlphaThemedButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:22], [TTDeviceUIUtils tt_newPadding:22])];
        _selectButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_selectButton setImage:[UIImage themedImageNamed:[SSCommonLogic followSelectedImageName]] forState:UIControlStateSelected];
        [_selectButton setImage:[UIImage themedImageNamed:[SSCommonLogic followUnSelectedImageName]] forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _selectButton;
}

- (SSThemedView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }

    return _bottomLineView;
}

@end


#define kHeaderViewHeight ([TTDeviceUIUtils tt_newPadding:54])
#define kFooterViewHeight ([TTDeviceUIUtils tt_newPadding:66])
#define kDislikeButtonWidth 60


@interface TTRecommendUserTableView () <UITableViewDataSource, UITableViewDelegate, TTRecommendUserLargeCardCellDelegate>

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedView *bottomLineView;
@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) SSThemedLabel *footerLabel;
@property (nonatomic, strong) TTColorAsFollowButton *followButton;
@property (nonatomic, strong) SSThemedImageView *loadingView;
@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, assign) BOOL isDisplay;
@property (nonatomic, strong) NSMutableArray<FRRecommendUserLargeCardStructModel *> *userCardModels;

//@property (nonatomic, weak) id <UICollectionViewDelegate> delegate;

@end

@implementation TTRecommendUserTableView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.bottomLineView];
        [self addSubview:self.tableView];
        [self addSubview:self.footerLabel];
        [self addSubview:self.followButton];
        [self.followButton addSubview:self.loadingView];
    }

    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.titleLabel.frame = CGRectMake(kLeftPadding, (kHeaderViewHeight - kTitleLabelHeight) / 2, self.width - kLeftPadding - kDislikeButtonWidth, kTitleLabelHeight);
    self.bottomLineView.frame = CGRectMake(0, kHeaderViewHeight - 1, self.width, [TTDeviceHelper ssOnePixel]);
    self.tableView.frame = CGRectMake(0, kHeaderViewHeight, self.width, kTableViewCellHeight * self.userCardModels.count);
    self.followButton.right = self.right - kRightPadding;
    self.followButton.top = self.tableView.bottom + [TTDeviceUIUtils tt_newPadding:15];
    self.footerLabel.centerY = self.followButton.centerY;
    self.footerLabel.left = kLeftPadding;
    self.footerLabel.width = self.width - kLeftPadding - self.followButton.width - kRightPadding;
    self.loadingView.center = CGPointMake(self.followButton.width / 2, self.followButton.height / 2);
}

- (void)configTitle:(NSString *)title {
    if ([title sizeWithAttributes:@{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:kTitleLabelFontSize]
    }].width > self.titleLabel.width) {
        title = @"推荐关注";
    }

    self.titleLabel.text = title;
}

- (void)configUserModels:(NSArray<FRRecommendUserLargeCardStructModel *> *)userModels {
    _userCardModels = [NSMutableArray arrayWithArray:userModels];

    [self.tableView reloadData];

    [self refreshFollowButtonUI];
}

- (void)startFollowButtonAnimation {
    self.isLoading = YES;
    self.followButton.titleLabel.hidden = YES;
    self.loadingView.hidden = NO;

    CGFloat duration = 0.4f;
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = NSUIntegerMax;

    [self.loadingView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopFollowButtonAnimation {
    self.isLoading = NO;
    self.followButton.titleLabel.hidden = NO;
    self.loadingView.hidden = YES;

    [self.loadingView.layer removeAllAnimations];
}

- (void)addFriendsAction:(id)sender {
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://add_friend"]];
}

- (void)submitAction:(id)sender {
    if (self.isLoading) { // 正在提交中...
        return;
    }

    NSMutableArray *needFollowRecommendUserLargeCards = [[NSMutableArray alloc] init];
    for (FRRecommendUserLargeCardStructModel *userModel in self.userCardModels) {
        if (userModel.selected.boolValue && userModel.user.info.user_id) {
            [needFollowRecommendUserLargeCards addObject:userModel];
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(submitMultiFollowRecommendUsersWithRecommendUserLargeCards:)]) {
        [self.delegate submitMultiFollowRecommendUsersWithRecommendUserLargeCards:needFollowRecommendUserLargeCards];
    }
}

- (void)refreshFollowButtonUI {
    NSMutableArray *followUsers = [[NSMutableArray alloc] init];
    for (FRRecommendUserLargeCardStructModel *userModel in self.userCardModels) {
        if (userModel.selected.boolValue && userModel.user.info.user_id) {
            [followUsers addObject:userModel.user];
        }
    }

    BOOL enabled = followUsers.count > 0;
    BOOL dayMode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    if (enabled) {
        if (dayMode) {
            [self.followButton setBackgroundColor:[UIColor colorWithHexString:@"2A90D7"]
                                      borderColor:[UIColor colorWithHexString:@"3090D4"]
                                          enabled:enabled];
        } else {
            [self.followButton setBackgroundColor:[UIColor colorWithHexString:@"67778B"]
                                      borderColor:[UIColor colorWithHexString:@"677689"]
                                          enabled:enabled];
        }

        [self.followButton setTitle:[NSString stringWithFormat:@"关注所选%ld人", followUsers.count] forState:UIControlStateNormal];
    } else {
        if (dayMode) {
            [self.followButton setBackgroundColor:[[UIColor colorWithHexString:@"3090D4"] colorWithAlphaComponent:0.6]
                                      borderColor:[UIColor colorWithHexString:@"51B1F4"]
                                          enabled:enabled];
        } else {
            [self.followButton setBackgroundColor:[[UIColor colorWithHexString:@"67778B"] colorWithAlphaComponent:0.6]
                                      borderColor:[UIColor colorWithHexString:@"375D78"]
                                          enabled:enabled];
        }

        [self.followButton setTitle:@"至少关注1人" forState:UIControlStateNormal];
    }
}

#pragma mark - TTRecommendUserLargeCardCellDelegate

- (BOOL)shouldRespondsToChangeAction {
    return !self.isLoading;
}

- (void)didChangeSelected:(BOOL)selected ofCell:(TTRecommendUserLargeCardCell *)cell  {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    FRRecommendUserLargeCardStructModel *userModel = self.userCardModels[indexPath.row];
    userModel.selected = @(selected);

    [self refreshFollowButtonUI];

    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeSelected:atIndex:)]) {
        [self.delegate didChangeSelected:userModel atIndex:indexPath.row];
    }
}

- (void)didClickAvatarViewOfCell:(TTRecommendUserLargeCardCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    FRRecommendUserLargeCardStructModel *userModel = self.userCardModels[indexPath.row];

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
    TTRecommendUserLargeCardCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTRecommendUserLargeCardCell class]) forIndexPath:indexPath];
    cell.delegate = self;

    FRRecommendUserLargeCardStructModel *userModel = self.userCardModels[indexPath.row];
    [cell configWithUserModel:userModel];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - getter and setter

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:kTitleLabelFontSize];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.userInteractionEnabled = YES;

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFriendsAction:)];
        [_titleLabel addGestureRecognizer:tapGestureRecognizer];
    }

    return _titleLabel;
}

- (SSThemedView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }

    return _bottomLineView;
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
        [_tableView registerClass:[TTRecommendUserLargeCardCell class] forCellReuseIdentifier:NSStringFromClass([TTRecommendUserLargeCardCell class])];
    }

    return _tableView;
}

- (SSThemedLabel *)footerLabel {
    if (!_footerLabel) {
        _footerLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(kLeftPadding, self.height - kHeaderViewHeight - self.tableView.height - kFooterViewHeight, self.width - kLeftPadding - [TTDeviceUIUtils tt_newPadding:160] - kRightPadding, kFooterViewHeight)];
        _footerLabel.text = @"关注他们可看到最新消息";
        _footerLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:13]];
        _footerLabel.numberOfLines = 1;
        _footerLabel.textColorThemeKey = kColorText3;
        _footerLabel.userInteractionEnabled = YES;

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFriendsAction:)];
        [_footerLabel addGestureRecognizer:tapGestureRecognizer];
    }

    return _footerLabel;
}

- (TTColorAsFollowButton *)followButton {
    if (!_followButton) {
        _followButton = [[TTColorAsFollowButton alloc] initWithFrame:CGRectMake(self.width - [TTDeviceUIUtils tt_newPadding:160] - kRightPadding, self.height - 15 - [TTDeviceUIUtils tt_newPadding:36], [TTDeviceUIUtils tt_newPadding:160], [TTDeviceUIUtils tt_newPadding:36])];
        [_followButton setTitle:@"关注所选" forState:UIControlStateNormal];
        _followButton.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:4];
        _followButton.layer.masksToBounds = YES;
        _followButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _followButton.enableNightMask = YES;
        _followButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _followButton.titleColorThemeKey = kColorText12;
        _followButton.backgroundColor = SSGetThemedColorWithKey(kColorBackground8);
        [_followButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _followButton;
}

- (SSThemedImageView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [[SSThemedImageView alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:160] / 2 - 6, [TTDeviceUIUtils tt_newPadding:36] / 2 - 6, 12, 12)];
        _loadingView.imageName = @"toast_keywords_refresh_white";
        _loadingView.hidden = YES;
    }

    return _loadingView;
}

@end
