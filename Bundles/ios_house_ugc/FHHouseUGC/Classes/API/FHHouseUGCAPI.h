//
//  FHHouseUGCAPI.h
//  FHHouseUGC
//

#import <Foundation/Foundation.h>
#import "TTNetworkManager.h"
#import <FHHouseBase/FHURLSettings.h>
#import <FHHouseBase/FHHouseType.h>
#import <FHHouseBase/FHMainApi.h>
#import <FHHouseBase/FHCommonApi.h>
#import "TTHTTPRequestSerializerBase.h"

@class TTHttpTask;
@class FHUGCNoticeModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseUGCAPI : NSObject

// UGC config 入口
+ (void)loadUgcConfigEntrance;

+ (TTHttpTask *)requestAllForumWithClass:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestTopicList:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestCommunityDetail:(NSString *)communityId tabName:(NSString *)tabName class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestFeedListWithCategory:(NSString *)category behotTime:(double)behotTime loadMore:(BOOL)loadMore listCount:(NSInteger)listCount extraDic:(NSDictionary *)extraDic completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

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
+ (TTHttpTask *)postDelete:(NSString *)groupId cellType:(NSInteger)cellType socialGroupId:(NSString *)socialGroupId enterFrom:(NSString *)enterFrom pageType:(NSString *)pageType completion:(void(^)(bool success , NSError *error))completion;

// 管理员操作帖子
+ (TTHttpTask *)postOperation:(NSString *)groupId cellType:(NSInteger)cellType socialGroupId:(NSString *)socialGroupId operationCode:(NSString *)operationCode enterFrom:(NSString *)enterFrom pageType:(NSString *)pageType completion:(void (^ _Nonnull)(id<FHBaseModelProtocol> model, NSError *error))completion;

// 评论详情
+ (TTHttpTask *)requestCommentDetailDataWithCommentId:(NSString *)comment_id socialGroupId:(NSString *)socialGroupId  class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 评论回复列表
+ (TTHttpTask *)requestReplyListWithCommentId:(NSString *)comment_id offset:(NSInteger)offset class:(Class)cls completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion;

// 小区列表（按区域，推荐，关注等获取）
+ (TTHttpTask *)requestCommunityList:(NSInteger)districtId source:(NSString *)source latitude:(CGFloat)latitude longitude:(CGFloat)longitude class:(Class)cls completion:(void (^)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 获取feed列表是否有新内容
+ (TTHttpTask *)refreshFeedTips:(NSString *)category beHotTime:(double)beHotTime completion:(void(^)(bool hasNew ,NSTimeInterval interval,NSTimeInterval cacheDuration, NSError *error))completion;

// 获取话题头部
+ (TTHttpTask *)requestTopicHeader:(NSString *)forum_id completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion;

// 获取话题Feed列表
+ (TTHttpTask *)requestTopicList:(NSString *)query_id tab_id:(NSString *)tab_id categoryName:(NSString *)category offset:(NSInteger)offset count:(NSInteger)count appExtraParams:(NSString *)appExtraParams completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion;

// 管理员修改公告信息及通知用户
+ (TTHttpTask *)requestUpdateUGCNoticeWithParam:(NSDictionary *)params class:(Class)cls completion:(void (^)(FHUGCNoticeModel *model, NSError *error))completion;

//请求评论列表
+ (TTHttpTask *)requestMyCommentListWithUserId:(NSString *)userId offset:(NSInteger)offset completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

//请求个人主页  个人信息
+ (TTHttpTask *)requestHomePageInfoWithUserId:(NSString *)userId completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestHomePageFeedListWithUserId:(NSString *)userId offset:(NSInteger)offset count:(NSInteger)count completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestFocusListWithUserId:(NSString *)userId completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 请求圈子用户关注列表
+ (TTHttpTask *)requestFollowUserListBySocialGroupId:(NSString *)socialGroupId offset:(NSInteger)offset class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 请求用户关注列表sug
+ (TTHttpTask *)requestFollowSugSearchByText:(NSString *)text socialGroupId:(NSString *)socialGroupId offset:(NSInteger)offset class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 投票发布器发布请求
+ (TTHttpTask *)requestVotePublishWithParam: (NSDictionary *)params class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 投票
// 提交投票
+ (TTHttpTask *)requestVoteSubmit:(NSString *)voteId optionIDs:(NSArray *)optionIds optionNum:(NSNumber *)optionNum class:(Class)cls completion:(void(^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 取消投票
+ (TTHttpTask *)requestVoteCancel:(NSString *)voteId optionNum:(NSNumber *)optionNum completion:(void(^)(BOOL success , NSError *error))completion;

// 提问发布请求
+ (TTHttpTask *)requestPublishWendaWithParam: (NSDictionary *)params class:(Class)cls completion:(void (^_Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 帖子编辑历史
+ (TTHttpTask *)requestPostHistoryByGroupId:(NSString *)gid offset:(NSInteger)offset class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// Feed编辑帖子发布请求
+ (TTHttpTask *)requestPublishEditedPostWithParam:(NSDictionary *)params  class:(Class)cls completion:(void (^_Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// 发布器热门标签
+ (TTHttpTask *)requestPublishHotTagsWithParam:(NSDictionary *)params class:(Class)cls completion:(void (^_Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestSpecialTopicContentWithTabId:(NSString *)tabId queryPath:(NSString *)queryPath categoryName:(NSString *)categoryName queryId:(NSString *)queryId extraDic:(NSDictionary *)extraDic completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestSpecialTopicHeaderWithforumId:(NSString *)forumId completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END

// POST JSON 提交
@interface FHVoteHTTPRequestSerializer : TTHTTPRequestSerializerBase<TTHTTPRequestSerializerProtocol>

@end
