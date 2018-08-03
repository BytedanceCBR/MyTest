//
//  TSVUserRecommendationModel.h
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/15.
//

#import <JSONModel/JSONModel.h>
#import "TSVUserModel.h"

@interface TSVUserRecommendationModel : JSONModel

@property (nonatomic, strong) TSVUserModel<Optional>    *user;
@property (nonatomic, copy) NSString<Optional>          *recommendReason;  //推荐理由
@property (nonatomic, strong) NSNumber<Optional>        *recommendType;    //推荐类型
@property (nonatomic, copy) NSString<Optional>          *statsPlaceHolder;

@end
