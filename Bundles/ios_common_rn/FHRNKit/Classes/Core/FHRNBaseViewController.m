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
#import "FHRNDebugViewController.h"
#import "FHRNKitMacro.h"
#import <TTRNKitViewWrapper.h>
#import <TTRNKitViewWrapper+Private.h>
#import <UIViewAdditions.h>

@interface FHRNBaseViewController ()<TTRNKitProtocol,FHRNDebugViewControllerProtocol>

@property (nonatomic, assign) BOOL hideBar;
@property (nonatomic, assign) BOOL hideStatusBar;
@property (nonatomic, strong) TTRNKitViewWrapper *viewWrapper;
@property (nonatomic, assign) BOOL originHideStatusBar;
@property (nonatomic, assign) BOOL originHideNavigationBar;
@property (nonatomic, strong) NSString *shemeUrlStr;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) NSString *channelStr;
@property (nonatomic, strong) NSString *moduleNameStr;
@property (nonatomic, assign) BOOL isDebug;
@property (nonatomic, strong) TTRouteParamObj *paramCurrentObj;
@property (nonatomic, strong) TTRNKit *ttRNKit;
@property (nonatomic, strong) UIView *container;

@end

@implementation FHRNBaseViewController
@synthesize manager = _manager;

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
    if (_channelStr) {
        [defaultBundlePath setValue:@"index.bundle" forKey:_channelStr];
    }
    [rnKitParams setValue:defaultBundlePath forKey:TTRNKitDefaultBundlePath];
    
    [rnKitParams setValue:@"index.bundle" forKey:TTRNKitBundleName];
    
    NSDictionary *rnAinimateParams = @{TTRNKitLoadingViewClass : @"loading",
                                       TTRNKitLoadingViewSize : [NSValue valueWithCGSize:CGSizeMake(100, 100)]
                                       };
    
    return [[TTRNKit alloc] initWithGeckoParams:rnKitParams
                                animationParams:rnAinimateParams];
}

- (instancetype)initWithParams:(NSDictionary *)params viewWrapper:(TTRNKitViewWrapper *)viewWrapper {
    if (self = [super init]) {
        _originHideStatusBar = [UIApplication sharedApplication].statusBarHidden;
        _originHideNavigationBar = self.navigationController.navigationBarHidden;
        _hideBar = [params tt_intValueForKey:RNHideBar] == 1;
        _hideStatusBar = [params tt_intValueForKey:RNHideStatusBar] == 1;
        self.title = [params tt_stringValueForKey:RNTitle];
        _viewWrapper = viewWrapper;
        _isDebug = [params tt_boolValueForKey:FHRN_DEBUG];
        _moduleNameStr = [params tt_stringValueForKey:FHRN_BUNDLE_MODULE_NAME];
        
    }
    return self;
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
        if ([paramObj.allParams[@"debug"] respondsToSelector:@selector(boolValue)]) {
            _isDebug = [paramObj.allParams[@"debug"] boolValue];
        }else
        {
            _isDebug = NO;
        }
        _paramCurrentObj = paramObj;
        _moduleNameStr = [paramObj.allParams tt_stringValueForKey:FHRN_BUNDLE_MODULE_NAME];
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
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0 , *)) {
            make.top.mas_equalTo(44.f + self.view.tt_safeAreaInsets.top);
        } else {
            make.top.mas_equalTo(65);
        }
    }];
    
    [self.view layoutIfNeeded];

    if (!_isDebug) {
        // Do any additional setup after loading the view.
        NSString *url = [NSString stringWithFormat:@"%@",_shemeUrlStr];
        
        self.ttRNKit.delegate = self;
        [self.ttRNKit handleUrl:url];
    }else
    {
        [self loadJSbundleAndShowWithIp:nil port:nil moduleName:nil];
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

#pragma mark - DebugProtocol
- (void)addViewWrapper:(TTRNKitViewWrapper *)viewWrapper
{
    [_container addSubview:viewWrapper];
    [viewWrapper setFrame:self.container.bounds];
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

- (void)loadJSbundleAndShowWithIp:(NSString *)host
                             port:(NSString *)port
                       moduleName:(NSString *)moduleName {
    NSString *hostFormat = @"http://%@/index.bundle?platform=ios&realtorId=213124234";
    NSURL *jsCodeLocation;
    if (host.length && port.length) {
        jsCodeLocation = [NSURL URLWithString:
                          [NSString stringWithFormat:hostFormat,
                           [NSString stringWithFormat:@"%@:%@", host, port]]];
    } else {
        jsCodeLocation = [NSURL URLWithString:[NSString stringWithFormat:hostFormat, @"127.0.0.1:8081"]];
    }
    NSMutableDictionary *initParams = [NSMutableDictionary dictionaryWithDictionary:_paramCurrentObj.allParams];
    initParams[RNModuleName] = moduleName ?: _moduleNameStr;
    
    TTRNKitViewWrapper *wrapper = [[TTRNKitViewWrapper alloc] init];
    [self.manager registerObserver:wrapper];
    
    [self addViewWrapper:wrapper];
    
    [self createRNView:initParams bundleURL:jsCodeLocation inWrapper:wrapper];
    
}

- (void)createRNView:(NSDictionary *)initParams bundleURL:(NSURL *)jsCodeLocation inWrapper:(TTRNKitViewWrapper *)wrapper {
    [wrapper reloadDataForDebugWith:initParams
                          bundleURL:jsCodeLocation
                         moduleName:initParams[RNModuleName] ?: @""];
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
