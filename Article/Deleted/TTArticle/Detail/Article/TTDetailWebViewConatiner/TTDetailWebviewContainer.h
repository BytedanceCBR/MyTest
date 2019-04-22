//
//  TTDetailWebviewContainer.h
//  Article
//
//  Created by yuxin on 4/7/16.
//
//

#import "SSThemed.h"
#import "TTArticleDetailDefine.h"
#import "ArticleJSBridgeWebView.h"
#import "SSJSBridgeWebViewDelegate.h"
#import "SSViewBase.h"
#import "TTImageInfosModel.h"
#import "ExploreMovieView.h"
#import "NewsDetailImageDownloadManager.h"
#import "TTDetailWebViewRequestProcessor.h"
#import "TTDetailModel.h"
#import "FriendDataManager.h"
#import "TTDeviceHelper.h"

NS_ASSUME_NONNULL_BEGIN
@protocol TTDetailFooterViewProtocol <NSObject>

@property (nonatomic,strong,nonnull)  UIScrollView * footerScrollView;

@end

@class TTDetailWebviewContainer;
@protocol TTDetailWebviewDelegate <NSObject>

@optional

//告知内部 是native转码页 还是web导流页
- (BOOL)webViewContentIsNativeType;

//5.7:是否需要开启footer计算优化
- (BOOL)supportFooterInsertionOptimization;

//added 5.6, 通过滚动即将展示第一条评论
- (void)webViewContainerWillShowFirstCommentCellByScrolling;

//added 5.7, 浮层处于Half状态时，通知webView的滚动offset，用于完善评论列表的impression计算。此为基于Half状态起点的相对值
- (void)webViewContainerInFooterHalfShowStatusWithScrollOffset:(CGFloat)rOffset;

//added 5.7, 拖拽隐藏insert类型的浮层
- (void)webViewWillCloseFooter;

//added 5.7, webViewContentSize发生变化
- (void)webViewDidChangeContentSize;

//webview related
- (void)webViewDidStartLoad:(nullable YSWebView *)webView;
- (void)webViewDidFinishLoad:(nullable YSWebView *)webView;
- (void)webView:(nullable YSWebView *)webView didFailLoadWithError:(nullable NSError *)error;
- (BOOL)webView:(nullable YSWebView *)webView shouldStartLoadWithRequest:(nullable NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType;

//scrollDelegate
- (void)webView:(nullable TTDetailWebviewContainer *)webViewContainer scrollViewDidScroll:(nullable UIScrollView *)scrollView;

//pgc 订阅
- (void)webContainer:(nullable TTDetailWebviewContainer *)webViewContainer pgcId:(nullable NSString*)pgcId Subscribe:(BOOL) isSubscribed;

//关注new source
- (FriendFollowNewSource)followNewSourceOfWebContainer:(nullable TTDetailWebviewContainer *)webViewContainer;

@end



@interface TTDetailWebviewContainer : SSViewBase<YSWebViewDelegate>

typedef void (^TTLoadWebImageJsCallbackBlock)(NSString * _Nonnull jsMethod);

@property (nonatomic, assign) TTDetailNatantStyle natantStyle;

@property (nonatomic, assign, readonly) TTDetailWebViewFooterStatus footerStatus;
@property (nonatomic, strong, readonly, nonnull) ArticleJSBridgeWebView * webView;
@property (nonatomic, assign) BOOL needCover; //夜间是web自己实现 还是使用遮罩

@property(nonatomic, strong,nonnull) TTDetailModel *detailModel;
@property (nonatomic, weak, nullable) id<TTDetailWebviewDelegate,TTDetailWebViewRequestProcessorDelegate> delegate;
@property (nonatomic, strong) SSThemedScrollView *containerScrollView;
//webView正文图片
@property (nonatomic, strong, nullable) NSArray <TTImageInfosModel *> *largeImageInfoModels;
@property (nonatomic, strong, nullable) NSArray <TTImageInfosModel *> *thumbImageInfoModels;
@property (nonatomic, strong, nullable) NSNumber *imageMode;
@property (nonatomic, strong, nullable) NewsDetailImageDownloadManager *downloadManager;
@property (nonatomic, copy, nullable) TTLoadWebImageJsCallbackBlock imageJsCallBackBlock;
@property (nonatomic, assign) CGFloat webViewContentHeight;
//webView正文视频
@property (nonatomic, strong, nullable) ExploreMovieView *movieView;
@property (nonatomic, strong, nullable) ExploreMovieViewModel *movieViewModel;

//自动降级, 默认为NO
@property (nonatomic, assign) BOOL needAutoDemoted;

- (nullable id)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView hiddenWebView:(ArticleJSBridgeWebView * _Nullable)hiddenWebView webViewDelegate:(SSJSBridgeWebViewDelegate * _Nullable)jsBridgeDelegate;

- (nullable id)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView ignoreGlobalSwitchKey:(BOOL)ignore hiddenWebView:(ArticleJSBridgeWebView * _Nullable)hiddenWebView webViewDelegate:(SSJSBridgeWebViewDelegate * _Nullable)jsBridgeDelegate;

- (void)addFooterView:(nonnull UIView<TTDetailFooterViewProtocol> *)footerView detailFooterAddType:(TTDetailNatantStyle)natantStyle;

- (void)setWebContentOffset:(CGPoint)offset;

- (void)removeFooterView;

/**
 * 只打开浮层
 */
- (void)openFooterView:(BOOL)isSendComment;

/**
 * 如果footerScrollView为tableView则 打开浮层并且滚动到第一条评论
 * 否则同openFooterView
 * 新版浮层中使用
 */
- (void)openFirstCommentIfNeed;

- (void)closeFooterView;

- (void)insertDivToWebViewIfNeed;

- (void)removeDivFromWebViewIfNeeded;

- (BOOL)isNatantViewVisible;

- (BOOL)isCommentVisible;

- (BOOL)isNatantViewOnOpenStatus;

- (BOOL)isManualPullFooter;

- (void)removeNatantLoadingView;

//获取最大进度
- (float)readPCTValue;

//webview页数
- (NSInteger)pageCount;
 
// 获取文章（分段后）每段内容的停留时长（格式：item_impression）
- (nonnull NSMutableDictionary *)readUnitStayTimeImpressionGroup;

- (void)refreshNatantLocation;

- (BOOL)isNewWebviewContainer;

@end

static inline CGFloat screenAdaptiveForFloatValue(CGFloat y) {
    return [TTDeviceHelper screenScale] > 1.f ? ceil(y) : floor(y);
}
NS_ASSUME_NONNULL_END
