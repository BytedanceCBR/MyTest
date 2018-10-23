//
//  TADDebugViewController.m
//  NewsInHouse
//
//  Created by carl on 2017/12/19.
//
#if INHOUSE

#import "TADDebugViewController.h"
#import "TTAdCanvasManager.h"
#import "TTAdManager.h"
#import "SSADManager.h"
#import "TTCanvasBundleManager.h"
#import "TTRouteService.h"

@interface TADDebugViewController ()

@end

@implementation TADDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =  @"商业化调试面板 0.0.1";
    
    NSMutableArray *dataSource = [NSMutableArray array];
    
    NSMutableArray *common_group = [NSMutableArray array];
    STTableViewCellItem *item_00 = [[STTableViewCellItem alloc] initWithTitle:@"回首页" target:self action:@selector(_goBackHome)];
    [common_group addObject:item_00];
    STTableViewCellItem *item_01 = [[STTableViewCellItem alloc] initWithTitle:@"Scheme" target:self action:@selector(_openURL)];
    [common_group addObject:item_01];
    
    STTableViewSectionItem *common_section = [[STTableViewSectionItem alloc] initWithSectionTitle:@"Common" items:common_group];
    [dataSource addObject:common_section];
    
    NSMutableArray *splash_group = [NSMutableArray array];
    STTableViewCellItem *item_10 = [[STTableViewCellItem alloc] initWithTitle:@"开屏广告" target:self action:@selector(_fireSpalshAd)];
    [splash_group addObject:item_10];
    
    STTableViewCellItem *item_28 = [[STTableViewCellItem alloc] initWithTitle:@"关闭Raw_ad_data" target:self action:NULL];
    item_28.switchStyle = YES;
    item_28.switchAction = @selector(_rawAdDataFired:);
    item_28.checked = ![SSCommonLogic isRawAdDataEnable];
    [splash_group addObject:item_28];
    
    STTableViewSectionItem *splash_section = [[STTableViewSectionItem alloc] initWithSectionTitle:@"Splash" items:splash_group];
    [dataSource addObject:splash_section];
    
    NSMutableArray *react_group = [NSMutableArray array];
    STTableViewCellItem *item_20 = [[STTableViewCellItem alloc] initWithTitle:@"删除预加载 Bundle" target:self action:@selector(_clearReactBundle)];
    [react_group addObject:item_20];
    
    STTableViewCellItem *item_21 = [[STTableViewCellItem alloc] initWithTitle:@"创意联动" target:self action:@selector(_showBundleInfo)];
    [react_group addObject:item_21];
    
    STTableViewCellItem *item_22 = [[STTableViewCellItem alloc] initWithTitle:@"下载沉浸式RN Bundle" target:self action:@selector(_downloadCanvasRNBundle)];
    [react_group addObject:item_22];
    
    STTableViewCellItem *item_23 = [[STTableViewCellItem alloc] initWithTitle:@"Bundle Info" target:self action:@selector(_showBundleInfo)];
    [react_group addObject:item_23];
    
    
    STTableViewSectionItem *react_section = [[STTableViewSectionItem alloc] initWithSectionTitle:@"React Native" items:react_group];
    [dataSource addObject:react_section];
    
    self.dataSource = dataSource;
    
}

- (void)executeCellDefaultHander {
    
}

- (void)_goBackHome {
    UIViewController *vc = self;

    while (vc.navigationController.viewControllers.count > 1 || vc.presentingViewController) {
        if (vc.navigationController.viewControllers.count > 1) {
            UIViewController *p = vc.navigationController;
            [vc.navigationController popToRootViewControllerAnimated:YES];
            vc = p;
        }
        
        if (vc.presentingViewController) {
             UIViewController *p = vc.presentingViewController;
            [vc dismissViewControllerAnimated:YES completion:nil];
            vc = p;
        }
    }
    
    while(vc.childViewControllers.count > 0) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)vc;
            vc = tab.selectedViewController;
        } else if ([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)vc;
            vc = nav.viewControllers.firstObject;
            [nav popToRootViewControllerAnimated:YES];
        } else {
            vc = vc.childViewControllers.firstObject;
        }
    }
}

- (void)_openURL {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"React Bundle" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"scheme";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [vc dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [vc dismissViewControllerAnimated:YES completion:^{
            
        }];
        NSString *urlString = vc.textFields.firstObject.text;
        NSURL *url = [NSURL URLWithString:urlString];
        BOOL canopen = [[TTRoute sharedRoute] canOpenURL:url];
        if (canopen) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
        canopen = [[UIApplication sharedApplication] canOpenURL:url];
        if (canopen) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    [vc addAction:okAction];
    [vc addAction:cancelAction];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)_rawAdDataFired:(UISwitch *)uiswitch {
    [SSCommonLogic setRawAdDataEnable:!uiswitch.isOn];
}

-(void)_fireSpalshAd {
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    
    [[adManagerInstance class] performSelector:@selector(clearSSADRecentlyEnterBackgroundTime)];
    [[adManagerInstance class] performSelector:@selector(clearSSADRecentlyShowSplashTime)];
    [adManagerInstance applicationDidBecomeActiveShowOnWindow:[UIApplication sharedApplication].keyWindow splashShowType:SSSplashADShowTypeShow];
}

- (void)_clearReactBundle {
    [[TTCanvasBundleManager sharedInstance] deleteAllBundles];
}

- (void)_showBundleInfo {
    TTAdRNBundleInfo *bundleInfo = [TTCanvasBundleManager currentCanvasBundleInfo];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"React Bundle" message:bundleInfo.debugDescription preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [vc dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    [vc addAction:cancelAction];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)_downloadCanvasRNBundle
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"下载自定义bundle" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"bundel url zip";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [vc dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [vc dismissViewControllerAnimated:YES completion:^{
            
        }];
        NSString *urlString = vc.textFields.firstObject.text;
        NSString *bundle_url = urlString;
        [TTCanvasBundleManager sharedInstance].isDebug = YES;
        NSString *localVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCanvasBundleVersionKey"];
        [TTCanvasBundleManager downloadIfNeeded:bundle_url version:@([localVersion integerValue] + 1).stringValue md5:@"anyone"];
    }];
    [vc addAction:okAction];
    [vc addAction:cancelAction];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

#endif
