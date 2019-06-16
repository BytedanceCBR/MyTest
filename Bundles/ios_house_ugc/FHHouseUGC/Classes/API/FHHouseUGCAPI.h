//
//  FHHouseUGCAPI.h
//  FHHouseUGC
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager.h>
#import <FHHouseBase/FHURLSettings.h>
#import <FHHouseBase/FHHouseType.h>
#import <FHHouseBase/FHMainApi.h>

@class TTHttpTask;

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseUGCAPI : NSObject

+ (TTHttpTask *)requestTopicList:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestCommunityDetail:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)joinCommunity:(NSString *)communityId join:(BOOL)join :class :(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

+ (TTHttpTask *)requestFeedListWithCategory:(NSString *)category behotTime:(double)behotTime loadMore:(BOOL)loadMore listCount:(NSInteger)listCount completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
