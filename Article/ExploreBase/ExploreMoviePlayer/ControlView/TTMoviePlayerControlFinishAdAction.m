//
//  TTMoviePlayerControlFinishAdAction.m
//  Article
//
//  Created by songxiangwu on 2016/9/22.
//
//

#import "TTMoviePlayerControlFinishAdAction.h"
#import "SSThemed.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "TTImageView.h"
#import "TTRoute.h"
#import "SSWebViewController.h"
#import "TTVideoEmbededAdButton.h"
#import "TTModuleBridge.h"
#import <StoreKit/StoreKit.h>
#import "UIViewController+TTMovieUtil.h"
#import "TTURLTracker.h"
#import "TTUIResponderHelper.h"
#import <TTServiceKit/TTServiceCenter.h>

#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"
#import "SSADEventTracker.h"
#import "TTAdAction.h"
#import "TTAdAppointAlertView.h"
#import "TTAdFeedModel.h"
#import "TTAdManagerProtocol.h"
#import "TTAdMonitorManager.h"
#import "ExploreActionButton.h"

static const CGFloat kAvatarWidth = 44;
static const CGFloat kPadding1 = 6;
static const CGFloat kPadding2 = 20;

@interface TTMoviePlayerControlFinishAdAction ()

@property (nonatomic, weak) UIView <TTPlayerControlView> *baseView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, strong) ExploreOrderedData *data;

@end

@implementation TTMoviePlayerControlFinishAdAction

- (instancetype)initWithBaseView:(ExploreMoviePlayerControlView *)baseView {
    self = [super init];
    if (self) {
        _baseView = baseView;
        _backView = [[UIView alloc] initWithFrame:baseView.bounds];
        UIColor *color = [UIColor tt_defaultColorForKey:kColorBackground15];
        _backView.backgroundColor = [color colorWithAlphaComponent:0.8];
        [_baseView addSubview:_backView];
        _logoImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, kAvatarWidth, kAvatarWidth)];
        _logoImageView.userInteractionEnabled = YES;
        _logoImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _logoImageView.backgroundColorThemeKey = kColorBackground1;
        _logoImageView.layer.cornerRadius = kAvatarWidth / 2;
        _logoImageView.layer.masksToBounds = YES;
        [_baseView addSubview:_logoImageView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoImageViewTapped:)];
        [_logoImageView addGestureRecognizer:tapGesture];
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_baseView addSubview:_titleLabel];
        _actionBtn = [[ExploreActionButton alloc] init];
        _actionBtn.backgroundColorThemeKey = nil;
        _actionBtn.titleColorThemeKey = nil;
        _actionBtn.borderColorThemeKey = nil;
        _actionBtn.layer.borderWidth = 0;
        _actionBtn.frame = CGRectMake(0, 0, 72, 28);
        _actionBtn.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground8];
        [_actionBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText7] forState:UIControlStateNormal];
        _actionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _actionBtn.layer.cornerRadius = 6;
        _actionBtn.layer.masksToBounds = YES;
        [_actionBtn addTarget:self action:@selector(actionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_baseView addSubview:_actionBtn];
    }
    return self;
}

- (void)layoutSubviews {
    _backView.frame = _baseView.bounds;
    CGFloat totalH = kAvatarWidth + kPadding1 + _titleLabel.height + kPadding2 + _actionBtn.height;
    _logoImageView.top = (_baseView.height - totalH) / 2;
    _logoImageView.centerX = _baseView.width / 2;
    _titleLabel.top = _logoImageView.bottom + kPadding1;
    _titleLabel.centerX = _baseView.width / 2;
    _actionBtn.top = _titleLabel.bottom + kPadding2;
    _actionBtn.centerX = _baseView.width / 2;
    if ([_baseView hasAdButton]) {
        for (UIView *view in _baseView.subviews) {
            if ([view isKindOfClass:[TTVideoEmbededAdButton class]]) {
                view.right = _baseView.width - [TTDeviceUIUtils tt_padding:6.0];
                view.bottom = _baseView.height - [TTDeviceUIUtils tt_padding:6.0];
            }
        }
    }
}

