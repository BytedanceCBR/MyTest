//
//  FHFlutterEmptyViewController.m
//  FHFlutter
//
//  Created by 谢飞 on 2020/11/24.
//

#import "FHFlutterEmptyViewController.h"
#import <UIColor+Theme.h>
#import "NSDictionary+BTDAdditions.h"
#import "FHFlutterConsts.h"
#import "BDPMSManager.h"
#import "FHFlutterManager.h"
#import "UIViewController+NavigationBarStyle.h"
#import "BDFlutterPackageManager.h"
#import "BDPMSFileManager.h"
#import "BDPMSFileUtility.h"
#import "PackageRouteManager.h"
#import <UIViewController+Refresh_ErrorHandler.h>
#import <Lottie/LOTAnimationView.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <FHCommonDefines.h>

@interface FHFlutterEmptyViewController ()

@property (nonatomic, strong) UIView *coverView; //
@property (nonatomic, strong) NSString *packageName; //
@property (nonatomic, weak) TTRouteParamObj *paramObj;
@property (nonatomic, strong) UILabel * progressTitleLabel;
@property (nonatomic, strong) LOTAnimationView *lotLoadingView;

@end

@implementation FHFlutterEmptyViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        self.paramObj = paramObj;
        self.ttDisableDragBack = NO;
        NSString *pluginName = self.paramObj.allParams[kFHFlutterchemaPluginNameKey];
        
        if (isEmptyString(pluginName)) {
            pluginName = @"BFlutterBusiness";
        }
        
        self.packageName = pluginName;
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self processNoPackage];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

-(LOTAnimationView *)lotLoadingView
{
    if (!_lotLoadingView) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"loading_lottie" ofType:@"json"];
        _lotLoadingView = [LOTAnimationView animationWithFilePath:path];
        _lotLoadingView.loopAnimation = YES;
        [_lotLoadingView play];
    }
    return _lotLoadingView;
}


- (void)processNoPackage{
    [self showLoading:self.view];
    
    self.coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.coverView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.coverView];

    [_coverView addSubview:self.lotLoadingView];
    [self.lotLoadingView setFrame:CGRectMake((self.view.frame.size.width - self.lotLoadingView.frame.size.width)/2, (self.view.frame.size.height - self.lotLoadingView.frame.size.height)/2 ,self.lotLoadingView.frame.size.width, self.lotLoadingView.frame.size.height)];

    UIImage *himg = SYS_IMG(@"nav_back_dark");
    UIButton * _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:himg forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(onBackAction) forControlEvents:UIControlEventTouchUpInside];
    [self.coverView addSubview:_backButton];
    [_backButton setFrame:CGRectMake(10, 40, 44, 44)];
    
    
    self.progressTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.lotLoadingView.frame.origin.y + self.lotLoadingView.frame.size.height + 5, self.view.frame.size.width, 50)];
    self.progressTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.progressTitleLabel.font = [UIFont systemFontOfSize:14];
    self.progressTitleLabel.textColor = [UIColor colorWithHexStr:@"#7f7f7f"];
    self.progressTitleLabel.text = @"页面加载中0%";
    [self.coverView addSubview:self.progressTitleLabel];

    
    [[BDFlutterPackageManager sharedInstance] reloadAllPackages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packageDownloadProgressNotification:) name:BDFlutterPackageInstallProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packageDownloadAndInstalledNotification:) name:BDFlutterPackageInstallResultNotification object:nil];
}

- (void)packageDownloadProgressNotification:(NSNotification *)notification {
    NSLog(@"noti: %@", notification);
    NSDictionary *userInfo = notification.userInfo;
    dispatch_async(dispatch_get_main_queue(), ^ {
        if (userInfo) {
                id package = userInfo[@"package"];
                if (package) {
                    NSString *packageName = [package valueForKey:@"name"];
                    if ([packageName isEqualToString:self.packageName]) {
                        double progress = userInfo[@"progress"] ? [userInfo[@"progress"] doubleValue] : 0.0;
                        if (progress == 1.0) {
                           self.progressTitleLabel.text = @"加载完成,跳转中";
                        }
                        self.progressTitleLabel.text = [NSString  stringWithFormat:@"页面加载中%ld%%",(long)(progress * 100)];
                    }
                }
            }
    });
}

- (void)packageDownloadAndInstalledNotification:(NSNotification *)notification {
    NSLog(@"noti: %@", notification);
    NSDictionary *userInfo = notification.userInfo;
    dispatch_async(dispatch_get_main_queue(), ^ {
        if (userInfo) {
            BOOL isSuccess = userInfo[@"isSuccess"] ? [userInfo[@"isSuccess"] boolValue] : NO;
            if (isSuccess) {
                id package = userInfo[@"package"];
                if (package) {
                    NSString *packageName = [package valueForKey:@"name"];
                    if ([packageName isEqualToString:self.packageName]) {
                        [self jumpNewFlutterPage];
                    }
                }
            }
            else {
                id package = userInfo[@"package"];
                if (package) {
                    NSString *packageName = [package valueForKey:@"name"];
                    if ([packageName isEqualToString:self.packageName]) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
                else {
                    id<PackageRoutePackageProtocol> _packageInfo = [[PackageRouteManager sharedManager] getPackageRoutePackageInfo:self.packageName];
                    if (_packageInfo) {
                        [self jumpNewFlutterPage];
                    }else{
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    // 没有package 回调默认为所有的包下载失败了
                }
            }
            
        }
    });
    
    
   
}

- (void)jumpNewFlutterPage
{
    id<PackageRoutePackageProtocol> _packageInfo = [[PackageRouteManager sharedManager] getPackageRoutePackageInfo:self.packageName];
    
    if (_packageInfo) {
        
        NSString *str = self.paramObj.sourceURL.absoluteString;
        NSString *changeStr = [str stringByReplacingOccurrencesOfString:@"sslocal://flutter_empty" withString:@"sslocal://flutter"];
        NSURL *flutterRealUrl = [NSURL URLWithString:changeStr];
        [[TTRoute sharedRoute] openURLByPushViewController:flutterRealUrl userInfo:self.paramObj.userInfo];
        
        NSMutableArray *vcStack = self.navigationController.viewControllers.mutableCopy;
        if (vcStack.count > 1) {
            [vcStack removeObjectAtIndex:vcStack.count - 2];
        }
        self.navigationController.viewControllers = vcStack;
    }
    
//    if([[BDFlutterPackageManager sharedInstance] loadPackages]){
//        BDPMSPackage * hasLocalPackage = [[BDFlutterPackageManager sharedInstance] validPackageWithName:pluginName];
//        if (hasLocalPackage) {

}

- (void)onBackAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    NSLog(@"empty dealloc!!!");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
