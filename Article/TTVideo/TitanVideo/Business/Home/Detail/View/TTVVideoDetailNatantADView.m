//
//  TTVVideoDetailNatantADView.m
//  Article
//
//  Created by pei yun on 2017/5/23.
//
//

#import "TTVVideoDetailNatantADView.h"
#import <TTVideoService/VideoInformation.pbobjc.h>
#import "SSWebViewController.h"
#import "TTStringHelper.h"
#import "TTAdManager.h"
#import "SSURLTracker.h"
#import "ExploreActionButton.h"
#import "TTImageView.h"
#import "TTAdFeedModel.h"
#import "TTAdAppointAlertView.h"
#import "TTAdAction.h"
#import "SSADEventTracker.h"

@interface TTVVideoDetailNatantADView ()

@property (nonatomic, strong) TTImageView *imageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *infoLabel;
@property (nonatomic, strong) ExploreActionButton *actionButton;

@property (nonatomic, strong) id<TTAdFeedModel> adModel;
@property (nonatomic, strong) UIView *infoContainerView;

@end

@implementation TTVVideoDetailNatantADView

@synthesize willDisAppearBlock = _willDisAppearBlock;
@synthesize willAppearBlock = _willAppearBlock;
@synthesize viewState = _viewState;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.height = [TTDeviceUIUtils tt_padding:60];
        self.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:self.imageView];
        [self addSubview:self.infoContainerView];
        [self.infoContainerView addSubview:self.titleLabel];
        [self.infoContainerView addSubview:self.infoLabel];
        [self addSubview:self.actionButton];
        [self setupConstraints];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWebView)];
        [self addGestureRecognizer:tap];
        
        __weak typeof(self) wself = self;
        self.willAppearBlock = ^{
            __strong typeof(wself) self = wself;
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionButton.actionModel label:@"detail_show" eventName:@"embeded_ad"];
        };
    }
    return self;
}

- (void)setArticle:(id<TTVVideoDetailNatantADViewDataProtocol> )article
{
    if (_article != article) {
        _article = article;
        self.adModel = article.adModel;
        [self refreshUI];
    }
}

- (void)refreshUI
{
    NSDictionary *urlHeader = nil;
    if (self.article.adVideoInfo.iconURL) {
        urlHeader = @{@"url" : self.article.adVideoInfo.iconURL};
    }
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithURL:self.article.adVideoInfo.iconURL withHeader:urlHeader];
    [self.imageView setImageWithModel:imageModel placeholderView:self.placeholderView];
    
    self.actionButton.adModel = self.adModel;
    self.titleLabel.text = self.article.adVideoInfo.name;
    self.infoLabel.text = self.article.adVideoInfo.desc;
    
    [self setupConstraints];
}

