//
//  TTAdCanvasContinerViewController.m
//  Article
//
//  Created by carl on 2017/7/14.
//
//

#import "TTAdCanvasContinerViewController.h"

#import "TTAdCanvasContainerViewModel.h"
#import "TTAdCanvasViewModel.h"
#import <KVOController/KVOController.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTThemed/SSThemed.h>
#import <TTUIWidget/TTNavigationController.h>
#import <TTUIWidget/UIView+Refresh_ErrorHandler.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>

@interface TTAdCanvasContinerViewController ()

@end

@implementation TTAdCanvasContinerViewController

+ (void)load
{
    RegisterRouteObjWithEntryName(kCanvasDetailPage);
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        TTAdCanvasContainerViewModel *viewModel = [[TTAdCanvasContainerViewModel alloc] initWithRouteParamObj:paramObj];
        self.containerViewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationItem.title = @"";
    self.view.backgroundColor = [UIColor blackColor];
    [self constructDetailViewController:nil];
    
    [self.containerViewModel fetchCanvasInfomationWithComplete:^{
        [self.detailViewController reloadState:self.containerViewModel.detailViewModel];
    }];
}

- (void)constructDetailViewController:(NSError **)error {
    self.detailViewController = [self.containerViewModel detailViewController];
    self.detailViewController.delegate = nil;
    
    self.ttNavBarStyle = self.detailViewController.ttNavBarStyle;
    self.ttHideNavigationBar = self.detailViewController.ttHideNavigationBar;
    self.ttStatusBarStyle = self.detailViewController.ttStatusBarStyle;
    
    self.ttHideNavigationBar = YES;
    [self addDetailVC];
}

- (void)addDetailVC {
    [self.detailViewController willMoveToParentViewController:self];
    [self addChildViewController:self.detailViewController];
    [self refreshDetailViewControllerViewFrameIfNeeded];
    [self.view addSubview:self.detailViewController.view];
    [self.detailViewController didMoveToParentViewController:self];
}

- (void)refreshDetailViewControllerViewFrameIfNeeded {
    self.detailViewController.view.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
