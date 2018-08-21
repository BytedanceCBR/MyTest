//
//  TTVDetailRelatedRecommendCellViewModel.m
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//

#import "TTVDetailRelatedRecommendCellViewModel.h"

@implementation TTVDetailRelatedRecommendCellViewModel

- (NSString *)userDecoration
{
    return self.infoModel.user.info.user_decoration;
}

- (NSString *)userId{
    return self.infoModel.user.info.user_id;
}

- (NSString *)userAuthInfo{
    return  self.infoModel.user.info.user_auth_info;
}

- (NSString *)name{
    return self.infoModel.user.info.name;
}

- (NSString *)desc{
    return self.infoModel.user.info.desc;
}

- (NSString *)avatarUrl{
    return self.infoModel.user.info.avatar_url;
}

- (NSString *)schema{
    return self.infoModel.user.info.schema;
}

- (NSNumber *)isFriend{
    return self.infoModel.user.relation.is_friend;
}

- (NSNumber *)isFollowed{
    return self.infoModel.user.relation.is_followed;
}

- (NSNumber *)isFollowing{
    return self.infoModel.user.relation.is_following;
}

- (NSNumber *)recommendType{
    return self.infoModel.recommend_type;
}

- (NSString *)recommendReason{
    return self.infoModel.recommend_reason;
}

- (void)setIsFriend:(NSNumber *)isFriend{
    self.infoModel.user.relation.is_friend = isFriend;
}

- (void)setIsFollowed:(NSNumber *)isFollowed{
    self.infoModel.user.relation.is_followed = isFollowed;
}

- (void)setIsFollowing:(NSNumber *)isFollowing{
    self.infoModel.user.relation.is_following = isFollowing;
}

@end

@implementation TTVDetailFollowUserRecommendInfoModel

@end

@implementation TTVDetailFollowUserRecommendInfoModelUser

@end

@implementation TTVDetailFollowUserRecommendInfoModelUserRelation

@end

@implementation TTVDetailFollowUserRecommendInfoModelUserInfo

@end


