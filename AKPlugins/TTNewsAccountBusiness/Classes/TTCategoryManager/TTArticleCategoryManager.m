//
//  TTArticleCategoryManager.m
//  Article
//
//  Created by Dianwei on 12-12-18.
//
//
/*
 1. 新用户第一次启动，使用推荐频道+默认频道+自动频道做为用户订阅的频道， 其他频道作为更多频道，无更新提示。
 2. 老用户第一次启动，及用户再次启动，使用推荐频道+本地已经订阅的频道+本地没有插入过的自动频道, 新增加的非自动频道如果tip_new为YES，则该频道提示更新
 3. 有提示的频道排在 “更多频道”的开头，其他的频道根据json返回的顺序。
 4. 退出频道管理后， 清除所有频道的tip_new属性。
 5. 客户端内置频道改为3个， 推荐， 热门， 本地
 */

#import "TTArticleCategoryManager.h"
#import <TTBaseLib/JSONAdditions.h>
//#import "SSCommonLogic.h"
#import "NetworkUtilities.h"
//#import "TTLocationManager.h"
//#import "TTInfoHelper.h"
#import "TTSandBoxHelper.h"
#import "TTDeviceHelper.h"
#import "TTNetworkManager.h"
#import "TTURLDomainHelper.h"
#import "TTAccountBusiness.h"

NSString *const kTTInsertCategoryToLastPositionNotification = @"kInsertCategoryToLastPositionNotification";
NSString *const kTTInsertCategoryNotificationCategoryKey = @"kInsertCategoryNotificationCategoryKey";
NSString *const kTTInsertCategoryNotificationPositionKey          = @"kInsertCategoryNotificationPositionKey";

@interface TTArticleCategoryManager()
<
TTAccountMulticastProtocol
>
@property(nonatomic, strong)NSMutableArray *allCategories;
@property(nonatomic, strong)NSMutableArray *preFixedCategories;
@property(nonatomic, strong)NSMutableArray *articleCategories;
@property(nonatomic, strong)NSMutableArray *essayCatgegories;
@property(nonatomic, strong)NSMutableArray *imageCategories;
@property(nonatomic, strong)NSMutableArray *subScribedCategories;
@property(nonatomic, strong)NSMutableArray *webCategories;
@property(nonatomic, strong)TTCategory *localCategory;
@property(nonatomic, strong)NSMutableArray *subscribeEntryCategories;//4.3新增，为entry频道， 目前只有一个

@property(nonatomic, copy)TTArticleCategoryManagerIARBlock iarBlock;
@property(nonatomic, copy)TTArticleCategoryManagerCityBlock cityBlock;
@property(nonatomic, copy)TTArticleCategoryManagerSysLocationBlock sysLocationBlock;

@end

@implementation TTArticleCategoryManager

static TTArticleCategoryManager *s_manager;
static TTCategory *s_mainCategoryModel = nil;
BOOL __hasInsertedDefaultData = NO;

+ (void)initialize
{
    [TTEntityBase disableBackupForPath:[TTCategory dbName]];
}

+ (TTArticleCategoryManager*)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[TTArticleCategoryManager alloc] init];
    });
    return s_manager;
}

#pragma mark -- public

+ (TTCategory *)mainArticleCategory
{
    if (!s_mainCategoryModel) {
        s_mainCategoryModel = [self checkDBAndReturnMainCategory];
    }
    return s_mainCategoryModel;
}

+ (TTCategory *)checkDBAndReturnMainCategory
{
    TTCategory *mainCategory = [TTCategory objectForPrimaryKey:kTTMainCategoryID];
    if (!mainCategory) {
        [self insertDefaultData];
    }
    return mainCategory;
}

+ (TTCategory *)categoryModelByCategoryID:(NSString *)categoryID
{
    if (isEmptyString(categoryID)) {
        return nil;
    }
    
    TTCategory *result = [TTCategory objectForPrimaryKey:categoryID];
    return result;
}


+ (TTCategory *)insertCategoryWithDictionary:(NSDictionary *)dict
{
    // 确保dict中包含ID和Name
    TTCategory *result = nil;
    NSString *categoryID = dict[@"category"];
    NSString *categoryName = dict[@"name"];
    
    if (!isEmptyString(categoryID) && !isEmptyString(categoryName)) {
        result = [TTCategory objectWithDictionary:dict];
        [result save];
    }
    return result;
}

+ (TTCategory *)newsLocalCategory
{
    TTCategory *result = [TTCategory objectForPrimaryKey:kTTNewsLocalCategoryID];
    return result;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.subscribeEntryCategories = [NSMutableArray arrayWithCapacity:20];
        self.allCategories = [NSMutableArray arrayWithCapacity:20];
        self.articleCategories = [NSMutableArray arrayWithCapacity:20];
        self.webCategories = [NSMutableArray arrayWithCapacity:20];
        self.imageCategories = [NSMutableArray arrayWithCapacity:20];
        self.essayCatgegories = [NSMutableArray arrayWithCapacity:20];
        self.subScribedCategories = [NSMutableArray arrayWithCapacity:20];
        self.preFixedCategories = [NSMutableArray arrayWithCapacity:20];
        
        [[self class] insertDefaultDataIfNeeded];
        
        [self dispatchData:[self localCategoriesContainDeleteCategory:NO]];
        
        [TTAccount addMulticastDelegate:self];
    }
    
    return self;
}

#pragma mark - url

- (NSString *)subscribedCategoryURLString
{
    NSString *domain = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
    return [NSString stringWithFormat:@"%@/category/get_light/1/", domain];
}

