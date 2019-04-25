//
//  TTTabBarProvider.h
//  Article
//
//  Created by fengyadong on 2017/12/15.
//

#import <Foundation/Foundation.h>
#import "TTTabBarManager.h"

extern NSString *kTTMiddleTabDidChangeNotification;

@interface TTTabBarProvider : NSObject

+ (UINavigationController *)naviVCForIdentifier:(NSString *)identifier;
+ (UIViewController *)rootVCForIdentifier:(NSString *)identifier;

+ (NSArray<NSString *> *)allSupportedTags;
+ (NSString *)priorMiddleTabIdentifier;
+ (NSString *)priorMiddleTabSchema;
+ (NSArray<NSString *> *)confTabList;

+ (BOOL)hasPriorMiddleTab;//正常tab
+ (BOOL)hasCustomMiddleButton;//伪tab实际上是一个button
+ (BOOL)isPublishButtonOnTabBar;
+ (BOOL)isMineTabOnTabBar;
+ (BOOL)isHTSTabOnTabBar;
+ (BOOL)isFollowTabOnTabBar;
+ (BOOL)isWeitoutiaoOnTabBar;

+ (NSString *)currentSelectedTabTag;

+ (BOOL)isPublishButtonOnTopBar;

+ (BOOL)isValidForMiddleTabIdenftifier:(NSString *)identifier;

@end
