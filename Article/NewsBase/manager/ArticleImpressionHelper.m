//
//  ArticleImpressionHelper.m
//  Article
//
//  Created by Zhang Leonardo on 14-6-24.
//
//

#import "ArticleImpressionHelper.h"

#import "Article.h"
#import "ExploreOrderedData+TTAd.h"
//#import "FRCommentRepost.h"
#import "HorizontalCard.h"
//#import "SurveyListData.h"
//#import "SurveyPairData.h"
#import "TSVShortVideoOriginalData.h"
#import "TTCommentReplyModel.h"
//#import "Thread.h"
//#import "UGCRepostCommonModel.h"
#import <TTImpression/SSImpressionModel.h>

@implementation ArticleImpressionHelper

+ (void)recordGroupForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status params:(SSImpressionParams *)params
{
    if (!orderedData.horizontalCard) {
        [self recordGroupExcludeHorizontalCardForExploreOrderedData:orderedData status:status params:params];
    }
}

+ (void)recordGroupExcludeHorizontalCardForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status params:(SSImpressionParams *)params
{
    if (orderedData.originalData.uniqueID == 0) {
        return;
    }

    if (params.refer == 3 && isEmptyString(params.categoryID)) {
        //处于Story列表，频道ID不能为空
        return;
    }

    if (params.refer == 2 && isEmptyString(params.concernID)) {
        //处于关心主页的列表，关心ID不能为空
        return;
    }
    
    if (params.refer == 1 && isEmptyString(params.categoryID)) {
        //处于频道的列表，频道ID不能为空
        return;
    }
    
    NSNumber * gid = @(orderedData.originalData.uniqueID);
    if ([gid longLongValue] != 0) {
        
        switch (orderedData.listType) {
            case ExploreOrderedDataListTypeFavorite:
            {
                params.categoryID = kImpressionFavoriteKeyName;
            }
                break;

            default:
                break;
        }
        if ([params.categoryID isEqualToString:kTTMainCategoryID]) {
            params.categoryID = kImporessionMainCategoryKeyName;
        }
        
        NSString *aid = orderedData.ad_id;
        
        NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
        [extraDic setValue:@(params.refer) forKey:@"refer"];
        if (params.refer == 1 && !isEmptyString(params.concernID)) {
            //处于频道，关心ID不为空
            [extraDic setValue:params.concernID forKey:@"concern_id"];
        }
        if (params.refer == 2 && !isEmptyString(params.categoryID)) {
            //处于关心主页，频道ID不为空
            [extraDic setValue:params.categoryID forKey:@"category_id"];
        }
        if (params.refer == 3 && !isEmptyString(params.userId)) {
            //处于Story主页，StoryUserID不为空
            [extraDic setValue:params.userId forKey:@"story_user_id"];
        }
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        [userInfo setValue:extraDic forKey:@"extra"];
        [userInfo setValue:params forKey:@"params"];
        
        SSImpressionModelType modelType;
        NSString *groupID = gid.stringValue;
        
//        if (orderedData.commentRepostModel) {
//            [self recordCommentRepost:orderedData.commentRepostModel status:status params:params userInfo:userInfo];
//            return;
//        }
        
        
//        if (orderedData.thread) {
//            modelType = SSImpressionModelTypeThread;
//            [self recordThread:orderedData.thread groupID:groupID aid:aid status:status params:params userInfo:userInfo];
//            return;
//        }
        if (orderedData.huoShan) {
            modelType = SSImpressionModelTypeHouShanListItem;
        }
        else if (orderedData.lianZai){
            modelType = SSImpressionModelTypeLianZaiListItem;
        }
//        else if (orderedData.live){
//            modelType = SSImpressionModelTypeLiveListItem;
//        }
//        else if (orderedData.recommendUserCardsData){
//            modelType = SSImpressionModelTypeU11RecommendUserItem;
//        }
        else if (orderedData.shortVideoOriginalData) {
            modelType = SSImpressionModelTypeUGCVideo;
        }
//        else if (orderedData.recommendUserLargeCardData) {
//            modelType = SSImpressionModelTypeU11RecommendUserItem;
//        }
//        else if (orderedData.momentsRecommendUserData) {
//            modelType = SSImpressionModelTypeU11MomentsRecommendUserItem;
//        }
//        else if (orderedData.fantasyCardData) {
//            modelType = 78;
//        }
//        else if (orderedData.surveyListData) {
//            SurveyListData *data = (SurveyListData *)(orderedData.surveyListData);
//            if (data && !data.hideNextTime) {
//                modelType = 1000;
//            } else {
//                modelType = SSImpressionModelTypeGroup;
//            }
//        }
//        else if (orderedData.surveyPairData) {
//            SurveyPairData *data = (SurveyPairData *)(orderedData.surveyPairData);
//            if (data && !data.hideNextTime) {
//                modelType = 1001;
//            } else {
//                modelType = SSImpressionModelTypeGroup;
//            }
//        }
//        else if (orderedData.recommendUserStoryCardData) {
//            modelType = SSImpressionModelTypeRecommendUserStory;
//        }
//
//        else if (orderedData.recommendUserStoryCoverCardData) {
//            modelType = SSImpressionModelTypeRecommendStoryCover;
//        }
        
//        else if (orderedData.tsvStoryOriginalData) {
//            modelType = SSImpressionModelTypeStory;
//        }
        else if (orderedData.hotNewsData) {
            modelType = 85; //热点要闻 单条样式
        } else if (orderedData.isHotNewsCellWithAvatar || orderedData.isHotNewsCellWithRedDot) {
            modelType = 86; //热点要闻 多条样式
        }
        else {
            modelType = SSImpressionModelTypeGroup;
            
            TTGroupModel *model = nil;
            if (orderedData.article) {
                model = [[TTGroupModel alloc] initWithGroupID:groupID itemID:orderedData.article.itemID impressionID:nil aggrType:orderedData.article.aggrType.integerValue];
            } else {
                model = [[TTGroupModel alloc] initWithGroupID:groupID];
            }
            
            groupID = model.impressionDescription;
        }
        
        
        
        [[SSImpressionManager shareInstance] recordGroupImpressionCategoryID:params.categoryID concernID:params.concernID refer:params.refer modelType:modelType groupID:groupID adID:aid status:status userInfo:userInfo];
    }
}

