//
//  TSVRecommendCardUserViewModel.h
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/17.
//

#import <Foundation/Foundation.h>
@class TSVUserRecommendationModel;

@interface TSVUserRecommendationViewModel : NSObject

@property (nonatomic, readonly) TSVUserRecommendationModel *model;
@property (nonatomic, readonly) BOOL isStartFollowLoading;

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) NSString *detailPageUserID;
@property (nonatomic, copy) NSString *listEntrance;
@property (nonatomic, copy) NSDictionary *logPb;
@property (nonatomic, copy) NSDictionary *commonParameter;
@property (nonatomic, copy) void (^followButtonClick)(NSError *error);

- (instancetype)initWithModel:(TSVUserRecommendationModel *)model;

- (void)clickFollowButton;

@end
