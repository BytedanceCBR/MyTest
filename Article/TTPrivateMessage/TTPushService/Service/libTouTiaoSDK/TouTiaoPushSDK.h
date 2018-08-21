//
//  TouTiaoPushSDK.h
//  TouTiaoPushSDKDemo
//
//  Created by wangdi on 2017/7/30.
//  Copyright © 2017年 wangdi. All rights reserved.
//

#import <UIKit/UIKit.h>

//使用时请结合wiki进行集成 地址 https://wiki.bytedance.net/pages/viewpage.action?pageId=93948218

@interface TTBaseRequestParam : NSObject
/**
 appID
 */
@property (nonatomic, copy) NSString *aId;
/**
 设备ID
 */
@property (nonatomic, copy) NSString *deviceId;
/**
 安装ID
 */
@property (nonatomic, copy) NSString *installId;
/**
 app名字， 各个app自己应该有定义
 */
@property (nonatomic, copy) NSString *appName;
/**
 初始化方法
 
 @return 对象本身
 */
+ (instancetype)requestParam;

@end

@interface TTChannelRequestParam : TTBaseRequestParam
/**
 渠道，如local_test
 */
@property (nonatomic, copy) NSString *channel;
/**
 iOS这边默认传[13]
 */
@property (nonatomic, copy) NSString *pushSDK;
/**
 app版本号
 */
@property (nonatomic, copy) NSString *versionCode;
/**
 系统版本号
 */
@property (nonatomic, copy) NSString *osVersion;
/**
 bundleID
 */
@property (nonatomic, copy) NSString *package;
/**
 应用内推送开关状态，0：打开，1:关闭
 */
@property (nonatomic, copy) NSString *notice;

@end

@interface TTUploadTokenRequestParam : TTBaseRequestParam
/**
 device_token
 */
@property (nonatomic, copy) NSString *token;

@end

@interface TTUploadSwitchRequestParam : TTBaseRequestParam

/**
 应用内推送开关状态，0：打开，1:关闭
 */
@property (nonatomic, copy) NSString *notice;

@end

@interface TTBaseResponse : NSObject

/**
 只有请求成功了error才为nil,否则error不为nil
 */
@property (nonatomic, strong) NSError *error;

/**
 请求的返回结果,里面有一个message 字段,该字段为success表示成功，否则就是请求失败
 */
@property (nonatomic, strong) id jsonObj;

@end

@interface TouTiaoPushSDK : NSObject

/**
 发出一个相应的请求
 
 @param requestParam 请求参数的模型，用于封装参数，传不同的模型会对应不同的请求，TTChannelRequestParam是上报device_id的请求;TTUploadTokenRequestParam是上报token的请求;TTUploadSwitchRequestParam是上报推送开关的请求
 @param completionHandler 请求结果的回调
 */
+ (void)sendRequestWithParam:(TTBaseRequestParam *)requestParam completionHandler:(void (^)(TTBaseResponse *response))completionHandler;

@end
