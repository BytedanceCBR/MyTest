//
//  ArticleDetailADView.m
//  Article
//
//  Created by Zhang Leonardo on 14-2-20.
//
//

#import "ArticleDetailADView.h"
#import "SSAvatarView.h"
#import "SSADActionManager.h"
#import "TTAdMonitorManager.h"
#import "SSWebViewController.h"
#import "TTImageView.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"



#define topPadding                          15
#define bottomPadding                       15
#define middlePadding                       8  //如果文字链和banner同时存在，其间的间距
#define textLinkViewHeight                  14
#define textLinkViewContainerHeight         (middlePadding + textLinkViewHeight + bottomPadding)
#define textLinkLabelViewLeftPadding        0
#define textLinkLabelFontSize               12
#define textLinkTitleFontSize               13
#define bannerViewContainerHeight           ([TTDeviceHelper isPadDevice] ?  66 : 80)
#define bannerViewContainerPadWidth         404

#define bannerViewContainerViewLeftPadding  ([TTDeviceHelper isPadDevice] ?  15 : 0)
#define bannerTitleLabelFontSize            ([TTDeviceHelper isPadDevice] ?  15 : 16)
#define bannerDescLabelFontSize             12
#define bannerLabelFontSize                 10

//#define appImageAspect                      1.92f

static float appImageAspect;

@interface ArticleDetailADView() <UIGestureRecognizerDelegate>
//{
//    BOOL _sendedShowTrack;
//}

@property(nonatomic, retain)UILabel * textLinkLabel;
@property(nonatomic, retain)UILabel * textLinkTitleLabel;
@property(nonatomic, retain)UIButton * textLinkBgButton;
@property(nonatomic, retain)UIView * textLinkViewContainer;

@property(nonatomic, retain)UILabel * bannerLabel;
@property(nonatomic, retain)UILabel * bannerTitleLabel;
@property(nonatomic, retain)UILabel * bannerDescLabel;
@property(nonatomic, retain)SSAvatarView * bannerImageView;
@property(nonatomic, retain)UIView * bannerViewContainer;
@property(nonatomic, retain)UIButton * bannerBgButton;
/// 图片类型广告
@property (nonatomic, retain) TTImageView   * imageBannerView;
@property (nonatomic, retain) UILabel       * imageLabel;

// 应用下载广告
@property (nonatomic, retain) UIView *appContainerView;
@property (nonatomic, retain) TTImageView *appImageView;
@property (nonatomic, retain) UILabel *appNameLabel;
@property (nonatomic, retain) UILabel *appInfoLabel;
@property (nonatomic, retain) UIButton *appDownloadButton;
@property (nonatomic, retain) UILabel *adsFlagLabel;
@end

@implementation ArticleDetailADView

- (void)dealloc
{
    self.bannerModel = nil;
    
    self.textLinkLabel = nil;
    self.textLinkTitleLabel = nil;
    self.textLinkBgButton = nil;
    self.textLinkViewContainer = nil;
    
    self.bannerLabel = nil;
    self.bannerTitleLabel = nil;
    self.bannerDescLabel = nil;
    self.bannerImageView = nil;
    self.bannerViewContainer = nil;
    self.bannerBgButton = nil;
    self.imageBannerView = nil;
    self.imageBannerModel = nil;
    self.imageLabel = nil;
    
    self.appModel = nil;
    self.appContainerView = nil;
    self.appImageView = nil;
    self.appNameLabel = nil;
    self.appInfoLabel = nil;
    self.appDownloadButton = nil;
    self.adsFlagLabel = nil;
}

- (id)initWithWidth:(CGFloat)width
{
    CGRect frame = CGRectMake(0, 0, width, 0);
    self = [super initWithFrame:frame];
    if (self) {
        _sendedShowTrack = NO;
    }
    return self;
}

