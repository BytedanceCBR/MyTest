//
//  TTFollowManager.m
//  Article
//
//  Created by SongChai on 20/06/2017.
//
//

#import "TTFollowManager.h"
#import <TTAccountBusiness.h>
#import "TTModuleBridge.h"
#import "ExploreEntryManager.h"
#import "TTURLDomainHelper.h"
#import "TTFriendRelationService.h"
#import "FRApiModel.h"

extern NSString * const TTFollowSuccessForPushGuideNotification;

@interface TTFollowURLSetting : NSObject

+ (NSString*)followURLString;
+ (NSString*)unfollowURLString;
+ (NSString*)inviteURLString;

@end

@implementation TTFollowURLSetting

+ (NSString*)followURLString
{
    return [NSString stringWithFormat:@"%@/2/relation/follow/v2/", [self baseURL]];
}

+ (NSString*)unfollowURLString
{
    return [NSString stringWithFormat:@"%@/2/relation/unfollow/", [self baseURL]];
}

+ (NSString*)inviteURLString
{
    return [NSString stringWithFormat:@"%@/2/relation/invite/", [self baseURL]];
}

+ (NSString*)baseURL {
    return [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
}

@end


@implementation TTFollowManager

+ (instancetype)sharedManager {
    static TTFollowManager* s_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[TTFollowManager alloc] init];
    });
    return s_manager;
}


#pragma - follow/unfollow

- (void)multiFollowUserIdArray:(NSArray<NSString *> *)idArray
                        source:(TTFollowNewSource)source
                        reason:(NSInteger)reason
                    completion:(FRMonitorNetworkModelFinishBlock)completionClk {
    if (SSIsEmptyArray(idArray)) {
        return;
    }
    
    NSString *followStr = [idArray componentsJoinedByString:@","];
    FRUserRelationMfollowRequestModel *requestModel = [FRUserRelationMfollowRequestModel new];
    requestModel.to_user_list = followStr;
    if (source > 0) requestModel.source = @(source);
    requestModel.reason = @(reason);
    [FRRequestManager requestModel:requestModel callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        for (NSString *userID in idArray) {
            [TTFollowManager updateUserFollowStateChangeForAction:FriendActionTypeFollow userID:userID];
        }
        
        if (completionClk) {
            completionClk(error, responseModel, monitorModel);
        }
    }];
}

- (void)tt_requestWrapperChangedSingleFollowStateModel:(TTRequestModel *)model
                                                userId:(NSString *)uid
                                            actionType:(FriendActionType)type
                                            completion:(FRMonitorNetworkModelFinishBlock)completionClk {
    [FRRequestManager requestModel:model callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        [TTFollowManager updateUserFollowStateChangeForAction:type userID:uid];
        
        if (completionClk) {
            completionClk(error, responseModel, monitorModel);
        }
    }];
}


- (void)tt_requestWrapperChangedUsersFollowStateModel:(TTRequestModel *)model
                                           actionType:(FriendActionType)type
                                        responseClass:(nullable Class)resClass
                                              keypath:(nullable NSString *)userIDKeyPath
                                       finalClassPair:(nullable NSDictionary<NSString *, NSString *> *)finalPair
                                           completion:(nullable FRMonitorNetworkModelFinishBlock)completionClk {
    [FRRequestManager requestModel:model callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        if ([responseModel isKindOfClass:resClass]) {
            id userObject = [responseModel valueForKeyPath:userIDKeyPath];
            
            if ([userObject isKindOfClass:[NSString class]]) {
                [TTFollowManager updateUserFollowStateChangeForAction:type userID:userObject];
            } else if ([userObject isKindOfClass:[NSArray class]]) {
                for (id singleUser in userObject) {
                    if ([singleUser isKindOfClass:[NSString class]]) {
                        [TTFollowManager updateUserFollowStateChangeForAction:type userID:singleUser];
                    } else if ([singleUser isKindOfClass:NSClassFromString([[finalPair allKeys] firstObject])]) {
                        id uidObject = [singleUser valueForKeyPath:[finalPair objectForKey:NSStringFromClass([singleUser class])]];
                        if ([uidObject isKindOfClass:[NSString class]]) {
                            [TTFollowManager updateUserFollowStateChangeForAction:type userID:uidObject];
                        }
                    }
                }
            }
        }
        
        if (completionClk) {
            completionClk(error, responseModel, monitorModel);
        }
    }];
    
}

- (void)follow:(NSDictionary *)info completion:(void (^ __nullable)(NSError *__nullable error, NSDictionary * __nullable result))completionClk {
    [self follow:info action:FriendActionTypeFollow completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        if (completionClk) {
            completionClk(error, result);
        }
    }];
}

