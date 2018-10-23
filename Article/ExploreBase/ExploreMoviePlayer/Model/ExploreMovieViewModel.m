//
//  ExploreMovieViewModel.m
//  Article
//
//  Created by panxiang on 2017/2/17.
//
//

#import "ExploreMovieViewModel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOrderedData+TTAd.h"

#import "TTModuleBridge.h"
#import "TTVArticleProtocol.h"
#import "Article.h"

#import "TTAdVideoRelateAdModel.h"
#import "TTAdFeedModel.h"


@implementation ExploreMovieViewModel

+ (void)load
{
    [[TTModuleBridge sharedInstance_tt] registerAction:@"NewMovieViewModel" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        ExploreMovieViewModel *movieViewModel = [[ExploreMovieViewModel alloc] init];
        movieViewModel.type                   = (ExploreMovieViewType)[params tt_integerValueForKey:@"type"];
        movieViewModel.gModel                 = [[TTGroupModel alloc] initWithGroupID:[params tt_stringValueForKey:@"groupID"]];
        movieViewModel.aID                    = [params tt_stringValueForKey:@"aID"];
        movieViewModel.clickTrackURLs         = [params tt_arrayValueForKey:@"clickTrackURLs"];
        movieViewModel.cID                    = [params tt_stringValueForKey:@"categoryID"];
        movieViewModel.logExtra               = [params tt_stringValueForKey:@"logExtra"];
        movieViewModel.gdLabel                = [params tt_stringValueForKey:@"gdLabel"];
        movieViewModel.videoPlayType          = (TTVideoPlayType)[params tt_integerValueForKey:@"videoPlayType"];
        return movieViewModel;
    }];
}

+ (nullable ExploreMovieViewModel *)viewModelWithOrderData:(nullable ExploreOrderedData *)orderedData
{
    ExploreMovieViewModel *model = [[ExploreMovieViewModel alloc] init];
    if (orderedData) {
        model.gModel                 = orderedData.article.groupModel;
        model.aID                    = orderedData.adModel.ad_id;
        model.cID                    = orderedData.categoryID;
        model.logExtra               = orderedData.adModel.log_extra;
        model.clickTrackURLs         = orderedData.adModel.click_track_url_list;
        if (!model.clickTrackURLs) {
            model.clickTrackURLs         = orderedData.adVideoClickTrackURLs;
        }
        model.playOverTrackUrls      = orderedData.adPlayOverTrackUrls;
        model.effectivePlayTrackUrls     = orderedData.adPlayEffectiveTrackUrls;
        model.activePlayTrackUrls    = orderedData.adPlayActiveTrackUrls;
        model.playTrackUrls          = orderedData.adPlayTrackUrls;
        model.effectivePlayTime          = orderedData.effectivePlayTime;
        model.trackSDK               = orderedData.trackSDK;
        if (orderedData.raw_ad.track_sdk > 0) {
            model.trackSDK = orderedData.raw_ad.track_sdk;
        }
        model.videoThirdMonitorUrl    = [orderedData.article videoThirdMonitorUrl];
    }
    return model;
}

+ (nullable ExploreMovieViewModel *)viewModelWithArticleVideoAdExtra:(nullable id<TTVArticleProtocol> )article
{
    if (article.videoAdExtra) {
        ExploreMovieViewModel *model = [[ExploreMovieViewModel alloc] init];
        model.gModel                 = article.groupModel;
        NSString * aID = [article.videoAdExtra.ad_id longLongValue] > 0 ? [NSString stringWithFormat:@"%@", article.videoAdExtra.ad_id] : @"";
        model.aID                    = aID;
        model.logExtra               = article.videoAdExtra.log_extra;
        model.clickTrackURLs         = article.videoAdExtra.click_track_url_list;
        model.playOverTrackUrls      = article.videoAdExtra.adPlayOverTrackUrls;
        model.effectivePlayTrackUrls     = article.videoAdExtra.adPlayEffectiveTrackUrls;
        model.activePlayTrackUrls    = article.videoAdExtra.adPlayActiveTrackUrls;
        model.playTrackUrls          = article.videoAdExtra.adPlayTrackUrls;
        model.effectivePlayTime          = article.videoAdExtra.effectivePlayTime;
        return model;
    }
    return nil;
}
@end
