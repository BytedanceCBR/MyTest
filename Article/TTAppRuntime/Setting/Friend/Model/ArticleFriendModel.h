//
//  ArticleFriendModel.h
//  Article
//
//  Created by Dianwei on 14-7-20.
//
//

#import "SSUserFriendModel.h"
#import "PGCAccount.h"
#import "ArticleFriend.h"
#import "SSUserModel.h"

// 新版好友格式

typedef NS_ENUM(NSInteger, ArticleFriendSuggestType){
    ArticleFriendSuggestJoinedNone  = 0,
    ArticleFriendSuggestJoined      = 1, // 平台好友
    ArticleFriendSuggestSuggest     = 2, // 系统推荐用户
    ArticleFriendSuggestFollower    = 3, // 粉丝
    ArticleFriendSuggestFollowing   = 4, // 关注
};

@interface ArticleFriendModel : SSUserFriendModel<NSCoding>
@property(nonatomic, strong)PGCAccount *pgcAccount;
@property(nonatomic, assign)ArticleFriendSuggestType suggestType;
@property(nonatomic, assign)int reasonType;// 回传，表示推荐理由
@property(nonatomic, strong)NSString *platformString;
@property(nonatomic, assign) NSUInteger newSource; // 新的页面信息
@property(nonatomic, assign) NSUInteger newReason; // 新的关注原因信息
// 用户绑定的平台对应的名字
@property(nonatomic, strong)NSString *platformScreenName;
// 4.2版本新增，如果用户类型为通讯录则展示通讯录名字，忽略该字段，如果用户不是通讯录则显示该字段值，该字段显示推荐理由
@property(nonatomic, strong)NSString *recommendReason;
@property (nonatomic, copy) NSString *mobileHash;
- (BOOL)isAccountUser;

// 兼容旧代码
- (ArticleFriend*)articleFriend;
- (SSUserModel *)userModel;

- (NSString *)titleString;
- (NSString *)subtitle1String;
- (NSString *)subtitle2String;
@end
