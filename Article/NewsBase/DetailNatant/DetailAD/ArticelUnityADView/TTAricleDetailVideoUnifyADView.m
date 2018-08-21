//
//  TTAricleDetailVideoUnifyADView.m
//  Article
//
//  Created by huic on 16/5/5.
//
//

#import "TTAricleDetailVideoUnifyADView.h"
#import "TTAdDetailViewHelper.h"

#define kAppHorizonPadding 12
#define kAppHeight 44

@implementation TTAricleDetailVideoUnifyADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_unify_video" forArea:TTAdDetailViewAreaVideo];
    [TTAdDetailViewHelper registerViewClass:self withKey:@"unify_video" forArea:TTAdDetailViewAreaGloabl];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.actionButton];
        [self.moreInfoLabel removeFromSuperview];
        [self.moreInfoButton removeFromSuperview];
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
    self.backgroundColorThemeKey = kColorBackground4;
    
    CGFloat centerY = self.logo.bottom + kAppHeight / 2;
    const CGFloat containWidth = self.width;
    
    self.actionButton.right = self.width - kAppHorizonPadding;
    self.actionButton.centerY = centerY;
    
    self.sourceLabel.left = kAppHorizonPadding;
    self.sourceLabel.centerY = centerY;
    CGFloat sourceMaxWidth = containWidth - 2 * kAppHorizonPadding - 5;
    self.sourceLabel.width = sourceMaxWidth;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat imageHeight = videoFitHeight(adModel, width);
    return imageHeight + kAppHeight;
}

#pragma mark - getter

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
