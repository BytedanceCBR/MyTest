//
//  TTMessageNotificationTipsView.m
//  Article
//
//  Created by lizhuoli on 17/3/24.
//
//

#import "TTMessageNotificationTipsView.h"
#import "TTMessageNotificationTipsModel.h"
#import "TTMessageNotificationManager.h"
#import "TTRoute.h"
#import "TTUGCEmojiParser.h"

#define kTTMessageNotificationTipsViewTitleFontSize [TTDeviceUIUtils tt_newFontSize:16]
#define kTTMessageNotificationTipsViewContentFontSize [TTDeviceUIUtils tt_newFontSize:14]
#define kTTMessageNotificationTipsViewAvatarLeft [TTDeviceUIUtils tt_padding:15]
#define kTTMessageNotificationTipsViewAvatarTop [TTDeviceUIUtils tt_padding:12]
#define kTTMessageNotificationTipsViewAvatarNormalLength 50
#define kTTMessageNotificationTipsViewAvatarLength [TTDeviceUIUtils tt_padding:50]
#define kTTMessageNotificationTipsViewNameActionHorizontalSpacing [TTDeviceUIUtils tt_padding:5]
#define kTTMessageNotificationTipsViewTitleAvatarHorizontalSpacing [TTDeviceUIUtils tt_padding:14]
#define kTTMessageNotificationTipsViewTitleAvatarBaselineSpacing [TTDeviceUIUtils tt_padding:2]

@interface TTMessageNotificationTipsView ()

@property (nonatomic, strong, readwrite) TTAsyncCornerImageView *avatarView;
@property (nonatomic, strong, readwrite) SSThemedLabel *nameLabel;
@property (nonatomic, strong, readwrite) SSThemedLabel *actionLabel;
@property (nonatomic, strong, readwrite) SSThemedLabel *contentLabel;
@property (nonatomic, strong, readwrite) SSThemedView *calloutView;
@property (nonatomic, strong, readwrite) NSString      *actionType;
@property (nonatomic, strong, readwrite) NSString      *msgID;

@end

@implementation TTMessageNotificationTipsView

- (instancetype)initWithFrame:(CGRect)frame tabCenterX:(CGFloat)centerX
{
    self = [super initWithFrame:frame];
    if (self) {
        self.calloutView = [[SSThemedView alloc] initWithFrame:CGRectMake(kTTMessageNotificationTipsViewPadding, 0, CGRectGetWidth(frame) - 2 * kTTMessageNotificationTipsViewPadding, CGRectGetHeight(frame))];
        self.calloutView.borderColorThemeKey = kColorLine7Highlighted;
        self.calloutView.layer.borderWidth = 0.5f;
        self.calloutView.backgroundColors = @[@"ffffff",@"1b1b1b"];
        self.calloutView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f].CGColor;
        self.calloutView.layer.shadowOffset = CGSizeMake(0.f, 2.f);
        self.calloutView.layer.shadowRadius = 6.f;
        self.calloutView.layer.shadowOpacity = 1.f;
        
        [self addSubview:self.calloutView];
    }
    return self;
}

