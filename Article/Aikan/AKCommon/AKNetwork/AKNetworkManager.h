//
//  AKNetworkManager.h
//  Article
//
//  Created by 冯靖君 on 2018/3/2.
//  

#import <Foundation/Foundation.h>
#import <TTNetworkManager.h>

typedef void (^AKNetworkJSONResponseFinishBlock)(NSInteger err_no, NSString *err_tips, NSDictionary *dataDict);

@interface CommonURLSetting (AKURLSettings)

+ (NSString *)akActivityMainPageURL;

@end

@interface AKNetworkManager : NSObject

// path format : com0/com1/
+ (void)requestForJSONWithPath:(NSString *)path
                        params:(id)params
                        method:(NSString *)method
                      callback:(AKNetworkJSONResponseFinishBlock)callback;

+ (void)requestForJSONWithURL:(NSString *)url
                       params:(id)params
                       method:(NSString *)method
                     callback:(AKNetworkJSONResponseFinishBlock)callback;

+ (void)requestSafeHttpForJSONWithURL:(NSString *)url
                               params:(id)params
                               method:(NSString *)method
                             callback:(AKNetworkJSONResponseFinishBlock)callback;

@end