- (void)buildViewForTextLine
{
    if (!_textLinkViewContainer) {
        self.textLinkViewContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _textLinkViewContainer.backgroundColor = [UIColor clearColor];
        [self addSubview:_textLinkViewContainer];
        
        self.textLinkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLinkLabel.backgroundColor = [UIColor clearColor];
        _textLinkLabel.textAlignment = NSTextAlignmentCenter;
        _textLinkLabel.font = [UIFont systemFontOfSize:textLinkLabelFontSize];
        [_textLinkViewContainer addSubview:_textLinkLabel];

        self.textLinkTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLinkTitleLabel.backgroundColor = [UIColor clearColor];
        _textLinkTitleLabel.font = [UIFont systemFontOfSize:textLinkTitleFontSize];
        _textLinkTitleLabel.numberOfLines = 1;
        [_textLinkViewContainer addSubview:_textLinkTitleLabel];
        
        self.textLinkBgButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_textLinkBgButton addTarget:self action:@selector(textLinkBgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_textLinkViewContainer addSubview:_textLinkBgButton];
        
        [self reloadThemeUI];
    }
}

- (void)buildViewForBannerView
{
    if (!_bannerViewContainer) {
        self.bannerViewContainer = [[UIView alloc] initWithFrame:[self frameForBannerContainer]];
        _bannerViewContainer.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        [self addSubview:_bannerViewContainer];
        
        self.bannerImageView = [[SSAvatarView alloc] initWithFrame:[self frameForBannerIConView]];
        _bannerImageView.avatarSupportNightModel = YES;
        _bannerImageView.avatarStyle = SSAvatarViewStyleRectangle;
        _bannerImageView.avatarImgPadding = 0.f;
        _bannerImageView.rectangleAvatarImgRadius = 2.f;
        _bannerImageView.backgroundColor = [UIColor clearColor];
        [_bannerViewContainer addSubview:_bannerImageView];
        
        self.bannerTitleLabel = [[UILabel alloc] initWithFrame:[self frameForBannerTitleView]];
        _bannerTitleLabel.font = [UIFont boldSystemFontOfSize:bannerTitleLabelFontSize];
        _bannerTitleLabel.backgroundColor = [UIColor clearColor];
        _bannerTitleLabel.numberOfLines = 1;
        [_bannerViewContainer addSubview:_bannerTitleLabel];
        
        self.bannerDescLabel = [[UILabel alloc] initWithFrame:[self frameForBannerDescView]];
        _bannerDescLabel.font = [UIFont systemFontOfSize:bannerDescLabelFontSize];
        _bannerDescLabel.backgroundColor = [UIColor clearColor];
        _bannerDescLabel.numberOfLines = 2;
        [_bannerViewContainer addSubview:_bannerDescLabel];
        
        self.bannerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _bannerLabel.backgroundColor = [UIColor clearColor];
        _bannerLabel.textAlignment = NSTextAlignmentCenter;
        _bannerLabel.font = [UIFont systemFontOfSize:bannerLabelFontSize];
        [_bannerViewContainer addSubview:_bannerLabel];
        
        self.bannerBgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bannerBgButton.backgroundColor = [UIColor clearColor];
        [_bannerBgButton addTarget:self action:@selector(bannerBgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_bannerViewContainer addSubview:_bannerBgButton];
        
        [self reloadThemeUI];
    }
}


- (void) buildViewForImageView {
    if (!_imageBannerView) {
        
        _imageBannerView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _imageBannerView.hidden = YES;
        _imageBannerView.backgroundColor = [UIColor clearColor];
        _imageBannerView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageBannerView];
        
        
        self.imageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _imageLabel.backgroundColor = [UIColor clearColor];
        _imageLabel.textAlignment = NSTextAlignmentCenter;
        _imageLabel.font = [UIFont systemFontOfSize:bannerLabelFontSize];
        [_imageBannerView addSubview:_imageLabel];
        
        [self reloadThemeUI];
    }
}

