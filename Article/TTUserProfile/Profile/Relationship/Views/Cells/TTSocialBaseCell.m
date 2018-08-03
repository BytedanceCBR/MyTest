//
//  TTSocialBaseCell.m
//  Article
//
//  Created by liuzuopeng on 8/11/16.
//
//

#import "AKUIHelper.h"
#import "TTSocialBaseCell.h"
#import "TTProfileThemeConstants.h"
#import "TTIconFontDefine.h"
#import "TTLabelTextHelper.h"
#import "TTFollowThemeButton.h"
#import <TTInstallJSONHelper.h>
@interface TTFollowButton : TTAlphaThemedButton
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) SSThemedLabel     *statusTextLabel;
@property (nonatomic, strong) SSThemedImageView *statusImageView;

@property (nonatomic, assign) TTFollowButtonStatusType followStatus;
@property (nonatomic, strong) CAGradientLayer   *backGradientLayer;
@end

@implementation TTFollowButton
+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    TTFollowButton *inst = [super buttonWithType:buttonType];
    if (inst) {
        [inst initSubviews];
    }
    return inst;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    _followStatus = FriendListCellUnitRelationButtonHide;
    
    [self.layer addSublayer:self.backGradientLayer];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.statusImageView];
    [self.containerView addSubview:self.statusTextLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self relayoutIfNeeded];
}

