//
//  SSFeedbackPostViewController.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-9.
//
//

#import "SSFeedbackPostViewController.h"
#import "SSFeedbackPostView.h"
//#import "SSControllerViewBase.h"
#import "SSNavigationBar.h"
 
#import "TTDeviceHelper.h"
#import "TTDebugRealMonitorManager.h"

#import "TTNavigationController.h"
#import <objc/runtime.h>

static char firstResponderKey;

@interface SSFeedbackPostViewController ()
@property(nonatomic, retain)SSFeedbackPostView * postView;

@end

@implementation SSFeedbackPostViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.postView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    SSThemedView * baseView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    baseView.backgroundColorThemeKey = kColorBackground4;//@"BackgroundColor1";
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:baseView];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"意见反馈", nil)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationBackButtonWithTarget:self action:@selector(back:)]];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:NSLocalizedString(@"发送", nil) target:self action:@selector(send:)]];

 
    CGRect feedbackViewRect = [self frameForFeedbackView];
    self.postView = [[SSFeedbackPostView alloc] initWithFrame:feedbackViewRect];
    [self.view addSubview:_postView];
    
    [self setUpPanAction];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_postView didAppear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_postView didDisappear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_postView willDisappear];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_postView willAppear];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.postView.frame = [self frameForFeedbackView];
}


- (CGRect)frameForFeedbackView
{
    CGRect titleBarRect = self.view.frame;
    CGRect rect = CGRectZero;
    rect.size.width = CGRectGetWidth(titleBarRect);
    if ([TTDeviceHelper isPadDevice]) {
        rect = CGRectInset(self.view.bounds, [TTUIResponderHelper paddingForViewWidth:0], 0);
    }
    rect.origin.y = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;
    rect.size.height = CGRectGetHeight(self.view.frame) - rect.origin.y;
    
    return rect;
}

 
#pragma mark -- button target

- (void)send:(id)sender
{
    [_postView send];
}

- (void)back:(id)sender
{
    [_postView quiteFeedbackPostView];
}

- (void)setUpPanAction
{
    WeakSelf;
    self.panBeginAction = ^{
        StrongSelf;
        UIResponder *firstResponder = nil;
        if ([self.postView.inputTextView isFirstResponder]) {
            firstResponder = self.postView.inputTextView;
        } else if ([self.postView.contactField isFirstResponder]) {
            firstResponder = self.postView.contactField;
        }
        objc_setAssociatedObject(self, &firstResponderKey, firstResponder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [firstResponder resignFirstResponder];
    };
    
    self.panRestoreAction = ^{
        StrongSelf;
        UIResponder *firstResponder = objc_getAssociatedObject(self, &firstResponderKey);
        [firstResponder becomeFirstResponder];
    };
}

@end