- (void)setData:(ExploreOrderedData *)data {
    _data = data;
    _isAd = YES;
    _title = data.article.source;
    _imageURL = data.article.sourceAvatar;
    if (data.adModel.adType == ExploreActionTypeAction) {
    
        id obj = [data.article.embededAdInfo objectForKey:@"article_alt_url"];
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)obj;
            if (arr.count) {
                _openURL = [arr firstObject];
            }
        } else if ([obj isKindOfClass:[NSString class]]) {
            _openURL = obj;
        }
    }
    NSDictionary *urlHeader = nil;
    if (_imageURL) {
        urlHeader = @{@"url":_imageURL};
    }
    TTImageInfosModel *imageModel = [[TTImageInfosModel alloc] initWithURL:_imageURL withHeader:urlHeader];
    [_logoImageView setImageWithModel:imageModel placeholderView:[self placeholderView]];
    _titleLabel.text = _title;
    [_titleLabel sizeToFit];
    [_actionBtn setActionModel:data];
    [self layoutSubviews];
}

- (void)refreshSubView:(BOOL)hasFinished {
    if (hasFinished) {
        [self sendTrackEvent:@"video_end_ad" label:@"show"];
    }
    _backView.hidden = !hasFinished;
    _logoImageView.hidden = !hasFinished;
    _titleLabel.hidden = !hasFinished;
    _actionBtn.hidden = !hasFinished;
}

- (void)actionBtnClicked:(UIButton *)sender {
    void(^event_click)(void) = ^(void) {
        [self sendTrackEvent:@"video_end_ad" label:@"click"];
        TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:self.actionBtn.actionModel.ad_id logExtra:self.actionBtn.actionModel.log_extra];
        if (!SSIsEmptyArray(self.actionBtn.actionModel.adClickTrackURLs)) {
            ttTrackURLsModel(self.actionBtn.actionModel.adClickTrackURLs, trackModel);
        }
    };
    
    dispatch_block_t dimissBlock = ^ {
        if (!self.isIndetail) {
            event_click();
        }
        id<TTAdFeedModel> adModel = self.actionBtn.adModel;
        switch (self.actionBtn.adModel.adType) {
            case ExploreActionTypeApp:
            {
                BOOL appInstalled = [[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:adModel.open_url]] || [TTRoute conformsToRouteWithScheme:adModel.appUrl];
                if (appInstalled) {
                    [self sendTrackEvent:@"video_end_ad" label:@"click_open"];
                } else {
                    [self sendTrackEvent:@"video_end_ad" label:@"click_start"];
                }
            }
                break;
            case ExploreActionTypeWeb:
            {
                [self sendTrackEvent:@"video_end_ad" label:@"click_landingpage"];
            }
                break;
            case ExploreActionTypeAction:
            {
                [self sendTrackEvent:@"video_end_ad" label:@"click_call"];
                [self listenCall:adModel];
            }
                break;
            case ExploreActionTypeForm:
            {
                [self sendTrackEvent:@"video_end_ad" label:@"click_button"];
                [self showForm:self.data];
            }
                break;
            default:
                break;
        }
        [self.actionBtn actionButtonClicked:sender showAlert:NO];
    };
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        UIViewController *vc = [UIViewController ttmu_currentViewController];
        if ([vc isKindOfClass:[SKStoreProductViewController class]]) {
            [vc dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StoreVCDismissFromVideoDetailViewController" object:nil];
                dimissBlock();
            }];
        } else {
            dimissBlock();
        }
    } else {
        dimissBlock();
    }
}

