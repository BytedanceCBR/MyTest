//
//  TTFollowManager.h
//  Article
//
//  Created by SongChai on 20/06/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTNetworkManager.h"
#import "FRRequestManager.h"
#import "TTFriendRelation_Enums.h"

typedef enum FriendActionType
{
    FriendActionTypeFollow      =   11,
    FriendActionTypeUnfollow    =   12,
    FriendActionTypeInvite      =   13
}FriendActionType;

#define RelationActionSuccessNotification @"RelationActionSuccessNotification"
#define kRelationActionSuccessNotificationActionTypeKey @"kRelationActionSuccessNotificationActionTypeKey"
#define kRelationActionSuccessNotificationBeFollowedStateKey @"kRelationActionSuccessNotificationBeFollowedStateKey"
#define kRelationActionSuccessNotificationUserIDKey @"kRelationActionSuccessNotificationUserIDKey"


@interface TTFollowManager : NSObject

+ (nonnull instancetype)sharedManager;


/**
 批量关注

 @param idArray             用户ID数组
 @param source              对应source
 @param reason
 @param completionClk       回调
 */
- (void)multiFollowUserIdArray:(nonnull NSArray<NSString *> *)idArray
                        source:(TTFollowNewSource)source
                        reason:(NSInteger)reason
                    completion:(nullable FRMonitorNetworkModelFinishBlock)completionClk;


/**
 封装接口
 某接口会改变 单个 用户关注状态时使用

 @param model            request
 @param uid              目标用户ID
 @param type             改变的行为 关注/取消关注
 @param completionClk    回调
 */
- (void)tt_requestWrapperChangedSingleFollowStateModel:(nonnull TTRequestModel *)model
                                                userId:(nonnull NSString *)uid
                                            actionType:(FriendActionType)type
                                            completion:(nullable FRMonitorNetworkModelFinishBlock)completionClk;


/**
 封装接口
 某接口会改变 单个或多个 用户关注状态时使用，可替代前一个接口

 @param model                request
 @param type                 改变的行为 关注/取消关注
 @param resClass             response的类型
 @param userIDKeyPath        response中用户ID的keypath
 @param finalPair            如果返回的是一个数组，且数组中不是用户ID，而是某个别的类型，key-value对应数组中的【类型-用户ID的keypath】
 @param completionClk        回调
 
 可参考 FRUserRelationContactfriendsRequestModel 的使用场景
 */
- (void)tt_requestWrapperChangedUsersFollowStateModel:(nonnull TTRequestModel *)model
                                           actionType:(FriendActionType)type
                                        responseClass:(nullable Class)resClass
                                              keypath:(nullable NSString *)userIDKeyPath
                                       finalClassPair:(nullable NSDictionary<NSString *, NSString *> *)finalPair
                                           completion:(nullable FRMonitorNetworkModelFinishBlock)completionClk;

- (void)follow:(NSDictionary * __nullable)info completion:(void (^ __nullable)(NSError *__nullable error, NSDictionary * __nullable result))completionClk;

- (void)unfollow:(NSDictionary * __nullable)info completion:(void (^ __nullable)(NSError *__nullable error, NSDictionary * __nullable result))completionClk;



- (void)newStartAction:(FriendActionType)actionType
                userID:(nonnull NSString *)userID
              platform:(nullable NSString *)platform
                  name:(nullable NSString *)name
                  from:(nullable NSString *)from
                reason:(nullable NSNumber *)reason
             newReason:(nullable NSNumber *)newReason
             newSource:(nullable NSNumber *)newSource
            completion:(void (^ __nullable)(FriendActionType type, NSError *__nullable error, NSDictionary * __nullable result))completionClk DEPRECATED_MSG_ATTRIBUTE("此接口名字不好，建议使用startFollowAction...替代");

/**
 关注取关统一接口
 */
- (void)startFollowAction:(FriendActionType)actionType
                   userID:(nonnull NSString *)userID
                 platform:(nullable NSString *)platform
                     name:(nullable NSString *)name
                     from:(nullable NSString *)from
                   reason:(nullable NSNumber *)reason
                newReason:(nullable NSNumber *)newReason
                newSource:(nullable NSNumber *)newSource
               completion:(void (^ __nullable)(FriendActionType type, NSError *__nullable error, NSDictionary * __nullable result))completionClk;

@end
