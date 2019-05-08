//
//  TTAdCommonUtil.m
//  Article
//
//  Created by carl on 2016/11/29.
//
//


#import "TTAdCommonUtil.h"
#import <TTMonitor/TTExtensions.h>
#import <TTBaseLib/TTNetworkHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <UIKit/UIKit.h>


@implementation TTAdCommonUtil
+ (NSDictionary *)generalDeviceInfo {
    NSMutableDictionary * parameterDict = [NSMutableDictionary dictionaryWithCapacity:10];

    [parameterDict setValue:[TTExtensions connectMethodName] forKey:@"access"];
    NSString *carrierName = [TTExtensions carrierName];
    [parameterDict setValue:carrierName forKey:@"carrier"];
    
    NSString *carrierMnc = [TTNetworkHelper carrierMNC];
    [parameterDict setValue:carrierMnc forKey:@"mcc_mnc"];
    
    float scale = [[UIScreen mainScreen] scale];
    NSString * displayDensity = [NSString stringWithFormat:@"%ix%i", (int)([TTUIResponderHelper screenSize].width * scale), (int)([TTUIResponderHelper screenSize].height * scale) ];
    
    [parameterDict setValue:displayDensity forKey:@"display_density"];
    
    return parameterDict;
}

@end

@implementation NSDictionary (TTAdJSONSerial)

- (NSString *)format2JSONString {
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }
    NSError *jsonSeriaError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&jsonSeriaError];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
