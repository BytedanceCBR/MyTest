//
//  ExploreOrderedADModel+TTVADSupport.m
//  Article
//
//  Created by pei yun on 2017/7/5.
//
//

#import "ExploreOrderedADModel+TTVADSupport.h"
#import <TTImage/TTImageInfosModel.h>
#import "TTImageInfosModel+Extention.h"
#import "ExploreOrderedADModel+TTVSupport.h"
#import "TTVADCell+ADInfo.h"

@implementation ExploreOrderedADModel (TTVADSupport)

+ (ExploreOrderedADModel *_Nullable)adModelWithTTVADInfo:(TTVADCell *_Nullable)adCell article:(TTVVideoArticle *)article
{
    if (adCell) {
        TTVADCellApp *app = adCell.app;
        TTVADCellPhone *phone = adCell.phone;
        TTVADCellForm *form = adCell.form;
        TTVADCellWeb *web = adCell.web;
        TTVADInfo *adInfo = [adCell adInfo];
        ExploreOrderedADModel *adModel = [[ExploreOrderedADModel alloc] init];
        adModel.ad_id = article.adId;
        adModel.log_extra = article.logExtra;
        if (adInfo.trackURL.trackURLListArray_Count > 0) {
            adModel.track_url_list = [NSArray arrayWithArray:adInfo.trackURL.trackURLListArray];
        }
        if (adInfo.trackURL.clickTrackURLListArray_Count > 0) {
            adModel.click_track_url_list = [NSArray arrayWithArray:adInfo.trackURL.clickTrackURLListArray];
        }
        if (adInfo.videoTrackURL.playTrackURLListArray_Count > 0) {
            adModel.playTrackUrls = adInfo.videoTrackURL.playTrackURLListArray;
        }
        if (adInfo.videoTrackURL.playoverTrackURLListArray_Count > 0) {
            adModel.playOverTrackUrls = adInfo.videoTrackURL.playoverTrackURLListArray;
        }
        if (adInfo.videoTrackURL.activePlayTrackURLListArray_Count > 0) {
            adModel.activePlayTrackUrls = adInfo.videoTrackURL.activePlayTrackURLListArray;
        }
        if (adInfo.videoTrackURL.effectivePlayTrackURLListArray_Count > 0) {
            adModel.effectivePlayTrackUrls = adInfo.videoTrackURL.effectivePlayTrackURLListArray;
        }
        adModel.effectivePlayTime = adInfo.videoTrackURL.effectivePlayTime;
        adModel.imageModel = [[TTImageInfosModel alloc] initWithImageUrlList:article.middleImageList];
        adModel.type = adInfo.type;
        adModel.displayType = adInfo.displayType;
        adModel.button_text = adInfo.buttonText;
        adModel.log_extra = article.logExtra;
        adModel.ui_type = @(adInfo.uiType);
        if ([adInfo.type isEqualToString:@"web"]) {
            adModel.webURL = web.base.webURL;
            adModel.webTitle = web.webTitle;
        }
        else if ([adInfo.type isEqualToString:@"action"]) {
            adModel.phoneNumber = phone.phoneNumber;
            adModel.dialActionType = @(phone.actionType);
            adModel.webURL = phone.base.webURL;
        }
        else if ([adInfo.type isEqualToString:@"form"]) {
            adModel.form_url = form.formURL;
            adModel.form_width = @(form.formWidth);
            adModel.form_height = @(form.formHeight);
            adModel.use_size_validation = @(form.useSizeValidation);
            adModel.webURL = form.base.webURL;
        }
        else if ([adInfo.type isEqualToString:@"app"]) {
            adModel.open_url = app.openURL;
            adModel.appName = app.appName;
            adModel.download_url = app.downloadURL;
            adModel.displayInfo = app.displayInfo;
            adModel.ipa_url = app.ipaURL;
            adModel.source = app.appName;
            adModel.apple_id = app.appleid;
            adModel.hideIfExists = @(app.hideIfExists);
            adModel.webURL = app.base.webURL;
        }
        return adModel;
    }
    return nil;
}

@end
