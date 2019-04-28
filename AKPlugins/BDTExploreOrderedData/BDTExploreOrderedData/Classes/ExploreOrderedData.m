//
//  ExploreOrderedData.m
//  Article
//
//  Created by Hu Dianwei on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExploreOrderedData.h"

@implementation ExploreOrderedData

@synthesize nextCellType;
@synthesize preCellType;
@synthesize cellTypeCached;
@synthesize isInCard;
@synthesize layoutUIType;
@synthesize cardPrimaryID;
@synthesize maxTextLine = _maxTextLine;
@synthesize defaultTextLine = _defaultTextLine;

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"primaryID";
}

+ (GYCacheLevel)cacheLevel {
    return GYCacheLevelResident;
}

- (Article *)article
{
    if (self.cellType == ExploreOrderedDataCellTypeArticle || self.cellType == ExploreOrderedDataCellTypeAppDownload) {
        if (!_article && self.uniqueID) {
            NSString *primaryID = [Article primaryIDByUniqueID:[self.uniqueID longLongValue]
                                                        itemID:self.itemID
                                                          adID:self.adIDStr];
            
            _article = [Article objectForPrimaryKey:primaryID];
        }
    }
    else{
        _article = nil;
    }
    return _article;
}

- (instancetype _Nonnull)initWithArticle:( Article * _Nonnull )article
{
    self = [super init];
    if (self) {
        if (article) {
            _uniqueID = [NSString stringWithFormat:@"%lld", article.uniqueID];
            _itemID = article.itemID;
            _cellType = ExploreOrderedDataCellTypeArticle;
            _logExtra = [article relatedLogExtra].length > 0 ? [article relatedLogExtra] : article.logExtra;
            _adID = article.relatedVideoExtraInfo[kArticleInfoRelatedVideoAdIDKey];
            if (!_adID) {
                _adID = @([article.adIDStr longLongValue]);
            }
            if (_adID) {
                _adIDStr = [NSString stringWithFormat:@"%@",self.adID];
            }
            _article = article;
        }
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    ExploreOrderedData *other = (ExploreOrderedData *)object;
    
    if ((self.uniqueID || other.uniqueID) && ![self.uniqueID isEqualToString:other.uniqueID]) {
        return NO;
    }
    
    if ((self.categoryID || other.categoryID) && ![self.categoryID isEqualToString:other.categoryID]) {
        return NO;
    }

    if ((self.concernID || other.concernID) && ![self.concernID isEqualToString:other.concernID]) {
        return NO;
    }
    
    if (self.listType != other.listType) {
        return NO;
    }
    
    if (self.listLocation != other.listLocation) {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash {
    return [self.primaryID hash];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registNotifications];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registNotifications {
    // implements in category
}

- (NSNumber *)showDislike {
    //历史、收藏，写死不显示
    if ([self.categoryID isEqualToString:kExploreFavoriteListIDKey] || [self.categoryID isEqualToString:@"_history"]) {
        return @(NO);
    }
    //后台没下发，默认显示
    if (_showDislike == nil) {
        return @(YES);
    }
    return _showDislike;
}

@end
