//
//  TTRNBundleInfoBuilder.h
//  Article
//
//  Created by yangning on 2017/4/28.
//
//

#import <Foundation/Foundation.h>

extern NSString *const TTRNBundleModuleName;
extern NSString *const TTRNBundleUrl;
extern NSString *const TTRNBundleVersion;
extern NSString *const TTRNBundleMD5;
extern NSString *const TTRNBundleFallbackUrl;
extern NSString *const TTRNBundleRNMinVersion;
extern NSString *const TTRNBundleNameInApp;
extern NSString *const TTRNBundleBitmask;
extern NSString *const TTRNBundleDirty;

@interface TTRNBundleInfoBuilder : NSObject

@property (nonatomic, copy) NSString *bundleUrl; // required
@property (nonatomic, copy) NSString *version; // required
@property (nonatomic, copy) NSString *md5; // optional
@property (nonatomic, copy) NSString *fallbackUrl; // required
@property (nonatomic, copy) NSString *rnMinVersion; // optional
@property (nonatomic, copy) NSString *bundleNameInApp; // optional
@property (nonatomic, copy) NSString *bitmask; // 扩展字段，bundle支持功能（bitmask表示），optional
@property (nonatomic, copy) NSNumber *dirty; // bundle是否可用，optional
@property (nonatomic, copy) NSString *patchUrl; // 是否是patch形式，optional
@property (nonatomic, copy) NSString *patchMD5; // 是否PatchMD5校验，optional

+ (instancetype)builderWithInfo:(NSDictionary *)info;
- (NSDictionary *)info;

@end
