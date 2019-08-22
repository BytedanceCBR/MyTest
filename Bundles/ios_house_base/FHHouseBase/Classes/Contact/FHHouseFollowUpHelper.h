//
//  FHHouseFollowUpHelper.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import <Foundation/Foundation.h>
#import "FHHouseFollowUpConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFollowUpHelper : NSObject

+ (void)silentFollowHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel;
+ (void)silentFollowHouseWithConfig:(NSDictionary *)config;
+ (void)silentFollowHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel completionBlock:(void(^)(BOOL isSuccess))completionBlock;
+ (void)followHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel;
+ (void)followHouseWithConfig:(NSDictionary *)config;
+ (void)cancelFollowHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel;
+ (void)cancelFollowHouseWithConfig:(NSDictionary *)config;
+(void)showFollowToast;

@end

NS_ASSUME_NONNULL_END
