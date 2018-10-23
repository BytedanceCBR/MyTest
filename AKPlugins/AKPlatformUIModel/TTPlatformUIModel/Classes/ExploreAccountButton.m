//
//  ArticleXPAccountButton.m
//  Article
//
//  Created by SunJiangting on 14-4-13.
//
//

#import "ExploreAccountButton.h"
#import <TTAccountBusiness.h>
#import <TTPlatformExpiration.h>
#import "TTThemedAlertController.h"
#import "TTUIResponderHelper.h"


@implementation ExploreAccountButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self addTarget:self action:@selector(authorizedAccount:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc
{
    [_accountInfo removeObserver:self forKeyPath:@"accountStatus"];
}

- (void) setAccountInfo:(TTThirdPartyAccountInfoBase *)accountInfo {
    [accountInfo addObserver:self forKeyPath:@"accountStatus" options:NSKeyValueObservingOptionNew context:nil];
    [_accountInfo removeObserver:self forKeyPath:@"accountStatus"];
    _accountInfo = accountInfo;
    [self reloadButtonState];
}

- (void) reloadButtonState {
    if (!self.accountInfo) {
        self.selected = NO;
        return;
    }
    switch (self.accountInfo.accountStatus) {
        case TTThirdPartyAccountStatusNone:
        case TTThirdPartyAccountStatusBounded:
            self.selected = NO;
            break;
        case TTThirdPartyAccountStatusChecked:
            self.selected = YES;
            break;
        default:
            self.selected = NO;
            break;
    }
}

- (void) authorizedAccount:(id) sender {
    if (!self.accountInfo) {
        return;
    }
    switch (self.accountInfo.accountStatus) {
        case TTThirdPartyAccountStatusNone:
        {
            [TTAccountLoginManager requestLoginPlatformByName:self.accountInfo.keyName completion:^(BOOL success, NSError *error) {
                
            }];
            self.selected = NO;
        }
            break;
        case TTThirdPartyAccountStatusBounded:
        {
            if ([self.accountInfo.keyName  isEqual: @"sina_weibo"]) {
                NSDate *weiboExpiredLastTime = [[NSUserDefaults standardUserDefaults] valueForKey:@"weiboExpiredLastTime"];
                double alertAfterTime = [[[NSUserDefaults standardUserDefaults] valueForKey:@"weiboExpiredShowInterval"] doubleValue];
                NSDate *nowDate = [NSDate date];
                if ([TTPlatformExpiration sharedInstance].alertWeiboExpired && (!weiboExpiredLastTime ||(weiboExpiredLastTime && [nowDate timeIntervalSinceDate:weiboExpiredLastTime] >= alertAfterTime))) {
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"weiboExpiredLastTime"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSString *title = NSLocalizedString(@"新浪微博授权过期，如需分享到新浪微博，请重新授权", @"新浪微博授权过期，如需分享到新浪微博，请重新授权");
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:title message:@"" preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:NSLocalizedString(@"取消", @"取消") actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
                    [alert addActionWithTitle:NSLocalizedString(@"去授权", @"去授权") actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                        
                        [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_SINA_WEIBO completion:^(BOOL success, NSError *error) {
                            
                        }];
                    
                        [TTPlatformExpiration sharedInstance].alertWeiboExpired = NO;
                    }];
                    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
                }
            }

            [self.accountInfo setAccountStatus:TTThirdPartyAccountStatusChecked];
            [[TTPlatformAccountManager sharedManager] setAccountPlatform:self.accountInfo.keyName checked:YES];

            self.selected = YES;
        }
            break;
        case TTThirdPartyAccountStatusChecked:
        {
            [self.accountInfo setAccountStatus:TTThirdPartyAccountStatusBounded];
            [[TTPlatformAccountManager sharedManager] setAccountPlatform:self.accountInfo.keyName checked:NO];
            
            self.selected = NO;
        }
            break;
        default:
            break;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.accountInfo && [keyPath isEqualToString:@"accountStatus"]) {
        [self reloadButtonState];
    }
}

@end
