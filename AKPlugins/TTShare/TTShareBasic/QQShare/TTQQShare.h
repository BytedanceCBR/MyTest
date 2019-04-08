//
//  TTQQShare.h
//  Article
//
//  Created by 王霖 on 15/9/21.
//
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

typedef NS_ENUM(int, kTTQQShareErrorType) {
    kTTQQShareErrorTypeNotInstalled = 0,
    kTTQQShareErrorTypeNotSupportAPI,
    kTTQQShareErrorTypeExceedMaxImageSize,
    kTTQQShareErrorTypeExceedMaxTextLength,
    kTTQQShareErrorTypeInvalidContent,
    kTTQQShareErrorTypeCancel,
    kTTQQShareErrorTypeOther,
};

extern NSString * const TTQQShareErrorDomain;

@class TTQQShare;

@protocol TTQQShareDelegate <NSObject>

@optional
/**
 *  qq分享回调
 *
 *  @param qqShare TTQQShare实例
 *  @param error 分享错误
 *  @param customCallbackUserInfo 用户自定义的分享回调信息
 */
- (void)qqShare:(TTQQShare *)qqShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

@end

@protocol TTQQShareRequestDelegate <NSObject>

@optional
/**
 *  来自qq请求
 *
 *  @param qqShare TTQQShare实例
 *  @param request QQ请求体
 */
- (void)qqShare:(TTQQShare *)qqShare receiveRequest:(QQBaseReq *)request;

@end

@interface TTQQShare : NSObject

@property(nonatomic, weak)id<TTQQShareDelegate> delegate;
@property(nonatomic, weak)id<TTQQShareRequestDelegate> requestDelegate;

/**
 *  QQ分享单例
 *
 *  @return QQ分享单例
 */
+ (instancetype)sharedQQShare;

/**
 *  QQ授权
 *
 *  @param appID 第三方应用在互联开放平台申请的唯一标识
 */
+ (void)registerWithID:(NSString *)appID;

/**
 *  QQ是否可用
 *
 *  @return QQ是否可用。没有安装QQ或者当前版本QQ不支持OpenApi，则返回NO。
 */
- (BOOL)isAvailable;

/**
 *  QQ SDK版本
 *
 *  @return 当前QQ SDK版本
 */
- (NSString *)currentVersion;

/*
 *  invoke in AppDelegate application:openURL:sourceApplication:annotation:
 *  如果返回YES， 其他应用就不要在handle了
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

#pragma mark - 分享到QQ好友
/**
 *  发送文本消息给好友
 *
 *  @param text 文本消息（最长1536字符。如果超过，内部会截断到1536）
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendText:(NSString *)text withCustomCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

/**
 *  发送图片给QQ好友
 *
 *  @param imageData 图片（不能超过5M）
 *  @param thumbnailImageData 缩略图（不能超过1M）
 *  @param title 图片标题（不超过128字符。如果超过，内部会截断到128）
 *  @param description 图片描述（不超过512字符。如果超过，内部会截断到512）
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendImageWithImageData:(NSData *)imageData
            thumbnailImageData:(NSData *)thumbnailImageData
                         title:(NSString *)title
                   description:(NSString *)description
        customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

/**
 *  发送图片给QQ好友，方法内部构造分享的图片的缩略图
 *
 *  @param image 图片
 *  @param title 图片标题（不超过128字符。如果超过，内部会截断到128）
 *  @param description 图片描述（不超过512字符。如果超过，内部会截断到512）
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendImage:(UIImage *)image
        withTitle:(NSString *)title
      description:(NSString *)description
customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

/**
 *  发送新闻给QQ好友。Note:缩略图可以指定的图片，也可以是指定的url。如果两个都有，使用url。
 *
 *  @param url 新闻url（不超过512字符）
 *  @param thumbnailImage 新闻缩略图
 *  @param thumbnailImageURL 新闻缩略图url（不超过512字符）
 *  @param title 新闻标题（不超过128字符。如果超过，内部会截断到128）
 *  @param description 新闻描述（不超过512字符。如果超过，内部会截断到512）
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendNewsWithURL:(NSString *)url
         thumbnailImage:(UIImage *)thumbnailImage
      thumbnailImageURL:(NSString *)thumbnailImageURL
                  title:(NSString *)title
            description:(NSString *)description
 customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

#pragma mark - 分享到QQ空间

/**
 *  发送图片到QQ空间
 *
 *  @param image 图片
 *  @param title 标题（不超过128字符。如果超过，内部会截断到128）
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendImageToQZoneWithImage:(UIImage *)image title:(NSString *)title customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

/**
 *  发送图片到QQ空间
 *  
 *  @param imageData 图片data
 *  @param thumbnailImageData 缩略图data
 *  @param title 标题（不超过128字符。如果超过，内部会截断到128）
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendImageToQZoneWithImageData:(NSData *)imageData thumbnailImageData:(NSData *)thumbnailImageData title:(NSString *)title customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

/**
 *  发送新闻到QZone。Note:如果新闻缩略图URL（imageURL）非空，使用URL指定的图片，如果新闻缩略图URL空，使用新闻缩略图（image）
 *
 *  @param url 新闻url
 *  @param thumbnailImage 新闻缩略图
 *  @param thumbnailImageURL 新闻缩略图URL（不超过512字符）
 *  @param title 新闻标题（不超过128字符。如果超过，内部会截断到128）
 *  @param description 新闻描述（不超过512字符。如果超过，内部会截断到512）
 *  @param customCallbackUserInfo 分享回调透传
 */
- (void)sendNewsToQZoneWithURL:(NSString *)url
                thumbnailImage:(UIImage *)thumbnailImage
             thumbnailImageURL:(NSString *)thumbnailImageURL
                         title:(NSString *)title
                   description:(NSString *)description
        customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

@end
