//
//  TTADEventTrackerEntity.m
//  Article
//
//  Created by panxiang on 2017/7/20.
//
//

#import "TTADEventTrackerEntity.h"
#import "VideoFeed.pbobjc.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "Article+TTADComputedProperties.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+Extension.h"
#import "TTVADCellApp+ComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"

@implementation TTADEventTrackerEntity

+ (TTADEventTrackerEntity *)entityWithData:(id)data
{
    if ([data isKindOfClass:[TTVFeedItem class]]) {
        TTVFeedItem *item = data;
        TTADEventTrackerEntity *entity = [[TTADEventTrackerEntity alloc] init];
        entity.ad_id = item.adID;
        entity.itemID = item.itemID;
        entity.uniqueid = item.uniqueIDStr;
        entity.aggrType = item.aggrType;
        entity.log_extra = item.logExtra;
        entity.adClickTrackURLs = item.adInfo.trackURL.clickTrackURLListArray;
        entity.adTrackURLs = item.adInfo.trackURL.trackURLListArray;
        return entity;
    }if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = data;
        if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
            TTADEventTrackerEntity *entity = [[TTADEventTrackerEntity alloc] init];
            entity.ad_id = orderedData.ad_id;
            entity.adTrackURLs = orderedData.adTrackURLs;
            entity.adClickTrackURLs = orderedData.adClickTrackURLs;
            entity.uniqueid = orderedData.uniqueID;
            entity.aggrType = orderedData.article.aggrType;
            entity.itemID = orderedData.article.itemID;
            entity.log_extra = orderedData.log_extra;
            if (orderedData.adModel != nil) {
                id<TTAdFeedModel> adModel = orderedData.adModel;
                entity.adTrackURLs = adModel.track_url_list;
                entity.adClickTrackURLs = adModel.click_track_url_list;
                entity.log_extra = adModel.log_extra;
            }
            return entity;
        }
    }
    return nil;
}

+ (TTADEventTrackerEntity *)entityWithData:(id)data item:(TTVFeedListItem *)item
{
    TTADEventTrackerEntity *entity = [self entityWithData:data];
    entity.feedListItem = item;
    return entity;
}

@end
