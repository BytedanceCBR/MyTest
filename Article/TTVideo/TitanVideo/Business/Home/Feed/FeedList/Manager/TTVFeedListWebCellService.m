//
//  TTVFeedListWebCellService.m
//  Article
//
//  Created by pei yun on 2017/4/21.
//
//

#import "TTVFeedListWebCellService.h"
#import "TTVTopWebCell+Extension.h"
#import "TTNetworkManager.h"

@implementation TTVFeedListWebCellService

- (void)startGetTemplateFromWapData:(TTVTopWebCell *)wapData completion:(void(^)(TTVTopWebCell *wapData, NSString *htmlStr, NSError *error))completion
{
    // 请求最新wap模板数据
    NSString *templateUrl = wapData.templateURL;
    
    if (isEmptyString(templateUrl)) {
        NSError *error = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
        completion(wapData, nil, error);
        return;
    }
    
    //templateUrl = [TTDeviceHelper customURLStringFromString:templateUrl];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:templateUrl params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSError *err = nil;
        NSString *html = nil;
        
        if ([jsonObj isKindOfClass:[NSDictionary class]] && [(NSDictionary *)jsonObj objectForKey:@"data"]) {
            //NSDictionary *resultDict = [result dictionaryValueForKey:@"result" defalutValue:nil];
            NSDictionary *dataDict = [jsonObj dictionaryValueForKey:@"data" defalutValue:nil];
            html = [dataDict stringValueForKey:@"template_html" defaultValue:nil];
            NSString *md5 = [dataDict stringValueForKey:@"template_md5" defaultValue:nil];
            NSString *baseUrl = [dataDict stringValueForKey:@"base_url" defaultValue:nil];
            [wapData updateWithTemplateContent:html templateMD5:md5 baseUrl:baseUrl];
            
            //[self removeTemplateChangedForID:@(wapData.uniqueID)];
        } else {
            err = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
        }
        
        if (completion) {
            completion(wapData, html, err);
        }
    }];
}

- (void)startGetDataFromWapData:(TTVTopWebCell *)wapData completion:(void(^)(TTVTopWebCell *wapData, NSDictionary *data, NSError *error))completion
{
    // 请求最新wap模板数据
    NSString *dataUrl = wapData.dataURL;
    
    if (isEmptyString(dataUrl)) {
        NSError *error = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
        completion(wapData, nil, error);
        return;
    }
    
    //dataUrl = [TTDeviceHelper customURLStringFromString:dataUrl];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:dataUrl params:nil method:@"GET" needCommonParams:YES callback:^(NSError *err, id jsonObj) {
        NSError *error;
        NSDictionary *data;
        //NSLog(@"err: %@ result: %@", err, result);
        if (!err) {
            NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:jsonObj];
            [mDict setValue:@"success" forKey:@"message"];
            [wapData updateWithDataContentObj:mDict];
        } else {
            error = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
            wapData.lastUpdateTime = [NSDate date];
        }
        
        if (completion) {
            completion(wapData, data, error);
        }
    }];
}

@end
