//
//  TTThirdPartyAccountInfoBase.m
//  ShareOne
//
//  Created by Dianwei Hu on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTThirdPartyAccountInfoBase.h"



#define NAME_FOR_SAVE_DICT              @"sdk_dict_account_info"
#define STATUS_KEY                      @"STATUS_KEY"
#define SCREEN_NAME_KEY                 @"SCREEEN_NAME_KEY"

@interface TTThirdPartyAccountInfoBase(){
    NSMutableDictionary *_dict;
    TTThirdPartyAccountStatus _status;
}

@property(nonatomic, strong) NSMutableDictionary *_dict;
@end

static NSMutableDictionary *s_dict;

@implementation TTThirdPartyAccountInfoBase

@synthesize accountStatus, _dict, screenName, platformUid;

- (instancetype)init
{
    if ((self = [super init])) {
        self._dict = [NSMutableDictionary dictionaryWithDictionary:[s_dict objectForKey:[self keyName]]];
        if (_dict) {
            self.screenName    = [_dict objectForKey:SCREEN_NAME_KEY];
            self.accountStatus = [[_dict objectForKey:STATUS_KEY] intValue];
            self.expiredIn     = [[_dict objectForKey:@"expires_in"] doubleValue];
        } else {
            // 如果《＝0 ，则表示已经过期，这里默认不过期
            self.expiredIn = 1;
            self._dict     = [[NSMutableDictionary alloc] init];
            [s_dict setObject:self._dict forKey:[self keyName]];
        }
    }
    
    return self;
}

+ (void)initialize
{
    if (!s_dict) {
        s_dict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:NAME_FOR_SAVE_DICT]];
    }
}

+ (NSString *)platformName
{
    return nil;
}

+ (NSString *)platformDisplayName
{
    return nil;
}

- (NSString *)keyName
{
    return nil;
}

- (NSString *)displayName
{
    return nil;
}

- (NSString *)iconImageName
{
    return nil;
}

- (NSString *)drawerDisplayImage
{
    return nil;
}

- (TTThirdPartyAccountStatus)accountStatus
{
    return  _status;
}

- (void)setAccountStatus:(TTThirdPartyAccountStatus)tAccountStatus
{
    if (_status != tAccountStatus) {
        _status = tAccountStatus;
        //        [self save];
    }
}

- (BOOL)logined
{
    return self.accountStatus != TTThirdPartyAccountStatusNone;
}

- (void)clear
{
    self.accountStatus = TTThirdPartyAccountStatusNone;
    self.screenName = nil;
    self.expiredIn  = 0.f;
    [self save];
}

- (void)save
{
    [_dict setObject:[NSNumber numberWithInt:self.accountStatus] forKey:STATUS_KEY];
    [_dict setObject:@(_expiredIn) forKey:@"expires_in"];
    
    if (screenName) {
        [_dict setObject:self.screenName forKey:SCREEN_NAME_KEY];
    } else {
        [_dict removeObjectForKey:SCREEN_NAME_KEY];
    }
    
    [s_dict setObject:_dict forKey:[self keyName]];
    
    [[NSUserDefaults standardUserDefaults] setObject:s_dict forKey:NAME_FOR_SAVE_DICT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@. status:%ld, screenName:%@, platformUID = %@", [self displayName], (long)[self accountStatus], [self screenName], [self platformUid]];
}

@end
