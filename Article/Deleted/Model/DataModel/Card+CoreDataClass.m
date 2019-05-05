//
//  Card+CoreDataClass.m
//  
//
//  Created by Chen Hong on 16/7/1.
//
//

#import "Card+CoreDataClass.h"
#import "ExploreListIItemDefine.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTGroupModel.h"
#import "ExploreItemActionManager.h"
#import "Article.h"

//NSString *const kCardArticleCategoryID  =   @"kCardArticleCategoryID";

@interface ExploreEmbedListCardArticlePlaceholder : NSObject
@property(nonatomic, strong)NSString *uniqueID;

- (instancetype)initWithDictionary:(NSDictionary *)data;
@end

@implementation ExploreEmbedListCardArticlePlaceholder

- (instancetype)initWithDictionary:(NSDictionary *)data {
    self = [super init];
    if (self) {
        ExploreOrderedDataCellType cellType = [[data objectForKey:@"cell_type"] intValue];
        switch (cellType) {
            case ExploreOrderedDataCellTypeArticle:
            {
                id gid = [data objectForKey:@"group_id"];
                if (gid) {
                    self.uniqueID = [NSString stringWithFormat:@"%@", gid];
                }
            }
                break;
            case ExploreOrderedDataCellTypeStock:
            {
                id gid = [data objectForKey:@"id"];
                if (gid) {
                    self.uniqueID = [NSString stringWithFormat:@"%@", gid];
                }
            }
                break;
            default:
                break;
        }
    }
    return self;
}

@end


@implementation ExploreEmbedListCardShowMoreModel

- (instancetype)initWithDictionary:(NSDictionary*)data
{
    self = [super init];
    if(self)
    {
        self.title = [data objectForKey:@"title"];
        self.urlString = [data objectForKey:@"url"];
    }
    
    return self;
}

@end

@implementation ExploreEmbedListCardHeadInfoModel

- (instancetype)initWithDictionary:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        if ([data objectForKey:@"score"]) {
            self.score = [data floatValueForKey:@"score" defaultValue:0.0];
        }
        if ([data objectForKey:@"image_url"]) {
            self.imageUrl = [data stringValueForKey:@"image_url" defaultValue:nil];
        }
        if ([data objectForKey:@"team1_icon"]) {
            self.team1IconUrl = [data stringValueForKey:@"team1_icon" defaultValue:nil];
        }
        if ([data objectForKey:@"team2_icon"]){
            self.team2IconUrl = [data stringValueForKey:@"team2_icon" defaultValue:nil];
        }
        if ([data objectForKey:@"team1_score"]){
            self.team1Score = [data intValueForKey:@"team1_score" defaultValue:0];
        }
        if ([data objectForKey:@"team2_score"]){
            self.team2Score = [data intValueForKey:@"team2_score" defaultValue:0];
        }
    }
    return self;
}

@end

@implementation ExploreEmbedListCardTabInfoModel

- (instancetype)initWithDictionary:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        self.tabtext = [data stringValueForKey:@"text" defaultValue:nil];
        self.taburl = [data stringValueForKey:@"url" defaultValue:nil];
    }
    return self;
}

@end


@implementation Card {
    NSArray * _cachedCardItems;
}

//+ (NSEntityDescription*)entityDescriptionInManager:(SSModelManager *)manager
//{
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:manager];
//    return entityDescription;
//}
//
//+ (NSString*)entityName
//{
//    return @"Card";
//}
//
//+ (NSArray*)primaryKeys
//{
//    return @[@"uniqueID"];
//}

+ (NSDictionary *)keyMapping {
    /*
     *  cardType:
     *  1：默认
     *  2：（电影）评分
     *  3：比赛战报
     *  4：头部为图片的样式
     *  6: 要闻卡片样式
     */
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"actionExtra":@"action_extra",
                       @"cardDayIcon":@"card_day_icon",
                       @"titlePrefix":@"card_label",
                       @"headerStyle":@"card_label_style",
                       @"cardNightIcon":@"card_night_icon",
                       @"cardStyle":@"card_style",
                       @"cardTitle":@"card_title",
                       @"cardType":@"card_type",
                       @"iconUrl":@"icon_url",
                       @"mediaID":@"media_id",
                       @"nightIconUrl":@"night_icon_url",
                       @"titleUrl":@"url",
                       };
    }
    return properties;
}

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"iconUrl",
                       @"nightIconUrl",
                       @"titlePrefix",
                       @"cardTitle",
                       @"actionExtra",
                       @"titleUrl",
                       @"headerStyle",
                       @"cardStyle",
                       @"mediaID",
                       @"filterWords",
                       @"showMoreData",
                       @"cardDayIcon",
                       @"cardNightIcon",
                       @"cardType",
                       @"headInfoData",
                       @"tabLists",
                       @"itemsData",
                       ];
    }
    return properties;
}

//+ (NSDictionary *)defaultValues {
//    static NSDictionary *values = nil;
//    if (!values) {
//        values = @{
//                    @"cardType" : @1,
//                    };
//    }
//    return values;
//}

