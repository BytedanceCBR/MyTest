//
//  FHHousePhoneCallUtils.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import <Foundation/Foundation.h>
#import "FHHouseContactConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHousePhoneCallUtils : NSObject

+ (void)callWithConfig:(NSDictionary *)configDict;
+ (void)callWithConfigModel:(FHHouseContactConfigModel *)configModel;

@end

NS_ASSUME_NONNULL_END