- (void)configWithModel:(TTMessageNotificationTipsModel *)tipsModel
{
    TTMessageNotificationTipsImportantModel *model = tipsModel.important;
    
    if (!model || ![model isKindOfClass:[TTMessageNotificationTipsImportantModel class]]) {
        return;
    }
    
    self.actionType = tipsModel.actionType;
    self.msgID = model.msgID;
    
    self.nameLabel.text = model.userName;
    self.actionLabel.text = model.action;
    self.contentLabel.attributedText = [TTUGCEmojiParser parseInTextKitContext:model.content fontSize:kTTMessageNotificationTipsViewContentFontSize];

    [self.avatarView tt_setImageWithURLString:model.thumbUrl];
    
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:model.userAuthInfo decoratorInfo:model.userDecoration sureQueryWithID:YES userID:nil];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.nameLabel sizeToFit];
    [self.actionLabel sizeToFit];
    [self.contentLabel sizeToFit];
    
    CGFloat labelMaxWidth = CGRectGetWidth(self.calloutView.frame) - CGRectGetMaxX(self.avatarView.frame) - kTTMessageNotificationTipsViewTitleAvatarHorizontalSpacing - kTTMessageNotificationTipsViewAvatarLeft;
    self.actionLabel.width = MIN(self.actionLabel.width, labelMaxWidth - kTTMessageNotificationTipsViewNameActionHorizontalSpacing);
    CGFloat nameMaxWidth = labelMaxWidth - self.actionLabel.width - kTTMessageNotificationTipsViewNameActionHorizontalSpacing;
    nameMaxWidth = (nameMaxWidth > 0) ? nameMaxWidth : 0;
    // 调整大小，优先显示动作标签，名称标签可以出省略号
    self.nameLabel.width = MIN(self.nameLabel.width, nameMaxWidth);
    
    if (isEmptyString(self.contentLabel.text)) {
        self.nameLabel.left = self.avatarView.right + kTTMessageNotificationTipsViewTitleAvatarHorizontalSpacing;
        self.nameLabel.centerY = self.avatarView.centerY;
        self.actionLabel.left = self.nameLabel.right + kTTMessageNotificationTipsViewNameActionHorizontalSpacing;
        self.actionLabel.centerY = self.avatarView.centerY;
    } else {
        self.nameLabel.left = self.avatarView.right + kTTMessageNotificationTipsViewTitleAvatarHorizontalSpacing;
        self.nameLabel.top = self.avatarView.top + kTTMessageNotificationTipsViewTitleAvatarBaselineSpacing;
        self.actionLabel.left = self.nameLabel.right + kTTMessageNotificationTipsViewNameActionHorizontalSpacing;
        self.actionLabel.top = self.nameLabel.top;
        self.contentLabel.left = self.avatarView.right + kTTMessageNotificationTipsViewTitleAvatarHorizontalSpacing;
        self.contentLabel.width = MIN(self.contentLabel.width, self.calloutView.width - self.avatarView.right - kTTMessageNotificationTipsViewTitleAvatarHorizontalSpacing - kTTMessageNotificationTipsViewAvatarLeft);
        self.contentLabel.bottom = self.avatarView.bottom - kTTMessageNotificationTipsViewTitleAvatarBaselineSpacing;
    }
}

- (SSThemedLabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[SSThemedLabel alloc] init];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.font = [UIFont boldSystemFontOfSize:kTTMessageNotificationTipsViewTitleFontSize];
        _nameLabel.textColorThemeKey = kColorText1;
        [self.calloutView addSubview:_nameLabel];
    }
    
    return _nameLabel;
}

- (SSThemedLabel *)actionLabel
{
    if (!_actionLabel) {
        _actionLabel = [[SSThemedLabel alloc] init];
        _actionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _actionLabel.font = [UIFont boldSystemFontOfSize:kTTMessageNotificationTipsViewTitleFontSize];
        _actionLabel.textColorThemeKey = kColorText1;
        [self.calloutView addSubview:_actionLabel];
    }
    
    return _actionLabel;
}

- (SSThemedLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[SSThemedLabel alloc] init];
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.font = [UIFont systemFontOfSize:kTTMessageNotificationTipsViewContentFontSize];
        _contentLabel.textColorThemeKey = kColorText2;
        [self.calloutView addSubview:_contentLabel];
    }
    
    return _contentLabel;
}

- (TTAsyncCornerImageView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(kTTMessageNotificationTipsViewAvatarLeft, kTTMessageNotificationTipsViewAvatarTop, kTTMessageNotificationTipsViewAvatarLength, kTTMessageNotificationTipsViewAvatarLength) allowCorner:YES];
        _avatarView.cornerRadius = kTTMessageNotificationTipsViewAvatarLength / 2;
        [_avatarView setupVerifyViewForLength:kTTMessageNotificationTipsViewAvatarNormalLength adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_newSize:standardSize];
        }];
        [self.calloutView addSubview:_avatarView];
    }
    
    return _avatarView;
}

@end
