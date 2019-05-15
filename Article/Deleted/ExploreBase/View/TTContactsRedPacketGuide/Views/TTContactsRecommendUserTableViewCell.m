//
//  TTContactsRecommendUserTableViewCell.m
//  Article
//
//  Created by Jiyee Sheng on 8/3/17.
//
//

#import <TTFriendRelation/TTFollowManager.h>
#import "TTContactsRecommendUserTableViewCell.h"
#import "SSAvatarView.h"
#import "TTAlphaThemedButton.h"
#import "TTVerifyIconHelper.h"
#import "SSAvatarView+VerifyIcon.h"

@implementation TTRecommendUserModel

- (instancetype)initWithFRUserRelationContactFriendsUserStructModel:(FRUserRelationContactFriendsUserStructModel *)model {
    self = [super init];
    if (self) {
        self.user_id = model.user_id;
        self.screen_name = model.screen_name;
        self.mobile_name = model.mobile_name;
        self.avatar_url = model.avatar_url;
        self.user_auth_info = model.user_auth_info;
        self.recommend_reason = model.recommend_reason;
        self.selected = YES;
        self.selectable = YES;
    }

    return self;
}

@end


@interface TTContactsRecommendUserTableViewCell()

@property (nonatomic, strong) TTRecommendUserModel *userModel;
@property (nonatomic, strong) UITapGestureRecognizer *avatarViewTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *nameLabelTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *descLabelTapGestureRecognizer;

@end


@implementation TTContactsRecommendUserTableViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.selectButton];
        [self addSubview:self.bottomLineView];

        self.avatarView.left = 15.f;
        self.avatarView.top = 15.f;

        [self.nameLabel sizeToFit];
        self.nameLabel.left = self.avatarView.right + 10.f;
        self.nameLabel.top = 15.f;
        self.nameLabel.height = 24.f;

        [self.descLabel sizeToFit];
        self.descLabel.left = self.nameLabel.left;
        self.descLabel.bottom = self.avatarView.bottom;

        self.selectButton.right = self.width - 15;
        self.selectButton.centerY = self.avatarView.centerY;
        self.selectButton.hidden = YES;

        self.bottomLineView.width = self.width;
        self.bottomLineView.height = [TTDeviceHelper ssOnePixel];
        self.bottomLineView.bottom = self.height - 1;

        UITapGestureRecognizer *avatarViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileAction:)];
        self.avatarView.userInteractionEnabled = YES;
        [self.avatarView addGestureRecognizer:avatarViewTapGestureRecognizer];
        self.avatarViewTapGestureRecognizer = avatarViewTapGestureRecognizer;

        UITapGestureRecognizer *nameLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileAction:)];
        self.nameLabel.userInteractionEnabled = YES;
        [self.nameLabel addGestureRecognizer:nameLabelTapGestureRecognizer];
        self.nameLabelTapGestureRecognizer = nameLabelTapGestureRecognizer;

        UITapGestureRecognizer *descLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileAction:)];
        self.descLabel.userInteractionEnabled = YES;
        [self.descLabel addGestureRecognizer:descLabelTapGestureRecognizer];
        self.descLabelTapGestureRecognizer = descLabelTapGestureRecognizer;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendFollowAction:) name:RelationActionSuccessNotification object:nil];

        [self themeChanged:nil];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.nameLabel sizeToFit];
    [self.descLabel sizeToFit];

    CGFloat maxWidth = self.width - 15 - 44 - 10 - 22 - 30;

    if (self.selectButton.hidden) {
        maxWidth = self.width - 15 - 44 - 10 - 15;
    }

    self.nameLabel.top = 13.f;
    self.nameLabel.width = MIN(self.nameLabel.width, maxWidth);

    self.descLabel.width = MIN(self.descLabel.width, maxWidth);
    self.descLabel.bottom = self.avatarView.bottom + 1;

    self.selectButton.right = self.width - 15;
    self.bottomLineView.width = self.width;
    self.bottomLineView.bottom = self.height - 1;
}

- (void)onChange:(id)sender {
    BOOL selected = self.selectButton.selected;
    if (!selected) {
        UIImageView *rotateImg = [[UIImageView alloc] initWithFrame:self.selectButton.bounds];
        rotateImg.image = [UIImage themedImageNamed:@"follow_coldstart_select_red"];
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

    if (self.delegate && [self.delegate respondsToSelector:@selector(addFriendsTableViewCell:didSelectedUser:)]) {
        [self.delegate addFriendsTableViewCell:self didSelectedUser:!selected];
    }
}

- (void)userProfileAction:(UIGestureRecognizer *)gestureRecognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addFriendsTableViewCell:didUserProfile:)]) {
        [self.delegate addFriendsTableViewCell:self didUserProfile:self.userModel.user_id];
    }
}

- (void)friendFollowAction:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *uid = [userInfo stringValueForKey:kRelationActionSuccessNotificationUserIDKey defaultValue:@""];
    NSNumber *type = [userInfo tt_objectForKey:kRelationActionSuccessNotificationActionTypeKey];
    BOOL isFollowing = type.unsignedIntegerValue == FriendActionTypeFollow;

    if (!isEmptyString(uid) && [uid isEqualToString:self.userModel.user_id]) {
        self.selectButton.selected = !isFollowing;
        [self onChange:nil];
    }
}

- (void)configWithUserModel:(TTRecommendUserModel *)userModel {
    _userModel = userModel;

    [self.avatarView showAvatarByURL:userModel.avatar_url];
    NSString *userAuthInfo = userModel.user_auth_info;
    NSString *userDecorationInfo = userModel.user_decoration;
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:userDecorationInfo sureQueryWithID:YES userID:nil];
    self.nameLabel.text = userModel.screen_name;
    self.descLabel.text = userModel.recommend_reason;

    self.selectButton.hidden = !userModel.selectable;
    self.selectButton.selected = userModel.selected;

    if (userModel.userProfileEnabled) {
        self.avatarViewTapGestureRecognizer.enabled = YES;
        self.nameLabelTapGestureRecognizer.enabled = YES;
        self.descLabelTapGestureRecognizer.enabled = YES;
    } else {
        self.avatarViewTapGestureRecognizer.enabled = NO;
        self.nameLabelTapGestureRecognizer.enabled = NO;
        self.descLabelTapGestureRecognizer.enabled = NO;
    }
}

- (SSAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[SSAvatarView alloc] initWithFrame:CGRectMake(0, 0, 44.f, 44.f)];
        _avatarView.avatarImgPadding = 0;
        _avatarView.avatarButton.userInteractionEnabled = NO;
        _avatarView.avatarStyle = SSAvatarViewStyleRound;
        [_avatarView setupVerifyViewForLength:50.f adaptationSizeBlock:nil];

        UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44.f, 44.f)];
        coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        coverView.layer.cornerRadius = 44.f / 2;
        coverView.layer.masksToBounds = YES;
        coverView.userInteractionEnabled = NO;
        coverView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
        [_avatarView addSubview:coverView];
    }

    return _avatarView;
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [SSThemedLabel new];
        _nameLabel.numberOfLines = 1;
        _nameLabel.font = [UIFont boldSystemFontOfSize:15.f];
        _nameLabel.textColorThemeKey = kColorText1;
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

- (TTAlphaThemedButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        _selectButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_selectButton setImage:[UIImage themedImageNamed:@"follow_coldstart_select_red"] forState:UIControlStateSelected];
        [_selectButton setImage:[UIImage themedImageNamed:@"follow_coldstart_unselect_red"] forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(onChange:) forControlEvents:UIControlEventTouchUpInside];
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
