//
//  SSPayManager.m
//  Article
//
//  Created by SunJiangting on 14-8-29.
//
//

#import "SSPayManager.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>


#define SSPayRSAPublicKeyBase64String @"MIICWDCCAcGgAwIBAgIJAMN5U/9tdXkqMA0GCSqGSIb3DQEBBQUAMEUxCzAJBgNVBAYTAkFVMRMw\
EQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwHhcN\
MTQxMDExMDQwMzU3WhcNMTQxMTEwMDQwMzU3WjBFMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29t\
ZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIGfMA0GCSqGSIb3DQEB\
AQUAA4GNADCBiQKBgQDOZZ7iAkS3oN970+yDONe5TPhPrLHoNOZOjJjackEtgbptdy4PYGBGdeAU\
Az75TO7YUGESCM+JbyOz1YzkMfKl2HwYdoePEe8qzfk5CPq6VAhYJjDFA/M+BAZ6gppWTjKnwMcH\
VK4l2qiepKmsw6bwf/kkLTV9l13r6Iq5U+vrmwIDAQABo1AwTjAdBgNVHQ4EFgQUF18veywud+8P\
0TiaRqHFMJsVAZ4wHwYDVR0jBBgwFoAUF18veywud+8P0TiaRqHFMJsVAZ4wDAYDVR0TBAUwAwEB\
/zANBgkqhkiG9w0BAQUFAAOBgQBMHZrUO0FSHxIe/W1D+uRFreYvDONd0TRr6EEhFAPlNFuUapJo\
T+iYMCrHG5mhlgCk3uUl+mTRdxHXVuIIyL6N2a0IGDYwQN7FD3oh8T0We5gMAE26Ns1d52rNOc6M\
oUn/DY74Eji/LMZpLZQSfZope/6hHHfYoCc/fva74bUGjw=="

@interface SSPayManager () {
@private
    SecKeyRef _publicKeyRef;
}

@property (nonatomic, strong) SSPayHandler payHandler;
@property (nonatomic, copy)   NSDictionary * trade;

@end

@implementation SSPayManager

static SSPayManager * _payManger;
static NSString *WXAppID = nil;
+ (instancetype) sharedPayManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _payManger = [[SSPayManager alloc] init];
    });
    return _payManger;
}

+ (void)registerWxAppID:(NSString *)appID {
    WXAppID = appID;
}

- (void)registerWxAppIDIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WXApi registerApp:WXAppID];
    });
}

- (void) dealloc {
    if (_publicKeyRef) {
        CFRelease(_publicKeyRef);
    }
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _publicKeyRef = [self _secKeyWithString:SSPayRSAPublicKeyBase64String];
    }
    return self;
}

- (BOOL) canHandleOpenURL:(NSURL *)URL {
    return NO;
}


- (BOOL) canPayForURL:(NSURL *) URL {
    NSString * scheme = [URL scheme];
    NSString * host = [URL host];
    return [scheme hasPrefix:@"interestingnews1206"] && [host isEqualToString:@"pay"];
}

- (BOOL) canPayForTrade:(NSDictionary *) trade {
    NSDictionary * tradeInfo = [trade valueForKey:@"trade_info"];
    if (![self _supportTradeInfo:tradeInfo]) {
        return NO;
    }
    NSDictionary * sdkInfo = [trade valueForKey:@"sdk_info"];
    NSString * sign = [sdkInfo valueForKey:@"sign"];
    return [self _validateTradeInfo:tradeInfo signature:sign];
}

- (void) payForTrade:(NSDictionary *) trade finishHandler:(SSPayHandler) handler {
    if (![self canPayForTrade:trade]) {
        return;
    }
    self.payHandler = handler;
    self.trade = trade;
    NSDictionary * sdkInfo = [trade valueForKey:@"sdk_info"];
    NSDictionary * tradeInfo = [trade valueForKey:@"trade_info"];
    SSPayPlatform platform = [[tradeInfo valueForKey:@"way"] intValue];
    if (platform == SSPayPlatformWXPay) {
        [self _payForWXWithSDKInfo:sdkInfo];
    } else {
        self.trade = nil;
        self.payHandler = nil;
    }
}

- (void) handleWXPayResponse:(PayResp *) payResponse {
    if (self.payHandler) {
        self.payHandler(self.trade, payResponse.errCode);
    }
    self.payHandler = nil;
    self.trade = nil;
}

- (void) _handleAliPayResponse:(NSDictionary *)payResponse {
//    AlixPayResult* result = [[AlixPayResult alloc] initWithString:payResponse];
    if (self.payHandler) {
        self.payHandler(self.trade, [[payResponse valueForKey:@"resultStatus"] intValue]);
    }
    self.payHandler = nil;
    self.trade = nil;
}