- (NSString *)unsubscribedCategoryURLString
{
    NSString *domain = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
    return [NSString stringWithFormat:@"%@/article/category/get_extra/v1/", domain];
}

#pragma mark - TTAccountProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
//    [self startGetCategory];
}

- (void)startGetUnsubscribedCategory
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[[self class] fetchGetCategoryVersion] forKey:@"version"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[self unsubscribedCategoryURLString]
                                                      params:params
                                                      method:@"GET"
                                            needCommonParams:YES
                                                    callback:^(NSError *error, id jsonObj) {
                                                        if (!error) {
                                                            NSArray *tmpData = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_arrayValueForKey:@"data"];
                                                            if (!SSIsEmptyArray(tmpData)) {
                                                                NSMutableArray *categoryData = [NSMutableArray arrayWithCapacity:0];
                                                                
                                                                //如果新获取的是未订阅频道，就和已获取的 左侧固定频道 以及 订阅频道 拼起来
                                                                //拼接推荐频道左侧的固定频道
                                                                for (TTCategory * model in self.preFixedCategories) {
                                                                    NSDictionary *data = [model dictionary];
                                                                    [categoryData addObject:data];
                                                                }
                                                                //拼接订阅频道
                                                                for (TTCategory *model in self.subScribedCategories) {
                                                                    NSDictionary *data = [model dictionary];
                                                                    [categoryData addObject:data];
                                                                }
                                                                [categoryData addObjectsFromArray:tmpData];
                                                                
                                                                //同一个频道重复出现订阅和未订阅的情况，需要过滤未订阅的那项数据，categoryData合成的时候需要保证：订阅在前，未订阅在后
                                                                [self rebuildAllCategoriesWithDataDicts:categoryData];
                                                            }
                                                        }
                                                        
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:kAritlceCategoryGotFinishedNotification object:nil];
                                                    }];
}

- (void)startGetCategory
{
    [self startGetCategory:NO];
}

- (void)startGetCategory:(BOOL)userChanged
{
    [self dispatchData:[self localCategoriesContainDeleteCategory:NO]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    
    TTCategory *newsLocalCategory = [TTArticleCategoryManager newsLocalCategory];
    //用户选择过城市，发送给服务端
    if (newsLocalCategory && [TTArticleCategoryManager isUserSelectedLocalCity]) {
        [params setValue:newsLocalCategory.name forKey:@"user_city"];
    }
    //location 发送给城市
//    CLLocationCoordinate2D coordinate = [TTLocationManager sharedManager].placemarkItem.coordinate;
//    if(coordinate.longitude * coordinate.latitude > 0) {
//        [params setValue:@(coordinate.latitude) forKey:@"latitude"];
//        [params setValue:@(coordinate.longitude) forKey:@"longitude"];
//    }
    
    if (_sysLocationBlock) {
        NSString *location = _sysLocationBlock();
        NSArray *coords = [location componentsSeparatedByString:@","];
        if (coords.count == 2) {
            double lon = [coords[0] doubleValue];
            double lat = [coords[1] doubleValue];
            if (lon * lat > 0) {
                [params setValue:@(lat) forKey:@"latitude"];
                [params setValue:@(lon) forKey:@"longitude"];
            }
        }
    }
    
    //gps 城市
    if (_cityBlock) {
        NSString *city = _cityBlock();//[TTLocationManager sharedManager].city;
        [params setValue:city forKey:@"city"];
    }
    
    //服务端返回的城市
    [params setValue:[TTArticleCategoryManager latestServerLocalCity] forKey:@"server_city"];
    
    //version
    [params setValue:[[self class] fetchGetCategoryVersion] forKey:@"version"];
    
    //categories
    NSString * categorysStr = [self fetchGetCategoryCategoryIDs];
    [params setValue:categorysStr forKey:@"categories"];

    NSString * preFixedCategoryIDStr = [self fetchGetPrefixedCategoryCategoryIDs];
    [params setValue:preFixedCategoryIDStr forKey:@"pre_categories"];
    
    if ([categorysStr isEqualToString:@"[\n\n]"]) {
        [params setValue: @"0" forKey:@"version"];
    }
    
    //是否用户主动修改
    [params setValue:@(userChanged) forKey:@"user_modify"];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[self subscribedCategoryURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        if (!error) {
            NSArray *tmpData = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_arrayValueForKey:@"data"];
            if (!SSIsEmptyArray(tmpData)) {
                NSMutableArray *categoryData = [NSMutableArray arrayWithCapacity:0];
                [TTArticleCategoryManager setHasGotRemoteData];
                
                NSString * remoteVersion = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"version"];
                [[self class] setGetCategoryVersion:remoteVersion];
                
                NSArray * tmpPreFixedData = [[self class] preFixedDataPreOperate:[[jsonObj tt_dictionaryValueForKey:@"data"] tt_arrayValueForKey:@"pre_data"]];
                if (tmpPreFixedData.count > 0) {
                    [categoryData addObjectsFromArray:tmpPreFixedData];
                }
                [categoryData addObjectsFromArray:tmpData];
                
                //如果已经获取过未订阅频道，则和新获取的订阅频道拼起来
                for (TTCategory *model in self.unsubscribeCategories) {
                    NSDictionary *data = [model dictionary];
                    [categoryData addObject:data];
                }
                //同一个频道重复出现订阅和未订阅的情况，需要过滤未订阅的那项数据，categoryData合成的时候需要保证：订阅在前，未订阅在后
                [self rebuildAllCategoriesWithDataDicts:categoryData];
                
                if (self.completionRequest) {
                    self.completionRequest(YES);
                }
            }
        }else
        {
            if (self.completionRequest) {
                self.completionRequest(NO);
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAritlceCategoryGotFinishedNotification object:nil];
    }];
}

