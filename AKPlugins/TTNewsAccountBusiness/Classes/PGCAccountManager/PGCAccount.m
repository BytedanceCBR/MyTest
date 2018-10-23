//
//  PGCAccount.m
//  Article
//
//  Created by Dianwei on 13-9-18.
//
//

#import "PGCAccount.h"
#import "PGCAccountManager.h"
#import <NSDictionary+TTAdditions.h>



@implementation PGCAccount

- (void)dealloc
{
    self.mediaID = nil;
    self.screenName = nil;
    self.userDesc = nil;
    self.avatarURLString = nil;
    self.verifiedDesc = nil;
    self.shareURL = nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.screenName forKey:@"screenName"];
    [aCoder encodeObject:self.userDesc forKey:@"userDesc"];
    [aCoder encodeObject:self.avatarURLString forKey:@"avatarURLString"];
    [aCoder encodeObject:self.verifiedDesc forKey:@"verifiedDesc"];
    [aCoder encodeObject:self.shareURL forKey:@"shareURL"];
    [aCoder encodeObject:self.userAuthInfo forKey:@"userAuthInfo"];
    [aCoder encodeObject:self.mediaID forKey:@"mediaID"];
    [aCoder encodeBool:self.liked forKey:@"liked"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.mediaID = [aDecoder decodeObjectForKey:@"mediaID"];
        self.screenName = [aDecoder decodeObjectForKey:@"screenName"];
        self.userDesc = [aDecoder decodeObjectForKey:@"userDesc"];
        self.avatarURLString = [aDecoder decodeObjectForKey:@"avatarURLString"];
        self.verifiedDesc = [aDecoder decodeObjectForKey:@"verifiedDesc"];
        self.shareURL = [aDecoder decodeObjectForKey:@"shareURL"];
        self.userAuthInfo = [aDecoder decodeObjectForKey:@"userAuthInfo"];
        self.liked = [aDecoder decodeBoolForKey:@"liked"];
    }
    return self;
}

- (BOOL)isLoginUser
{
    if (_mediaID != nil && [[PGCAccountManager shareManager] currentLoginPGCAccount].mediaID != nil && [[[PGCAccountManager shareManager] currentLoginPGCAccount].mediaID isEqualToString:_mediaID]) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    self = [self init];
    if(self)
    {
        self.avatarURLString = [dict objectForKey:@"avatar_url"];
        self.mediaID = [dict objectForKey:@"media_id"];
        self.liked = [[dict objectForKey:@"is_like"] boolValue];
        self.userDesc = [dict objectForKey:@"description"];
        self.userAuthInfo = [dict tt_stringValueForKey:@"user_auth_info"];
        self.shareURL = [dict objectForKey:@"share_url"];
        self.screenName = [dict objectForKey:@"name"];
        self.verifiedDesc = [dict objectForKey:@"verified_desc"];
    }
    
    return self;
}

@end
