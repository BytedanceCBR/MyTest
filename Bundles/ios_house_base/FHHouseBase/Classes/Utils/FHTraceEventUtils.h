//
//  FHTraceEventUtils.h
//  FHHouseBase
//
//  Created by fupeidong on 2019/1/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHTraceEventUtils : NSObject

+ (NSString *) generateEnterfrom:(NSString *)categoryName;
+ (NSString *)generateEnterfrom:(NSString *)categoryName enterFrom:(NSString *)enterFrom;
@end

NS_ASSUME_NONNULL_END
