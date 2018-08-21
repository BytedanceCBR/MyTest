//
//  TTVideoDetailLeftUnifyADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "TTVideoDetailLeftUnifyADView.h"
#import "NSString-Extension.h"
#import "TTAdDetailViewHelper.h"

#define kPaddingRight 10
#define kVideoDislikeImageWidth 20
#define kVideoDislikeMarginPadding  4


@implementation TTVideoDetailLeftUnifyADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_unify_leftPic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.actionButton];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    [super setAdModel:adModel];
    
    self.titleLabel.text = adModel.titleString;
    self.sourceLabel.text = [adModel sourceText];
    
    CGSize imageSize = [TTAdDetailViewUtil imgSizeForViewWidth:self.width+30];
    CGFloat containWidth = self.width - imageSize.width - kVideoLeftPadding - kVideoRightPadding - kVideoRightImgLeftPadding;
    
    [self.titleLabel sizeToFit: containWidth];
    [self.sourceLabel sizeToFit];
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    [self.actionButton setTitle:adModel.actionButtonText forState:UIControlStateNormal];
    
    NSString *actionButtonIcon = adModel.actionButtonIcon;
    if (isEmptyString(actionButtonIcon)) {
        [self.actionButton sizeToFit];
    } else {
        self.actionButton.imageName = adModel.actionButtonIcon;
        CGFloat actionButtonWidth = [adModel.actionButtonText tt_sizeWithMaxWidth:CGFLOAT_MAX font:[UIFont systemFontOfSize:kDetailAdSourceFontSize]].width;
        actionButtonWidth += 5;
        actionButtonWidth += 12;
        self.actionButton.size = CGSizeMake(actionButtonWidth, kDetailAdSourceLineHeight);
        [self adjustButtonSpace:self.actionButton space:5.0f];
    }
    
    [self layoutVideo:adModel];
}

- (void)adjustButtonSpace:(UIButton *)button space:(CGFloat)spacing {
    CGFloat insetAmount = spacing / 2.0;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -insetAmount, 0, insetAmount);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, -insetAmount);
    button.contentEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
}

- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    [super layoutVideo:adModel];
    
    const CGFloat containWidth = self.width;
    CGSize imageSize = [TTAdDetailViewUtil imgSizeForViewWidth:self.width + 30];
    self.actionButton.right = self.imageView.left - kVideoRightImgLeftPadding;
    self.actionButton.centerY = self.sourceLabel.centerY;
   
    
    const CGFloat actionButtonWidth = self.actionButton.width;
    
    CGFloat leftWidth = containWidth - imageSize.width - kVideoLeftPadding - kVideoRightPadding - kVideoRightImgLeftPadding;
    self.sourceLabel.width = leftWidth - kAdLabelWidth - actionButtonWidth - kVideoAdLabelRitghtPadding * 2;
     self.dislikeView.center = CGPointMake(self.imageView.right - kVideoDislikeImageWidth/2 - kVideoDislikeMarginPadding, self.imageView.top + kVideoDislikeImageWidth/2 + kVideoDislikeMarginPadding);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGSize picSize = [TTAdDetailViewUtil imgSizeForViewWidth:width];
    CGFloat height = kVideoTopPadding + picSize.height + kVideoBottomPadding;
    return height;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_ad_details";
}

#pragma mark - getter

- (TTAlphaThemedButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:kDetailAdSourceFontSize];
        _actionButton.titleColorThemeKey = kColorText5;
        [_actionButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

@end
