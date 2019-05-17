//
//  TTPersonalHomeManager.h
//  Article
//
//  Created by wangdi on 2017/3/20.
//
//

#import <Foundation/Foundation.h>
#import "TTPersonalHomeUserInfoResponseModel.h"
#import "TTPersonalHomeRecommendFollowResponseModel.h"
#import "FriendDataManager.h"
#import "FRRequestManager.h"

@interface TTPersonalHomeManager : NSObject

+ (instancetype)sharedInstance;

- (void)requestPersonalHomeUserInfoWithUserID:(NSString *)userID mediaID:(NSString *)mediaID refer:(NSString *)refer Completion:(void (^)(NSError *error,TTPersonalHomeUserInfoResponseModel *responseModel,FRForumMonitorModel *monitorModel))completion;

- (void)requestFollowWithUserID:(NSString *)userID action:(FriendActionType)action source:(TTFollowNewSource)source reason:(NSNumber *)reason newReason:(NSNumber *)newReason completion:(void (^)(NSError *error,FriendActionType type, NSDictionary *result))completion;

- (void)requestReCommendFollowWithUserID:(NSString *)userID page:(NSString *)page completion:(void (^)(NSError *error,TTPersonalHomeRecommendFollowResponseModel *recommendFollowResponseModel))completion;


@end
