//
//  TTSecurityUtil.m
//  Article
//
//  Created by muhuai on 2017/9/20.
//
//
#include <assert.h>
#include <map>
#include <string.h>
#include <iostream>
#include <queue>
#include "modp_b64.h"
#include "libtfcc++.h"
#import "Base64.h"
#import <TTMonitor/TTMonitor.h>
#import <TTBaseLib/NSStringAdditions.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTSettingsManager/TTSettingsManager.h>

static const std::string nonce = "eb2a31655e12a84863314f97";
static const unsigned char g_client_nacl_ec_asymmetric_public_key1[32] = { 0x95,0xfe,0x58,0x2a,0x9b,0xb5,0x11,0x58,0xaf,0x53,0xca,0x3e,0x04,0x72,0xa0,0xdb,0x75,0x7b,0xd9,0xa0,0x19,0x0c,0xf9,0x43,0x24,0x3f,0x5f,0x43,0xa2,0x20,0x0e,0x66 };
static const unsigned char g_client_nacl_ec_asymmetric_public_key2[32] = {0x1b,0x2d,0xd9,0x9b,0xe3,0x5e,0xf3,0x93,0x53,0x3f,0xb6,0x06,0xfc,0xb2,0x44,0x14,0xb7,0x62,0xf3,0xad,0xdc,0x5d,0x31,0xdb,0xcc,0x40,0xbe,0x3e,0x15,0xc4,0x60,0x23};

#import "TTSecurityUtil.h"

@implementation TTSecurityUtil {
    std::map<std::string, tfcc_handler_t> handlerMap;
}

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkTfccStabilityIfNeed];
    });
}

+ (instancetype)sharedInstance {
    static TTSecurityUtil *security;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        security = [[TTSecurityUtil alloc] init];
    });
    return security;
}

- (void)dealloc {
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSString *)encrypt:(NSString *)str token:(NSString *)token {
    if (isEmptyString(str) || isEmptyString(token)) {
        return nil;
    }
    
    BOOL enable = [[[TTSettingsManager sharedManager] settingForKey:@"tt_tfcc_cfg" defaultValue:@{} freeze:NO] tt_boolValueForKey:@"enable"];
    if (!enable) {
        return nil;
    }
    
    std::string key = [token UTF8String];
    tfcc_handler_t h;
    if (handlerMap.find(key) == handlerMap.end()) {
        tfcc_handler_t nh = tfcc_create_handler();
        modp::b64_decode(key);
        tfcc_add_public_key(nh, 1, key.c_str(), nonce.data());
        handlerMap.insert(std::make_pair([token UTF8String], nh));
        h = nh;
    } else {
        h = handlerMap[key];
    }
    
    std::string *d = new std::string([str UTF8String]);
    std::string encrypted = tfcc::build_request(h, d->data(), d->size());
    modp::b64_encode(encrypted);
    
    
    NSString *base64 = [NSString stringWithUTF8String:encrypted.c_str()];
    return base64;
}

- (NSString *)decrypt:(NSString *)str token:(NSString *)token {
    
    if (isEmptyString(str) || isEmptyString(token)) {
        return nil;
    }
    
    BOOL enable = [[[TTSettingsManager sharedManager] settingForKey:@"tt_tfcc_cfg" defaultValue:@{} freeze:NO]  tt_boolValueForKey:@"enable"];
    if (!enable) {
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    
    std::string key = [token UTF8String];
    tfcc_handler_t h;
    if (handlerMap.find(key) == handlerMap.end()) {
        tfcc_handler_t nh = tfcc_create_handler();
        modp::b64_decode(key);
        tfcc_add_public_key(nh, 1, key.c_str(), nonce.data());
        handlerMap.insert(std::make_pair([token UTF8String], nh));
        h = nh;
    } else {
        h = handlerMap[key];
    }
    
    std::string decrypted = tfcc::parse_response(h, data.bytes, data.length); //解密
    modp::b64_encode(decrypted); //在C层面base64
    
    NSString *base64 = [NSString stringWithUTF8String:decrypted.c_str()];
    
    return base64;
}

+ (void)checkTfccStabilityIfNeed {
    BOOL enable = [[[TTSettingsManager sharedManager] settingForKey:@"tt_tfcc_cfg" defaultValue:@{} freeze:NO] tt_boolValueForKey:@"enable"];
    if (!enable) {
        return;
    }
    
    NSString *encryptStr = [[TTSecurityUtil sharedInstance] encrypt:@"{}" token:@"Gy3Zm+Ne85NTP7YG/LJEFLdi863cXTHbzEC+PhXEYCM="];
    [[TTMonitor shareManager] trackService:@"tfcc_encrypt" status:0 extra:@{}];
    if (!encryptStr) {
        return;
    }
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://i.snssdk.com/caijing/pay/router"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[@{@"data": encryptStr} JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [[TTMonitor shareManager] trackService:@"tfcc_decrypt" status:0 extra:@{@"errMsg": error.localizedDescription? :@""}];
            return;
        }
        NSDictionary *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] JSONValue];
        NSString *base64Data = [json tt_stringValueForKey:@"data"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *decrypt = [[[TTSecurityUtil sharedInstance] decrypt:base64Data token:@"Gy3Zm+Ne85NTP7YG/LJEFLdi863cXTHbzEC+PhXEYCM="] base64DecodedString];
            NSString *correct = @"{\"status\":\"OK\"}\"";
            if ([decrypt isEqualToString:correct]) {
                [[TTMonitor shareManager] trackService:@"tfcc_decrypt" status:1 extra:@{}];
            } else {
                [[TTMonitor shareManager] trackService:@"tfcc_decrypt" status:0 extra:@{@"errMsg": @"解密失败"}];
            }
        });
    }];
    [sessionDataTask resume];
}
@end
