//
//  TTRNKitHelper.h
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/11.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface TTRNKitRouteParams : NSObject

@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *segment;
@property (nonatomic, copy) NSDictionary *queryParams;

@end

@interface TTRNKitHelper : NSObject
+ (BOOL)isEmptyString:(NSString *)str;
+ (UIViewController *)findWrapperController:(UIView *)view;
+ (void)closeViewController:(UIViewController *)viewController;
+ (UIView *)getLoadingViewWith:(NSString *)className size:(CGSize)size;
+ (TTRNKitRouteParams *)routeParamObjWithString:(NSString *)str;
//LRU
+ (void)initLRUList;
+ (void)insertURL:(id)url withValue:(id)value useLRU:(BOOL)lru;
+ (void)deleteURL:(NSURL *)url;
+ (void)trimToCount:(NSInteger)count;
+ (id)getValueForURL:(NSURL *)url updateLRU:(BOOL)update;

#if DEBUG
+ (NSString *)LRUListDebugDescription;
#endif

#ifdef __cplusplus             //告诉编译器，这部分代码按C语言的格式进行编译，而不是C++的
extern "C" {
#endif

    NSString *geckoBundleDirPathForGeckoParams(NSDictionary *geckoParams, NSString *channel);
    NSString *geckoBundlePathForGeckoParams(NSDictionary *geckoParams, NSString *channel);
    NSString *bundleIdentifierWithBundlePathAndVersion(NSString *bundlePath, NSString *version);
    NSString *commonBundleVersionForGeckoParams(NSDictionary *geckoParams);
    NSArray *geckoBundleInfoForGeckoParams(NSDictionary *geckoParams, NSString *channel);
    NSURL *bundleUrlForGeckoParams(NSDictionary *geckoParams, NSString *channel);
    void initLRUList();
#ifdef __cplusplus
}
#endif
@end
