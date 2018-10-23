//
//  TTPersonalHomeRecommendFollowResponseModel.m
//  Article
//
//  Created by wangdi on 2017/3/22.
//
//

#import "TTPersonalHomeRecommendFollowResponseModel.h"

@implementation TTPersonalHomeRecommendFollowRequestModel

- (instancetype)init
{
    if(self = [super init]) {
        self._host = [CommonURLSetting baseURL];
        self._uri = @"/2/relation/follow_recommends/";
        self._method = @"GET";
        self._response = NSStringFromClass([TTPersonalHomeRecommendFollowResponseModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    if(!isEmptyString(self.page)) {
        dict[@"page"] = self.page;
    }
    if(!isEmptyString(self.to_user_id)) {
        dict[@"to_user_id"] = self.to_user_id;
    }
    return dict;
}

@end

@implementation TTPersonalHomeRecommendFollowDataResponseModel

@end

@implementation TTPersonalHomeRecommendFollowResponseModel

@end
