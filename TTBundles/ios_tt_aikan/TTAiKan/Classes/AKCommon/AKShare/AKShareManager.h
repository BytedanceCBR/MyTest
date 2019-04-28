//
//  AKShareManager.h
//  Article
//
//  Created by 冯靖君 on 2018/3/7.
//

#import <Foundation/Foundation.h>
#import <TTShare/TTWeChatShare.h>
#import <TTShare/TTQQShare.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <WXApi.h>
#import <MessageUI/MessageUI.h>
#import "AKNetworkManager.h"

// 分享渠道
typedef NS_ENUM(NSInteger, AKSharePlatform)
{
    AKSharePlatformWeChat = 0,          //微信好友
    AKSharePlatformWeChatTimeLine,      //朋友圈
    AKSharePlatformQQ,                  //手Q
    AKSharePlatformQZone,               //qq空间
    AKSharePlatformSMS                  //系统短信
};

// 分享内容类型
typedef NS_ENUM(NSInteger, AKShareContentType)
{
    AKShareContentTypeText = 0,         //文字，适用口令场景
    AKShareContentTypeWebPage,          //web落地页
    AKShareContentTypeImage,            //图片
    AKShareContentTypeVideo             //视频，使用拜年小视频？
};

typedef void(^AKQRShareImageCompletionBlock)(UIImage *imageWithQRCode);

@interface AKQRShareHelper : NSObject

/**
 *  分享图贴二维码接口。异步
 *  @param  oriImage                原分享图
 *  @param  oriImageURL             原分享图url
 *  @param  qrImage                 后端生成二维码
 *  @param  qrImageShortLinkURL     二维码短链，客户端生成图片
 *  @param  completion              异步回调
 */
+ (void)genQRImageWithOriImage:(UIImage *)oriImage
                   oriImageURL:(NSString *)oriImageURL
                       qrImage:(UIImage *)qrImage
              qrImageShortLink:(NSString *)qrImageShortLinkURL
               completionBlock:(AKQRShareImageCompletionBlock)completion;

@end

// 分享业务回调
typedef void(^AKShareCompletionBlock)(NSDictionary *extra, NSError *error);

// 获取shareInfo接口回调
typedef void(^AKShareInfoBlock)(NSDictionary *shareInfo);

// 发送sms消息回调
typedef void(^AKSendSMSCompletion)(MessageComposeResult result);

@interface AKShareManager : NSObject <TTWeChatShareDelegate, TTWeChatShareRequestDelegate, TTQQShareDelegate, TTQQShareRequestDelegate>

+ (instancetype)sharedManager;

/**
 *  分享接口。没有的参数传nil
 *  @param  platform            分享渠道
 *  @param  contentType         分享内容类型
 *  @param  text                消息分享文字（需contentType为text）
 *  @param  title               标题（需contentType为webPage或video）
 *  @param  description         描述（需contentType为webPage或video）
 *  @param  webPageURLString    网页链接（需contentType为webPage）
 *  @param  thumbImage          缩略图（需contentType为webPage或video）
 *  @param  thumbImageURL       缩略图URL（需contentType为webPage或video）
 *  @param  image               分享图片（需contentType为image）
 *  @param  videoURLString      分享视频（需contentType为video）
 *  @param  extra               分享业务参数，透传
 *  @param  completion          分享完成回调，包含结果及错误信息
 */
- (void)shareToPlatform:(AKSharePlatform)platform
            contentType:(AKShareContentType)contentType
                   text:(NSString *)text
                  title:(NSString *)title
            description:(NSString *)description
             webPageURL:(NSString *)webPageURLString
             thumbImage:(UIImage *)thumbImage
          thumbImageURL:(NSString *)thumbImageURL
                  image:(UIImage *)image
               videoURL:(NSString *)videoURLString
                  extra:(NSDictionary *)extra
        completionBlock:(AKShareCompletionBlock)completion;

/**
 *  获取分享信息
 *  @param  taskID              任务ID
 *  @param  shareInfoBlock      分享信息
 */
- (void)startFetchShareInfoWithTaskID:(NSInteger)taskID
                      completionBlock:(AKShareInfoBlock)shareInfoBlock;

/**
 *  发送sms消息
 *  @param  messageBody     消息内容
 *  @param  recipients      收信人
 *  @param  viewController  弹出短信弹窗的vc
 *  @param  completion      回调
 */
- (void)sendSMSMessageWithBody:(NSString *)messageBody
                    recipients:(NSArray <NSString *> *)recipients
      presentingViewController:(UIViewController *)viewController
                sendCompletion:(AKSendSMSCompletion)completion;

@end

static inline AKSharePlatform AKSharePlatformWithString(NSString *sharePlatformString) {
    if ([sharePlatformString isEqualToString:@"weixin"]) {
        return AKSharePlatformWeChat;
    } else if ([sharePlatformString isEqualToString:@"weixin_moments"]) {
        return AKSharePlatformWeChatTimeLine;
    } else if ([sharePlatformString isEqualToString:@"qq"]) {
        return AKSharePlatformQQ;
    } else if ([sharePlatformString isEqualToString:@"qzone"]) {
        return AKSharePlatformQZone;
    } else if ([sharePlatformString isEqualToString:@"sms"]) {
        return AKSharePlatformSMS;
    } else {
        return nil;
    }
}
