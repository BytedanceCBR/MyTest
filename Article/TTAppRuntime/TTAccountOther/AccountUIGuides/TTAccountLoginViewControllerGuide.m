//
//  TTAccountLoginViewControllerGuide.m
//  Article
//
//  Created by liuzuopeng on 04/06/2017.
//
//

#import "TTAccountLoginViewControllerGuide.h"
#import "NewsBaseDelegate.h"
#import "SSCommonLogic.h"
#import <TTAccountLoginViewController.h>
#import <TTAccountNavigationController.h>
#import <objc/runtime.h>



@implementation TTAccountLoginViewControllerGuide

- (void)dealloc
{
    
}

#pragma mark - TTGuideProtocol Method

- (BOOL)shouldDisplay:(id)context
{
    return YES;
}

- (void)showWithContext:(id)context
{
    return ;
    UINavigationController *rootNavController = [TTUIResponderHelper topNavigationControllerFor:nil];
    if ([context isKindOfClass:[NewsBaseDelegate class]]) {
        NewsBaseDelegate *contextDelegate = (NewsBaseDelegate *)context;
        
        rootNavController = [contextDelegate appTopNavigationController];
    }
    
    TTAccountLoginViewController *loginVC =
    [[TTAccountLoginViewController alloc] initWithTitle:[SSCommonLogic dialogTitleOfIndex:1] source:@"splash" isPasswordLogin:NO];
    loginVC.loginCompletionHandler = ^(TTAccountLoginState state) {
        [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self];
    };
    
    if ([TTDeviceHelper isPadDevice]) {
        TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:loginVC];
        navigationController.ttDefaultNavBarStyle = @"White";
        navigationController.ttHideNavigationBar = NO;
        
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        [rootNavController presentViewController:navigationController animated:YES completion:nil];
    } else {
        TTAccountNavigationController *navigationController = [[TTAccountNavigationController alloc] initWithRootViewController:loginVC];
        
        [rootNavController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (id)context
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContext:(id)context
{
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
