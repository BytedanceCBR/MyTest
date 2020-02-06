//
//  VideoCategoryManager.m
//  Article
//
//  Created by xuzichao on 16-7-25.
//
//
/*
 1. 用户每次有网就去网络返回，没网就去本地值，保证推荐在前面
 */

#import "TTVideoCategoryManager.h"
#import "TTBaseMacro.h"
#import "Crashlytics.h"

@implementation TTVideoCategoryManager

static TTVideoCategoryManager *s_manager;

+ (TTVideoCategoryManager*)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[TTVideoCategoryManager alloc] init];
    });
    return s_manager;
}


+ (void)initialize
{
    [TTEntityBase disableBackupForPath:[TTVideoCategory dbName]];
    [self insertDefaultData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- public

//查询
+ (TTVideoCategory *)categoryModelByCategoryID:(NSString *)categoryID
{
    if (isEmptyString(categoryID)) {
        return nil;
    }
    
    TTVideoCategory *result = nil;
    
    NSArray *categories = [TTVideoCategory objectsWithQuery:@{@"categoryID":categoryID, @"topCategoryType" : @(TTCategoryModelTopTypeVideo)}
                                                    orderBy:@"orderIndex ASC"
                                                     offset:0
                                                      limit:NSIntegerMax];
    
    if ([categories count] > 0) result = [categories objectAtIndex:0];
    return result;
}

//插入
+ (TTVideoCategory *)insertCategoryWithDictionary:(NSDictionary *)dict
{
    // 确保dict中包含ID和Name
    TTVideoCategory *result = nil;
    NSString *categoryID = dict[@"category"];
    NSString *categoryName = dict[@"name"];
    
    if (!isEmptyString(categoryID) && !isEmptyString(categoryName)) {
        result = [TTVideoCategory objectWithDictionary:dict];
        [result save];
    }
    return result;
}

- (NSArray *)videoCategoriesWithDataDicts:(NSArray *)dataDicts
{
    NSMutableArray *videoCategories = [NSMutableArray arrayWithCapacity:0];
    
    // 检查关键字段是否存在，过滤无效数据
    NSMutableArray *validDicts = nil;
    
    if ([dataDicts isKindOfClass:[NSArray class]] && [dataDicts count] > 0) {
        validDicts = [NSMutableArray arrayWithCapacity:[dataDicts count]];
        [dataDicts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([[obj objectForKey:@"category"] isKindOfClass:[NSString class]]) {
                    [validDicts addObject:obj];
                } else {
                    [Answers logCustomEventWithName:@"InvalidVideoCategory" customAttributes:obj];
                }
            } else {
                [Answers logCustomEventWithName:@"InvalidVideoCategory" customAttributes:@{@"reason" : @"notDict"}];
            }
        }];
    }
    
    if ([validDicts count] > 0)
    {
        __block bool hasVideo = NO;
        __block bool hasFollow = NO;

        [TTVideoCategory removeAllEntities];
        NSArray *insertedCategories = [TTVideoCategory insertObjectsWithDataArray:validDicts];

        [insertedCategories enumerateObjectsUsingBlock:^(TTVideoCategory *obj, NSUInteger idx, BOOL *stop) {
            obj.topCategoryType = TTCategoryModelTopTypeVideo;
            obj.orderIndex = idx;
            [obj save];

            if ([obj.categoryID isEqualToString:kTTVideoCategoryID]) {
                hasVideo = YES;
            }
            if ([obj.categoryID isEqualToString:kTTFollowCategoryID]) {
                hasFollow = YES;
            }
        }];

        [videoCategories addObjectsFromArray:insertedCategories];

        //推荐频道固定插入第一位
        if (!hasVideo) {
            TTVideoCategory *mainCategory = [self videoMainCategory];
            if (!mainCategory) {
                mainCategory = [TTVideoCategoryManager insertMainCategory];
            }
            if (mainCategory) {
                if (hasFollow) {
                    [videoCategories insertObject:mainCategory atIndex:1];
                } else {
                    [videoCategories insertObject:mainCategory atIndex:0];
                }

                // 更新orderIndex
                [videoCategories enumerateObjectsUsingBlock:^(TTVideoCategory *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.orderIndex = idx;
                    [obj save];
                }];
            }
        }
        
    } else {
        //无网络数据，获取本地频道（默认或上次获取的数据）
        [videoCategories addObjectsFromArray:[self localVideoCategories]];
    }

    return videoCategories;
}

- (NSArray *)localVideoCategories
{
    NSArray *result = [TTVideoCategory objectsWithQuery:@{@"topCategoryType" : @(TTCategoryModelTopTypeVideo)}
                                                orderBy:@"orderIndex ASC"
                                                 offset:0
                                                  limit:NSIntegerMax];
    return result;
}

+ (TTVideoCategory *)insertMainCategory {
    return [self insertCategoryWithDictionary:@{@"category":@"video",
                                                    @"name":NSLocalizedString(@"推荐",nil),
                                                    @"type":@(TTFeedListDataTypeArticle),
                                              @"concern_id":@"",
                                              @"subscribed":@(NO),
                                             @"order_index":@(0),
                                         @"topCategoryType":@(TTCategoryModelTopTypeVideo)}];
}


- (TTVideoCategory *)videoMainCategory
{
    NSArray *mainCategory = [TTVideoCategory objectsWithQuery:@{@"categoryID" : kTTVideoCategoryID}];
    
    if ([mainCategory count] > 0) {
        return [mainCategory firstObject];
    }
    return nil;
}

static NSString *s_currentSelectedCategoryID;

+ (NSString*)currentSelectedCategoryID
{
    return s_currentSelectedCategoryID;
}

