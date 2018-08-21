//
//  ArticleFriends.h
//  Article
//
//  Created by Dianwei on 14-7-21.
//
//

#import <Foundation/Foundation.h>


typedef enum FriendListCellUnitPlatformType{
    FriendListCellUnitPlatformTypeHide = 0,
    FriendListCellUnitPlatformTypeSinaWeibo,
    FriendListCellUnitPlatformTypeTencentWeibo,
    FriendListCellUnitPlatformTypeQQZone,
    FriendListCellUnitPlatformTypeRenRen,
    FriendListCellUnitPlatformTypeKaixin
}FriendListCellUnitPlatformType;

typedef enum FriendListCellUnitRelationButtonType{
    FriendListCellUnitRelationButtonHide = 0,
    FriendListCellUnitRelationButtonLoading,            //等待中...
    FriendListCellUnitRelationButtonFollow,
    FriendListCellUnitRelationButtonCancelFollow,
    FriendListCellUnitRelationButtonFollowingFollowed,   //互相关注
    FriendListCellUnitRelationButtonInviteFriend,       //告诉TA
    FriendListCellUnitRelationButtonInvitedFriend,       //已发送
    
    // 拉黑
    FriendListCellUnitRelationButtonBlock,
    FriendListCellUnitRelationButtonCancelBlock
}FriendListCellUnitRelationButtonType;

typedef enum FriendListCellUnitVerifyType{
    FriendListCellUnitVerifyTypeHide = 0,
    FriendListCellUnitVerifyPGCVerify,
    FriendListCellUnitVerifyUserVerify,
}FriendListCellUnitVerifyType;