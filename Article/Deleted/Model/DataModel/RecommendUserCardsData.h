//
//  RecommendUserCardsData.h
//  Article
//
//  Created by 王双华 on 16/11/30.
//
//

#import "ExploreOriginalData.h"

@class FRRecommendCardStructModel;
@interface RecommendUserCardsData : ExploreOriginalData

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *showMore;
@property (nullable, nonatomic, retain) NSString *showMoreJumpURL;
@property (nullable, nonatomic, retain) NSArray *userCards;
@property (nonatomic, assign) BOOL hasMore;

/**
 *  返回多个用户, 使用List转换
 *
 *  @return
 */
@property (nullable, nonatomic, retain) NSArray<FRRecommendCardStructModel*> *userCardModels;

- (void)setIsFollowed:(BOOL)isFollowed index:(NSUInteger)index;

@end