+ (void)setCurrentSelectedCategoryID:(NSString*)categoryID
{
    s_currentSelectedCategoryID = categoryID;
}

@end


@implementation TTVideoCategoryManager(InsertDefaultCategory)

+ (void)insertDefaultData
{
    TTVideoCategory *result = [TTVideoCategory objectForPrimaryKey:kTTVideoCategoryID];
    if (result) { // 有数据，就不需要插入了
        return;
    }

    NSUInteger categoryOrderIndex = 0;
    
        //视频频道默认数据
    NSArray *videoCategories = @[@{@"category":@"video",             @"name":NSLocalizedString(@"推荐",nil),      @"type":@(TTFeedListDataTypeArticle)},
                                 @{@"category":@"subv_funny",        @"name":NSLocalizedString(@"逗比剧", nil),   @"type":@(TTFeedListDataTypeArticle)},
                                 @{@"category":@"subv_society",      @"name":NSLocalizedString(@"社会", nil),     @"type":@(TTFeedListDataTypeArticle)},
                                 @{@"category":@"subv_cute",         @"name":NSLocalizedString(@"呆萌", nil),     @"type":@(TTFeedListDataTypeArticle)},
                                 @{@"category":@"subv_entertainment",@"name":NSLocalizedString(@"娱乐", nil),     @"type":@(TTFeedListDataTypeArticle)},
                                 @{@"category":@"subv_life",         @"name":NSLocalizedString(@"生活", nil),     @"type":@(TTFeedListDataTypeArticle)},
                                 @{@"category":@"subv_comedy",       @"name":NSLocalizedString(@"小品", nil),     @"type":@(TTFeedListDataTypeArticle)}
                                 ];
#if 0
    if ([TTDeviceHelper isPadDevice]) {
        videoCategories = @[@{@"category":@"video",             @"name":NSLocalizedString(@"推荐",nil),      @"type":@(TTFeedListDataTypeArticle)},
                            @{@"category":@"subv_funny",        @"name":NSLocalizedString(@"逗比剧", nil),   @"type":@(TTFeedListDataTypeArticle)},
                            @{@"category":@"subv_society",      @"name":NSLocalizedString(@"社会", nil),     @"type":@(TTFeedListDataTypeArticle)},
                            @{@"category":@"subv_cute",         @"name":NSLocalizedString(@"呆萌", nil),     @"type":@(TTFeedListDataTypeArticle)},
                            @{@"category":@"subv_entertainment",@"name":NSLocalizedString(@"娱乐", nil),     @"type":@(TTFeedListDataTypeArticle)},
                            @{@"category":@"subv_life",         @"name":NSLocalizedString(@"生活", nil),     @"type":@(TTFeedListDataTypeArticle)},
                            @{@"category":@"subv_comedy",       @"name":NSLocalizedString(@"小品", nil),     @"type":@(TTFeedListDataTypeArticle)}
                            ];
    }
#endif
    
    for (int i = 0; i < [videoCategories count]; i++) {
        NSString * name = [[videoCategories objectAtIndex:i] objectForKey:@"name"];
        NSString * category = [[videoCategories objectAtIndex:i] objectForKey:@"category"];
        TTFeedListDataType type = [[[videoCategories objectAtIndex:i] objectForKey:@"type"] intValue];
        
        [self insertCategoryForName:name categoryID:category concernID:@"" orderIndex:@(categoryOrderIndex) subscribed:NO categoryType:type categoryTopType:TTCategoryModelTopTypeVideo save:NO];
        
        categoryOrderIndex ++;
    }
}

#pragma mark -- private util

/**
 *  插入视频频道
 *
 *  @param categoryName 频道名字
 *  @param cID          频道 ID
 *  @param concernID    关心 ID
 *  @param index        频道位置
 *  @param subscribed   是否订阅
 *  @param type         频道类型
 *  @param save         是否保存
 */
+ (void)insertCategoryForName:(NSString *)categoryName
                   categoryID:(NSString *)cID
                    concernID:(NSString *)concernID
                   orderIndex:(NSNumber *)index
                   subscribed:(BOOL)subscribed
                 categoryType:(TTFeedListDataType)type
                         save:(BOOL)save
{
    [self insertCategoryForName:categoryName
                     categoryID:cID
                      concernID:concernID
                     orderIndex:index
                     subscribed:subscribed
                   categoryType:type
                categoryTopType:TTCategoryModelTopTypeVideo
                           save:save];
}

/**
 *  插入频道
 *
 *  @param categoryName 频道名字
 *  @param cID          频道 ID
 *  @param concernID    关心 ID
 *  @param index        频道位置
 *  @param subscribed   是否订阅
 *  @param type         二级频道类型
 *  @param topType      一级频道类型
 *  @param save         是否保存
 */
+ (void)insertCategoryForName:(NSString *)categoryName
                   categoryID:(NSString *)cID
                    concernID:(NSString *)concernID
                   orderIndex:(NSNumber *)index
                   subscribed:(BOOL)subscribed
                 categoryType:(TTFeedListDataType)type
              categoryTopType:(TTCategoryModelTopType)topType
                         save:(BOOL)save
{
    if (isEmptyString(categoryName) || isEmptyString(cID) || !index) {
        return;
    }
    NSDictionary *data = @{@"name":categoryName,
                           @"category":cID,
                           @"concern_id":concernID,
                           @"order_index":index,
                           @"subscribed":@(subscribed),
                           @"type":@(type),
                           @"topCategoryType":@(topType)
                           };
    
    TTVideoCategory *category = [TTVideoCategory objectWithDictionary:data];
    [category save];
}

@end
