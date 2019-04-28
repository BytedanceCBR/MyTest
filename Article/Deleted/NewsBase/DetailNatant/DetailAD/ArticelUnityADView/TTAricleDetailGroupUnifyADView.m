//
//  TTAricleDetailGroupUnifyADView.m
//  Article
//
//  Created by 冯靖君 on 16/7/11.
//
//

#import "TTAdDetailViewHelper.h"
#import "TTAricleDetailGroupUnifyADView.h"
#import "TTLabelTextHelper.h"

#define kGroupDislikeImageWidth 10
#define kGroupDislikeImageTopPadding 14
#define kGroupDislikeImageRightPadding 12

@implementation TTAricleDetailGroupUnifyADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"unify_groupPic" forArea:TTAdDetailViewAreaGloabl];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.actionButton];
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
    
    [self layout];
}

- (void)layout
{
    [super layout];
    
    const CGFloat containWidth = self.width;
    
    self.dislikeView.center = CGPointMake(self.groupPicView.right - kGroupDislikeImageWidth/2, kGroupDislikeImageTopPadding + kGroupDislikeImageWidth/2);
    
    self.actionButton.top = [ExploreDetailMixedGroupPicADView heightForADModel:self.adModel constrainedToWidth:self.width];
    self.actionButton.right = self.width - kHoriMargin;
    
    self.sourceLabel.left = kHoriMargin;
    const CGFloat sourceMaxWidth = containWidth - kActionButtonWidth - 2 * kHoriMargin - 5;
    self.sourceLabel.width = sourceMaxWidth;
    self.sourceLabel.centerY = self.actionButton.centerY;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat superHeight = [ExploreDetailMixedGroupPicADView heightForADModel:adModel constrainedToWidth:width];
    superHeight += kActionButtonHeight + kActionBottomMargin;
    return superHeight;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_details";
}


#pragma mark - getter

- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* sourceLabel = [super sourceLabel];
    sourceLabel.textColorThemeKey = kColorText1;
    return sourceLabel;
}

- (TTAlphaThemedButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:14.0f]; // font size 和 button size 需要同步调整
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
