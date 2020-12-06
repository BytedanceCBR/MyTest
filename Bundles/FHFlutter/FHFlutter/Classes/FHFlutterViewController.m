//
//  FHFlutterViewController.m
//  ABRInterface
//
//  Created by 谢飞 on 2020/8/25.
//

#import "FHFlutterViewController.h"
#import "FHFlutterChannels.h"
#import "BDFlutterMethodManager.h"
#import "NSString+URLEncoding.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHFlutterConsts.h"
#import "NSString+BTDAdditions.h"
#import "XGFlutterProxyGestureRecognizer.h"
#import "TTNavigationController.h"
#import <Heimdallr/HMDTTMonitor.h>

#import "FHFlutterManager.h"
#import "BDFlutterPackageManager.h"
#import "NSDictionary+BTDAdditions.h"
#import "UIViewController+NavigationBarStyle.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "BDPMSManager.h"
#import "MBProgressHUD.h"
#import <UIColor+Theme.h>
#import "PackageRouteManager.h"
#import <TTBaseMacro.h>

@interface FHFlutterViewController()

@property (nonatomic, strong) XGFlutterProxyGestureRecognizer *proxyGR;
@property (nonatomic, assign) BOOL loadDynamicartNoPackage;
@property (nonatomic, weak) TTRouteParamObj *paramObj;

@end

@implementation FHFlutterViewController


+ (NSURL * _Nonnull )redirectURLWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] initWithDictionary:paramObj.allParams];
    BOOL hasAot = [paramObj.allParams btd_boolValueForKey:kFHFlutterchemaAOTSKey default:YES];
    NSString *pluginName = [paramObj.allParams btd_stringValueForKey:kFHFlutterchemaPluginNameKey];
     
    if(!hasAot && pluginName){
        BOOL canFlutterDynamicart =  [FHFlutterManager isCanFlutterDynamicart];
        id<PackageRoutePackageProtocol> _packageInfo = [[PackageRouteManager sharedManager] getPackageRoutePackageInfo:pluginName];

        if(!_packageInfo){
            NSString *str = paramObj.sourceURL.absoluteString;
            NSString *changeStr = [str stringByReplacingOccurrencesOfString:@"sslocal://flutter" withString:@"sslocal://flutter_empty"];
            NSURL *flutterEmptyUrl = [NSURL URLWithString:changeStr];
            return flutterEmptyUrl;
        }
    }
    return paramObj.sourceURL;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParams:[self processSchemaPrams:paramObj]];
    if (self) {
        self.paramObj = paramObj;
        FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
            methodChannelWithName:@"plugins.f.io/common_channel"
                                                binaryMessenger:self.flutterVC];

        @weakify(self);
        [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                               FlutterResult result) {
            @strongify(self);
            [FHFlutterChannels processChannelsImp:call callback:result];
            if ([@"setIsEnableSlideback" isEqualToString:call.method]) {
                NSDictionary *param = call.arguments;
                if([param isKindOfClass:[NSDictionary class]]){
                    BOOL isEnableDragBack = [param btd_boolValueForKey:@"isEnable"];
                    self.ttDisableDragBack = !isEnableDragBack;
                }
            }
         }];
     }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.proxyGR = [[XGFlutterProxyGestureRecognizer alloc] initWithTarget:self action:nil];
    [self.view addGestureRecognizer:self.proxyGR];
    //TTNavigationController 会使用一个全屏的后退手势，这里会要求 XGFlutterProxyGestureRecognizer 手势识别失败后才能触发全屏后退手势。
    if ([self.navigationController isKindOfClass:[TTNavigationController class]]) {
        [((TTNavigationController *)self.navigationController).panRecognizer requireGestureRecognizerToFail:self.proxyGR];
    }
    
    self.hidesBottomBarWhenPushed = YES;
    
    
    [self sendLoadingFinishLog];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}