- (void)unfollow:(NSDictionary *)info completion:(void (^ __nullable)(NSError *__nullable error, NSDictionary * __nullable result))completionClk {
    [self follow:info action:FriendActionTypeUnfollow completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        if (completionClk) {
            completionClk(error, result);
        }
    }];
}

- (void)follow:(NSDictionary *)info action:(FriendActionType)type completion:(void (^ __nullable)(FriendActionType type, NSError *__nullable error, NSDictionary * __nullable result))completionClk {
    NSString *userID    = [info tt_stringValueForKey:@"id"];
    NSNumber *newReason = @([info tt_integerValueForKey:@"new_reason"]);
    NSNumber *newSource = @([info tt_integerValueForKey:@"new_source"]);
    NSString *from      = [info tt_stringValueForKey:@"from"];
    [self newStartAction:type userID:userID platform:nil name:nil from:from reason:nil newReason:newReason newSource:newSource completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        if (completionClk) {
            completionClk(type, error, result);
        }
    }];
}

- (void)newStartAction:(FriendActionType)actionType
                userID:(nonnull NSString *)userID
              platform:(nullable NSString *)platform
                  name:(nullable NSString *)name
                  from:(nullable NSString *)from
                reason:(nullable NSNumber *)reason
             newReason:(nullable NSNumber *)newReason
             newSource:(nullable NSNumber *)newSource
            completion:(void (^ __nullable)(FriendActionType type, NSError *__nullable error, NSDictionary * __nullable result))completionClk {
    [self startFollowAction:actionType
                     userID:userID
                   platform:platform
                       name:name
                       from:from
                     reason:reason
                  newReason:newReason
                  newSource:newSource
                 completion:completionClk];
}

