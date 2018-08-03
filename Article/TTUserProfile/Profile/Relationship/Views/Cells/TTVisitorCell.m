//
//  TTVisitorCell.m
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import "TTVisitorCell.h"
#import "SSAvatarView+VerifyIcon.h"
#import "TTIconLabel.h"
#import "TTProfileThemeConstants.h"
#import <TTInstallJSONHelper.h>

@interface TTVisitorCell ()
@property (nonatomic, strong) SSAvatarView      *avatarView;
@property (nonatomic, strong) TTIconLabel       *titleLabel;
@property (nonatomic, strong) SSThemedLabel     *lastVisitTimeLabel;
@property (nonatomic, strong) SSThemedImageView *arrowImageView;
@property (nonatomic, strong, readwrite) SSThemedView *textContainerView;
@end

@implementation TTVisitorCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        self.topLineEnabled = NO;
        self.bottomLineEnabled = NO;
        
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.textContainerView];
        [self.contentView addSubview:self.arrowImageView];
        [self.textContainerView addSubview:self.titleLabel];
        [self.textContainerView addSubview:self.lastVisitTimeLabel];
        
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).with.offset([self.class spacingToMargin]);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-[TTDeviceUIUtils tt_padding:30.f/2]);
            make.width.height.mas_equalTo([self.class imageSize]);
        }];
        [_textContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_avatarView);
            make.right.equalTo(_arrowImageView.mas_left).with.offset(-[self.class spacingToMargin]);
            make.left.equalTo(_avatarView.mas_right).with.offset([self.class spacingOfAvatarTitle]);
            make.top.equalTo(_titleLabel);
            make.bottom.equalTo(_lastVisitTimeLabel);
        }];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_textContainerView.mas_right);
            make.left.mas_equalTo(0);
        }];

        [_lastVisitTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_textContainerView);
            make.left.mas_equalTo(0);
            make.top.equalTo(_titleLabel.mas_bottom).with.offset([TTDeviceUIUtils tt_padding:12.f/2]);
        }];
        
        CGSize size = _arrowImageView.image.size;
        [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(size);
            make.centerY.equalTo(self.avatarView.mas_centerY);
            make.right.equalTo(self.contentView.mas_right).with.offset(-[self.class spacingToMargin]);
        }];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // backgroundview frame
    self.bgView.frame = CGRectMake(0, self.contentView.height - [TTDeviceUIUtils tt_padding:132.f/2], self.contentView.width, [TTDeviceUIUtils tt_padding:132.f/2] - 0.5f);
    
    [_lastVisitTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).with.offset(isEmptyString(_lastVisitTimeLabel.text) ? 0 : [TTDeviceUIUtils tt_padding:12.f/2]);;
    }];
}

/**
 *      Layout as follows
 *  ----------------------------------
 *  Image  titleLabel [V] [T]
 *  Image                      >[arrow]
 *  Image  [visitedTimeLabel]
 *  -----------------------------------
 */
- (void)reloadWithVisitorModel:(TTVisitorFormattedModelItem *)aModel {
    if (!aModel) return;

    [self.avatarView showAvatarByURL:aModel.avatar_url];
    self.titleLabel.text = aModel.screen_name ? : @" ";
    self.lastVisitTimeLabel.text = [aModel formattedTimeLabel];
    
    [self.titleLabel removeAllIcons];
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:aModel.userAuthInfo decoratorInfo:aModel.userDecoration sureQueryWithID:YES userID:nil];

    if ([aModel isToutiaohaohaoUser]) {
        [self.titleLabel addIconWithImageName:@"toutiaohao" size:CGSizeMake(30, 15)];
    }
    [self.titleLabel refreshIconView];
    
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (self.shouldHighlight) {
        [super setHighlighted:highlighted animated:animated];
        self.bgView.backgroundColorThemeKey = highlighted ? kColorBackground4Highlighted : kColorBackground4;
    }
}

#pragma mark - loazied of properties

- (TTIconLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[TTIconLabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.textColorThemeKey = kTTSocialHubTitleColorKey;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kTTSocialHubTitleFontSize]];
    }
    return _titleLabel;
}

- (SSThemedLabel *)lastVisitTimeLabel {
    if (!_lastVisitTimeLabel) {
        _lastVisitTimeLabel = [[SSThemedLabel alloc] init];
        _lastVisitTimeLabel.numberOfLines = 1;
        _lastVisitTimeLabel.textAlignment = NSTextAlignmentLeft;
        _lastVisitTimeLabel.backgroundColor = [UIColor clearColor];
        _lastVisitTimeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _lastVisitTimeLabel.textColorThemeKey = kColorText3;
        _lastVisitTimeLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:28.f/2]];
    }
    return _lastVisitTimeLabel;
}


- (SSThemedView *)textContainerView {
    if (!_textContainerView) {
        _textContainerView = [SSThemedView new];
        _textContainerView.backgroundColor = [UIColor clearColor];
    }
    return _textContainerView;
}

- (SSAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[SSAvatarView alloc] initWithFrame:CGRectMake(0, 0, kTTSocialHubImageWidth, kTTSocialHubImageWidth)];
        _avatarView.avatarStyle      = SSAvatarViewStyleRound;
        _avatarView.avatarImgPadding = [TTDeviceHelper ssOnePixel];
        _avatarView.rectangleAvatarImgRadius = 0.f;
        _avatarView.userInteractionEnabled = NO;
        [_avatarView setupVerifyViewForLength:36.f adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_size:standardSize];
        } adaptationOffsetBlock:^UIOffset(UIOffset standardOffset) {
            return UIOffsetMake(standardOffset.horizontal - [TTDeviceHelper ssOnePixel], standardOffset.vertical - [TTDeviceHelper ssOnePixel]);
        }];
    }
    return _avatarView;
}

- (SSThemedImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[SSThemedImageView alloc] init];
        _arrowImageView.imageName = @"setting_rightarrow";
        [_arrowImageView sizeToFit];
    }
    return _arrowImageView;
}

+ (CGFloat)spacingOfAvatarTitle {
    return [TTDeviceUIUtils tt_padding:kTTSocialHubSpacingOfAvatarTitle];
}

+ (CGFloat)spacingToMargin {
    return [TTDeviceUIUtils tt_padding:kTTProfileInsetLeft];
}

+ (CGFloat)imageSize {
    return [TTDeviceUIUtils tt_padding:kTTSocialHubImageWidth];
}

/**
 *  spacing between title and verified label
 */
+ (CGFloat)spacingOfNewV {
    return [TTDeviceUIUtils tt_padding:6.f/2];
}

/**
 *  spacing between verified label and toutiaohao label
 */
+ (CGFloat)spacingOfToutiao {
    return [TTDeviceUIUtils tt_padding:8.f/2];
}

+ (CGFloat)cellHeight {
    return [TTDeviceUIUtils tt_padding:(72.f/2 + 60.f/2)];
}
@end
