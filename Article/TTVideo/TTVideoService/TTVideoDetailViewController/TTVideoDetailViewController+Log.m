//
//  TTVideoDetailViewController+Log.m
//  Article
//
//  Created by 刘廷勇 on 16/4/26.
//
//

#import "TTVideoDetailViewController+Log.h"
#import "TTDetailModel.h"
#import "Article.h"
#import "ExploreMovieView.h"
#import "NetworkUtilities.h"
#import "TTDetailModel.h"
//#import "SSURLTracker.h"
#import "TTURLTracker.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTVideoDetailPlayControl.h"
#import "TTTrackerProxy.h"

@implementation TTVideoDetailViewController (Log)

//进入页面
- (void)logEnter
{
}

//readPct事件
- (void)logReadPctTrack
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    if (self.detailModel.gdExtJsonDict) {
        [dict setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
    }
    
    [dict setValue:@"article" forKey:@"category"];
    [dict setValue:@"read_pct" forKey:@"tag"];
    [dict setValue:self.detailModel.clickLabel forKey:@"label"];
    [dict setValue:@(self.detailModel.article.uniqueID) forKey:@"value"];
    [dict setValue:self.detailModel.adID forKey:@"ext_value"];
    [dict setValue:[self detailReadPCT] forKey:@"pct"];
    [dict setValue:@(1) forKey:@"page_count"];
    if (!isEmptyString(self.detailModel.article.groupModel.itemID)) {
        [dict setValue:@(self.detailModel.article.groupModel.aggrType) forKey:@"aggr_type"];
        [dict setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
    }
    [TTTrackerWrapper eventData:dict];
}

//点击举报
- (void)logClickReport
{
}

//点击写评论按钮
- (void)logClickWriteComment
{
}

//发布评论
- (void)logConfirmComment
{
    //ExploreWriteCommentView发送
}

//点击看评论按钮
- (void)logClickComment:(VideoDetailViewShowStatus)status
{
}


//点击收藏
- (void)logFavorite
{
}

//点击取消收藏
- (void)logUnFavorite
{
}

//点击pgc
- (void)logClickPGC
{
    //在pgcView中统计
}

//点击订阅pgc
- (void)logSubscribe
{
    //在pgcView中统计
}

//点击取消订阅pgc
- (void)logUnSubscribe
{
    //在pgcView中统计
}

/*
 非视频统计
//?点击高亮词
//?点击标签词
//?点击相关阅读词
 */

//点击广告
- (void)logClickAd
{
    //TTAdDetailContainerView中统计
}

//文章点赞
//取消点赞
//以上两个在TTDetailNatantVideoInfoView中统计

//点击回复评论 在commentCell中统计
//点评论进详情页 在TTCommentViewController中统计
//评论点赞 在commentCell中统计
//评论取消点赞 在commentCell中统计
//评论点击头像 在commentCell中统计

/*
 非视频统计
//?点赞展示
//?标签词展示
//?相关阅读展示
 */

//?评论展示

- (void)sendADEvent:(NSString *)event label:(NSString *)label value:(NSString *)value extra:(NSDictionary *)extra logExtra:(NSString *)logExtra click:(BOOL)click
{
    const NSArray * clicks = @[@"ad_click",@"click",@"click_card",@"click_landingpage",@"click_call",@"click_start"];
    BOOL showThisLabel = [clicks containsObject:label] || ([label isEqualToString:@"detail_show"] && [event isEqualToString:@"detail_landingpage"]);
    if (click) {
        if (showThisLabel) {
            TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:self.orderedData.ad_id logExtra:self.orderedData.log_extra];
            
            if (!SSIsEmptyArray(self.orderedData.adModel.click_track_url_list)) {
                ttTrackURLsModel(self.orderedData.adModel.click_track_url_list, trackModel);
            } else if (self.orderedData.adClickTrackURLs) {
                ttTrackURLsModel(self.orderedData.adClickTrackURLs, trackModel);
            }
        }        
    }

    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    [dict setValue:value forKey:@"value"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    if (self.article.groupModel.groupID) {
        [dict setValue:self.article.groupModel.groupID forKey:@"ext_value"];
    }
    
    [dict setValue:@([TTTrackerProxy sharedProxy].connectionType) forKey:@"nt"];
    [dict setValue:logExtra forKey:@"log_extra"];

    if (extra.count > 0) {
        [dict addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:dict];
}

#pragma mark -
#pragma mark helper

- (NSMutableDictionary *)screenContext
{
    NSMutableDictionary *screenContext = [[NSMutableDictionary alloc] init];
    [screenContext setValue:self.detailModel.adID forKey:@"ad_id"];
    [screenContext setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [screenContext setValue:@(self.detailModel.article.uniqueID) forKey:@"group_id"];
    return screenContext;
}

- (NSNumber *)detailReadPCT
{
    float readPct = [self.playControl watchPercent];
    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
    return @(percent);
}

@end
