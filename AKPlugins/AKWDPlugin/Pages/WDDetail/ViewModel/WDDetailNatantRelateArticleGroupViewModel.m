//
//  WDDetailNatantRelateArticleGroupViewModel.m
//  Article
//
//  Created by 延晋 张 on 16/4/26.
//
//

#import "WDDetailNatantRelateArticleGroupViewModel.h"
#import "WDDetailNatantRelateArticleGroupView.h"
#import "WDDetailNatantRelatedEntity.h"
#import "WDAnswerEntity.h"

#import "TTRoute.h"
#import "TTGroupModel.h"
#import "SSImpressionManager.h"
#import "TTStringHelper.h"

@interface WDDetailNatantRelateArticleGroupViewModel ()
/**
 *  存储相关item的impression记录状态
 */
@property(nonatomic, strong, nullable) NSMutableDictionary *relatedImpressionDic;

@end


@implementation WDDetailNatantRelateArticleGroupViewModel

-(id)init{
    self = [super init];
    if (self) {
        self.relatedImpressionDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight{
    for (int idx = 0; idx < self.relatedItems.count; idx++) {
        WDDetailNatantRelatedEntity * relatedModel = [self relatedArticleAtIndex:idx];
        CGFloat itemDistance = [self.groupView relatedItemDistantFromTopToNantantTopAtIndex:idx];
        CGFloat curItemHeight = [self.groupView heightOfItemInWrapper];
        NSString *key = relatedModel.impressionID;
        SSImpressionGroupType listType = [self listTypeForRelatedItem];
        
        TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.answerEntity.ansid];
        
        if (offsetY < itemDistance + curItemHeight  && offsetY > itemDistance - referHeight) {
            //当前可视的item
            if (![self impressionStateForRelatedID:key]) {
                [self recordDetailForNewWendaKey:relatedModel.impressionID groupModel:groupModel listType:listType withStatus:SSImpressionStatusRecording];
                
                [self updateImpressionState:YES forRelatedID:key];
            }
        }
        else {
            //当前不可视的item
            if ([self impressionStateForRelatedID:key]) {
                [self recordDetailForNewWendaKey:relatedModel.impressionID groupModel:groupModel listType:listType withStatus:SSImpressionStatusEnd];
                [self updateImpressionState:NO forRelatedID:key];
            }
        }
    }
}

/*
 *  notAtBottom方式打开的浮层收起来时停止所有related记录
 */
- (void)resetAllRelatedItemsWhenNatantDisappear {
    
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.answerEntity.ansid];
    
    for (int idx = 0; idx < self.relatedItems.count; idx++) {
        WDDetailNatantRelatedEntity * relatedModel = [self relatedArticleAtIndex:idx];
        if ([self impressionStateForRelatedID:relatedModel.impressionID]) {
            SSImpressionGroupType listType = [self listTypeForRelatedItem];
            [self recordDetailForNewWendaKey:relatedModel.impressionID groupModel:groupModel listType:listType withStatus:SSImpressionStatusEnd];
            [self updateImpressionState:NO forRelatedID:relatedModel.impressionID];
        }
    }
}


- (WDDetailNatantRelatedEntity *)relatedArticleAtIndex:(NSInteger)index{
    if (index < self.relatedItems.count) {
        return self.relatedItems[index];
    }
    return nil;
}

- (NSString *)relatedOpenPageUrlAtIndex:(NSInteger)index{
    return [self relatedItemUrlWithDetailModelItem:[self relatedArticleAtIndex:index]];
}

- (NSString *)relatedItemUrlWithDetailModelItem:(WDDetailNatantRelatedEntity *)relatedModel{
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
    return SSImpressionGroupTypeDetailRelatedArticle;
}

- (void)recordDetailForNewWendaKey:(NSString *)wendaKey
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

#pragma mark - public

- (NSArray *)mappingOriginToModel:(NSArray<WDOrderedItemStructModel *> *)originData{
    NSMutableArray * relatedItems = [[NSMutableArray alloc] init];
    [originData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WDOrderedItemStructModel *oneItem = (WDOrderedItemStructModel *)obj;
        WDDetailNatantRelatedEntity *entity = [[WDDetailNatantRelatedEntity alloc] initWithRelatedStructModel:oneItem];
        [relatedItems addObject:entity];
    }];
    return relatedItems.copy;
}

@end
