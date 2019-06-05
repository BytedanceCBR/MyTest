//
//  FHWDPostViewController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/31.
//

#import "FHWDPostViewController.h"
#import "TTNavigationController.h"
#import "SSNavigationBar.h"
#import "TTDeviceHelper.h"

@interface FHWDPostViewController ()

@property (nonatomic, strong) TTNavigationBarItemContainerView *rightBarView;

@end

@implementation FHWDPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNaviBar];
    [self setupUI];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNaviBar {
    [self setupDefaultNavBar:YES];
    TTNavigationBarItemContainerView *leftView = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:@"取消" target:self action:@selector(previousAction:)];
    leftView.button.titleLabel.font = [UIFont systemFontOfSize:16];
    if ([TTDeviceHelper getDeviceType] == TTDeviceMode736) {
        leftView.button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, -4.3, 0.0f, 4.3);
    }
    leftView.button.titleColorThemeKey = kColorText1;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    
    self.rightBarView = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:NSLocalizedString(@"提问", nil) target:self action:@selector(postQuestionAction:)];
    self.rightBarView.button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarView];
    
    if ([TTDeviceHelper getDeviceType] == TTDeviceMode736) {
        self.rightBarView.button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 3.0f, 0, -3.0f);
    }
//    self.rightBarView.button.titleColorThemeKey = [self.viewModel hasEnoughTitleText] ? kColorText6 : kColorText9;
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
//    [self setTartgetView:self.contentView];
//    [self.view addSubview:self.bannerWrapView];
//    [self.bannerWrapView addSubview:self.bannerView];
//    [self.view addSubview:self.toolView];
//    [self.view addSubview:self.characterNumberLabel];
//    self.contentView.bannerWrapView = self.bannerWrapView;
//    self.contentView.bannerView = self.bannerView;
//    self.contentView.toolView = self.toolView;
}

- (void)dismissSelf
{
    if (self.navigationController.viewControllers.count>1) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers && viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}


#pragma mark - Action

- (void)previousAction:(id)sender {
//    [self.contentView resignAllResponser];
//    [self.contentView hidekeyboardCoverView];
    [self dismissSelf];
}

- (void)postQuestionAction:(id)sender {
    
}
@end
