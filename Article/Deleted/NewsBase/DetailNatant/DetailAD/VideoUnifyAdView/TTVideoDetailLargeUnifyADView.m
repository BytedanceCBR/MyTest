//
//  TTVideoDetailLargeUnifyADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "TTVideoDetailLargeUnifyADView.h"
#import "TTLabelTextHelper.h"
#import "NSString-Extension.h"
#import "TTAdDetailViewHelper.h"

#define kHorizonPadding 10
#define kAppHeight 44
#define kPaddingSourceToTitle 1 //app名称与标题间距(纵向)
#define kLargeDislikeImageWidth 10
#define kLargeDislikeImageTopPadding 14
#define kLargeDislikeImageRightPadding 0
#define kLargeDislikeImageLeftPadding 15

@implementation TTVideoDetailLargeUnifyADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_unify_largePic" forArea:TTAdDetailViewAreaVideo];
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
    
    self.dislikeView.center = CGPointMake(self.width - kLargeDislikeImageWidth/2, kLargeDislikeImageTopPadding + kLargeDislikeImageWidth/2);
    const CGFloat dislikePadding = self.adModel.showDislike? kLargeDislikeImageWidth + kLargeDislikeImageLeftPadding:0;
    self.titleLabel.width = self.width - dislikePadding;
    
    self.bottomContainerView.frame = CGRectMake(self.imageView.left, self.imageView.top, self.imageView.width, self.imageView.height + self.actionButton.height + kVideoActionButtonPadding*2);
    
    CGFloat x = self.imageView.left, y = self.imageView.bottom;
    CGFloat containWidth = self.width;
    
    const CGFloat centerY = y + kVideoActionButtonPadding + kActionButtonHeight / 2;
    self.actionButton.right = containWidth - kHorizonPadding;
    self.actionButton.centerY = centerY;
    self.sourceLabel.left = x + kHorizonPadding;
    self.sourceLabel.centerY = centerY;
    CGFloat sourceMaxWidth = containWidth  - 5 * 2 - kAdLabelWidth  - kActionButtonWidth - kAppHorizonPadding * 2;
    self.sourceLabel.width = [self.sourceLabel.text tt_sizeWithMaxWidth:sourceMaxWidth font:self.sourceLabel.font].width;
    self.adLabel.left = self.sourceLabel.right + 5;
    self.adLabel.centerY = centerY;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
   
    CGFloat height = [TTAdDetailViewUtil imageFitHeight:adModel width:width];
    if (!isEmptyString(adModel.titleString)) {
        const CGFloat dislikePadding = adModel.showDislike? kLargeDislikeImageWidth + kLargeDislikeImageLeftPadding : 0;
        const CGFloat maxTitleWidth = width - kVideoTitleLeftPadding - kVideoTitleRightPadding - dislikePadding;
        CGFloat titleHeight = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:kDetailAdTitleFontSize forWidth:maxTitleWidth forLineHeight:kDetailAdTitleLineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        height += kVideoTitleTopPadding + titleHeight + kVideoTitleBottomPadding + kActionButtonHeight + kVideoActionButtonPadding*2 + kVideoAppPhoneBottomPadding;
    }
    return height;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_details";
}

#pragma mark - getter

- (SSThemedLabel *)titleLabel
{
    SSThemedLabel *label = [super titleLabel];
    label.font = [UIFont systemFontOfSize:kDetailAdTitleFontSize];
    return label;
}

- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* sourceLabel = [super sourceLabel];
    sourceLabel.textColorThemeKey = kColorText2;
    sourceLabel.font = [UIFont systemFontOfSize:kDetailAdSourceFontSize];
    return sourceLabel;
}

- (SSThemedButton *)actionButton
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
