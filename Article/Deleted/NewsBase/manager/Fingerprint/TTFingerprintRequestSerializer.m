//
//  TTTInstallIDPostDataHttpRequestSerializer.m
//  Pods
//
//  Created by fengyadong on 2017/8/3.
//
//
#import "TTFingerprintRequestSerializer.h"
#import "TTInstallIDManager.h"
#import "encrypt.h"
#import "NSData+Godzippa.h"
#import "TTInstallSandBoxHelper.h"
#import "NSDictionary+TTInstallAdditions.h"
#import "TTInstallDeviceHelper.h"
#import "TTHTTPRequestSerializerBase.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTInstallBaseMacro.h"
#import "TTNetworkUtil.h"
#import "TTInstallNetworkUtilities.h"

@implementation TTFingerprintRequestSerializer

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                              params:(NSDictionary *)parameters
                              method:(NSString *)method
               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                        commonParams:(NSDictionary *)commonParam {
    TTHttpRequest * request = [super URLRequestWithURL:URL params:parameters method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
    
    [request setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    
    NSString *aid = [TTInstallIDManager sharedInstance].appID ?: [TTInstallSandBoxHelper ssAppID];
    if(!TTInstallIsEmptyString(aid)) {
        [request setValue:aid forHTTPHeaderField:@"aid"];
    }
    
    NSError * compressionError;
    NSData * postData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:nil];
    NSData *compressedData = [postData dataByGZipCompressingWithError:&compressionError];
    BOOL needEcrypt = YES;
    if (needEcrypt) {
        NSString * privateKey = Key;
        size_t dataSize = (size_t)ss_encrypted_size((int)compressedData.length);
        uint8_t * resultBuffer = malloc(dataSize);
        uint8_t * buf = (uint8_t *)[compressedData bytes];
        int v = ss_encrypt(buf, (int)compressedData.length, (uint8_t *)[privateKey UTF8String], (int)privateKey.length, resultBuffer);
        NSData * resultData;
        if (v==0) {
            resultData = [NSData dataWithBytesNoCopy:resultBuffer length:dataSize];
            [request setValue:nil forHTTPHeaderField:@"Content-Encoding"];
            [request setValue:@"application/octet-stream;tt-data=a" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:resultData];
        }else{
            [request setHTTPBody:postData];
        }
        
    }else{
        [request setHTTPBody:postData];
    }
    return request;
    
}

@end
