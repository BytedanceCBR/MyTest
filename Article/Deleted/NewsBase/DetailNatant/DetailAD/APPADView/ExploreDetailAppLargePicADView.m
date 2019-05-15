//
//  ExploreDetailAppLargePicADView.m
//  Article
//
//  Created by huic on 16/5/5.
//
//

#import "ExploreDetailAppLargePicADView.h"
#import "TTLabelTextHelper.h"
#import "TTAdDetailViewHelper.h"

#define kAppHorizonPadding 12
#define kDownLoadWidth 72
#define kDownLoadHeight 28
#define kAppHeight 44
#define kPaddingSourceToTitle 1 //app名称与标题间距(纵向)

@implementation ExploreDetailAppLargePicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"app_largePic" forArea:TTAdDetailViewAreaArticle];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.downloadButton];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    
    [super setAdModel:adModel];
    
    self.sourceLabel.text = adModel.appName;
    [self.sourceLabel sizeToFit];
    
    [self.downloadButton setTitle:adModel.actionButtonText forState:UIControlStateNormal];
    self.downloadButton.size = CGSizeMake(kDownLoadWidth, kDownLoadHeight);
    
    [self layout];
}

- (void)layout
{
    //布局上方图片
    self.imageView.origin = CGPointMake(0, 0);
    
    //布局推广标签
    self.adLabel.origin = CGPointMake(self.imageView.right - self.adLabel.width - 6, self.imageView.bottom - self.adLabel.height - 6);
    
    [self.titleLabel sizeToFit];
    
    //布局dislike
    self.dislikeView.center = CGPointMake(self.width - kAppDislikeImageRightPadding - kAppDislikeImageWidth/2, kAppDislikeImageTopPadding + kAppDislikeImageWidth/2);
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
    self.downloadButton.right = self.width - kAppHorizonPadding;
    self.downloadButton.centerY = self.imageView.bottom + kAppHeight / 2;
    
    //title与source过长时截断
    self.titleLabel.width = self.downloadButton.left - kAppHorizonPadding * 2;
    self.sourceLabel.width = self.downloadButton.left - kAppHorizonPadding * 2;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat height = [TTAdDetailViewUtil imageFitHeight:adModel width:width];
    height += kAppHeight;
    return height;
}

#pragma mark - response

- (void)_downloadAppActionFired:(id)sender {
    [self sendActionForTapEvent];
    [self.adModel trackWithTag:@"detail_download_ad" label:@"click_start" extra:nil];
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

- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* sourceLabel = [super sourceLabel];
    sourceLabel.textColorThemeKey = kColorText1;
    return sourceLabel;
}

- (SSThemedButton *)downloadButton
{
    if (!_downloadButton) {
        _downloadButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _downloadButton.backgroundColor = [UIColor clearColor];
        _downloadButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _downloadButton.layer.cornerRadius = 6;
        _downloadButton.layer.borderWidth = 1;
        _downloadButton.borderColorThemeKey = kColorLine3;
        _downloadButton.clipsToBounds = YES;
        _downloadButton.titleColorThemeKey = kColorText6;
        [_downloadButton addTarget:self action:@selector(_downloadAppActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_ad_details";
}

@end
