//
//  TTAccountAuthDefine.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 16/12/7.
//  Copyright © 2016年 com.bytedance.news. All rights reserved.
//

#ifndef TTAccountAuthDefine_h
#define TTAccountAuthDefine_h

#import "TTAccountDefine.h"



NS_ASSUME_NONNULL_BEGIN


/**
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=524948#id-享评SDK-更新当前登录用户的个人信息
 */
/** 第三方账号平台类型 */
typedef
NS_ENUM(NSInteger, TTAccountAuthType) {
    TTAccountAuthTypeUnsupport =-1, /** None */
    TTAccountAuthTypeWeChat    = 0, /** 微信 */
    TTAccountAuthTypeTencentQQ = 1, /** Tencent QQ */
    TTAccountAuthTypeTencentWB = 2, /** Tencent微博 */
    TTAccountAuthTypeSinaWeibo = 3, /** 新浪微博 */
    TTAccountAuthTypeTianYi    = 4, /** 电信天翼 */
    TTAccountAuthTypeRenRen    = 5, /** 人人网 */
    TTAccountAuthTypeKaixin    = 6, /** 开心网 */
    TTAccountAuthTypeFacebook  = 7, /** Facebook */
    TTAccountAuthTypeTwitter   = 8, /** Twitter */
    
    /** attention: [10-1000) 之间为公司产品类型；与BDSDKProductType定义产品类型顺序一致 */
    TTAccountAuthTypeToutiao   = 10, /** 幸福里 */
    TTAccountAuthTypeDouyin    = 11, /** 抖音 */
    TTAccountAuthTypeHuoshan   = 12, /** 火山 */
    TTAccountAuthTypeTTVideo   = 13, /** 西瓜视频 */
    TTAccountAuthTypeTTWukong  = 14, /** 悟空问答 */
    TTAccountAuthTypeTTFinance = 15, /** 财经 */
    TTAccountAuthTypeTTCar     = 16, /** 懂车帝 */
};




#define TTAccountAuthCorpProductMinType   (10)

#define TTAccountAuthCorpProductMaxType   (999)



/** 第三方平台授权登录相关的错误码 */
typedef
NS_ENUM(NSInteger, TTAccountAuthErrCode) {
    TTAccountAuthErrCodeUnknown           = -1,/** 未知 */
    TTAccountAuthSuccess                  = 0, /** 成功 */
    
    TTAccountAuthErrCodeCommon            = 1, /** 普通错误 */
    TTAccountAuthErrCodeURAppId           = 2, /** 没有注册(unregistered)AppID */
    TTAccountAuthErrCodeUserCancel        = 3, /** 用户主动取消 */
    TTAccountAuthErrCodeSendFail          = 4, /** 发送失败 */
    TTAccountAuthErrCodeNetworkFail       = 5, /** 网络错误 */
    TTAccountAuthErrCodeAuthDeny          = 6, /** 授权失败 */
    TTAccountAuthErrCodeUnsupport         = 7, /** 平台不支持 */
    TTAccountAuthErrCodeCancelInstall     = 8, /** 取消应用下载 */
    TTAccountAuthErrCodeCSRFAttack        = 9, /** csrf 攻击 */
};



/**
 *  UserInfo in notification:
 *  {
 *      TTAccountStatusCodeKey: ***,
 *      TTAccountAuthPlatformTypeKey: ***,
 *      TTAccountAuthPlatformNameKey: ***,
 *      TTAccountAuthPlatformResponseKey: ***,
 *  }
 *
 */
/** 第三方平台授权完成通知 */
FOUNDATION_EXPORT
NSString * TTAccountPlatformDidAuthorizeCompletionNotification;

/** 第三方授权平台类型 NSNumber(TTAccountAuthType) */
FOUNDATION_EXPORT
NSString * TTAccountAuthPlatformTypeKey;

/** 第三方授权平台响应 */
FOUNDATION_EXPORT
NSString * TTAccountAuthPlatformResponseKey;



@class TTAccountAuthResponse;
typedef
void (^TTAccountAuthWillLoginBlock)(NSString * _Nonnull platformName);
typedef
void (^TTAccountAuthLoginCompletedBlock)(TTAccountAuthResponse * _Nullable resp, NSError * _Nullable error);


NS_ASSUME_NONNULL_END



#endif /* TTAccountAuthDefine_h */
