//
//  NewsTrendsManager.m
//  Article
//
//  Created by Dianwei on 14-5-22.
//
//

#import "ArticleMomentManager.h"
#import "TTNetworkManager.h"
#import "ArticleURLSetting.h"
#import "ArticleMomentModel.h"
#import "SSUserModel.h"
#import "SSUpdateListNotifyManager.h"
#import "ArticleMomentHelper.h"
#import "NSDictionary+TTAdditions.h"

#import "TTLCSServerConfig.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Comment.h"

#import <TTAccountBusiness.h>
#import "FRActionDataService.h"


NSString *const kArticleMomentGetUpdateNumberNotification   = @"kArticleMomentGetUpdateNumberNotification";
NSString *const kArticleMomentUpdateNumberKey               = @"kArticleMomentUpdateNumberKey";
NSString *const kArticleMomentUserInfoChangeListKey         = @"kArticleMomentUserInfoChangeListKey";
NSString *const kArticleMomentUserInfoHasMoreKey            = @"kArticleMomentUserInfoHasMoreKey";
NSString *const kArticleMomentUserTipDataKey                = @"kArticleMomentUserTipDataKey";

//add on 4.6 for user avatar
NSString *const kArticleMomentUpdateUserKey               = @"kArticleMomentUpdateUserKey";

NSString *const kArticleMomentSyncNotification = @"kArticleMomentSyncNotification";
NSString *const kArticleMomentModelUserInfoKey = @"kArticleMomentModelUserInfoKey";
NSString *const kArticleMomentModelCommentCountKey = @"kArticleMomentModelCommentCountKey";

static NSTimeInterval const kInvalidCursor                  = -1.f;
static NSString *const kMomentCacheStorageKey               = @"kMomentCacheStorageKeyV3_5_2";


@interface ArticleMomentManager()
<
TTAccountMulticastProtocol
>
{
    NSTimeInterval _currentMinCursor;
    NSTimeInterval _currentMaxCurosr;
}

@property(nonatomic, retain)NSTimer *timer;
@property(nonatomic, assign)NSTimeInterval getUpdateNumberInterval;
@property(nonatomic, retain)NSMutableOrderedSet *momentSet;
@property(nonatomic, assign, readwrite, getter = isLoading)BOOL loading;
@property(nonatomic, assign) BOOL isNewMoment;

//added for ExploreComment
@property(nonatomic, retain)NSCache *commentToMomentCache;

@end

@implementation ArticleMomentManager

static ArticleMomentManager *s_manager;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[ArticleMomentManager alloc] init];
    });
    
    return s_manager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
    [_timer invalidate];
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.momentSet = [[NSMutableOrderedSet alloc] init];
        _commentToMomentCache = [[NSCache alloc] init];
        
        self.cacheEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [TTAccount addMulticastDelegate:self];
    }
    
    return self;
}

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    if (_cacheEnabled) {
        [self removeAllMoments];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notifiction
{
    if (_cacheEnabled) {
        [self syncronizeCache];
    }
}

- (void)startGetUpdateNumberTimer
{
    [_timer invalidate];
    
    BOOL repeat = YES;
    if ([[TTLCSServerConfig sharedInstance] isEnabled]) {
        repeat = NO;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[SSUpdateListNotifyManager updateBadgeRefreshInterval] target:self selector:@selector(getUpdateNumber:) userInfo:nil repeats:repeat];
    [_timer fire];
}

- (void)stopGetUpdateNumberTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (NSArray*)moments
{
    if (_cacheEnabled &&  [_momentSet count] == 0) {
        NSMutableOrderedSet * cachedMoments = [self fetchCachedMoments];
        if ([cachedMoments count] > 0) {
            [_momentSet addObjectsFromArray:[cachedMoments array]];
        }
        
    }
    return [_momentSet array];
}

- (NSArray *)momentsInManagerForID:(NSString *)mID containForwardOriginItem:(BOOL)contain
{
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:10];
    if ([mID longLongValue] == 0) {
        return array;
    }
    
    for (ArticleMomentModel * model in [self moments]) {
        if ([model.ID longLongValue] == [mID longLongValue]) {
            [array addObject:model];
        }
        else if (contain && [model.originItem.ID longLongValue] == [mID longLongValue]) {
            [array addObject:model];
        }
    }
    return array;
}

