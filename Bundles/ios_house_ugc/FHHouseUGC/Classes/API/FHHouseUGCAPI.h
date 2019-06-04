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

+ (TTHttpTask *)requestFeedListWithCategory:(NSString *)category behotTime:(double)behotTime loadMore:(BOOL)loadMore listCount:(NSInteger)listCount completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
