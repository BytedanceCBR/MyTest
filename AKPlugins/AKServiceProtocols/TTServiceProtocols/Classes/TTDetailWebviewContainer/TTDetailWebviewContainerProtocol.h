//
//  TTDetailWebviewContainerProtocol.h
//  Pods
//
//  Created by muhuai on 2017/4/27.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTDetailWebviewContainerDefine.h"
#import "TTDetailWebviewRequestProcessorDelegate.h"

#pragma mark - TTDetailFooterViewProtocol
@protocol TTDetailFooterViewProtocol <NSObject>

@property (nonatomic,strong,nonnull)  UIScrollView * footerScrollView;

@end

#pragma mark - TTDetailWebviewDelegate
@protocol TTDetailWebviewContainer, YSWebViewDelegate;
@class YSWebView;
@protocol TTDetailWebviewDelegate <NSObject, YSWebViewDelegate>

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

//scrollDelegate
- (void)webView:(id<TTDetailWebviewContainer>)webViewContainer scrollViewDidScroll:(UIScrollView *)scrollView;

//pgc 订阅
- (void)webContainer:(id<TTDetailWebviewContainer>)webViewContainer pgcId:(NSString*)pgcId Subscribe:(BOOL) isSubscribed;

@end

#pragma mark - TTDetailWebviewContainerProtocol
@class SSJSBridgeWebView, SSJSBridgeWebViewDelegate, SSThemedScrollView;
@protocol  TTDetailWebviewContainerProtocol <NSObject>

@required

@property (nonatomic, assign) TTDetailNatantStyle natantStyle;

@property (nonatomic, assign, readonly) TTDetailWebViewFooterStatus footerStatus;
@property (nonatomic, strong, readonly, nonnull) SSJSBridgeWebView * webView;
@property (nonatomic, assign) BOOL needCover; //夜间是web自己实现 还是使用遮罩

#warning TTDetailModel
//@property(nonatomic, strong,nonnull) TTDetailModel *detailModel;
@property (nonatomic, weak, nullable) id<TTDetailWebviewDelegate,TTDetailWebViewRequestProcessorDelegate> delegate;
@property (nonatomic, strong) SSThemedScrollView *containerScrollView;
//webView正文图片
@property (nonatomic, strong, nullable) NSNumber *imageMode;
@property (nonatomic, assign) CGFloat webViewContentHeight;
//webView正文视频
#warning ExploreMovieView
//@property (nonatomic, strong, nullable) ExploreMovieView *movieView;
//@property (nonatomic, strong, nullable) ExploreMovieViewModel *movieViewModel;

//自动降级, 默认为NO
@property (nonatomic, assign) BOOL needAutoDemoted;

- (id)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView hiddenWebView:(SSJSBridgeWebView *)hiddenWebView webViewDelegate:(SSJSBridgeWebViewDelegate *)jsBridgeDelegate;

- (id)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView ignoreGlobalSwitchKey:(BOOL)ignore hiddenWebView:(SSJSBridgeWebView *)hiddenWebView webViewDelegate:(SSJSBridgeWebViewDelegate *)jsBridgeDelegate;

- (void)addFooterView:(UIView<TTDetailFooterViewProtocol> *)footerView detailFooterAddType:(TTDetailNatantStyle)natantStyle;

- (void)setWebContentOffset:(CGPoint)offset;

- (void)removeFooterView;

/**
 * 只打开浮层
 */
- (void)openFooterView;

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