- (ArticleMomentModel *)momentInListForID:(NSString *)mID
{
    if ([mID longLongValue] == 0) {
        return nil;
    }
    
    for (ArticleMomentModel * model in [self moments]) {
        if ([model.ID longLongValue] == [mID longLongValue]) {
            return model;
        }
    }
    return nil;
}

- (BOOL)containMomentForID:(NSString *)mID
{
    if ([self momentInListForID:mID] == nil) {
        return NO;
    }
    return YES;
}

- (void)removeAllMoments
{
    [_momentSet removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMomentCacheStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setCurrentMinCursor:0];
    [self setCurrentMaxCursor:0];
}

- (void)removeMoment:(ArticleMomentModel *)model
{
    [_momentSet removeObject:model];
}

- (void)removeMoments:(NSArray *)models
{
    if ([models count] == 0) {
        return;
    }
    for (ArticleMomentModel * model in models) {
        [_momentSet removeObject:model];
    }
}

- (NSTimeInterval)currentMinCursor
{
    if(_currentMinCursor == 0 && [self isCacheEnabled])
    {
        NSMutableOrderedSet * cachedMoments = [self fetchCachedMoments];
        if ([cachedMoments count] > 0) {
            id mom = [cachedMoments firstObject];
            if ([mom isKindOfClass:[ArticleMomentModel class]]) {
                _currentMinCursor = ((ArticleMomentModel *)mom).cursor;
            }

        }
    }
    
    return _currentMinCursor;
}

- (void)setCurrentMinCursor:(NSTimeInterval)minCurosr
{
    _currentMinCursor = minCurosr;
}

- (NSTimeInterval)currentMaxCursor
{
    if(_currentMaxCurosr == 0 && [self isCacheEnabled])
    {
        NSMutableOrderedSet * cachedMoments = [self fetchCachedMoments];
        if ([cachedMoments count] > 0) {
            id mom = [cachedMoments lastObject];
            if ([mom isKindOfClass:[ArticleMomentModel class]]) {
                _currentMaxCurosr = ((ArticleMomentModel *)mom).cursor;
            }
        }
    }
    
    // 保护：防止请求到重复数据
    ArticleMomentModel * lastModel = [self.momentSet lastObject];
    if (_currentMaxCurosr > lastModel.cursor) {
        _currentMaxCurosr = lastModel.cursor;
    }
    
    return _currentMaxCurosr;
}

- (void)setCurrentMaxCursor:(NSTimeInterval)maxCursor
{
    _currentMaxCurosr = maxCursor;
}



