//
//  FHRealtorDetailWebViewController.m
//  Article
//
//  Created by leo on 2019/1/7.
//

#import "FHRealtorDetailWebViewController.h"
#import <TTRJSBForwarding.h>
#import <TTRStaticPlugin.h>
#import <FHHouseDetail/FHHouseDetailPhoneCallViewModel.h>
#import "TTRoute.h"
#import <TTTracker/TTTracker.h>
#import "FHUserTracker.h"
#import "NetworkUtilities.h"

@interface FHRealtorDetailWebViewController ()
{
    NSTimeInterval _startTime;
    NSString* _realtorId;
}
@property (nonatomic, strong) TTRouteUserInfo *realtorUserInfo;
@property (nonatomic, strong) NSMutableDictionary *tracerDict;
@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, assign) FHHouseType houseType; // 房源类型

@end

@implementation FHRealtorDetailWebViewController
static NSString *s_oldAgent = nil;

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _tracerDict = @{}.mutableCopy;
        self.realtorUserInfo = paramObj.userInfo;
        _realtorId = paramObj.allParams[@"realtor_id"];
        [_tracerDict addEntriesFromDictionary:[self.realtorUserInfo allInfo][@"trace"]];
        _houseId = paramObj.userInfo.allInfo[@"house_id"];
        _houseType = [paramObj.userInfo.allInfo[@"house_type"] integerValue];
        _phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc]initWithHouseType:FHHouseTypeSecondHandHouse houseId:self.houseId];
    }
    return self;
}

- (void)viewDidLoad {
    [[self class] registerUserAgentV2:YES];
    [super viewDidLoad];
    _startTime = [NSDate new].timeIntervalSince1970;
    _delegate = [self.realtorUserInfo allInfo][@"delegate"];

    @weakify(self);
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        @strongify(self);
        self->_realtorId = params[@"realtor_id"];
        NSString *phone = params[@"phone"];

        self.tracerDict[@"pageType"] = @"realtor_detail";
        NSString *searchId = self.tracerDict[@"search_id"];
        NSString *imprId = self.tracerDict[@"impr_id"];

        if (self->_realtorId != nil && phone != nil) {
            [self.phoneCallViewModel callWithPhone:phone searchId:searchId imprId:imprId successBlock:^(BOOL isSuccess) {
                completion(TTRJSBMsgSuccess, @{});
            } failBlock:^(NSError * _Nonnull error) {
                completion(TTRJSBMsgFailed, @{});

            }];
            // add by zjing for test 应用silent
            if ([self.delegate respondsToSelector:@selector(followHouseByFollowId:houseType:actionType:)]) {
                [self.delegate followUpActionByFollowId:self.houseId houseType:self.houseType];
            }
        }
    } forMethodName:@"phoneSwitch"];
    [FHUserTracker writeEvent:@"go_detail" params:[self goDetailParams]];
}

-(NSMutableDictionary*)goDetailParams {
  
    NSDictionary* params = @{@"page_type": @"realtor_detail",
                             @"enter_from": _tracerDict[@"enter_from"] ? : @"be_null",
                             @"element_from": _tracerDict[@"element_from"] ? : @"be_null",
                             @"rank": _tracerDict[@"rank"] ? : @"be_null",
                             @"origin_from": _tracerDict[@"origin_from"] ? : @"be_null",
                             @"origin_search_id": _tracerDict[@"origin_search_id"] ? : @"be_null",
                             @"log_pb": _tracerDict[@"log_pb"] ? : @"be_null",
                             @"realtor_id": _realtorId ? : @"be_null",
                             };
    return [params mutableCopy];
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
