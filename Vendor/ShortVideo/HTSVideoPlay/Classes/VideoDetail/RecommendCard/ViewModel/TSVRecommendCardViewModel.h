//
//  TSVRecommendCardViewModel.h
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/15.
//

#import <Foundation/Foundation.h>
#import "SSImpressionManager.h"

@class TSVRecommendCardModel;
@class TSVUserRecommendationViewModel;

@interface TSVRecommendCardViewModel : NSObject 

@property (nonatomic, copy) NSDictionary *commonParameter;
@property (nonatomic, copy) NSString *detailPageUserID;
@property (nonatomic, copy) NSString *listEntrance;
@property (nonatomic, copy) NSDictionary *logPb;

@property (nonatomic, readonly) NSArray *userCards;
@property (nonatomic, readonly) BOOL isRecommendCardFinishFetching;
@property (nonatomic, readonly) BOOL isRecommendCardShowing;
@property (nonatomic, readonly) BOOL scrollAfterFollowed;
@property (nonatomic, readonly) BOOL resetContentOffset;

- (void)fetchRecommendArrayWithUserID:(NSString *)userID;

- (void)didSelectItemAtIndex:(NSUInteger)index;

- (TSVUserRecommendationViewModel *)viewModelAtIndex:(NSUInteger)index;

- (void)processImpressionAtIndex:(NSIndexPath *)indexPath status:(SSImpressionStatus)status;

- (void)resetContentOffsetIfNeed;

- (void)viewWillAppear;

- (void)viewWillDisappear;

@end