#pragma mark - PrivateMethod

- (BOOL) _supportTradeInfo:(NSDictionary *) tradeInfo {
    SSPayPlatform platform = [[tradeInfo valueForKey:@"way"] intValue];
    [self registerWxAppIDIfNeeded];
    return (platform == SSPayPlatformWXPay && [WXApi isWXAppSupportApi]) || platform == SSPayPlatformAliPay;
}

- (BOOL) _validateTradeInfo:(NSDictionary *) tradeInfo signature:(NSString *) signature {
    NSString * sign = [tradeInfo valueForKey:@"tt_sign"];
    
    NSMutableDictionary * validates = [tradeInfo mutableCopy];
    [validates setValue:signature forKey:@"sign"];
    [validates removeObjectsForKeys:@[@"tt_sign", @"tt_sign_type"]];
    NSMutableString* joined = [NSMutableString string];
    NSArray* keys = [validates.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (id key in keys) {
        id value = [validates valueForKey:key];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [value stringValue];
        }
        if ([value isKindOfClass:[NSString class]]) {
            [joined appendFormat:@"%@=%@&", key, value];
        }
    }
    if ([joined hasSuffix:@"&"]) {
        [joined deleteCharactersInRange:NSMakeRange(joined.length - 1, 1)];
    }
    if (sign.length == 0 || joined.length == 0) {
        return NO;
    }
    return [self _verifySignature:[[NSData alloc] initWithBase64EncodedString:sign options:NSDataBase64DecodingIgnoreUnknownCharacters] usingSecKey:_publicKeyRef signedData:[joined dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) _payForWXWithSDKInfo:(NSDictionary *) sdkInfo {
    [self registerWxAppIDIfNeeded];
    PayReq * wxPay = [[PayReq alloc] init];
    wxPay.nonceStr = [sdkInfo valueForKey:@"noncestr"];
    wxPay.package = [sdkInfo valueForKey:@"package"];
    wxPay.partnerId = [sdkInfo valueForKey:@"partnerid"];
    wxPay.prepayId = [sdkInfo valueForKey:@"prepayid"];
    wxPay.timeStamp = [[sdkInfo valueForKey:@"timestamp"] intValue];
    wxPay.sign = [sdkInfo valueForKey:@"sign"];
    wxPay.openID = [sdkInfo valueForKey:@"appid"];
    [WXApi sendReq:wxPay];
}

- (NSDictionary *) _dictionaryWithURLQuery:(NSString *) query {
    if (![query isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString * (^ trimString)(NSString *) = ^(NSString * string) {
        return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    };
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    NSArray * compontents = [query componentsSeparatedByString:@"&"];
    [compontents enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
        NSArray * temp = [obj componentsSeparatedByString:@"="];
        if (temp.count > 1) {
            NSString * key = trimString(temp[0]);
            NSString * value = trimString(temp[1]);
            if (key.length > 0 && value.length > 0) {
                if ([value rangeOfString:@"%"].length > 0) {
                    value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                [parameters setValue:value forKey:key];
            }
        }
    }];
    return parameters;
}

- (SecKeyRef) _secKeyWithString:(NSString *) key {
    SecKeyRef secKeyRef;
    NSData * data = [[NSData alloc] initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters];
    SecCertificateRef secCertificateRef = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    if (!secCertificateRef) {
        return nil;
    }
    SecPolicyRef secPolicyRef = SecPolicyCreateBasicX509();
    SecTrustRef secTrustRef;
    OSStatus status = SecTrustCreateWithCertificates(secCertificateRef, secPolicyRef, &secTrustRef);
    SecTrustResultType trustResultType;
    if (status == noErr) {
        SecTrustEvaluate(secTrustRef, &trustResultType);
    }
    NSLog(@"%d %d", (int)status, (int)trustResultType);
    secKeyRef = SecTrustCopyPublicKey(secTrustRef);
    CFRelease(secCertificateRef);
    CFRelease(secPolicyRef);
    CFRelease(secTrustRef);
    return secKeyRef;
}

- (BOOL) _verifySignature:(NSData *) signature usingSecKey:(SecKeyRef) publicKey signedData:(NSData *) signedData {
    if (signedData.length == 0 || signature.length == 0 || !publicKey) {
        return NO;
    }
    uint8_t result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(signedData.bytes, (CC_LONG)signedData.length, result);
    OSStatus status = SecKeyRawVerify(publicKey, kSecPaddingPKCS1SHA1, result, CC_SHA1_DIGEST_LENGTH, signature.bytes, SecKeyGetBlockSize(publicKey));
    return (status == noErr);
}

@end