- (void)startGetCategoryWithCompleticon:(void(^)(BOOL isSuccess))completion
{
    self.completionRequest = completion;
    [self startGetCategory];
}


- (void)clearCategoryTipNewWithSave:(BOOL)save
{
    for (TTCategory * model in self.allCategories) {
        if (model.tipNew) {
            model.tipNew = NO;
            [model save];
        }
    }
    
    if (save) {
        [self saveWithNotify:NO];
    }
}

- (void)updateSubScribedCategoriesOrderIndex
{
    [self.subScribedCategories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TTCategory *c1 = (TTCategory *)obj1;
        TTCategory *c2 = (TTCategory *)obj2;
        //return [c1.orderIndex compare:c2.orderIndex];
        if (c1.orderIndex < c2.orderIndex) return NSOrderedAscending;
        if (c1.orderIndex > c2.orderIndex) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

- (NSArray *)localCategoriesContainDeleteCategory:(BOOL)containDelete
{
    NSDictionary * queryDict = nil;
    if (!containDelete) {
        queryDict = @{
                      @"ttDeleted" : @(0),
                      @"topCategoryType" : @(TTCategoryModelTopTypeNews)
                      };
    } else {
        queryDict = @{
                      @"topCategoryType" : @(TTCategoryModelTopTypeNews)
                      };
    }
    
    NSArray *result = [TTCategory objectsWithQuery:queryDict orderBy:@"subscribed DESC, orderIndex ASC" offset:0 limit:NSIntegerMax];
    return result;
}

- (NSArray *)localPhotoCategories
{
    NSArray *otherPhotoCategories = [TTCategory objectsWithQuery:@{@"listDataType" : @(TTFeedListDataTypeImage)} orderBy:@"orderIndex ASC" offset:0 limit:NSIntegerMax];
    
    NSMutableArray *photoCategories = [NSMutableArray arrayWithArray:otherPhotoCategories];
    
    TTCategory *mainPhotoCategory = [self photoMainCategory];
    if (mainPhotoCategory) {
        mainPhotoCategory.name = @"图集";
        [photoCategories insertObject:mainPhotoCategory atIndex:0];
    }
    
    if ([self iar]) {
        for (TTCategory *model in photoCategories) {
            if ([model.categoryID isEqualToString:@"image_wonderful"]) {
                return @[model];
            }
        }
    }
    
    return photoCategories;
}

- (BOOL)iar
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"SSCommonLogicSettingIarKey"]) {
        return [[userDefaults objectForKey:@"SSCommonLogicSettingIarKey"] boolValue];
    }
    return NO;
}

- (TTCategory *)photoMainCategory
{
    TTCategory *topPhotoCategory = [TTCategory objectForPrimaryKey:@"组图"];
    return topPhotoCategory;
}

- (void)rebuildAllCategoriesWithDataDicts:(NSArray *)dataDicts
{
    // by zjing,放出服务端config下发的频道
//    return;
    
    NSMutableArray * fixedData = [NSMutableArray arrayWithCapacity:10];
    NSMutableSet * remoteDataCategoryID = [NSMutableSet setWithCapacity:10];    //远端返回的所有categoryID
    NSMutableSet * remotePreFixCategoryIDs = [NSMutableSet setWithCapacity:10]; //远端返回的左侧固定频道的categoryID
    NSMutableSet * remoteSubscribedCategoryIDs = [NSMutableSet setWithCapacity:100];//远端返回的订阅的categoryID
    int orderIndex = 0;
    BOOL preFixedCategoryEnumerEnd = NO; //左侧固定频道是否遍历完
    for (NSInteger index = 0;index < dataDicts.count;index++) {
        NSDictionary *dic = [dataDicts objectAtIndex:index];
        if (dic != nil) {
            //一次返回内消重(对category字段消重，防止服务端bug)
            NSString *categoryID = [dic tt_stringValueForKey:@"category"];
            if (isEmptyString(categoryID) ||
                [remoteDataCategoryID containsObject:categoryID] ||
                [categoryID isEqualToString:kTTMainCategoryID]) {
                continue;
            }
            [remoteDataCategoryID addObject:categoryID];
            
            BOOL isPreFixed = [dic tt_boolValueForKey:@"isPreFixedCategory"];
            BOOL subscribed = [dic tt_boolValueForKey:@"default_add"];
            if (isPreFixed && NO == preFixedCategoryEnumerEnd) {
                //左侧固定频道
                [remotePreFixCategoryIDs addObject:categoryID];
            }else {
                if (NO == preFixedCategoryEnumerEnd) {
                    preFixedCategoryEnumerEnd = YES;
                    orderIndex += 1; //+1因为推荐频道
                }
                if (subscribed) {
                    //订阅频道
                    [remoteSubscribedCategoryIDs addObject:categoryID];
                }
            }
            
            NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [tmpDic setValue:@(orderIndex) forKey:@"order_index"];
            [tmpDic setValue:@(subscribed) forKey:@"subscribed"];//根据default_add来决定是否订阅
            [tmpDic setValue:@(isPreFixed) forKey:@"isPreFixedCategory"];
            [fixedData addObject:tmpDic];
            
            //保存服务器返回的本地城市名
            if ([categoryID isEqualToString:kTTNewsLocalCategoryID]) {
                NSString *serverCityName = [dic objectForKey:@"name"];
                [TTArticleCategoryManager setServerLocalCityName:serverCityName];
            }
        }
        orderIndex ++;
    }
    
    NSArray *oldCategories = [self localCategoriesContainDeleteCategory:YES];
    
    //先取消数据库中除主频道外所有频道的订阅状态,把delete都设置为YES
    [oldCategories enumerateObjectsUsingBlock:^(TTCategory * category, NSUInteger idx, BOOL *stop) {
        if ([category.categoryID isEqualToString:kTTMainCategoryID]) {
            //调整推荐频道的orderIndex
            category.orderIndex = remotePreFixCategoryIDs.count;
            
            if (isEmptyString(category.concernID)) {
                //v5.5.x:推荐频道增加对应的concernID，对于升级用户需要添加对应的concernID
                category.concernID = kTTMainConcernID;
            }
            if (!category.subscribed) {
                category.subscribed = YES;
            }
            if (category.ttDeleted) {
                category.ttDeleted = NO;
            }
        }
        else {
            if ([remoteDataCategoryID containsObject:category.categoryID]) {
                if (category.ttDeleted) {
                    category.ttDeleted = NO;
                }
                if ([remoteSubscribedCategoryIDs containsObject:category.categoryID]) {
                    if (!category.subscribed) {
                        category.subscribed = YES;
                    }
                }
                else {
                    if (category.subscribed) {
                        category.subscribed = NO;
                    }
                }
            }
            else {
                if (!category.ttDeleted) {
                    category.ttDeleted = YES;
                }
            }
        }
        
        //字典设置TTCategory持久化尺寸
        for (NSMutableDictionary *dict in fixedData) {
            NSString *categoryID = [dict tt_stringValueForKey:@"category"];
            if ([categoryID isEqualToString:category.categoryID]) {
                [dict setValue:category.cachedSize forKey:@"cachedSize"];
            }
        }
        
        [category save];
    }];
    
    NSArray *insertedCategorys = [TTCategory insertObjectsWithDataArray:fixedData];
    
    __block BOOL hasTipNew = NO;
    
    [insertedCategorys enumerateObjectsUsingBlock:^(TTCategory * model, NSUInteger idx, BOOL *stop) {
        if (model.tipNew) {
            hasTipNew = YES;
            *stop = YES;
        }
    }];
    [TTArticleCategoryManager setHasNewTip:hasTipNew];
    
    NSArray *categories = [self localCategoriesContainDeleteCategory:NO];
    [self dispatchData:categories];
}

