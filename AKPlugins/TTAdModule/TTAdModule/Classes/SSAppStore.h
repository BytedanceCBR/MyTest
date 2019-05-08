//
//  SSAppStore.h
//  Article
//
//  Created by Zhang Leonardo on 12-11-30.
//
//

#import <Foundation/Foundation.h>

extern NSString * const SKStoreProductViewDidAppearKey;
extern NSString * const SKStoreProductViewDidDisappearKey;
extern NSString * const SKStoreProductViewWillDisappearKey;

@protocol TTAppStoreProtocol <NSObject>

/**
 appStore加载状态

 @param result 是否成功
 @param error 错误信息
 */
- (void)appStoreLoad:(BOOL)result error:(NSError *)error appleId:(NSString*)appleId;

/**
 app store页面展现

 @param viewController skContoller
 */
- (void)appStoreDidAppear:(UIViewController*)viewController;

/**
 app store页面消失
 
 @param viewController skContoller
 */
- (void)appStoreDidDisappear:(UIViewController *)viewController;

- (BOOL)openAppStoreAppleID:(NSString*)appleID controller:(UIViewController*)controller;

@end

@interface SSAppStore : NSObject

+ (instancetype)shareInstance;

- (BOOL)registerService:(id<TTAppStoreProtocol>)service;

- (BOOL)unregisterService:(id<TTAppStoreProtocol>)service;

- (void)openAppStoreByActionURL:(NSString *)actionURL itunesID:(NSString *)appleID presentController:(UIViewController *)controller;
- (void)openAppStoreByActionURL:(NSString *)actionURL itunesID:(NSString *)appleID presentController:(UIViewController *)controller appName:(NSString *)appName;

@end
