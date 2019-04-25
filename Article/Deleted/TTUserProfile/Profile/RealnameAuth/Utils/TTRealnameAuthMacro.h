//
//  TTRealnameAuthMacro.h
//  Article
//
//  Created by lizhuoli on 16/12/26.
//
//

#ifndef TTRealnameAuthMacro_h
#define TTRealnameAuthMacro_h

#define kTTRealnameAuthErrorDomain @"kTTRealnameAuthErrorDomain" // ErrorDomain
#define kTTRealnameAuthErrorCodeNetwork -1
#define kTTRealnameAuthErrorCodeServer 1
#define kTTRealnameAuthErrorNetworkMsg @"网络不给力，请重试"
#define kIDCardPhotoRatio 0.75 // 中国大陆身份证宽高比
#define kPersonPhotoRatio 0.75 // 人像照片高宽比3:4
#define kPersonOverlayImageWidth 640 // 人像轮廓图宽度
#define kPersonOverlayImageHeight 597 // 人像轮廓图高度
#define kPersonOverlayImageLeft 76 // 人像轮廓图片左右的距离（需要换算到真实的frame的width）
#define kPersonOverlayImageBottom 53 // 人像轮廓图片下方的距离

#endif /* TTRealnameAuthMacro_h */
