//
//  FRForumOnlooksManager.m
//  Article
//
//  Created by ZhangLeonardo on 15/7/17.
//
//

#import "FRForumOnlooksManager.h"
#import "FRApiModel.h"
#import "FRForumEntity.h"

NSString *const kForumLikeStatusChangeNotification = @"kForumLikeStatusChangeNotification";
NSString *const kForumLikeStatusChangeForumIDKey   = @"kForumLikeStatusChangeForumIDKey";
NSString *const kForumLikeStatusChangeForumLikeKey = @"kForumLikeStatusChangeForumLikeKey";

@implementation FRForumOnlooksManager

+ (void)switchFollowStatus:(FRForumEntity *)entity
{
    if (entity.like_time > 0) {
        [self unonlooksForForumID:entity.forum_id callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
            if (error.code == TTNetworkErrorCodeSuccess) {
                entity.like_time = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:kFRForumEntityFollowChangeNotification object:self userInfo:nil];
            }
        }];
    } else {
        [self onlooksForForumID:entity.forum_id callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
            if (error.code == TTNetworkErrorCodeSuccess) {
                entity.like_time = [[NSDate date] timeIntervalSince1970];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFRForumEntityFollowChangeNotification object:self userInfo:nil];
            }
        }];
    }
}

+ (void)unonlooksForForumID:(int64_t)fid callback:(TTNetworkResponseModelFinishBlock)callback
{
    FRTtdiscussV1CommitUnfollowforumRequestModel *request = [[FRTtdiscussV1CommitUnfollowforumRequestModel alloc] init];
    request.forum_id = @(fid);
    
    [[TTNetworkManager shareInstance] requestModel:request callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (!error) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:@(fid) forKey:kForumLikeStatusChangeForumIDKey];
            [userInfo setValue:@(NO) forKey:kForumLikeStatusChangeForumLikeKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:kForumLikeStatusChangeNotification object:self userInfo:userInfo];
        }
        
        if (callback) {
            callback(error, responseModel);
        }
    }];
    
}

+ (void)onlooksForForumID:(int64_t)fid callback:(TTNetworkResponseModelFinishBlock)callback
{
    FRTtdiscussV1CommitFollowforumRequestModel *request = [[FRTtdiscussV1CommitFollowforumRequestModel alloc] init];
    request.forum_id = @(fid);
    
    [[TTNetworkManager shareInstance] requestModel:request callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (!error) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:@(fid) forKey:kForumLikeStatusChangeForumIDKey];
            [userInfo setValue:@(YES) forKey:kForumLikeStatusChangeForumLikeKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:kForumLikeStatusChangeNotification object:self userInfo:userInfo];
        }
        
        if (callback) {
            callback(error, responseModel);
        }
    }];
}

@end
