//
//  ExploreMovieViewModel+ConvertFromTTVFeedItem.m
//  Article
//
//  Created by pei yun on 2017/4/3.
//
//

#import "ExploreMovieViewModel+ConvertFromTTVFeedItem.h"
#import <TTVideoService/VideoFeed.pbobjc.h>
#import <TTVideoService/Common.pbobjc.h>
#import "TTVADCell+ADInfo.h"

@implementation ExploreMovieViewModel (ConvertFromTTVFeedItem)

+ (nullable ExploreMovieViewModel *)viewModelWithVideoFeed:(nullable TTVFeedItem *)orderedData categoryID:(NSString *_Nullable)categoryID {
    if (orderedData) {
        ExploreMovieViewModel *model = [[ExploreMovieViewModel alloc] init];
        TTVVideoArticle *article = orderedData.videoCell.article;
        TTVADInfo *adInfo = [orderedData.adCell adInfo];
        TTGroupModel *gModel = [[TTGroupModel alloc] initWithGroupID:[NSString stringWithFormat:@"%lld", article.groupId] itemID:[NSString stringWithFormat:@"%lld", article.itemId] impressionID:nil aggrType:article.aggrType];
        model.gModel = gModel;
        model.aID = article.adId;
        model.cID = categoryID;
        model.logExtra = article.logExtra;
        model.clickTrackURLs = adInfo.trackURL.clickTrackURLListArray;
        if (!model.clickTrackURLs) {
            model.clickTrackURLs = adInfo.trackURL.trackURLListArray;
        }
        TTVVideoTrackUrlList *videoTrackURL = adInfo.videoTrackURL;
        model.playOverTrackUrls = videoTrackURL.playoverTrackURLListArray;
        model.effectivePlayTrackUrls = videoTrackURL.effectivePlayTrackURLListArray;
        model.activePlayTrackUrls = videoTrackURL.activePlayTrackURLListArray;
        model.playTrackUrls = videoTrackURL.playTrackURLListArray;
        model.effectivePlayTime = videoTrackURL.effectivePlayTime;
        model.videoThirdMonitorUrl = article.videoDetailInfo.videoThirdMonitorURL;
        
        return model;
    }
    return nil;
}

@end
