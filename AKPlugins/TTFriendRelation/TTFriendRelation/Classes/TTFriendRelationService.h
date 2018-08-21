//
//  TTFriendRelationService.h
//  Article
//
//  Created by lipeilun on 2017/12/12.
//

#import <Foundation/Foundation.h>
#import "TTServiceCenter.h"
#import "TTFriendRelationEntity.h"

typedef NS_ENUM(NSInteger, TTFriendRelationQueryResult) {
    TTFriendRelationQueryResultSelf = -2,          //是自己
    TTFriendRelationQueryResultUnknown = -1,       //尚没有人写入过数据，所以未知
    TTFriendRelationQueryResultFalse = 0,          //结果为否
    TTFriendRelationQueryResultTrue = 1,           //结果为是
};

@interface TTFriendRelationService : NSObject <TTService>

//-------------------------------------------- 获取entity --------------------------------------



/**
 NOTICE:在不知道数据的情况下尝试获取 TTFriendRelationEntity

 @param uid                 用户ID
 @return                    返回该用户数据或nil
 */
- (TTFriendRelationEntity *)entityWithUnknownDataUserID:(NSString *)uid;

/**
 NOTICE:在知道数据的情况下获取 TTFriendRelationEntity，该方法会更新数据
 
 使用则必须保证数据写入，在后端不提供全量支持前，使用者共同保证数据的准确性
 【若某个地方没有使用此方法输入数据，则不应该使用这里的数据】。因为当前很多独立的接口会获取用户状态，也不会进行存储，
 与数据库中的关注状态也一样会不一致。所以鼓励谁使用，谁维护。
 
 根据已知的数据获取一个entity使用，并根据是否已经存在，添加到表中或更新数据
 
 @param uid                 用户ID
 @param isFollowing         是否关注
 */
- (TTFriendRelationEntity *)entityWithKnownDataUserID:(NSString *)uid certainFollowing:(BOOL)isFollowing;


//-------------------------------------------- 查询entity --------------------------------------


/**
 在不需要实体的时候，纯查询关注状态
 
 @param uid                 用户ID
 @return                    查询结果，TTFriendRelationQueryResultUnknown 说明实体还没有过该用户的信息
 */
- (TTFriendRelationQueryResult)queryFollowingStateUser:(NSString *)uid;

@end
