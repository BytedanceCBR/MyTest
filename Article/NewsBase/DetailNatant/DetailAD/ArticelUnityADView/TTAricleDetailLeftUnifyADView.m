//
//  TTAricleDetailLeftUnifyADView.m
//  Article
//
//  Created by huic on 16/5/3.
//
//

#import "TTAricleDetailLeftUnifyADView.h"
#import "NSString-Extension.h"
#import "TTAdDetailViewHelper.h"

#define kPaddingLeft 10
#define kPaddingRight 10
#define kPaddingBottom 10
#define kPaddingTop 10
#define kPaddingTitleToPic 10  //标题与图片(视频)间距(横向)
#define kPaddingTitleBottom 7  //标题与来源文字间距(纵向)

#define kLeftDislikeImageWidth 10
#define kLeftDislikeImageTopPadding 21
#define kLeftDilikeToTitleRightPadding 10
#define kLeftDislikeToTitleTopPadding 4.5
#define kLeftDislikeImageRightPadding 12
#define kActionButtonMaxWidth 130

@implementation TTAricleDetailLeftUnifyADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"unify_leftPic" forArea:TTAdDetailViewAreaGloabl];
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

    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    [self.actionButton setTitle:adModel.actionButtonText forState:UIControlStateNormal];
    NSString *actionButtonIcon = adModel.actionButtonIcon;
    if (isEmptyString(actionButtonIcon)) {
        [self.actionButton sizeToFit];
    } else {
        self.actionButton.imageName = adModel.actionButtonIcon;
        CGFloat actionButtonWidth = [adModel.actionButtonText tt_sizeWithMaxWidth:kActionButtonMaxWidth font:[UIFont systemFontOfSize:kDetailAdSourceFontSize]].width;
        actionButtonWidth += 5;
        actionButtonWidth += 12;
        self.actionButton.size = CGSizeMake(actionButtonWidth, kDetailAdSourceLineHeight);
        [self adjustButtonSpace:self.actionButton space:5.0f];
    }
    
    [self layout];
}

- (void)adjustButtonSpace:(UIButton *)button space:(CGFloat)spacing {
    CGFloat insetAmount = spacing / 2.0;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -insetAmount, 0, insetAmount);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, -insetAmount);
    button.contentEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
}

- (void) layout {
    [super layout];
    
    self.dislikeView.center = CGPointMake(self.width - kLeftDislikeImageRightPadding - kLeftDislikeImageWidth/2, self.titleLabel.top + kLeftDislikeToTitleTopPadding + kLeftDislikeImageWidth/2);
    
    self.actionButton.right = self.width - kPaddingRight;
    self.actionButton.centerY = self.sourceLabel.centerY;
    
    //source过长时截断
    self.sourceLabel.width = self.actionButton.left - 5 - self.sourceLabel.left;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGSize picSize = [TTAdDetailViewUtil imgSizeForViewWidth:(width - kPaddingLeft - kPaddingRight)];
    CGFloat height = kPaddingTop + picSize.height + kPaddingBottom;
    return height;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_details";
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