- (void)showForm:(ExploreOrderedData *)orderdata
{
    TTAdFeedModel* rawAdModel = orderdata.raw_ad;
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc] initWithAdId:rawAdModel.ad_id logExtra:rawAdModel.log_extra formUrl:rawAdModel.form_url width:rawAdModel.form_width height:rawAdModel.form_height sizeValid:rawAdModel.use_size_validation];
    
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceFeed completeBlock:^(TTAdApointCompleteType type) {
        if (type == TTAdApointCompleteTypeCloseForm) {
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"click_cancel" eventName:@"video_end_ad"];
        }
        else if (type == TTAdApointCompleteTypeLoadFail){
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderdata label:@"load_fail" eventName:@"video_end_ad"];
        }
    }];
}

//监听电话状态
- (void)listenCall:(id<TTAdFeedModel>)adModel
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:adModel.ad_id forKey:@"ad_id"];
    [dict setValue:adModel.log_extra forKey:@"log_extra"];
    [dict setValue:[NSDate date] forKey:@"dailTime"];
    [dict setValue:@"video_end_ad" forKey:@"position"];
    [dict setValue:adModel.dialActionType forKey:@"dailActionType"];
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance call_callAdDict:dict];
}

- (void)logoImageViewTapped:(UITapGestureRecognizer *)gesture {
    void(^event_click)(void) = ^(void) {
        [self sendTrackEvent:@"video_end_ad" label:@"click"];
        TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[self.actionBtn.actionModel.adID stringValue] logExtra:self.actionBtn.actionModel.log_extra];
        if (!SSIsEmptyArray(self.actionBtn.actionModel.adClickTrackURLs)) {
            ttTrackURLsModel(self.actionBtn.actionModel.adClickTrackURLs, trackModel);
        }
    };
    
    dispatch_block_t dismissBlock = ^ {
        if (!self.isIndetail) {
            event_click();
        }
        id<TTAdFeedModel> adModel = self.actionBtn.adModel;
        if (!isEmptyString(self.openURL)) {
            [self sendTrackEvent:@"video_end_ad" label:@"click_card"];
            [self sendTrackEvent:@"video_end_ad" label:@"detail_show"];
            if ([(ExploreMoviePlayerController *)self.baseView.delegate isMovieFullScreen]) {
                [ExploreMovieView stopAllExploreMovieView];
            }
            UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor:self.baseView];
            ssOpenWebView([TTStringHelper URLWithURLString:self.openURL], nil, topController, NO, nil);
        } else {
            if (adModel.adType == ExploreActionTypeWeb) {
                [self sendTrackEvent:@"video_end_ad" label:@"click_card"];
            } else if (adModel.adType == ExploreActionTypeApp) {
                [self sendTrackEvent:@"video_end_ad" label:@"click_card"];
                [self sendTrackEvent:@"video_end_ad" label:@"detail_show"];
            }
            
            if (!isEmptyString(self.actionBtn.adModel.webURL)) {
                UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor:self.baseView];
                ssOpenWebView([TTStringHelper URLWithURLString:self.actionBtn.adModel.webURL], nil, topController, NO, nil);
            } else {
                [self.actionBtn actionButtonClicked:self.actionBtn showAlert:NO];
            }
        }
    };
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        UIViewController *vc = [UIViewController ttmu_currentViewController];
        if ([vc isKindOfClass:[SKStoreProductViewController class]]) {
            [vc dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StoreVCDismissFromVideoDetailViewController" object:nil];
                dismissBlock();
            }];
        } else {
            dismissBlock();
        }
    } else {
        dismissBlock();
    }
}

- (void)sendTrackEvent:(NSString *)event label:(NSString *)label {
    [[SSADEventTracker sharedManager] sendADWithOrderedData:_data event:event label:label extra:nil];
}

- (SSThemedLabel *)placeholderView {
    NSString *firstName = @"";
    if (_title.length >= 1) {
        firstName = [_title substringToIndex:1];
    }
    SSThemedLabel *view = [[SSThemedLabel alloc] init];
    view.text = firstName;
    view.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:19]];
    view.textColor = [UIColor tt_defaultColorForKey:kColorText12];
    [view sizeToFit];
    return view;
}

@end
