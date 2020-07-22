//
//  FHBrowseHistoryAPI.h
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/7/13.
//

#import <Foundation/Foundation.h>
#import "TTNetworkManager.h"
#import "FHMainApi.h"
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FHBrowseHistoryType) {
    FHBrowseHistoryTypeNew = 1,
    FHBrowseHistoryTypeOld = 2,
    FHBrowseHistoryTypeRent = 3,
    FHBrowseHistoryTypeNeighborhood = 4
};

@interface FHBrowseHistoryAPI : NSObject

+ (TTHttpTask *)requestBrowseHistoryWithCount:(NSInteger)count houseType:(FHHouseType)houseType offset:(NSInteger)offset class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
