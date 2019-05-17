//
//  ExploreDetailImpressionHelper.m
//  Article
//
//  Created by 冯靖君 on 15/10/29.
//
//

#import "ExploreDetailImpressionHelper.h"

@implementation ExploreDetailImpressionHelper

//记录文章



+ (void)recordDetailForRelatedGroupModel:(TTGroupModel *)rGroupModel
                              groupModel:(TTGroupModel *)groupModel
                                listType:(SSImpressionGroupType)listType
                              withStatus:(SSImpressionStatus)status
{
    if (isEmptyString(rGroupModel.groupID) || isEmptyString(groupModel.groupID)) {
        return;
    }
    NSString *keyName = [NSString stringWithFormat:@"%@_%@", groupModel.groupID, groupModel.itemID];
    NSString *itemID = [NSString stringWithFormat:@"%@_%@", rGroupModel.groupID, rGroupModel.itemID];
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:groupModel.itemID forKey:@"item_id"];
    [extra setValue:@(groupModel.aggrType) forKey:@"aggr_type"];
    
    [[SSImpressionManager shareInstance] recordDetailRelatedImpressionWithKeyName:keyName
                                                                         listType:listType
                                                                           status:status
                                                                           itemID:itemID
                                                                         userInfo:@{@"extra":extra}];
}

//记录频道推荐、话题等非文章，传url
+ (void)recordDetailForUrl:(NSString *)url
                groupModel:(TTGroupModel *)groupModel
                  listType:(SSImpressionGroupType)listType
                withStatus:(SSImpressionStatus)status
{
    if (isEmptyString(url) || isEmptyString(groupModel.groupID)) {
        return;
    }

    NSString *keyName = [NSString stringWithFormat:@"%@_%@", groupModel.groupID, groupModel.itemID];
    [[SSImpressionManager shareInstance] recordDetailRelatedImpressionWithKeyName:keyName
                                                                         listType:listType
                                                                           status:status
                                                                           itemID:url
                                                                         userInfo:nil];
}

//记录详情页相关问答，传qid_aid
+ (void)recordDetailForWendaKey:(NSString *)wendaKey
                     groupModel:(TTGroupModel *)groupModel
                       listType:(SSImpressionGroupType)listType
                     withStatus:(SSImpressionStatus)status
{
    NSString *keyName = [NSString stringWithFormat:@"%@_%@", groupModel.groupID, groupModel.itemID];
    [[SSImpressionManager shareInstance] recordDetailWendaImpressionWithKeyName:keyName
                                                                       listType:listType
                                                                         status:status
                                                                         itemID:wendaKey
                                                                       userInfo:nil];
}

//新版记录详情页相关问答，传qid_aid
+ (void)recordDetailForNewWendaKey:(NSString *)wendaKey
                        groupModel:(TTGroupModel *)groupModel
                          listType:(SSImpressionGroupType)listType
                        withStatus:(SSImpressionStatus)status
{
    [[SSImpressionManager shareInstance] recordDetailWendaImpressionWithKeyName:groupModel.groupID
                                                                       listType:listType
                                                                         status:status
                                                                         itemID:wendaKey
                                                                       userInfo:nil];
}

@end
