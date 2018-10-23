//
//  TSVRecommendCardUserViewModel.m
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/17.
//

#import "TSVUserRecommendationViewModel.h"
#import "TSVUserRecommendationModel.h"
#import "AWEVideoPlayAccountBridge.h"
#import "AWEVideoDetailTracker.h"
#import "ReactiveObjC.h"
#import "AWEVideoUserInfoManager.h"
#import "HTSVideoPlayToast.h"
#import "AWEUserModel.h"
#import "TTTrackerWrapper.h"

@interface TSVUserRecommendationViewModel()

@property (nonatomic, strong) TSVUserRecommendationModel *model;
@property (nonatomic, assign) BOOL isStartFollowLoading;

@end

@implementation TSVUserRecommendationViewModel

- (instancetype)initWithModel:(TSVUserRecommendationModel *)model
{
    self = [super init];
    if (self) {
        self.model = model;
        
        @weakify(self);
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"RelationActionSuccessNotification"
                                                               object:nil]
         subscribeNext:^(NSNotification * _Nullable x) {
             @strongify(self);
             NSString *userID = x.userInfo[@"kRelationActionSuccessNotificationUserIDKey"];
             if ([self.model.user.userID isEqualToString:userID]) {
                 NSInteger actionType = [(NSNumber *)x.userInfo[@"kRelationActionSuccessNotificationActionTypeKey"] integerValue];
                 if (actionType == 11) {//关注
                     self.model.user.isFollowing = YES;
                     if (self.followButtonClick) {
                         self.followButtonClick(nil);
                     }
                 } else if (actionType == 12) {//取消关注
                     self.model.user.isFollowing = NO;
                 }
             }
         }];
    }
    return self;
}

- (void)clickFollowButton
{
    NSString *userId = self.model.user.userID;

    if ([AWEVideoPlayAccountBridge isCurrentLoginUser:self.model.user.userID]) {
        return;
    }
    
    self.isStartFollowLoading = YES;
    if (!self.model.user.isFollowing) {
        @weakify(self);
        //关注
        [self trackEventWithFollowAction:YES];
        
        [AWEVideoUserInfoManager followUser:self.model.user.userID completion:^(AWEUserModel *user, NSError *error) {
            @strongify(self);
            if (self && error) {
                NSString *prompts = error.userInfo[@"prompts"] ?: @"关注失败，请稍后重试";
                [HTSVideoPlayToast show:prompts];
            } else if (self) {
                self.model.user.isFollowing = user.isFollowing;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RelationActionSuccessNotification" object:self
                                                                  userInfo:@{
                                                                             @"kRelationActionSuccessNotificationUserIDKey": userId ?: @"",
                                                                             @"kRelationActionSuccessNotificationActionTypeKey": @11
                                                                             }
                 ];
            }
            
            if (self.followButtonClick) {
                self.followButtonClick(error);
            }
            self.isStartFollowLoading = NO;
        }];
    } else {
        //取消关注
        [self trackEventWithFollowAction:NO];

        @weakify(self);
        [AWEVideoUserInfoManager unfollowUser:userId completion:^(AWEUserModel *user, NSError *error) {
            @strongify(self);
            if (self && error) {
                NSString *prompts = error.userInfo[@"prompts"] ?: @"取消关注失败，请稍后重试";
                [HTSVideoPlayToast show:prompts];
            } else if (self) {
                self.model.user.isFollowing = user.isFollowing;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RelationActionSuccessNotification" object:self
                                                                  userInfo:@{
                                                                             @"kRelationActionSuccessNotificationUserIDKey": userId ?: @"",
                                                                             @"kRelationActionSuccessNotificationActionTypeKey": @12 }
                 ];
            }
            self.isStartFollowLoading = NO;
        }];
    }
}

- (void)trackEventWithFollowAction:(BOOL)isFollow
{
    NSString *eventName = isFollow? @"rt_follow" : @"rt_unfollow";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:self.commonParameter];
    [params setValue:self.model.user.userID forKey:@"to_user_id"];
    [params setValue:@"from_recommend" forKey:@"follow_type"];
    [params setValue:@(self.index + 1) forKey:@"order"];
    [params setValue:@"91" forKey:@"server_source"];
    [params setValue:self.detailPageUserID forKey:@"profile_user_id"];
    [params setValue:@"list" forKey:@"positon"];
    [params setValue:@"shortvideo_detail_follow_card" forKey:@"source"];
    [params setValue:self.listEntrance forKey:@"list_entrance"];
    [params setValue:self.logPb forKey:@"log_pb"];
    [TTTracker eventV3:eventName params:[params copy]];
}

@end
