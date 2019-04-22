//
//  SSADActionManager.m
//  Article
//
//  Created by Zhang Leonardo on 14-2-10.
//
//


#import "SSADActionManager.h"

#import "Article+TTADComputedProperties.h"
#import "Article.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "NSString-Extension.h"
#import "PBModelHeader.h"
#import "SSADBaseModel.h"
#import "SSADEventTracker.h"
#import "SSWebViewController.h"
#import "TTAdAction.h"
#import "TTAdAppDownloadManager.h"
#import "TTAdConstant.h"
#import "TTAdManager.h"
#import "TTAdManagerProtocol.h"
#import "TTAdMonitorManager.h"
#import "TTAppLinkManager.h"
#import "TTStringHelper.h"
#import "TTUIResponderHelper.h"
#import "TTVADCellApp+ComputedProperties.h"
#import "TTVFeedItem+Extension.h"
#import <TTBaseLib/TTStringHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTRoute/TTRoute.h>
#import <TTServiceKit/TTServiceCenter.h>
#import <TTUIWidget/TTThemedAlertController.h>
#import "TTAdAction.h"
#import "TTADEventTrackerEntity.h"


#define kSeperatorString        @"://"

@implementation TTVOpenAppParameter

+ (TTVOpenAppParameter *)parameterWithFeedItem:(TTVFeedItem *)item
{
    TTVADCellApp *app = item.adCell.app;
    TTVVideoArticle *article = item.article;
    TTVOpenAppParameter *parameter = [[TTVOpenAppParameter alloc] init];
    parameter.openURL = app.openURL;
    parameter.appURL = app.appURL;
    parameter.tabURL = app.tabURL;
    parameter.adID = article.adId;
    parameter.logExtra = article.logExtra;
    parameter.ipaURL = app.ipaURL;
    parameter.source = article.source;
    parameter.displayInfo = app.displayInfo;
    parameter.downloadURL = app.downloadURL;
    parameter.appleid = app.appleid;
    parameter.trackerEntity = [TTADEventTrackerEntity entityWithData:item];
    return parameter;
}

- (BOOL)isInstalledApp
{
    return [[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:self.openURL]] || [TTRoute conformsToRouteWithScheme:self.appURL];
}

- (NSString *)openURL {
    NSString *openURL = _openURL;
    if (!isEmptyString(openURL) && [self.adID longLongValue] > 0 && self.logExtra != nil) {
        openURL = [openURL tt_adChangeUrlWithLogExtra:self.logExtra];
    }
    return openURL;
}

- (NSString *)appURL {
    if (!isEmptyString(_appURL)) {
        return _appURL;
    }
    NSRange seperateRange = [self.openURL rangeOfString:kSeperatorString];
    if (seperateRange.length > 0) {
        _appURL = [self.openURL substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];

        _tabURL = [self.openURL substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [self.openURL length] - NSMaxRange(seperateRange))];
    } else {
        _appURL = self.openURL;
    }
    return _appURL;
}

- (NSString *)tabURL {
    if (!isEmptyString(_tabURL)) {
        return _tabURL;
    }

    NSRange seperateRange = [self.openURL rangeOfString:kSeperatorString];
    if (seperateRange.length > 0) {
        _appURL = [self.openURL substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];

        _tabURL = [self.openURL substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [self.openURL length] - NSMaxRange(seperateRange))];
    } else {
        _appURL = self.openURL;
    }
    return _tabURL;
}

@end

@implementation SSADActionManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static SSADActionManager *_sharedManager = nil;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

#pragma mark - embed ad actions

//下载
- (void)handleAppAdModel:(id<TTAd, TTAdAppAction>)adModel orderedData:(ExploreOrderedData *)orderedData needAlert:(BOOL)needAlert {
    
    TTAdAppModel *appModel  = [[TTAdAppModel alloc] init];
    appModel.ad_id = adModel.ad_id;
    appModel.log_extra = adModel.log_extra;
    appModel.apple_id = adModel.apple_id;
    appModel.download_url = adModel.download_url;
    appModel.ipa_url = adModel.ipa_url;
    appModel.open_url = adModel.open_url;
    
    BOOL canOpenApp = NO;
    canOpenApp = [TTAdAppDownloadManager downloadApp:appModel];
    
    if (canOpenApp) {
        [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"open" eventName:@"embeded_ad" clickTrackUrl:NO];
    }
}

