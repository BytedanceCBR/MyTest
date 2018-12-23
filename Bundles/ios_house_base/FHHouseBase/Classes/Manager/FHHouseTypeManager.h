//
//  FHHouseTypeManager.h
//  FHHouseBase
//
//  Created by 张元科 on 2018/12/23.
//

#import <Foundation/Foundation.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseTypeManager : NSObject

+(instancetype)sharedInstance;

- (NSString *)searchBarPlaceholderForType:(FHHouseType)houseType;
- (NSString *)traceValueForType:(FHHouseType)houseType;
- (NSString *)stringValueForType:(FHHouseType)houseType;

@end

NS_ASSUME_NONNULL_END