- (void)actionButtonClickedForModel:(ArticleDetailADModel *)model
{
    switch (model.ADActionType) {
        case SSADModelActionTypeApp:
        {
            [[SSADActionManager sharedManager] handleAppActionForADBaseModel:model];
            
            if (isEmptyString(model.appURL) && isEmptyString(model.openURL)) {
                [TTAdMonitorManager trackService:@"ad_article_app" status:0 extra:model.monitorInfo];
            }
        }
            break;
        case SSADModelActionTypeWeb:
        {
            NSMutableString *urlString = [NSMutableString stringWithString:model.webURL];
            SSWebViewController * controller = [[SSWebViewController alloc] initWithSupportIPhoneRotate:YES];
            controller.adID = [NSString stringWithFormat:@"%lld", model.adID.longLongValue];
            controller.logExtra = model.logExtra;
            [controller requestWithURL:[TTStringHelper URLWithURLString:urlString]];
            UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
            [topController.navigationController pushViewController:controller animated:YES];
            [controller setTitleText:model.webTitle];
            [model sendTrackEventWithLabel:@"click"];
            
            if (isEmptyString(model.webURL)) {
                [TTAdMonitorManager trackService:@"ad_article_web" status:0 extra:model.monitorInfo];
            }
        }
            break;
        default: {
            [TTAdMonitorManager trackService:@"ad_article_others" status:0 extra:model.monitorInfo];
        }
            break;
    }

}

- (void)bannerBgButtonClicked
{
    [self actionButtonClickedForModel:_bannerModel];
}

- (void) imageBannerViewTapActionFired:(id) gesture {
    [self actionButtonClickedForModel:_imageBannerModel];
}

- (void)appDownloadButtonTagActionFired
{
    [self actionButtonClickedForModel:_appModel];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    _textLinkLabel.textColor = [UIColor tt_themedColorForKey:kColorBackground4];
    _textLinkLabel.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"4073ba" nightColorName:@"57607f"]];
    _textLinkTitleLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"4073ba" nightColorName:@"57607f"]];
    
    _bannerViewContainer.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"fafafa" nightColorName:@"2b2b2b"]];
    _bannerViewContainer.layer.borderColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"dedede" nightColorName:@"303030"]].CGColor;
    _bannerTitleLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"454545" nightColorName:@"707070"]];
    
    _bannerLabel.textColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"252525"];
    _bannerLabel.backgroundColor = [UIColor colorWithDayColorName:@"2a90d7" nightColorName:@"3c6598"];
    
    _imageLabel.textColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"252525"];
    _imageLabel.backgroundColor = [UIColor colorWithDayColorName:@"2a90d7" nightColorName:@"3c6598"];
    
    _bannerDescLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"707070" nightColorName:@"505050"]];

}

- (void)sendShowEventIfNeed
{
    if (_sendedShowTrack) {
        return;
    }
    _sendedShowTrack = YES;

    [_bannerModel sendTrackEventWithLabel:@"show"];
    [_imageBannerModel sendTrackEventWithLabel:@"show"];
    [_appModel sendTrackEventWithLabel:@"show"];
}

- (void)setBannerModel:(ArticleDetailADModel *)bannerModel
{
    if (_bannerModel != bannerModel) {
        _bannerModel = bannerModel;
        
        _sendedShowTrack = NO;
    }
}

- (void) setImageBannerModel:(ArticleDetailADModel *)imageBannerModel {
    if (_imageBannerModel != imageBannerModel) {
        _imageBannerModel = imageBannerModel;
        
        _sendedShowTrack = NO;
    }
}

- (void)setAppModel:(ArticleDetailADModel *)appModel {
    if (_appModel != appModel) {
        _appModel = appModel;
        
        _sendedShowTrack = NO;
    }
}

#pragma mark - Getter
- (UIView *)appContainerView
{
    if (!_appContainerView) {
        _appContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _appContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_appContainerView];
    }
    return _appContainerView;
}

- (TTImageView *)appImageView
{
    if (!_appImageView) {
        _appImageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        _appImageView.backgroundColor = [UIColor clearColor];
        [self.appContainerView addSubview:_appImageView];
    }
    return _appImageView;
}

- (UILabel *)appNameLabel
{
    if (!_appNameLabel) {
        _appNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _appNameLabel.backgroundColor = [UIColor clearColor];
        _appNameLabel.font = [UIFont systemFontOfSize:15.0f];
        _appNameLabel.textColor = SSGetThemedColorInArray(@[@"999999", @"505050"]);
        [self.appContainerView addSubview:_appNameLabel];
    }
    return _appNameLabel;
}

