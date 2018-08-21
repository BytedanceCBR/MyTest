//
//  SSViewControllerBase.m
//  Article
//
//  Created by Yu Tianhang on 12-11-21.
//
//

#import <QuartzCore/QuartzCore.h>
#import "SSViewControllerBase.h"

#import "SSNavigationBar.h"
#import "UIViewController+NavigationBarStyle.h"
#import "NSDictionary+TTAdditions.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"

BOOL STATUS_BAR_ORIENTATION_MODIFY = NO;

@interface SSViewControllerBase (){
    UIStatusBarStyle _lastStyle;
}
@property(nonatomic, copy) TTAppPageCompletionBlock completionBlock;
@end

@implementation SSViewControllerBase
@synthesize modeChangeActionType;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTThemeManagerThemeModeChangedNotification object:nil];
    if (self.completionBlock) {
        self.completionBlock(self);
    }
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self commonInit];
        self.ttStatusBarStyle = [[TTThemeManager sharedInstance_tt] statusBarStyle];
        self.completionBlock = [paramObj.userInfo.extra objectForKey:@"completion_block"];
        
    }
    return self;
}

//- (instancetype)initWithBaseCondition:(NSDictionary *)baseCondition
//{
//    self = [super initWithNibName:nil bundle:nil];
//    if (self) {
//        [self commonInit];
//        self.ttStatusBarStyle = [[TTThemeManager sharedInstance_tt] statusBarStyle];
//        NSDictionary *parameters = [baseCondition dictionaryValueForKey:@"kSSAppPageBaseConditionParamsKey" defalutValue:nil];
//        self.completionBlock = [parameters objectForKey:@"completion_block"];
//        
//    }
//    return self;
//}

- (void)commonInit {
    // could be extended
    self.hidesBottomBarWhenPushed = YES;
    self.viewBoundsChangedNotifyEnable = YES;
    
    self.modeChangeActionType = ModeChangeActionTypeCustom;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_themeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    _statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
    
    self.ttHideNavigationBar = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count>1 || self.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationBackButtonWithTarget:self action:@selector(dismissSelf)]];
    }
    
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

#pragma mark - theme

- (void)_themeChanged:(NSNotification*)notification
{
    
    if([TTDeviceHelper isPadDevice])
    {
        [self themeChanged:nil];
        return;
    }
    
    if((modeChangeActionType & ModeChangeActionTypeCustom) != 0)
    {
        [self themeChanged:notification];
    }
}

- (void)reloadThemeUI
{
    [self _themeChanged:nil];
    
}

- (void)themeChanged:(NSNotification*)notification
{
    // do nothing
    //    [self updateStatusBarStyle];
}

#pragma mark -- rotate

- (BOOL)shouldAutorotate
{
    if ([TTDeviceHelper isPadDevice]) {
        return YES;
    } else {
        // 如果需要手动设置status bar的方向，则shouldAutorotate必须返回NO
        if (STATUS_BAR_ORIENTATION_MODIFY) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([TTDeviceHelper isPadDevice]) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
