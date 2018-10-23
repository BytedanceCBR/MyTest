//
//  TTVersionHelper.h
//  Article
//
//  Created by xushuangqing on 2017/5/21.
//
//

#import <Foundation/Foundation.h>

@interface TTVersionHelper : NSObject


/**
 本次启动是否是更新后首次启动
 */
+ (BOOL)isFirstLaunchAfterUpdate;

/**
 当前版本号
 */
+ (NSString *)currentVersion;

/**
 上次启动时的版本号
 */
+ (NSString *)lastLaunchVersion;

/**
 上次更新的时间
 */
+ (double)lastUpdateTimestamp;

/**
 更新前的版本
 */
+ (NSString *)lastUpdateVersion;

@end
