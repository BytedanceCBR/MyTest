//
//  ExploreEntryHelper.m
//  Article
//
//  Created by Zhang Leonardo on 14-11-25.
//
//

#import "ExploreEntryHelper.h"
#import "ExploreEntryDefines.h"
#import "PGCAccountManager.h"
#import "ExploreEntryManager.h"
#import "UIImage+TTThemeExtension.h"

@implementation ExploreEntryHelper

+ (NSDictionary *)parseEntryDictByPGCDict:(NSDictionary *)dict
{
    if ([[dict objectForKey:@"media_id"] longLongValue] == 0) {
        return nil;
    }
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:dict];
    [result setValue:[dict objectForKey:@"avatar_url"] forKey:@"icon"];
    [result setValue:[dict objectForKey:[NSString stringWithFormat:@"%@", [dict objectForKey:@"media_id"]]] forKey:@"id"];
    [result setValue:[dict objectForKey:@([[dict objectForKey:@"media_id"] longLongValue])] forKey:@"media_id"];
    [result setValue:@([[dict objectForKey:@"is_like"] intValue]) forKey:@"is_subscribed"];
    [result setValue:@(ExploreEntryTypePGC) forKey:@"type"];
    
    return result;
}


+ (BOOL)isLoginUserEntry:(ExploreEntry *)entry
{
    if (!isEmptyString(entry.entryID) &&
        [[PGCAccountManager shareManager] currentLoginPGCAccount].mediaID != nil &&
        [[[PGCAccountManager shareManager] currentLoginPGCAccount].mediaID isEqualToString:entry.entryID]) {
        return YES;
    }
    return NO;
}


+ (PGCAccount *)transToPGCAccountFromEntry:(ExploreEntry *)entry
{
    if (!entry.managedObjectContext) {
        return nil;
    }
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    [dict setValue:entry.mediaID forKey:@"id"];
    [dict setValue:entry.mediaID forKey:@"media_id"];
    [dict setValue:entry.imageURLString forKey:@"avatar_url"];
    [dict setValue:entry.name forKey:@"name"];
    [dict setValue:entry.subscribed forKey:@"is_like"];
    [dict setValue:entry.shareURL forKey:@"share_url"];
    [dict setValue:entry.desc forKey:@"description"];
    PGCAccount * account = [[PGCAccount alloc] initWithDictionary:dict];
    return account;
}

+ (ExploreEntry *)transToEntryFromPGCAccount:(PGCAccount *)account
{
    if (isEmptyString(account.mediaID)) {
        long long mediaIDLong = [account.mediaID longLongValue];
        if (mediaIDLong != 0) {
            account.mediaID = [NSString stringWithFormat:@"%@", account.mediaID];
        }
        if (isEmptyString(account.mediaID)) {
            return nil;
        }
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:account.mediaID forKey:@"id"];
    [dict setValue:@([account.mediaID longLongValue]) forKey:@"media_id"];
    [dict setValue:account.screenName forKey:@"name"];
    [dict setValue:account.userDesc forKey:@"description"];
    [dict setValue:account.avatarURLString forKey:@"icon"];
    [dict setValue:account.shareURL forKey:@"share_url"];
    [dict setValue:@(account.liked) forKey:@"is_subscribed"];
    [dict setValue:@(ExploreEntryTypePGC) forKey:@"type"];
    return [[ExploreEntryManager sharedManager] insertExploreEntry:dict save:YES];
}
 

@end
