//
//  TSVDownloadManager.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSVDownloadManager : NSObject

+ (BOOL)shouldDownloadAppForGroupSource:(NSString *)groupSource;

+ (void)downloadAppForGroupSource:(NSString *)groupSource
                          urlDict:(NSDictionary *)dict;

+ (void)openAppForGroupSource:(NSString *)groupSource;

+ (void)preloadAppStoreForGroupSourceIfNeeded:(NSString *)groupSource;

@end

NS_ASSUME_NONNULL_END
