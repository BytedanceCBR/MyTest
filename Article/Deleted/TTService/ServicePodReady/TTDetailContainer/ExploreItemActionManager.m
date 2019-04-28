//
//  ExploreItemActionManager.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-16.
//
//

#import "ExploreItemActionManager.h"
#import "ArticleURLSetting.h"
#import "Article.h"
#import "DetailActionRequestManager.h"
#import "TTNetworkManager.h"
//#import "Thread.h"

@interface ExploreItemActionManager()
@property(nonatomic, retain)DetailActionRequestManager *actionManager;
@property(nonatomic, copy)ExploreItemActionFinishBlock finishBlock;
@end

@implementation ExploreItemActionManager

+ (void)removeOrderedData:(ExploreOrderedData *)orderedData
{
    if (orderedData.originalData.userRepined) {
        [self unRepinData:orderedData.originalData];
    }
    
    [orderedData deleteObject];
}

+ (NSDictionary *)queryDictionaryWithOriginalData:(ExploreOriginalData *)originalData isRepin:(BOOL)repin
{
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [mDict setValue:kExploreFavoriteListIDKey forKey:@"categoryID"];
    NSString *uniqueID = [NSString stringWithFormat:@"%lld", originalData.uniqueID];
    [mDict setValue:uniqueID forKey:@"uniqueID"];
    
    [mDict setValue:@(ExploreOrderedDataListTypeFavorite) forKey:@"listType"];
    return mDict;
}

+ (void)repinData:(ExploreOriginalData *)originalData
{
    originalData.userRepinTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    originalData.repinCount = [NSNumber numberWithInt:[originalData.repinCount intValue] + 1];
    originalData.userRepined = YES;
    [originalData save];
}

+ (void)unRepinData:(ExploreOriginalData *)originalData
{
    originalData.userRepinTime = [NSNumber numberWithFloat:0.f];
    if ([originalData.repinCount intValue] >= 0) {
        originalData.repinCount = [NSNumber numberWithInt:[originalData.repinCount intValue] - 1];
    }
    originalData.userRepined = NO;
    [originalData save];
}

+ (void)changeFavoriteStatus:(ExploreOriginalData *)originData
{
    LOGD(@"changeFavoriteStatus %p", originData);
    if (originData.userRepined) {
        [self unRepinData:originData];
    }
    else {
        [self repinData:originData];
    }
}

- (void)startSendDislikeActionType:(DetailActionRequestType)type
                            source:(TTDislikeSourceType)source
                        groupModel:(TTGroupModel *)groupModel
                       filterWords:(NSArray*)filterWords
                            cardID:(NSString*)cardID
                       actionExtra:(NSString*)actionExtra
                              adID:(NSNumber *)adID
                           adExtra:(NSDictionary *)adExtra
                          widgetID:(NSString *)widgetID
                          threadID:(NSString *)threadID
                       finishBlock:(ExploreItemActionFinishBlock)finishBlock {
    self.finishBlock = finishBlock;
    if(type != DetailActionTypeNewVersionDislike && type != DetailActionTypeNewVersionUndislike)
    {
        NSLog(@"only support new version dislike and new version undislike");
        return;
    }
    
    if(groupModel.groupID != 0 && !isEmptyString(cardID))
    {
        NSLog(@"only one ID is not empty");
        return;
    }
  
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = groupModel;
    context.cardID = cardID;
    context.actionExtra = actionExtra;
    context.filterWords = filterWords;
    if (adID.longLongValue > 0) {
        context.adID = [NSString stringWithFormat:@"%@", adID];
    }
    context.adExtra = adExtra;
    context.widgetID = widgetID;
    context.threadID = threadID;
    
    if (source == TTDislikeSourceTypeFeed) {
        context.dislikeSource = @"0";//0 代表feed
    }
    else {
        context.dislikeSource = @"1";
    }
    
    if (!_actionManager)
    {
        self.actionManager = [[DetailActionRequestManager alloc] init];
    }
    _actionManager.finishBlock = self.finishBlock;
    
    [_actionManager setContext:context];
    [_actionManager startItemActionByType:type];
}

- (void)startSendDislikeActionType:(DetailActionRequestType)type groupModel:(TTGroupModel *)groupModel filterWords:(NSArray*)filterWords cardID:(NSString*)cardID actionExtra:(NSString*)actionExtra adID:(NSNumber *)adID adExtra:(NSDictionary *)adExtra widgetID:(NSString *)widgetID threadID:(NSString *)threadID finishBlock:(ExploreItemActionFinishBlock)finishBlock
{
    [self startSendDislikeActionType:type source:TTDislikeSourceTypeFeed groupModel:groupModel filterWords:filterWords cardID:cardID actionExtra:actionExtra adID:adID adExtra:adExtra widgetID:widgetID threadID:threadID finishBlock:finishBlock];
}


