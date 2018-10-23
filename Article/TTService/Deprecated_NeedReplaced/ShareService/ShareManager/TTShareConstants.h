//
//  TTShareConstants.h
//  Article
//
//  Created by 王霖 on 16/2/1.
//
//

#ifndef TTShareConstants_h
#define TTShareConstants_h

#define kShareChannelFrom @"tt_from" //分享到社交网络的关键字
#define kUTMSource @"utm_source"
#define kUTMOther @"utm_medium=toutiao_ios&utm_campaign=client_share"

#define kShareChannelFromMail [NSString stringWithFormat:@"%@=email&%@=email&%@", kShareChannelFrom, kUTMSource, kUTMOther]
#define kShareChannelFromQQ [NSString stringWithFormat:@"%@=mobile_qq&%@=mobile_qq&%@", kShareChannelFrom, kUTMSource, kUTMOther]
#define kShareChannelFromQQZone [NSString stringWithFormat:@"%@=qzone&%@=qzone&%@", kShareChannelFrom, kUTMSource, kUTMOther]
#define kShareChannelFromWeixin [NSString stringWithFormat:@"%@=weixin&%@=weixin&%@", kShareChannelFrom, kUTMSource, kUTMOther]
#define kShareChannelFromZhiFuBao [NSString stringWithFormat:@"%@=zhifubao&%@=zhifubao&%@", kShareChannelFrom, kUTMSource, kUTMOther]
#define kShareChannelFromDingTalk [NSString stringWithFormat:@"%@=dingtalk&%@=dingtalk&%@", kShareChannelFrom, kUTMSource, kUTMOther]
#define kShareChannelFromWeixinMoment [NSString stringWithFormat:@"%@=weixin_moments&%@=weixin_moments&%@", kShareChannelFrom, kUTMSource, kUTMOther]
#define kShareChannelFromSMS [NSString stringWithFormat:@"%@=sms&%@=sms&%@", kShareChannelFrom, kUTMSource, kUTMOther]
#define kShareChannelFromTwitter [NSString stringWithFormat:@"%@=twitter&%@=twitter&%@", kShareChannelFrom, kUTMSource, kUTMOther]
#define kShareChannelFromFacebook [NSString stringWithFormat:@"%@=facebook&%@=facebook&%@", kShareChannelFrom, kUTMSource, kUTMOther]
#define kShareChannelFromCopy [NSString stringWithFormat:@"%@=copy_link&%@=copy_link&%@", kShareChannelFrom, kUTMSource, kUTMOther]

#define kShareToPlatformNeedEnterBackground @"kShareToPlatformNeedEnterBackground" 
#endif /* TTShareConstants_h */
