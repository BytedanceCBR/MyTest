//
//  PGCAccountManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-10-17.
//
//  记录当前用户的PGC账号

#import <Foundation/Foundation.h>
#import "PGCAccount.h"



#define kLoginPGCAccountChangedNotification @"kLoginPGCAccountChangedNotification"

@interface PGCAccountManager : NSObject

+ (PGCAccountManager *)shareManager;

- (BOOL)hasPGCAccount;

- (BOOL)isMyPGC:(NSString *)mediaID;

- (PGCAccount *)currentLoginPGCAccount;

- (void)saveCurrentPGCAccount:(PGCAccount *)account;

+ (void)synchronizePGCAccount;

@end
