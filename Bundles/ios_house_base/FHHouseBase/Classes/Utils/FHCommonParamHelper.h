//
//  FHCommonParamHelper.h
//  FHHouseBase
//
//  Created by bytedance on 2020/10/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCommonParamHelper : NSObject

+ (NSDictionary *)generateRequestCommonParams:(NSDictionary *)cacheParams;

@end

NS_ASSUME_NONNULL_END