- (void)dispatchData:(NSArray*)categories
{
    if (categories.count == 0) return;
    
    [self.allCategories removeAllObjects];
    [self.articleCategories removeAllObjects];
    [self.webCategories removeAllObjects];
    [self.essayCatgegories removeAllObjects];
    [self.imageCategories removeAllObjects];
    [self.subScribedCategories removeAllObjects];
    [self.preFixedCategories removeAllObjects];
    self.localCategory = nil;
    
    for (TTCategory *category in categories)
    {
        //此处判断当前版本是否支持该category
        BOOL supportCategory = [TTArticleCategoryManager isCurrentVersionSupportCategoryModel:category];
        BOOL delete = category.ttDeleted;
        if (supportCategory && !delete) {
            [self.allCategories addObject:category];
        }
        else {
            continue;
        }
        if (category.isPreFixedCategory) {
            [self.preFixedCategories addObject:category];
        }else if (category.subscribed) {
            [self.subScribedCategories addObject:category];
        }
        
        if ([category.categoryID isEqualToString:kTTNewsLocalCategoryID]) {
            self.localCategory = category;
        }
        
        switch (category.listDataType) {
            case TTFeedListDataTypeArticle:
            {
                [self.articleCategories addObject:category];
            }
                break;
            case TTFeedListDataTypeEssay:
            {
                [self.essayCatgegories addObject:category];
            }
                break;
            case TTFeedListDataTypeImage:
            {
                [self.imageCategories addObject:category];
            }
                break;
            case TTFeedListDataTypeWeb:
            {
                [self.webCategories addObject:category];
            }
                break;
            case TTFeedListDataTypeSubscribeEntry:
            {
                [self.subscribeEntryCategories addObject:category];
            }
                break;
            default:
                break;
        }
    }
}

- (NSArray *)preFixedAndSubscribeCategories {
    NSMutableArray * preFixedAndSubscribeCategories = [NSMutableArray array];
    [preFixedAndSubscribeCategories addObjectsFromArray:self.preFixedCategories];
    [preFixedAndSubscribeCategories addObjectsFromArray:self.subScribedCategories];
    return preFixedAndSubscribeCategories.copy;
}

