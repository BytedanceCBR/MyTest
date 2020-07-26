//
//  FHRealtorDetailWebViewController.m
//  Article
//
//  Created by leo on 2019/1/7.
//

#import "FHRealtorDetailWebViewController.h"
#import "TTRJSBForwarding.h"
#import "TTRStaticPlugin.h"
#import <FHHouseDetail/FHHouseDetailPhoneCallViewModel.h>
#import "TTRoute.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import "FHUserTracker.h"
#import "NetworkUtilities.h"
#import <FHHouseBase/FHHousePhoneCallUtils.h>

#import <ReactiveObjC/ReactiveObjC.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <FHHouseBase/FHUtils.h>
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>

@interface FHRealtorDetailWebViewController ()
{
    NSTimeInterval _startTime;
    NSString* _realtorId;
}
@property (nonatomic, strong) TTRouteUserInfo *realtorUserInfo;
@property (nonatomic, strong) NSMutableDictionary *tracerDict;
@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, assign) NSInteger houseType; // 房源类型

@end

@implementation FHRealtorDetailWebViewController
static NSString *s_oldAgent = nil;

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _tracerDict = @{}.mutableCopy;
        self.realtorUserInfo = paramObj.userInfo;
        _realtorId = paramObj.allParams[@"realtor_id"];
        self.houseType = 0;
        [_tracerDict addEntriesFromDictionary:[self.realtorUserInfo allInfo][@"tracer"]];
        _houseId = paramObj.userInfo.allInfo[@"house_id"];
        _phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc]initWithHouseType:FHHouseTypeSecondHandHouse houseId:self.houseId];
    }
    return self;
}

- (void)viewDidLoad {
    [[self class] registerUserAgentV2:YES];
    [super viewDidLoad];
    _startTime = [NSDate new].timeIntervalSince1970;
//    _delegate = [self.realtorUserInfo allInfo][@"delegate"];

    @weakify(self);
    [self.ssWebView.ssWebContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        @strongify(self);
        self->_realtorId = params[@"realtor_id"];
        NSString *phone = params[@"phone"];
        if ([params[@"house_type"] isKindOfClass:[NSNumber class]]) {
            self.houseType = [params[@"house_type"] integerValue];
        }
        self.houseId = params[@"house_id"];

        self.tracerDict[@"pageType"] = @"realtor_detail";
        NSDictionary *reportParams = nil;
        
        if ([params[@"reportParams"] isKindOfClass:[NSString class]]) {
            reportParams = params[@"reportParams"];
        }else if ([params[@"reportParams"] isKindOfClass:[NSString class]]) {
            NSString *reportParamsStr = [params btd_stringValueForKey:@"reportParams"];
            if (reportParamsStr) {
                NSMutableString *processString= [NSMutableString stringWithString:reportParamsStr];
                NSString *character = nil;
                for (int i = 0; i < processString.length; i ++) {
                    character = [processString substringWithRange:NSMakeRange(i, 1)];
                    
                    if ([character isEqualToString:@"\\"])
                        [processString deleteCharactersInRange:NSMakeRange(i, 1)];
                }
                reportParams = [FHUtils dictionaryWithJsonString:processString];
            }
        }
        NSDictionary *associateInfoDict = nil;
        NSString *associateInfoStr = [params btd_stringValueForKey:@"phone_info"];
        if (associateInfoStr) {
            NSMutableString *processString= [NSMutableString stringWithString:associateInfoStr];
            NSString *character = nil;
            for (int i = 0; i < processString.length; i ++) {
                character = [processString substringWithRange:NSMakeRange(i, 1)];
                
                if ([character isEqualToString:@"\\"])
                    [processString deleteCharactersInRange:NSMakeRange(i, 1)];
            }
            associateInfoDict = [FHUtils dictionaryWithJsonString:processString];
        }
        [self callWithPhone:phone extraDict:reportParams phoneInfo:associateInfoDict completion:completion];
    } forMethodName:@"phoneSwitch"];
    [FHUserTracker writeEvent:@"go_detail" params:[self goDetailParams]];
}

- (void)callWithPhone:(NSString *)phone extraDict:(NSDictionary *)extraDict phoneInfo:(NSDictionary *)phoneInfo completion:(TTRJSBResponse)completion {
    
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.tracerDict) {
        [params addEntriesFromDictionary:self.tracerDict];
    }
    if (extraDict) {
        [params addEntriesFromDictionary:extraDict];
    }
    
    params[kFHAssociateInfo] = phoneInfo;
    FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
    associatePhone.reportParams = params;
    associatePhone.associateInfo = phoneInfo;
    associatePhone.realtorId = self->_realtorId;
    if ([params[@"log_pb"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *logPb = params[@"log_pb"];
        associatePhone.searchId = logPb[@"search_id"];
        associatePhone.imprId = logPb[@"impr_id"];
    }else if ([params[@"log_pb"] isKindOfClass:[NSString class]]) {
        NSDictionary *logPb = [FHUtils dictionaryWithJsonString:params[@"log_pb"]];
        associatePhone.searchId = logPb[@"search_id"];
        associatePhone.imprId = logPb[@"impr_id"];
    }
    associatePhone.houseType = self.houseType ? self.houseType : 9;
    associatePhone.houseId = self.houseId;
    associatePhone.showLoading = NO;
    [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhone completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
        if (success) {
            completion(TTRJSBMsgSuccess, @{});
        }else {
            completion(TTRJSBMsgFailed, @{});
        }
    }];
    
//    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:params error:nil];
//    configModel.houseType = self.houseType;
//    configModel.followId = self.houseId;
//    configModel.hideToast = YES;
//    // 静默关注功能
//    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];
    
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
