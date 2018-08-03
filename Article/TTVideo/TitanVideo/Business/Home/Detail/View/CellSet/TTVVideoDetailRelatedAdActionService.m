//
//  TTVVideoDetailRelatedAdActionService.m
//  Article
//
//  Created by pei yun on 2017/6/4.
//
//

#import "TTVVideoDetailRelatedAdActionService.h"
#import "TTAdAppDownloadManager.h"
#import "TTAdVideoRelateAdModel.h"
#import "TTTrackerProxy.h"
#import "TTAdManager.h"
#import "TTAdTrackManager.h"
#import "TTAdVideoManager.h"
#import "TTURLTracker.h"
#import "TTAppLinkManager.h"
#import "TTURLUtils.h"
#import "TTRoute.h"
#import "TTAdAppointAlertView.h"
#import "TTAdAction.h"

@implementation TTVVideoDetailRelatedAdActionService

- (void)trackRelateAdShow:(id<TTVDetailRelatedADInfoDataProtocol> )article uniqueIDStr:(NSString *)uniqueIDStr
{
    TTAdVideoRelateAdModel *adModel = article.adModel;
    [self trackRelateAdWithTag:@"detail_ad_list" label:@"show" uniqueID:uniqueIDStr adModel:adModel];
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra];
    ttTrackURLsModel(adModel.track_url_list, trackModel);
}

- (void)video_relateHandleAction:(id<TTVDetailRelatedADInfoDataProtocol> )article uniqueIDStr:(NSString *)uniqueIDStr
{
    TTAdVideoRelateAdModel *adModel = article.adModel;
    if ([adModel.creative_type isEqualToString:@"app"]) {
        BOOL canOpen = [TTAdAppDownloadManager downloadApp:adModel];
        [[self class] trackRealTimeAdModel:adModel];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" uniqueID:uniqueIDStr extra:@{@"has_v3": @"1"} adModel:adModel];
        if (canOpen) {
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"open" uniqueID:uniqueIDStr adModel:adModel];
        } else {
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"click_start" uniqueID:uniqueIDStr adModel:adModel];
        }
    }
    else if ([adModel.creative_type isEqualToString:@"action"]){
        [self handleAction:adModel];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" uniqueID:uniqueIDStr adModel:adModel];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click_call" uniqueID:uniqueIDStr adModel:adModel];
    }
    else if ([adModel.creative_type isEqualToString:@"form"]){
        [self handleForm:adModel];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" uniqueID:uniqueIDStr adModel:adModel];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click_button" uniqueID:uniqueIDStr adModel:adModel];
    }
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra];
    ttTrackURLsModel(adModel.click_track_url_list, trackModel);
    [self videoTrack];
}

- (void)videoAdCell_didSelect:(id<TTVDetailRelatedADInfoDataProtocol> )article uniqueIDStr:(NSString *)uniqueIDStr
{
    TTAdVideoRelateAdModel *adModel = article.adModel;
    if ([adModel.type isEqualToString:@"app"]) {
        BOOL canOpen = [TTAdAppDownloadManager downloadApp:adModel];
        [[self class] trackRealTimeAdModel:adModel];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" uniqueID:uniqueIDStr extra:@{@"has_v3": @"1"} adModel:adModel];
        if (canOpen) {
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"open" uniqueID:uniqueIDStr adModel:adModel];
        }
    }
    else if ([adModel.type isEqualToString:@"action"])
    {
        [self handleAction:adModel];
        [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" uniqueID:uniqueIDStr adModel:adModel];
    } else if ([adModel.type isEqualToString:@"web"]) {
        [self handleWeb:adModel];
        [self trackRelateAdClick:adModel uniqueIDStr:uniqueIDStr];
    }
    [self videoTrack];
}

-(void)trackRelateAdWithTag:(NSString*)tag
                      label:(NSString*)label
                   uniqueID:(NSString *)uniqueIDStr
                    adModel:(TTAdVideoRelateAdModel*)adModel
{
    if (!isEmptyString(adModel.ad_id)) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:adModel.log_extra forKey:@"log_extra"];
        [dict setValue:uniqueIDStr forKey:@"ext_value"];
        [dict setValue:@([[TTTrackerProxy sharedProxy]  connectionType]) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [TTAdTrackManager trackWithTag:tag label:label value:adModel.ad_id extraDic:dict];
    }
}