- (NSArray*)unsubscribeCategories
{
    NSMutableSet *allSet = [NSMutableSet setWithArray:self.allCategories];
    //过滤左侧固定频道
    NSSet *preFixedSet = [NSSet setWithArray:self.preFixedCategories];
    [allSet minusSet:preFixedSet];
    //过滤订阅频道
    NSSet *subscribedSet = [NSSet setWithArray:self.subScribedCategories];
    [allSet minusSet:subscribedSet];
    
    NSArray *unsubscribedSet = allSet.allObjects;
    NSArray *result = [unsubscribedSet sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TTCategory *c1 = (TTCategory *)obj1;
        TTCategory *c2 = (TTCategory *)obj2;
        if (c1.orderIndex < c2.orderIndex) return NSOrderedAscending;
        if (c1.orderIndex > c2.orderIndex) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    return result;
}

- (void)subscribe:(TTCategory *)category
{
    category.subscribed = YES;
    category.ttDeleted = NO;
    [category save];
    
    if (category.isPreFixedCategory) {
        return;
    }

    if (![self.subScribedCategories containsObject:category]) {
        [self.subScribedCategories addObject:category];
    }
    
    if (![self.allCategories containsObject:category]) {
        [self.allCategories addObject:category];
    }
    
    [self.subScribedCategories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TTCategory *c1 = (TTCategory*)obj1;
        TTCategory *c2 = (TTCategory*)obj2;
        if (c1.orderIndex < c2.orderIndex) return NSOrderedAscending;
        if (c1.orderIndex > c2.orderIndex) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

- (void)unSubscribe:(TTCategory *)category
{
    category.subscribed = NO;
    [category save];
    [self.subScribedCategories removeObject:category];
}


- (void)insertCategoryToPreFixed:(TTCategory *)category toOrderIndex:(NSInteger)toOrderIndex{

    if (!category || isEmptyString(category.categoryID)) {
        return;
    }

    //如果已经在推荐左侧，则不进行处理
    if ([self.preFixedCategories containsObject:category]) {
        return;
    }

    //如果超出可插入范围，则不进行处理
    if (toOrderIndex < 0 || toOrderIndex > self.preFixedCategories.count) {
        return;
    }

    //更新带插入的频道的状态
    category.subscribed = YES;
    category.ttDeleted = NO;
    category.isPreFixedCategory = YES;
    [category save];

    //如果已经在订阅（推荐右侧），则需要先在推荐右侧去掉此频道
    if ([self.subScribedCategories containsObject:category]) {
        [self.subScribedCategories removeObject:category];
    }

    //将此频道插入推荐左侧
    [self.preFixedCategories insertObject:category atIndex:toOrderIndex];

    //将此频道插入全频道
    if (![self.allCategories containsObject:category]) {
        [self.allCategories addObject:category];
    }

    //调整推荐左侧频道的orderIndex
    for (NSInteger preFixedIndex = 0; preFixedIndex < self.preFixedCategories.count; preFixedIndex++) {
        TTCategory *insertAfterCategory = [self.preFixedCategories objectAtIndex:preFixedIndex];
        insertAfterCategory.orderIndex = preFixedIndex;
        [insertAfterCategory save];
    }

    [self.preFixedCategories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TTCategory *c1 = (TTCategory*)obj1;
        TTCategory *c2 = (TTCategory*)obj2;
        if (c1.orderIndex < c2.orderIndex) return NSOrderedAscending;
        if (c1.orderIndex > c2.orderIndex) return NSOrderedDescending;
        return NSOrderedSame;
    }];

    //调整推荐右侧频道的orderIndex
    NSUInteger subscribeCategoriesStartIndex = self.preFixedCategories.count;
    [self.subScribedCategories enumerateObjectsUsingBlock:^(TTCategory * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        category.orderIndex = subscribeCategoriesStartIndex + idx;
        [category save];
    }];
    
    [self.subScribedCategories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TTCategory *c1 = (TTCategory*)obj1;
        TTCategory *c2 = (TTCategory*)obj2;
        if (c1.orderIndex < c2.orderIndex) return NSOrderedAscending;
        if (c1.orderIndex > c2.orderIndex) return NSOrderedDescending;
        return NSOrderedSame;
    }];


    //调整未订阅频道的orderindex
    NSUInteger unSubscribeCategoriesStartIndex = subscribeCategoriesStartIndex + self.subScribedCategories.count;
    [self.unsubscribeCategories enumerateObjectsUsingBlock:^(TTCategory * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        category.orderIndex = unSubscribeCategoriesStartIndex + idx;
        [category save];
    }];
    
}

- (void)changeSubscribe:(TTCategory *)category toOrderIndex:(NSInteger)index
{
    if (index < 0 || index > self.subScribedCategories.count - 1) {
        return;
    }
    
    if (![self.subScribedCategories containsObject:category]) {
        return;
    }
    
    [self.subScribedCategories removeObject:category];
    [self.subScribedCategories insertObject:category atIndex:index];
    NSUInteger beginIdx = self.preFixedCategories.count;
    [self.subScribedCategories enumerateObjectsUsingBlock:^(TTCategory * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        category.orderIndex = beginIdx + idx;
        [category save];
    }];
}

- (void)save
{
    [self saveWithNotify:YES];
}

- (void)saveWithNotify:(BOOL)notify
{
    @synchronized(self)
    {
        [self.localCategory save];
        
        if (notify) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kArticleCategoryHasChangeNotification object:self];
        }
    }
}