- (void)sendActionForOriginalData:(ExploreOriginalData *)originalData adID:(NSNumber *)adID actionType:(DetailActionRequestType)type finishBlock:(ExploreItemActionFinishBlock)finishBlock
{
    self.finishBlock = finishBlock;
    BOOL needUseArticleSujectItemAction = NO;

    if (originalData == nil || originalData.uniqueID == 0) {
        return;
    }
    
    if ([originalData isKindOfClass:[Article class]]) {
        Article * article = (Article *)originalData;
        if (article) {
            BOOL isTopic = [article.groupType intValue] == ArticleGroupTypeTopic;
            needUseArticleSujectItemAction = isTopic && (type == DetailActionTypeDislike || type == DetailActionTypeUnDislike);
        }
    }
    
    if (needUseArticleSujectItemAction) {
        [self sendSubjectDislke:(Article *)originalData adID:adID actionType:type];
    }
    else {
        
        if(!_actionManager)
        {
            self.actionManager = [[DetailActionRequestManager alloc] init];
        }
        _actionManager.finishBlock = self.finishBlock;
        TTGroupModel *groupModel = nil;
        if ([originalData isKindOfClass:[Article class]]) {
            Article *article = (Article *)originalData;
            groupModel = [[TTGroupModel alloc] initWithGroupID:article.groupModel.groupID itemID:article.itemID impressionID:nil aggrType:article.aggrType.integerValue];
        } else {
            groupModel = [[TTGroupModel alloc] initWithGroupID:@(originalData.uniqueID).stringValue];
        }
        
        TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
        context.groupModel = groupModel;
        if (adID) {
            context.adID = [NSString stringWithFormat:@"%@", adID];
        }
        [_actionManager setContext:context];
        
        [_actionManager startItemActionByType:type];
    }
}

- (void)sendBatchUnRepinActionForGroupIDs:(NSArray<NSNumber *> *)groupIDs itenIDs:(NSArray<NSNumber *> *)itemsIDs finishBlock:(ExploreItemActionFinishBlock)finishBlock {
    self.finishBlock = finishBlock;
    
    if(!_actionManager)
    {
        self.actionManager = [[DetailActionRequestManager alloc] init];
    }
    _actionManager.finishBlock = self.finishBlock;
    
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupIDs = groupIDs;
    context.itemIDs = itemsIDs;
    [_actionManager setContext:context];
    
    [_actionManager startItemActionByType:DetailActionTypeMultiUnFavourite];
}

/**
 *  发送专题的item Action，该方法只支持专题的dislike 和 undislike
 *
 *  @param orderedData
 *  @param finishBlock
 */
- (void)sendSubjectDislke:(Article *)article adID:(NSNumber *)adID actionType:(DetailActionRequestType)type
{
    NSString * urlString = [ArticleURLSetting articleItemActionURLString];
    NSMutableDictionary * postParam = [NSMutableDictionary dictionaryWithCapacity:10];
    [postParam setValue:@(article.uniqueID) forKey:@"group_id"];
    [postParam setValue:article.groupModel.itemID forKey:@"item_id"];
    [postParam setValue:@(article.groupModel.aggrType) forKey:@"aggr_type"];
    if (type == DetailActionTypeDislike) {
        [postParam setValue:@"dislike" forKey:@"action"];
    }
    else if (type == DetailActionTypeUnDislike) {
        [postParam setValue:@"undislike" forKey:@"action"];
    }
    [postParam setValue:article.itemVersion forKey:@"item_version"];
    [postParam setValue:article.topicGroupId forKey:@"topic_group_id"];
    [postParam setValue:adID forKey:@"ad_id"];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlString params:postParam method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (_finishBlock) {
            _finishBlock(nil, error);
        }
    }];
}

#pragma mark -- tip

- (void)unfavoriteForOriginalData:(ExploreOriginalData *)originalData adID:(NSNumber *)adID finishBlock:(ExploreItemActionFinishBlock)finishBlock
{
    if (!originalData.userRepined) {
        //已经是非收藏状态
        return;
    }
    [ExploreItemActionManager changeFavoriteStatus:originalData];
    [self sendActionForOriginalData:originalData adID:adID actionType:DetailActionTypeUnFavourite finishBlock:finishBlock];
}

- (void)unfavoriteForOrderedDataGroup:(NSArray<ExploreOrderedData *> *)orderedDataGroup finishBlock:(ExploreItemActionFinishBlock)finishBlock {
    NSMutableArray<NSNumber *> *groupIDs = [NSMutableArray arrayWithCapacity:orderedDataGroup.count];
    NSMutableArray<NSNumber *> *itemsIDs = [NSMutableArray arrayWithCapacity:orderedDataGroup.count];
    for (ExploreOrderedData *orderedData in orderedDataGroup) {
        if (!orderedData.originalData.userRepined) {
            //已经是非收藏状态
            continue;
        }
        [groupIDs addObject:@(orderedData.uniqueID.longLongValue)];
        [itemsIDs addObject:@(orderedData.itemID.longLongValue)];
    }
    
    [self sendBatchUnRepinActionForGroupIDs:[groupIDs copy] itenIDs:[itemsIDs copy]finishBlock:finishBlock];
}

- (void)favoriteForOriginalData:(ExploreOriginalData *)originalData adID:(NSNumber *)adID finishBlock:(ExploreItemActionFinishBlock)finishBlock
{
    if (originalData.userRepined) {
        //已经是收藏状态
        return;
    }

    [ExploreItemActionManager changeFavoriteStatus:originalData];
    [self sendActionForOriginalData:originalData adID:adID actionType:DetailActionTypeFavourite finishBlock:finishBlock];
}

- (void)favoriteForGroupModel:(TTGroupModel *)groupModel adID:(NSNumber *)adID isFavorite:(BOOL)isFavorite finishBlock:(ExploreItemActionFinishBlock)finishBlock
{
    self.finishBlock = finishBlock;
    
    if (!groupModel && !adID) {
        return;
    }
    
    if(!_actionManager)
    {
        self.actionManager = [[DetailActionRequestManager alloc] init];
    }
    _actionManager.finishBlock = self.finishBlock;
    
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = groupModel;
    if (adID) {
        context.adID = [NSString stringWithFormat:@"%@", adID];
    }
    [_actionManager setContext:context];
    [_actionManager startItemActionByType:isFavorite ? DetailActionTypeFavourite : DetailActionTypeUnFavourite];
}

@end
