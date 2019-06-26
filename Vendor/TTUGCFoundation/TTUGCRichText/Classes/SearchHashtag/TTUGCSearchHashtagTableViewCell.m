//
//  TTUGCSearchHashtagTableViewCell.m
//  Article
//
//  Created by Jiyee Sheng on 25/09/2017.
//
//

#import "TTUGCSearchHashtagTableViewCell.h"
#import "NSString+UGCUtils.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"

@implementation TTUGCSearchHashtagTableHeaderViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self.contentView addSubview:self.separatorView];
        [self.contentView addSubview:self.titleLabel];
    }

    return self;
}

- (void)configWithHashtagHeaderModel:(TTUGCHashtagHeaderModel *)hashtagHeaderModel {
    self.titleLabel.text = hashtagHeaderModel.text;
    [self.titleLabel sizeToFit];
    self.titleLabel.width = MIN(self.titleLabel.width, self.contentView.width - 30.f);
    self.titleLabel.left = 15.f;
    self.titleLabel.bottom = self.contentView.bottom;

    self.separatorView.hidden = !hashtagHeaderModel.showTopSeparator;
    self.separatorView.width = self.contentView.width;
    self.separatorView.left = 0;
    self.separatorView.height = 6.f;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.font = [UIFont systemFontOfSize:16.f];
    }

    return _titleLabel;
}

- (SSThemedView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[SSThemedView alloc] init];
        _separatorView.backgroundColorThemeKey = kColorBackground3;
    }

    return _separatorView;
}

@end

@implementation TTUGCSearchHashtagTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.descLabel];
        [self.contentView addSubview:self.discussLabel];
        [self.contentView addSubview:self.cornerImageView];
        [self.contentView addSubview:self.bottomLineView];

        self.avatarView.left = 15.f;
        self.avatarView.top = 15.f;

        self.nameLabel.left = self.avatarView.right + 10.f;
        self.nameLabel.top = 15.f;
        self.nameLabel.height = 24.f;

        self.descLabel.left = self.nameLabel.left;
        self.descLabel.bottom = self.avatarView.bottom;

        self.cornerImageView.width = 16.f;
        self.cornerImageView.height = 16.f;
        self.cornerImageView.right = self.avatarView.right;
        self.cornerImageView.bottom = self.avatarView.bottom;

        self.bottomLineView.left = 15.f;
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
    [self.discussLabel sizeToFit];

    CGFloat nameMaxWidth = self.width - 15 - 44 - 10 - 15 - self.discussLabel.width - 30;
    self.nameLabel.top = 13.f;
    self.nameLabel.width = MIN(self.nameLabel.width, nameMaxWidth);
    self.nameLabel.height = 24.f;

    if (isEmptyString(self.descLabel.text)) {
        self.nameLabel.centerY = self.avatarView.centerY;
    }

    CGFloat descMaxWidth = self.width - 15 - 44 - 10 - 15;
    self.descLabel.width = MIN(self.descLabel.width, descMaxWidth);
    self.descLabel.bottom = self.avatarView.bottom;

    self.discussLabel.centerY = self.nameLabel.centerY;
    self.discussLabel.right = self.width - 15.f;

    self.bottomLineView.width = self.width;
    self.bottomLineView.bottom = self.contentView.bottom;
}

- (void)configWithHashtagModel:(TTUGCHashtagModel *)hashtagModel row:(NSInteger)row longSeparatorLine:(BOOL)longSeparatorLine {
    if (!hashtagModel) return;

    CGFloat maxWidth = self.width;

    [self.avatarView showAvatarByURL:hashtagModel.forum.avatar_url];

    NSString *forumName = [NSString stringWithFormat:@"#%@#", hashtagModel.forum.forum_name];

    CGFloat constraintsWidth = maxWidth - 15 - 44 - 10 - 15;

    NSString *ellipsisForumName = [forumName ellipsisStringWithFont:self.nameLabel.font constraintsWidth:constraintsWidth];

    NSString *commonPrefixString = [ellipsisForumName commonPrefixWithString:forumName options:NSCaseInsensitiveSearch];

    // Highlight Keywords
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:ellipsisForumName];
    if (hashtagModel.highlight.forum_name.count > 0) {
        for (NSNumber *location in hashtagModel.highlight.forum_name) {
            if ([location isKindOfClass:[NSNumber class]] && location.unsignedIntegerValue + 1 < commonPrefixString.length) {
                // 处理 emoji 表情字符数问题
                NSRange range = [commonPrefixString rangeOfComposedCharacterSequenceAtCodePoint:location.unsignedIntegerValue + 1];
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                                value:SSGetThemedColorWithKey(kColorText4)
                                                range:range];
            }
        }
    }

    self.nameLabel.attributedText = mutableAttributedString;

    self.descLabel.text = hashtagModel.forum.desc;
    self.discussLabel.text = hashtagModel.forum.talk_count_str;

    if (hashtagModel.canBeCreated) {
        self.descLabel.font = [UIFont boldSystemFontOfSize:14.f];
    } else {
        self.descLabel.font = [UIFont systemFontOfSize:14.f];
    }

    if (longSeparatorLine) {
        self.bottomLineView.left = 0.f;
    } else {
        self.bottomLineView.left = 15.f;
    }

    if (row >= 1 && row <= 3) {
        switch (row) {
            case 1:
                self.cornerImageView.imageName = @"topic_no_1";
                break;
            case 2:
                self.cornerImageView.imageName = @"topic_no_2";
                break;
            case 3:
                self.cornerImageView.imageName = @"topic_no_3";
                break;
            default:
                break;
        }

        self.cornerImageView.hidden = NO;
    } else {
        self.cornerImageView.hidden = YES;
    }
}


#pragma mark - getter and setter

- (SSAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[SSAvatarView alloc] initWithFrame:CGRectMake(0, 0, 44.f, 44.f)];
        _avatarView.avatarImgPadding = 0;
        _avatarView.avatarButton.userInteractionEnabled = NO;
        _avatarView.avatarStyle = SSAvatarViewStyleRectangle;
        _avatarView.rectangleAvatarImgRadius = 0.f;

        CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, SSGetThemedColorWithKey(kColorBackground2).CGColor);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _avatarView.defaultHeadImg = image;
    }

    return _avatarView;
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [SSThemedLabel new];
        _nameLabel.numberOfLines = 1;
        _nameLabel.font = [UIFont boldSystemFontOfSize:16.f];
        _nameLabel.textColorThemeKey = kColorText1;
        _nameLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    }

    return _nameLabel;
}

- (SSThemedLabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [SSThemedLabel new];
        _descLabel.numberOfLines = 1;
        _descLabel.font = [UIFont systemFontOfSize:14.f];
        _descLabel.textColorThemeKey = kColorText1;
        _descLabel.contentInset = UIEdgeInsetsMake(1.f, 0, 1.f, 0);
    }

    return _descLabel;
}

- (SSThemedLabel *)discussLabel {
    if (!_discussLabel) {
        _discussLabel = [SSThemedLabel new];
        _discussLabel.numberOfLines = 1;
        _discussLabel.font = [UIFont systemFontOfSize:13.f];
        _discussLabel.textColorThemeKey = kColorText3;
    }

    return _discussLabel;
}

- (SSThemedImageView *)cornerImageView {
    if (!_cornerImageView) {
        _cornerImageView = [[SSThemedImageView alloc] init];
    }

    return _cornerImageView;
}

- (SSThemedView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
    }

    return _bottomLineView;
}

@end
