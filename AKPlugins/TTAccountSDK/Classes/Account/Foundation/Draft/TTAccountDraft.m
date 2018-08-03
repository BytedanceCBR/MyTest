//
//  TTAccountDraft.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/26/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import "TTAccountDraft.h"



@implementation TTAccountDraft

static NSString * const kTTAccountUserPhone = @"com.bytedance.account.user.phone";

+ (void)setDraftPhone:(NSString *)draftPhoneString
{
    [[NSUserDefaults standardUserDefaults] setObject:draftPhoneString forKey:kTTAccountUserPhone];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)draftPhone
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTTAccountUserPhone];
}


static NSString * const kTTAccountUserNickname = @"com.bytedance.account.user.nickname";

+ (void)setNickname:(NSString *)nicknameString
{
    [[NSUserDefaults standardUserDefaults] setObject:nicknameString forKey:kTTAccountUserNickname];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)nickname
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTTAccountUserNickname];
}


static NSString * const kTTAccountUserBirthday = @"com.bytedance.account.user.birthday";

+ (void)setBirthday:(NSString *)birthdayString
{
    [[NSUserDefaults standardUserDefaults] setObject:birthdayString forKey:kTTAccountUserBirthday];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)birthday
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTTAccountUserBirthday];
}


static NSString * const kTTAccountUserGender = @"com.bytedance.account.user.gender";

+ (void)setUserGender:(NSString *)despString
{
    [[NSUserDefaults standardUserDefaults] setObject:despString forKey:kTTAccountUserGender];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)userGender
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTTAccountUserGender];
}


static NSString * const kTTAccountUserSignature = @"com.bytedance.account.user.signature";

+ (void)setUserSignature:(NSString *)despString
{
    [[NSUserDefaults standardUserDefaults] setObject:despString forKey:kTTAccountUserSignature];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)userSignature
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kTTAccountUserSignature];
}

@end
