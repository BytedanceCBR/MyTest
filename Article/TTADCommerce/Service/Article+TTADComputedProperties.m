//
//  Article+TTADComputedProperties.m
//  Article
//
//  Created by pei yun on 2017/9/19.
//
//

#import "Article+TTADComputedProperties.h"

#import <objc/runtime.h>
#import "JSONAdditions.h"
#import "SSCommonLogic.h"

@implementation Article (TTADComputedProperties)

- (id<TTAdFeedModel>)adModel {
    if ([SSCommonLogic isRawAdDataEnable]) {
        return self.rawAd;
    }
    if (self.exploreAdModel != nil) {
        return self.exploreAdModel;
    }
    return self.rawAd;
}

// used for setValue:forKey:
- (void)setAdModel:(id<TTAdFeedModel>  _Nullable)adModel {
    if ([SSCommonLogic isRawAdDataEnable]) {
        objc_setAssociatedObject(self, @selector(rawAd), adModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    objc_setAssociatedObject(self, @selector(exploreAdModel), adModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTAdFeedModel *)rawAd {
    if (SSIsEmptyDictionary(self.raw_ad_data)) {
        return nil;
    }
    TTAdFeedModel *rawAd = objc_getAssociatedObject(self, @selector(rawAd));
    if (rawAd) {
        return rawAd;
    }
    NSError *jsonError;
    rawAd = [[TTAdFeedModel alloc] initWithDictionary:self.raw_ad_data error:&jsonError];
    self.rawAd = rawAd;
    return rawAd;
}

- (void)setRawAd:(TTAdFeedModel * _Nullable)rawAd {
    objc_setAssociatedObject(self, @selector(rawAd), rawAd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ExploreOrderedADModel *)exploreAdModel {
    if (isEmptyString(self.adPromoter) && SSIsEmptyDictionary(self.embededAdInfo)) {
        return nil;
    }
    ExploreOrderedADModel *associatedADModel = objc_getAssociatedObject(self, @selector(exploreAdModel));
    if (associatedADModel) {
        return associatedADModel;
    }
    NSError *error = nil;
    NSDictionary *dict = [NSString tt_objectWithJSONString:self.adPromoter error:&error];
    if (!SSIsEmptyDictionary(dict)) {
        ExploreOrderedADModel *exploreAdModel = [[ExploreOrderedADModel alloc] initWithDictionary:dict];
        
        //5.5信息流组图创意通投广告，需要将article中的image_list传入ad_data中
        //adModel.listGroupImgDicts = self.listGroupImgDicts;
        
        //5.7.5 如果ad_data中缺少ad_id或logExtra，需要将orderedData中的对应数据传入ad_data中
        [self fixAdModel:exploreAdModel];
        
        associatedADModel = exploreAdModel;
        self.exploreAdModel = associatedADModel;
    } else if (!SSIsEmptyDictionary(self.embededAdInfo)) {
        dict = self.embededAdInfo;
        ExploreOrderedADModel *exploreAdModel = [[ExploreOrderedADModel alloc] initWithDictionary:dict];
        [self fixAdModel:exploreAdModel];
        associatedADModel = exploreAdModel;
        self.exploreAdModel = associatedADModel;
    }
    return associatedADModel;
}

- (void)setExploreAdModel:(ExploreOrderedADModel * _Nullable)exploreAdModel
{
    objc_setAssociatedObject(self, @selector(exploreAdModel), exploreAdModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)fixAdModel:(ExploreOrderedADModel *)exploreAdModel {
    // 如果ad_data中缺少ad_id或logExtra，需要将article中的对应数据传入ad_data中
    if (isEmptyString(exploreAdModel.ad_id)) {
        exploreAdModel.ad_id = self.adIDStr;
    }
    
    if (isEmptyString(exploreAdModel.log_extra)) {
        exploreAdModel.log_extra = self.logExtra;
    }
}

- (void)clearCachedModels {
    self.exploreAdModel = nil;
}

- (BOOL)isAd {
    return [self.adModel.ad_id longLongValue] > 0;
}

@end
