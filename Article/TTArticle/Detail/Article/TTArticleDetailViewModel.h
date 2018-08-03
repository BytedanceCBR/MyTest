//
//  TTArticleDetailViewModel.h
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//

#import <Foundation/Foundation.h>
#import "TTDetailModel.h"
#import "TTArticleDetailDefine.h"
#import <TTNetworkManager/TTNetworkDefine.h>
#import <AKWebViewBundlePlugin/TTDetailWebContainerDefine.h>

@class YSWebView;
typedef void(^TTArticleDetailViewModelLoadHTMLFinishCallback)(NSURL * _Nullable fileURL);
//文章展示出来的样式（包含导流超时加载转码机制）
typedef NS_ENUM(NSInteger, TTArticleDetailLoadedContentType)
{
    TTArticleDetailLoadedContentTypeNative,
    TTArticleDetailLoadedContentTypeWeb
};

@interface TTArticleDetailViewModel : NSObject

- (nonnull instancetype)initWithDetailModel:(nonnull TTDetailModel *)detailModel;

- (TTDetailArchType)tt_articleDetailType;

//导流页超时加载转码页机制状态开关
- (void)tt_setWebHasBeenTransformed:(BOOL)transformed;
- (BOOL)tt_webHasBeenTransformed;
- (TTArticleDetailLoadedContentType)tt_articleDetailLoadedContentType;
- (BOOL)tt_isArticleNonCooperationWebContent;

- (void)tt_setArticleHasRead;
- (BOOL)tt_detailNeedLoadJS;
- (TTDetailNatantStyle)tt_natantStyleFromNatantLevel;

- (CGFloat)tt_getLastContentOffsetY;
- (void)tt_setContentOffsetY:(CGFloat)offsetY;
- (void)tt_uploadArticlePosition:(CGFloat)positionY finishBlock:(nullable TTNetworkJSONFinishBlock)finishBlock;

- (BOOL)tt_disableWKWebview;
@end

@interface TTArticleDetailViewModel(TTArticleDetailNativeContentCategory)
/**
 *  获取转码页的HTML， 如果不是转码页，且不是导流页超时导致加载转码页，则返回nil
 *
 *  @param webView 从该值获取webview的高宽，不会进行加载等设置
 *
 *  @return 获取转码页的HTML
 */
- (nullable NSString *)tt_nativeContentHTMLForWebView:(nullable YSWebView *)webView;


/**
 局部刷新的content内容, 只用于全局共享的webview
 @param article 需要提取cotnent内容的article
 @return 局部刷新的content内容
 */
- (nullable NSString *)tt_sharedHTMLContentWithArticle:(nonnull Article *)article;

/**
 局部刷新的模板HTML, 只用于全局共享的webview

 @return 局部刷新的模板HTML
 */
+ (nonnull NSString *)tt_sharedHTMLTemplate;

/**
 局部刷新页面的URL, 只用于全局共享的webview

 @return 页面URL
 */
+ (nullable NSURL *)tt_sharedHTMLFilePath;


/**
 局部刷新所需要的extra, 只用于全局共享的webview
 
 @return JSON String
 */
- (nullable NSString *)tt_sharedWebViewExtraJSONString;
/**
 *  获取转码页的baseURL
 *
 *  @return 如果是非转码页，且不是导流页超时导致加载转码页，返回nil
 */
- (nullable NSURL *)tt_nativeContentFilePath;


/**
 将HTML写入ios_asset目录下,然后回调
 
 回调会在主线程

 @param callback 写入完成后的回调
 */
- (void)tt_nativeContentFilePathWithWebView:(nonnull YSWebView *)webview callback:(nullable TTArticleDetailViewModelLoadHTMLFinishCallback)callback;


/**
 获取新的h5Extra, 普通webivew和全局共享webview都用这个h5extra

 @return 新h5Extra
 */
- (nullable NSDictionary *)tt_h5ExtraDictWithArticle:(nonnull Article *)article;

@end

@interface TTArticleDetailViewModel(TTArticleDetailWebContentCategory)

- (nullable NSURLRequest *)tt_requstForWebContentArticle;
- (nullable NSURLRequest *)tt_requstForWebContentArticleForURLString:(nonnull NSString *)urlString;

@end

