//
//  TTCanvasBundleManager.h
//  Article
//
//  Created by yin on 2017/1/3.
//
//

#import <Foundation/Foundation.h>

@interface TTAdRNBundleInfo : JSONModel
@property (nonatomic, copy) NSString *md5;
@property (nonatomic, copy) NSString *moduleName;
@property (nonatomic, copy) NSString *requireMinReactVersion;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, assign) NSInteger type; // 0 buildin 1 temp 2 online 3 debug
@end

@interface TTCanvasBundleManager : NSObject

@property (nonatomic, assign) BOOL isDebug;

+ (TTCanvasBundleManager * )sharedInstance;

+ (void)downloadIfNeeded:(NSString *)url version:(NSString *)version md5:(NSString *)md5;

+ (NSURL *)bundleURL;

+ (NSString *)localVersion;

+ (NSString *)RNVersion;

+ (NSURL *)fallbackSourceURL;
- (void)deleteAllBundles;

+ (TTAdRNBundleInfo *)currentCanvasBundleInfo;

@end