- (NSDictionary *)processSchemaPrams:(TTRouteParamObj *)paramObj{
    NSMutableDictionary *resultPrams = [NSMutableDictionary new];
    
    NSArray *validPackages = [[BDFlutterPackageManager sharedInstance] allValidPackages];

    BOOL hasAot = [paramObj.allParams btd_boolValueForKey:kFHFlutterchemaAOTSKey default:YES];
    
    NSString *pluginName = paramObj.allParams[kFHFlutterchemaPluginNameKey];
    
    
    BDPMSPackage * hasLocalPackage = [[BDFlutterPackageManager sharedInstance] validPackageWithName:pluginName];
    BOOL canFlutterDynamicart =  [FHFlutterManager isCanFlutterDynamicart];

    _loadDynamicartNoPackage = NO;

    if(hasLocalPackage && canFlutterDynamicart && !isEmptyString(pluginName)){
        NSString *flutterUrl = [NSString stringWithFormat:@"local-flutter://%@%@",pluginName,[paramObj.allParams btd_objectForKey:kFHFlutterchemaRouteSKey default:@"/"]];
       [resultPrams setValue:flutterUrl forKey:@"url"];
    }else{
        if(!hasAot){
            NSString *flutterUrl = [NSString stringWithFormat:@"local-flutter://%@%@",pluginName,[paramObj.allParams btd_objectForKey:kFHFlutterchemaRouteSKey default:@"/"]];
            [resultPrams setValue:flutterUrl forKey:@"url"];
            
            if(canFlutterDynamicart){
                _loadDynamicartNoPackage = YES;
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:NO];
                });
            }
        }else{
          [resultPrams setValue:[paramObj.allParams btd_objectForKey:kFHFlutterchemaRouteSKey default:@"/"] forKey:@"url"];
        }
    }
    
    NSString * paramsStr = [paramObj.allParams btd_objectForKey:kFHFlutterchemaParamsKey default:@""];
    if ([paramsStr isKindOfClass:[NSString class]]) {
       NSDictionary * paramsDict = [paramsStr btd_jsonDictionary];
        if ([paramsDict isKindOfClass:[NSDictionary class]]) {
            [resultPrams addEntriesFromDictionary:paramsDict];
        }
        
    }
    NSString *reportStr = resultPrams[@"report_params"];

    if ([reportStr isKindOfClass:[NSString class]]) {
        reportStr = [reportStr btd_stringByURLDecode];
        resultPrams[@"report_params"] = reportStr;
    }
    
    if (![resultPrams.allKeys containsObject:kFHFlutterchemaViewTokenKey]) {
        if (isEmptyString(pluginName)) {
            [resultPrams setValue:kFHFlutterBDefaultModuleName forKey:kFHFlutterchemaViewTokenKey];
        }else{
            [resultPrams setValue:pluginName forKey:kFHFlutterchemaViewTokenKey];
        }
    }
    
    if (isEmptyString(pluginName)) {
        [resultPrams setValue:kFHFlutterBDefaultModuleName forKey:kFHFlutterchemaPluginNameKey];
    }
    
    
    NSDate *datenow = [NSDate date];//现在时间
    NSNumber *timeSpNum = @([[NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)] longLongValue]);
    [resultPrams setValue:timeSpNum forKey:@"start_timestamp"];

        
    return resultPrams;
}


- (void)sendLoadingFinishLog
{
    NSMutableDictionary *extra = [NSMutableDictionary new];

    NSMutableDictionary *metricDict = [NSMutableDictionary new];

    NSDictionary *cat = [NSMutableDictionary new];
    
    NSString *pageKey = [NSString stringWithFormat:@"%@:%@",self.packageName,self.curUrl];
    [cat setValue:@"1" forKey:pageKey];
    
    [[HMDTTMonitor defaultManager] hmdTrackService:@"f_flutter_monitor" metric:metricDict category:cat extra:extra];
}

@end
