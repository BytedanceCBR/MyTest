//
//  ExploreEntryHelper.h
//  Article
//
//  Created by Zhang Leonardo on 14-11-25.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ExploreEntry.h"
#import "PGCAccount.h"

@interface ExploreEntryHelper : NSObject

+ (NSDictionary *)parseEntryDictByPGCDict:(NSDictionary *)dict;


/**
 *  判断该entry是否是当前用户的entry
 *
 *  @param entry 待判断entry
 *
 *  @return YES: 是当前登录用户的entry
 */
+ (BOOL)isLoginUserEntry:(ExploreEntry *)entry;

/**
 *  ExploreEntry 到PGCAccount的转换， 临时方法， 未来逐渐废弃PGCAccount
 *
 *  @param entry 需要转换的Entry
 *
 *  @return 转换后的PGCAccount
 */
+ (PGCAccount *)transToPGCAccountFromEntry:(ExploreEntry *)entry;

/**
 *  PGCAccount到ExploreEntry的转换， 临时方法， 未来逐渐废弃PGCAccount
 *
 *  @param entry 需要转换的Account
 *
 *  @return 转换后的 ExploreEntry
 */
+ (ExploreEntry *)transToEntryFromPGCAccount:(PGCAccount *)account;


//+ (ExploreEntry *)transToEntryWithMid:(NSString *)mid;

@end