- (void)relayoutIfNeeded {
    NSDictionary *properties = [self propertiesOfFollowStatus:_followStatus];
    
    BOOL      hidden = [properties[@"hidden"] boolValue];
    NSString *text = properties[@"text"];
    NSString *textColorKey = properties[@"textColorKey"];
    NSString *borderColorKey = properties[@"borderColorKey"];
    NSString *backgroundColorKey = properties[@"backgroundColorKey"];
    NSString *imageName = properties[@"imageName"];
    
    self.hidden = hidden;
    if (!isEmptyString(backgroundColorKey)) {
        self.backgroundColor = SSGetThemedColorWithKey(backgroundColorKey);
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    if (!isEmptyString(borderColorKey)) {
        self.layer.borderColor = [SSGetThemedColorWithKey(borderColorKey) CGColor];
    } else {
        self.layer.borderColor = [[UIColor clearColor] CGColor];
    }
    if([text isKindOfClass:[NSString class]]) {
        if (!isEmptyString(text)) {
            _statusTextLabel.hidden = NO;
            _statusTextLabel.text = text;
            [_statusTextLabel sizeToFit];
        } else {
            _statusTextLabel.hidden = YES;
            _statusTextLabel.size = CGSizeZero;
        }
    } else if([text isKindOfClass:[NSMutableAttributedString class]]) {
        _statusTextLabel.hidden = NO;
        _statusTextLabel.attributedText = (NSMutableAttributedString *)text;
        [_statusTextLabel sizeToFit];
    }
    
    if (!isEmptyString(textColorKey)) {
        _statusTextLabel.textColorThemeKey = textColorKey;
    }
    
    if (!isEmptyString(imageName)) {
        _statusImageView.hidden = NO;
        _statusImageView.imageName = imageName;
        _statusImageView.size = self.statusImageView.image.size;
    } else {
        _statusImageView.hidden = YES;
        _statusImageView.size = CGSizeZero;
    }
    
    CGFloat spacing = imageName ? [TTDeviceUIUtils tt_padding:16.f/2] : 0;
    _containerView.size = CGSizeMake(_statusTextLabel.width + spacing + _statusImageView.width, MAX(_statusImageView.height, _statusTextLabel.height));
    _backGradientLayer.frame = self.bounds;
    _containerView.center = CGPointMake(self.width/2, self.height/2);
    _statusImageView.frame = CGRectMake(0, (self.containerView.height - _statusImageView.height)/2, _statusImageView.width, _statusImageView.height);
    _statusTextLabel.frame = CGRectMake(_statusImageView.right + spacing, (self.containerView.height - _statusTextLabel.height)/2, _statusTextLabel.width , _statusTextLabel.height);
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.height / 2;
}

- (NSDictionary *)propertiesOfFollowStatus:(TTFollowButtonStatusType)type {
    BOOL      hidden = NO;
    NSString *text = @"";
    NSString *textColorKey = kColorText12;
    NSString *borderColorKey = nil;
    NSString *backgroundColorKey = kColorBackground8;
    NSString *imageName = nil;
    BOOL isRed = [SSCommonLogic followButtonDefaultColorStyleRed];
    [AKUIHelper CALayerDisableAnimationActionBlock:^{
        self.backGradientLayer.hidden = YES;
    }];
    switch (type) {
        case FriendListCellUnitRelationButtonFollowingFollowed: {
            text = NSLocalizedString(@"互相关注", nil);
            textColorKey = kColorText3;
            borderColorKey = kColorLine1;
            backgroundColorKey= nil;
            break;
        }
        case FriendListCellUnitRelationButtonCancelFollow: {
            text = @"已关注";
            textColorKey = kColorText3;
            borderColorKey = kColorLine1;
            backgroundColorKey = nil;
            break;
        }
        case FriendListCellUnitRelationButtonFollow: {
            text = NSLocalizedString(@"关注", nil);
            textColorKey = kColorText12;
            borderColorKey = nil;
            backgroundColorKey = nil;
            [AKUIHelper CALayerDisableAnimationActionBlock:^{
                self.backGradientLayer.hidden = NO;
            }];
            break;
        }
        case FriendListCellUnitRelationButtonInviteFriend: {
            text = NSLocalizedString(@"告诉TA", nil);
            textColorKey = kColorText12;
            borderColorKey = isRed ? kColorLine4 : kColorLine5;
            backgroundColorKey = isRed ? kColorBackground7 : kColorBackground8;
            
            break;
        }
        case FriendListCellUnitRelationButtonInvitedFriend: {
            text = NSLocalizedString(@"已发送", nil);
            textColorKey = kColorText12;
            borderColorKey = kColorLine7;
            backgroundColorKey = isRed ? kColorBackground7 : kColorBackground8;
            break;
        }
        case FriendListCellUnitRelationButtonCancelBlock:{
            text = NSLocalizedString(@"解除", nil);
            textColorKey = isRed ? kColorText4 : kColorText6;
            borderColorKey = isRed ? kColorLine4 : kColorLine5;
            backgroundColorKey = nil;
            break;
        }
        case FriendListCellUnitRelationButtonBlock: {
            text = NSLocalizedString(@"已解除", nil);
            textColorKey = kColorText3;
//            borderColorKey = kColorLine7;
            backgroundColorKey = kColorBackground2;
            break;
        }
        default: {
            hidden = YES;
            break;
        }
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setValue:text forKey:@"text"];
    [properties setValue:textColorKey forKey:@"textColorKey"];
    [properties setValue:borderColorKey forKey:@"borderColorKey"];
    [properties setValue:backgroundColorKey forKey:@"backgroundColorKey"];
    [properties setValue:imageName forKey:@"imageName"];
    [properties setValue:@(hidden) forKey:@"hidden"];
//    text ? properties[@"text"] = text : nil;
//    textColorKey ? properties[@"textColorKey"] = textColorKey : nil;
//    borderColorKey ? properties[@"borderColorKey"] = borderColorKey : nil;
//    backgroundColorKey ? properties[@"backgroundColorKey"] = backgroundColorKey : nil;
//    imageName ?  properties[@"imageName"] = imageName : nil;
//    properties[@"hidden"] = @(hidden);
    
    return properties;
}

#pragma mark - properties

- (void)setFollowStatus:(TTFollowButtonStatusType)status {
    if (_followStatus != status) {
        _followStatus = status;
        
        [self relayoutIfNeeded];
    }
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.userInteractionEnabled = NO;
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (SSThemedLabel *)statusTextLabel {
    if (!_statusTextLabel) {
        _statusTextLabel = [SSThemedLabel new];
        _statusTextLabel.userInteractionEnabled = NO;
        _statusTextLabel.backgroundColor = [UIColor clearColor];
        _statusTextLabel.textColorThemeKey = kColorText3;
        _statusTextLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:28.f/2]];
    }
    return _statusTextLabel;
}

- (SSThemedImageView *)statusImageView {
    if (!_statusImageView) {
        _statusImageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _statusImageView.userInteractionEnabled = NO;
        _statusImageView.backgroundColor = [UIColor clearColor];
    }
    return _statusImageView;
}

- (CAGradientLayer *)backGradientLayer
{
    if (_backGradientLayer == nil) {
        _backGradientLayer = [AKUIHelper AiKanBackGrandientLayer];
    }
    return _backGradientLayer;
}

+ (CGFloat)width {
    return [TTDeviceUIUtils tt_padding:144.f/2];
}

+ (CGFloat)height {
    return [TTDeviceUIUtils tt_padding:56.f/2];
}
@end



/**
 * TTSocialBaseCell
 */