+ (void)recordShortVideoForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status params:(SSImpressionParams *)params {
    if (orderedData.originalData.uniqueID == 0) {
        return;
    }
    NSString * aid = orderedData.ad_id;
    
    if ([params.categoryID isEqualToString:kTTMainCategoryID]) {
        params.categoryID = kImporessionMainCategoryKeyName;
    }
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:@(params.refer) forKey:@"refer"];
    if (params.refer == 1 && !isEmptyString(params.concernID)) {
        //处于频道，关心ID不为空
        [extraDic setValue:params.concernID forKey:@"concern_id"];
    }
    
    SSImpressionModelType modelType;
    NSString *groupID = @(orderedData.originalData.uniqueID).stringValue;
    TTGroupModel *model = [[TTGroupModel alloc] initWithGroupID:groupID];
    if (orderedData.tsvRecUserCardOriginalData) {
        modelType = SSImpressionModelTypeU11RecommendUserItem;
    }
//    else if (orderedData.tsvStoryOriginalData) {
//        modelType = SSImpressionModelTypeStory;
//    }
    else if (orderedData.tsvActivityEntranceOriginalData) {
        modelType = SSImpressionModelTypeShortVideoActivityEntrance;
    } else if (orderedData.tsvActivityBannerOriginalData) {
        modelType = SSImpressionModelTypeShortVideoActivityBananer;
    } else {
        modelType = SSImpressionModelTypeUGCVideo;
    }
    
    groupID = model.impressionDescription;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setValue:extraDic forKey:@"extra"];
    [userInfo setValue:params forKey:@"params"];
    
    [[SSImpressionManager shareInstance] recordWithListKey:params.categoryID listType:SSImpressionGroupTypeHuoshanVideoList itemID:groupID modelType:modelType adID:aid status:status userInfo:userInfo];
}

+ (void)recordCommentForCommentModel:(id<TTCommentModelProtocol>)comment status:(SSImpressionStatus)status groupModel:(TTGroupModel *)groupModel
{
    if ([comment.commentID longLongValue] != 0 && groupModel.groupID != 0) {
        NSString * cIDStr = [NSString stringWithFormat:@"%@", comment.commentID];
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        if ([comment respondsToSelector:@selector(trackerDic)]) {
            [extra addEntriesFromDictionary:comment.trackerDic];
        }
        [extra setValue:groupModel.itemID forKey:@"item_id"];
        [extra setValue:@(groupModel.aggrType) forKey:@"aggr_type"];
        //记录reply信息，原始
        NSArray<TTCommentReplyModel*>* commentReplyInfo = [comment replyModelArr];
        NSDictionary *uInfo;
        if([commentReplyInfo count] != 0)
        {
            NSMutableArray<NSString*> *replyIDs = [NSMutableArray new];
            [commentReplyInfo enumerateObjectsUsingBlock:^(TTCommentReplyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [replyIDs addObject:obj.replyID];
            }];
            uInfo = @{@"extra":extra,@"replyIDs":replyIDs};
        }else
        {
            uInfo = @{@"extra":extra};
        }
        
        [[SSImpressionManager shareInstance] recordCommentImpressionGroupID:groupModel.impressionDescription commentID:cIDStr status:status userInfo:uInfo];
    }
}