- (void)setLastAddedCategory:(TTCategory *)lastAddedCategory
{
    if (!lastAddedCategory) {
        _lastAddedCategory = nil;
        return;
    }
    
    if (![lastAddedCategory.categoryID isEqualToString:_lastAddedCategory.categoryID]) {
        // 由于“频道优化”（category optimizing）引入了新的category model（context = nil），因此同一个category可能对应不只一个model obj
        // 下面的代码是为了确保_lastAddedCategory是subScribedCategories中的元素
        for (TTCategory *category in self.subScribedCategories) {
            if ([category.categoryID isEqualToString:lastAddedCategory.categoryID]) {
                _lastAddedCategory = category;
                return;
            }
        }
    }
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

#pragma mark -- get category categoryIDs
/**
 *  返回get_category API发送是携带的category信息
 *
 *  @return category ID的array 转换为Json的array
 */
- (NSString *)fetchGetCategoryCategoryIDs
{
    NSArray *categoryIDs = [self subscribedCategoryIDs];
    //怀东 曾在14-12-11的下午6:04输入：
    //> @赵聪 @晨龙 推荐频道能否不上传？
    NSMutableArray *fixCategoryIDs = [NSMutableArray arrayWithArray:categoryIDs];
    if ([fixCategoryIDs containsObject:kTTMainCategoryID]) {
        [fixCategoryIDs removeObject:kTTMainCategoryID];
    }
    NSString *result = [fixCategoryIDs tt_JSONRepresentation];
    return result;
}

- (NSString *)fetchGetPrefixedCategoryCategoryIDs {

    NSArray *preFixedCategoryIDs = [self prefixedCategoryIDs];
    NSMutableArray *fixCategoryIDs = [NSMutableArray arrayWithArray:preFixedCategoryIDs];

    if ([fixCategoryIDs containsObject:kTTMainCategoryID]) {
        [fixCategoryIDs removeObject:kTTMainCategoryID];
    }

    NSString *result = [fixCategoryIDs tt_JSONRepresentation];
    return result;

}

#pragma mark -- get category version
/**
 *  返回get_category API发送是携带的version信息
 *
 *  @return version信息
 */
+ (NSString *)fetchGetCategoryVersion
{
    NSString *result = nil;
    if ([TTArticleCategoryManager hasGotRemoteData]) {//从远端获取到过频道信息， 用频道数据库的信息
        result = [[NSUserDefaults standardUserDefaults] objectForKey:kArticleCategoryManagerVersionKey];
    }
    else {//未从远端获取到过频道信息
        //特殊情况下的客户端段上报：上报内置频道列表时version为2，旧版升级新版时上报版本为1
        result = @"2";
    }
    
    if (isEmptyString(result)) {
        return @"0";
    }
    return result;
}

+ (void)setGetCategoryVersion:(NSString *)version
{
    if (isEmptyString(version)) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kArticleCategoryManagerVersionKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:kArticleCategoryManagerVersionKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -- 数据记录

+ (void)setServerLocalCityName:(NSString *)name
{
    if (name == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kArticleCategoryManagerServerLocalCityNameKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:name forKey:kArticleCategoryManagerServerLocalCityNameKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)latestServerLocalCity
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kArticleCategoryManagerServerLocalCityNameKey];
}

#pragma mark -- 状态记录

+ (BOOL)hasNewTip
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:KArticleCategoryManagerHasNewTipKey] boolValue];
}

+ (void)setHasNewTip:(BOOL)hasNew
{
    [[NSUserDefaults standardUserDefaults] setBool:hasNew forKey:KArticleCategoryManagerHasNewTipKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kArticleCategoryTipNewChangedNotification object:nil];
}

//////////////////////////

+ (void)setUserSelectedLocalCity
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kArticleCategoryManagerUserSelectedLocalCityKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isUserSelectedLocalCity
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kArticleCategoryManagerUserSelectedLocalCityKey];
}

//////////////////////////

+ (BOOL)hasGotRemoteData
{
    [self insertDefaultDataIfNeeded];
    
    NSString * keyStr = [NSString stringWithFormat:@"ArticleCategoryManagerGotRemoteData%@", [TTSandBoxHelper versionName]];
    return [[[NSUserDefaults standardUserDefaults] objectForKey:keyStr] boolValue];
}

/**
 *  设置当前版本获取到过远端的频道数据
 */
+ (void)setHasGotRemoteData
{
    NSString * keyStr = [NSString stringWithFormat:@"ArticleCategoryManagerGotRemoteData%@", [TTSandBoxHelper versionName]];
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:keyStr];
}

+ (void)clearHasGotRemoteData {
    NSString * keyStr = [NSString stringWithFormat:@"ArticleCategoryManagerGotRemoteData%@", [TTSandBoxHelper versionName]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyStr];
}

#pragma mark -- private

/**
 *  获取当前订阅的category ID的数组
 *
 *  @return 返回当前订阅的category ID的array
 */
- (NSArray *)subscribedCategoryIDs
{
    NSMutableArray *categories = [NSMutableArray arrayWithArray:self.subScribedCategories];
    [categories removeObject:[TTArticleCategoryManager mainArticleCategory]];
    
    NSMutableArray * subscribes = [NSMutableArray arrayWithCapacity:[categories count]];
    for (TTCategory *category in categories) {
        if (!isEmptyString(category.categoryID)) {
            [subscribes addObject:category.categoryID];
        }
    }
    return subscribes;
}

- (NSArray *)prefixedCategoryIDs {

    NSMutableArray *categories = [NSMutableArray arrayWithArray:self.preFixedCategories];
    if ([categories containsObject:[TTArticleCategoryManager mainArticleCategory]]) {
        [categories removeObject:[TTArticleCategoryManager mainArticleCategory]];
    }

    NSMutableArray * subscribes = [NSMutableArray arrayWithCapacity:[categories count]];
    for (TTCategory *category in categories) {
        if (!isEmptyString(category.categoryID)) {
            [subscribes addObject:category.categoryID];
        }
    }
    return subscribes;
}

#pragma mark -- private util

/**
 *  判断当前版本是否支持该model
 */
+ (BOOL)isCurrentVersionSupportCategoryModel:(TTCategory *)model
{
    BOOL supportCategory = NO;
    switch (model.listDataType) {
        case TTFeedListDataTypeArticle:
        case TTFeedListDataTypeEssay:
        case TTFeedListDataTypeImage:
        case TTFeedListDataTypeWeb:
        case TTFeedListDataTypeSubscribeEntry:
            supportCategory = YES;
            break;
        case TTFeedListDataTypeVideo:
            supportCategory = NO;
            break;
        default:
            break;
    }
    return supportCategory;
}

