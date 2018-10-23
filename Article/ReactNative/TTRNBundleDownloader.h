//
//  TTRNBundleDownloader.h
//  Article
//
//  Created by yangning on 2017/4/28.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TTRNBundleDownloaderCompletionBlock)(NSString *_Nullable cacheBundlePath, NSError *_Nullable error);

@interface TTRNBundleDownloader : NSObject

+ (instancetype)sharedDownloader;

- (void)downloadBundleForModuleName:(NSString *)moduleName
                                url:(NSURL *)url
                            isPatch:(BOOL)isPatch
                          bundleMD5:(nullable NSString *)bundleMD5
                         completion:(nullable TTRNBundleDownloaderCompletionBlock)completion;



- (BOOL)cacheBundleFileExistsForModuleName:(NSString *)moduleName;

- (NSString *)cacheBundleFilePathForModuleName:(NSString *)moduleName;

- (NSString *)bundleRootDirectory;

- (NSString *)cachedDirectoryNameForModuleName:(NSString *)moduleName;

@end

NS_ASSUME_NONNULL_END
