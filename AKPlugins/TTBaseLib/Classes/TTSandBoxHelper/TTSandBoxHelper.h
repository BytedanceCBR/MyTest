//
//  TTSandBoxHelper.h
//  Pods
//
//  Created by 冯靖君 on 17/2/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTSandBoxHelper : NSObject
@end

@interface TTSandBoxHelper (TTPlist)

/**
 *  获取info.plist中的CFBundleDisplayName
 *
 *  @return 如果没有，返回CFBundleName
 */
+ (nullable NSString *)appDisplayName;

/**
 *  获取info.plist发布版本号
 *
 *  @return 可能为nil
 */
+ (nullable NSString *)versionName;

/**
 *  获取plist中的CFBundleIdentifier
 *
 *  @return CFBundleIdentifier
 */
+ (nullable NSString*)bundleIdentifier;

/**
 *  获取plist中的CFBundleVersion
 *
 *  @return CFBundleVersion
 */
+ (nonnull NSString *)buildVerion;

/**
 *  获取info.plist中的App Name
 *
 *  @return 可能为nil
 */
+ (nullable NSString *)appName;

/**
 *  判断Target是否为InHouseApp
 *
 *  @return Yes or No
 */
+ (BOOL)isInHouseApp;

/**
 *  获取SSAppID
 *
 *  @return SSAppID
 */
+ (nullable NSString*)ssAppID;

/**
 *  获取info.plist中的SSMID
 *
 *  @return 可能为nil（会打印log信息）
 */
+ (nullable NSString *)ssAppMID;

/**
 *  将SSMID转换
 *
 *  @return snssdk+(SSMID)+://
 */
+ (nullable NSString *)ssAppScheme;

/**
 *  获取plist中的CFBundleURLSchemes
 *
 *  @return CFBundleURLSchemes
 */
+ (nullable NSString *)appOwnURL;

/**
 *  获取下载渠道
 *
 *  @return 下载渠道
*/
+ (nullable NSString *)getCurrentChannel;

/**
 *  判断渠道是否为App Store
 *
 *  @return Yes or No
 */
+ (BOOL)isAppStoreChannel;

@end

@interface TTSandBoxHelper (TTUserDefault)

// 这几个方法注释掉，业务方从installID服务获取
///**
// *  获取NSUserDefaults中的kSSCommonSavedDeviceIDKey信息（兼容版本，当kSSCommonSavedDeviceIDKey不存在时，返回kDeviceIDStorageKey）
// *
// *  @return deviceID
// */
//+ (nullable NSString *)deviceID;
//
///**
// *  保存deviceID至kSSCommonSavedDeviceIDKey
// *
// *  @param deviceID
// */
//+ (void)saveDeviceID:(nullable NSString *)deviceID;
//
///**
// *  存储InstallID
// *
// *  @param installID
// */
//+ (void)saveInstallID:(nullable NSString *)installID;
//
///**
// *  获取installID
// *
// *  @return
// */
//+ (nullable NSString *)installID;

/**
 *  判断APP是否第一次Launch
 *
 *  @return Yes or No
 */
+ (BOOL)isAPPFirstLaunch;

/**
 *  设置APP的第一次启动Launch
 */
+ (void)setAppFirstLaunch;

/**
 *  返回APP启动的次数
 *
 *  @return APP启动的次数
 */
+ (NSInteger)appLaunchedTimes;

/**
 *  应用运行了一次, 只在AppDidFinishLaunchwithoption里面设置1次
 */
+ (void)setAppDidLaunchThisTime;

/**
 *  重置开机启动次数为0
 */
+ (void)resetAppLaunchedTimes;

@end

@interface TTSandBoxHelper (TTFileSystem)

/**
 *  沙盒cache路径
 */
- (NSString *)sandBoxCachePath;

/**
 *  沙盒documents路径
 */
- (NSString *)sandBoxDocumentsPath;
/**
 *  查看路径是否允许备份
 *
 *  @param path path
 *
 *  @return Yes or No
 */
+ (BOOL)disableBackupForPath:(NSString*)path;

@end

@interface TTSandBoxHelper (TTAssetCount)

+ (void)saveAssetCount;

+ (BOOL)hasValidAssetCountSavedLastTime;

+ (NSInteger)assetCountSavedLastTime;

@end

NS_ASSUME_NONNULL_END
