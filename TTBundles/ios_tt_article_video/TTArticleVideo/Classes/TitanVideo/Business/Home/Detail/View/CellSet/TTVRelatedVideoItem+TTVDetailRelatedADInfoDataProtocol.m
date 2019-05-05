//
//  TTVRelatedVideoItem+TTVDetailRelatedADInfoDataProtocol.m
//  Article
//
//  Created by pei yun on 2017/6/4.
//
//

#import "TTVRelatedVideoItem+TTVDetailRelatedADInfoDataProtocol.h"
#import <TTVideoService/Common.pbobjc.h>
#import "TTImageInfosModel+Extention.h"
#import "TTAdVideoRelateAdModel.h"
#import "NSArray+BlocksKit.h"

@implementation TTVRelatedVideoItem (TTVDetailRelatedADInfoDataProtocol)

- (NSString *)card_type
{
    return self.ad.cardType;
}

- (NSString *)show_tag
{
    return self.ad.showTag;
}

- (NSString *)source
{
    return self.article.source;
}

- (NSString *)title
{
    return self.article.title;
}

- (NSString *)creative_type
{
    return self.ad.creativeType;
}

- (TTImageInfosModel *)middleImageInfosModel
{
    return [[TTImageInfosModel alloc] initWithImageUrlList:self.article.middleImageList];
}

- (NSString *)button_text
{
    return self.ad.buttonText;
}

- (NSString *)ad_id
{
    return self.ad.adId;
}

- (NSString *)uniqueIDStr
{
    if (self.article.groupId > 0) {
        return [NSString stringWithFormat:@"%lld", self.article.groupId];
    }
    return self.ad.adId;
}

- (int32_t)ui_type
{
    return self.ad.uiType;
}

- (TTAdVideoRelateAdModel *)adModel
{
    TTAdVideoRelateAdModel *adModel = [[TTAdVideoRelateAdModel alloc] init];
    adModel.card_type = self.card_type;
    adModel.ad_id = self.ad.adId;
    adModel.show_tag = self.show_tag;
    adModel.source = self.source;
    adModel.log_extra = self.ad.logExtra;
    adModel.web_url = self.ad.webURL;
    adModel.title = self.title;
    adModel.image_url = self.ad.imageURL;
    adModel.track_url_list = self.ad.trackURL.trackURLListArray;
    adModel.click_track_url_list = self.ad.trackURL.clickTrackURLListArray;
    adModel.adPlayTrackUrls = self.ad.videoTrackURL.playTrackURLListArray;
    adModel.adPlayActiveTrackUrls = self.ad.videoTrackURL.activePlayTrackURLListArray;
    adModel.adPlayEffectiveTrackUrls = self.ad.videoTrackURL.effectivePlayTrackURLListArray;
    adModel.adPlayOverTrackUrls = self.ad.videoTrackURL.playoverTrackURLListArray;
    
    TTAdVideoRelateAdImageUrlModel *imageModel = [[TTAdVideoRelateAdImageUrlModel alloc] init];
    imageModel.url = self.ad.middleImage.URL;
    imageModel.width = @(self.ad.middleImage.width);
    imageModel.url_list = (NSArray<Optional, TTAdVideoRelateAdUrlModel>* )[self.ad.middleImage.URLListArray bk_map:^id(TTVAUrl *obj) {
        TTAdVideoRelateAdUrlModel *model = [[TTAdVideoRelateAdUrlModel alloc] init];
        model.url = obj.URL;
        return model;
    }];
    imageModel.uri = self.ad.middleImage.uri;
    imageModel.height = @(self.ad.middleImage.height);
    adModel.middle_image = imageModel;
    adModel.type = self.ad.type;
    adModel.is_preview = @(self.ad.isPreview);
    adModel.creative_type = self.creative_type;
    adModel.button_text = self.button_text;
    adModel.phone_number = self.ad.phoneNumber;
    adModel.download_url = self.ad.downloadURL;
    adModel.apple_id = self.ad.appleId;
    adModel.open_url = self.ad.openURL;
    adModel.ipa_url = self.ad.ipaURL;
    adModel.dial_action_type = @(self.ad.dialActionType);
    adModel.form_url = self.ad.formURL;
    adModel.form_width = @(self.ad.formWidth);
    adModel.form_height = @(self.ad.formHeight);
    adModel.use_size_validation = @(self.ad.useSizeValidation);
    
    return adModel;
}

@end
