//
//  TTContactsRedPacketManager.m
//  Article
//
//  Created by Jiyee Sheng on 8/1/17.
//
//

#import "TTContactsRedPacketManager.h"
#import "TTContactsRedPacketViewController.h"
#import "TTNavigationController.h"
#import "TTTabBarController.h"
#import "TTUIResponderHelper.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "NewsBaseDelegate.h"
#import "TTIndicatorView.h"
#import "TTContactsUserDefaults.h"
#import "TTNetworkManager.h"
#import "TTGuideDispatchManager.h"
#import "TTContactsRedPacketGuideViewHelper.h"
#import "TTRedPacketDetailBaseView.h"
#import <TTDialogDirector.h>

NSString *const kNotificationFollowAndGainMoneySuccessNotification = @"kNotificationFollowAndGainMoneySuccessNotification";

@implementation TTContactsRedPacketManager

+ (instancetype)sharedManager {
    static TTContactsRedPacketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTContactsRedPacketManager alloc] init];
    });

    return manager;
}

- (void)presentInViewController:(UIViewController *)fromViewController contactUsers:(NSArray *)contactUsers {
    [self presentInViewController:fromViewController
                     contactUsers:contactUsers
                             type:TTContactsRedPacketViewControllerTypeContactsRedpacket
                        viewModel:nil
                      extraParams:nil
                         needPush:NO];
}

- (void)presentInViewController:(UIViewController *)fromViewController
                   contactUsers:(NSArray *)contactUsers
                           type:(TTContactsRedPacketViewControllerType)type
                      viewModel:(TTRedPacketDetailBaseViewModel *)viewModel
                    extraParams:(NSDictionary *)extraParams
                       needPush:(BOOL)needPush {
    NSAssert(fromViewController, @"fromViewController should not be nil");
    TTContactsRedPacketViewController *viewController = [[TTContactsRedPacketViewController alloc] initWithContactUsers:contactUsers
                                                                                                     fromViewController:fromViewController
                                                                                                                   type:type
                                                                                                              viewModel:viewModel
                                                                                                            extraParams:extraParams];
    if (!needPush) {
        TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:viewController];
        navigationController.view.backgroundColor = [UIColor clearColor];
        navigationController.definesPresentationContext = YES;
        navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

        if (type == TTContactsRedPacketViewControllerTypeContactsRedpacket) {
            [TTTrackerWrapper eventV3:@"upload_contact_redpacket" params:@{@"action_type": @"show"}];
        }
        viewController.fromPush = needPush;

        [TTDialogDirector showInstantlyDialog:navigationController shouldShowMe:nil showMe:^(id  _Nonnull dialogInst) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TTOpenRedPackertNotification" object:nil userInfo:nil];
            [fromViewController presentViewController:navigationController animated:NO completion:nil];
        } hideForcedlyMe:nil];

        __weak id<NSObject> weakObserver = nil;
        weakObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"TTCloseRedPackertNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            if (weakObserver) {
                [[NSNotificationCenter defaultCenter] removeObserver:weakObserver name:@"TTCloseRedPackertNotification" object:nil];
            }
            [TTDialogDirector dequeueDialog:navigationController];
        }];
    } else {
        //push
        UIGraphicsBeginImageContextWithOptions(fromViewController.view.size, NO, 0);
        [fromViewController.view drawViewHierarchyInRect:fromViewController.view.bounds afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        viewController.backgroundImage = image;
        viewController.fromPush = needPush;

        [TTDialogDirector showInstantlyDialog:viewController shouldShowMe:nil showMe:^(id  _Nonnull dialogInst) {
            [fromViewController.navigationController pushViewController:viewController animated:NO];
        } hideForcedlyMe:nil];

        __weak id<NSObject> weakObserver = nil;
        weakObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"TTCloseRedPackertNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            if (weakObserver) {
                [[NSNotificationCenter defaultCenter] removeObserver:weakObserver name:@"TTCloseRedPackertNotification" object:nil];
            }
            [TTDialogDirector dequeueDialog:viewController];
        }];
    }
}

@end
