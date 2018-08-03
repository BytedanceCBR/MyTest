//
//  TTFriendRelationEntity.h
//  Article
//
//  Created by lipeilun on 2017/11/30.
//

#import <TTEntityBase/TTEntityBase.h>
#import "TTFriendRelationFollowingNotifier.h"


/**
 TTFriendRelationEntity
 用户关系实体
 */
@interface TTFriendRelationEntity : TTEntityBase <TTFriendRelationNotifyProtocol>
@property (nonatomic, strong) NSString *userID;                                             //目标用户ID
@property (nonatomic, assign) BOOL isFollowing;                                             //是否已经关注
@property (nonatomic, strong, readonly) TTFriendRelationFollowingNotifier *notifier;       //通知器
@end