/**
 *  推荐频道左侧固定频道数据预处理
 */
+ (NSArray *)preFixedDataPreOperate:(NSArray <NSDictionary *> *)preFixedData {
    if (![preFixedData isKindOfClass:[NSArray class]] || 0 == preFixedData.count) {
        return nil;
    }
    NSMutableArray <NSDictionary *> * resultPreFixedData = [NSMutableArray array];
    [preFixedData enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary * preOperateObj = [NSMutableDictionary dictionaryWithDictionary:obj];
            [preOperateObj setValue:@(YES) forKey:@"isPreFixedCategory"];
            [resultPreFixedData addObject:preOperateObj.copy];
        }
    }];
    if (0 == resultPreFixedData.count) {
        return nil;
    }else {
        return resultPreFixedData.copy;
    }
}

- (void)setSysLocationBlock:(TTArticleCategoryManagerSysLocationBlock)block {
    _sysLocationBlock = block;
}

- (void)setIARBlock:(TTArticleCategoryManagerIARBlock)block {
    _iarBlock = block;
}

- (void)setCityBlock:(TTArticleCategoryManagerCityBlock)block {
    _cityBlock = block;
}

@end

////////////////////////////////////////////////////////////////////////

@implementation TTArticleCategoryManager(InsertDefaultCategory)

