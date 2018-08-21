//
//  TTVPlayerTipAdOldFinish.m
//  Article
//
//  Created by panxiang on 2017/7/19.
//
//

#import "TTVPlayerTipAdOldFinish.h"

#import "Article.h"
#import "ExploreActionButton.h"
#import "ExploreOrderedData+TTAd.h"
#import "ExploreOrderedData.h"
#import "SSADEventTracker.h"
#import "SSWebViewController.h"
#import "TTAdAction.h"
#import "TTAdAppointAlertView.h"
#import "TTAdCallManager.h"
#import "TTAdFeedModel.h"
#import "TTAdManager.h"
#import "TTRoute.h"
#import "TTUIResponderHelper.h"
#import "TTURLTracker.h"
#import "TTVPlayerStateAction.h"
#import "TTVPlayerStateModel.h"
#import "UIViewController+TTMovieUtil.h"
#import <StoreKit/StoreKit.h>
#import "TTAdManager.h"
#import "TTAdFeedModel.h"
#import "TTAdAppointAlertView.h"
#import "TTAdAction.h"
#import "TTVPlayerStateStore.h"
#import "Article+TTADComputedProperties.h"
#import "TTTrackerProxy.h"

@interface TTVPlayerTipAdOldFinish ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, strong) ExploreActionButton *actionBtn;
@end

@implementation TTVPlayerTipAdOldFinish
@dynamic data;

- (void)dealloc
{

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
        [self.backView addSubview:_actionBtn];
    }
    return self;
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    [super actionChangeCallbackWithAction:action state:state];
    if ([action isKindOfClass:[TTVPlayerStateAction class]] && ([state isKindOfClass:[TTVPlayerStateModel class]] || state == nil)) {
        switch (action.actionType) {
            case TTVPlayerEventTypeFinishUIShow:{
                [self sendTrackEvent:@"video_end_ad" label:@"show"];
            }
                break;
            default:
                break;
        }
    }
    
}

- (void)setExploreOrderedData:(ExploreOrderedData *)data
{
    _title = data.article.source;
    _imageURL = data.article.sourceAvatar;
    if (data.article.adModel.adType == ExploreActionTypeAction) {
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
    [self.logoImageView setImageWithModel:imageModel placeholderView:[self placeholderViewWithTitle:self.title]];
    self.titleLabel.text = _title;
    [self.titleLabel sizeToFit];
    self.webURL = data.article.adModel.webURL;
    [_actionBtn setAdModel:data.article.adModel];
}

- (void)setData:(id)data {
    [super setData:data];
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        [self setExploreOrderedData:data];
    }
    [self layoutIfNeeded];
}

- (void)actionBtnClicked:(UIButton *)sender {
    
    [self.playerStateStore sendAction:TTVPlayerEventTypeAdDetailAction payload:nil];

    void(^event_click)(void) = ^(void) {
        NSMutableDictionary *extra = [@{} mutableCopy];
        if (self.actionBtn.adModel.adType == ExploreActionTypeApp) {
            [[self class] trackRealTime:self.actionBtn.actionModel extraData:nil];
            [extra setValue:@"1" forKey:@"has_v3"];
        }
        [self sendTrackEvent:@"video_end_ad" label:@"click" extra:extra];
        TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[self.actionBtn.actionModel.adID stringValue] logExtra:self.actionBtn.actionModel.log_extra];
        if (!SSIsEmptyArray(self.actionBtn.actionModel.adClickTrackURLs)) {
            ttTrackURLsModel(self.actionBtn.actionModel.adClickTrackURLs, trackModel);
        } 
    };
    
    dispatch_block_t dimissBlock = ^ {
        
        if (!self.playerStateStore.state.isInDetail) {
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
    TTAdCallListenModel* callModel = [[TTAdCallListenModel alloc] init];
    callModel.ad_id = adModel.ad_id;
    callModel.log_extra = adModel.log_extra;
    callModel.position = @"video_end_ad";
    callModel.dailTime = [NSDate date];
    callModel.dailActionType = adModel.dialActionType;
    [[TTAdManager sharedManager] call_callAdModel:callModel];
}

+ (void)trackRealTime:(ExploreOrderedData*)orderData extraData:(NSDictionary *)extraData
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:orderData.adIDStr forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:orderData.logExtra forKey:@"log_extra"];
    [params setValue:@"2" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [TTTracker eventV3:@"realtime_click" params:params];
}

- (void)sendTrackEvent:(NSString *)event label:(NSString *)label{
    [[SSADEventTracker sharedManager] sendADWithOrderedData:(ExploreOrderedData *)self.data event:event label:label extra:nil];
}

- (void)sendTrackEvent:(NSString *)event label:(NSString *)label extra:(NSDictionary *)extra{
    [[SSADEventTracker sharedManager] sendADWithOrderedData:(ExploreOrderedData *)self.data event:event label:label extra:extra];
}

- (void)onLogoImageViewTapped
{
    [self.playerStateStore sendAction:TTVPlayerEventTypeAdDetailAction payload:nil];
    
    void(^event_click)(void) = ^(void) {
        [self sendTrackEvent:@"video_end_ad" label:@"click"];
        TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[self.actionBtn.actionModel.adID stringValue] logExtra:self.actionBtn.actionModel.log_extra];
        if (!SSIsEmptyArray(self.actionBtn.actionModel.adClickTrackURLs)) {
            ttTrackURLsModel(self.actionBtn.actionModel.adClickTrackURLs, trackModel);
        }
    };
    
    dispatch_block_t dismissBlock = ^ {
        if (!self.playerStateStore.state.isInDetail) {
            event_click();
        }
        id<TTAdFeedModel> adModel = self.actionBtn.adModel;
        if (!isEmptyString(self.openURL)) {
            [self sendTrackEvent:@"video_end_ad" label:@"click_card"];
            [self sendTrackEvent:@"video_end_ad" label:@"detail_show"];
            UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor:self];
            ssOpenWebView([TTStringHelper URLWithURLString:self.openURL], nil, topController, NO, nil);
        } else {
            if (adModel.adType == ExploreActionTypeWeb) {
                [self sendTrackEvent:@"video_end_ad" label:@"click_card"];
            } else {
                [self sendTrackEvent:@"video_end_ad" label:@"click_card"];
                [self sendTrackEvent:@"video_end_ad" label:@"detail_show"];
            }
            if (!isEmptyString(self.webURL)) {
                UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor:self];
                ssOpenWebView([TTStringHelper URLWithURLString:self.webURL], nil, topController, NO, nil);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTVDismissSKStoreProductViewController" object:nil];
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

- (UIView *)onGetActionBtn
{
    return self.actionBtn;
}

@end


