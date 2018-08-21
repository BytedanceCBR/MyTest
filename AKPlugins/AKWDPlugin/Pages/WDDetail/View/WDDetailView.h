//
//  WDDetailView.h
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//

#import "SSThemed.h"

@class WDDetailModel;
@class WDDetailViewModel;
@class TTDetailWebviewContainer;
@class WDDetailView;

typedef void(^WDDetailShowTitleViewBlock)(BOOL show);

//定义一些需要通知VC处理的事件
@protocol WDDetailViewDelegate <NSObject>

@optional

// web下一个网络跳转失败
- (void)tt_WDDetailWebViewNextPageFailed;

//- (void)tt_articleDetailViewShouldLoadNativeContent;
- (void)tt_WDDetailViewWillShowLargeImage;

//added 5.6, 展示第一条评论
- (void)tt_WDDetailViewWillShowFirstCommentCell;

//added 5.7, 浮层half状态时webView的相对offset
- (void)tt_WDDetailViewFooterHalfStatusOffset:(CGFloat)rOffset;

- (void)webView:(nullable TTDetailWebviewContainer *)webViewContainer scrollViewDidScroll:(nullable UIScrollView *)scrollView;

- (void)tt_articleDetailViewWillChangeFontSize;
- (void)tt_articleDetailViewDidChangeFontSize;

- (void)tt_wdDetailViewWillShowComment:(nonnull NSString *)commentID;
- (void)tt_wdDetailViewCommentDigg:(nonnull NSString *)commentID;

- (void)tt_wdDetailViewWillShowOppose:(nonnull NSDictionary *)result;
- (void)tt_wdDetailViewWillShowReport:(nonnull NSDictionary *)result;

@end

@interface WDDetailView : SSThemedView

@property(nonatomic, nonnull, strong) WDDetailViewModel *detailViewModel;
@property(nonatomic, nonnull, strong) TTDetailWebviewContainer *detailWebView;
@property(nonatomic, assign) BOOL domReady;
@property(nonatomic, assign) BOOL isNewVersion;

// titleView显示/隐藏触发高度
@property(nonatomic, assign) CGFloat titleViewAnimationTriggerPosY;

@property(nonatomic, nullable, weak) id<WDDetailViewDelegate> delegate;

- (nonnull instancetype)initWithFrame:(CGRect)frame
                          detailModel:(nullable WDDetailModel *)detailModel;


/**
 *  拿到可依赖数据后，开始渲染文章
 */
- (void)tt_startLoadWebViewContent;

/**
 *  information接口返回后更新文章
 *
 */
- (void)tt_loadInformationContent;

/**
 *  根据information返回判断是否需要删除文章
 */
- (void)tt_deleteArticleByInfoFetchedIfNeeded;

/**
 *  给文章详情页添加特定类型的浮层
 *
 *  @param footerView 浮层View
 *  @param footerScrollView 浮层View的子scrollView
 */
- (void)tt_setNatantWithFooterView:(nullable UIView *)footerView includingFooterScrollView:(nonnull UIScrollView *)footerScrollView;

- (nonnull UIScrollView *)scrollView;

/**
 *  详情页接口端监控
 *
 */
- (void)tt_initializeServerRequestMonitorWithName:(NSString * _Nullable)apiName;
- (void)tt_serverRequestTimeMonitorWithName:(NSString * _Nullable)apiName error:(NSError * _Nullable)error;

@end
