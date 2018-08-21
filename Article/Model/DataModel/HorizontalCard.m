//
//  HorizontalCard.m
//  Article
//
//  Created by 王双华 on 2017/5/15.
//
//

#import "HorizontalCard.h"
#import "ExploreListIItemDefine.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVShortVideoCategoryFetchManager.h"

NSString *const kHorizontalCardCategoryID  =   @"kHorizontalCardCategoryID";

@implementation HorizontalCardMoreModel

- (instancetype)initWithDictionary:(NSDictionary*)data
{
    self = [super init];
    
    if (self) {
        self.title = [data tt_stringValueForKey:@"title"];
        self.urlString = [data tt_stringValueForKey:@"url"];
    }
    
    return self;
}

@end

@interface HorizontalCard()

@property (nonatomic, strong) NSArray *cachedCardItems;
@property (nonatomic, assign) BOOL hasInsertCardItems;

@end

@implementation HorizontalCard

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"cardTitle":@"card_title",
                       @"cardType":@"card_type",
                       @"showMore":@"show_more",
                       @"prefetchType":@"prefetch_type",
                       @"cardLayoutStyle":@"multi_pic_type",
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
                       @"cardTitle",
                       @"cardType",
                       @"itemsData",
                       @"showMore",
                       @"prefetchType",
                       @"cardLayoutStyle"
                       ];
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dataDict
{
    if (!self.managedObjectContext) return;
    
    [super updateWithDictionary:dataDict];
    
    self.itemsData = [dataDict tt_arrayValueForKey:@"data"];
    
    self.cardType = @([dataDict intValueForKey:@"card_type" defaultValue:1]);
}

- (nullable NSArray *)originalCardItems {
    if (_cachedCardItems) return _cachedCardItems;
    
    NSMutableArray *items = [NSMutableArray array];
    
    for (NSDictionary *itemData in self.itemsData)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:itemData];
        [dict setValue:kHorizontalCardCategoryID forKey:@"categoryID"];
        [dict setValue:@"" forKey:@"concernID"];
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
    [self.originalCardItems enumerateObjectsUsingBlock:^(ExploreOrderedData *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            obj.originalData.notInterested = @(YES);
        }
    }];
    [self clearCachedCardItems];
}

- (id)modelWithData:(NSDictionary*)data {
    NSAssert([NSThread isMainThread], @"modelWithData: needs to be accessed on the main thread.");
    ExploreOrderedDataCellType cellType = [data tt_intValueForKey:@"cell_type"];
    id result = nil;
    id gid = nil;
    
    NSAssert(cellType != ExploreOrderedDataCellTypeHorizontalCard, @"card should not be inside card");
    
    switch (cellType) {
            
        case ExploreOrderedDataCellTypeShortVideo:
        {
            gid = [data objectForKey:@"id"];
        }
            break;
        default:
            break;
    }
    
    if (gid) {
        __unused NSNumber *uniqueID = @([[NSString stringWithFormat:@"%@", gid] longLongValue]);
        //        NSArray *results = [[[SSDataContext sharedContext] mainThreadModelManager] entitiesWithQuery:@{@"originalData.uniqueID": uniqueID, @"cellType": @(cellType), @"categoryID": kCardArticleCategoryID} entityClass:[ExploreOrderedData class] error:nil];
        
        NSString *primaryID = [ExploreOrderedData primaryIDFromDictionary:@{@"uniqueID" : [NSString stringWithFormat:@"%@", gid],
                                                                            @"categoryID" : kHorizontalCardCategoryID,
                                                                            @"listType" : @(ExploreOrderedDataListTypeCategory),
                                                                            @"listLocation" : @(ExploreOrderedDataListLocationCategory),
                                                                            }];
        
        ExploreOrderedData *orderedData = [ExploreOrderedData objectForPrimaryKey:primaryID];
        
        if (orderedData) {
            LOGD(@"...got %@", uniqueID);
            if (![orderedData.originalData.notInterested boolValue]) {
                result = orderedData;
            }
        } else {
            LOGD(@"...lost");
        }
    }
    
    return result;
}

- (HorizontalCardMoreModel *)showMoreModel{
    return [[HorizontalCardMoreModel alloc] initWithDictionary:self.showMore];
}

- (void)setPrefetchType:(NSNumber *)prefetchType{
    _prefetchType = prefetchType;
    if (!_prefetchManager) {
        _prefetchManager = [[TSVShortVideoCategoryFetchManager alloc] initWithOrderedDataArray:nil cardID:nil preFetchType:[self cardPrefetchType]];
    }
}

- (TSVShortVideoCardPreFetchType)cardPrefetchType{
    switch ([self.prefetchType integerValue]) {
        case 0:
            return TSVShortVideoCardPreFetchTypeNone;
            break;
        case 1:
            return TSVShortVideoCardPreFetchTypeOnce;
            break;
        case 2:
            return TSVShortVideoCardPreFetchTypeInfinite;
            break;
        default:
            return TSVShortVideoCardPreFetchTypeNone;
            break;
    }
}

- (NSArray *)allCardItems{
    if (![self isHorizontalScrollEnabled]) {
        return self.originalCardItems;
    } else {
        if (!_hasInsertCardItems) {
            [self.prefetchManager insertCardItemsIfNeeded:self.originalCardItems];
            _hasInsertCardItems = YES;
        }
        return [self.prefetchManager horizontalCardItems];
    }
}

- (BOOL)isHorizontalScrollEnabled{
    if ([self cardPrefetchType] == TSVShortVideoCardPreFetchTypeNone) {
        return NO;
    } else {
        return YES;
    }
}

@end
