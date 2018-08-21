//
//  TSVRecommendCardModel.h
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/15.
//

#import <JSONModel/JSONModel.h>
@class TSVUserRecommendationModel;
@protocol TSVUserRecommendationModel;

@interface TSVRecommendCardModel : JSONModel

@property (nonatomic, assign) BOOL  hasMore;
@property (nonatomic, copy) NSArray<TSVUserRecommendationModel *><TSVUserRecommendationModel, Optional> *userCards;

@end