- (UILabel *)appInfoLabel
{
    if (!_appInfoLabel) {
        _appInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _appInfoLabel.backgroundColor = [UIColor clearColor];
        _appInfoLabel.font = [UIFont systemFontOfSize:10.0f];
        _appInfoLabel.textColor = _appNameLabel.textColor;
        [self.appContainerView addSubview:_appInfoLabel];
    }
    return _appInfoLabel;
}

- (UIButton *)appDownloadButton
{
    if (!_appDownloadButton) {
        _appDownloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _appDownloadButton.frame = CGRectZero;
        _appDownloadButton.backgroundColor = [UIColor clearColor];
        _appDownloadButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [_appDownloadButton setTitleColor:SSGetThemedColorInArray(@[@"2a90d7", @"67778b"]) forState:UIControlStateNormal];
        _appDownloadButton.layer.cornerRadius = 6.0f;
        _appDownloadButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _appDownloadButton.layer.borderColor = [SSGetThemedColorInArray(@[@"2a90d7", @"67778b"]) CGColor];
//        _appDownloadButton.layer.backgroundColor = [[UIColor clearColor] CGColor];
        [_appDownloadButton addTarget:self
                               action:@selector(downloadAppActionFired:)
                     forControlEvents:UIControlEventTouchUpInside];
        [self.appContainerView addSubview:_appDownloadButton];
    }
    return _appDownloadButton;
}

- (UILabel *)adsFlagLabel
{
    if (!_adsFlagLabel) {
        _adsFlagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _adsFlagLabel.backgroundColor = [UIColor clearColor];
        _adsFlagLabel.font = [UIFont systemFontOfSize:9.0f];
        _adsFlagLabel.textColor = SSGetThemedColorInArray(@[@"ffffff", @"cacaca"]);
        _adsFlagLabel.textAlignment = NSTextAlignmentCenter;
        CALayer *layer = _adsFlagLabel.layer;
        layer.borderColor = [_adsFlagLabel.textColor CGColor];
        layer.borderWidth = [TTDeviceHelper ssOnePixel];
        layer.cornerRadius = 2.0f;
        layer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] CGColor];
        [self.appImageView addSubview:_adsFlagLabel];
    }
    return _adsFlagLabel;
}

#pragma mark - Layout

- (void)refreshWithWidth:(CGFloat)width
{
    [super refreshWithWidth:width];
    [self refreshUI];
}

- (void)refreshUI
{
    CGFloat height = [ArticleDetailADView heightTxtLineADModel:nil
                                                 bannerADModel:_bannerModel
                                                  imageADModel:_imageBannerModel
                                                    appADModel:_appModel
                                            constrainedToWidth:self.width];
    self.height = height;
    
    if ([_bannerModel isModelAvailable]) {
        [self buildViewForBannerView];
        _bannerViewContainer.frame = [self frameForBannerContainer];
        [_bannerImageView showAvatarByURL:_bannerModel.imageURLString];
        _bannerTitleLabel.text = _bannerModel.titleString;
        _bannerDescLabel.text = _bannerModel.descString;
        _bannerLabel.text = _bannerModel.labelString;
        [_bannerLabel sizeToFit];
        _bannerLabel.frame = [self frameForBannerLabel];
        _bannerBgButton.frame = CGRectMake(0, 0, _bannerViewContainer.frame.size.width, _bannerViewContainer.frame.size.height);
        _bannerViewContainer.hidden = NO;
    }
    else {
        _bannerViewContainer.hidden = YES;
    }

    if ([_imageBannerModel isModelAvailable]) {
        [self buildViewForImageView];
        self.imageBannerView.hidden = NO;
        self.imageBannerView.frame = [self frameForImageContainer];
        [self.imageBannerView setImageWithURLString:_imageBannerModel.imageURLString];
        
        UITapGestureRecognizer * panGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageBannerViewTapActionFired:)];
        [self.imageBannerView addGestureRecognizer:panGesture];
        
        _imageLabel.text = _imageBannerModel.labelString;
        [_imageLabel sizeToFit];
        if (_imageLabel.text.length == 0) {
            _imageLabel.frame = CGRectZero;
        } else {
            _imageLabel.origin = CGPointMake(self.imageBannerView.width - _imageLabel.width, self.imageBannerView.height - _imageLabel.height);
        }
    } else {
        self.imageBannerView.hidden = YES;
    }
    
    if ([_appModel isModelAvailable]) {
        [self layoutAppContainerViewSubViews];
    }
    else {
        self.appContainerView.hidden = YES;
    }
}

