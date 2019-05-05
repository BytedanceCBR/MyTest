//
//  TTPersonalHomeRecommendFollowResponseModel.h
//  Article
//
//  Created by wangdi on 2017/3/22.
//
//


#import "TTResponseModel.h"
#import "TTRequestModel.h"
#import "TTRecommendModel.h"

@protocol TTRecommendModel <NSObject>
@end

@interface TTPersonalHomeRecommendFollowRequestModel : TTRequestModel

@property (nonatomic, copy) NSString *to_user_id;
@property (nonatomic, copy) NSString *page;

@end

@interface TTPersonalHomeRecommendFollowDataResponseModel : TTResponseModel

@property (nonatomic, strong) NSArray<TTRecommendModel> *recommend_users;

@end

@interface TTPersonalHomeRecommendFollowResponseModel : TTResponseModel

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) TTPersonalHomeRecommendFollowDataResponseModel *data;

@end
