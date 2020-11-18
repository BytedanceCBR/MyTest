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

@interface FHFlutterViewController()

@property (nonatomic, strong) XGFlutterProxyGestureRecognizer *proxyGR;

@end

@implementation FHFlutterViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParams:[self processSchemaPrams:paramObj]];
    if (self) {
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

    BOOL hasAot = [paramObj.allParams btd_boolValueForKey:kFHFlutterchemaAOTSKey default:NO];
    
    if([[BDFlutterPackageManager sharedInstance] validPackageWithName:@"BFlutterBusiness"] && [FHFlutterManager isCanFlutterDynamicart]){
        NSString *flutterUrl = [NSString stringWithFormat:@"local-flutter://BFlutterBusiness%@",[paramObj.allParams btd_objectForKey:kFHFlutterchemaRouteSKey default:@"/"]];
       [resultPrams setValue:flutterUrl forKey:@"url"];
    }else{
        if(!hasAot){
            
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
