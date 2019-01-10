//
//  FHRealtorDetailWebViewController.m
//  Article
//
//  Created by leo on 2019/1/7.
//

#import "FHRealtorDetailWebViewController.h"
#import <TTRJSBForwarding.h>
#import <TTRStaticPlugin.h>
#import "Bubble-Swift.h"
#import "TTRoute.h"
#import <TTTracker/TTTracker.h>
@interface FHRealtorDetailWebViewController ()
{
    FHPhoneCallViewModel* _phoneCallViewModel;
    HouseRentTracer* _tracerModel;
    NSTimeInterval _startTime;
    NSString* _realtorId;
//    NSTimeInterval _lastClickCall;
}
@end

@implementation FHRealtorDetailWebViewController
static NSString *s_oldAgent = nil;

- (void)viewDidLoad {
    [[self class] registerUserAgentV2:YES];
    [super viewDidLoad];
    _startTime = [NSDate new].timeIntervalSince1970;
    _phoneCallViewModel = [[FHPhoneCallViewModel alloc] init];
    _tracerModel = [self.userInfo allInfo][@"trace"];
    _delegate = [self.userInfo allInfo][@"delegate"];
    _realtorId = [self.userInfo allInfo][@"realtorId"];

    @weakify(self);
    [self.webview.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        @strongify(self);
//        if (self->_lastClickCall - [[NSDate new] timeIntervalSince1970] < 3) {
//            return;
//        } else {
//            self->_lastClickCall = [[NSDate new] timeIntervalSince1970];
//        }
        self->_realtorId = params[@"realtor_id"];
        NSString* phone = params[@"phone"];
        if (self->_realtorId != nil && phone != nil) {
            [self->_phoneCallViewModel requestVirtualNumberAndCallWithRealtorId:self->_realtorId
                                                                     traceModel:self->_tracerModel
                                                                          phone:phone
                                                                        houseId:self->_tracerModel.groupId
                                                                       searchId:self->_tracerModel.searchId
                                                                         imprId:self->_tracerModel.imprId
                                                                    onSuccessed:^{
                                                                        completion(TTRJSBMsgSuccess, @{});
                                                                    }];
            [self->_delegate followUpAction];
        }
    } forMethodName:@"phoneSwitch"];
    [TTTracker eventV3:@"go_detail" params:[self goDetailParams]];
}

-(NSMutableDictionary*)goDetailParams {
    NSParameterAssert(_tracerModel);
    NSDictionary* params = @{@"page_type": _tracerModel.pageType,
                             @"enter_from": _tracerModel.enterFrom,
                             @"element_from": _tracerModel.elementFrom,
                             @"rank": _tracerModel.rank,
                             @"origin_from": _tracerModel.originFrom,
                             @"origin_search_id": _tracerModel.originSearchId,
                             @"log_pb": _tracerModel.logPb,
                             @"realtor_id": _realtorId,
                             };
    return [params mutableCopy];
}

- (void)dealloc
{
    NSTimeInterval stayTime = [NSDate new].timeIntervalSince1970 - _startTime;
    NSInteger stayTimeInt = stayTime * 1000;
    NSMutableDictionary* params = [self goDetailParams];
    params[@"stay_time"] = @(stayTimeInt);
    [TTTracker eventV3:@"stay_page" params:params];
}

+ (NSString *)toutiaoUA {
    NSMutableString *ua = [NSMutableString string];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    // Attempt to find a name for this application
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    if (!appName) {
        appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }

    NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
    appName = [[NSString alloc] initWithData:latin1Data encoding:NSISOLatin1StringEncoding];

    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];

    [ua appendFormat:@"NewsArticle/%@", developmentVersionNumber];

    NSString *netType = nil;
    if(TTNetworkWifiConnected())
    {
        netType = @"WIFI";
    }
    else if(TTNetwork4GConnected())
    {
        netType = @"4G";
    }
    else if(TTNetwork4GConnected())
    {
        netType = @"3G";
    }
    else if(TTNetworkConnected())
    {
        netType = @"2G";
    }
    [ua appendFormat:@" ManyHouse/%@", marketingVersionNumber];
    [ua appendFormat:@" JsSdk/%@", @"2.0"];
    [ua appendFormat:@" NetType/%@", netType];
    [ua appendFormat:@" (%@ %@ %f)", appName, marketingVersionNumber, [TTDeviceHelper OSVersionNumber]];

    return [ua copy];
}

+ (NSString *)origUA {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWebView *webView = [[UIWebView alloc] init];
        s_oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    });
    return s_oldAgent;
}

//新版, 不会每次都创建一个webview里
+ (void)registerUserAgentV2:(BOOL)appendAppInfo {
    CFPropertyListRef CFCurrentUA = CFPreferencesCopyAppValue(CFSTR("UserAgent"), CFSTR("com.apple.WebFoundation"));
    NSString *currentUA = CFPropertyListRefToNSString1(CFCurrentUA);

    if (isEmptyString(currentUA) || [currentUA rangeOfString:@"WebKit" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        CFPreferencesSetAppValue(CFSTR("UserAgent"), NULL, CFSTR("com.apple.WebFoundation"));
        currentUA = [self origUA];
    }

    NSString *toutiaoUA = [self toutiaoUA];
    NSRange toutiaoUARange = [currentUA rangeOfString:toutiaoUA];
    if (appendAppInfo && toutiaoUARange.location == NSNotFound) { //需要拼接,并且目前UA里没有头条相关参数
        NSString *appendAppInfoUA = [currentUA stringByAppendingFormat:@" %@", toutiaoUA];
        CFPreferencesSetAppValue(CFSTR("UserAgent"), (__bridge CFPropertyListRef _Nullable)(appendAppInfoUA), CFSTR("com.apple.WebFoundation"));
    }

    if (!appendAppInfo && toutiaoUARange.location != NSNotFound) { //不需要拼接, 但已经包含了头条相关
        NSString *deappendAppInfoUA = [currentUA componentsSeparatedByString:toutiaoUA].firstObject;
        deappendAppInfoUA = [deappendAppInfoUA stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        CFPreferencesSetAppValue(CFSTR("UserAgent"), (__bridge CFPropertyListRef _Nullable)(deappendAppInfoUA), CFSTR("com.apple.WebFoundation"));
    }
    return;
}

static NSString * CFPropertyListRefToNSString1(CFPropertyListRef ref) {
    if (ref == NULL) {
        return nil;
    }
    if (CFGetTypeID(ref) == CFStringGetTypeID()) {
        return (NSString *)CFBridgingRelease(ref);
    }
    return nil;
}

@end
