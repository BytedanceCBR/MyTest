//
//  TTRNBundleManager.h
//  Article
//
//  Created by Chen Hong on 16/7/21.
//
//

#import <Foundation/Foundation.h>
#import "TTRNBundleInfoBuilder.h"
#import <React/RCTBridgeModule.h>

typedef NS_ENUM(NSInteger, TTRNBundleUpdatePolicy) {
    TTRNBundleUpdateDefaultPolicy        = 0,
    TTRNBundleUseBundleInAppIfVersionLow = 1,
};

// https://wiki.bytedance.net/pages/viewpage.action?pageId=95650574
typedef NS_OPTIONS(int64_t, TTRNBundleBitMask) {
    TTRNBundleFeedWidgetCommon        = 1 << 1,  // 通用
    TTRNBundleFeedWidgetSport         = 1 << 2,  // 体育
    TTRNBundleFeedWidgetMovie         = 1 << 3,  // 电影
    TTRNBundleFeedWidgetFinance       = 1 << 4,  // 财经
    TTRNBundleFeedWidgetLive          = 1 << 5,  // 直播
    TTRNBundleFeedWidgetLocal         = 1 << 6,  // 本地
    TTRNBundleFeedWidgetEntertainment = 1 << 7,  // 娱乐
};

NS_ASSUME_NONNULL_BEGIN

extern NSString *const TTRNWidgetBundleName;
extern NSString *const TTRNCommonBundleName;


typedef void(^TTRNBundleUpdateCompletionBlock)(NSURL *_Nullable localBundleURL, BOOL update, NSError *_Nullable error);

@interface TTRNBundleManager : NSObject <RCTBridgeModule>

+ (TTRNBundleManager *)sharedManager;

- (nullable NSURL *)localBundleURLForModuleName:(NSString *)moduleName;

- (NSDictionary *)localBundleInfoForModuleName:(NSString *)moduleName;

- (NSInteger)localBundleVersionForModuleName:(NSString *)moduleName;

- (void)updateBundleForModuleName:(NSString *)moduleName
                       bundleInfo:(void(^)(TTRNBundleInfoBuilder *builder))newBlock
                     updatePolicy:(TTRNBundleUpdatePolicy)policy
                       completion:(nullable TTRNBundleUpdateCompletionBlock)completion;

- (void)deleteCachedBundleForModuleName:(NSString *)moduleName;

- (void)deleteAllBundles;

- (NSString *)RNVersion;

- (BOOL)supportRNVersion:(NSString *)rnVersion;

// bundle支持功能，bitmask表示（目前仅用于feed接口）
- (NSString *)bitMaskStringForModuleName:(NSString *)moduleName;

- (void)setLocalBundleDirty:(BOOL)dirty forModuleName:(NSString *)moduleName;
- (BOOL)localBundleDirtyForModuleName:(NSString *)moduleName;

// 本地调试相关
@property (nonatomic, copy) NSString *devHost;
@property (nonatomic) BOOL devEnable;


@end

NS_ASSUME_NONNULL_END
