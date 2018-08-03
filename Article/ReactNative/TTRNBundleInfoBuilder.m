//
//  TTRNBundleInfoBuilder.m
//  Article
//
//  Created by yangning on 2017/4/28.
//
//

#import "TTRNBundleInfoBuilder.h"

NSString *const TTRNBundleModuleName   = @"moduleName";
NSString *const TTRNBundleUrl          = @"bundleUrl";
NSString *const TTRNBundleVersion      = @"version";
NSString *const TTRNBundleMD5          = @"md5";
NSString *const TTRNBundleFallbackUrl  = @"fallbackUrl";
NSString *const TTRNBundleRNMinVersion = @"rnMinVersion";
NSString *const TTRNBundleNameInApp    = @"bundleNameInApp";
NSString *const TTRNBundleBitmask      = @"bitmask";
NSString *const TTRNBundleDirty        = @"dirty";

@implementation TTRNBundleInfoBuilder

+ (instancetype)builderWithInfo:(NSDictionary *)info
{
    TTRNBundleInfoBuilder *builder = [TTRNBundleInfoBuilder new];
    builder.bundleUrl = info[TTRNBundleUrl];
    builder.version = info[TTRNBundleVersion];
    builder.md5 = info[TTRNBundleMD5];
    builder.fallbackUrl = info[TTRNBundleFallbackUrl];
    builder.rnMinVersion = info[TTRNBundleRNMinVersion];
    builder.bundleNameInApp = info[TTRNBundleNameInApp];
    builder.bitmask = info[TTRNBundleBitmask];
    builder.dirty = info[TTRNBundleDirty];
    return builder;
}

- (NSDictionary *)info
{
    return @{
             TTRNBundleUrl         : self.bundleUrl ? : @"",
             TTRNBundleVersion     : self.version ? : @"",
             TTRNBundleMD5         : self.md5 ? : @"",
             TTRNBundleFallbackUrl : self.fallbackUrl ? : @"",
             TTRNBundleRNMinVersion: self.rnMinVersion ? : @"",
             TTRNBundleNameInApp   : self.bundleNameInApp ? : @"",
             TTRNBundleBitmask     : self.bitmask ? : @"",
             TTRNBundleDirty       : @([self.dirty boolValue]),
             };
}

@end
