//
//  ExploreDetailAppointLargePicADView.m
//  Article
//
//  Created by yin on 16/9/29.
//
//

#import "ExploreDetailAppointLargePicADView.h"
#import "TTLabelTextHelper.h"
#import "TTAdDetailViewHelper.h"

#define kAppHorizonPadding 12
#define kCallActionWidth 72
#define kCallActionHeight 28
#define kAppHeight 44
#define kPaddingSourceToTitle 1 //app名称与标题间距(纵向)


@implementation ExploreDetailAppointLargePicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"appoint_largePic" forArea:TTAdDetailViewAreaArticle];
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
    
    self.sourceLabel.text = adModel.sourceString;
    [self.sourceLabel sizeToFit];
    
    self.titleLabel.text = adModel.titleString;
    [self.titleLabel sizeToFit];
    
    [self.actionButton setTitle:adModel.buttonText ? adModel.buttonText : @"立即预约" forState:UIControlStateNormal];
    self.actionButton.size = CGSizeMake(kCallActionWidth, kCallActionHeight);
    
    [self layout];
}

- (void)layout
{
    self.imageView.origin = CGPointMake(0, 0);
    
    //布局dislike
    self.dislikeView.center = CGPointMake(self.width - kAppointDislikeImageRightPadding - kAppointDislikeImageWidth/2, kAppointDislikeImageTopPadding + kAppointDislikeImageWidth/2);
    self.dislikeView.hidden = !self.adModel.showDislike;
    CGFloat leftHeight = self.sourceLabel.height +kPaddingSourceToTitle + self.titleLabel.height;
    leftHeight = MIN(leftHeight, kAppHeight);
    
    CGFloat x = kAppHorizonPadding;
    CGFloat y = self.imageView.bottom + floor((kAppHeight - leftHeight) / 2);
    
    //布局来源（app名称）
    self.sourceLabel.origin = CGPointMake(x, y);
    y += self.sourceLabel.height;
    y += kPaddingSourceToTitle;
    
    //布局广告标题
    self.titleLabel.origin = CGPointMake(x, y);
    //布局下载按钮
    self.actionButton.right = self.width - kAppHorizonPadding;
    self.actionButton.centerY = self.imageView.bottom + kAppHeight / 2;
    
    //title与source过长时截断
    self.titleLabel.width = self.actionButton.left - kAppHorizonPadding * 2;
    self.sourceLabel.width = self.actionButton.left - kAppHorizonPadding * 2;
    //布局推广标签
    self.adLabel.origin = CGPointMake(self.imageView.right - self.adLabel.width - 6, self.imageView.bottom - self.adLabel.height - 6);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat height = [TTAdDetailViewUtil imageFitHeight:adModel width:width];
    height += kAppHeight;
    return height;
}

#pragma mark - response

- (void)appointActionFired:(id)sender {
    [self appointActionWithADModel:self.adModel];
}

#pragma mark - getter

- (SSThemedLabel *)titleLabel
{
    SSThemedLabel *label = [super titleLabel];
    label.textColorThemeKey = kColorText3;
    label.font = [UIFont systemFontOfSize:9];
    label.numberOfLines = 1;
    return label;
}

- (SSThemedButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor clearColor];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _actionButton.layer.cornerRadius = 6;
        _actionButton.layer.borderWidth = 1;
        _actionButton.borderColorThemeKey = kColorLine3;
        _actionButton.clipsToBounds = YES;
        _actionButton.titleColorThemeKey = kColorText6;
        [_actionButton addTarget:self action:@selector(appointActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_ad_details";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
