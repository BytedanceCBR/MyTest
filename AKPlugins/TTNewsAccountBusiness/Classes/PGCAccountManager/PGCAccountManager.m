//
//  PGCAccountManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-10-17.
//
//

#import "PGCAccountManager.h"
#import <TTStringHelper.h>
#import "TTAccountManager.h"



#define kCurrentPGCAccountKey @"kCurrentPGCAccountKey"

static PGCAccountManager * pgcAccountManager;

@implementation PGCAccountManager

+ (PGCAccountManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pgcAccountManager = [[PGCAccountManager alloc] init];
    });
    return pgcAccountManager;
}

#pragma mark - public

- (BOOL)hasPGCAccount
{
    if (![TTAccountManager isLogin]) {
        return NO;
    }
    if (isEmptyString([self currentLoginPGCAccount].mediaID)) {
        return NO;
    }
    return YES;
}

- (BOOL)isMyPGC:(NSString *)mediaID
{
    if (![TTAccountManager isLogin]) {
        return NO;
    }
    
    PGCAccount *account = [self currentLoginPGCAccount];
    
    if (!account) return NO;
    
    // 如果不是字符串，转成字符串
    NSString *mediaIDStr = [NSString stringWithFormat:@"%@", mediaID];
    NSString *myMediaIDStr = [NSString stringWithFormat:@"%@", account.mediaID];
    
    return [myMediaIDStr isEqualToString:mediaIDStr];
}

- (PGCAccount *)currentLoginPGCAccount
{
    return [PGCAccountManager loginPGCAccount];
}

- (void)saveCurrentPGCAccount:(PGCAccount *)account
{
    [PGCAccountManager savecurrentPGCAccount:account];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginPGCAccountChangedNotification object:nil];
}

+ (void)synchronizePGCAccount
{
    if ([TTAccountManager isLogin]) {
        TTAccountMediaUserEntity *mediaUser = [TTAccountManager currentUser].media;
        if ([[[TTAccountManager currentUser] mediaIDString] length] > 0) {
            PGCAccount *pgcAccount = [[self shareManager] currentLoginPGCAccount];
            if (!pgcAccount) {
                pgcAccount = [PGCAccount new];
            }
            pgcAccount.mediaID = [[TTAccountManager currentUser] mediaIDString];
            pgcAccount.avatarURLString = mediaUser.avatarURL;
            pgcAccount.screenName = mediaUser.name;
            
            [[self shareManager] saveCurrentPGCAccount:pgcAccount];
        } else {
            [[self shareManager] saveCurrentPGCAccount:nil];
        }
    } else {
        [[self shareManager] saveCurrentPGCAccount:nil];
    }
}

#pragma mark - private

- (void)removePGCAccount
{
    [PGCAccountManager savecurrentPGCAccount:nil];
}

#pragma mark - static util

+ (void)savecurrentPGCAccount:(PGCAccount *)account
{
    if (!account || isEmptyString(account.mediaID)) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kCurrentPGCAccountKey]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentPGCAccountKey];
        }
    } else {
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:account];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentPGCAccountKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (PGCAccount *)loginPGCAccount
{
    NSData * data = [[NSUserDefaults standardUserDefaults] dataForKey:kCurrentPGCAccountKey];
    if (data) {
        PGCAccount * account = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return account;
    }
    return nil;
}

@end
