//
//  TTWeChatShare.h
//  Article
//
//  Created by 王霖 on 15/9/21.
//
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiObject.h"

typedef NS_ENUM(int, kTTWeChatShareErrorType) {
    kTTWeChatShareErrorTypeNotInstalled = 0,
    kTTWeChatShareErrorTypeNotSupportAPI,
    kTTWeChatShareErrorTypeExceedMaxImageSize,
    kTTWeChatShareErrorTypeExceedMaxTextSize,
    kTTWeChatShareErrorTypeInvalidContent,
    kTTWeChatShareErrorTypeCancel,
    kTTWeChatShareErrorTypeOther,
};

extern NSString * const TTWeChatShareErrorDomain;

@class TTWeChatShare;

@protocol TTWeChatShareDelegate <NSObject>

@optional
/**
 *  微信分享回调
 *
 *  @param weChatShare TTWeChatShare实例
 *  @param error 分享错误
 *  @param customCallbackUserInfo 用户自定义的分享回调信息
 */
- (void)weChatShare:(TTWeChatShare *)weChatShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;
@end

@protocol TTWeChatSharePayDelegate <NSObject>

@optional
/**
 *  微信支付回调
 *
 *  @param weChatShare TTWeChatShare实例
 *  @param payResponse 微信支付Response
 */
- (void)weChatShare:(TTWeChatShare *)weChatShare payResponse:(PayResp *)payResponse;
@end

@protocol TTWeChatShareRequestDelegate <NSObject>

@optional
/**
 *  来自微信请求
 *
 *  @param weChatShare TTWeChatShare实例
 *  @param request 微信请求体
 */
- (void)weChatShare:(TTWeChatShare *)weChatShare receiveRequest:(BaseReq *)request;
@end

@interface TTWeChatShare : NSObject

@property(nonatomic, weak)id<TTWeChatShareDelegate> delegate;
@property(nonatomic, weak)id<TTWeChatSharePayDelegate> payDelegate;
@property(nonatomic, weak)id<TTWeChatShareRequestDelegate> requestDelegate;

/**
 *  微信分享单例
 *
 *  @return 微信分享单例
 */
+ (instancetype)sharedWeChatShare;

/*! @brief WXApi的成员函数，向微信终端程序注册第三方应用。
 *
 *  需要在每次启动第三方应用程序时调用。第一次调用后，会在微信的可用应用列表中出现。 iOS7及以上系统需要调起一次微信才会出现在微信的可用应用列表中。
 *  @Attention: 请保证在主线程中调用此函数
 *
 *  @param appID 微信开发者ID
 */
+ (void)registerWithID:(NSString*)appID;

/**
 *  微信是否可用
 *
 *  @return 微信是否可用。没有安装微信或者当前版本微信不支持OpenApi，则返回NO。
 */
- (BOOL)isAvailable;

/**
 *  微信SDK版本
 *
 *  @return 当前微信SDK版本
 */
- (NSString *)currentVersion;

/**
 *  invoke in AppDelegate application:openURL:sourceApplication:annotation:
 *  如果返回YES， 其他应用就不要在handle了
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/**
 *  发送文本消息到微信
 *
 *  @param scene 发送场景
 *  @param text 发送的文本（文本长度必须小于10k。如果超过，内部会二分截断）
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendTextToScene:(enum WXScene)scene withText:(NSString *)text customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

/**
 *  发送图片到微信
 *
 *  @param scene 发送场景
 *  @param image 图片
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendImageToScene:(enum WXScene)scene withImage:(UIImage*)image customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

/**
 *  向微信发送web page多媒体消息
 *
 *  @paramm scene 发送场景
 *  @param webpageURL web page url
 *  @param thumbnailImage 缩略图
 *  @param title 标题（不能超过512字节。如果超过，内部会二分截断）
 *  @param description 摘要（不能超过1k。如果超过，内部会二分截断）
 *  @param customCallbackUserInfo 分享回调透传
 */ 
- (void)sendWebpageToScene:(enum WXScene)scene withWebpageURL:(NSString *)webpageURL thumbnailImage:(UIImage *)thumbnailImage title:(NSString*)title description:(NSString*)description customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

/**
 *  向微信发送webPage分享到微信小程序
 *
 *  @param scene 发送场景
 *  @param dict 参数字典
           目前所需参数为:group_id id(即item_id) iid(即install_id) page_type(0表示文章，1表示视频)
           最终会以'&key=value'这种形式拼在一起
 *  @param webpageURL web page url 在分享到小程序失败的时候，会降级成原来的页面分享
 *  @param thumbnailImage 缩略图
 *  @param title 标题（不能超过512字节。如果超过，内部会二分截断）
 *  @param description 摘要（不能超过1k。如果超过，内部会二分截断）
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendWebpageWithMiniProgramShareInScene:(enum WXScene)scene withParameterDict:(NSDictionary *)dict WebpageURL:(NSString *)webpageURL thumbnailImage:(UIImage *)thumbnailImage title:(NSString*)title description:(NSString*)description customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

/**
 *  向微信发送带有视频数据对象的消息
 *
 *  @paramm scene 发送场景
 *  @param videoURL 视频网页的URL（不超过10k）
 *  @param thumbnailImage 缩略图
 *  @param title 标题（不超过512字节。如果超过，内部会二分截断）
 *  @param description 摘要（不超过1K。如果超过，内部会二分截断）
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendVideoToScene:(enum WXScene)scene withVideoURL:(NSString *)videoURL thumbnailImage:(UIImage*)thumbnailImage title:(NSString*)title description:(NSString*)description customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

@end