@interface TTSocialBaseCell ()
@property (nonatomic, strong, readwrite) TTIconLabel  *titleLabel;
@property (nonatomic, strong, readwrite) SSThemedLabel  *subtitle1Label;
@property (nonatomic, strong, readwrite) SSThemedLabel  *subtitle2Label;
@property (nonatomic, strong, readwrite) SSThemedView   *textContainerView;
@property (nonatomic, strong, readwrite) SSAvatarView   *avatarView;
@property (nonatomic, strong, readwrite) TTFollowButton *followStatusButton; //关注按钮

@property (nonatomic, strong, readwrite) UIActivityIndicatorView *loadingIndicator;
@end

@implementation TTSocialBaseCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        self.topLineEnabled    = NO;
        self.bottomLineEnabled = NO;
        
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.textContainerView];
        [self.contentView addSubview:self.followStatusButton];
        [self.contentView addSubview:self.loadingIndicator];
        [self.textContainerView addSubview:self.titleLabel];
        [self.textContainerView addSubview:self.subtitle1Label];
        [self.textContainerView addSubview:self.subtitle2Label];
        
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset([self.class spacingByMargin] + [self.class extraInsetTop]);
            make.left.equalTo(self.contentView.mas_left).with.offset([self.class spacingByMargin]);
            make.width.height.mas_equalTo([self.class imageSize]);
        }];

        [_followStatusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([TTFollowButton width]);
            make.height.mas_equalTo([TTFollowButton height]);
            make.centerY.equalTo(self.avatarView.mas_centerY);
            make.right.equalTo(self.contentView.mas_right).with.offset(-[self.class spacingByMargin]);
        }];
        [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_followStatusButton);
        }];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    _currentFriend       = nil;
    _titleLabel.text     = nil;
    _subtitle1Label.text = nil;
    _subtitle1Label.text = nil;
    _followStatusButton.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutTextContainerIfNeeded];
}

- (void)layoutTextContainerIfNeeded {
    BOOL isToutiaoUser  = [_currentFriend isToutiaohaoUser];
    
    CGFloat offsetX __attribute__((unused)) = 0.f;
    CGFloat offsetY __attribute__((unused)) = 0.f;
    CGFloat buttonWidth = [TTFollowButton width];
    // max width of text container
    CGFloat offsetXOfTextContainer = [self.class imageSize] + [self.class spacingByMargin] + [TTDeviceUIUtils tt_padding:20.f/2];
    CGFloat maxWidth = self.contentView.width - offsetXOfTextContainer - [self.class spacingByMargin] ;
    if (!_followStatusButton.hidden) maxWidth -= (buttonWidth + [TTDeviceUIUtils tt_padding:30.f/2]);
    CGFloat height = [TTLabelTextHelper heightOfText:_titleLabel.text fontSize:_titleLabel.font.pointSize forWidth:maxWidth forLineHeight:_titleLabel.font.lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByTruncatingMiddle];
    
    if (!isEmptyString(_titleLabel.text)) {
        _titleLabel.frame = CGRectMake(offsetX, offsetY, maxWidth, height);
        offsetY = _titleLabel.bottom;
    } else {
        _titleLabel.frame = CGRectMake(offsetX, offsetY, 0, 0);
    }
    
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:_currentFriend.userAuthInfo decoratorInfo:_currentFriend.userDecoration sureQueryWithID:NO userID:nil];

    [_titleLabel removeAllIcons];
    if (isToutiaoUser) {
        _titleLabel.iconSpacing = [self.class spacingOfToutiao];
        [_titleLabel addIconWithImageName:@"toutiaohao" size:CGSizeMake(30, 15)];
        _titleLabel.labelMaxWidth = maxWidth - _titleLabel.iconContainerWidth;
    } else {
        _titleLabel.labelMaxWidth = maxWidth;
    }
    [_titleLabel refreshIconView];
    
    if (!isEmptyString(_subtitle1Label.text)) {
        offsetY += [self.class spacingOfTitle];
        
        CGFloat height = [TTLabelTextHelper heightOfText:_subtitle1Label.text fontSize:_subtitle1Label.font.pointSize forWidth:maxWidth forLineHeight:_subtitle1Label.font.lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByTruncatingMiddle];
        _subtitle1Label.frame = CGRectIntegral(CGRectMake(offsetX, offsetY, maxWidth, height));
        
        offsetY = _subtitle1Label.bottom;
    } else {
        _subtitle1Label.frame = CGRectMake(offsetX, offsetY, maxWidth, 0);
    }
    
    if (!isEmptyString(_subtitle2Label.text)) {
        offsetY += [self.class spacingOfTitle];
        
        CGFloat height = [TTLabelTextHelper heightOfText:_subtitle2Label.text fontSize:_subtitle2Label.font.pointSize forWidth:maxWidth forLineHeight:_subtitle2Label.font.lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByTruncatingMiddle];

        _subtitle2Label.frame = CGRectIntegral(CGRectMake(offsetX, offsetY, maxWidth, height));
        
        offsetY = _subtitle2Label.bottom;
    } else {
        _subtitle2Label.frame = CGRectMake(offsetX, offsetY, maxWidth, 0);
    }
    
    _textContainerView.frame = CGRectMake(offsetXOfTextContainer, (self.contentView.height - offsetY) / 2, maxWidth, offsetY);
}