- (void)handlePhotoAlbumAppActionForADModel:(TTPhotoDetailAdModel *)photoDetailAdModel {
    
    if (!photoDetailAdModel || !photoDetailAdModel.image_recom) {
        return;
    }
    
    TTPhotoDetailAdImageRecomModel *adModel = photoDetailAdModel.image_recom;
    TTAdAppModel *appModel  = [[TTAdAppModel alloc] init];
    appModel.ad_id = adModel.ID;
    appModel.log_extra = adModel.log_extra;
    appModel.apple_id = adModel.appleid;
    appModel.download_url = adModel.download_url;
    appModel.ipa_url = adModel.ipa_url;
    appModel.open_url = adModel.open_url;
    
    BOOL canOpenApp = NO;
    canOpenApp = [TTAdAppDownloadManager downloadApp:appModel];
    
    if (canOpenApp) {
        [TTAdManageInstance photoAlbum_trackDownloadClickToOpenApp];
    } else {
        [TTAdManageInstance photoAlbum_trackDownloadClickToAppstore];
    }
}

- (void)handlePhotoAlbumBackgroundWebModel:(TTPhotoDetailAdModel *)adModel WithResponder:(UIResponder*)responder{
    
    if (!adModel || !adModel.image_recom) {
        return;
    }
    
    if (isEmptyString(adModel.image_recom.web_url) && isEmptyString(adModel.image_recom.open_url)) {
        [TTAdManager monitor_trackService:@"ad_photoAlbum_newAd_webBackground_urlError" status:0 extra:adModel.image_recom.mointerInfo];
        return;
    }
    
    NSMutableDictionary *applinkTrackDic = [NSMutableDictionary dictionary];
    [applinkTrackDic setValue:adModel.image_recom.log_extra forKey:@"log_extra"];
    
    BOOL canOpenApp = canOpenApp = [TTAppLinkManager dealWithWebURL:adModel.image_recom.web_url openURL:adModel.image_recom.open_url sourceTag:@"detail_ad" value:adModel.image_recom.ID extraDic:applinkTrackDic];
    
    if (!canOpenApp && !isEmptyString(adModel.image_recom.open_url)) {
        
        NSURL *url = [NSURL URLWithString:adModel.image_recom.open_url];
        
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            NSMutableDictionary* paramDict = [NSMutableDictionary dictionary];
            [paramDict setValue:adModel.image_recom.log_extra forKey:@"log_extra"];

            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(paramDict)];
            
            canOpenApp = YES;
        }
    }
    
    if (!canOpenApp && !isEmptyString(adModel.image_recom.web_url)) {
        
        NSMutableString *webUrlString = [NSMutableString stringWithString:adModel.image_recom.web_url];
        SSWebViewController * controller = [[SSWebViewController alloc] initWithSupportIPhoneRotate:YES];
        controller.adID = adModel.image_recom.ID;
        controller.logExtra = adModel.image_recom.log_extra;
        [controller requestWithURL:[TTStringHelper URLWithURLString:webUrlString]];
        UIViewController *topController = [TTUIResponderHelper topViewControllerFor:responder];
        [topController.navigationController pushViewController:controller animated:YES];
        [controller setTitleText:adModel.image_recom.web_title];
        
        canOpenApp = YES;
    }
    
    if (!canOpenApp) {
        [TTAdManager monitor_trackService:@"ad_photoAlbum_webBackground_OpenError" status:0 extra:adModel.image_recom.mointerInfo];
    }
    
}

