//
//  TTSFShareManager.h
//  Article
//
//  Created by 冯靖君 on 2017/11/26.
//

#import <Foundation/Foundation.h>
#import <TTShare/TTWeChatShare.h>
#import <TTShare/TTQQShare.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <WXApi.h>
#import <TTRoute/TTRoute.h>

// 分享业务回调
typedef void(^TTSFShareCompletionBlock)(NSDictionary *extra, NSError *error);

// 回流业务回调
typedef void(^TTSFShareRouteAction)(NSDictionary *params);

// 新人红包回调
typedef void(^TTSFNewbeeRedPackageCheckBlock)();

// 启动处理block，用于资源没有准备好时暂存
typedef BOOL(^TTSFShareManagerDelayHandleBlock)(NSDictionary *context);

// 分享渠道
typedef NS_ENUM(NSInteger, TTSFSharePlatform)
{
    TTSFSharePlatformWeChat = 0,        //微信好友
    TTSFSharePlatformWeChatTimeLine,    //朋友圈
    TTSFSharePlatformQQ,                //手Q
    TTSFSharePlatformWeitoutiao,        //端内微头条分享
    TTSFSharePlatformSaveImage,         //保存图片
    TTSFSharePlatformOthers             //其他分享（其实就是口令）
};

// 分享内容类型
typedef NS_ENUM(NSInteger, TTSFShareContentType)
{
    TTSFShareContentTypeText = 0,       //文字，适用口令场景
    TTSFShareContentTypeWebPage,        //web落地页
    TTSFShareContentTypeImage,          //图片
    TTSFShareContentTypeVideo           //视频，使用拜年小视频？
};

// 分享渠道如果走口令，内容是否后端可配
typedef NS_ENUM(NSInteger, TTSFShareWithTokenPlatform)
{
    TTSFShareWithTokenPlatformQQ = 0x1 << 0,
    TTSFShareWithTokenPlatformWeixin = 0x1 << 1,
    TTSFShareWithTokenPlatformTimeline = 0x1 << 2,
    TTSFShareWithTokenPlatformOthers = 0x1 << 3,
    TTSFShareWithTokenPlatformNone = 0
};

@interface TTSFSharePassword : NSObject

- (instancetype)initWithPlainText:(NSString *)plainText encryptText:(NSString *)encryptText;

@end

@interface TTSFShareManager : NSObject <TTWeChatShareDelegate, TTWeChatShareRequestDelegate, TTQQShareDelegate, TTQQShareRequestDelegate>

+ (instancetype)sharedManager;

/**
 *  判断分享平台是否可用
 */
+ (NSString *)checkAvailableOnPlatform:(TTSFSharePlatform)platform;

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
- (void)shareToPlatform:(TTSFSharePlatform)platform
            contentType:(TTSFShareContentType)contentType
                   text:(NSString *)text
                  title:(NSString *)title
            description:(NSString *)description
             webPageURL:(NSString *)webPageURLString
                  ttURL:(NSString *)weitoutiaoURL
             thumbImage:(UIImage *)thumbImage
          thumbImageURL:(NSString *)thumbImageURL
                  image:(UIImage *)image
               videoURL:(NSString *)videoURLString
                  extra:(NSDictionary *)extra
        completionBlock:(TTSFShareCompletionBlock)completion;

@end

@interface TTSFShareManager (OpenURLRouteAction)

/**
 *  业务层注册回流链接打开app时需要执行的动作。业务场景以外依然需要生效的，需要及早注册，推荐+load
 *  @param  action                  业务行为
 *  @param  routeActionIdentifier   对应的路由action identifier,参照TTRoute.h，格式：sslocal://target?action=routeActionIdentifier&param0=hello&param1=world
 */
+ (void)registerOpenURLAction:(TTSFShareRouteAction)action
               withIdentifier:(NSString *)routeActionIdentifier;

/**
 *  通过universalLink打开活动URL
 */
+ (BOOL)openUniversalLinkWithURL:(NSURL *)url;

/**
 *  通过scheme打开活动URL
 */
+ (BOOL)openSchemeWithURL:(NSURL *)url;

/**
 *  通过apns推送打开活动URL
 */
+ (BOOL)openRemoteNotificationWithURL:(NSURL *)url;

@end