- (void)reloadWithModel:(TTFriendModel *)aModel {
    if (!aModel) return;
    _currentFriend = aModel;
    
    [_avatarView showAvatarByURL:_currentFriend.avatarURLString];
    _titleLabel.text = [_currentFriend titleString];
    _subtitle1Label.text =  [aModel isAccountUser] ? nil : [_currentFriend subtitle1String];
    _subtitle2Label.text = [_currentFriend subtitle2String];

    // update status of follow button
    TTFollowButtonStatusType type = [self.class friendRelationTypeOfModel:_currentFriend];
    [self updateFollowButtonForType:type];
    
    [self layoutIfNeeded];
}

//- (void)refresh {
//    [_avatarView showAvatarByURL:_currentFriend.avatarURLString];
//    _titleLabel.text = [_currentFriend titleString];
//    _subtitle1Label.text = [_currentFriend subtitle1String];
//    _subtitle2Label.text = [_currentFriend subtitle2String];
//    
//    // update status of follow button
//    TTFollowButtonStatusType type = [self.class friendRelationTypeOfModel:_currentFriend];
//    [self updateFollowButtonForType:type];
//    
//    // update contraints
//    [_textContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(_followStatusButton.hidden ? self.contentView.mas_right : _followStatusButton.mas_left).with.offset(-[TTDeviceUIUtils tt_padding:30.f/2]);
//    }];
//    
//    [self layoutTextContainerIfNeeded];
//}

- (void)updateFollowButtonStatus {
    [self reloadWithModel:_currentFriend];
}

- (void)updateFollowButtonForType:(TTFollowButtonStatusType)type {
    _followStatusButton.followStatus = type;
    if (type == FriendListCellUnitRelationButtonHide ||
        type == FriendListCellUnitRelationButtonLoading) {
        _followStatusButton.hidden = YES;
    } else {
        _followStatusButton.hidden = NO;
    }
}

