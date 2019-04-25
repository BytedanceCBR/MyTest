//
//  TTDetailNatantRelateArticleGroupViewModel.m
//  Article
//
//  Created by Ray on 16/4/11.
//
//

#import "TTDetailNatantRelateArticleGroupViewModel.h"
#import "TTDetailNatantRelateArticleGroupView.h"
#import "TTDetailNatantRelateReadViewModel.h"
#import "ExploreDetailImpressionHelper.h"
#import "ArticleInfoManager.h"
#import "TTRoute.h"
#import "TTDetailModel.h"
#import "TTStringHelper.h"


@interface TTDetailNatantRelateArticleGroupViewModel ()
/**
 *  存储相关item的impression记录状态
 */
@property(nonatomic, strong, nullable) NSMutableDictionary *relatedImpressionDic;

@end

@implementation TTDetailNatantRelateArticleGroupViewModel

-(id)init{
    self = [super init];
    if (self) {
        self.relatedImpressionDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight{
    for (int idx = 0; idx < self.relatedItems.count; idx++) {
        CGFloat itemDistance;
        CGFloat curItemHeight;
        NSString *key;
        TTDetailNatantRelatedItemModel * relatedModel = [self relatedArticleAtIndex:idx];
        itemDistance = [self.groupView relatedItemDistantFromTopToNantantTopAtIndex:idx];
        curItemHeight = [self.groupView heightOfItemInWrapper];
        key = relatedModel.impressionID;
        SSImpressionGroupType listType = 9;
        
        if (offsetY < itemDistance + curItemHeight  && offsetY > itemDistance - referHeight) {
            //当前可视的item
            if (![self impressionStateForRelatedID:key]) {
                [TTDetailNatantRelateArticleGroupViewModel recordDetailForRelatedGroupModel:relatedModel
                                                                                 groupModel:self.articleInfoManager.detailModel.article.groupModel
                                                                                   listType:listType
                                                                                 withStatus:SSImpressionStatusRecording];

                [self updateImpressionState:YES forRelatedID:key];
            }
        }
        else {
            //当前不可视的item
            if ([self impressionStateForRelatedID:key]) {
                [TTDetailNatantRelateArticleGroupViewModel recordDetailForRelatedGroupModel:relatedModel
                                                                                 groupModel:self.articleInfoManager.detailModel.article.groupModel
                                                                                   listType:listType
                                                                                 withStatus:SSImpressionStatusEnd];
                [self updateImpressionState:NO forRelatedID:key];
            }
        }
    }
}

+ (void)recordDetailForRelatedGroupModel:(TTDetailNatantRelatedItemModel *)rGroupModel
                              groupModel:(TTGroupModel *)groupModel
                                listType:(SSImpressionGroupType)listType
                              withStatus:(SSImpressionStatus)status
{
    NSString *keyName = rGroupModel.impressionID;
    NSString *itemID = [NSString stringWithFormat:@"%@_%@", rGroupModel.groupId, rGroupModel.itemId];
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:groupModel.itemID forKey:@"item_id"];
    [extra setValue:@(groupModel.aggrType) forKey:@"aggr_type"];
    
    [[SSImpressionManager shareInstance] recordDetailRelatedImpressionWithKeyName:keyName
                                                                         listType:listType
                                                                           status:status
                                                                           itemID:itemID
                                                                         userInfo:@{@"extra":extra}];
}

/*
 *  notAtBottom方式打开的浮层收起来时停止所有related记录
 */
- (void)resetAllRelatedItemsWhenNatantDisappear {
    for (int idx = 0; idx < self.relatedItems.count; idx++) {
        CGFloat itemDistance;
        CGFloat curItemHeight;
        NSString *key;
        TTDetailNatantRelatedItemModel * relatedModel = [self relatedArticleAtIndex:idx];
        key = relatedModel.impressionID;
        itemDistance = [self.groupView relatedItemDistantFromTopToNantantTopAtIndex:idx];
        curItemHeight = [self.groupView heightOfItemInWrapper];

        if ([self impressionStateForRelatedID:key]) {
            SSImpressionGroupType listType = 9;
            [TTDetailNatantRelateArticleGroupViewModel recordDetailForRelatedGroupModel:relatedModel
                                                                             groupModel:self.articleInfoManager.detailModel.article.groupModel
                                                                               listType:listType
                                                                             withStatus:SSImpressionStatusEnd];
            [self updateImpressionState:NO forRelatedID:key];
        }
    }
}

- (TTDetailNatantRelatedItemModel *)relatedArticleAtIndex:(NSInteger)index{
    if (index < self.relatedItems.count) {
        return self.relatedItems[index];
    }
    return nil;
}

- (NSString *)relatedOpenPageUrlAtIndex:(NSInteger)index{
    return [self relatedItemUrlWithDetailModelItem:[self relatedArticleAtIndex:index]];
}

- (NSString *)relatedItemUrlWithDetailModelItem:(TTDetailNatantRelatedItemModel *)relatedModel{
    NSString * schema = relatedModel.schema;
    if (!isEmptyString(schema) && [[UIApplication sharedApplication] canOpenURL:[TTStringHelper URLWithURLString:schema]]) {
        return schema;
    }
    
    if (!isEmptyString(schema) && [[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:schema]]) {
        return schema;
    }
    return nil;
}

- (void)updateImpressionState:(BOOL)state forRelatedID:(NSString *)groupID
{
    if (isEmptyString(groupID)) {
        return;
    }
    _relatedImpressionDic[groupID] = @(state);
}

- (BOOL)impressionStateForRelatedID:(NSString *)groupID
{
    if ([[_relatedImpressionDic allKeys] containsObject:groupID]) {
        return [_relatedImpressionDic[groupID] boolValue];
    }
    else {
        return NO;
    }
}

- (SSImpressionGroupType)listTypeForRelatedItem {
    if ([self.eventLabel isEqualToString:@"slide_detail"]) {
        return SSImpressionGroupTypeDetailRelatedGallery;
    }
    return SSImpressionGroupTypeDetailRelatedArticle;
}

#pragma mark - public

- (NSArray *)mappingOriginToModel:(NSArray *)originData{
    NSMutableArray * relatedItems = [[NSMutableArray alloc] init];
    [originData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary * oneItem = (NSDictionary *)obj;
        NSError * parseError;
        TTDetailNatantRelatedItemModel * oneItemModel = [[TTDetailNatantRelatedItemModel alloc] initWithDictionary:oneItem error:&parseError];
        if (oneItemModel) {
            [relatedItems addObject:oneItemModel];
        }
    }];
    return relatedItems.copy;
}
@end
