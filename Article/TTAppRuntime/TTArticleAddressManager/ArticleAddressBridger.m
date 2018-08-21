//
//  ArticleAddressManager.m
//  Article
//
//  Created by Dianwei on 14-7-17.
//
//

#import "ArticleAddressBridger.h"
#import "SSAddressBook.h"
#import "MBProgressHUD.h"
#import "TTThemedAlertController.h"
#import "TTNavigationController.h"
#import "TTTrackerWrapper.h"

#import "TTDeviceHelper.h"
//#import "TTAddFriendViewController.h"

@interface ArticleAddressBridger()<UIAlertViewDelegate>

@end

@implementation ArticleAddressBridger

static ArticleAddressBridger *s_bridger;
+ (instancetype)sharedBridger
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_bridger = [[ArticleAddressBridger alloc] init];
    });
    
    return s_bridger;
}

- (BOOL)tryShowGetAddressBookAlertWithMobileLoginState:(ArticleLoginState)state
{
//    // 张晓东：注册或绑定手机号后show
//    if(state != ArticleLoginStateMobileBind && state != ArticleLoginStateMobileRegister) {
//        return NO;
//    }
//
//    if(![TTDeviceHelper isPadDevice]) {
////        if(![SSAddressBook hasAccessedAddressBook])
//        {
//            [SSAddressBook setHasAccessedAddressBook:YES];
//            wrapperTrackEvent(@"add_friends", @"address_friend_pop");
//            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"看看通讯录哪些好友已经在用爱看", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
//            [alert addActionWithTitle:NSLocalizedString(@"以后再说", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
//                wrapperTrackEvent(@"add_friends", @"later");
//            }];
//            [alert addActionWithTitle:NSLocalizedString(@"现在看看", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
//                wrapperTrackEvent(@"add_friends", @"now");
//                if(_presentingController)
//                {
//                    TTAddFriendViewController *vc = [[TTAddFriendViewController alloc] init];
//                    vc.autoSynchronizeAddressBook = YES;
//                    TTNavigationController *nav = [[TTNavigationController alloc] initWithRootViewController:vc];
//                    nav.ttDefaultNavBarStyle = @"White";
//                    [_presentingController presentViewController:nav animated:YES completion:^{
//
//                    }];
//                }
//            }];
//            [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
//            return YES;
//        }
//    }
    
    return NO;
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(buttonIndex == alertView.firstOtherButtonIndex)
//    {
//        wrapperTrackEvent(@"add_friends", @"now");
//        if(_presentingController)
//        {
//            TTAddFriendViewController *vc = [[TTAddFriendViewController alloc] init];
//            vc.autoSynchronizeAddressBook = YES;
//            TTNavigationController *nav = [[TTNavigationController alloc] initWithRootViewController:vc];
//            nav.ttDefaultNavBarStyle = @"White";
//
//            [_presentingController presentViewController:nav animated:YES completion:^{
//
//            }];
//        }
//    }
//    else
//    {
//        wrapperTrackEvent(@"add_friends", @"later");
//    }
//}

@end
