//
//  TTTestAppViewControlller.m
//  TTAccountLoginDemo
//
//  Created by liuzuopeng on 14/06/2017.
//  Copyright © 2017 Nice2Me. All rights reserved.
//

#import "TTTestAppViewControlller.h"
#import "TTAccountLoginManager.h"
#import "TTTestDelayDeallocViewController.h"
#import <TTThemedAlertController.h>



typedef NS_ENUM(NSInteger, TTTestAppCaseCellType) {
    TTTestAppCaseCellTypeLargeLogin = 0,
    TTTestAppCaseCellTypeSmallLoginAlert,
    TTTestAppCaseCellTypeAccountAlertView,
    TTTestAppCaseCellTypeCustomLoginPanel,
    TTTestAppCaseCellTypeOtherTestEntry,
    TTTestAppCaseCellTypeDelayDeallocVC,
    TTTestAppCaseCellTypeAlertViewChangeKeyWindow,
    TTTestAppCaseCellTypeActionSheetChangeKeyWindow,
    TTTestAppCaseCellTypeThemedControllerChangeKeyWindow
};

@interface TTTestAppViewControlller ()

@end

@implementation TTTestAppViewControlller

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *texts = @[
                       @"随机文案",
                       @"随机文案，我说了算",
                       @"随机文案，哎呀妈呀",
                       @"随机文案，哎呀妈呀你太任性",
                       @"随机文案，哎呀妈呀你太任性，会被打的"
                       ];
    switch (indexPath.row) {
        case TTTestAppCaseCellTypeLargeLogin: {
            NSInteger randomInt = arc4random() % 5;
            if (randomInt < 2) {
                [TTAccountLoginManager presentLoginViewControllerFromVC:self type:TTAccountLoginDialogTitleTypeDefault source:@"test" completion:^(TTAccountLoginState state) {
                    
                }];
            } else {
                [TTAccountLoginManager presentLoginViewControllerFromVC:self title:texts[randomInt] source:@"test" completion:^(TTAccountLoginState state) {
                    
                }];
            }
        }
            break;
            
        case TTTestAppCaseCellTypeSmallLoginAlert: {
            NSInteger randomInt = arc4random() % 5;
            if (randomInt < 2) {
                [TTAccountLoginManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"test" completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
                    
                }];
            } else {
                [TTAccountLoginManager showLoginAlertWithTitle:texts[randomInt] source:@"test" completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
                    
                }];
            }
        }
            break;
            
        case TTTestAppCaseCellTypeAccountAlertView: {
            TTAccountAlertView *alertView = [[TTAccountAlertView alloc] initWithTitle:@"Test" message:@"Test ME(TTAccountAlertView)" cancelBtnTitle:@"取消" confirmBtnTitle:@"确认" animated:YES tapCompletion:^(TTAccountAlertCompletionEventType type) {
                
            }];
            [alertView show];
        }
            break;
            
        case TTTestAppCaseCellTypeCustomLoginPanel: {
            [TTAccountLoginManager requestLoginPlatformByType:TTAccountAuthTypeTencentQQ completion:^(BOOL success, NSError *error) {
                
            }];
        }
            break;
            
        case TTTestAppCaseCellTypeDelayDeallocVC: {
            TTTestDelayDeallocViewController *delayVC = [TTTestDelayDeallocViewController new];
            [self.navigationController pushViewController:delayVC animated:YES];
        }
            break;
            
        case TTTestAppCaseCellTypeAlertViewChangeKeyWindow: {
            
            TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"ChangeKeyWindow" message:@"test change key window" preferredType:TTThemedAlertControllerTypeAlert];
            
            [alertController addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                NSLog(@"%@", [UIApplication sharedApplication].keyWindow);
            }];
            NSLog(@"%@", [UIApplication sharedApplication].keyWindow);
            [alertController showFrom:self animated:YES];
            NSLog(@"%@", [UIApplication sharedApplication].keyWindow);
        }
            break;
            
        case TTTestAppCaseCellTypeActionSheetChangeKeyWindow: {
            UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"设置字体大小", nil)
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"小", nil), NSLocalizedString(@"中", nil), NSLocalizedString(@"大", nil), NSLocalizedString(@"特大", nil), nil];
            NSLog(@"%@", [UIApplication sharedApplication].keyWindow);
            
            [sheet showInView:self.view];
            
            NSLog(@"%@", [UIApplication sharedApplication].keyWindow);
        }
            break;
            
        case TTTestAppCaseCellTypeThemedControllerChangeKeyWindow: {
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"退出确认", nil) message:NSLocalizedString(@"退出当前头条账号，将不能同步收藏，发布评论和云端分享等", nil) preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
            [alert addActionWithTitle:NSLocalizedString(@"确认退出", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                
            }];
            [alert showFrom:self animated:YES];
        }
            break;
            
        default: {
            
        }
            break;
    }
}

@end
