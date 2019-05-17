//
//  ExploreDetailPhoneLeftPicADView.m
//  Article
//
//  Created by admin on 16/6/14.
//
//

#import "ExploreDetailPhoneLeftPicADView.h"
#import "TTAdDetailViewHelper.h"
#import "TTArticleCellHelper.h"

#define kPaddingLeft 10
#define kPaddingRight 10
#define kPaddingBottom 10
#define kPaddingTop 10
#define kPaddingTitleToPic 10  //标题与图片(视频)间距(横向)
#define kPaddingTitleBottom 7  //标题与来源文字间距(纵向)


@implementation ExploreDetailPhoneLeftPicADView


+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"phone_leftPic" forArea:TTAdDetailViewAreaArticle];
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
    CGFloat containWidth = self.width - kPaddingLeft - kPaddingRight;
    
    self.titleLabel.text = adModel.titleString;
    self.sourceLabel.text = adModel.sourceString;
    CGFloat dislikePadding = self.adModel.showDislike? (kPhoneDislikeImageWidth + kPhoneDilikeToTitleRightPadding):0;
    CGFloat rightWidth = containWidth - self.imageView.width - kPaddingTitleToPic - dislikePadding;
    [self.titleLabel sizeToFit: rightWidth];
    [self.sourceLabel sizeToFit];
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    [self.actionButton setTitle:adModel.buttonText ? adModel.buttonText : @"拨打电话" forState:UIControlStateNormal];
    [self.actionButton sizeToFit];
    [self layout];
}

- (void) layout {
    [super layout];
    self.dislikeView.center = CGPointMake(self.width - kPhoneDislikeImageRightPadding - kPhoneDislikeImageWidth/2, self.titleLabel.top + kPhoneDislikeToTitleTopPadding + kPhoneDislikeImageWidth/2);
    self.actionButton.right = self.width - kPaddingRight;
    self.actionButton.centerY = self.sourceLabel.centerY;
    //source过长时截断
    self.sourceLabel.width = self.actionButton.left - 3 - self.sourceLabel.left;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGSize picSize = [TTAdDetailViewUtil imgSizeForViewWidth:(width - kPaddingLeft - kPaddingRight)];
    CGFloat height = kPaddingTop + picSize.height + kPaddingBottom;
    return height;
}

#pragma mark - response

- (void)callActionFired:(id)sender {
    [self callActionWithADModel:self.adModel];
}

#pragma mark - getter

- (SSThemedButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _actionButton.titleColorThemeKey = kColorText5;
        [_actionButton addTarget:self action:@selector(callActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_details";
}

@end