- (void)updateWithDictionary:(NSDictionary *)dataDict
{
    [super updateWithDictionary:dataDict];
    
    self.filterWords = [dataDict tt_arrayValueForKey:@"filter_words"];
    
    
    self.itemsData = [dataDict tt_arrayValueForKey:@"data"];
    
    self.showMoreData = [dataDict tt_dictionaryValueForKey:@"show_more"];

    self.headInfoData = [dataDict tt_dictionaryValueForKey:@"head_info"];
    
    self.tabLists = [dataDict tt_arrayValueForKey:@"tab_list"];
    
    self.cardType = @([dataDict intValueForKey:@"card_type" defaultValue:1]);
}

- (ExploreEmbedListCardShowMoreModel *)showMoreModel {
    ExploreEmbedListCardShowMoreModel *model = nil;
    if (self.showMoreData) {
        model = [[ExploreEmbedListCardShowMoreModel alloc] initWithDictionary:self.showMoreData];
    }
    return model;
}

- (ExploreEmbedListCardHeadInfoModel *)headInfoModel {
    ExploreEmbedListCardHeadInfoModel *model = nil;
    if([self.cardType intValue] != 1 && self.headInfoData){
        model = [[ExploreEmbedListCardHeadInfoModel alloc] initWithDictionary:self.headInfoData];
    }
    return model;
}

- (nullable NSArray *)tabModelLists {
    if (self.tabLists.count == 0) return nil;

    NSMutableArray *tabLists = [NSMutableArray array];
    for (NSDictionary *listData in self.tabLists) {
        ExploreEmbedListCardTabInfoModel *model = [[ExploreEmbedListCardTabInfoModel alloc] initWithDictionary:listData];
        [tabLists addObject:model];
    }
    return tabLists;
}

- (nullable NSArray *)cardItems {
    if (_cachedCardItems) return _cachedCardItems;
    
    NSMutableArray *items = [NSMutableArray array];
    
    for (NSDictionary *itemData in self.itemsData)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:itemData];
//        [dict setValue:kCardArticleCategoryID forKey:@"categoryID"];
//        [dict setValue:@"" forKey:@"concernID"];
        id result = [self modelWithData:dict];
        if(result) [items addObject:result];
    }
    
    _cachedCardItems = [items copy];
    
    return items;
}

- (void)clearCachedCardItems {
    _cachedCardItems = nil;
}

- (void)setAllCardItemsNotInterested {
    [self.cardItems enumerateObjectsUsingBlock:^(ExploreOrderedData *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            obj.originalData.notInterested = @(YES);
            
            [self sendDislikeForCardItem:obj];
        }
    }];
    [self clearCachedCardItems];
}

- (void)sendDislikeForCardItem:(ExploreOrderedData *)obj {
    TTGroupModel *groupModel = [[TTGroupModel alloc] init];
    NSString *groupId = [NSString stringWithFormat:@"%lld", obj.originalData.uniqueID];
    if ([obj.article respondsToSelector:@selector(itemID)]) {
        groupModel = [[TTGroupModel alloc] initWithGroupID:groupId itemID:obj.article.itemID impressionID:nil aggrType:[obj.article.aggrType integerValue]];
    } else {
        groupModel = [[TTGroupModel alloc] initWithGroupID:groupId];
    }
    
    TTDislikeSourceType sourceType = TTDislikeSourceTypeFeed;
    
    ExploreItemActionManager *itemActionManager = [[ExploreItemActionManager alloc] init];
    [itemActionManager startSendDislikeActionType:DetailActionTypeNewVersionDislike source:sourceType groupModel:groupModel filterWords:nil cardID:nil actionExtra:obj.actionExtra adID:nil adExtra:nil widgetID:nil threadID:nil finishBlock:nil];
}

- (id)modelWithData:(NSDictionary*)data {
    NSAssert([NSThread isMainThread], @"modelWithData: needs to be accessed on the main thread.");
    ExploreOrderedDataCellType cellType = [data tt_intValueForKey:@"cell_type"];
    NSString *categoryID = [data stringValueForKey:@"categoryID" defaultValue:@""];
    NSString *concernID = [data stringValueForKey:@"concernID" defaultValue:@""];
    
    id result = nil;
    id gid = nil;
    
    NSAssert(cellType != ExploreOrderedDataCellTypeCard, @"card should not be inside card");
    
    switch (cellType) {
            
        case ExploreOrderedDataCellTypeArticle:
        {
            gid = [data objectForKey:@"group_id"];
        }
            break;
        case ExploreOrderedDataCellTypeStock:
        {
            gid = [data objectForKey:@"id"];
        }
            break;
        case ExploreOrderedDataCellTypeBook:
        {
            gid = [data objectForKey:@"id"];
        }
            break;
        default:
            break;
    }
    
    if (gid) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
        [dict setValue:gid forKey:@"uniqueID"];
        [dict setValue:categoryID forKey:@"categoryID"];
        [dict setValue:concernID forKey:@"concernID"];
        [dict setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
        [dict setValue:@(ExploreOrderedDataListLocationCard) forKey:@"listLocation"];
        
        NSString *primaryID = [ExploreOrderedData primaryIDFromDictionary:dict];

        ExploreOrderedData *orderedData = [ExploreOrderedData objectForPrimaryKey:primaryID];
        
        if (orderedData) {
//            LOGD(@"...got %@", uniqueID);
            if (![orderedData.originalData.notInterested boolValue]) {
                result = orderedData;
            }
        } else {
            LOGD(@"...lost");
        }
    }
    
    return result;
}

@end
