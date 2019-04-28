//
//  Card+CoreDataClass.h
//  
//
//  Created by Chen Hong on 16/7/1.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ExploreCardStyle) {
    ExploreCardStyleUser = 1,
    ExploreCardStyleArticle = 2,
    ExploreCardStylePGC = 3,
    ExploreCardStyleCategory = 4,
    ExploreCardStyleForum = 5,
    ExploreCardStyleDynamic = 6,
    ExploreCardStyleCommon = 7,
    ExploreCardStyleGame = 8,
    ExploreCardStyleVideo = 9
};//5.1新加 暂时用来满足统计需求

// fake categoryID for article in card
//extern  NSString * _Nullable const kCardArticleCategoryID;


@interface ExploreEmbedListCardShowMoreModel : NSObject
@property(nonatomic, strong, nullable)NSString *title;
@property(nonatomic, strong, nullable)NSString *urlString;
@end

@interface ExploreEmbedListCardHeadInfoModel : NSObject
@property(nonatomic, assign)float score;
@property(nonatomic, strong, nullable)NSString *imageUrl;
@property(nonatomic, strong, nullable)NSString *team1IconUrl;
@property(nonatomic, strong, nullable)NSString *team2IconUrl;
@property(nonatomic, assign)int team1Score;
@property(nonatomic, assign)int team2Score;
@end

@interface ExploreEmbedListCardTabInfoModel : NSObject
@property(nonatomic, strong, nullable)NSString *tabtext;
@property(nonatomic, strong, nullable)NSString *taburl;

@end


@interface Card : ExploreOriginalData

@property (nullable, nonatomic, copy) NSString *iconUrl;
@property (nullable, nonatomic, copy) NSString *nightIconUrl;
@property (nullable, nonatomic, copy) NSString *titlePrefix;
@property (nullable, nonatomic, copy) NSString *cardTitle;
@property (nullable, nonatomic, copy) NSString *actionExtra;
@property (nullable, nonatomic, copy) NSString *titleUrl;
@property (nullable, nonatomic, copy) NSNumber *headerStyle;
@property (nullable, nonatomic, copy) NSNumber *cardStyle;
@property (nullable, nonatomic, copy) NSString *mediaID;
@property (nullable, nonatomic, retain) NSArray *filterWords;
@property (nullable, nonatomic, retain) NSDictionary *showMoreData;
@property (nullable, nonatomic, copy) NSString *cardDayIcon;
@property (nullable, nonatomic, copy) NSString *cardNightIcon;
@property (nullable, nonatomic, copy) NSNumber *cardType;
@property (nullable, nonatomic, retain) NSDictionary *headInfoData;
@property (nullable, nonatomic, retain) NSArray *tabLists;
@property (nullable, nonatomic, retain) NSArray *itemsData;

- (nullable ExploreEmbedListCardShowMoreModel *)showMoreModel;
- (nullable ExploreEmbedListCardHeadInfoModel *)headInfoModel;
- (nullable NSArray *)tabModelLists;

// 主线程调用
- (nullable NSArray *)cardItems;
- (void)clearCachedCardItems;

- (void)setAllCardItemsNotInterested;

@end

NS_ASSUME_NONNULL_END

