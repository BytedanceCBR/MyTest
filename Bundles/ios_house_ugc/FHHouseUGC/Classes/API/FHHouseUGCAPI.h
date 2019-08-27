//
//  FHHouseUGCAPI.h
//  FHHouseUGC
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager.h>
#import <FHHouseBase/FHURLSettings.h>
#import <FHHouseBase/FHHouseType.h>
#import <FHHouseBase/FHMainApi.h>
#import <FHHouseBase/FHCommonApi.h>

@class TTHttpTask;

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseUGCAPI : NSObject

// UGC config 入口
+ (void)loadUgcConfigEntrance;

+ (TTHttpTask *)requestTopicList:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestCommunityDetail:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestFeedListWithCategory:(NSString *)category behotTime:(double)behotTime loadMore:(BOOL)loadMore listCount:(NSInteger)listCount completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestFeedListWithCategory:(NSString *)categoryId offset:(NSInteger)offset loadMore:(BOOL)loadMore completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestForumFeedListWithForumId:(NSString *)forumId offset:(NSInteger)offset loadMore:(BOOL)loadMore completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// type 用户关注的类型，类型int，0/不传:不限制，1:小区，2:话题，3:用户
+ (TTHttpTask *)requestFollowListByType:(NSInteger)type class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// action 0 取消关注 1 关注
+ (TTHttpTask *)requestFollow:(NSString *)group_id action:(NSInteger)action completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion;

// 小区搜索
+ (TTHttpTask *)requestSocialSearchByText:(NSString *)text class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 我感兴趣小区列表
+ (TTHttpTask *)requestRecommendSocialGroupsWithSource:(NSString *)source latitude:(CGFloat)latitude longitude:(CGFloat)longitude class:(Class)cls completion:(void (^)(id <FHBaseModelProtocol> model, NSError *error))completion;

// ugc配置
+ (TTHttpTask *)requestUGCConfig:(Class)cls completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion;

// 删除帖子
+ (TTHttpTask *)postDelete:(NSString *)groupId socialGroupId:(NSString *)socialGroupId enterFrom:(NSString *)enterFrom pageType:(NSString *)pageType completion:(void(^)(bool success , NSError *error))completion;

// 评论详情
+ (TTHttpTask *)requestCommentDetailDataWithCommentId:(NSString *)comment_id socialGroupId:(NSString *)socialGroupId  class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 评论回复列表
+ (TTHttpTask *)requestReplyListWithCommentId:(NSString *)comment_id offset:(NSInteger)offset class:(Class)cls completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion;

// 小区列表（按区域，推荐，关注等获取）
+ (TTHttpTask *)requestCommunityList:(NSInteger)districtId source:(NSString *)source latitude:(CGFloat)latitude longitude:(CGFloat)longitude class:(Class)cls completion:(void (^)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 获取feed列表是否有新内容
+ (TTHttpTask *)refreshFeedTips:(NSString *)category beHotTime:(NSString *)beHotTime completion:(void(^)(bool hasNew , NSError *error))completion;

// 获取话题头部
+ (TTHttpTask *)requestTopicHeader:(NSString *)forum_id completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion;

// 获取话题列表
+ (TTHttpTask *)requestTopicList:(NSString *)forum_id completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
