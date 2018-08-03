//
//  NewFeedbackAlertManager.m
//  Essay
//
//  Created by Tianhang Yu on 12-5-8.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "NewFeedbackAlertManager.h"
#import "SSFeedbackManager.h"
#import "SSAlertCenter.h"
#import "SSBaseAlertModel.h"
#import "SSFeedbackViewController.h"
#import "TTNavigationController.h"
#import "TTDeviceHelper.h"


@implementation NewFeedbackAlertManager

static NewFeedbackAlertManager * alertManger;

+ (id)alertManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alertManger = [[NewFeedbackAlertManager alloc] init];
    });
    return alertManger;
}

- (void)startAlert
{    
    if (![SSFeedbackManager hasNewFeedback] || [TTDeviceHelper isPadDevice]) {
        [[SSAlertCenter defaultCenter] removeAlert:self];
        return;
    }
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(startAlert) withObject:nil waitUntilDone:YES];
        return;
    }
    
    [[SSAlertCenter defaultCenter] addAlert:self];
    NSArray * result = [self handleAlert:nil];
    if ([result count] > 0) {
        [self.alertModels addObjectsFromArray:result];
        [[SSAlertCenter defaultCenter] refresh];
        [self.alertModels removeObjectsInArray:result];
        [[SSAlertCenter defaultCenter] removeAlert:self];
    }
}

- (NSArray *)handleAlert:(NSDictionary *)result
{
    SSBaseAlertModel * m = [[SSBaseAlertModel alloc] init];
    m.title = NSLocalizedString(@"发现新的回复", nil);
    m.actions = @"";
    m.buttons = NSLocalizedString(@"查看,取消", nil);
    return [NSArray arrayWithObject:m];
}

- (void)clickedButtonAtIndex:(NSInteger)buttonIndex alertModel:(SSBaseAlertModel *)alertModel
{
    if (buttonIndex == 0) { //查看
        if (![TTDeviceHelper isPadDevice]) {
            
            SSFeedbackViewController * feedbackViewController = [[SSFeedbackViewController alloc] init];
            
//            UIViewController * topController = nil;
//            SEL selector = NSSelectorFromString(@"appTopNavigationController");
//            if ([[UIApplication sharedApplication].delegate respondsToSelector:selector]) {
//                topController = [[UIApplication sharedApplication].delegate performSelector:selector];
//            }
            UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor: nil];
//            if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(appTopNavigationController)]) {
//                topController = [[[UIApplication sharedApplication] delegate] performSelector:@selector(appTopNavigationController)];
//            }
//
//
//            if (topController == nil) {
//                topController = [TTUIResponderHelper topViewControllerFor: nil];
//            }

            TTNavigationController *navController = [[TTNavigationController alloc] initWithRootViewController:feedbackViewController];
            navController.ttDefaultNavBarStyle = @"White";

            if ([topController isKindOfClass:[UINavigationController class]]) {
                [topController presentViewController:navController animated:YES completion:NULL];
            }
            else if(topController.navigationController){
                [topController.navigationController presentViewController:navController animated:YES completion:NULL];
            }
            else
            {
                [topController presentViewController:navController animated:YES completion:NULL];
            }
        }
        
    }
}

@end
