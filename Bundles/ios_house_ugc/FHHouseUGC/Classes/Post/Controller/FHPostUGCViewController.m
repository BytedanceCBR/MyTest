//
//  FHPostUGCViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import "FHPostUGCViewController.h"
#import "TTNavigationController.h"
#import "SSThemed.h"
#import "SSNavigationBar.h"
#import "TTDeviceHelper.h"
#import "TTThemedAlertController.h"

@interface FHPostUGCViewController ()

@property (nonatomic, strong) SSThemedButton * cancelButton;
@property (nonatomic, strong) SSThemedButton * postButton;

@end

@implementation FHPostUGCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNaviBar];
}

- (void)setupNaviBar {
    [self setupDefaultNavBar:YES];
    TTNavigationBarItemContainerView * leftBarItem = nil;
    leftBarItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft
                                                                                           withTitle:NSLocalizedString(@"取消", nil)
                                                                                              target:self
                                                                                              action:@selector(cancel:)];
    if ([leftBarItem isKindOfClass:[TTNavigationBarItemContainerView class]]) {
        leftBarItem.button.titleColorThemeKey = kColorText1;
        leftBarItem.button.highlightedTitleColorThemeKey = kColorText1Highlighted;
        leftBarItem.button.disabledTitleColorThemeKey = kColorText1;
        if ([TTDeviceHelper is736Screen]) {
            // Plus上bar button item的左边距会多4.3个点（13px），调整到间距为30px
            [leftBarItem.button setTitleEdgeInsets:UIEdgeInsetsMake(0, -4.3, 0, 4.3)];
        }
    }
    self.cancelButton = leftBarItem.button;
    UIBarButtonItem * leftPaddingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                      target:nil
                                                                                      action:nil];
    leftPaddingItem.width = 17.f;
    TTNavigationBarItemContainerView * rightBarItem = nil;
    rightBarItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight
                                                                                            withTitle:NSLocalizedString(@"发布", nil)
                                                                                               target:self
                                                                                               action:@selector(sendPost:)];
    
    if ([rightBarItem isKindOfClass:[TTNavigationBarItemContainerView class]]) {
        rightBarItem.button.titleColorThemeKey = kColorText6;
        rightBarItem.button.highlightedTitleColorThemeKey = kColorText6Highlighted;
        rightBarItem.button.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        if ([TTDeviceHelper is736Screen]) {
            //Plus上bar button item的右边距会多4.3个点（13px），调整到间距为30px
            [rightBarItem.button setTitleEdgeInsets:UIEdgeInsetsMake(0, 4.3, 0, -4.3)];
        }
        self.postButton = rightBarItem.button;
    }
    UIBarButtonItem * rightPaddingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil
                                                                                       action:nil];
    rightPaddingItem.width = 17.f;
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:leftBarItem], leftPaddingItem];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:rightBarItem], rightPaddingItem];
}

- (void)dismissSelf
{
    if (self.navigationController.viewControllers.count > 1) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers && viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)endEditing {
    [self.view endEditing:YES];
    
//    [self.toolbar endEditing:YES];
}

- (void)cancel:(id)sender {
    [self endEditing];
    [self dismissSelf];
    /*
    NSString * titleText = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * inputText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * phoneText = [self.phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL shouldAlert = !(isEmptyString(titleText) && isEmptyString(phoneText) && isEmptyString(inputText) && self.addImagesView.selectedImageCacheTasks.count == 0);
    if (self.postUGCEnterFrom == TTPostUGCEnterFromConcernHomepage && ![self textHasChanged] && ![self imageHasChanged]) { // 话题来的且未改变内容则不弹
        shouldAlert = NO;
    }
    
    if (!shouldAlert) {
        [self trackWithEvent:kPostTopicEventName label:@"cancel_none" containExtra:YES extraDictionary:nil];
        [self postFinished:NO];
    } else {
        [self trackWithEvent:kPostTopicEventName label:@"cancel" containExtra:YES extraDictionary:nil];
        
        if ([self draftEnable]) {
            TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"保存已输入的内容？" message:nil preferredType:TTThemedAlertControllerTypeAlert];
            WeakSelf;
            [alertController addActionWithTitle:@"不保存" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                StrongSelf;
                [self clearDraft];
                [self postFinished:NO];
            }];
            
            [alertController addActionWithTitle:@"保存" actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
                StrongSelf;
                [self trackWithEvent:kPostTopicEventName label:@"cancel_confirm" containExtra:YES extraDictionary:nil];
                [self postFinished:NO];
                [self saveDraft];
            }];
            [alertController showFrom:self animated:YES];
        } else {
            TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:@"确定退出？" message:nil preferredType:TTThemedAlertControllerTypeAlert];
            [alertController addActionWithTitle:NSLocalizedString(@"取消", comment:nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
            WeakSelf;
            [alertController addActionWithTitle:NSLocalizedString(@"退出", comment:nil) actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
                StrongSelf;
                [self trackWithEvent:kPostTopicEventName label:@"cancel_confirm" containExtra:YES extraDictionary:nil];
                [self postFinished:NO];
            }];
            [alertController showFrom:self animated:YES];
        }
        
    }
     */
}

- (void)sendPost:(id)sender {
    
}


@end