+ (void)insertDefaultData
{
    @synchronized (self) {
        if (__hasInsertedDefaultData) {
            return;
        }
        
        if (![TTSandBoxHelper isAPPFirstLaunch]) {
            return;
        }
        
        [TTArticleCategoryManager setGetCategoryVersion:nil];
        [TTArticleCategoryManager clearHasGotRemoteData];
        
//        NSString *mainTitle = NSLocalizedString(@"推荐", nil);
//
//        NSDictionary *data = @{@"name":mainTitle,
//                               @"category":kTTMainCategoryID,
//                               @"concern_id":kTTMainConcernID,
//                               @"order_index":@(0),
//                               @"subscribed":@(1),
//                               @"type":@(TTFeedListDataTypeArticle)
//                               };
//
//        TTCategory *mainCategory = [TTCategory objectWithDictionary:data];
//        [mainCategory save];
//        s_mainCategoryModel = mainCategory;
        
        BOOL haveFixationCategory = NO;
    //    NSDictionary * fixationDict = TTLogicDictionary(@"CategoryManagerFixationCategory", nil);
    //    if ([[fixationDict allKeys] containsObject:@"category"]) {
    //        haveFixationCategory = YES;
    //        [[TTCategory objectWithDictionary:fixationDict] save];
    //    }
        NSUInteger categoryOrderIndex = haveFixationCategory ? 2 : 1;
        
        NSArray * insertCategorys = @[@{@"category":@"f_house_news",
                                        @"name":NSLocalizedString(@"推荐",nil),
                                        @"type":@(TTFeedListDataTypeArticle),
                                        @"concernID":@""},
//                                      @{@"category":@"f_find_house",
//                                        @"name":NSLocalizedString(@"找房",nil),
//                                        @"type":@(TTFeedListDataTypeArticle),
//                                        @"concernID":@""},
                                      @{@"category": @"f_shipin",
                                        @"name": NSLocalizedString(@"视频", nil),
                                        @"type": @(TTFeedListDataTypeArticle),
                                        @"concernID": @""},
                                      @{@"category": @"f_hotsoon_video",
                                        @"name": NSLocalizedString(@"看房",nil),
                                        @"type": @(TTFeedListDataTypeArticle),
                                        @"concernID": @""},
                                      @{@"category": @"f_knowledge",
                                        @"name": NSLocalizedString(@"百科",nil),
                                        @"type": @(TTFeedListDataTypeArticle),
                                        @"concernID": @""},
                                      @{@"category": @"f_wenda",
                                        @"name": NSLocalizedString(@"问答",nil),
                                        @"type": @(TTFeedListDataTypeArticle),
                                        @"concernID": @""},
                                      @{@"category": @"f_home",
                                        @"name": NSLocalizedString(@"家居", nil),
                                        @"type": @(TTFeedListDataTypeArticle),
                                        @"concernID": @""},

                                      ];

//        NSArray * insertCategorys = @[@{@"category":@"news_house",
//                                        @"name":NSLocalizedString(@"房产",nil),
//                                        @"type":@(TTFeedListDataTypeArticle),
//                                        @"concernID":@"6215497897127971330"},
//                                      @{@"category": @"news_home",
//                                        @"name": NSLocalizedString(@"家居", nil),
//                                        @"type": @(TTFeedListDataTypeArticle),
//                                        @"concernID": @"6215497901804620289"},
//                                      @{@"category": @"question_and_answer",
//                                        @"name": NSLocalizedString(@"问答",nil),
//                                        @"type": @(TTFeedListDataTypeArticle),
//                                        @"concernID": @"6260258266329123329"},
//                                      //                                      @{@"category": @"hotsoon_video",
//                                      //                                        @"name": NSLocalizedString(@"小视频",nil),
//                                      //                                        @"type": @(TTFeedListDataTypeArticle),
//                                      //                                        @"concernID": @""},
//                                      ];
        


        
        for (int i = 0; i < [insertCategorys count]; i++) {
            NSString * name = [[insertCategorys objectAtIndex:i] objectForKey:@"name"];
            NSString * category = [[insertCategorys objectAtIndex:i] objectForKey:@"category"];
            NSString * concernID = [[insertCategorys objectAtIndex:i] objectForKey:@"concernID"];
            TTFeedListDataType type = [[[insertCategorys objectAtIndex:i] objectForKey:@"type"] intValue];
            
            [self insertCategoryForName:name categoryID:category concernID:concernID orderIndex:@(categoryOrderIndex) subscribed:YES categoryType:type save:NO];
            
            categoryOrderIndex ++;
        }
        
//        NSArray * insertUnsubscribedCategorys =
//                                    @[@{@"category":@"movie",           @"name":NSLocalizedString(@"电影",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497900554717698"},
//                                      @{@"category":@"digital",         @"name":NSLocalizedString(@"数码",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497897518041601"},
//                                      @{@"category":@"news_fashion",    @"name":NSLocalizedString(@"时尚",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497898084272641"},
//                                      @{@"category":@"rumor",           @"name":NSLocalizedString(@"辟谣",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@""},
//                                      @{@"category":@"marvel",          @"name":NSLocalizedString(@"奇葩",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497896461076993"},
//                                      @{@"category":@"news_game",       @"name":NSLocalizedString(@"游戏",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497899027991042"},
//                                      @{@"category":@"news_travel",     @"name":NSLocalizedString(@"旅游",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497897899723265"},
//                                      @{@"category":@"news_baby",       @"name":NSLocalizedString(@"育儿",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497900164647426"},
//                                      @{@"category":@"fitness",         @"name":NSLocalizedString(@"减肥",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497895651576321"},
//                                      @{@"category":@"news_regimen",    @"name":NSLocalizedString(@"养生",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497901406161409"},
//                                      @{@"category":@"news_food",       @"name":NSLocalizedString(@"美食",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497899774577154"},
//                                      @{@"category":@"government",      @"name":NSLocalizedString(@"政务",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@""},
//                                      @{@"category":@"news_history",    @"name":NSLocalizedString(@"历史",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497901590710786"},
//                                      @{@"category":@"news_discovery",  @"name":NSLocalizedString(@"探索",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497901993363970"},
//                                      @{@"category":@"news_story",      @"name":NSLocalizedString(@"故事",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497902182107649"},
//                                      @{@"category":@"news_essay",      @"name":NSLocalizedString(@"美文",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497902563789314"},
//                                      @{@"category":@"emotion",         @"name":NSLocalizedString(@"情感",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215845055769348610"},
//                                      @{@"category":@"essay_saying",    @"name":NSLocalizedString(@"语录",nil),      @"type":@(TTFeedListDataTypeEssay),          @"concernID":@""},
//                                      @{@"category":@"image_wonderful", @"name":NSLocalizedString(@"美图",nil),      @"type":@(TTFeedListDataTypeImage),          @"concernID":@""},
//                                      @{@"category":@"news_house",      @"name":NSLocalizedString(@"家居",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497897127971330"},
//                                      @{@"category":@"funny",           @"name":NSLocalizedString(@"搞笑",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497900768627201"},
//                                      @{@"category":@"news_astrology",  @"name":NSLocalizedString(@"星座",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@""},
//                                      @{@"category":@"news_culture",    @"name":NSLocalizedString(@"文化",nil),      @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215497897710979586"},
//                                      @{@"category":@"graduate",        @"name":NSLocalizedString(@"毕业生",nil),     @"type":@(TTFeedListDataTypeArticle),          @"concernID":@"6215847699854395905"}
//                                      ];
        
//        for (int i = 0; i < [insertUnsubscribedCategorys count]; i++) {
//            NSString * name = [[insertUnsubscribedCategorys objectAtIndex:i] objectForKey:@"name"];
//            NSString * category = [[insertUnsubscribedCategorys objectAtIndex:i] objectForKey:@"category"];
//            NSString * concernID = [[insertUnsubscribedCategorys objectAtIndex:i] objectForKey:@"concernID"];
//            TTFeedListDataType type = [[[insertUnsubscribedCategorys objectAtIndex:i] objectForKey:@"type"] intValue];
//
//            [self insertCategoryForName:name categoryID:category concernID:concernID orderIndex:@(categoryOrderIndex) subscribed:NO categoryType:type save:NO];
//
//            categoryOrderIndex ++;
//        }
        
        //图片频道默认数据
//        if ([TTDeviceHelper isPadDevice]) {
//            NSArray *photoCategories = @[@{@"category":@"组图", @"name":NSLocalizedString(@"图集", nil), @"type":@(TTFeedListDataTypeArticle)}];
//            for (int i = 0; i < [photoCategories count]; i++) {
//                NSString * name = [[photoCategories objectAtIndex:i] objectForKey:@"name"];
//                NSString * category = [[photoCategories objectAtIndex:i] objectForKey:@"category"];
//                TTFeedListDataType type = [[[photoCategories objectAtIndex:i] objectForKey:@"type"] intValue];
//
//                [self insertCategoryForName:name categoryID:category concernID:@"" orderIndex:@(categoryOrderIndex) subscribed:NO categoryType:type categoryTopType:TTCategoryModelTopTypePhoto save:NO];
//
//                categoryOrderIndex ++;
//            }
//        }
        
        __hasInsertedDefaultData = YES;
    }
}

+ (void)insertDefaultDataIfNeeded {
    TTCategory *result = [TTCategory objectForPrimaryKey:kTTMainCategoryID];
    if (!result) {
        [self insertDefaultData];
    }
}

#pragma mark -- private util

/**
 *  插入新闻频道
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
                categoryTopType:TTCategoryModelTopTypeNews
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
    [[TTCategory objectWithDictionary:data] save];
}

@end
