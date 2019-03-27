//
//  FHRNBaseViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/25.
//

#import "FHRNBaseViewController.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import "TTRNKitHelper.h"
#import "TTRNKit.h"
#import "TTRNKitMacro.h"
#import <FHEnvContext.h>
#import <FHIESGeckoManager.h>
#import <TTInstallIDManager.h>

@interface FHRNBaseViewController ()<TTRNKitProtocol>

@property (nonatomic, assign) BOOL hideBar;
@property (nonatomic, assign) BOOL hideStatusBar;
@property (nonatomic, strong) TTRNKitViewWrapper *viewWrapper;
@property (nonatomic, assign) BOOL originHideStatusBar;
@property (nonatomic, assign) BOOL originHideNavigationBar;
@property (nonatomic, strong) NSString *shemeUrlStr;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) NSString *channelStr;

@property (nonatomic, strong) TTRNKit *ttRNKit;
@property (nonatomic, strong) UIView *container;

@end

@implementation FHRNBaseViewController

- (TTRNKit *)extracted {
    NSString *stringVersion = [FHEnvContext getToutiaoVersionCode];
    
    NSDictionary *rnInitKitParams = @{TTRNKitUserId:@"user",                                  //gecko的userID，无实用意义
                                  TTRNKitScheme:@"sslocal://",                           //js与oc交互时使用的scheme
                                  TTRNKitAppName:@"f100",
                                  TTRNKitInnerAppName:@"Inner_Example",
                                  //       TTRNKitCommonBundlePath:commonBundlePath,
                                  //       TTRNKitCommonBundleMetaPath:commonBundleMetaPath,
                                  //TTRNKitGeckoDomain:@"gecko-sg.byteoversea.com"        //如果是海外资源，或者有自定义域名，请添加此行参数，
                                  };
    
    NSMutableDictionary *rnKitParams = [NSMutableDictionary dictionaryWithDictionary:rnInitKitParams];
    
    [rnKitParams setValue:stringVersion forKey:TTRNKitGeckoAppVersion];
    [rnKitParams setValue:_channelStr forKey:TTRNKitGeckoChannel];//一个ttrnkit实例只对应一个channel
    [rnKitParams setValue:kFHIESGeckoKey forKey:TTRNKitGeckoKey];
    [rnKitParams setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:TTRNKitDeviceId];
    
    NSMutableDictionary *defaultBundlePath = [NSMutableDictionary new];
    [defaultBundlePath setValue:@"index.bundle" forKey:_channelStr];
    [rnKitParams setValue:defaultBundlePath forKey:TTRNKitDefaultBundlePath];
    
    [rnKitParams setValue:@"index.bundle" forKey:TTRNKitBundleName];
    
    NSDictionary *rnAinimateParams = @{TTRNKitLoadingViewClass : @"loading",
                                       TTRNKitLoadingViewSize : [NSValue valueWithCGSize:CGSizeMake(100, 100)]
                                       };
    
    return [[TTRNKit alloc] initWithGeckoParams:rnKitParams
                                animationParams:rnAinimateParams];
}

- (void)initRNKit
{
    self.ttRNKit = [self extracted];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        if ([paramObj.sourceURL respondsToSelector:@selector(absoluteString)]) {
            _shemeUrlStr = [paramObj.sourceURL absoluteString];
        }
        _titleStr = paramObj.allParams[@"title"];
        _channelStr = paramObj.allParams[@"channelName"];
        
        [self initRNKit];
    }
    return self;
}

- (void)setupUI
{
    [self setupDefaultNavBar:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setupUI];
    
    self.customNavBarView.title.text = _titleStr;

    _container = [[UIView alloc] init];
    [self.view addSubview:_container];
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(120, 20, 50, 20));
    }];
    
    // Do any additional setup after loading the view.
    NSString *url = [NSString stringWithFormat:@"%@",_shemeUrlStr];
    
    self.ttRNKit.delegate = self;
    //    self.ttRNKit = NO;
    //    self.ttRNKit.fallBack x= NO;
    [self.ttRNKit handleUrl:url];
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

# pragma mark - TTRNKitProtocol
- (UIViewController *)presentor {
    return self;
}

- (void)handleWithWrapper:(TTRNKitViewWrapper *)wrapper
              specialHost:(NSString *)specialHost
                      url:(NSString *)url
            reactCallback:(RCTResponseSenderBlock)reactCallback
              webCallback:(TTRNKitWebViewCallback)webCallBack
            sourceWrapper:(TTRNKitViewWrapper *)sourceWrapper
                  context:(TTRNKit *)context {
    if (wrapper) {
        [_container addSubview:wrapper];
        [(UIView *)wrapper mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_container);
        }];
    } else if (specialHost) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:specialHost message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)closeparams:(NSDictionary *)params
      reactCallback:(RCTResponseSenderBlock)reactCallback
        webCallback:(TTRNKitWebViewCallback)webCallback
      sourceWrapper:(TTRNKitViewWrapper *)wrapper {
    
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