- (void)startGetMomentWithListID:(NSString *)listID talkID:(NSString *)talkID sourceType:(ArticleMomentSourceType)sourceType minCursor:(NSTimeInterval)minCursor maxCursor:(NSTimeInterval)maxCursor count:(int)count finishBlock:(MomentFinishBlock)block
{
    
    if((minCursor >= 0 && maxCursor >= 0) || (minCursor < 0 && maxCursor < 0))
    {
        SSLog(@"can only specify one and only one as non-zero");
        return;
    }
    
    NSMutableDictionary *getParam = [NSMutableDictionary dictionaryWithCapacity:3];

    BOOL isForumRequest = NO;
    if (sourceType == ArticleMomentSourceTypeForum) {
        isForumRequest = YES;
    }
    
    if (isForumRequest) {
        if (isEmptyString(listID)) {
            NSLog(@"讨论区需要设置forum ID");
            return;
        }
        [getParam setValue:listID forKey:@"forum_id"];
        [getParam setValue:talkID forKey:@"talk_id"];
    }
    else {
        [getParam setValue:listID forKey:@"user_id"];
    }
    
    [getParam setValue:@(sourceType) forKey:@"source"];
    
    BOOL isLoadMore = NO;
    
    if(minCursor >= 0)
    {
        getParam[@"min_cursor"] = @(minCursor);
    }
    else if(maxCursor >= 0)
    {
        getParam[@"max_cursor"] = @(maxCursor);
        isLoadMore = YES;
    }
    
    [getParam setValue:@([TTUIResponderHelper screenResolution].width) forKey:@"screen_width"];
    
    getParam[@"count"] = @(count);
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting momentListURLString] params:getParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSMutableArray *moments = nil;
        NSArray *changeList = nil;
        NSDictionary * tipDict = nil;
        BOOL hasMore = NO;
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        if(!error)
        {
            moments = [NSMutableArray arrayWithCapacity:10];
            
            NSDictionary * resultDict = jsonObj;
            NSDictionary * data = [resultDict dictionaryValueForKey:@"data" defalutValue:nil];
            
            
            NSArray * momentData= [data arrayValueForKey:@"data" defaultValue:nil];
            changeList = [data arrayValueForKey:@"change_list" defaultValue:nil];
            hasMore = [data integerValueForKey:@"has_more" defaultValue:0] != 0 ? YES : NO;
            
            tipDict = [data dictionaryValueForKey:@"tips" defalutValue:nil];
            
            
            for(NSDictionary *dict in momentData)
            {
                if (![ArticleMomentHelper momentDictValid:dict]) {
                    continue;
                }
                ArticleMomentModel *moment = [[ArticleMomentModel alloc] initWithDictionary:dict];
                if (moment.cursor == 0) {
                    ArticleMomentModel *lastObj = [moments lastObject];
                    moment.cursor = lastObj.cursor;
                }
                [moments addObject:moment];
            }
            
            if(!isLoadMore && hasMore)
            {
                [self removeAllMoments];
            }
            // 重复的动态，移除老的，保留新的
            [_momentSet removeObjectsInArray:moments];
            
            if(isLoadMore)
            {
                [_momentSet addObjectsFromArray:moments];
            }
            else
            {
                [_momentSet insertObjects:moments atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, moments.count)]];
            }
            
            [self sortMomentSet];
            
            [userInfo setValue:@(hasMore) forKey:kArticleMomentUserInfoHasMoreKey];
            if(changeList && changeList.count > 0)
            {
                [userInfo setValue:changeList forKey:kArticleMomentUserInfoChangeListKey];
            }
            
            if (tipDict) {
                [userInfo setValue:tipDict forKey:kArticleMomentUserTipDataKey];
            }
            
            // it's my moment
            NSTimeInterval tMinCursor = [data doubleValueForKey:@"min_cursor" defaultValue:0];
            
            NSTimeInterval tMaxCursor = [data doubleValueForKey:@"max_cursor" defaultValue:0];
            
            
            if([self isCacheEnabled])
            {
                if([self currentMinCursor] < tMinCursor)
                {
                    [self setCurrentMinCursor:tMinCursor];
                }
                
                
                if([self currentMaxCursor] == 0 || [self currentMaxCursor] > tMaxCursor)
                {
                    [self setCurrentMaxCursor:tMaxCursor];
                }
                
                [self syncronizeCache];
                
            }
            else
            {
                if(_currentMinCursor == 0 || _currentMinCursor < tMinCursor)
                {
                    _currentMinCursor = tMinCursor;
                }
                
                if(_currentMaxCurosr == 0 || _currentMaxCurosr > tMaxCursor)
                {
                    _currentMaxCurosr = tMaxCursor;
                }
            }
        }
        _loading = NO;
        if (block) {
            block(moments, userInfo, error);
        }
    }];
    
    _loading = YES;
}

/**
 *  排序
 */
- (void)sortMomentSet
{
    [_momentSet sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id obj1, id obj2) {
        ArticleMomentModel *moment1 = (ArticleMomentModel*)obj1;
        ArticleMomentModel *moment2 = (ArticleMomentModel*)obj2;
        
        if(moment1.cursor > moment2.cursor)
        {
            return NSOrderedAscending;
        }
        else if(moment1.cursor < moment2.cursor)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];

}