+ (TTFollowButtonStatusType)friendRelationTypeOfModel:(TTFriendModel *)aModel {
    TTFollowButtonStatusType type = FriendListCellUnitRelationButtonHide;
    if ([aModel isAccountUser]) {
        // 自己不能关注自己
        type = FriendListCellUnitRelationButtonHide;
    } else {
        if (aModel.isFollowed && aModel.isFollowing) {
            type = FriendListCellUnitRelationButtonFollowingFollowed;
        } else if (aModel.isFollowing) {
            type = FriendListCellUnitRelationButtonCancelFollow;
        } else {
            type = FriendListCellUnitRelationButtonFollow;
        }
    }
    return type;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    _followStatusButton.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);
    _followStatusButton.titleLabel.textColor = SSGetThemedColorWithKey(kColorText3);
    [_followStatusButton setTitleColor:SSGetThemedColorWithKey(kColorText3) forState:UIControlStateNormal];
    
    if([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        _loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    } else {
        _loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
}

- (void)setAvatarViewStyle:(NSUInteger)style {
    self.avatarView.avatarStyle = style;
}

- (void)startLoading {
    _loadingIndicator.hidden = NO;
    _followStatusButton.hidden = YES;
    
    [_loadingIndicator startAnimating];
}

- (void)stopLoading {
    _loadingIndicator.hidden = YES;
    _followStatusButton.hidden = NO;
    
    [_loadingIndicator stopAnimating];
}

#pragma mark - events

- (void)followStatusButtonDidTap:(id)sender {
    if ([_delegate respondsToSelector:@selector(socialBaseCell:didTapFollowButton:)]) {
        [_delegate socialBaseCell:self didTapFollowButton:sender];
    }
}

#pragma mark - loazied load of properties

- (TTIconLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[TTIconLabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.textColorThemeKey = [self.class titleColorThemeKey];
        _titleLabel.font = [UIFont systemFontOfSize:[self.class titleFontSize]];
    }
    return _titleLabel;
}

- (SSThemedLabel *)subtitle1Label {
    if (!_subtitle1Label) {
        _subtitle1Label = [[SSThemedLabel alloc] init];
        _subtitle1Label.textAlignment = NSTextAlignmentLeft;
        _subtitle1Label.backgroundColor = [UIColor clearColor];
        _subtitle1Label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _subtitle1Label.textColorThemeKey = [self.class subtitle1ColorThemeKey];
        _subtitle1Label.font = [UIFont systemFontOfSize:[self.class subtitle1FontSize]];
    }
    return _subtitle1Label;
}

- (SSThemedLabel *)subtitle2Label {
    if (!_subtitle2Label) {
        _subtitle2Label = [[SSThemedLabel alloc] init];
        _subtitle2Label.textAlignment = NSTextAlignmentLeft;
        _subtitle2Label.backgroundColor = [UIColor clearColor];
        _subtitle2Label.lineBreakMode = NSLineBreakByTruncatingTail;
        _subtitle2Label.textColorThemeKey = [self.class subtitle2ColorThemeKey];
        _subtitle2Label.font = [UIFont systemFontOfSize:[self.class subtitle2FontSize]];
    }
    return _subtitle2Label;
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
        _avatarView = [[SSAvatarView alloc] initWithFrame:CGRectMake(0, 0, [self.class imageSize], [self.class imageSize])];
        _avatarView.avatarStyle      = SSAvatarViewStyleRound;
        _avatarView.avatarImgPadding = [TTDeviceHelper ssOnePixel];
        _avatarView.borderColorName = kColorLine1;
        _avatarView.rectangleAvatarImgRadius = 0.f;
        _avatarView.userInteractionEnabled = NO;
        UIImage *defaultImage = [UIImage imageWithColor:[UIColor tt_themedColorForKey:kColorBackground2] size:CGSizeMake([self.class imageSize], [self.class imageSize])];
        _avatarView.defaultHeadImg = defaultImage;
        [_avatarView setLocalAvatarImage:[defaultImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
        [_avatarView setupVerifyViewForLength:[self.class imageNormalSize] adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [self.class verifyIconSize:standardSize];
        }];
    }
    return _avatarView;
}

- (TTFollowButton *)followStatusButton {
    if (!_followStatusButton) {
        _followStatusButton = [[TTFollowButton alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_padding:144.f/2], [TTDeviceUIUtils tt_padding:56.f/2])];
        _followStatusButton.enableHighlightAnim = YES;
        _followStatusButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _followStatusButton.layer.cornerRadius = 4;
        _followStatusButton.hidden = YES;
        [_followStatusButton addTarget:self action:@selector(followStatusButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followStatusButton;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        UIActivityIndicatorViewStyle style = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray;
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    }
    return _loadingIndicator;
}

+ (CGFloat)extraInsetTop {
    return 0.f;
}

+ (CGFloat)imageNormalSize{
    return 36.f;
}

+ (CGSize)verifyIconSize:(CGSize)standardSize{
    return [TTVerifyIconHelper tt_size:standardSize];
}

+ (CGFloat)imageSize {
    return [TTDeviceUIUtils tt_padding:kTTSocialHubImageWidth];
}

+ (CGFloat)spacingOfTitle {
    return [TTDeviceUIUtils tt_padding:16.f/2];
}
+ (NSString *)titleColorThemeKey {
    return kTTSocialHubTitleColorKey;
}

+ (NSString *)subtitle1ColorThemeKey {
    return kTTSocialHubSubtitle1ColorKey;
}

+ (NSString *)subtitle2ColorThemeKey {
    return kTTSocialHubSubtitle2ColorKey;
}

+ (NSString *)buttonTextColorThemeKey {
    return kColorText3;
}

+ (CGFloat)titleFontSize {
    return [TTDeviceUIUtils tt_fontSize:kTTSocialHubTitleFontSize];
}

+ (CGFloat)subtitle1FontSize {
    return [TTDeviceUIUtils tt_fontSize:kTTSocialHubSubtitle1FontSize];
}

+ (CGFloat)subtitle2FontSize {
    return [TTDeviceUIUtils tt_fontSize:kTTSocialHubSubtitle2FontSize];
}

+ (CGFloat)buttonTextFontSize {
    return [TTDeviceUIUtils tt_fontSize:14.f];
}

+ (CGFloat)spacingByMargin {
    return [TTDeviceUIUtils tt_padding:30.f/2];
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

+ (CGFloat)cellHeightOfModel:(ArticleFriendModel *)aModel {
    if (!aModel) {
        return 0.f;
    }
    if (isEmptyString([aModel subtitle1String]) || [aModel isAccountUser])
        return [TTDeviceUIUtils tt_padding:134.f/2] + [self extraInsetTop];
    return [TTDeviceUIUtils tt_padding:172.f/2] + [self extraInsetTop];
}
@end
