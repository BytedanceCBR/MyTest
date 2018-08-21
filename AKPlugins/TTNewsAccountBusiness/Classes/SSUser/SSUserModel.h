//
//  SSUserModel.h
//  Article
//
//  Created by Dianwei on 14-5-21.
//
//

#import "SSUserBaseModel.h"



typedef NS_ENUM(NSInteger, SSUserRoleType) {
    SSUserRoleTypeOfNormal = 0,
    SSUserRoleTypeOfMaster      //管理员
};

typedef NS_ENUM(NSUInteger, SSUserRelationType) {
    SSUserRelationTypeNone, //未关注
    SSUserRelationTypeFollow,//已关注
    SSUserRelationTypeFriend,//好友(互相关注)
};

@interface  SSUserRoleModel : NSObject<NSCoding>

@property(nonatomic, copy) NSString *ID; // 该属性对外部只读

@property (assign, nonatomic) NSUInteger roleDisplayType;

//原来是这样的 改成NSUInteger
//@property (assign, nonatomic) FRRoleDisplayType roleDisplayType;


@property (strong, nonatomic) NSString *roleName;
@end

@interface SSUserModel : SSUserBaseModel

+ (NSArray*)usersWithArray:(NSArray*)data;
//@property(nonatomic, assign, getter = isVerified)BOOL verified;
@property(nonatomic, assign) BOOL isFriend;
@property(nonatomic, assign) SSUserRoleType role;
@property(nonatomic, strong) SSUserRoleModel * userRole;
@property(nonatomic, assign) SSUserRelationType relation;
@property(nonatomic, assign) BOOL isOwner; //是否为动态详情页的楼主

@end
