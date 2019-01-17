//
//  FHRentDetailAPI.h
//  Pods
//
//  Created by leo on 2018/11/25.
//

#import <Foundation/Foundation.h>
#import "FHRentDetailResponse.h"

NS_ASSUME_NONNULL_BEGIN
@class TTHttpTask;
@interface FHRentDetailAPI : NSObject
+(TTHttpTask*)requestRentDetail:(NSString*)rentCode
                     completion:(void(^)(FHRentDetailResponseModel * _Nullable model , NSError * _Nullable error))completion;
@end

NS_ASSUME_NONNULL_END