- (void)getUpdateNumber:(NSTimer*)timer
{
    
    [self getUpdateNumberSince:[self currentMinCursor] finishBlock:^(int count, SSUserModel * userModel, NSError *error) {
        if(!error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kArticleMomentGetUpdateNumberNotification
                                                                object:self
                                                              userInfo:@{kArticleMomentUpdateNumberKey: @(count),
                                                                         kArticleMomentUpdateUserKey: userModel}];
        }
    }];
}

- (void)getUpdateNumberSince:(NSTimeInterval)cursor finishBlock:(void(^)(int count,SSUserModel * latestUpdateUser, NSError *error))finishBlock
{

    NSMutableDictionary *getParam = [NSMutableDictionary dictionaryWithCapacity:1];
    [getParam setValue:@(cursor) forKey:@"min_cursor"];
   
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting momentUpdateNumberURLString] params:getParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        int count = 0;
        SSUserModel * userModel = [SSUserModel new];
        
        if(!error)
        {
            NSDictionary * resultDict = jsonObj;
            NSDictionary * data = [resultDict dictionaryValueForKey:@"data" defalutValue:nil];
            
            count= [data intValueForKey:@"update_count" defaultValue:0];
            
            if ([data dictionaryValueForKey:@"user" defalutValue:nil]) {
                userModel = [[SSUserModel alloc]initWithDictionary:[data dictionaryValueForKey:@"user" defalutValue:nil]];
                
            }
            
        }
        
        if(finishBlock)
        {
            finishBlock(count,userModel, error);
        }
    }];
}

+ (void)clearMomentCache
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMomentCacheStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)syncronizeCache
{
    if ([_momentSet count] == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMomentCacheStorageKey];
    }
    else {
        NSRange range = NSMakeRange(0, MAX(MIN(20, _momentSet.count) - 1, 0));
        NSMutableOrderedSet * set = [NSMutableOrderedSet orderedSetWithArray:[_momentSet objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]]];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:set];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kMomentCacheStorageKey];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableOrderedSet *)fetchCachedMoments
{
    @try {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kMomentCacheStorageKey];
        if (!data) {
            return nil;
        }
        NSMutableOrderedSet * cachedMoments = [NSMutableOrderedSet orderedSetWithOrderedSet:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        return cachedMoments;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
}

+ (void)postSyncNotificationWithMoment:(ArticleMomentModel *)model commentCount:(NSNumber *)commentCount{
    if (!model) {
        LOGD(@"-----------\n\nmoment must not be nil!!!!\n\n-----------");
        return;
    }
    if (isEmptyString(model.ID) || isEmptyString(model.content)) {
        LOGD(@"-----------\n\nmoment is invalid!!!!\n\n-----------");
        return;
    }
    
//    Comment *comment = [Comment objectForPrimaryKey:model.ID];//根据动态id去数据库里修改点赞数和评论数
//    if (comment) {
//        [comment updateDictWithArticleMomentModel:model commentCount:commentCount];
//    }
//直接在数据库更改
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setValue:model forKey:kArticleMomentModelUserInfoKey];
    [userInfo setValue:commentCount forKey:kArticleMomentModelCommentCountKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kArticleMomentSyncNotification object:nil userInfo:userInfo];
    
    id<FRActionDataProtocol> actionData = [GET_SERVICE(FRActionDataService) modelWithUniqueID:model.ID type:FRActionDataModelTypeComment];
    actionData.hasRead = YES;
    actionData.diggCount = model.diggsCount;
    actionData.hasDigg = model.digged;
    actionData.commentCount = commentCount;
}

@end

////////////////////////////////////////////////////////////////////////

@implementation ArticleMomentManager(ExploreMomentListManagerCategory)

