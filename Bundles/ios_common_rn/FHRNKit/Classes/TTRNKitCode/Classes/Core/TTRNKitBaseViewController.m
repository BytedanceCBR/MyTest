//
//  TTRNKitBaseViewController.m
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/7.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import "TTRNKitBaseViewController.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import "TTRNKitHelper.h"
#import "TTRNKit.h"
#import "TTRNKitMacro.h"

@interface TTRNKitBaseViewController ()

@property (nonatomic, assign) BOOL hideBar;
@property (nonatomic, assign) BOOL hideStatusBar;
@property (nonatomic, strong) TTRNKitViewWrapper *viewWrapper;
@property (nonatomic, assign) BOOL originHideStatusBar;
@property (nonatomic, assign) BOOL originHideNavigationBar;

@end

@implementation TTRNKitBaseViewController
- (instancetype)initWithParams:(NSDictionary *)params viewWrapper:(TTRNKitViewWrapper *)viewWrapper {
    if (self = [super init]) {
        _originHideStatusBar = [UIApplication sharedApplication].statusBarHidden;
        _originHideNavigationBar = self.navigationController.navigationBarHidden;
        _hideBar = [params tt_intValueForKey:RNHideBar] == 1;
        _hideStatusBar = [params tt_intValueForKey:RNHideStatusBar] == 1;
        self.title = [params tt_stringValueForKey:RNTitle];
        _viewWrapper = viewWrapper;
        if (!_hideBar) {
            UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0 , [UIApplication sharedApplication].keyWindow.bounds.size.width, [TTDeviceHelper isIPhoneXDevice] ? 88 : 64)];//高度适配iPhoneX
            bar.translucent = NO;
            bar.shadowImage = [[UIImage alloc] init];
            [bar setBackgroundImage : [[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
            bar.barTintColor = [UIColor whiteColor];
            if ([UIDevice currentDevice].systemVersion.doubleValue >= 11.0) {//针对iOS11导航栏的适配
                bar.backgroundColor = [UIColor whiteColor];
            }
            [self.view addSubview:bar];
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            UIImage *image = [[UIImage imageWithContentsOfFile:[bundle pathForResource:@"TTRNKit_Core.bundle/lefterbackicon_titlebar" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            UIButton *leftCustomButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            [leftCustomButton setImage:image forState:UIControlStateNormal];
            [leftCustomButton addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            [view addSubview:leftCustomButton];
            UIBarButtonItem * leftButtonItem =[[UIBarButtonItem alloc] initWithCustomView:view];
            self.navigationItem.leftBarButtonItems = @[leftButtonItem];
        } else {
            self.navigationItem.leftBarButtonItems = nil;
            self.navigationItem.rightBarButtonItems = nil;
            self.title = nil;
        }
        [self.navigationItem setHidesBackButton:YES];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    if (_viewWrapper) {
        CGFloat top = _hideBar ? 0 : ([TTDeviceHelper isIPhoneXDevice] ? 88 : 64);
        CGRect frame = CGRectMake(0, top, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - top);
        _viewWrapper.frame = frame;
        [self.view addSubview:_viewWrapper];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_hideBar) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:_hideStatusBar];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:self.originHideNavigationBar animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:self.originHideStatusBar];
}

- (BOOL)prefersStatusBarHidden {
    return _hideStatusBar;
}

- (void)onClose {
    [TTRNKitHelper closeViewController:self];
}
#pragma mark - TTRNKitProtocol
- (UIViewController *)presentor {
    return self;
}
@end
