//
//  TSVCategoryManager.m
//  Article
//
//  Created by 王双华 on 2017/10/29.
//

#import "TSVCategoryManager.h"
#import "TTBaseMacro.h"
#import <Crashlytics/Crashlytics.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import "CommonURLSetting.h"

@implementation TSVCategoryManager

static TSVCategoryManager *s_manager;
static NSArray *s_localDefaultCategories;

+ (TSVCategoryManager*)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[TSVCategoryManager alloc] init];
    });
    return s_manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setCurrentSelectedCategoryID:kTTUGCVideoCategoryID];
    }
    return self;
}

+ (void)initialize
{
    [TTEntityBase disableBackupForPath:[TSVCategory dbName]];
    [self insertDefaultData];
}

//查询
+ (TSVCategory *)categoryModelByCategoryID:(NSString *)categoryID
{
    if (isEmptyString(categoryID)) {
        return nil;
    }
    
    TSVCategory *result = nil;
    
    NSArray *categories = [TSVCategory objectsWithQuery:@{@"categoryID":categoryID, @"topCategoryType" : @(TTCategoryModelTopTypeShortVideo)}
                                                    orderBy:@"orderIndex ASC"
                                                     offset:0
                                                      limit:NSIntegerMax];
    
    if ([categories count] > 0) result = [categories objectAtIndex:0];
    return result;
}

//插入
+ (TSVCategory *)insertCategoryWithDictionary:(NSDictionary *)dict
{
    // 确保dict中包含ID和Name
    TSVCategory *result = nil;
    NSString *categoryID = dict[@"category"];
    NSString *categoryName = dict[@"name"];
    
    if (!isEmptyString(categoryID) && !isEmptyString(categoryName)) {
        result = [TSVCategory objectWithDictionary:dict];
        [result save];
    }
    return result;
}

- (NSArray <TSVCategory *> *)localCategories;
{
    NSArray *result = [TSVCategory objectsWithQuery:@{@"topCategoryType" : @(TTCategoryModelTopTypeShortVideo)}
                                            orderBy:@"orderIndex ASC"
                                             offset:0
                                              limit:NSIntegerMax];
    if ([result count] == 1) {//数据库只有一个推荐频道时，返回本地默认频道
        return s_localDefaultCategories;
    } else {
        return result;
    }
}

- (void)fetchCategoriesFromRemote:(TSVCategoryManagerRequestFinishBlock)finishBlock
{
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting shortVideoCategoryURLString] params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error) {
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                NSArray *categories = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_arrayValueForKey:@"data"];
                if (finishBlock) {
                    finishBlock([self generateAndSaveCategoriesWithDataDicts:categories]);
                }
            }
        }
    }];
}

- (NSArray *)generateAndSaveCategoriesWithDataDicts:(NSArray *)dataDicts
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
        
        NSArray *insertedCategories = [TSVCategory insertObjectsWithDataArray:validDicts];
        
        [insertedCategories enumerateObjectsUsingBlock:^(TSVCategory *obj, NSUInteger idx, BOOL *stop) {
            obj.topCategoryType = TTCategoryModelTopTypeShortVideo;
            obj.orderIndex = idx+1;
            [obj save];
            
            if ([obj.categoryID isEqualToString:kTTUGCVideoCategoryID]) {
                hasVideo = YES;
            }
        }];
        
        [videoCategories addObjectsFromArray:insertedCategories];
        
        //推荐频道固定插入第一位
        if (!hasVideo) {
            TSVCategory *mainCategory = [[self class] mainCategory];
            if (mainCategory) {
                [videoCategories insertObject:mainCategory atIndex:0];
            }
        }
        
    }
    return videoCategories;
}

+ (TSVCategory *)mainCategory
{
    TSVCategory *mainCategory = [self insertCategoryForName:NSLocalizedString(@"推荐",nil) categoryID:@"hotsoon_video" concernID:@"" orderIndex:@0 subscribed:NO categoryType:TTFeedListDataTypeShortVideo categoryTopType:TTCategoryModelTopTypeShortVideo save:YES];
    return mainCategory;
}

+ (void)insertDefaultData
{
    NSUInteger categoryOrderIndex = 1;
    
    //视频频道默认数据
    NSArray *videoCategories = @[
                                 @{@"category":@"ugc_video_local",
                                   @"name":NSLocalizedString(@"同城",nil),
                                   @"type":@(TTFeedListDataTypeShortVideo)},
                                 @{@"category":@"ugc_video_casual",
                                   @"name":NSLocalizedString(@"自拍", nil),
                                   @"type":@(TTFeedListDataTypeShortVideo)},
                                 @{@"category":@"ugc_video_cute",
                                   @"name":NSLocalizedString(@"呆萌", nil),
                                   @"type":@(TTFeedListDataTypeShortVideo)},
                                 @{@"category":@"ugc_video_funny",
                                   @"name":NSLocalizedString(@"搞笑", nil),
                                   @"type":@(TTFeedListDataTypeShortVideo)},
                                 @{@"category":@"ugc_video_dance",
                                   @"name":NSLocalizedString(@"舞蹈",nil),
                                   @"type":@(TTFeedListDataTypeShortVideo)},
                                 ];
    
    NSMutableArray *defaultCategories = [NSMutableArray arrayWithCapacity:videoCategories.count];
    [defaultCategories addObject:[self mainCategory]];///添加推荐频道
    for (int i = 0; i < [videoCategories count]; i++) {
        NSString * name = [[videoCategories objectAtIndex:i] objectForKey:@"name"];
        NSString * category = [[videoCategories objectAtIndex:i] objectForKey:@"category"];
        TTFeedListDataType type = [[[videoCategories objectAtIndex:i] objectForKey:@"type"] intValue];
        
        TSVCategory *tsvCategory = [self insertCategoryForName:name categoryID:category concernID:@"" orderIndex:@(categoryOrderIndex) subscribed:NO categoryType:type categoryTopType:TTCategoryModelTopTypeShortVideo save:NO];
        [defaultCategories addObject:tsvCategory];
        categoryOrderIndex ++;
    }
    s_localDefaultCategories = [defaultCategories copy];
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
+ (TSVCategory *)insertCategoryForName:(NSString *)categoryName
                            categoryID:(NSString *)cID
                             concernID:(NSString *)concernID
                            orderIndex:(NSNumber *)index
                            subscribed:(BOOL)subscribed
                          categoryType:(TTFeedListDataType)type
                                  save:(BOOL)save
{
    return [self insertCategoryForName:categoryName
                            categoryID:cID
                             concernID:concernID
                            orderIndex:index
                            subscribed:subscribed
                          categoryType:type
                       categoryTopType:TTCategoryModelTopTypeShortVideo
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
+ (TSVCategory *)insertCategoryForName:(NSString *)categoryName
                            categoryID:(NSString *)cID
                             concernID:(NSString *)concernID
                            orderIndex:(NSNumber *)index
                            subscribed:(BOOL)subscribed
                          categoryType:(TTFeedListDataType)type
                       categoryTopType:(TTCategoryModelTopType)topType
                                  save:(BOOL)save
{
    if (isEmptyString(categoryName) || isEmptyString(cID) || !index) {
        return nil;
    }
    NSDictionary *data = @{@"name":categoryName,
                           @"category":cID,
                           @"concern_id":concernID,
                           @"order_index":index,
                           @"subscribed":@(subscribed),
                           @"type":@(type),
                           @"topCategoryType":@(topType),
                           };
    
    TSVCategory *category = [TSVCategory objectWithDictionary:data];
    if (save) {
        [category save];
    }
    return category;
}

@end

