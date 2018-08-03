//
//  ExploreDetailAppGroupPicADView.m
//  Article
//
//  Created by 冯靖君 on 16/7/11.
//
//

#import "ExploreDetailAppGroupPicADView.h"
#import "TTLabelTextHelper.h"
#import "ExploreDetailMixedGroupPicADView.h"
#import "TTAdDetailViewHelper.h"

@implementation ExploreDetailAppGroupPicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"app_groupPic" forArea:TTAdDetailViewAreaArticle];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.appDownloadButton];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    
    [super setAdModel:adModel];
    
    self.sourceLabel.text = adModel.appName;
    [self.sourceLabel sizeToFit];
    
    [self.appDownloadButton setTitle:adModel.actionButtonText forState:UIControlStateNormal];
    self.appDownloadButton.size = CGSizeMake(kActionButtonWidth, kActionButtonHeight);
    [self layout];
    
}

- (void)layout
{
    [super layout];
    //布局dislike
    self.dislikeView.center = CGPointMake(self.groupPicView.right - kAppDislikeImageWidth/2, kAppDislikeImageTopPadding + kAppDislikeImageWidth/2);
    
    self.appDownloadButton.top = [ExploreDetailMixedGroupPicADView heightForADModel:self.adModel constrainedToWidth:self.width];
    self.appDownloadButton.right = self.width - kHoriMargin;
    
    self.sourceLabel.left = kHoriMargin;
    self.sourceLabel.centerY = self.appDownloadButton.centerY;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat superHeight = [ExploreDetailMixedGroupPicADView heightForADModel:adModel constrainedToWidth:width];
    superHeight += kActionButtonHeight + kActionBottomMargin;
    return superHeight;
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
    sourceLabel.textColorThemeKey = kColorText1;
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
