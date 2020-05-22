//
//  FHHousePhoneCallUtils.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import <Foundation/Foundation.h>
#import "FHHouseContactConfigModel.h"

#import "FHAssociatePhoneModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface FHHousePhoneCallUtils : NSObject

#pragma mark - refator
+ (void)callWithAssociatePhoneDict:(NSDictionary *)associatePhoneDict completion:(FHHousePhoneCallCompletionBlock)completionBlock;
+ (void)callWithAssociatePhoneModel:(FHAssociatePhoneModel *)associatePhoneModel completion:(FHHousePhoneCallCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