-(void)trackRelateAdWithTag:(NSString*)tag
                      label:(NSString*)label
                   uniqueID:(NSString *)uniqueIDStr
                      extra:(NSDictionary *)extra
                    adModel:(TTAdVideoRelateAdModel*)adModel
{
    if (!isEmptyString(adModel.ad_id)) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:adModel.log_extra forKey:@"log_extra"];
        [dict setValue:uniqueIDStr forKey:@"ext_value"];
        [dict setValue:@([[TTTrackerProxy sharedProxy]  connectionType]) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [dict addEntriesFromDictionary:extra];
        [TTAdTrackManager trackWithTag:tag label:label value:adModel.ad_id extraDic:dict];
    }
}

- (void)trackRelateAdClick:(TTAdVideoRelateAdModel *)adModel uniqueIDStr:(NSString *)uniqueIDStr
{
    [self trackRelateAdWithTag:@"detail_ad_list" label:@"click" uniqueID:uniqueIDStr adModel:adModel];
    TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra];
    ttTrackURLsModel(adModel.click_track_url_list, trackModel);
}

+ (void)trackRealTimeAdModel:(TTAdVideoRelateAdModel*)adModel
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:adModel.ad_id forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:adModel.log_extra forKey:@"log_extra"];
    [params setValue:@"1" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [TTTracker eventV3:@"realtime_click" params:params];
}

+ (void)trackRealTimeAd:(TTVRelatedVideoAD*)ad
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:ad.adId forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:ad.logExtra forKey:@"log_extra"];
    [params setValue:@"1" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [TTTracker eventV3:@"realtime_click" params:params];
}

- (void)handleForm:(TTAdVideoRelateAdModel *)adModel
{
    TTAdAppointAlertModel* model = [[TTAdAppointAlertModel alloc] initWithAdId:adModel.ad_id logExtra:adModel.log_extra formUrl:adModel.form_url width:adModel.form_width height:adModel.form_height sizeValid:adModel.use_size_validation];
    
    [TTAdAction handleFormActionModel:model fromSource:TTAdApointFromSourceFeed completeBlock:^(TTAdApointCompleteType type) {
        if (type == TTAdApointCompleteTypeCloseForm) {
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"click_cancel" uniqueID:adModel.ad_id adModel:adModel];
        }
        else if (type == TTAdApointCompleteTypeLoadFail){
            [self trackRelateAdWithTag:@"detail_ad_list" label:@"load_fail" uniqueID:adModel.ad_id adModel:adModel];
        }
    }];
}

- (void)handleAction:(TTAdVideoRelateAdModel*)adModel
{
    NSString *phoneNumber = adModel.phone_number;
    if (phoneNumber.length > 0) {
        
        NSURL *URL = [TTStringHelper URLWithURLString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
        if ([TTDeviceHelper OSVersionNumber] < 8) {
            [self listenCall:adModel];
            UIWebView * callWebview = [[UIWebView alloc] init];
            [callWebview loadRequest:[NSURLRequest requestWithURL:URL]];
            [[UIApplication sharedApplication].keyWindow addSubview:callWebview];
            // 这里delay1s之后把callWebView干掉，不能直接干掉，否则不能打电话。
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [callWebview removeFromSuperview];
            });
            return;
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [self listenCall:adModel];
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
}

- (void)listenCall:(TTAdVideoRelateAdModel*)adModel
{
    TTAdCallListenModel* callModel = [[TTAdCallListenModel alloc] init];
    callModel.ad_id = adModel.ad_id;
    callModel.log_extra = adModel.log_extra;
    callModel.position = @"detail_ad_list";
    callModel.dailTime = [NSDate date];
    callModel.dailActionType = adModel.dial_action_type;
    [TTAdManageInstance call_callAdModel:callModel];
}

- (void)handleWeb:(TTAdVideoRelateAdModel*)adModel
{
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionaryWithCapacity:3];
    [extraDic setValue:adModel.log_extra forKey:@"log_extra"];
    BOOL canOpen = [TTAppLinkManager dealWithWebURL:adModel.web_url openURL:adModel.open_url sourceTag:@"detail_ad_list" value:adModel.ad_id extraDic:extraDic];
    
    if (!canOpen) {
        NSURL *openURL = [TTURLUtils URLWithString:adModel.open_url];
        canOpen = [[TTRoute sharedRoute] canOpenURL:openURL];
        if (canOpen) {
            [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:TTRouteUserInfoWithDict(extraDic)];
        }
    }
    
    //点击广告图片跳转到广告详情页
    if (!canOpen && !isEmptyString(adModel.web_url)) {
        [extraDic setValue: adModel.web_url forKey:@"url"];
        [extraDic setValue:adModel.ad_id forKey:@"ad_id"];
        NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:extraDic];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(@{@"supportRotate":@1})];
    }
}

- (void)videoTrack
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kTTAdVideoManagerDidRelateAdClick" object:nil];
    });
}

@end
