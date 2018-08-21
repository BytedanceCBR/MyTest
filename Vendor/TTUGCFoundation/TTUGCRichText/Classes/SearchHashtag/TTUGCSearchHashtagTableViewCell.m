//
//  TTUGCSearchHashtagTableViewCell.m
//  Article
//
//  Created by Jiyee Sheng on 25/09/2017.
//
//

#import <TTAvatar/SSAvatarView.h>
#import "TTUGCSearchHashtagTableViewCell.h"
#import "NSString+UGCUtils.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"

@implementation TTUGCSearchHashtagTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self addSubview:self.avatarView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.cornerImageView];
        [self addSubview:self.bottomLineView];

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

- (void)configWithHashtagModel:(FRPublishPostSearchHashtagStructModel *)hashtagModel row:(NSInteger)row {
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
            if (location.unsignedIntegerValue + 1 < commonPrefixString.length) {
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
