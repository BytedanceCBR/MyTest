//
//  TTVideoDetailGroupUnifyADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "NSString-Extension.h"
#import "TTLabelTextHelper.h"
#import "TTVideoDetailGroupUnifyADView.h"
#import "TTAdDetailViewHelper.h"

#define kGroupHorizonPadding 10

#define kGroupDislikeImageWidth 10
#define kGroupDislikeImageTopPadding 14
#define kGroupDislikeImageRightPadding 0
#define kGroupDislikeImageLeftPadding 15

@implementation TTVideoDetailGroupUnifyADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_unify_groupPic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.actionButton];
        [self addSubview:self.bottomContainerView];
        [self sendSubviewToBack:self.bottomContainerView];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    [super setAdModel:adModel];
    
    self.sourceLabel.text = [adModel sourceText];
    [self.sourceLabel sizeToFit];
    
    [self.actionButton setTitle:adModel.actionButtonText forState:UIControlStateNormal];
    self.actionButton.size = CGSizeMake(kActionButtonWidth, kActionButtonHeight);
    [self layoutVideo:adModel];
}

- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    [super layoutVideo:adModel];
    
    self.dislikeView.center = CGPointMake(self.width - kGroupDislikeImageWidth/2, kGroupDislikeImageTopPadding + kGroupDislikeImageWidth/2);
    CGFloat dislikePadding = self.adModel.showDislike ? kGroupDislikeImageWidth + kGroupDislikeImageLeftPadding:0;
    const CGFloat maxTitleWidth = self.width- 2 * kVideoHoriMargin - dislikePadding;
    self.titleLabel.width = maxTitleWidth;

    
    self.bottomContainerView.frame = CGRectMake(self.groupPicView.left, self.groupPicView.top, self.groupPicView.width, self.groupPicView.height + kActionButtonHeight + 2*kVideoActionButtonPadding);
    
    CGFloat x = self.groupPicView.left, y = self.groupPicView.bottom;
    CGFloat containWidth = self.groupPicView.width;
    
    const CGFloat centerY = y + kVideoActionButtonPadding + kActionButtonHeight / 2;
    self.actionButton.centerY = centerY;
    self.actionButton.right = containWidth - kGroupHorizonPadding;
    
    self.sourceLabel.left = x + kGroupHorizonPadding;
    self.sourceLabel.centerY = centerY;
    CGFloat sourceMaxWidth = containWidth - kAdLabelWidth - kActionButtonWidth - kGroupHorizonPadding * 2 - 5 * 2;
    self.sourceLabel.width = [self.sourceLabel.text tt_sizeWithMaxWidth:sourceMaxWidth font:self.sourceLabel.font].width;
    self.adLabel.left = self.sourceLabel.right + 5;
    self.adLabel.centerY = centerY;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat dislikePadding = adModel.showDislike ? kGroupDislikeImageWidth + kGroupDislikeImageLeftPadding : 0;
    const CGFloat maxTitleWidth = width - 2 * kVideoHoriMargin - dislikePadding;
    CGFloat height = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:kDetailAdTitleFontSize forWidth:maxTitleWidth forLineHeight:kDetailAdTitleLineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    height += [ExploreDetailADGroupPicView heightForWidth:width];
    height += kVideoTitleTopPadding + kVideoTitleBottomPadding + kActionButtonHeight + 2*kVideoActionButtonPadding + kVideoAppPhoneBottomPadding;
    return height;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_details";
}

#pragma mark - getter

- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* sourceLabel = [super sourceLabel];
    sourceLabel.textColorThemeKey = kColorText2;
    sourceLabel.font = [UIFont systemFontOfSize:kDetailAdSourceFontSize];
    return sourceLabel;
}

- (TTAlphaThemedButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _actionButton.layer.cornerRadius = 6;
        _actionButton.layer.borderWidth = 1;
        _actionButton.borderColorThemeKey = kColorLine3;
        _actionButton.clipsToBounds = YES;
        _actionButton.titleColorThemeKey = kColorText6;
        [_actionButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

@end