- (void)_downloadAppActionFired:(id)sender
{
    TTADEventTrackerEntity *trackerEntity = nil;
    if (self.getADEventTrackerEntity) {
        trackerEntity = self.getADEventTrackerEntity();
    }
    switch (self.adModel.adType) {
        case ExploreActionTypeApp:
            [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click_start" eventName:@"detail_download_ad"];
            break;
        case ExploreActionTypeAction:
            [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click_call" eventName:@"detail_call"];
            [self listenCall:self.adModel];
            break;
        case ExploreActionTypeWeb:
            [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click_landingpage" eventName:@"embeded_ad"];
            break;
        case ExploreActionTypeForm:
            [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click_button" eventName:@"detail_form"];
            [self showForm:self.adModel trackerEntity:trackerEntity];
            break;
        default:
            break;
    }
    [self.actionButton actionButtonClicked:sender showAlert:NO];
}

- (void)showForm:(id<TTAdFeedModel>)adModel trackerEntity:(TTADEventTrackerEntity *)trackerEntity
{
    TTAdFeedModel* rawAdModel = [[TTAdFeedModel alloc] initWithDictionary:self.detailStateStore.state.rawAdData error:nil];
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc] initWithAdId:rawAdModel.ad_id logExtra:rawAdModel.log_extra formUrl:rawAdModel.form_url width:rawAdModel.form_width height:rawAdModel.form_height sizeValid:rawAdModel.use_size_validation];
    
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceDetail completeBlock:^(TTAdApointCompleteType type) {
        if (type == TTAdApointCompleteTypeCloseForm) {
            [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click_cancel" eventName:@"detail_form"];
        }
        else if (type == TTAdApointCompleteTypeLoadFail){
            [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"load_fail" eventName:@"detail_form"];
        }
    }];
}

//监听电话状态
- (void)listenCall:(id<TTAdFeedModel>)adModel
{
    TTAdCallListenModel* callModel = [[TTAdCallListenModel alloc] init];
    callModel.ad_id = adModel.ad_id;
    callModel.log_extra = adModel.log_extra;
    callModel.position = @"detail_call";
    callModel.dailTime = [NSDate date];
    callModel.dailActionType = adModel.dialActionType;
    [TTAdManageInstance call_callAdModel:callModel];
}

- (void)openWebView
{
    if (!isEmptyString(self.article.adVideoInfo.URL)) {
        UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor:self];
        ssOpenWebView([TTStringHelper URLWithURLString:self.article.adVideoInfo.URL], nil, topController, NO, nil);
        
        TTADEventTrackerEntity *trackerEntity = nil;
        if (self.getADEventTrackerEntity) {
            trackerEntity = self.getADEventTrackerEntity();
        }
        switch (self.adModel.adType) {
            case ExploreActionTypeApp:
                [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click_card" eventName:@"detail_download_ad"];
                break;
            case ExploreActionTypeAction:
                [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click_card" eventName:@"detail_call"];
                break;
            case ExploreActionTypeWeb:
                [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click_card" eventName:@"embeded_ad"];
                break;
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark layout

- (void)setupConstraints
{
    BOOL hasDetailInfo = !isEmptyString(self.infoLabel.text);
    
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@([TTDeviceUIUtils tt_padding:40]));
        make.height.equalTo(@([TTDeviceUIUtils tt_padding:40]));
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset([TTDeviceUIUtils tt_padding:15]);
    }];
    
    [self.infoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.imageView.mas_right).offset([TTDeviceUIUtils tt_padding:5]);
        make.right.lessThanOrEqualTo(self.actionButton.mas_left).offset(-[TTDeviceUIUtils tt_padding:10]);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (hasDetailInfo) {
            make.top.equalTo(self.infoContainerView);
        } else {
            make.centerY.equalTo(self.infoContainerView);
        }
        
        make.left.equalTo(self.infoContainerView);
        make.right.lessThanOrEqualTo(self.infoContainerView);
    }];
    
    [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.infoContainerView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset([TTDeviceUIUtils tt_padding:4]);
        make.bottom.equalTo(self.infoContainerView);
        make.right.lessThanOrEqualTo(self.infoContainerView);
    }];
    
    [self.actionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-[TTDeviceUIUtils tt_padding:15]);
        make.width.mas_equalTo(72);
        make.height.mas_equalTo(28);
    }];
}

#pragma mark -
#pragma mark getters

- (TTImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[TTImageView alloc] init];
        _imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _imageView.backgroundColorThemeKey = kColorBackground1;
        _imageView.layer.cornerRadius = [TTDeviceUIUtils tt_padding:20];
    }
    return _imageView;
}

- (UIView *)infoContainerView
{
    if (!_infoContainerView) {
        _infoContainerView = [[UIView alloc] init];
        _infoContainerView.backgroundColor = [UIColor clearColor];
    }
    return _infoContainerView;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
    }
    return _titleLabel;
}

- (SSThemedLabel *)infoLabel
{
    if (!_infoLabel) {
        _infoLabel = [[SSThemedLabel alloc] init];
        _infoLabel.textColorThemeKey = kColorText3;
        _infoLabel.numberOfLines = 1;
        _infoLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
    }
    return _infoLabel;
}

- (ExploreActionButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [[ExploreActionButton alloc] init];
        _actionButton.backgroundColorThemeKey = kColorBackground3;
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_actionButton addTarget:self action:@selector(_downloadAppActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (SSThemedLabel *)placeholderView
{
    //缺省用来源名称第一个字作为头像
    NSString *firstName = @"";
    if (self.article.adVideoInfo.name.length >= 1) {
        firstName = [self.article.adVideoInfo.name substringToIndex:1];
    }
    SSThemedLabel *view = [[SSThemedLabel alloc] init];
    view.text = firstName;
    view.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:19]];
    view.textColorThemeKey = kColorText12;
    [view sizeToFit];
    return view;
}

@end
