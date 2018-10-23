//
//  TTDetailNatantVideoADView.m
//  Article
//
//  Created by 刘廷勇 on 16/6/7.
//
//

#import "TTDetailNatantVideoADView.h"

#import "ArticleInfoManager.h"
#import "Article.h"
#import "SSWebViewController.h"
#import "TTDeviceUIUtils.h"
#import "TTStringHelper.h"

#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSADEventTracker.h"
#import "TTAdAction.h"
#import "TTAdAppointAlertView.h"
#import "TTAdFeedModel.h"
#import "TTAdManager.h"
#import "TTAdMonitorManager.h"


@interface TTDetailNatantVideoAdModel : JSONModel

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *openURL;

@end

@implementation TTDetailNatantVideoAdModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"url"      : @"openURL",
                           @"icon_url" : @"imageURL",
                           @"desc"     : @"desc",
                           @"name"     : @"title"
                           };
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

@end


@interface TTDetailNatantVideoADView ()

@property (nonatomic, strong) TTImageView *imageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *infoLabel;
@property (nonatomic, strong) ExploreActionButton *actionButton;

@property (nonatomic, strong) id<TTAdFeedModel> adModel;
@property (nonatomic, strong) UIView *infoContainerView;
@property (nonatomic, strong) TTDetailNatantVideoAdModel *bannerModel;

@end

@implementation TTDetailNatantVideoADView

@synthesize willDisAppearBlock = _willDisAppearBlock;
@synthesize willAppearBlock = _willAppearBlock;
@synthesize viewState = _viewState;

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
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

- (void)setData:(ExploreOrderedData *)data
{
    if (_data != data) {
        _data = data;
       // self.adModel = data.adModel;
        self.actionButton.actionModel = data;
    }
}

- (void)setAdModel:(id<TTAdFeedModel>)adModel
{
    if (_adModel != adModel) {
        _adModel = adModel;
        [self refreshUI];
    }
}

- (void)refreshUI
{
    NSDictionary *urlHeader = nil;
    if (self.bannerModel.imageURL) {
        urlHeader = @{@"url" : self.bannerModel.imageURL};
    }
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithURL:self.bannerModel.imageURL withHeader:urlHeader];
    [self.imageView setImageWithModel:imageModel placeholderView:self.placeholderView];
    
    self.actionButton.actionModel = self.data;
    self.titleLabel.text = self.bannerModel.title;
    self.infoLabel.text = self.bannerModel.desc;
    
    [self setupConstraints];
}

- (void)reloadData:(id)object
{
    if (![object isKindOfClass:[ArticleInfoManager class]]) {
        return;
    }
    ArticleInfoManager *articleInfo = (ArticleInfoManager *)object;
    self.bannerModel = [[TTDetailNatantVideoAdModel alloc] initWithDictionary:articleInfo.videoEmbededAdInfo error:nil];
    [self refreshUI];
}

- (void)_downloadAppActionFired:(id)sender
{
    switch (self.adModel.adType) {
        case ExploreActionTypeApp:
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionButton.actionModel label:@"click_start" eventName:@"detail_download_ad"];
            break;
        case ExploreActionTypeAction:
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionButton.actionModel label:@"click_call" eventName:@"detail_call"];
            [self listenCall:self.adModel];
            break;
        case ExploreActionTypeWeb:
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionButton.actionModel label:@"click_landingpage" eventName:@"embeded_ad"];
            break;
        case ExploreActionTypeForm:
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionButton.actionModel label:@"click_button" eventName:@"detail_form"];
            [self showForm:self.actionButton.actionModel];
            break;
        default:
            break;
    }
    [self.actionButton actionButtonClicked:sender showAlert:NO];
}

- (void)showForm:(ExploreOrderedData *)orderdata
{
    TTAdFeedModel* rawAdModel = orderdata.raw_ad;
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc] initWithAdId:rawAdModel.ad_id logExtra:rawAdModel.log_extra formUrl:rawAdModel.form_url width:rawAdModel.form_width height:rawAdModel.form_height sizeValid:rawAdModel.use_size_validation];
    
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceDetail completeBlock:^(TTAdApointCompleteType type) {
        if (type == TTAdApointCompleteTypeCloseForm) {
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"click_cancel" eventName:@"detail_form"];
        }
        else if (type == TTAdApointCompleteTypeLoadFail){
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"load_fail" eventName:@"detail_form"];
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
    if (!isEmptyString(self.bannerModel.openURL)) {
        UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor:self];
        ssOpenWebView([TTStringHelper URLWithURLString:self.bannerModel.openURL], nil, topController, NO, nil);
        
        switch (self.adModel.adType) {
            case ExploreActionTypeApp:
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionButton.actionModel label:@"click_card" eventName:@"detail_download_ad"];
                break;
            case ExploreActionTypeAction:
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionButton.actionModel label:@"click_card" eventName:@"detail_call"];
                break;
            case ExploreActionTypeWeb:
                [[SSADEventTracker sharedManager] trackEventWithOrderedData:self.actionButton.actionModel label:@"click_card" eventName:@"embeded_ad"];
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
    if (self.bannerModel.title.length >= 1) {
        firstName = [self.bannerModel.title substringToIndex:1];
    }
    SSThemedLabel *view = [[SSThemedLabel alloc] init];
    view.text = firstName;
    view.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:19]];
    view.textColorThemeKey = kColorText12;
    [view sizeToFit];
    return view;
}

@end
