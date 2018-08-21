//
//  ExploreVideoDetailAppLargePicADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreVideoDetailAppLargePicADView.h"
#import "TTLabelTextHelper.h"
#import "NSString-Extension.h"
#import "TTAdDetailViewUtil.h"
#import "TTAdDetailViewHelper.h"

#define kAppHorizonPadding 12
#define kDownLoadWidth 72
#define kDownLoadHeight 28
#define kAppHeight 44
#define kPaddingSourceToTitle 1 //app名称与标题间距(纵向)

@implementation ExploreVideoDetailAppLargePicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_app_largePic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        
        [self addSubview:self.sourceLabel];
        [self addSubview:self.downloadButton];
        [self addSubview:self.bottomContainerView];
        [self sendSubviewToBack:self.bottomContainerView];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    
    [super setAdModel:adModel];
    
    self.sourceLabel.text = adModel.appName;
    [self.sourceLabel sizeToFit];
    
    [self.downloadButton setTitle:adModel.buttonText ? adModel.buttonText : @"立即下载" forState:UIControlStateNormal];
    self.downloadButton.size = CGSizeMake(kDownLoadWidth, kDownLoadHeight);
    
    [self layoutVideo:adModel];
}

- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    const CGFloat contentMaxWidth = self.width - kVideoTitleLeftPadding - kVideoTitleRightPadding;
    const CGFloat dislikePadding = self.adModel.showDislike ? (kVideoDislikeImageWidth + kAppDislikeImageLeftPadding) : 0;
    const CGFloat titleContentMaxWidth = contentMaxWidth - dislikePadding;
    
    self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:adModel.titleString fontSize:[TTDeviceUIUtils tt_fontSize:17] lineHeight:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]].pointSize * 1.2];
    const CGFloat titleHeight = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize] forWidth:titleContentMaxWidth forLineHeight:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize]].pointSize * 1.2 constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.titleLabel.frame = CGRectMake(kVideoTitleLeftPadding, kVideoTitleTopPadding, titleContentMaxWidth, titleHeight);
    //布局dislike
    self.dislikeView.center = CGPointMake(self.width - kAppDislikeImageWidth/2, kAppDislikeImageTopPadding + kAppDislikeImageWidth/2);
    self.dislikeView.hidden = !self.adModel.showDislike;
    
    CGFloat imageHeight = [TTAdDetailViewUtil imageFitHeight:adModel width:contentMaxWidth];
    self.imageView.size = CGSizeMake(contentMaxWidth, imageHeight);
    self.imageView.origin = CGPointMake(self.titleLabel.left, self.titleLabel.bottom + kVideoTitleBottomPadding);
    
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    self.bottomContainerView.frame = CGRectMake(self.imageView.left, self.imageView.top, self.imageView.width, self.imageView.height + self.downloadButton.height + kVideoActionButtonPadding*2);
    self.downloadButton.top = self.imageView.bottom + kVideoActionButtonPadding;
    self.downloadButton.right = self.imageView.right - 8;
    self.sourceLabel.left = self.imageView.left + 10;
    self.sourceLabel.centerY = self.downloadButton.centerY;
    CGFloat sourceMaxWidth = contentMaxWidth - self.sourceLabel.left - 5 - self.adLabel.width - kVideoAdLabelRitghtPadding - self.downloadButton.width - 8;
    self.sourceLabel.width = [self.sourceLabel.text tt_sizeWithMaxWidth:sourceMaxWidth font:self.sourceLabel.font].width;
    self.adLabel.left = self.sourceLabel.right + 5;
    self.adLabel.centerY = self.sourceLabel.centerY;
    self.downloadButton.hidden = isEmptyString(adModel.buttonText);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat height = 0.0f;
    const CGFloat contentMaxWidth = width - kVideoTitleLeftPadding - kVideoTitleRightPadding;
    height += [TTAdDetailViewUtil imageFitHeight:adModel width:contentMaxWidth];
   
    if (!isEmptyString(adModel.titleString)) {
        const CGFloat dislikePadding = adModel.showDislike ? (kAppDislikeImageWidth + kAppDislikeImageLeftPadding) : 0;
        const CGFloat titleContentMaxWidth = contentMaxWidth - dislikePadding;
        CGFloat titleHeight = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize] forWidth:titleContentMaxWidth forLineHeight:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize]].pointSize * 1.2 constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        height += kVideoTitleTopPadding + titleHeight + kVideoTitleBottomPadding + kDownLoadHeight + kVideoActionButtonPadding*2 + kVideoAppPhoneBottomPadding;
    }
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
    label.font = [UIFont systemFontOfSize:17];
    return label;
}

- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* sourceLabel = [super sourceLabel];
    sourceLabel.textColorThemeKey = kColorText2;
    sourceLabel.font = [UIFont systemFontOfSize:14];
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
    return @"dislikeicon_details";
}

@end