// name is only for invite action
- (void)startFollowAction:(FriendActionType)actionType
                   userID:(nonnull NSString *)userID
                 platform:(nullable NSString *)platform
                     name:(nullable NSString *)name
                     from:(nullable NSString *)from
                   reason:(nullable NSNumber *)reason
                newReason:(nullable NSNumber *)newReason
                newSource:(nullable NSNumber *)newSource
               completion:(void (^ __nullable)(FriendActionType type, NSError *__nullable error, NSDictionary * __nullable result))completionClk {
    NSString *urlString = nil;
    
    void(^monitorBlock)(NSError *error,NSString *userID,FriendActionType action) = ^(NSError *error,NSString *userID,FriendActionType action){
        
        NSInteger status = [[FRForumNetWorkMonitor sharedInstance] monitorStatusWithNetError:error];
        if (error && [error.domain isEqualToString:@"kCommonErrorDomain"]) {
            status = kTTNetworkMonitorFollowActionStatusError;
        }
        
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:userID forKey:@"user_id"];
        [extra setValue:error.domain forKey:@"error_domain"];
        [extra setValue:@(error.code) forKey:@"error_code"];
        NSString *description;
        if([error.userInfo tt_stringValueForKey:@"urlErrorCode"]){
            description  = [error.userInfo tt_stringValueForKey:@"urlErrorCode"];
        }
        else{
            description  = [error.userInfo tt_stringValueForKey:@"description"];
        }
        [extra setValue:description forKey:@"error_description"];
        NSString *message = [error.userInfo tt_stringValueForKey:@"server_old_error_code"];
        [extra setValue:message forKey:@"error_message"];
        
        if (actionType == FriendActionTypeFollow) {
             [[TTMonitor shareManager] trackService:@"ugc_friend_follow" status:status extra:nil];
        }
        else if (actionType == FriendActionTypeUnfollow){
            [[TTMonitor shareManager] trackService:@"ugc_friend_unfollow" status:status extra:nil];
        }
        else if (actionType == FriendActionTypeInvite){
            [[TTMonitor shareManager] trackService:@"ugc_friend_invite" status:status extra:nil];
        }
    };
    
    switch (actionType) {
        case FriendActionTypeFollow:
        {
            urlString = [TTFollowURLSetting followURLString];
        }
            break;
        case FriendActionTypeUnfollow:
        {
            urlString = [TTFollowURLSetting unfollowURLString];
        }
            break;
        case FriendActionTypeInvite:
        {
            if(![TTAccountManager isLogin]) {
                if (completionClk) {
                    
                    NSError *error =  [NSError errorWithDomain:@"kCommonErrorDomain" code:1007 userInfo:nil];
                    completionClk(actionType, error, nil);
                    if (monitorBlock) {
                        monitorBlock(error,userID,actionType);
                    }
                }
                return;
            }
            
            urlString = [TTFollowURLSetting inviteURLString];
        }
            break;
        default:
        {
#ifdef DEBUG
            @throw [NSException exceptionWithName:@"FriendDataManagerException" reason:@"unkown action type" userInfo:nil];
#endif
        }
            break;
    }
    
    if (isEmptyString(urlString)) {
        
        NSError *error =  [NSError errorWithDomain:@"kCommonErrorDomain" code:1010 userInfo:@{@"urlErrorCode": @"url is empty"}];
        if (completionClk)
            completionClk(actionType, [NSError errorWithDomain:@"kCommonErrorDomain" code:1010 userInfo:@{@"urlErrorCode": @"url is empty"}], nil);
        
        if (monitorBlock) {
            monitorBlock(error,userID,actionType);
        }
        
        return;
    }
    
    NSMutableDictionary *getParams = [self commonURLParameters];
    if(actionType == FriendActionTypeInvite) {
        [getParams setValue:userID forKey:@"uid"];
        [getParams setValue:name forKey:@"name"];
    } else {
        [getParams setValue:userID forKey:@"user_id"];
    }
    if (platform) {
        [getParams setValue:platform forKey:@"platform"];
    }
    if (from) {
        [getParams setValue:from forKey:@"source"];
    }
    if (reason) {
        [getParams setValue:reason forKey:@"reason"];
    }
    if (!newSource) {
        newSource = @(0);
    }
    [getParams setValue:newSource forKey:@"new_source"];
    if (!newReason) {
        newReason = @(0);
    }
    [getParams setValue:newReason forKey:@"new_reason"];

    [FRRequestManager requestForJSONWithURL:urlString params:getParams method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSDictionary *result = (jsonObj ? @{@"result": jsonObj} : nil);
        if (!error && (actionType == FriendActionTypeFollow || actionType == FriendActionTypeUnfollow)) {
            NSDictionary *user = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_dictionaryValueForKey:@"user"];
            NSString *userID = [user tt_stringValueForKey:@"user_id"];
            NSString *mediaID = [user tt_stringValueForKey:@"media_id"];
            BOOL isFollowing = [user tt_boolValueForKey:@"is_following"];
            BOOL isFollowed = [user tt_boolValueForKey:@"is_followed"];
            [GET_SERVICE(TTFriendRelationService) entityWithKnownDataUserID:userID certainFollowing:isFollowing];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:RelationActionSuccessNotification object:self userInfo:@{kRelationActionSuccessNotificationActionTypeKey : [NSNumber numberWithInt:actionType], kRelationActionSuccessNotificationUserIDKey: (isEmptyString(userID)?@"":userID),
                                                                                                                                    kRelationActionSuccessNotificationBeFollowedStateKey : [NSNumber numberWithBool:isFollowed]}];
                
                // 如果有mediaID,同时发一个订阅状态变化通知
                if (!isEmptyString(mediaID)) {
                    [self notifyMediaID:mediaID isFollowing:isFollowing];
                }
            });
        }
        
        if ([error.domain isEqualToString:kTTNetworkServerDataFormatErrorDomain] && !isEmptyString([error.userInfo tt_stringValueForKey:@"description"])) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[error.userInfo objectForKey:@"description"] indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        }
        
        if (completionClk) {
            completionClk(actionType, error, result);
        }

        if (!error && (FriendActionTypeFollow == actionType)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTFollowSuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(2)}];
        }
        if (monitorBlock) {
            monitorBlock(error,userID,actionType);
        }
        
    }];
}

#pragma mark - private


/**
 统一更新用户数据

 @param type                操作行为
 @param uid                 用户ID
 */
+ (void)updateUserFollowStateChangeForAction:(FriendActionType)type userID:(id)uidObj {
    if (!uidObj || ![uidObj isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSString *uid = (NSString *)uidObj;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!isEmptyString(uid)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RelationActionSuccessNotification
                                                                object:nil
                                                              userInfo:@{kRelationActionSuccessNotificationActionTypeKey : @(type),
                                                                         kRelationActionSuccessNotificationUserIDKey : uid}];
        }
    });
}

- (NSMutableDictionary *)commonURLParameters
{
    __block NSMutableDictionary *dic ;
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"commonURLParameters" object:nil withParams:nil complete:^(id  _Nullable result) {
        dic = [result mutableCopy];
    }];
    return dic;
}

- (void)notifyMediaID:(NSString *)mediaID isFollowing:(BOOL)isFollowing {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:mediaID forKey:@"id"];
    [dic setValue:@(isFollowing) forKey:@"is_subscribed"];
    [dic setValue:@1 forKey:@"type"];
    [dic setValue:[NSNumber numberWithLongLong:mediaID.longLongValue] forKey:@"media_id"];
    [dic setValue:mediaID forKey:@"entry_id"];
    
    ExploreEntry *entry = [[ExploreEntryManager sharedManager] insertExploreEntry:dic save:YES];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:entry forKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEntrySubscribeStatusChangedNotification object:nil userInfo:dict];
}

@end