- (BOOL)insertModel:(ArticleMomentModel *)model toIndex:(NSUInteger)index
{
    if (model == nil) {
        return NO;
    }
    
    if (![self.momentSet containsObject:model]) {
        BOOL contain = NO;
        for (ArticleMomentModel * m in _momentSet) {
            if ([m isKindOfClass:[ArticleMomentModel class]] && m.cellType == MomentListCellTypeMoment) {
                if ([m.ID longLongValue] == [model.ID longLongValue]) {
                    contain = YES;
                    break;
                }
            }
        }
        if (!contain) {
            ArticleMomentModel * modelInSet = nil;
            if (index >= [_momentSet count]) {
                modelInSet = [_momentSet lastObject];
            }
            else {
                modelInSet = [_momentSet objectAtIndex:index];
            }
            model.cursor = modelInSet.cursor + 1;
            [self.momentSet addObject:model];
            
            [self sortMomentSet];
            
            return YES;
        }
    }
    return NO;
}

- (void)startLoadMoreWithID:(NSString*)listID listType:(ArticleMomentSourceType)type count:(int)count finishBlock:(MomentFinishBlock)block
{
    [self startGetMomentWithListID:listID talkID:nil sourceType:type minCursor:kInvalidCursor maxCursor:[self currentMaxCursor] count:count finishBlock:block];
}

- (void)startRefreshWithID:(NSString*)listID talkID:(NSString *)talkID listType:(ArticleMomentSourceType)type count:(int)count finishBlock:(MomentFinishBlock)block
{
    [self startGetMomentWithListID:listID talkID:talkID sourceType:type minCursor:[self currentMinCursor] maxCursor:kInvalidCursor count:count finishBlock:block];
}


@end

////////////////////////////////////////////////////////////////////////

@implementation ArticleMomentManager(ExploreMomentBadgeManagerCategory)
/**
 开始周期性的获取更新数，获取成功发出notification
 */
+ (void)startPeriodicalGetUpdateNumber
{
    [[ArticleMomentManager sharedManager] startGetUpdateNumberTimer];
}

+ (void)stopPeriodicalGetUpdateNumber
{
    [[ArticleMomentManager sharedManager] stopGetUpdateNumberTimer];
}
@end

////////////////////////////////////////////////////////////////////////

@implementation ArticleMomentManager(ExploreMomentDetailManagerCategory)
/**
 获取详情, 若在moments列表中，则会更新相应内容
 */
- (void)startGetMomentDetailWithIDs:(NSArray*)momentIDs finishBlock:(MomentFinishBlock)block
{
    if(momentIDs.count == 0)
    {
        SSLog(@"must has moment id");
        return;
    }
    
    
    NSString *momentIDString = [momentIDs componentsJoinedByString:@","];
    
    NSMutableDictionary * getParam = [NSMutableDictionary dictionaryWithCapacity:10];
    [getParam setValue:momentIDString forKey:@"ids"];
    [getParam setValue:@([TTUIResponderHelper screenResolution].width) forKey:@"screen_width"];
    
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting momentDetailListURLString] params:getParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSArray *recvMoments = nil;
        if (!error) {
            NSDictionary *resultDict = jsonObj;
            NSArray * data = [resultDict arrayValueForKey:@"data" defaultValue:nil];
            
            recvMoments = [ArticleMomentModel momentsWithArray:data];
            
            [recvMoments enumerateObjectsUsingBlock:^(ArticleMomentModel *recvMoment, NSUInteger idx, BOOL *stop) {
                if([_momentSet containsObject:recvMoment])
                {
                    NSDictionary *recvData  = [data objectAtIndex:idx];
                    [[_momentSet objectAtIndex:[_momentSet indexOfObject:recvMoment]] updateWithDictionary:recvData];
                }
            }];
            _loading = NO;
        }
        
        if (block)
        {
            block(recvMoments, nil, error);
        }
    }];

    _loading = YES;
}

- (void)startGetMomentDetailWithID:(NSString*)ID sourceType:(ArticleMomentSourceType)sourceType modifyTime:(NSTimeInterval)modifyTime finishBlock:(void(^)(ArticleMomentModel *model, NSError *error))block {
    [self startGetMomentDetailWithID:ID sourceType:sourceType modifyTime:modifyTime isNewMoment:NO finishBlock:block];
}

