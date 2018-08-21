//
//  ExploreOrderedData+TTAd.m
//  Article
//
//  Created by carl on 2017/10/18.
//

#import "ExploreOrderedData+TTAd.h"

#import "Article+TTADComputedProperties.h"
#import "Article.h"
#import "SSCommonLogic.h"
#import "TTVPlayerUrlTracker.h"
#import "TTADTrackEventLinkModel.h"
#import "ExploreOrderedADModel.h"
#import "JSONAdditions.h"
#import "TTAdFeedModel.h"

@implementation ExploreOrderedData (TTAd)

- (TTAdFeedModel *)raw_ad {
    if (SSIsEmptyDictionary(self.raw_ad_data)) {
        return nil;
    }
    TTAdFeedModel *result = objc_getAssociatedObject(self, @selector(raw_ad));
    if (!result) {
        NSError *jsonError;
        result = [[TTAdFeedModel alloc] initWithDictionary:self.raw_ad_data error:&jsonError];
        self.raw_ad = result;
    }
    return result;
}

- (void)setRaw_ad:(TTAdFeedModel *)raw_ad {
    objc_setAssociatedObject(self, @selector(raw_ad), raw_ad, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable TTADTrackEventLinkModel *)adEventLinkModel{
    
    NSString *ad_id = nil;
    ad_id = self.adID != nil ? [NSString stringWithFormat:@"%@", self.adID] : nil;
    
    if (ad_id == nil) {
        return nil;
    }
    
    NSString *log_extra = self.log_extra;
    if (isEmptyString(log_extra)) {
        log_extra = self.raw_ad_data[@"log_extra"];
    }
    
    TTADTrackEventLinkModel *result = objc_getAssociatedObject(self, @selector(adEventLinkModel));
    if (result) {
        return result;
    }
    
    result = [[TTADTrackEventLinkModel alloc] init];
    
    result.adID = ad_id;
    result.logExtra = log_extra;
    self.adEventLinkModel = result;
    
    return result;
}

- (void)setAdEventLinkModel:(TTADTrackEventLinkModel *)adEventLinkModel {
    objc_setAssociatedObject(self, @selector(adEventLinkModel), adEventLinkModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *)ad_id {
    if ([self.raw_ad.ad_id longLongValue] > 0) {
        return self.raw_ad.ad_id;
    }
    if ([self.adID longLongValue] > 0) {
        return [self.adID stringValue];
    }
    return nil;
}

- (NSString *)log_extra {
    if (self.raw_ad.log_extra) {
        return self.raw_ad.log_extra;
    }
    return self.logExtra;
}

- (BOOL)isAdExpire {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval expireSeconds = 0;
    expireSeconds = MAX(self.adExpireInterval, self.raw_ad.expire_seconds);
    /// 根据adid是否过期来判断是否需要展示
    if (expireSeconds > 0 && self.ad_id != nil) {
        /// 如果广告已经过期了，就不管了
        if (timeInterval - self.requestTime > expireSeconds) {
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)adExtraData {
    NSMutableDictionary *extraData = [NSMutableDictionary dictionary];
    NSMutableDictionary *status = [NSMutableDictionary dictionary];
    if (self.comefrom == (ExploreOrderedDataFromOptionPullUp) ) {
        status[@"source"] = @2;
        status[@"first_in_cache"] = @(self.isFirstCached ? 1 : 0);
    } else if (self.comefrom == ExploreOrderedDataFromOptionPullDown) {
        status[@"source"] = @0;
        status[@"first_in_cache"] = @(1);
    } else {
        status[@"source"] = @1;
        status[@"first_in_cache"] = @0;
    }
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:status options:0 error:&error];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    extraData[@"ad_extra_data"] = json;
    return extraData;
}

- (NSDictionary *)realTimeAdExtraData:(NSString *)tag label:(NSString *)label extraData:(NSDictionary *)extraData
{
    NSMutableDictionary *events = [@{} mutableCopy];
    NSMutableDictionary *adExtraData = [NSMutableDictionary dictionary];
    NSDictionary *linkExtra = [self.adEventLinkModel adEventLinkDictionaryWithTag:tag WithLabel:label];
    [adExtraData addEntriesFromDictionary:linkExtra];
    
    NSString *extraString = [extraData objectForKey:@"ad_extra_data"];
    if (!isEmptyString(extraString)) {
        NSError *error = nil;
        NSDictionary *extraJsonDic = [NSString tt_objectWithJSONString:extraString error:&error];
        [adExtraData addEntriesFromDictionary:extraJsonDic];
    }
    NSString *finalString = [adExtraData tt_JSONRepresentation];
    [events setValue:finalString forKey:@"ad_extra_data"];
    return events;
}

- (id<TTAdFeedModel>)exploreAdModel {
    if (![self.article respondsToSelector:@selector(exploreAdModel)]) {
        return self.article.adModel;
    }
    ExploreOrderedADModel *adModel = self.article.exploreAdModel;
    if (self.adTrackURLs && !adModel.track_url_list) {
        adModel.track_url_list = self.adTrackURLs;
    }
    if (self.adClickTrackURLs && !adModel.click_track_url_list) {
        adModel.click_track_url_list = self.adClickTrackURLs;
    }
    return adModel;
}

- (id<TTAdFeedModel>)adModel {
    if ([SSCommonLogic isRawAdDataEnable]) { // 严格模式， 默认严格模式
        return self.raw_ad;
    } else {
        return self.exploreAdModel;
    }
}

- (BOOL)isAdButtonUnderPic {
    if ([SSCommonLogic isRawAdDataEnable]) {
        return self.raw_ad.button_style;
    } else {
        return self.exploreAdModel != nil;
    }
}

- (BOOL)isAd {
    if ([self.adID longLongValue] > 0 || self.raw_ad.ad_id != nil) {
        return YES;
    }
    return NO;
}

- (TTVPlayerUrlTracker *)videoPlayTracker {
    TTVPlayerUrlTracker *urlTracker = [[TTVPlayerUrlTracker alloc] init];
    if ([SSCommonLogic isRawAdDataEnable]) {
        urlTracker.effectivePlayTime = self.raw_ad.effectivePlayTime;
        urlTracker.clickTrackURLs = self.raw_ad.click_track_url_list;
        urlTracker.playTrackUrls = self.raw_ad.playOverTrackUrls;
        urlTracker.activePlayTrackUrls = self.raw_ad.activePlayTrackUrls;
        urlTracker.effectivePlayTrackUrls = self.raw_ad.effectivePlayTrackUrls;
        urlTracker.playOverTrackUrls = self.raw_ad.playOverTrackUrls;
    } else {
        urlTracker.effectivePlayTime = self.effectivePlayTime;
        urlTracker.clickTrackURLs = self.adClickTrackURLs;
        urlTracker.playTrackUrls = self.adPlayOverTrackUrls;
        urlTracker.activePlayTrackUrls = self.adPlayActiveTrackUrls;
        urlTracker.effectivePlayTrackUrls = self.adPlayEffectiveTrackUrls;
        urlTracker.playOverTrackUrls = self.adPlayOverTrackUrls;
    }

    return urlTracker;
}

@end
