//
//  TTRealnameAuthServiceForWebManager.h
//  Article
//
//  Created by chenren on 27/04/2017.
//
//

#import <Foundation/Foundation.h>
#import "SSJSBridgeWebView.h"
#import "NSObject+TTAdditions.h"

typedef NS_ENUM(NSUInteger, TTRealnameAuthServiceForWebType){
    TTRealnameAuthServiceForWebTypeNone,
    TTRealnameAuthServiceForWebTypeImageShot,       // 拍照
    TTRealnameAuthServiceForWebTypeImageUpload,     // 上传照片
    TTRealnameAuthServiceForWebTypeVideoShot,       // 视频录制
    TTRealnameAuthServiceForWebTypeVideoUpload,     // 上传视频
};

typedef NS_ENUM(NSUInteger, TTRealnameAuthServiceStateType){
    TTRealnameAuthServiceStateTypeFail,
    TTRealnameAuthServiceStateTypeSuccess,
};

@interface TTRealnameAuthServiceForWebManager : NSObject<Singleton>

/*
 *  返回当前支持的所有服务类型Services
 *  code为对应的枚举类型
 *  name为服务名称，也是JS调用的方法名称
 *  optionParams为数组，数组每个对象为字典，即每次调用可选择的参数，可为空
 */
+ (NSArray *)services;

/*
 *  预注册JSBridge方法，让Web有能力知晓已注册的服务
 */
+ (void)supportNativeServiceForWebView:(SSJSBridgeWebView *)webView;

/*
 *  单独注册服务个别类型
 */
+ (void)registerWebView:(SSJSBridgeWebView *)webView forService:(TTRealnameAuthServiceForWebType)serviceType;

@end
