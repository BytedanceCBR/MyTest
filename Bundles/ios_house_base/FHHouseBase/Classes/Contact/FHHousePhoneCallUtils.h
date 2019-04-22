//
//  FHHousePhoneCallUtils.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHHouseContactConfigModel;

@interface FHHousePhoneCallUtils : NSObject

+ (void)callWithConfig:(NSDictionary *)configDict;
+ (void)callWithConfigModel:(FHHouseContactConfigModel *)configModel;

@end

NS_ASSUME_NONNULL_END
