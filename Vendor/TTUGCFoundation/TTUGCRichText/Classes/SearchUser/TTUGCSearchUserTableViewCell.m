//
//  TTUGCSearchUserTableViewCell.m
//  Article
//
//  Created by Jiyee Sheng on 05/09/2017.
//
//

#import <TTAvatar/SSAvatarView+VerifyIcon.h>
#import "TTUGCSearchUserTableViewCell.h"
#import "TTIconLabel.h"
#import "UIViewAdditions.h"
#import "FRApiModel.h"
#import "TTDeviceHelper.h"
#import "TTBusinessManager+StringUtils.h"

@interface TTUGCSearchUserTableViewCell ()

@end

@implementation TTUGCSearchUserTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.bottomLineView];

        self.avatarView.left = 15.f;
        self.avatarView.top = 15.f;

        self.nameLabel.left = self.avatarView.right + 10.f;
        self.nameLabel.top = 15.f;
        self.nameLabel.height = 24.f;

        self.descLabel.left = self.nameLabel.left;
        self.descLabel.bottom = self.avatarView.bottom;

        self.bottomLineView.left = 15.f;
        self.bottomLineView.width = self.width - 15.f;
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

    CGFloat maxWidth = self.width - 15 - 44 - 10 - 15;

    self.nameLabel.top = 13.f;
    self.nameLabel.width = MIN(self.nameLabel.width, maxWidth);
    self.nameLabel.height = 24.f;

    self.descLabel.width = MIN(self.descLabel.width, maxWidth);
    self.descLabel.bottom = self.avatarView.bottom + 1;

    self.bottomLineView.width = self.width;
    self.bottomLineView.bottom = self.height - 1;
}

- (void)configWithUserModel:(FRPublishPostSearchUserStructModel *)userModel {
    if (!userModel) return;

    CGFloat maxWidth = self.width;

    [self.avatarView showAvatarByURL:userModel.user.info.avatar_url];
    NSString *userAuthInfo = userModel.user.info.user_auth_info;
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:userModel.user.info.user_decoration sureQueryWithID:NO userID:nil];

    NSDictionary *attributes = @{
        NSFontAttributeName: self.nameLabel.font
    };

    NSString *remarkName = @"";
    CGFloat remarkNameWidth = 0;
    if (!isEmptyString(userModel.user.relation.remark_name)) {
        remarkName = [NSString stringWithFormat:@" (%@)", userModel.user.relation.remark_name];
        remarkNameWidth = [remarkName sizeWithAttributes:attributes].width;
    }

    NSString *userName = userModel.user.info.name;

    CGFloat constraintsWidth = maxWidth - 15 - 44 - 10 - remarkNameWidth - 15;
    if (!isEmptyString(userModel.user.info.media_id)) {
        constraintsWidth -= 32;
    }

    NSString *ellipsisUserName = [self stringWithUserName:userName constraintsWitdh:constraintsWidth];

    SSThemedLabel *nameLabel = (SSThemedLabel *) self.nameLabel.label;

    NSString *name = [NSString stringWithFormat:@"%@%@", ellipsisUserName, remarkName];

    NSString *userNameCommonPrefix = [ellipsisUserName commonPrefixWithString:userName options:NSCaseInsensitiveSearch];

    // Highlight Keywords
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:name];
    if (userModel.highlight.name.count > 0) {
        for (NSNumber *location in userModel.highlight.name) {
            if (location.unsignedIntegerValue < userNameCommonPrefix.length) {
                // 处理 emoji 表情字符数问题
                NSRange range = [self rangeOfComposedCharacterSequences:name atCodePoint:location.unsignedIntegerValue];
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                                value:SSGetThemedColorWithKey(kColorText4)
                                                range:range];
            }
        }
    }

    if (userModel.highlight.remark_name.count > 0) {
        for (NSNumber *location in userModel.highlight.remark_name) {
            NSUInteger highlightLocation = location.unsignedIntegerValue + 2; // 空格和左括号
            if (highlightLocation < name.length - 1) { // 右括号
                NSRange range = [self rangeOfComposedCharacterSequences:remarkName atCodePoint:highlightLocation];
                range.location += ellipsisUserName.length; // 这里避免重复计算 ellipsisUserName 的长度
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                                value:SSGetThemedColorWithKey(kColorText4)
                                                range:range];
            }
        }
    }

    nameLabel.attributedText = mutableAttributedString;

    [self.nameLabel removeAllIcons];
    if (!isEmptyString(userModel.user.info.media_id)) {
        self.nameLabel.iconSpacing = 4.f;
        [self.nameLabel addIconWithImageName:@"toutiaohao" size:CGSizeMake(30, 15)];
        self.nameLabel.labelMaxWidth = maxWidth - self.nameLabel.iconContainerWidth;
    } else {
        self.nameLabel.labelMaxWidth = maxWidth;
    }
    [self.nameLabel refreshIconView];

    NSNumber *followersCount = userModel.user.relation_count.followers_count;
    NSString *followersText = @"";

    if (followersCount.integerValue > 0) {
        followersText = [TTBusinessManager formatCommentCount:followersCount.longLongValue];
        followersText = [followersText stringByAppendingString:@"粉丝  "];
    }

    if (userModel.user.info.desc) {
        followersText = [followersText stringByAppendingString:userModel.user.info.desc];
    }

    self.descLabel.text = followersText;
}

- (NSRange)rangeOfComposedCharacterSequences:(NSString *)string atCodePoint:(NSUInteger)codePoint {
    NSUInteger codeUnit = 0;
    NSRange result = NSMakeRange(0, 0);
    for (NSUInteger index = 0; index <= codePoint; index++) {
        result = [string rangeOfComposedCharacterSequenceAtIndex:codeUnit];
        codeUnit += result.length;
    }

    return result;
}

- (NSString *)stringWithUserName:(NSString *)userName constraintsWitdh:(CGFloat)constraintsWidth {
    if (isEmptyString(userName)) {
        return nil;
    }

    NSString *ellipsis = @"...";

    // 按加粗字体简化计算
    NSDictionary *attributes = @{
        NSFontAttributeName: self.nameLabel.font
    };
    NSMutableString *truncatedString = [userName mutableCopy];

    NSRange range = NSMakeRange(userName.length, 1);

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

#pragma mark - getter and setter

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

- (TTIconLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [TTIconLabel new];
        _nameLabel.numberOfLines = 1;
        _nameLabel.font = [UIFont boldSystemFontOfSize:15.f];
        _nameLabel.textColorThemeKey = kColorText1;
        _nameLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _nameLabel.enableAsync = NO;
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

- (SSThemedView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }

    return _bottomLineView;
}

@end
