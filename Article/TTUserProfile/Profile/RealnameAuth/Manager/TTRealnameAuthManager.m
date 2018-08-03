//
//  TTRealnameAuthManager.m
//  Article
//
//  Created by lizhuoli on 16/12/22.
//
//

#import "TTRealnameAuthManager.h"
#import <TTAccountBusiness.h>
#import "TTNetworkManager.h"
#import "TTNetworkUtilities.h"

#import "TTRealnameAuthEncrypt.h"

@implementation TTRealnameAuthManager

+ (instancetype)sharedInstance
{
    static TTRealnameAuthManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [TTRealnameAuthManager new];
    });
    
    return manager;
}

- (void)uploadImageWithImage:(UIImage *)image type:(TTRealnameAuthImageType)type callback:(uploadBlock)callback
{
    NSMutableDictionary * postParams = [NSMutableDictionary dictionaryWithCapacity:2];
    postParams[@"user_id"] = [TTAccountManager userID];
    postParams[@"pic_type"] = @(type);
    
    if (type == TTRealnameAuthImagePerson) {
        postParams[@"submit_ocr"] = @(1);
    }
    
    if (![SSCommonLogic isRealnameAuthEncryptDisabled]) {
        NSMutableDictionary *snDict = [NSMutableDictionary dictionaryWithDictionary:postParams];
        [snDict addEntriesFromDictionary:[TTNetworkUtilities commonURLParameters]];
        NSString *sn = p_sn(snDict);
        postParams[@"sn"] = sn;
    }
    
    [[TTNetworkManager shareInstance] uploadWithURL:[CommonURLSetting imageOcrUploadURLString] parameters:postParams constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.f) name:@"ocr_pic" fileName:@"image.jpeg" mimeType:@"image/jpeg"];
    } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error && jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
            TTRealnameAuthUploadResponseModel *model = [[TTRealnameAuthUploadResponseModel alloc] initWithDictionary:jsonObj[@"data"] error:nil];
            if (type != TTRealnameAuthImageCardForeground || (!isEmptyString(model.real_name) && !isEmptyString(model.identity_number))) { // 服务端OCR偶尔会返回空串
                callback(nil, model);
            } else {
                error = [NSError errorWithDomain:kTTRealnameAuthErrorDomain code:kTTRealnameAuthErrorCodeServer userInfo:nil];
                callback(error, nil);
            }
        } else {
            if (jsonObj && [jsonObj isKindOfClass:[NSDictionary class]] && !isEmptyString(((NSString *)jsonObj[@"reason"]))) {
                error = [NSError errorWithDomain:kTTRealnameAuthErrorDomain code:kTTRealnameAuthErrorCodeServer userInfo:@{@"reason" : jsonObj[@"reason"]}];
            }
            if (callback) {
                callback(error, nil);
            }
        }
    }];
}

- (void)submitInfoWithName:(NSString *)name IDNum:(NSString *)IDNum callback:(void (^)(NSError *))callback
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:3];
    params[@"user_id"] = [TTAccountManager userID];
    params[@"identity_number"] = IDNum;
    params[@"real_name"] = name;
    
    if (![SSCommonLogic isRealnameAuthEncryptDisabled]) {
        NSMutableDictionary *snDict = [NSMutableDictionary dictionaryWithDictionary:params];
        [snDict addEntriesFromDictionary:[TTNetworkUtilities commonURLParameters]];
        NSString *sn = p_sn(snDict);
        params[@"sn"] = sn;
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting imageOcrInfoSubmitURLString] params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error && jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
            if (callback) {
                callback(nil);
            }
        } else {
            if (jsonObj && [jsonObj isKindOfClass:[NSDictionary class]] && !isEmptyString(((NSString *)jsonObj[@"reason"]))) {
                error = [NSError errorWithDomain:kTTRealnameAuthErrorDomain code:kTTRealnameAuthErrorCodeServer userInfo:@{@"reason" : jsonObj[@"reason"]}];
            }
            if (callback) {
                callback(error);
            }
        }
    }];
}

- (void)fetchInfoStatusWithCallback:(statusBlock)callback
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:1];
    params[@"user_id"] = [TTAccountManager userID];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting imageOcrInfoStatusURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error && jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
            TTRealnameAuthStatusResponseModel *model = [[TTRealnameAuthStatusResponseModel alloc] initWithDictionary:jsonObj[@"data"] error:nil];
            if (callback) {
                callback(nil, model);
            }
        } else {
            if (jsonObj && [jsonObj isKindOfClass:[NSDictionary class]] && !isEmptyString(((NSString *)jsonObj[@"reason"]))) {
                error = [NSError errorWithDomain:kTTRealnameAuthErrorDomain code:kTTRealnameAuthErrorCodeServer userInfo:@{@"reason" : jsonObj[@"reason"]}];
            }
            if (callback) {
                callback(error, nil);
            }
        }
    }];
}

@end
