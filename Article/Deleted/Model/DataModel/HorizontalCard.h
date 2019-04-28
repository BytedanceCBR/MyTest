//
//  HorizontalCard.h
//  Article
//
//  Created by 王双华 on 2017/5/15.
//
//

#import "ExploreOriginalData.h"

@class TSVShortVideoCategoryFetchManager;
// fake categoryID for article in card
extern  NSString * _Nullable const kHorizontalCardCategoryID;

@interface HorizontalCardMoreModel : NSObject

@property(nonatomic, strong, nullable)NSString *title;
@property(nonatomic, strong, nullable)NSString *urlString;

@end

@interface HorizontalCard : ExploreOriginalData

@property (nullable, nonatomic, copy) NSNumber *cardType;
@property (nullable, nonatomic, copy) NSString *cardTitle;
@property (nullable, nonatomic, retain) NSArray *itemsData;
@property (nullable, nonatomic, copy) NSDictionary *showMore;
@property (nullable, nonatomic, strong) TSVShortVideoCategoryFetchManager *prefetchManager;
@property (nullable, nonatomic, copy) NSNumber *prefetchType;
@property (nullable, nonatomic, copy) NSNumber *cardLayoutStyle;

// 主线程调用,原有卡片里面带的cardItems
- (nullable NSArray *)originalCardItems;

- (void)clearCachedCardItems;

- (void)setAllCardItemsNotInterested;

- (nullable HorizontalCardMoreModel *)showMoreModel;

- (BOOL)isHorizontalScrollEnabled;

// 可能包含预加载的cardItems
- (nullable NSArray *)allCardItems;

@end
