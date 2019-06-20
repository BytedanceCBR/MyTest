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

+ (TTHttpTask *)requestTopicList:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestCommunityDetail:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)joinCommunity:(NSString *)communityId join:(BOOL)join :class :(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestFeedListWithCategory:(NSString *)category behotTime:(double)behotTime loadMore:(BOOL)loadMore listCount:(NSInteger)listCount completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// type 用户关注的类型，类型int，0/不传:不限制，1:小区，2:话题，3:用户
+ (TTHttpTask *)requestFollowListByType:(NSInteger)type class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

// action 0 取消关注 1 关注
+ (TTHttpTask *)requestFollow:(NSString *)group_id action:(NSInteger)action completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion;

// 小区搜索
+ (TTHttpTask *)requestSocialSearchByText:(NSString *)text class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
