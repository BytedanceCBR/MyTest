//
//  FHHouseFollowUpHelper.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHHouseFollowUpConfigModel;

@interface FHHouseFollowUpHelper : NSObject

+ (void)silentFollowHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel;
+ (void)silentFollowHouseWithConfig:(NSDictionary *)config;
+ (void)followHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel;
+ (void)followHouseWithConfig:(NSDictionary *)config;
+ (void)cancelFollowHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel;
+ (void)cancelFollowHouseWithConfig:(NSDictionary *)config;


@end

NS_ASSUME_NONNULL_END
