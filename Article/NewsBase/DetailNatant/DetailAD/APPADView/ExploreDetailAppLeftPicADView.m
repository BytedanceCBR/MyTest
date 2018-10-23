//
//  ExploreDetailAppLeftPicADView.m
//  Article
//
//  Created by huic on 16/5/3.
//
//

#import "ExploreDetailAppLeftPicADView.h"
#import "TTAdDetailViewHelper.h"

#define kPaddingLeft 10
#define kPaddingRight 10
#define kPaddingBottom 10
#define kPaddingTop 10
#define kPaddingTitleToPic 10  //标题与图片(视频)间距(横向)
#define kPaddingTitleBottom 7  //标题与来源文字间距(纵向)

@implementation ExploreDetailAppLeftPicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"app_leftPic" forArea:TTAdDetailViewAreaArticle];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.downloadButton];
        [self addSubview:self.downloadIcon];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    [super setAdModel:adModel];
    
    CGFloat containWidth = self.width - kPaddingLeft - kPaddingRight;
    
    self.titleLabel.text = adModel.titleString;
    self.sourceLabel.text = adModel.appName;
    
    CGFloat dislikePadding = self.adModel.showDislike? (kAppDislikeImageWidth + kAppDilikeToTitleRightPadding):0;
    CGFloat rightWidth = containWidth - self.imageView.width - kPaddingTitleToPic - dislikePadding;
    [self.titleLabel sizeToFit: rightWidth];
    [self.sourceLabel sizeToFit];
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    [self.downloadButton setTitle:adModel.actionButtonText forState:UIControlStateNormal];
    [self.downloadButton sizeToFit];
    
    [self layout];
}

- (void) layout {
    [super layout];
    self.dislikeView.center = CGPointMake(self.width - kAppDislikeImageRightPadding - kAppDislikeImageWidth/2, self.titleLabel.top + kAppDislikeToTitleTopPadding + kAppDislikeImageWidth/2);
    self.downloadButton.right = self.width - kPaddingRight;
    self.downloadButton.centerY = self.sourceLabel.centerY;
    
    self.downloadIcon.right = self.downloadButton.left - 3;
    self.downloadIcon.centerY = self.downloadButton.centerY;
    
    //source过长时截断
    self.sourceLabel.width = self.downloadIcon.left - 3 - self.sourceLabel.left;
    
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGSize picSize = [TTAdDetailViewUtil imgSizeForViewWidth:(width - kPaddingLeft - kPaddingRight)];
    CGFloat height = kPaddingTop + picSize.height + kPaddingBottom;
    return height;
}

#pragma mark - response

- (void)_downloadAppActionFired:(id)sender {
    [self sendActionForTapEvent];
    [self.adModel trackWithTag:@"detail_download_ad" label:@"click_start" extra:nil];
}

#pragma mark - getter

- (SSThemedButton *)downloadButton
{
    if (!_downloadButton) {
        _downloadButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _downloadButton.backgroundColor = [UIColor clearColor];
        _downloadButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _downloadButton.titleColorThemeKey = kColorText5;
        [_downloadButton addTarget:self action:@selector(_downloadAppActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}

- (SSThemedButton *)downloadIcon {
    if (!_downloadIcon) {
        _downloadIcon = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_downloadIcon setImageName:@"download_ad_detais"];
        _downloadIcon.backgroundColor = [UIColor clearColor];
        _downloadIcon.size = CGSizeMake(12, 12);
        [_downloadIcon addTarget:self action:@selector(_downloadAppActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadIcon;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_details";
}

@end
