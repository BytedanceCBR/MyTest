//
//  TTPersonalHomeManager.m
//  Article
//
//  Created by wangdi on 2017/3/20.
//
//

#import "TTPersonalHomeManager.h"


@implementation TTPersonalHomeManager

static id _instance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (void)requestPersonalHomeUserInfoWithUserID:(NSString *)userID mediaID:(NSString *)mediaID refer:(NSString *)refer Completion:(void (^)(NSError *error,TTPersonalHomeUserInfoResponseModel *responseModel,FRForumMonitorModel *monitorModel))completion;
{
    TTPersonalHomeUserInfoRequestModel *param = [[TTPersonalHomeUserInfoRequestModel alloc] init];
    param.user_id = userID;
    param.media_id = mediaID;
    param.refer = refer;
    [FRRequestManager requestModel:param callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        TTPersonalHomeUserInfoResponseModel *model = (TTPersonalHomeUserInfoResponseModel *)responseModel;
        if(completion) {
            completion(error,model,monitorModel);
        }
    }];
}

- (void)requestFollowWithUserID:(NSString *)userID action:(FriendActionType)action source:(TTFollowNewSource)source reason:(NSNumber *)reason newReason:(NSNumber *)newReason completion:(void (^)(NSError *error,FriendActionType type, NSDictionary *result))completion
{
    [[TTFollowManager sharedManager] startFollowAction:action userID:userID  platform:nil name:nil from:nil reason:reason newReason:newReason newSource:@(source) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        if(completion) {
            completion(error,type,result);
        }
        
    }];
}

- (void)requestReCommendFollowWithUserID:(NSString *)userID page:(NSString *)page completion:(void (^)(NSError *error, TTPersonalHomeRecommendFollowResponseModel *recommendFollowResponseModel))completion
{
    TTPersonalHomeRecommendFollowRequestModel *param = [[TTPersonalHomeRecommendFollowRequestModel alloc] init];
    param.to_user_id = userID;
    param.page = page;
    [FRRequestManager requestModel:param callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        TTPersonalHomeRecommendFollowResponseModel *model = (TTPersonalHomeRecommendFollowResponseModel *)responseModel;
        if(completion) {
            completion(error,model);
        }
    }];
}


@end