- (void)layoutAppContainerViewSubViews {
    [self updateAppContainerViewData];
    CGFloat appImageViewWidth = [[UIScreen mainScreen] bounds].size.width * 0.6;   //应用图片宽度占屏幕宽度60%
    CGFloat appImageViewHeight = appImageAspect ? appImageViewWidth / appImageAspect : 100;
    self.appImageView.frame = CGRectMake(0, 0, appImageViewWidth, appImageViewHeight);
    self.adsFlagLabel.frame = CGRectMake(self.appImageView.right - 23 - 2, self.appImageView.bottom - 13 - 2, 23, 13);
    
    [self.appNameLabel sizeToFit];
    self.appNameLabel.frame = CGRectMake(self.appImageView.right + 10, 16, self.appNameLabel.width, self.appNameLabel.height);
    [self.appInfoLabel sizeToFit];
    self.appInfoLabel.frame = CGRectMake(self.appNameLabel.left, self.appNameLabel.bottom + 4, self.appInfoLabel.width, self.appInfoLabel.height);
    
//    CGFloat buttonTop = self.appInfoLabel.hidden ? self.appNameLabel.bottom + 28 : self.appInfoLabel.bottom + 18;
    self.appDownloadButton.frame = CGRectMake(self.appNameLabel.left, self.bottom - 32 - 16, 72, 32);
    self.appContainerView.frame = CGRectMake(0, 0, self.width, self.height);
    self.appContainerView.hidden = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadAppActionFired:)];
    tap.delegate = self;
    [self.appContainerView addGestureRecognizer:tap];
}

- (void)updateAppContainerViewData
{
    [self.appImageView setImageWithURLString:_appModel.imageURLString];
    self.adsFlagLabel.text = _appModel.labelString;
    self.appNameLabel.text = _appModel.appName;
    NSString *appInfo = nil;
    if (!isEmptyString(_appModel.appSize)) {
        appInfo = _appModel.appSize;
    }
    if (!isEmptyString(_appModel.downloadCount)) {
        appInfo = [appInfo stringByAppendingFormat:@"  %@", _appModel.downloadCount];
    }
    if (!isEmptyString(appInfo)) {
        self.appInfoLabel.text = appInfo;
    }
    else {
        self.appInfoLabel.hidden = YES;
    }
    
    [self.appDownloadButton setTitle:_appModel.buttonText forState:UIControlStateNormal];
}

#pragma mark - Action
- (void)downloadAppActionFired:(id)sender{
    //TODO:给SSADActionManager传SSADBaseModel进去执行下载和track操作
    [[SSADActionManager sharedManager] handleAppActionForADBaseModel:_appModel];
}

#pragma mark - Helper

- (CGRect)frameForBannerLabel
{
    if (isEmptyString(_bannerModel.labelString)) {
        return CGRectZero;
    }
    else {
        
        CGFloat width = MAX(30, _textLinkLabel.frame.size.width);
        width = MIN(width, 60);
        
        CGRect bannerContainerFrame = [self frameForBannerContainer];
        CGRect result = CGRectMake(0, 0, width, bannerLabelFontSize + 2);
        result.origin.x = bannerContainerFrame.size.width - result.size.width - [TTDeviceHelper ssOnePixel];
        result.origin.y = bannerContainerFrame.size.height - result.size.height - [TTDeviceHelper ssOnePixel];
        return result;
    }
}

