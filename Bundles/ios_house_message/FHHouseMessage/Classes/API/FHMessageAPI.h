//
//  FHMessageAPI.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager.h>
#import "FHURLSettings.h"
#import "FHMainApi.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,FHMessageType) {
    FHMessageTypeNew          = 300, //新房
    FHMessageTypeOld          = 301, //二手房
    FHMessageTypeRent         = 302, //租房
    FHMessageTypeNeighborhood = 303, //小区
    FHMessageTypeHouseOld     = 307, //房源推荐-二手房
    FHMessageTypeSystem       = 308, //系统消息
    FHMessageTypeHouseRent    = 309, //房源推荐-租房
};

@interface FHMessageAPI : NSObject

+ (TTHttpTask *)requestMessageListWithCompletion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

+ (TTHttpTask *)requestSysMessageWithListId:(NSInteger)listId maxCoursor:(NSString *)maxCoursor completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

+ (TTHttpTask *)requestHouseMessageWithListId:(NSInteger)listId maxCoursor:(NSString *)maxCoursor searchId:(nullable NSString *)searchId completion:(void(^_Nullable)(id<FHBaseModelProtocol> model , NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
