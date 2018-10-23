//
//  TTEditableUserAuditInfo.m
//  Article
//
//  Created by liuzuopeng on 8/25/16.
//
//

#import "TTEditableUserAuditInfo.h"
#import "TTAccountUserAuditSet+MethodsHelper.h"



@implementation TTEditableUserAuditInfo
- (instancetype)init {
    if ((self = [super init])) {
        _isAuditing    = NO;
        _editEnabled   = NO;
        _editingItem   = kTTEditingUserItemTypeNone;
        _modifiedFlags = kTTUserInfoModifiedFlagNone;
    }
    return self;
}

- (BOOL)containUserAuditInfo:(TTAccountUserAuditSet *)info {
    BOOL bContain = YES;
    if (![self.name isEqualToString:[info username]]) {
        bContain = NO;
    }
    if (![self.userDescription isEqualToString:[info userDescription]]) {
        bContain = NO;
    }
    if (![self.avatarURL isEqualToString:[info userAvatarURLString]]) {
        bContain = NO;
    }
    return bContain;
}

- (NSDictionary *)toUploadedParameters
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.name forKey:TTAccountUserNameKey];
    [params setValue:self.userDescription forKey:TTAccountUserDescriptionKey];
    [params setValue:self.avatarImageURI forKey:TTAccountUserAvatarKey];
    [params setValue:self.bgImageURI forKey:@"bg_uri"];
    return params;
}

- (NSDictionary *)toModifiedParamters {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.modifiedFlags & kTTUserInfoModifiedFlagUsername) {
        [params setValue:self.name forKey:@"name"];
    }
    if (self.modifiedFlags & kTTUserInfoModifiedFlagDescription) {
        [params setValue:self.userDescription forKey:@"description"];
    }
    if (self.modifiedFlags & kTTUserInfoModifiedFlagAvatar) {
        [params setValue:self.avatarImageURI forKey:@"avatar"];
    }
    if (self.modifiedFlags & kTTUserInfoModifiedFlagBgImage) {
        [params setValue:self.bgImageURI forKey:@"bg_uri"];
    }
    return params;
}
@end

