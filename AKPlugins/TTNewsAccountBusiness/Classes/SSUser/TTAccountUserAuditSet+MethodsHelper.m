//
//  TTAccountUserAuditSet+MethodsHelper.m
//  Article
//
//  Created by liuzuopeng on 04/06/2017.
//
//

#import "TTAccountUserAuditSet+MethodsHelper.h"
#import "TTAccountManager.h"



@implementation TTAccountUserAuditSet (MethodsHelper)

+ (BOOL)isPGCUser
{
    return ([TTAccountManager accountUserType] == TTAccountUserTypePGC);
}

+ (BOOL)isUGCUser
{
    return ([TTAccountManager accountUserType] == TTAccountUserTypeUGC);
}

/**
 *  是UGC用户，并且在审核(认证)中
 */
- (BOOL)isAuditingUGCUser
{
    return ([self.class isUGCUser] && [[self.verifiedUserAuditEntity toDictionary] count] > 0);
}

- (BOOL)isAuditing
{
    BOOL auditing = NO;
    if ([self.class isPGCUser]) {
        auditing = self.pgcUserAuditEntity.auditing;
    } else if ([self isAuditingUGCUser]) {
        auditing = YES;
    }
    return auditing;
}

- (BOOL)modifyUserInfoEnabled
{
    if ([self isAuditing]) {
        return NO;
    }
    if (self.pgcUserAuditEntity && [self.pgcUserAuditEntity.expiredTime integerValue] > 0) {
        return NO;
    }
    if ([[self.verifiedUserAuditEntity toDictionary] count] > 0) {
        return NO;
    }
    return YES;
}

- (NSString *)showingUsername
{
    if ([self.class isPGCUser]) {
        if (self.pgcUserAuditEntity.auditing) {
            return self.currentUserEntity.name ? : [TTAccountManager currentUser].name;
        }
        return self.pgcUserAuditEntity.name ? : [TTAccountManager currentUser].name;
    } else if ([self.class isUGCUser]) {
        return self.verifiedUserAuditEntity.name ? : [TTAccountManager currentUser].name;
    } else {
        return self.currentUserEntity.name ? : [TTAccountManager currentUser].name;
    }
}

- (NSString *)showingUserDescription
{
    if ([self.class isPGCUser]) {
        if (self.pgcUserAuditEntity.auditing) {
            return self.currentUserEntity.userDescription;
        }
        return self.pgcUserAuditEntity.userDescription ? : self.currentUserEntity.userDescription;
    } else if ([self.class isUGCUser]) {
        return self.currentUserEntity.userDescription;
    } else {
        return self.currentUserEntity.userDescription;
    }
}

- (NSString *)showingUserAvatarURLString
{
    if ([self.class isPGCUser]) {
        if (self.pgcUserAuditEntity.auditing) {
            return self.currentUserEntity.avatarURL;
        }
        return self.pgcUserAuditEntity.avatarURL ? : self.currentUserEntity.avatarURL;
    } else if ([self.class isUGCUser]) {
        return self.currentUserEntity.avatarURL;
    } else {
        return self.currentUserEntity.avatarURL;
    }
}

- (NSString *)username
{
    NSString *name = nil;
    if ([self.class isPGCUser]) {
        name = self.pgcUserAuditEntity.name;
    } else if ([self isAuditingUGCUser]) {
        name = self.verifiedUserAuditEntity.name;
    } else {
        name = self.currentUserEntity.name;
    }
    if (isEmptyString(name)) {
        name = self.currentUserEntity.name;
    }
    return name ? : [TTAccountManager currentUser].name;
}

- (NSString *)userDescription
{
    NSString *desp = nil;
    if ([self.class isPGCUser]) {
        desp = self.pgcUserAuditEntity.userDescription;
    } else if ([self isAuditingUGCUser]) {
        desp = self.verifiedUserAuditEntity.userDescription;
    } else {
        desp = self.currentUserEntity.userDescription;
    }
    if (isEmptyString(desp)) {
        desp = self.currentUserEntity.userDescription;
    }
    return desp ? : @"这个人很机智，什么也没留下";
}

- (NSString *)userAvatarURLString
{
    NSString *urlString = nil;
    if ([self.class isPGCUser]) {
        urlString = self.pgcUserAuditEntity.avatarURL;
    } else if ([self isAuditingUGCUser]) {
        urlString = self.verifiedUserAuditEntity.avatarURL;
    } else {
        urlString = self.currentUserEntity.avatarURL;
    }
    if (isEmptyString(urlString)) {
        urlString = self.currentUserEntity.avatarURL;
    }
    return urlString ? : [TTAccountManager currentUser].avatarURL;
}

- (void)setUsername:(NSString *)name
{
    if ([self.class isPGCUser]) {
        self.pgcUserAuditEntity.name = name;
    } else if ([self isAuditingUGCUser]) {
        self.verifiedUserAuditEntity.name = name;
    } else {
        self.currentUserEntity.name = name;
    }
    
    if (self == [TTAccount sharedAccount].user.auditInfoSet) {
        [[TTAccount sharedAccount] persistence];
    }
}

- (void)setUserDescription:(NSString *)desp
{
    if ([self.class isPGCUser]) {
        self.pgcUserAuditEntity.userDescription = desp;
    } else if ([self isAuditingUGCUser]) {
        self.verifiedUserAuditEntity.userDescription = desp;
    } else {
        self.currentUserEntity.userDescription = desp;
    }
    
    if (self == [TTAccount sharedAccount].user.auditInfoSet) {
        [[TTAccount sharedAccount] persistence];
    }
}

- (void)setUserAvatarURLString:(NSString *)imageURLString
{
    if ([self.class isPGCUser]) {
        self.pgcUserAuditEntity.avatarURL = imageURLString;
    } else if ([self isAuditingUGCUser]) {
        self.verifiedUserAuditEntity.avatarURL = imageURLString;
    } else {
        self.currentUserEntity.avatarURL = imageURLString;
    }
    
    if (self == [TTAccount sharedAccount].user.auditInfoSet) {
        [[TTAccount sharedAccount] persistence];
    }
}

@end