- (void)handlePhotoAlbumButtondWebModel:(TTPhotoDetailAdModel *)adModel WithResponder:(UIResponder*)responder{
    
    if (!adModel || !adModel.image_recom) {
        return;
    }
    
    if (!adModel.image_recom.web_url) {
        [TTAdManager monitor_trackService:@"ad_photoAlbum_webButton_urlAllError" status:0 extra:adModel.image_recom.mointerInfo];
    }
    
    NSMutableDictionary *applinkParams = [NSMutableDictionary dictionary];
    [applinkParams setValue:adModel.image_recom.log_extra forKey:@"log_extra"];
    
    NSMutableString *webUrlString = [NSMutableString stringWithString:adModel.image_recom.web_url];
    SSWebViewController * controller = [[SSWebViewController alloc] initWithSupportIPhoneRotate:YES];
    controller.adID = adModel.image_recom.ID;
    controller.logExtra = adModel.image_recom.log_extra;
    [controller requestWithURL:[TTStringHelper URLWithURLString:webUrlString]];
    UIViewController *topController = [TTUIResponderHelper topViewControllerFor:responder];
    [topController.navigationController pushViewController:controller animated:YES];
    [controller setTitleText:adModel.image_recom.web_title];
}

- (void)handlePhotoAlbumPhoneActionModel:(TTPhotoDetailAdModel *)adModel {
    
    if (!adModel || !adModel.image_recom) {
        return;
    }
    
    NSString *phoneNumber = adModel.image_recom.phone_number;
    if (!isEmptyString(phoneNumber)) {
        TTAdCallModel* callModel = [[TTAdCallModel alloc] initWithPhoneNumber:phoneNumber];
        [TTAdAction handleCallActionModel:callModel];
        [self photoAlbumlistenCall:adModel];
        
    } else {
        [TTAdMonitorManager trackService:@"ad_photoAlbum_actionButton_phone" status:0 extra:adModel.image_recom.mointerInfo];
    }
}

//监听电话状态
- (void)photoAlbumlistenCall:(TTPhotoDetailAdModel*)adModel
{
    if (!adModel || !adModel.image_recom) {
        return;
    }
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:adModel.image_recom.ID forKey:@"ad_id"];
    [dict setValue:adModel.image_recom.log_extra forKey:@"log_extra"];
    [dict setValue:[NSDate date] forKey:@"dailTime"];
    [dict setValue:adModel.image_recom.dial_action_type forKey:@"dailActionType"];
    [dict setValue:@"detail_call" forKey:@"position"];
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance call_callAdDict:dict];
}

- (void)handleAppActionForADBaseModel:(SSADBaseModel *)adModel forTrackEvent:(NSString *)event needAlert:(BOOL)needAlert {
    
    BOOL canOpenApp = NO;
    canOpenApp = [TTAdAppDownloadManager downloadApp:adModel];
    
    [adModel sendTrackEventWithLabel:@"click" eventName:event extra:@{@"has_v3": @"1"}];
    if (canOpenApp) {
        [adModel sendTrackEventWithLabel:@"open" eventName:event]; // click_start 和  open 同时存在
    }
}

- (void)openAppWithParameter:(TTVOpenAppParameter *)parameter
{
    NSString *openURL = parameter.openURL;
    NSString *adID = parameter.adID;
    NSString *logExtra = parameter.logExtra;
    NSString *ipaURL = parameter.ipaURL;
    NSString *downloadURL = parameter.downloadURL;
    NSString *appleid = parameter.appleid;


    TTAdAppModel *appModel  = [[TTAdAppModel alloc] init];
    appModel.ad_id = adID;
    appModel.log_extra = logExtra;
    appModel.apple_id = appleid;
    appModel.download_url = downloadURL;
    appModel.ipa_url = ipaURL;
    appModel.open_url = openURL;
    
    BOOL canOpenApp = NO;
    canOpenApp = [TTAdAppDownloadManager downloadApp:appModel];
    
    if (canOpenApp) {
        [[SSADEventTracker sharedManager] trackEventWithEntity:parameter.trackerEntity label:@"open" eventName:@"embeded_ad" extra:nil clickTrackUrl:NO];
    }
}

@end
