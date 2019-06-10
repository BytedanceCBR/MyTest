//
//  TTVDetailRelatedRecommendCellViewModel.h
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//

#import <Foundation/Foundation.h>
#import "TTVVideoDetailNatantPGCViewModel.h"

@protocol TTVDetailRelatedRecommendCellViewModelProtocol <NSObject>

//用户个人信息
@property (nonatomic, strong, readonly)NSString *userId;
@property (nonatomic, strong, readonly)NSString *name;
@property (nonatomic, strong, readonly)NSString *avatarUrl;
@property (nonatomic, strong, readonly)NSString *desc;
@property (nonatomic, strong, readonly)NSString *schema;
@property (nonatomic, strong, readonly)NSString *userAuthInfo;
//被推荐用户与该用户的关系信息
@property (nonatomic, strong)NSNumber *isFollowing;
@property (nonatomic, strong)NSNumber *isFollowed;
@property (nonatomic, strong)NSNumber *isFriend;

@property (nonatomic, strong, readonly)NSString *recommendReason;  //推荐理由
@property (nonatomic, strong, readonly)NSNumber *recommendType;    //推荐类型
@property (nonatomic, strong ,readonly)NSString *userDecoration;
@end

/**
 * 服务端返回的数据
 */

//被推荐用户的个人信息
@interface TTVDetailFollowUserRecommendInfoModelUserInfo : JSONModel

@property (nonatomic, strong)NSString<Optional> *user_id;
@property (nonatomic, strong)NSString<Optional> *name;
@property (nonatomic, strong)NSString<Optional> *avatar_url;
@property (nonatomic, strong)NSString<Optional> *desc;
@property (nonatomic, strong)NSString<Optional> *schema;
@property (nonatomic, strong)NSString<Optional> *user_auth_info;
@property (nonatomic, strong)NSString<Optional> *user_decoration;
@end

//被推荐用户与该用户的关系信息
@interface TTVDetailFollowUserRecommendInfoModelUserRelation : JSONModel

@property (nonatomic, strong)NSNumber<Optional> *is_following;
@property (nonatomic, strong)NSNumber<Optional> *is_followed;
@property (nonatomic, strong)NSNumber<Optional> *is_friend;

@end

@interface TTVDetailFollowUserRecommendInfoModelUser : JSONModel

@property (strong, nonatomic)TTVDetailFollowUserRecommendInfoModelUserRelation<Optional> *relation;//用户关系信息
@property (strong, nonatomic)TTVDetailFollowUserRecommendInfoModelUserInfo<Optional> *info; //卡片内的用户信息

@end

@interface TTVDetailFollowUserRecommendInfoModel : JSONModel

@property (strong, nonatomic)TTVDetailFollowUserRecommendInfoModelUser<Optional> *user;//被推荐用户
@property (nonatomic, strong)NSString *recommend_reason;  //推荐理由
@property (nonatomic, strong)NSNumber *recommend_type;    //推荐类型

@end

@interface TTVDetailRelatedRecommendCellViewModel : NSObject <TTVDetailRelatedRecommendCellViewModelProtocol>

@property (nonatomic, strong)TTVDetailFollowUserRecommendInfoModel *infoModel;

@end

