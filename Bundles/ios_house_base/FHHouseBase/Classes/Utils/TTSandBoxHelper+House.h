//
//  TTSandBoxHelper+House.h
//  FHHouseBase
//
//  Created by 张静 on 2019/6/26.
//

#import "TTSandBoxHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTSandBoxHelper (House)

+ (BOOL)fh_isInHouseApp;

+ (BOOL)isAPPFirstLaunchForAd;

+ (void)setAppFirstLaunchForAd;

+ (BOOL)isInHouseApp;

+ (void)saveAssetCount;

+ (BOOL)hasValidAssetCountSavedLastTime;

+ (NSInteger)assetCountSavedLastTime;

/**
 *  f100发布版本号，在info.plist基础上+600，为了兼容主端
 *
 *  @return 可能为nil
 */
+ (nullable NSString *)fhVersionCode;

@end

NS_ASSUME_NONNULL_END