+ (void)recordGroupWithUniqueID:(NSString *)uniqueID adID:(NSString *)adID groupModel:(TTGroupModel *)groupModel status:(SSImpressionStatus)status params:(SSImpressionParams *)params
{
    NSString *categoryID = params.categoryID;
    if (isEmptyString(uniqueID) || isEmptyString(categoryID)) {
        return;
    }
    NSNumber *gid = @(uniqueID.longLongValue);
    if ([gid longLongValue] != 0) {
        if ([categoryID isEqualToString:kTTMainCategoryID]) {
            categoryID = kImporessionMainCategoryKeyName;
        }

        NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
        [extraDic setValue:@(1) forKey:@"refer"];

        SSImpressionModelType modelType = SSImpressionModelTypeGroup;
        NSString *groupID = gid.stringValue;

        groupID = groupModel.impressionDescription;

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        [userInfo setValue:extraDic forKey:@"extra"];
//        [userInfo setValue:params forKey:@"params"];//是为了加cellStyle视频不需要
        [[SSImpressionManager shareInstance] recordGroupImpressionCategoryID:categoryID concernID:nil refer:1 modelType:modelType groupID:groupID adID:adID status:status userInfo:userInfo];
    }
}


//涉及thread的impression，因为转发的原文要单独发
//+ (void)recordThread:(Thread *)thread groupID:(NSString*)groupID aid:(NSString *)aid status:(SSImpressionStatus)status params:(SSImpressionParams *)params userInfo:(NSDictionary*)userInfo
//{
//    if (thread == nil || isEmptyString(groupID)) {
//        return;
//    }
//
//    NSString *profileGroupID = nil;
//    switch (thread.repostOriginType) {
//        case TTThreadRepostOriginTypeShortVideo:
//            profileGroupID = [@(thread.originShortVideoOriginalData.uniqueID) stringValue];
//            break;
//        case TTThreadRepostOriginTypeArticle:
//            profileGroupID = [@(thread.originGroup.uniqueID) stringValue];
//            break;
//        case TTThreadRepostOriginTypeThread:
//            profileGroupID = [@(thread.originThread.uniqueID) stringValue];
//            break;
//        case TTThreadRepostOriginTypeCommon:
//        {
//            if(!SSIsEmptyDictionary(thread.repostParameters)){
//                profileGroupID = [thread.repostParameters tt_stringValueForKey:@"fw_id"];
//            }
//        }
//            break;
//        default:
//            break;
//    }
//
//    if (profileGroupID.length > 0 && ![profileGroupID isEqualToString:@"0"]) {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
//        [dict setValue:@{@"profile_group_id" : profileGroupID} forKey:@"modelExtra"];
//        userInfo = [dict copy];
//    }
//
//    SSImpressionModelType modelType = SSImpressionModelTypeThread;
//    [[SSImpressionManager shareInstance] recordGroupImpressionCategoryID:params.categoryID concernID:params.concernID refer:params.refer modelType:modelType groupID:groupID adID:aid status:status userInfo:userInfo];
//}

////参考Thread的impression，加上原内容双发
//+ (void)recordCommentRepost:(FRCommentRepost *)commentRepost status:(SSImpressionStatus)status params:(SSImpressionParams *)params userInfo:(NSDictionary*)userInfo
//{
//    if (commentRepost == nil) {
//        return;
//    }
//
//    NSString *profileGroupID = nil;
//
//    if (commentRepost.originRepostCommonModel) {
//        profileGroupID = commentRepost.originRepostCommonModel.group_id;
//    }
//    else {
//        switch (commentRepost.commentType) {
//            case FRCommentTypeCodeARTICLE:
//                profileGroupID = [@(commentRepost.originGroup.uniqueID) stringValue];
//                break;
//            case FRCommentTypeCodeTHREAD:
//                profileGroupID = [@(commentRepost.originThread.uniqueID) stringValue];
//                break;
//            default:
//                break;
//        }
//    }
//    if (profileGroupID.length > 0 && ![profileGroupID isEqualToString:@"0"]) {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
//        [dict setValue:@{@"profile_group_id" : profileGroupID} forKey:@"modelExtra"];
//        userInfo = [dict copy];
//    }
//
//    SSImpressionModelType modelType = SSImpressionModelTypeCommentRepostDetail;
//
//    [[SSImpressionManager shareInstance] recordGroupImpressionCategoryID:params.categoryID concernID:params.concernID refer:params.refer modelType:modelType groupID:commentRepost.groupId adID:nil status:status userInfo:userInfo];
//}
@end
