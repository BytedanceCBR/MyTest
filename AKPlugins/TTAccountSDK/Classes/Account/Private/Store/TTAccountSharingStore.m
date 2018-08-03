//
//  TTAccountSharingStore.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/17/17.
//
//

#import "TTAccountSharingStore.h"
#import "TTAccountKeyChainStore.h"
#import <UIKit/UIPasteboard.h>



@interface TTAccountSharingStore ()
@property (nonatomic, strong) UIPasteboard *appSharingPastboard;
@property (nonatomic, strong) TTAccountKeyChainStore *appSharingKeyChain;
@end

@implementation TTAccountSharingStore

- (instancetype)init
{
    if ((self = [super init])) {
        _appSharingPastboard = [UIPasteboard pasteboardWithName:[self.class sharingPastboardName] create:YES];
        [_appSharingPastboard setPersistent:YES];
    }
    return self;
}

+ (void)setSessionKey:(NSString *)sessionKey
{
    
}

+ (NSString *)sessionKey
{
    return nil;
}

- (void)setSessionKey:(NSString *)sessionKey
{
    if ([sessionKey length] <= 0) {
        return;
    }
    [_appSharingPastboard setString:sessionKey];
}

- (NSString *)sessionKey
{
    return nil;
}


#pragma mark - toutiao sharing pastboard name

+ (NSString *)sharingPastboardName
{
    return @"toutiao.account.sharing.pastboard";
}

@end
