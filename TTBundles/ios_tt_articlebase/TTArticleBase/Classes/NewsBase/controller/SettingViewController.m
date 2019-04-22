//
//  SettingViewController.m
//  Article
//
//  Created by Hu Dianwei on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingView.h"
#import "SSNavigationBar.h"
#import "SSDebugViewController.h"
#import "TTNavigationController.h"



@interface SettingViewController ()
@property (nonatomic, strong) SettingView *settingView;
@end

@implementation SettingViewController
@synthesize settingView;

- (void)dealloc
{
    [TTAccount removeMulticastDelegate:self.settingView];
    self.settingView = nil;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.hidesBottomBarWhenPushed = YES;
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
    }
    
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [settingView willAppear];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.settingView = [[SettingView alloc] initWithFrame:self.view.bounds];
    self.settingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.view = settingView;
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: NSLocalizedString(@"设置", nil)];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: [SSNavigationBar navigationBackButtonWithTarget:self action:@selector(goBack:)]];
    
#if INHOUSE
    if ([SSDebugViewController supportDebugItem:SSDebugItemController]) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:@"高级调试" target:self action:@selector(_debugModeActionFired:)]];

    }
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [settingView willDisappear];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)goBack:(id)sender
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

#if INHOUSE
- (void)_debugModeActionFired:(id)sender
{
    SSDebugViewController *debugViewController = [[SSDebugViewController alloc] init];
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:debugViewController];
    navigationController.ttDefaultNavBarStyle = @"White";
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}
#endif

@end
