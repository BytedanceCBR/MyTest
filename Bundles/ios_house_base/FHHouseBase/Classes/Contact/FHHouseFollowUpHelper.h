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

+ (void)followHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel;

+ (void)cancelFollowHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel;

+ (void)showFollowToast;

@end

NS_ASSUME_NONNULL_END
