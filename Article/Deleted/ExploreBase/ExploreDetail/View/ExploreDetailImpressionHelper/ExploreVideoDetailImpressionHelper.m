//
//  ExploreVideoDetailImpressionHelper.m
//  Article
//
//  Created by 冯靖君 on 15/10/10.
//
//

#import "ExploreVideoDetailImpressionHelper.h"
#import "ArticleInfoManager.h"
#import "TTTrackerWrapper.h"

@implementation ExploreVideoDetailImpressionHelper

//+ (void)enterVideoDetailForVideoID:(NSString *)videoID groupModel:(TTGroupModel *)groupModel
//{
//    if (isEmptyString(videoID) || isEmptyString(groupModel.groupID)) {
//        return;
//    }
//    NSString *keyName = [NSString stringWithFormat:@"%@_%@_%@", groupModel.groupID, groupModel.itemID, videoID];
//    [[SSImpressionManager shareInstance] leaveVideoDetailViewForKeyName:keyName];
//}
//
//+ (void)leaveVideoDetailForVideoID:(NSString *)videoID groupModel:(TTGroupModel *)groupModel
//{
//    if (isEmptyString(videoID) || isEmptyString(groupModel.groupID)) {
//        return;
//    }
//    NSString *keyName = [NSString stringWithFormat:@"%@_%@_%@", groupModel.groupID, groupModel.itemID, videoID];
//    [[SSImpressionManager shareInstance] enterVideoDetailViewForKeyName:keyName];
//}

+ (void)recordVideoDetailForArticle:(Article *)article
                           rArticle:(Article *)rArticle
                             status:(SSImpressionStatus)status
{
    NSString *videoID = article.videoDetailInfo[VideoInfoIDKey];
    NSString *rVideoID = rArticle.videoDetailInfo[VideoInfoIDKey];
    if (isEmptyString(rVideoID) || isEmptyString(rArticle.groupModel.groupID)) {
        return;
    }
    NSString *keyName = [NSString stringWithFormat:@"%@_%@_%@", article.groupModel.groupID, article.groupModel.itemID, videoID];
    NSString *impressionItemID = [NSString stringWithFormat:@"%@_%@_%@", rArticle.groupModel.groupID, rArticle.groupModel.itemID, rVideoID];
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:article.groupModel.itemID forKey:@"item_id"];
    [extra setValue:@(article.groupModel.aggrType) forKey:@"aggr_type"];
    
    if ([article hasVideoSubjectID]) {
        [extra setValue:[article videoSubjectID] forKey:@"video_subject_id"];
    }
    
    if ([rArticle relatedVideoType] == ArticleRelatedVideoTypeAd && status == SSImpressionStatusRecording) {
        if ([rArticle relatedLogExtra]) {
            extra[@"log_extra"] = [rArticle relatedLogExtra];
        }
    }
    
    [[SSImpressionManager shareInstance] recordVideoDetailImpressionWithKeyName:keyName itemID:impressionItemID status:status userInfo:@{@"extra":extra}];
}

@end
