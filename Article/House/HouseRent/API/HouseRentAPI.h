//
//  HouseRentAPI.h
//  Article
//
//  Created by leo on 2018/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TTHttpTask;
@interface HouseRentAPI : NSObject
+(TTHttpTask*)requestHouseRentRelated;
@end

NS_ASSUME_NONNULL_END
