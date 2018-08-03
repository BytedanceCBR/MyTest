//
//  NSUserDefaultsAdditions.h
//  Base
//
//  Created by Tu Jianfeng on 6/14/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    firstTimeTypeAppDelegate,
    firstTimeTypeHomePage,
    firstTimeTypeDetailPage
} firstTimeType;

typedef enum {
    everyTimeRunTypeAppDelegate,
    everyTimeRunTypeHomePage,
    everyTimeRunTypeDetailPage
} everyTimeRunType;

@interface NSUserDefaults (SSCategory)

+ (NSString *)standardStringForKey:(NSString *)defaultName;
+ (BOOL)boolForKey:(NSString *)key;
+ (void)saveBoolForKey:(NSString *)key boolValue:(BOOL)value;
+ (BOOL)firstTimeRun;
+ (BOOL)firstTimeRunByType:(firstTimeType)type;   // default set 1 when return
+ (BOOL)firstTimeRunByKey:(NSString *)defaultKey;   // default not set 1 when return
+ (void)setNotFirstTimeRunByKey:(NSString *)defaultKey;
+ (void)resetEveryTimeRunDefaults;
+ (BOOL)everyTimeRunByType:(everyTimeRunType)type;

@end