- (CGRect)frameForBannerDescView
{
    CGRect frame = CGRectZero;
    CGRect bannerTitleViewFrame = [self frameForBannerTitleView];
    frame.origin.x = CGRectGetMinX(bannerTitleViewFrame);
    frame.origin.y = CGRectGetMaxY(bannerTitleViewFrame) + 4;
    frame.size.width = CGRectGetWidth(bannerTitleViewFrame);
    frame.size.height = CGRectGetMaxY(_bannerImageView.frame) - CGRectGetMaxY(bannerTitleViewFrame);
    return frame;
}

- (CGRect)frameForBannerTitleView
{
    CGRect frame = CGRectZero;
    frame.origin.x = CGRectGetMaxX(_bannerImageView.frame) + ([TTDeviceHelper isPadDevice] ? 13 : 10);
    frame.origin.y = CGRectGetMinY(_bannerImageView.frame);
    frame.size.width = CGRectGetWidth(_bannerViewContainer.frame) - frame.origin.x - ([TTDeviceHelper isPadDevice] ? 13 : 10);
    frame.size.height = bannerTitleLabelFontSize + 2;
    return frame;
}

- (CGRect)frameForBannerIConView
{
    if ([TTDeviceHelper isPadDevice]) {
        return CGRectMake(10, 8, 50, 50);
    }
    else {
        return CGRectMake(12, 15, 50, 50);
    }
}

- (CGRect)frameForBannerContainer
{
    CGRect frame;
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat width = bannerViewContainerPadWidth;
        CGFloat originX = (self.frame.size.width - bannerViewContainerPadWidth) / 2 ;
        frame = CGRectMake(originX, topPadding, width, bannerViewContainerHeight);
    }
    else {
        frame = CGRectMake(0, 0, self.width, bannerViewContainerHeight);
    }
    return frame;
}

- (CGRect)frameForTextLinkContainer
{
    CGRect bannerContainerFrame = [self frameForBannerContainer];
    CGFloat width = bannerContainerFrame.size.width - 10 * 2;
    CGFloat originX = CGRectGetMinX(bannerContainerFrame) + 10;
    CGFloat originY = _bannerViewContainer ? CGRectGetMaxY(_bannerViewContainer.frame) :topPadding - middlePadding;
    CGRect frame = CGRectMake(originX, originY, width, textLinkViewContainerHeight);
    return frame;
}

- (CGRect) frameForImageContainer
{
    CGRect frame = self.bounds;
    return frame;
}

- (void)refreshWithJson:(NSDictionary *)detailADDict
{
//    app ad
//    detailADDict = @{@"app":@{
//                             @"ad_id":@"4534107356",
//                             @"app_name":@"内涵图片段子",
//                             @"app_size":@"12k",
//                             @"download_count":@"5万次下载",
//                             @"appleid":@"517166184",
//                             @"button_text":@"立即下载",
//                             @"description":@"hello word",
//                             @"download_url":@"https://itunes.apple.com/cn/app/nei-han-duan-zi-pu-tong-ban/id517166184?mt=8",
//                             @"id":@"4534109731",
//                             @"image":@{@"url_list":@[@{@"url":@"http://p0.pstatp.com/origin/4617/2546874397"}],
//                                        @"height":@(238),
//                                        @"width":@(428)},
//                             @"label":@"广告",
//                             @"open_url":@"",
//                             @"rate":@"-1",
//                             @"track_url":@"",
//                             @"track_url_list":@[],
//                             @"type":@"app",
//                             }};
    NSDictionary *adModels = [[self class] detailADModelsWithJson:detailADDict];
    self.bannerModel = adModels[@"banner"];
    self.imageBannerModel = adModels[@"image"];
    self.appModel = adModels[@"app"];
    [self refreshUI];
}

