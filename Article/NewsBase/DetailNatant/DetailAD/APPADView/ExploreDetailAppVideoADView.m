//
//  ExploreDetailAppVideoADView.m
//  Article
//
//  Created by huic on 16/5/5.
//
//

#import "ExploreDetailAppVideoADView.h"
#import "TTAdDetailViewHelper.h"

#define kAppHorizonPadding 8
#define kDownLoadWidth 72
#define kDownLoadHeight 28
#define kAppHeight 44


@implementation ExploreDetailAppVideoADView

+ (void)load {
    [TTAdDetailViewHelper registerViewClass:self withKey:@"app_video" forArea:TTAdDetailViewAreaArticle];
    [TTAdDetailViewHelper registerViewClass:self withKey:@"app_video" forArea:TTAdDetailViewAreaVideo];
}

//+ (void)fakeData:(ArticleDetailADModel *)adModel
//{
//    if (!adModel) {
//        adModel = [[ArticleDetailADModel alloc] init];
//    }
//    
//    if (!adModel.videoInfo) {
//        adModel.videoInfo = [[ArticleDetailADVideoModel alloc] init];
//    }
//    
//    adModel.ad_id = [NSNumber numberWithInteger:6375080775];
//    adModel.titleString = @"欢迎来到网易公开课，这里是千万免费课程平台！";
//    adModel.videoInfo.coverURL = @"http://p3.pstatp.com/origin/2f5000287d9dfc951d9";
//    adModel.videoInfo.videoWidth = 580;
//    adModel.videoInfo.videoHeight = 326;
//    adModel.videoInfo.videoDuration = 126;
//    adModel.videoInfo.videoID = @"78c5510bd9fe4c04999c2b53c99f8e33";
//    adModel.buttonText = @"马上下载";
//    adModel.appName = @"网易课堂";
//}


- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.sourceLabel];
        [self addSubview:self.downloadButton];
        [self.moreInfoLabel removeFromSuperview];
        [self.moreInfoButton removeFromSuperview];
    }
    return self;
}

#pragma mark - refresh

- (void)setAdModel:(ArticleDetailADModel *)adModel {
    
    [super setAdModel:adModel];
    
    //    #warning fakeData
    //    [[self class] fakeData:adModel];
    
    self.sourceLabel.text = adModel.appName;
    [self.sourceLabel sizeToFit];
    
    [self.downloadButton setTitle:adModel.actionButtonText forState:UIControlStateNormal];
    self.downloadButton.size = CGSizeMake(kDownLoadWidth, kDownLoadHeight);
    
    [self layout];
}

- (void)layout
{
    [super layout];
    self.backgroundColorThemeKey = kColorBackground4;
    self.sourceLabel.left = kAppHorizonPadding;
    self.sourceLabel.centerY = self.logo.bottom + kAppHeight / 2;
    self.downloadButton.right = self.width - kAppHorizonPadding;
    self.downloadButton.centerY = self.logo.bottom + kAppHeight / 2;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
//    #warning fakeData
//    [self fakeData:adModel];
   
    CGFloat imageHeight = videoFitHeight(adModel, width);
    return imageHeight + kAppHeight;
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
@end
