//
//  TTAricleDetailLargeUnifyADView.m
//  Article
//
//  Created by huic on 16/5/5.
//
//

#import "TTAricleDetailLargeUnifyADView.h"
#import "TTLabelTextHelper.h"
#import "TTAdDetailViewHelper.h"

#define kAppHeight 44
#define kAppHorizonPadding 12
#define kDetailAdLargeTitleFontSize ceil([TTDeviceUIUtils tt_newFontSize:9])

#define kLargeDislikeImageWidth 18
#define kLargeDislikeImageTopPadding 4
#define kLargeDislikeImageRightPadding 4

@implementation TTAricleDetailLargeUnifyADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"unify_largePic" forArea:TTAdDetailViewAreaGloabl];
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
    
    self.sourceLabel.text = [adModel sourceText];;

    [self.actionButton setTitle:adModel.actionButtonText forState:UIControlStateNormal];
    self.actionButton.size = CGSizeMake(kActionButtonWidth, kActionButtonHeight);
    
    [self layout];
}

- (void)layout
{
    CGFloat x = 0, y = 0;
    CGFloat containWidth = self.width;
    CGFloat imageHeight = [TTAdDetailViewUtil imageFitHeight:self.adModel width:containWidth];
    //布局上方图片
    self.imageView.frame = CGRectMake(x, y, containWidth, imageHeight);
    
    //布局推广标签
    self.adLabel.origin = CGPointMake(self.imageView.right - self.adLabel.width - 6, self.imageView.bottom - self.adLabel.height - 6);
    //布局dislike
    self.dislikeView.center = CGPointMake(self.width - kLargeDislikeImageRightPadding - kLargeDislikeImageWidth/2, kLargeDislikeImageTopPadding + kLargeDislikeImageWidth/2);
    self.dislikeView.hidden = !self.adModel.showDislike;
    
    x += kAppHorizonPadding;
    y += imageHeight;
    
    //布局 右侧按钮
    self.actionButton.right = containWidth - kAppHorizonPadding;
    self.actionButton.centerY = y + kAppHeight / 2;
    
    [self.titleLabel sizeToFit];
    [self.sourceLabel sizeToFit];
    
    CGFloat leftHeight = self.sourceLabel.height +kPaddingSourceToTitle + self.titleLabel.height;
    leftHeight = MIN(leftHeight, kAppHeight);
    
   
    CGFloat y1 = y + floor((kAppHeight - leftHeight) / 2);
    
    //布局来源（app名称）
    self.sourceLabel.origin = CGPointMake(x, y1);
    y1 += self.sourceLabel.height;
    y1 += kPaddingSourceToTitle;
    
    //布局广告标题
    self.titleLabel.origin = CGPointMake(x, y1);
    //title与source过长时截断
    const CGFloat textMaxWidth = containWidth - 3 * kAppHorizonPadding - kActionButtonWidth;
    self.titleLabel.width = textMaxWidth;
    self.sourceLabel.width = textMaxWidth;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat height = [TTAdDetailViewUtil imageFitHeight:adModel width:width];
    height += kAppHeight;
    return height;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_ad_details";
}

#pragma mark - getter

- (SSThemedLabel *)titleLabel
{
    SSThemedLabel *label = [super titleLabel];
    label.textColorThemeKey = kColorText3;
    label.font = [UIFont systemFontOfSize:kDetailAdLargeTitleFontSize];
    label.numberOfLines = 1;
    return label;
}

- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* sourceLabel = [super sourceLabel];
    sourceLabel.font = [UIFont systemFontOfSize:kDetailAdSourceFontSize];
    sourceLabel.textColorThemeKey = kColorText1;
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
