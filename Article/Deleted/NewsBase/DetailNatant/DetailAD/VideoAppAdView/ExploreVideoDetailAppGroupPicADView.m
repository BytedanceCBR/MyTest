//
//  ExploreVideoDetailAppGroupPicADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreVideoDetailAppGroupPicADView.h"
#import "TTLabelTextHelper.h"
#import "ExploreDetailMixedGroupPicADView.h"
#import "NSString-Extension.h"
#import "TTAdDetailViewHelper.h"

@implementation ExploreVideoDetailAppGroupPicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_app_groupPic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.appDownloadButton];
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
    
    [self.appDownloadButton setTitle:adModel.buttonText ? adModel.buttonText : @"立即下载" forState:UIControlStateNormal];
    self.appDownloadButton.size = CGSizeMake(kActionButtonWidth, kActionButtonHeight);
    [self layoutVideo:adModel];

}

- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    [super layoutVideo:adModel];
    
    self.dislikeView.center = CGPointMake(self.width - kAppDislikeImageWidth/2, kAppDislikeImageTopPadding + kAppDislikeImageWidth/2);
    CGFloat dislikePadding = self.adModel.showDislike? kAppDislikeImageWidth + kAppDislikeImageLeftPadding:0;
    self.titleLabel.width = self.width- 2 * kVideoHoriMargin - dislikePadding;
    
    self.bottomContainerView.frame = CGRectMake(self.groupPicView.left, self.groupPicView.top, self.groupPicView.width, self.groupPicView.height + kActionButtonHeight + 2*kVideoActionButtonPadding);
    
    self.appDownloadButton.top = self.groupPicView.bottom + kVideoActionButtonPadding;
    self.appDownloadButton.right = self.groupPicView.right - 8;
    self.sourceLabel.left = self.groupPicView.left + 10;
    self.sourceLabel.centerY = self.appDownloadButton.centerY;
    CGFloat sourceMaxWidth = self.groupPicView.width - self.sourceLabel.left - 5 - self.adLabel.width - kVideoAdLabelRitghtPadding - kActionButtonWidth - 8;
    self.sourceLabel.width = [self.sourceLabel.text tt_sizeWithMaxWidth:sourceMaxWidth font:self.sourceLabel.font].width;
    self.adLabel.left = self.sourceLabel.right + kVideoAdLabelRitghtPadding;
    self.adLabel.centerY = self.sourceLabel.centerY;
    self.appDownloadButton.hidden = isEmptyString(adModel.buttonText);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat height = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:kDetailAdTitleFontSize forWidth:width - 2 * kVideoHoriMargin forLineHeight:kDetailAdTitleLineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    height += [ExploreDetailADGroupPicView heightForWidth:width];
    height += kVideoTitleTopPadding + kVideoTitleBottomPadding + kActionButtonHeight + 2*kVideoActionButtonPadding + kVideoAppPhoneBottomPadding;
    return height;
}

#pragma mark - response

- (void)appDownloadActionFired {
    [self sendActionForTapEvent];
    [self.adModel trackWithTag:@"detail_download_ad" label:@"click_start" extra:nil];
}

#pragma mark - getter


- (SSThemedLabel*)sourceLabel
{
    SSThemedLabel* sourceLabel = [super sourceLabel];
    sourceLabel.textColorThemeKey = kColorText2;
    sourceLabel.font = [UIFont systemFontOfSize:14];
    return sourceLabel;
}

- (SSThemedButton *)appDownloadButton
{
    if (!_appDownloadButton) {
        _appDownloadButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _appDownloadButton.backgroundColor = [UIColor clearColor];
        _appDownloadButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _appDownloadButton.layer.cornerRadius = 6;
        _appDownloadButton.layer.borderWidth = 1;
        _appDownloadButton.borderColorThemeKey = kColorLine3;
        _appDownloadButton.clipsToBounds = YES;
        _appDownloadButton.titleColorThemeKey = kColorText6;
        [_appDownloadButton addTarget:self action:@selector(appDownloadActionFired) forControlEvents:UIControlEventTouchUpInside];
    }
    return _appDownloadButton;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_details";
}

@end