/**
 获取详情, 若在moments列表中，则会更新相应内容
 modifyTime没有时传0
 */

- (void)startGetMomentDetailWithID:(NSString*)ID sourceType:(ArticleMomentSourceType)sourceType modifyTime:(NSTimeInterval)modifyTime isNewMoment:(BOOL)isNewMoment finishBlock:(void(^)(ArticleMomentModel *model, NSError *error))block
{
    if(isEmptyString(ID))
    {
        SSLog(@"ID cannot be empty");
    }
    
    //根据sourceType指定ID代表的参数
    NSString *paramKeyName;
    id paramValue;
    id paramSource = nil;
    if (sourceType == ArticleMomentSourceTypeArticleDetail) {
        paramKeyName = @"comment_id";
        paramValue = @([ID longLongValue]);
        paramSource = @(5);
    }
    else {
        paramKeyName = @"id";
        paramValue = ID;
    }
    
    NSMutableDictionary *getParam = [NSMutableDictionary dictionaryWithCapacity:2];
    [getParam setValue:paramValue forKey:paramKeyName];
    if (paramSource) {
        [getParam setValue:paramSource forKey:@"source"];
    }
    [getParam setValue:@(modifyTime) forKey:@"modify_time"];
    [getParam setValue:@([TTUIResponderHelper screenResolution].width) forKey:@"screen_width"];
    
    NSString *url = nil;
    if (isNewMoment) {
        if (sourceType == ArticleMomentSourceTypeArticleDetail) {
            url = [ArticleURLSetting commentDetailURLString];
        } else {
            url = [ArticleURLSetting momentDetailURLStringV8];
        }
    } else {
        url = [ArticleURLSetting momentDetailURLString];
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:getParam method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        ArticleMomentModel *resultModel = nil;
        if(!error)
        {
            NSDictionary * resultDict = jsonObj;
            NSDictionary * dict = [resultDict dictionaryValueForKey:@"data" defalutValue:nil];
            
            
            if ([dict isKindOfClass:[NSDictionary class]] && dict.count > 0) {
                resultModel = [[ArticleMomentModel alloc] initWithDictionary:dict];
                if ([resultModel isDeleted]) {
                    [resultModel deleteModelContent];
                }
                if([_momentSet containsObject:resultModel])
                {
                    NSInteger idx = [_momentSet indexOfObject:resultModel];
                    ArticleMomentModel *oldMoment = [_momentSet objectAtIndex:idx];
                    // bug fix:（luohuaqing）后端会传回一个“无用”的“cursor”，需要忽略
                    NSMutableDictionary * mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    [mutDict removeObjectForKey:@"cursor"];
                    ///////////////////////////////////////////////////////////
                    [oldMoment updateWithDictionary:mutDict];
                    resultModel = oldMoment;
                    [_momentSet replaceObjectAtIndex:idx withObject:resultModel];
                }
            }
            
        }
        
        if(block)
        {
            block(resultModel, error);
        }
    }];
}

@end

@implementation ArticleMomentManager(ExploreCommentModelCategory)

- (void)tryCacheMomentModelWithCommentId:(NSNumber *)commentId
{
    if ([self getMomentModelWithCommentId:commentId] == nil) {
        int64_t commentIdValue = [commentId longLongValue];
        [self startGetMomentDetailWithID:[@(commentIdValue) stringValue]
                              sourceType:ArticleMomentSourceTypeArticleDetail
                              modifyTime:0
                             finishBlock:^(ArticleMomentModel *model, NSError *error) {
                                 if (model && !error) {
                                     [self.commentToMomentCache setObject:model forKey:commentId];
                                 }
                             }];
    }
}

- (ArticleMomentModel *)getMomentModelWithCommentId:(NSNumber *)commentId
{
    ArticleMomentModel *momentModel = [self.commentToMomentCache objectForKey:commentId];
    return momentModel;
}

@end


