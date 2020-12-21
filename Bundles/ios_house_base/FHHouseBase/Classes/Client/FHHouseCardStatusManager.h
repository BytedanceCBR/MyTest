//
//  FHHouseCardManager.h
//  FHHouseBase
//
//  Created by xubinbin on 2020/12/21.
//

#import <Foundation/Foundation.h>
#import "FHHouseType.h"

const float FHHouseCardReadOpacity = 0.6;

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseCardStatusManager : NSObject

+ (instancetype)sharedInstance;

- (void)readHouseId:(NSString *)houseId withHouseType:(NSInteger)houseType;

- (BOOL)isReadHouseId:(NSString *)houseId withHouseType:(NSInteger)houseType;

@end

NS_ASSUME_NONNULL_END