+ (NSDictionary *)detailADModelsWithJson:(NSDictionary *)detailADDict
{
    NSMutableDictionary *adModels = [NSMutableDictionary dictionaryWithCapacity:5];
    NSDictionary * bannerADDict = [detailADDict objectForKey:@"banner"];
    ArticleDetailADModel * bannerADModel = nil;
    if ([bannerADDict count] > 0) {
        bannerADModel = [[ArticleDetailADModel alloc] initWithDictionary:bannerADDict detailADType:ArticleDetailADModelTypeBanner];
        if (![bannerADModel isModelAvailable]) {
            bannerADModel = nil;
        }
    }
    
    NSDictionary * imageADDict = [detailADDict objectForKey:@"image"];
    ArticleDetailADModel * imageADModel = nil;
    if (imageADDict.count > 0) {
        imageADModel = [[ArticleDetailADModel alloc] initWithDictionary:imageADDict detailADType:ArticleDetailADModelTypeImage];
        if (![imageADModel isModelAvailable]) {
            imageADModel = nil;
        }
    }
    
    NSDictionary * appADDict = detailADDict[@"app"];
    ArticleDetailADModel *appModel = nil;
    if (appADDict.count) {
        appModel = [[ArticleDetailADModel alloc] initWithDictionary:appADDict detailADType:ArticleDetailADModelTypeApp];
        if (![appModel isModelAvailable]) {
            appModel = nil;
        }
    }
    
    /*
    NSDictionary * videoAppADDict = detailADDict[@"videoApp"];
    ArticleDetailADModel *videoAppModel = nil;
    if (videoAppADDict.count) {
        videoAppModel = [[ArticleDetailADModel alloc] initWithDictionary:appADDict detailADType:ArticleDetailADModelTypeVideoApp];
        if (![videoAppModel isModelAvailable]) {
            videoAppModel = nil;
        }
    }
    [adModels setValue:videoAppModel forKey:@"videoApp"];
     */
    
    [adModels setValue:bannerADModel forKey:@"banner"];
    [adModels setValue:imageADModel forKey:@"image"];
    [adModels setValue:appModel forKey:@"app"];
    
    return adModels;
}

+ (CGFloat)heightTxtLineADModel:(ArticleDetailADModel *)txtModel
                  bannerADModel:(ArticleDetailADModel *)bannerModel
                   imageADModel:(ArticleDetailADModel *)imageModel
                     appADModel:(ArticleDetailADModel *)appModel
             constrainedToWidth:(CGFloat)cellWidth
{
    CGFloat height = 0;
    BOOL txtModelExist = [txtModel isModelAvailable];
    BOOL bannerModelExist = [bannerModel isModelAvailable];
    BOOL imageModelExist = [imageModel isModelAvailable];
    BOOL appModelExist = [appModel isModelAvailable];
    
    if (imageModelExist) {
        CGFloat imageHeight = imageModel.imageHeight / imageModel.imageWidth * cellWidth;
        height += imageHeight;
    }
    else {
        if (bannerModelExist) {
            height += bannerViewContainerHeight;
            if ([TTDeviceHelper isPadDevice]) {
                if (height > 0) {
                    height += (topPadding + bottomPadding + (txtModelExist + bannerModelExist + imageModelExist - 1) * middlePadding);
                }
            }
        }
        else if (txtModelExist) {
            height += (textLinkViewContainerHeight - middlePadding - bottomPadding);
            if (height > 0) {
                height += (topPadding + bottomPadding + (txtModelExist + bannerModelExist + imageModelExist - 1) * middlePadding);
            }
        }
        else if (appModelExist) {
            if (appModel.imageHeight > 0) {
                appImageAspect = appModel.imageWidth / appModel.imageHeight;
            }
            height = appImageAspect ? [[UIScreen mainScreen] bounds].size.width * 0.6 / appImageAspect : 100.f;
        }
    }
    return height;
}

+ (CGFloat)heightForJson:(NSDictionary *)detailADDict cellWidth:(CGFloat)cellWidth
{
    NSDictionary *adModels = [self detailADModelsWithJson:detailADDict];
    return [self heightTxtLineADModel:adModels[@"text_link"]
                        bannerADModel:adModels[@"banner"]
                         imageADModel:adModels[@"image"]
                           appADModel:adModels[@"app"]
                   constrainedToWidth:cellWidth];
}

@end
