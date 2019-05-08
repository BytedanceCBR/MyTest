//
//  TTDetailWebViewRequestProcessor.h
//  Article
//
//  Created by yuxin on 4/13/16.
//
//

#import <Foundation/Foundation.h>
#import "YSWebView.h"

////////////////////////////////////////////////////////////////////////////////////////

#define kLocalSDKDetailSCheme               @"localsdk://detail"    //兼容较早相关阅读代码
#define kMediaAccountProfileHost            @"media_account"        //PGC profile
#define kShowOriginImageHost                @"origin_image"         //单张显示大图
#define kShowFullImageHost                  @"full_image"           //进入图片浏览页面
#define kWebViewShowThumbImage              @"thumb_image"          //非wifi下加载缩略图
#define kWebViewCancelimageDownload         @"cancel_image"         //用户取消下载
#define kUserProfile                        @"user_profile"         //用户主页
#define kWebViewUserClickLoadOriginImg      @"toggle_image"         //用户点击显示原图，//一键切换大图 按钮
#define kClickSource                        @"click_source"         //来源
#define kDomReady                           @"domReady"             //domReady事件

#define kBytedanceScheme                    @"bytedance"
#define kSNSSDKScheme                       @"snssdk35"
#define kDownloadAppHost                    @"download_app"
#define kCustomOpenHost                     @"custom_open"
#define kTrackURLHost                       @"track_url"
#define kCustomEventHost                    @"custom_event"
#define kKeyWordsHost                       @"keywords"
#define kArticleImpression                  @"article_impression"
#define kClientEscapeTranscodeError         @"transcode_error"      //客户端转码失败
#define kClientEscapeOpenInWebViewHost      @"open_origin_url"      //客户端转码
#define kMediaLike                          @"media_like"
#define kMediaUnlike                        @"media_unlike"



@protocol TTDetailWebViewRequestProcessorDelegate <NSObject>

@optional

/**
 *  domReady 事件
 */
- (void)processRequestReceiveDomReady;


/**
 *  打开一个webview
 *
 *  @param manager 当前的manager
 *  @param url     webview的URL
 *  @param support 是否支持旋转
 */
- (void)processRequestOpenWebViewUseURL:(nullable NSURL *)url supportRotate:(BOOL)support;
/**
 *  显示一个提示的tip
 *
 *  @param manager 当前的manager
 *  @param tipMsg  需要提示的字符串
 */
- (void)processRequestShowTipMsg:(nullable NSString *)tipMsg;

/**
 *  显示一个提示及icon的tip
 *
 *  @param manager 当前的manager
 *  @param tipMsg  需要提示的字符串
 */
- (void)processRequestShowTipMsg:(nullable NSString *)tipMsg icon:(nullable UIImage *)image;

/**
 *  需要重新加载web类型内容
 *
 *  @param manager 当前的manager
 */
- (void)processRequestNeedLoadWebTypeContent;
/**
 *  在大图浏览页现实大图
 *
 *  @param manager     当前的manager
 *  @param index       从哪张图片开始浏览
 *  @param frameValue 图片在详情页上的位置（for animation, optional）
 */
- (void)processRequestShowImgInPhotoScrollViewAtIndex:(NSUInteger)index withFrameValue:(nullable NSValue *)frameValue;
/**
 *  执行JS
 *
 *  @param manager 当前的manager
 *  @param jsStr   待执行的JS
 */
- (void)processRequestStringByEvaluatingJavaScriptFromString:(nullable NSString *)jsStr;

/**
 *  显示用户主页
 *
 *  @param manager 当前的manager
 *  @param userID  用户ID
 */
- (void)processRequestShowUserProfileForUserID:(nullable NSString *)userID;

/**
 *  打开应用商店
 *
 *  @param manager   当前的manager
 *  @param actionURL 应用商店的URL
 *  @param appleID   应用商店的ID
 */
- (void)processRequestOpenAppStoreByActionURL:(nullable NSString *)actionURL itunesID:(nullable NSString *)appleID;
/**
 *  显示PGC主页
 *
 *  @param manager    当前的manager
 *  @param paramsDict 进入PGC主页所需的参数，如media ID
 */
- (void)processRequestShowPGCProfileWithParams:(nullable NSDictionary *)paramsDict;
/**
 *  显示搜索
 *
 *  @param manager 当前的manager
 *  @param query   查询词
 *  @param type    来源类型
 *  @param index   位置
 */
- (void)processRequestShowSearchViewWithQuery:(nullable NSString *)query fromType:(NSInteger)type index:(NSUInteger)index;

/**
 *  修改article 的 imagemode
 *
 */
- (void)processRequestUpdateArticleImageMode:(nullable NSNumber*)mode;

@end


@interface TTDetailWebViewRequestProcessor : NSObject

@property (nonatomic,weak, nullable) id<TTDetailWebViewRequestProcessorDelegate> delegate;
- (BOOL)webView:(nullable YSWebView *)webView shouldStartLoadWithRequest:(nullable NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType;

@end
