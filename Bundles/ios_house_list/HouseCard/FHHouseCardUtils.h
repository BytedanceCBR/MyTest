//
//  FHHouseCardUtils.h
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseCardUtils : NSObject

+ (NSDictionary *)supportCellStyleMap;

+ (NSObject *)getEntityFromModel:(id)model;

@end

NS_ASSUME_NONNULL_END
