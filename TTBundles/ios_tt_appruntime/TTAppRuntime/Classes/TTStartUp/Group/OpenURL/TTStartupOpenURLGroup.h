//
//  TTStartupOpenURLGroup.h
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTStartupGroup.h"

typedef NS_ENUM(NSUInteger, TTOpenURLType) {
    TTOpenURLTypeQQShare = 0,       //QQ分享
    TTOpenURLTypeAppLink,       //调起京东or淘宝
    TTOpenURLTypeWeixin,        //微信
    TTOpenURLTypeDingtalk,      //钉钉
    TTOpenURLTypePayManager,    //支付
    TTOpenURLTypeAlipay,        //支付宝
    TTOpenURLFeedBackLog,       //回流监控
    TTOpenURLTypeTTTracker,     //TTTracker
    TTOpenURLTypeBytedanceSDKs, //BDSDK和BDPlatformSDK
//    TTOpenURLTypeSF,            //TTSF吊起
};

@interface TTStartupOpenURLGroup : TTStartupGroup

+ (TTStartupOpenURLGroup *)openURLGroup;

@end
