//
//  ExploreVideoDetailAppLeftPicADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreVideoDetailAppLeftPicADView.h"
#import "TTAdDetailViewHelper.h"

#define kPaddingRight 10


@implementation ExploreVideoDetailAppLeftPicADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_app_leftPic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.downloadButton];
        [self addSubview:self.downloadIcon];
        [self addSubview:self.dislikeView];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    [super setAdModel:adModel];
    
    self.titleLabel.text = adModel.titleString;
    self.sourceLabel.text = adModel.appName;
    
    CGSize imageSize = [TTAdDetailViewUtil imgSizeForViewWidth:self.width+30];
    CGFloat containWidth = self.width - imageSize.width - kVideoLeftPadding - kVideoRightPadding - kVideoRightImgLeftPadding;
    
    [self.titleLabel sizeToFit: containWidth];
    [self.sourceLabel sizeToFit];
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    [self.downloadButton setTitle:adModel.buttonText ? adModel.buttonText : @"立即下载" forState:UIControlStateNormal];
    [self.downloadButton sizeToFit];
    
    [self layoutVideo:adModel];
}

- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    [super layoutVideo:adModel];
    self.downloadButton.right = self.imageView.left - kPaddingRight;
    self.downloadButton.centerY = self.sourceLabel.centerY;
    
    self.downloadIcon.right = self.downloadButton.left - 3;
    self.downloadIcon.centerY = self.downloadButton.centerY;
    CGSize imageSize = [TTAdDetailViewUtil imgSizeForViewWidth:self.width+30];
    CGFloat containWidth = self.width - imageSize.width - kVideoLeftPadding - kVideoRightPadding - kVideoRightImgLeftPadding;
    self.sourceLabel.width = containWidth - self.adLabel.width -self.downloadIcon.width - self.downloadButton.width - kVideoAdLabelRitghtPadding -3;
    self.downloadButton.hidden = isEmptyString(adModel.buttonText);
    
    self.dislikeView.center = CGPointMake(self.imageView.right - kVideoDislikeImageWidth/2 - kVideoDislikeMarginPadding, self.imageView.top + kVideoDislikeImageWidth/2 + kVideoDislikeMarginPadding);
    
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGSize picSize = [TTAdDetailViewUtil imgSizeForViewWidth:width];
    CGFloat height = kVideoTopPadding + picSize.height + kVideoBottomPadding;
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
